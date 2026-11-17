import 'package:intl/intl.dart';

/// Parses a positive measurement using the active locale's decimal separator.
/// Grouping separators are rejected to avoid ambiguous health data.
/// Supports ASCII and Arabic-Indic decimal digits for RTL input methods.
double? parseMeasurement(String input, String locale) {
  final text = input.trim();
  // Bound untrusted input before normalization to avoid excessive work and
  // unrealistic precision in a personal health measurement.
  if (text.isEmpty || text.runes.length > 64) return null;
  final separator = NumberFormat.decimalPattern(locale).symbols.DECIMAL_SEP;
  final normalized = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      normalized.writeCharCode(rune);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      normalized.writeCharCode(rune - 0x0660 + 0x30);
    } else if (rune >= 0x06F0 && rune <= 0x06F9) {
      normalized.writeCharCode(rune - 0x06F0 + 0x30);
    } else if (String.fromCharCode(rune) == separator ||
        (locale.split(RegExp(r'[-_]')).first == 'ar' && rune == 0x066B)) {
      normalized.write('.');
    } else {
      return null;
    }
  }
  final canonical = normalized.toString();
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(canonical)) return null;
  final value = double.tryParse(canonical);
  return value != null && value.isFinite && value > 0 ? value : null;
}
