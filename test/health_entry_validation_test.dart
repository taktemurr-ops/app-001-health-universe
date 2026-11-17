import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final valid = <String, dynamic>{
    'id': 'entry-1',
    'recordedAt': '2026-11-17T08:00:00.000Z',
    'metric': 'Weight',
    'value': 72.5,
    'unit': 'kg',
  };

  test('valid persisted health entry round trips', () {
    final entry = HealthEntry.fromJson(valid);
    expect(HealthEntry.fromJson(entry.toJson()).value, 72.5);
  });

  test('invalid or nonfinite measurements are rejected on restore', () {
    for (final bad in <Object?>[0, -1, 'oops', null, double.nan, double.infinity]) {
      final payload = Map<String, dynamic>.from(valid)..['value'] = bad;
      expect(() => HealthEntry.fromJson(payload), throwsFormatException);
    }
  });

  test('missing identity and malformed timestamps are rejected', () {
    expect(() => HealthEntry.fromJson({...valid, 'id': ''}), throwsFormatException);
    expect(() => HealthEntry.fromJson({...valid, 'recordedAt': 'invalid'}), throwsFormatException);
  });

  test('corrupt saved list cannot partially replace loaded entries', () async {
    final journal = HealthJournal();
    await journal.add('Weight', 71, 'kg');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(HealthJournal.storageKey, jsonEncode([
      valid,
      {...valid, 'id': 'invalid', 'value': -2},
    ]));
    await journal.load();
    expect(journal.entries, hasLength(1));
    expect(journal.entries.single.value, 71);
    expect(prefs.getString(HealthJournal.storageKey), contains('"invalid"'));
  });
}
