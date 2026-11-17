import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_universe/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('clearAll deletes stored entries and notifies listeners', () async {
    final journal = HealthJournal();
    var notifications = 0;
    journal.addListener(() => notifications++);
    await journal.add('Weight', 70, 'kg');
    await journal.add('Water', 250, 'ml');
    expect(journal.entries.length, 2);

    await journal.clearAll();
    expect(journal.entries, isEmpty);
    expect(notifications, 3);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey(HealthJournal.storageKey), isFalse);

    final restored = HealthJournal();
    await restored.load();
    expect(restored.entries, isEmpty);
  });

  test('clearAll is safe on an empty journal', () async {
    final journal = HealthJournal();
    await journal.clearAll();
    expect(journal.entries, isEmpty);
  });
}
