import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_universe/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('health entries persist and explicit clear removes disk data', () async {
    final journal = HealthJournal();
    await journal.add('Weight', 72.5, 'kg');
    expect(journal.entries.single.value, 72.5);
    final restored = HealthJournal();
    await restored.load();
    expect(restored.entries.single.metric, 'Weight');
    await restored.clearAll();
    expect(restored.entries, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(HealthJournal.storageKey), isFalse);
  });

  test('malformed persisted records never partially restore', () async {
    final valid = HealthEntry(
      id: 'one',
      recordedAt: DateTime.utc(2026, 1, 1),
      metric: 'Weight',
      value: 70,
      unit: 'kg',
    ).toJson();
    SharedPreferences.setMockInitialValues({
      HealthJournal.storageKey: jsonEncode([valid, {'invalid': true}]),
    });
    final journal = HealthJournal();
    await journal.load();
    expect(journal.entries, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(HealthJournal.storageKey), isTrue);
  });

  test('nonfinite and nonpositive measurements are rejected', () async {
    final journal = HealthJournal();
    await expectLater(journal.add('Weight', double.nan, 'kg'), throwsArgumentError);
    await expectLater(journal.add('Weight', -1, 'kg'), throwsArgumentError);
    expect(journal.entries, isEmpty);
  });
}
