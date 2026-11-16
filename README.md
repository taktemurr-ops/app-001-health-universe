# APP-001 — Health Universe

Flutter-based privacy-first personal health journal for Android and iOS.

## Implemented initial MVP
- Record weight, heart rate, systolic and diastolic pressure, water intake, and sleep duration.
- Browse and delete measurements.
- Local persistence with shared_preferences.
- Input validation, serialization unit test, GitHub Actions analysis/test workflow.

## Run
Install Flutter SDK, then:

```sh
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

Native Android/iOS scaffolding is not committed yet and must be generated with the command above.

## Planned
Profiles, charts, export, reminders, localization, accessibility, encrypted storage, privacy controls, additional health modules, device integrations, monetization and release pipelines.

**Not a medical device. Not for diagnosis or emergency use.**

Status: initial source code committed; tests and device builds have not yet been verified.
