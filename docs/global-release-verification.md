# APP-001 global release verification matrix

Current checked-in ARB resources: **en**, **tr**, **ar**. These are translation files, not evidence of professional translation review or successful device rendering.

## Must pass before publishing
- Run `flutter gen-l10n`, `flutter analyze`, `flutter test` on the committed revision.
- Test Arabic RTL navigation, text scaling at 200%, screen readers, touch target sizes, high contrast and reduced motion on real devices.
- Verify Unicode numeric input and locale-specific decimal parsing for all supported locales.
- Confirm date, time, decimal and unit formatting; currency formatting is not yet applicable to the free journal but must be added if subscriptions are introduced.
- Review health data retention, deletion and export requirements per release region. Local `shared_preferences` storage is **not encrypted**.
- Review localized store listings and privacy disclosures with native speakers; do not claim regulatory compliance without legal review.
- Validate Android AAB and iOS archive signing, permissions and store privacy forms.

## Remaining release blockers
Native platform projects and device builds have not been independently verified. No production-ready encrypted storage, consent workflow, data export or regional legal review is implemented. Never describe the app as a diagnostic or emergency product.
