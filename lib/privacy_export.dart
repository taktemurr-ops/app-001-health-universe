import 'dart:convert';
import 'main.dart';

/// Generates a portable JSON snapshot entirely on-device.
///
/// Call only after an explicit user export action. This function does not
/// transmit, upload, log or persist personal records.
String exportHealthEntries(Iterable<HealthEntry> entries) {
  return jsonEncode({
    'schemaVersion': 1,
    'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
    'healthEntries': entries.map((entry) => entry.toJson()).toList(),
  });
}
