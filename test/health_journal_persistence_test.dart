import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('journal persists an entry and restores it after reload', () async {
    final journal = HealthJournal();
    await journal.add('Weight', 72.5, 'kg');

    final restored = HealthJournal();
    await restored.load();

    expect(restored.entries, hasLength(1));
    expect(restored.entries.single.metric, 'Weight');
    expect(restored.entries.single.value, 72.5);
    expect(restored.entries.single.unit, 'kg');
    expect(restored.entries.single.id, journal.entries.single.id);

    journal.dispose();
    restored.dispose();
  });

  test('invalid measurements are rejected without writing storage', () async {
    final journal = HealthJournal();

    for (final invalid in <double>[0, -1, double.nan, double.infinity]) {
      await expectLater(
        journal.add('Weight', invalid, 'kg'),
        throwsArgumentError,
      );
    }

    expect(journal.entries, isEmpty);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(HealthJournal.storageKey), isNull);
    journal.dispose();
  });

  test('removing an entry persists deletion', () async {
    final journal = HealthJournal();
    await journal.add('Water', 250, 'ml');
    final id = journal.entries.single.id;
    await journal.remove(id);

    final restored = HealthJournal();
    await restored.load();
    expect(restored.entries, isEmpty);

    journal.dispose();
    restored.dispose();
  });

  test('corrupt local JSON does not crash loading or overwrite the source', () async {
    const damaged = '{not-json';
    SharedPreferences.setMockInitialValues({
      HealthJournal.storageKey: damaged,
    });

    final journal = HealthJournal();
    await journal.load();
    expect(journal.entries, isEmpty);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(HealthJournal.storageKey), damaged);
    journal.dispose();
  });
}
