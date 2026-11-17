# APP-001 — Local health data integrity

Health journal entries are saved as a JSON list under `health_entries_v1` using `shared_preferences`. This storage is **not encrypted** and must not be described as secure medical-record storage.

## Validation on restore
The decoder rejects missing identifiers, invalid field types, nonpositive/nonfinite measurements and malformed timestamps. The entire saved list is parsed before in-memory state is replaced. If any item is malformed, the original saved payload is retained for recovery and the existing in-memory journal remains unchanged.

## Tests
`test/health_entry_validation_test.dart` covers JSON round trips, invalid values, malformed fields and atomic load behavior. These tests are committed but **not yet verified by a Flutter test runner**.

## Remaining release blockers
- Encrypted storage or explicit risk acceptance for sensitive records
- Safe backup/export and recoverable corruption handling
- Deletion behavior across backups and cloud sync, if later introduced
- Locale-aware validation and screen-reader testing
- GDPR/UK GDPR and other region-specific privacy assessments
- Android and iOS builds, automated test and CI verification
