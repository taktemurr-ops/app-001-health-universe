import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/measurement_parser.dart';

void main() {
  test('locale-aware measurement rejects grouping and nonfinite values', () {
    expect(parseMeasurement('12.5', 'en'), 12.5);
    expect(parseMeasurement('12,5', 'tr'), 12.5);
    expect(parseMeasurement('١٢٫٥', 'ar'), 12.5);
    expect(parseMeasurement('1,234.5', 'en'), isNull);
    expect(parseMeasurement('0', 'en'), isNull);
    expect(parseMeasurement('-3', 'en'), isNull);
    expect(parseMeasurement('12.3.4', 'en'), isNull);
    expect(parseMeasurement('9' * 65, 'en'), isNull);
  });
}
