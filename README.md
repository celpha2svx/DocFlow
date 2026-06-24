# DocFlow

Clinical calculation tool for Nigerian doctors. Built with Flutter.

## Features

- **15 medical calculators** across 5 categories: Body Metrics, Fluids & Drips, Renal, Cardiac, Paediatrics
- **Full formula transparency** — every calculation shows step-by-step working
- **Patient records** — save calculations to patient profiles (local SQLite)
- **PIN-protected access** — SHA-256 hashed, with lockout after 3 failed attempts
- **Cloud sync** — optional Firebase Firestore backup and restore
- **Offline-first** — all features work without internet; submissions queue when offline

## Tech Stack

- Flutter 3.44+ (Dart 3.12+)
- SQLite (sqflite) — local patient data
- Firebase Firestore — cloud backup + feature requests + analytics
- SharedPreferences — auth state + lockout tracking
- GitHub Actions — CI/CD (test + build)

## Setup

### Prerequisites

- Flutter SDK >=3.12.2
- Android SDK (for building APK)
- Java JDK 17+ (for release signing)

### Getting started

```bash
git clone <repo-url>
cd DocFlow/docflow_app
flutter pub get
flutter run
```

### Release signing

Before building a release APK, generate a keystore:

```bash
chmod +x generate-keystore.sh
./generate-keystore.sh
```

Then build:

```bash
flutter build apk --release
```

## Project Structure

```
docflow_app/
├── lib/
│   ├── calculators/     # Pure Dart calculation logic
│   ├── models/          # Doctor, Patient, Calculation, Category
│   ├── services/        # Database, Auth, Cloud Sync, Analytics
│   ├── screens/         # UI screens (onboarding, calculator, patient, etc.)
│   ├── widgets/         # Reusable UI components
│   └── utils/           # Constants, validators, formatters
├── test/
│   ├── calculators/     # Unit tests for each calculator
│   └── services/        # Service tests
└── android/             # Android platform config
```

## License

Clinical interpretation remains the responsibility of the attending clinician.
