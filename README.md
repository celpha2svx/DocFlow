# DocFlow

Clinical calculation tool for Nigerian doctors. Built with Flutter.

<p align="center">
  <a href="https://github.com/celpha2svx/DocFlow/releases/latest"><img src="https://img.shields.io/github/v/release/celpha2svx/DocFlow?label=version&logo=github" alt="Latest release"></a>
  <a href="https://github.com/celpha2svx/DocFlow/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/celpha2svx/DocFlow/release.yml?logo=github" alt="Release build"></a>
  <img src="https://img.shields.io/badge/flutter-3.44+-blue?logo=flutter" alt="Flutter 3.44+">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <a href="https://celpha2svx.github.io/DocFlow/"><img src="https://img.shields.io/badge/website-docs-1F4E79?logo=githubpages" alt="Website"></a>
</p>

## Features

- **50+ medical calculators** across 12 specialties — Body Metrics, Cardiac, Renal, Fluids & Drips, Paediatrics, Neurology, Respiratory, Sepsis & ICU, Obstetrics & Gynaecology, Gastroenterology, Haematology & Oncology, Endocrinology & Metabolic
- **Full formula transparency** — every calculation shows step-by-step working with substituted values
- **JSON-driven calculator engine** — new calculators added via `assets/calculators.json`, no app store update required
- **Patient records** — save calculations to patient profiles (local SQLite)
- **PIN-protected access** — SHA-256 hashed, with lockout after 3 failed attempts
- **Cloud sync** — optional Firebase Firestore backup and restore
- **Offline-first** — all features work without internet

## Calculators

| Category | Calculators |
|---|---|
| Body Metrics | BMI, BSA (Mosteller/DuBois), Ideal Body Weight (Devine) |
| Cardiac | MAP, QTc (Bazett/Fridericia), Cardiac Output & Index |
| Renal | eGFR (Cockcroft-Gault), Anion Gap, FeNa |
| Fluids & Drips | IV Drip Rate (Nigerian giving sets), Maintenance Fluids (4-2-1), Parkland Formula |
| Paediatrics | Weight by Age (Nelson/APLS), Paediatric eGFR (Schwartz), Drug Dosing |
| Neurology | GCS, NIHSS, ABCD², Revised Trauma Score, Ramsay Sedation Scale |
| Respiratory | CURB-65, Wells PE, PERC Rule, A-a Gradient, P/F Ratio (ARDS) |
| Sepsis & ICU | qSOFA, SOFA, SIRS, Shock Index, APACHE II |
| Obstetrics & Gynaecology | Naegele's EDD, Bishop Score, Preeclampsia Risk, APGAR, PPH Estimator |
| Gastroenterology | Child-Pugh, MELD, Ranson's, Glasgow-Blatchford, Rockall |
| Haematology & Oncology | ANC, CHA₂DS₂-VASc, HAS-BLED, Corrected Calcium, Transfusion Volume |
| Endocrinology & Metabolic | HbA1c ↔ eAG, Osmolality, Corrected Sodium, Bicarbonate Deficit, Burch-Wartofsky |

## Tech Stack

- Flutter 3.44+ (Dart 3.12+)
- SQLite (sqflite) — local patient data
- Firebase Firestore — optional cloud backup
- Cloudflare Workers — issue reporting (feature requests & feedback)
- SharedPreferences — auth state + lockout tracking
- GitHub Actions — CI/CD (release build triggered on `v*` tags)

## Setup

### Prerequisites

- Flutter SDK >=3.12.2
- Android SDK (for building APK)
- Java JDK 17+ (for release signing)

### Getting started

```bash
git clone https://github.com/celpha2svx/DocFlow.git
cd DocFlow/docflow_app
flutter pub get
flutter run
```

### Issue reporting (feature requests & feedback)

Feature requests and feedback are sent through a Cloudflare Worker that creates GitHub Issues. No user GitHub account needed.

**Setup:**

1. Go to https://github.com/settings/tokens?type=beta — create a fine-grained PAT with **Issues → Read and write** on this repo
2. Deploy the worker (requires a free Cloudflare account + Node.js):

```bash
cd cloudflare-worker
npm install -g wrangler
wrangler login
wrangler secret put GITHUB_TOKEN    # paste your PAT
wrangler deploy
```

3. Copy the deploy URL (e.g. `https://docflow-issues.your-subdomain.workers.dev`) and paste it into `docflow_app/lib/services/issue_reporter.dart`:

```dart
static const String _workerUrl = 'https://docflow-issues.your-subdomain.workers.dev/submit';
```

### Release signing

```bash
chmod +x generate-keystore.sh
./generate-keystore.sh
flutter build apk --release
```

## Project Structure

```
docflow_app/
├── assets/
│   └── calculators.json      # 50+ JSON-driven calculator definitions
├── lib/
│   ├── models/                # Doctor, Patient, Calculation, Category
│   ├── services/              # Database, FormulaEvaluator, CalculatorLoader, Cloud Sync
│   ├── screens/               # UI screens (onboarding, calculator, patient, etc.)
│   ├── widgets/               # Reusable UI components
│   └── utils/                 # Constants, validators, formatters
└── android/                   # Android platform config
```

## Architecture

DocFlow uses a JSON-driven calculator engine. Each calculator is defined in `assets/calculators.json` with:
- **Inputs** — typed fields (number, toggle, dropdown) with validation
- **Formulas** — evaluated by `FormulaEvaluator` (recursive descent parser) supporting arithmetic, comparisons, ternary, and 12 built-in functions
- **Results** — primary and intermediate values with units and precision
- **Interpretations** — severity-graded clinical guidance based on result thresholds
- **Transparency templates** — human-readable formula breakdown with substituted values

No app store update is needed to add new calculators — just edit the JSON file.

## License

MIT. Clinical interpretation remains the responsibility of the attending clinician.
