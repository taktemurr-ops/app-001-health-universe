import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/main.dart';

void main() {
  test('HealthEntry serializes and deserializes without losing values', () {
    final original = HealthEntry(
      id: 'entry-1',
      recordedAt: DateTime.utc(2026, 11, 16, 10, 30),
      metric: 'Weight',
      value: 72.5,
      unit: 'kg',
    );
    final restored = HealthEntry.fromJson(original.toJson());
    expect(restored.id, original.id);
    expect(restored.recordedAt, original.recordedAt);
    expect(restored.metric, original.metric);
    expect(restored.value, original.value);
    expect(restored.unit, original.unit);
  });
}
