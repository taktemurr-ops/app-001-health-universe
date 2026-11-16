import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('malformed later record cannot partially replace loaded journal', () async {
    SharedPreferences.setMockInitialValues({});
    final journal = HealthJournal();
    await journal.add('Weight', 70, 'kg');
    final originalId = journal.entries.single.id;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      HealthJournal.storageKey,
      jsonEncode([
        {
          'id': 'new-valid',
          'recordedAt': '2026-11-01T12:00:00.000',
          'metric': 'Water',
          'value': 250,
          'unit': 'ml',
        },
        {
          'id': 'broken',
          'recordedAt': 'not-a-date',
          'metric': 'Weight',
          'value': 80,
          'unit': 'kg',
        },
      ]),
    );
    final damagedPayload = preferences.getString(HealthJournal.storageKey);

    await journal.load();

    expect(journal.entries, hasLength(1));
    expect(journal.entries.single.id, originalId);
    expect(journal.entries.single.value, 70);
    expect(preferences.getString(HealthJournal.storageKey), damagedPayload);
    journal.dispose();
  });

  test('valid restored records are sorted newest first', () async {
    SharedPreferences.setMockInitialValues({
      HealthJournal.storageKey: jsonEncode([
        {
          'id': 'old',
          'recordedAt': '2025-01-01T00:00:00.000Z',
          'metric': 'Weight',
          'value': 65,
          'unit': 'kg',
        },
        {
          'id': 'new',
          'recordedAt': '2026-01-01T00:00:00.000Z',
          'metric': 'Weight',
          'value': 66,
          'unit': 'kg',
        },
      ]),
    });
    final journal = HealthJournal();
    await journal.load();
    expect(journal.entries.map((e) => e.id).toList(), ['new', 'old']);
    journal.dispose();
  });
}
