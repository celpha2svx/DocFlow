# DocFlow

Clinical calculation tool for Nigerian clinicians — doctors, medical students, and nurses. Built with Flutter. Offline-first.

<p align="center">
  <a href="https://github.com/celpha2svx/DocFlow/releases/latest"><img src="https://img.shields.io/github/v/release/celpha2svx/DocFlow?label=version&logo=github" alt="Latest release"></a>
  <a href="https://github.com/celpha2svx/DocFlow/actions/workflows/release.yml"><img src="https://img.shields.io/github/actions/workflow/status/celpha2svx/DocFlow/release.yml?logo=github" alt="Release build"></a>
  <img src="https://img.shields.io/badge/flutter-3.44+-blue?logo=flutter" alt="Flutter 3.44+">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  <a href="https://celpha2svx.github.io/DocFlow/"><img src="https://img.shields.io/badge/website-docs-1F4E79?logo=githubpages" alt="Website"></a>
</p>

## What it does

DocFlow is a fast bedside calculator app for clinical decision-making. Every calculation shows the formula, the substituted values, and the primary citation. No internet required after first install.

**175 clinical calculators** across **15 specialties** — every one with a published source (WHO, ACC, AHA, NICE, KDIGO, SCCM, etc.).

## Features

- **175 evidence-based calculators** — sourced from WHO, ACC/AHA, KDIGO, NICE, Surviving Sepsis, ASHP, and other authoritative guidelines
- **Full formula transparency** — every calculation shows the formula with substituted values so you can verify
- **Source citation** — every result screen shows the primary reference (PMID or guideline body + year)
- **JSON-driven calculator engine** — new calculators added via `assets/calculators.json`, no app store update required
- **In-place app updates** — Settings → Check for Updates downloads and installs the APK without uninstalling or losing data
- **Patient records** — save calculations to patient profiles (local SQLite)
- **PIN-protected access** — SHA-256 hashed, with lockout after 3 failed attempts
- **Profile editor** — name, title (Dr./Nurse/Prof./etc.), specialty, phone
- **Offline-first** — all features work without internet

## Calculator categories

| Category | Examples |
|---|---|
| **Cardiac** | MAP, QTc (Bazett/Fridericia), CHA₂DS₂-VASc, HAS-BLED, ATRIA, ASCVD risk, HEART score, TIMI (STEMI/NSTEMI), GRACE, Wells (PE/DVT), Geneva, age-adjusted D-dimer, PESI, Framingham CHF risk |
| **Renal** | eGFR (Cockcroft-Gault / MDRD / CKD-EPI 2021 race-free), FeNa, FeUrea, Anion Gap, CKD staging, RIFLE/AKIN, Kt/V, URR, TTKG, urine anion gap |
| **Fluids & Drips** | IV Drip Rate, Maintenance Fluids (4-2-1), Parkland, Brooke (modified), free water deficit, sodium deficit, hypertonic saline, potassium replacement, fluid balance |
| **Sepsis & ICU** | qSOFA, SOFA, SIRS, MEWS, NEWS2, SAPS II, SAPS 3, APACHE II, lactate clearance, shock index, ARDSNet tidal volume |
| **Respiratory** | CURB-65, PERC, Wells PE, P/F ratio (Berlin ARDS), SF ratio, A-a gradient, BODE, GOLD staging, alveolar gas equation, shunt fraction, O₂ delivery/consumption |
| **Endocrinology & Metabolic** | HbA1c ↔ eAG, osmolality, corrected sodium (Katz), bicarbonate deficit, Burch-Wartofsky (thyroid storm), HOMA-IR, QUICKI, DKA severity, HHS criteria, hyperkalaemia treatment, hyponatraemia correction |
| **Paediatrics** | Weight by age (Nelson/APLS), Schwartz eGFR, paediatric drug dosing (Clark/Fried/Young), Bhutani nomogram, Westley croup, paediatric trauma score, ORS (WHO), 20 mL/kg bolus (PALS), Ballard/Downes/Silverman-Anderson, neonatal BP/hypoglycaemia/sepsis |
| **Neurology** | GCS, NIHSS, ABCD², Revised Trauma Score |
| **Obstetrics & Gynaecology** | EDD (Naegele), APGAR, Bishop, BPP, MgSO₄ (eclampsia), gestational diabetes (IADPSG), PCOS (Rotterdam), EPDS, OHSS, Hadlock fetal weight, fetal lung maturity, cervical cancer (ASCCP), Pearl Index |
| **Gastroenterology** | Child-Pugh, MELD, MELD-Na, Ranson, BISAP, Glasgow-Blatchford, AIMS65, Oakland, Rockall, FIB-4, APRI |
| **Haematology & Oncology** | ANC, ALC, MASCC, correct calcium, transfusion volume, total blood volume (Nadler), Calvert (carboplatin), tumour lysis syndrome |
| **Tropical & Infectious Disease** *(Nigeria-focused)* | Malaria density, cholera (WHO Plan A/B/C), Lassa fever triage, snakebite (20WBCT), rabies PEP (Essen/Zagreb), TB treatment phase, HIV CD4/CD8, Widal interpretation, dengue severity (WHO 2009), measles risk, bacterial meningitis score |
| **Body Metrics** | BMI, BSA (Mosteller/DuBois), IBW (Devine), ABW, LBM (Boer), WHR, WHtR |
| **Emergency & Trauma** | STOP-BANG, Caprini, Padua, RCRI (Lee), Canadian C-Spine, NEXUS, Ottawa Ankle, LA toxicity (max dose), LAST/Intralipid (ASRA), NAC paracetamol (Prescott), phenytoin loading |
| **Psychiatry** | HAM-D 17, YMRS, C-SSRS screening |

## Drug dosing calculators (most-requested in real life)

- Vancomycin AUC-guided dosing (ASHP/IDSA 2020)
- Gentamicin once-daily (Hartford nomogram)
- Amikacin
- Enoxaparin prophylaxis (NICE NG89) and treatment (ACCP)
- Warfarin loading (Fennerty)
- Insulin sliding scale (Endocrine Society)
- IV drug Y-site compatibility (ASHP Trissel)

## Tech Stack

- **Flutter 3.44+** (Dart 3.12+) — single codebase, Android-first
- **SQLite (sqflite)** — local patient data
- **Cloudflare Workers** — issue reporting (feature requests & feedback)
- **SharedPreferences** — auth state + lockout tracking
- **GitHub Actions** — CI/CD (release build triggered on `v*` tags)
- **No Firebase dependency** — Firebase plugin is applied only if `google-services.json` exists; otherwise the app builds and runs offline-only

## Setup

### Prerequisites

- Flutter SDK >= 3.12.2
- Android SDK (for building APK)
- Java JDK 17+ (for release signing)

### Local development

```bash
git clone https://github.com/celpha2svx/DocFlow.git
cd DocFlow/docflow_app
flutter pub get
flutter run
```

### Issue reporting (feature requests & feedback)

The app's "Request a Feature" button sends to a Cloudflare Worker that creates a GitHub Issue. The user does not need a GitHub account.

**Setup:**

1. Create a fine-grained PAT at https://github.com/settings/tokens?type=beta — give it **Issues → Read and write** on `celpha2svx/DocFlow`
2. Deploy the worker (free Cloudflare account + Node.js required):

```bash
cd cloudflare-worker
npm install -g wrangler
wrangler login
wrangler secret put GITHUB_TOKEN    # paste your PAT
wrangler deploy
```

3. Copy the worker URL and paste into `docflow_app/lib/services/issue_reporter.dart`:

```dart
static const String _workerUrl = 'https://docflow-issues.YOUR-SUBDOMAIN.workers.dev/submit';
```

## Architecture

### JSON-driven calculator engine

Each calculator is defined in `assets/calculators.json` with:

- **Inputs** — typed fields (`number`, `toggle`, `dropdown`) with validation, units, and unit toggles
- **Formulas** — evaluated by `FormulaEvaluator` (recursive descent parser) supporting arithmetic, comparisons, ternary, and 12 built-in functions
- **Results** — primary and intermediate values with units and precision
- **Interpretations** — severity-graded clinical guidance (`normal` / `warning` / `high`) with detail text
- **Transparency templates** — human-readable formula breakdown with substituted values
- **Source** — primary citation (PMID or guideline body + year), shown on the result screen

The app loads `calculators.json` from bundled assets on first launch, then fetches the latest version from GitHub on subsequent launches. So new calculators added to the JSON file become available to all users without an app store update — only an in-place APK update is needed.

### Adding a new calculator

Edit `docflow_app/assets/calculators.json` and add an entry:

```json
{
  "id": "my_calc",
  "name": "My Calculator",
  "category": "Cardiac",
  "description": "What it does.",
  "inputs": [
    {"id": "weight", "label": "Weight", "type": "number", "unit": "kg", "required": true}
  ],
  "results": [
    {"key": "score", "label": "Score", "formula": "weight * 0.1", "unit": "mg", "decimals": 1, "is_primary": true}
  ],
  "interpretations": [
    {"condition": "score > 50", "label": "High", "severity": "warning"}
  ],
  "transparency_template": "Score = weight × 0.1 = {weight} × 0.1 = {score}",
  "source": "Author et al. Journal. Year;Volume:Pages."
}
```

### Release flow

1. Push commits to `main`
2. Tag with `v*` (e.g. `v1.2.3`) and push tag
3. GitHub Actions builds the release APK using the saved signing keystore (configured as `KEYSTORE_BASE64` and `KEYSTORE_PASSWORD` GitHub Secrets)
4. APK appears at `https://github.com/celpha2svx/DocFlow/releases/latest`
5. Users tap **Settings → Check for Updates** in the app, the new APK downloads and installs in-place (no uninstall required)

## Project structure

```
docflow_app/
├── assets/
│   └── calculators.json       # 175 JSON-driven calculator definitions with citations
├── lib/
│   ├── models/                 # Doctor, Patient, Calculation, Category
│   ├── services/               # Database, FormulaEvaluator, CalculatorLoader, UpdateService
│   ├── screens/                # UI screens (onboarding, calculator, patient, settings, ...)
│   ├── widgets/                # Reusable UI components
│   └── utils/                  # Constants, validators, formatters
└── android/                    # Android platform config + keystore handling
```

## License

MIT. Clinical interpretation remains the responsibility of the attending clinician.