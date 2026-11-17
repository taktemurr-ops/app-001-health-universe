# Health Universe — English store and privacy draft

**Short description:** Private offline journal for everyday wellness measurements.

**Description:** Record weight, pulse, blood pressure, water intake and sleep duration. Review and delete your entries on your device. This app is a personal journal, not a medical device or emergency service.

## Data handling — current MVP
- Health measurements and timestamps are stored locally using shared_preferences.
- Local storage is **not encrypted**. Anyone with access to an unlocked or compromised device or backup may be able to read these records.
- No account, cloud sync, analytics, advertising or remote upload is implemented in the current source.
- Users can delete individual measurements; complete account/device data erasure, export and retention controls are **not yet implemented**.
- Do not enter clinical records or sensitive diagnoses. Do not use for medical decisions.

## Release blockers
Implement encrypted storage and an explicit delete-all control; verify Android backup policy, privacy labels, accessibility and locale behavior; conduct security review before publishing. This draft is **not** a final legal privacy policy.
