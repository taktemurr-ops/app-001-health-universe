# Internationalization and regional readiness

## Verified translation assets
- English (`en`) — default template, `lib/l10n/app_en.arb`
- Turkish (`tr`) — `lib/l10n/app_tr.arb`

These are the only translation assets verified in this repository. Their presence does not prove native-speaker review, accessibility compliance, or a passing device build.

## Adding a locale
1. Copy `app_en.arb` to `app_<locale>.arb` using a supported BCP 47 language/region code compatible with Flutter gen-l10n file naming.
2. Set `@@locale` correctly, translate all message values, and preserve named placeholders and their metadata.
3. Run `flutter gen-l10n`, `flutter analyze`, and `flutter test`; verify layout at large text scale and with screen readers.
4. For RTL locales (e.g. Arabic), test directionality, input cursor behavior, number/date formatting, icons and bidirectional mixed-script content on real devices.
5. Localize store descriptions and screenshots independently; review medical terminology and claims before publication.

## Regional privacy and safety release gate
This application records personal health information locally. Local storage is not equivalent to encrypted storage. Before any public release, review device backup behavior, deletion/export expectations, access controls, analytics and crash-reporting data flows, consent, retention, and applicable regional health-data rules. Avoid claiming HIPAA/GDPR compliance without legal and technical assessment.

The application is a journal, not a medical device or emergency service. Verify that translations preserve this limitation. Date, decimal, measurement-unit and currency formatting must use the active locale and explicit region-specific rules; do not assume every locale uses the same measurement system.

## Automated checks
`test/arb_contract_test.dart` checks English/Turkish key and placeholder parity and validates locale declarations for all shipped ARB files. CI runs `flutter analyze` and `flutter test`. These checks are necessary but not sufficient for localization quality.
