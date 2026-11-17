import 'package:intl/intl.dart';

/// Parses a positive measurement using the active locale's decimal separator.
/// Grouping separators are rejected to avoid ambiguous health data.
double? parseMeasurement(String input, String locale) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final separator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;
  final normalized = separator == '.' ? text : text.replaceAll(separator, '.');
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(normalized)) return null;
  final value = double.tryParse(normalized);
  return value != null && value.isFinite && value > 0 ? value : null;
}
