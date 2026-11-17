# Locale-aware health measurement input

The measurement parser accepts positive, finite decimal values only. It uses the
active Flutter/intl locale's decimal separator, rejects grouping separators,
scientific notation and signs, and normalizes ASCII (0-9), Arabic-Indic
(٠-٩), and Eastern Arabic-Indic (۰-۹) digits.

## Safety and localization contract

- Use the selected app locale, not the device keyboard locale, to determine
  the decimal separator. Never silently guess a different separator.
- Display the saved numeric value using `NumberFormat` with the active locale.
- Do not change stored measurements when users switch languages.
- Invalid or ambiguous input must not be persisted.
- Arabic digit input support does **not** imply Arabic UI translation is complete.
- RTL layouts, screen-reader labels, large text, and translated error messages
  require separate UI checks.
- Health records are sensitive: do not log measurement values in CI, analytics,
  crash reports, or error messages.

## Verification

Run `flutter pub get && flutter analyze && flutter test` in CI.
Manually verify decimal entry using English and Turkish keyboards, then Arabic
and Persian keyboards, including pasted Unicode numerals. Confirm screen-reader
announcements and right-to-left field alignment on devices.

The added tests cover parser behavior only; they do not certify end-to-end
localization, regulatory compliance, or production readiness.
