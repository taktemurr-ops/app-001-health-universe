import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';
import 'package:health_universe/privacy_export.dart';

void main() {
  test('export retains Unicode metric, unit, measurement and record identity', () {
    final at = DateTime.utc(2026, 11, 17, 10, 30);
    final entry = HealthEntry(
      id: 'ölçüm-١', recordedAt: at, metric: 'Kalp hızı ❤️',
      value: 72.5, unit: 'atım/dk',
    );
    final payload = jsonDecode(exportHealthEntries([entry])) as Map<String, dynamic>;
    final records = payload['healthEntries'] as List<dynamic>;
    expect(records.length, 1);
    final restored = HealthEntry.fromJson(
      Map<String, dynamic>.from(records.single as Map),
    );
    expect(restored.id, entry.id);
    expect(restored.metric, entry.metric);
    expect(restored.value, entry.value);
    expect(restored.unit, entry.unit);
    expect(restored.recordedAt, at);
  });

  test('export contains no extra transport or storage metadata', () {
    final payload = jsonDecode(exportHealthEntries([])) as Map<String, dynamic>;
    expect(payload.keys.toSet(), {'schemaVersion', 'exportedAtUtc', 'healthEntries'});
    expect(payload['healthEntries'], isEmpty);
  });
}
