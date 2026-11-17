import 'package:flutter_test/flutter_test.dart';
import 'package:health_universe/measurement_parser.dart';
import 'package:intl/intl.dart';

void main() {
  test('English decimal input', () {
    expect(parseMeasurement('12.5', 'en'), 12.5);
    expect(parseMeasurement('12,5', 'en'), isNull);
  });

  test('Turkish decimal input', () {
    expect(parseMeasurement('12,5', 'tr'), 12.5);
    expect(parseMeasurement('12.5', 'tr'), isNull);
  });

  test('Arabic-Indic digits and locale decimal separator', () {
    final separator = NumberFormat.decimalPattern('ar').symbols.DECIMAL_SEP;
    expect(parseMeasurement('١٢${separator}٥', 'ar'), 12.5);
    expect(parseMeasurement('۱۲${separator}۵', 'ar'), 12.5);
    expect(parseMeasurement('١٢,٥', 'en'), isNull);
  });

  test('rejects grouping, invalid and unsafe values', () {
    for (final input in [
      '1,234.5', '1.234,5', '-2', '0', 'NaN',
      'Infinity', '1e6', '1 000', '', '  ',
    ]) {
      expect(parseMeasurement(input, 'en'), isNull, reason: input);
    }
    expect(parseMeasurement(' 3.25 ', 'en'), 3.25);
  });
}
