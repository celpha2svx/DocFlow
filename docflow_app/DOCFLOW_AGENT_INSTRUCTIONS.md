# DocFlow — AI Agent Build Instructions
> Complete specification for building the DocFlow clinical calculator app for Nigerian doctors.
> Stack: Flutter + SQLite + Firebase Firestore
> Every file path, formula, UI screen, and database schema is defined here.

---

## 0. CONTEXT & RULES

- This is a **production medical app**, not a demo. Treat every calculation as safety-critical.
- Every calculation result **must** include a `transparency` string showing the full step-by-step working.
- All calculator logic lives in `lib/calculators/`. Pure Dart — no Flutter imports in these files.
- Every calculator file has a corresponding test file in `test/calculators/`.
- Tests must verify **exact numeric results** using real clinical values, not placeholder data.
- Never use `import` statements anywhere except the top of each file.
- UI is built **after** all calculator logic and tests pass.

---

## 1. COMPLETE FILE STRUCTURE

```
docflow_app/
├── .github/
│   └── workflows/
│       └── main.yml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── screens/
│   │   ├── onboarding_screen.dart
│   │   ├── pin_screen.dart
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   ├── category_screen.dart
│   │   ├── calculator_screen.dart
│   │   ├── result_screen.dart
│   │   ├── patient_list_screen.dart
│   │   ├── patient_detail_screen.dart
│   │   ├── save_to_patient_screen.dart
│   │   ├── settings_screen.dart
│   │   └── feature_request_screen.dart
│   ├── models/
│   │   ├── doctor.dart
│   │   ├── patient.dart
│   │   ├── calculation.dart
│   │   └── category.dart
│   ├── services/
│   │   ├── database_service.dart
│   │   ├── auth_service.dart
│   │   ├── cloud_sync_service.dart
│   │   └── analytics_service.dart
│   ├── calculators/
│   │   ├── body_metrics.dart        ✅ DONE
│   │   ├── fluids_drips.dart        ✅ DONE
│   │   ├── renal.dart               ✅ DONE
│   │   ├── cardiac.dart             ← BUILD NEXT
│   │   └── paediatrics.dart
│   ├── widgets/
│   │   ├── category_card.dart
│   │   ├── calculator_input.dart
│   │   ├── formula_display.dart
│   │   ├── result_display.dart
│   │   └── patient_card.dart
│   └── utils/
│       ├── constants.dart
│       ├── validators.dart
│       └── formatters.dart
├── test/
│   ├── calculators/
│   │   ├── body_metrics_test.dart   ✅ DONE (9 tests)
│   │   ├── fluids_drips_test.dart   ✅ DONE (10 tests)
│   │   ├── renal_test.dart          ✅ DONE (8 tests)
│   │   ├── cardiac_test.dart        ← BUILD NEXT
│   │   └── paediatrics_test.dart
│   └── services/
│       └── database_service_test.dart
├── assets/
│   ├── images/
│   └── fonts/
└── pubspec.yaml
```

---

## 2. DEPENDENCIES (pubspec.yaml — already set)

```yaml
dependencies:
  sqflite: ^2.3.0
  path_provider: ^2.1.0
  shared_preferences: ^2.2.0
  share_plus: ^7.2.1
  uuid: ^4.3.3
  connectivity_plus: ^5.0.2
  crypto: ^3.0.3
```

---

## 3. CALCULATOR SPECIFICATIONS

### Already built and passing:
- `lib/calculators/body_metrics.dart` — BMI, BSA (Mosteller + DuBois), IBW (Devine)
- `lib/calculators/fluids_drips.dart` — IV Drip Rate, Maintenance Fluids (4-2-1), Parkland Formula
- `lib/calculators/renal.dart` — eGFR (Cockcroft-Gault), Anion Gap, FeNa

---

### 3.4 CARDIAC — `lib/calculators/cardiac.dart`

#### 3.4.1 Mean Arterial Pressure (MAP)

```
Formula: MAP = Diastolic + (Systolic - Diastolic) / 3
Equivalent: (Systolic + 2 × Diastolic) / 3
Normal range: 70–100 mmHg
Critical threshold: < 65 mmHg requires immediate intervention
```

Result class:
```dart
class MAPResult {
  final double value;
  final String interpretation;
  final String transparency;
}
```

Interpretation logic:
- `< 65` → `'Critical — immediate intervention required'`
- `65–70` → `'Low normal — monitor closely'`
- `70–100` → `'Normal'`
- `> 100` → `'Elevated — assess for hypertensive emergency'`

Transparency must show both formula forms and the full substitution.

---

#### 3.4.2 Corrected QT Interval (QTc)

```
Type 1 — Bazett's Formula (default, most common in Nigeria):
  QTc = QT / √(RR)
  Where RR = 60 / Heart Rate (in seconds)

Type 2 — Fridericia Formula (for HR < 60 or HR > 100):
  QTc = QT / ∛(RR)

Inputs: QT interval (ms), Heart Rate (bpm)
Normal QTc: < 440ms (male), < 460ms (female)
Prolonged: > 500ms — high risk of Torsades de Pointes
```

Result class:
```dart
class QTcResult {
  final double bazett;
  final double fridericia;
  final String interpretation;
  final String transparency;
}
```

Interpretation logic (use Bazett as primary):
- `< 440` → `'Normal'`
- `440–500` → `'Borderline prolonged — review QT-prolonging medications'`
- `> 500` → `'Critically prolonged — high risk of Torsades de Pointes'`

---

#### 3.4.3 Cardiac Output (CO)

```
Formula: CO = Heart Rate (bpm) × Stroke Volume (mL)
Normal CO: 4.0–8.0 L/min
Cardiac Index = CO / BSA (links to BSA from body_metrics.dart)
```

Result class:
```dart
class CardiacOutputResult {
  final double cardiacOutput;      // L/min
  final double? cardiacIndex;      // L/min/m² (optional, if BSA provided)
  final String interpretation;
  final String transparency;
}
```

Interpretation:
- `< 4.0` → `'Low — assess for cardiogenic shock'`
- `4.0–8.0` → `'Normal'`
- `> 8.0` → `'Elevated — assess for high-output state'`

---

### 3.5 PAEDIATRICS — `lib/calculators/paediatrics.dart`

#### 3.5.1 Weight Estimation by Age

```
Type 1 — APLS Formula (1–12 years):
  Weight (kg) = (Age + 4) × 2

Type 2 — Nelson's Formula (1–5 years, West African validated):
  Weight (kg) = (Age × 2) + 8

Both results returned. Nelson's shown as primary for ages 1–5.
Age must be between 1 and 12 years. Return error string outside this range.
```

Result class:
```dart
class WeightEstimationResult {
  final double apls;
  final double? nelsons;       // null if age > 5
  final double recommended;    // nelsons for 1-5, apls for 6-12
  final String transparency;
}
```

---

#### 3.5.2 Paediatric eGFR (Modified Schwartz)

```
Formula: eGFR = (0.413 × Height (cm)) / Serum Creatinine (mg/dL)
Use only for patients under 18 years.
Normal: > 90 mL/min/1.73m²
```

Result class:
```dart
class SchwartzResult {
  final double egfr;
  final String stage;
  final String transparency;
}
```

CKD staging same thresholds as adult eGFR (G1–G5).

---

#### 3.5.3 Paediatric Drug Dosing Helper

```
This is a dose calculator, not a drug database.
Takes: drug dose in mg/kg/dose or mg/kg/day, patient weight, frequency
Returns: single dose in mg, daily total in mg

Formula:
  Single dose (mg) = Dose (mg/kg) × Weight (kg)
  Daily total (mg) = Single dose × Frequency per day
```

Result class:
```dart
class PaedDoseResult {
  final double singleDoseMg;
  final double dailyTotalMg;
  final String transparency;
}
```

Common presets to include in `utils/constants.dart`:
```dart
// Paediatric dose reference (mg/kg/dose)
const Map<String, Map<String, dynamic>> paedDosePresets = {
  'Paracetamol': {'dose': 15.0, 'maxSingleDose': 1000.0, 'frequency': 4, 'unit': 'mg/kg/dose'},
  'Amoxicillin': {'dose': 25.0, 'maxSingleDose': 500.0, 'frequency': 3, 'unit': 'mg/kg/dose'},
  'Ibuprofen':   {'dose': 10.0, 'maxSingleDose': 400.0, 'frequency': 3, 'unit': 'mg/kg/dose'},
};
```

---

## 4. TEST SPECIFICATIONS

### 4.4 `test/calculators/cardiac_test.dart`

```
MAP tests:
  - systolic 120, diastolic 80 → 93.3 mmHg, Normal
  - systolic 90, diastolic 50  → 63.3 mmHg, Critical
  - systolic 180, diastolic 110 → 133.3 mmHg, Elevated

QTc tests:
  - QT 400ms, HR 60 → Bazett: 400ms, Normal
  - QT 480ms, HR 72 → Bazett prolonged, verify > 440
  - Fridericia always returned alongside Bazett
  - Transparency contains both formula names

Cardiac Output tests:
  - HR 72, SV 70 → CO 5.04 L/min, Normal
  - HR 50, SV 40 → CO 2.0 L/min, Low
  - With BSA 1.8 → cardiac index = CO / 1.8
```

### 4.5 `test/calculators/paediatrics_test.dart`

```
Weight Estimation tests:
  - Age 3: Nelson's = (3×2)+8 = 14kg, APLS = (3+4)×2 = 14kg
  - Age 8: APLS = (8+4)×2 = 24kg, Nelson's = null
  - Age 0 or 13: returns error
  - recommended = nelsons for age 1-5, apls for age 6-12

Schwartz eGFR tests:
  - Height 120cm, creatinine 0.5 → eGFR = (0.413 × 120) / 0.5 = 99.1, G1
  - Height 100cm, creatinine 2.0 → eGFR = (0.413 × 100) / 2.0 = 20.65, G5

Paed Dose tests:
  - Paracetamol 15mg/kg, 20kg → 300mg single dose, 1200mg daily (×4)
  - Amoxicillin 25mg/kg, 15kg → 375mg single dose
  - Max dose cap: 25mg/kg × 100kg does not exceed maxSingleDose
```

---

## 5. DATABASE SCHEMA

File: `lib/services/database_service.dart`

```sql
CREATE TABLE doctors (
  id TEXT PRIMARY KEY,
  full_name TEXT NOT NULL,
  phone_number TEXT UNIQUE NOT NULL,
  specialty TEXT,
  pin_hash TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE patients (
  id TEXT PRIMARY KEY,
  doctor_phone TEXT NOT NULL,
  full_name TEXT NOT NULL,
  hospital_number TEXT,
  age INTEGER,
  sex TEXT,
  weight_kg REAL,
  diagnosis TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE calculations (
  id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL,
  doctor_phone TEXT NOT NULL,
  calculator_type TEXT NOT NULL,
  category TEXT NOT NULL,
  input_values TEXT NOT NULL,
  result_value REAL NOT NULL,
  result_unit TEXT NOT NULL,
  result_label TEXT NOT NULL,
  transparency TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patients(id)
);

CREATE INDEX idx_patient_name ON patients(full_name);
CREATE INDEX idx_patient_hospital ON patients(hospital_number);
CREATE INDEX idx_calc_patient ON calculations(patient_id);
CREATE INDEX idx_calc_type ON calculations(calculator_type);
CREATE INDEX idx_calc_date ON calculations(created_at);
```

### DatabaseService methods required:

```dart
// Patients
Future<void> insertPatient(Patient patient);
Future<List<Patient>> searchPatients(String query, String doctorPhone);
Future<Patient?> getPatient(String id);
Future<void> updatePatient(Patient patient);
Future<void> deletePatient(String id);

// Calculations
Future<void> saveCalculation(Calculation calc);
Future<List<Calculation>> getPatientHistory(String patientId);
Future<List<Calculation>> getRecentCalculations(String doctorPhone, {int limit = 20});

// Doctor
Future<void> saveDoctor(Doctor doctor);
Future<Doctor?> getDoctor(String phoneNumber);
```

---

## 6. MODELS

### `lib/models/doctor.dart`
```dart
class Doctor {
  final String id;           // UUID
  final String fullName;
  final String phoneNumber;  // Unique ID
  final String? specialty;
  final String pinHash;      // SHA-256 hashed
  final DateTime createdAt;
}
```

### `lib/models/patient.dart`
```dart
class Patient {
  final String id;           // UUID
  final String doctorPhone;
  final String fullName;
  final String? hospitalNumber;
  final int? age;
  final String? sex;         // 'Male' | 'Female'
  final double? weightKg;
  final String? diagnosis;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### `lib/models/calculation.dart`
```dart
class Calculation {
  final String id;           // UUID
  final String patientId;
  final String doctorPhone;
  final String calculatorType;  // e.g. 'iv_drip_rate'
  final String category;        // e.g. 'Fluids & Drips'
  final Map<String, dynamic> inputValues;  // stored as JSON
  final double resultValue;
  final String resultUnit;
  final String resultLabel;
  final String transparency;
  final DateTime createdAt;
}
```

### `lib/models/category.dart`
```dart
class Category {
  final String name;
  final String icon;
  final List<CalculatorMeta> calculators;
}

class CalculatorMeta {
  final String id;        // e.g. 'iv_drip_rate'
  final String name;      // e.g. 'IV Drip Rate'
  final String category;
  final List<String> searchTags;
}
```

---

## 7. CATEGORY & CALCULATOR REGISTRY

File: `lib/utils/constants.dart`

```dart
final List<Category> categories = [
  Category(
    name: 'Body Metrics',
    icon: '🧍',
    calculators: [
      CalculatorMeta(id: 'bmi', name: 'Body Mass Index (BMI)',
        searchTags: ['bmi', 'weight', 'obesity', 'body mass']),
      CalculatorMeta(id: 'bsa', name: 'Body Surface Area (BSA)',
        searchTags: ['bsa', 'surface area', 'oncology', 'chemo']),
      CalculatorMeta(id: 'ibw', name: 'Ideal Body Weight (IBW)',
        searchTags: ['ibw', 'ideal weight', 'ventilator', 'tidal volume']),
    ],
  ),
  Category(
    name: 'Fluids & Drips',
    icon: '💧',
    calculators: [
      CalculatorMeta(id: 'iv_drip_rate', name: 'IV Drip Rate',
        searchTags: ['drip', 'iv', 'infusion', 'drops', 'gtt']),
      CalculatorMeta(id: 'maintenance_fluid', name: 'Maintenance Fluids (4-2-1)',
        searchTags: ['maintenance', 'fluid', 'holliday', 'segar', '421']),
      CalculatorMeta(id: 'parkland', name: 'Parkland Formula (Burns)',
        searchTags: ['parkland', 'burns', 'tbsa', 'fluid resuscitation']),
    ],
  ),
  Category(
    name: 'Renal',
    icon: '🫘',
    calculators: [
      CalculatorMeta(id: 'egfr', name: 'eGFR (Cockcroft-Gault)',
        searchTags: ['egfr', 'gfr', 'kidney', 'creatinine', 'renal function', 'ckd']),
      CalculatorMeta(id: 'anion_gap', name: 'Anion Gap',
        searchTags: ['anion gap', 'dka', 'acidosis', 'metabolic']),
      CalculatorMeta(id: 'fena', name: 'Fractional Excretion of Sodium (FeNa)',
        searchTags: ['fena', 'sodium', 'aki', 'prerenal', 'atn']),
    ],
  ),
  Category(
    name: 'Cardiac',
    icon: '❤️',
    calculators: [
      CalculatorMeta(id: 'map', name: 'Mean Arterial Pressure (MAP)',
        searchTags: ['map', 'blood pressure', 'perfusion', 'icu']),
      CalculatorMeta(id: 'qtc', name: 'Corrected QT Interval (QTc)',
        searchTags: ['qtc', 'qt', 'ecg', 'arrhythmia', 'torsades']),
      CalculatorMeta(id: 'cardiac_output', name: 'Cardiac Output',
        searchTags: ['cardiac output', 'co', 'stroke volume', 'heart rate']),
    ],
  ),
  Category(
    name: 'Paediatrics',
    icon: '👶',
    calculators: [
      CalculatorMeta(id: 'paed_weight', name: 'Weight Estimation by Age',
        searchTags: ['weight', 'paediatric', 'child', 'nelson', 'apls', 'emergency']),
      CalculatorMeta(id: 'schwartz', name: 'Paediatric eGFR (Schwartz)',
        searchTags: ['schwartz', 'paediatric gfr', 'child kidney', 'creatinine']),
      CalculatorMeta(id: 'paed_dose', name: 'Paediatric Drug Dosing',
        searchTags: ['dose', 'paracetamol', 'amoxicillin', 'drug', 'mg/kg']),
    ],
  ),
];
```

---

## 8. AUTH SERVICE

File: `lib/services/auth_service.dart`

```dart
// PIN is SHA-256 hashed before storage — never stored in plain text
// Phone number is the unique doctor identifier

class AuthService {
  // Hash PIN before storing
  String hashPin(String pin);  // SHA-256

  // Onboarding
  Future<void> saveDoctor(Doctor doctor);

  // Login
  Future<bool> verifyPin(String phoneNumber, String pin);

  // Check onboarding state
  Future<bool> isOnboardingComplete();

  // Lock logic
  // After 3 wrong PINs → lock for 30 seconds
  // Track attempts in SharedPreferences
  Future<bool> isLocked();
  Future<void> recordFailedAttempt();
  Future<void> resetAttempts();
}
```

---

## 9. CLOUD SYNC SERVICE

File: `lib/services/cloud_sync_service.dart`

```dart
// Firebase Firestore structure:
// backups/{doctorPhone}/patients/{patientId}
// backups/{doctorPhone}/calculations/{calculationId}

class CloudSyncService {
  // Sync all local data to Firestore (silent, background)
  Future<void> syncToCloud(String doctorPhone);

  // Restore all data from Firestore to local SQLite (new phone scenario)
  Future<void> restoreFromCloud(String doctorPhone);

  // Check connectivity before any cloud operation
  Future<bool> isConnected();

  // Feature requests
  Future<void> submitFeatureRequest({
    required String description,
    required String doctorPhone,
    String? specialty,
  });
}
```

---

## 10. UI/UX SCREENS

### Design tokens:
```
Primary:     #1F4E79  (deep clinical blue)
Secondary:   #2E75B6  (medium blue)
Accent:      #00B4D8  (bright teal — used sparingly for results)
Background:  #F8FAFC  (off-white, not pure white)
Surface:     #FFFFFF
Error:       #C0392B
Text:        #1A1A2E  (near-black)
Subtext:     #6B7280
Success:     #16A34A
Font:        Inter (display), system-ui (body fallback)
Border radius: 12px cards, 8px inputs, 24px buttons
```

---

### SCREEN 1: ONBOARDING (`onboarding_screen.dart`)

Fields (in order):
1. Full name — text input, prefix "Dr."
2. Phone number — numeric, +234 prefix shown
3. Specialty — optional dropdown (General Practice, Internal Medicine, Paediatrics, Surgery, Obstetrics & Gynaecology, Emergency Medicine, Cardiology, Nephrology, Other)
4. Create 4-digit PIN — numeric keypad, dots shown
5. Confirm PIN — must match

Bottom:
- "Get Started" button — disabled until all required fields filled and PINs match
- Disclaimer text: "DocFlow is a calculation aid. Clinical interpretation remains the responsibility of the attending clinician."

Validation:
- Name: minimum 2 characters
- Phone: minimum 10 digits
- PIN: exactly 4 digits, both entries must match

On submit:
- Hash PIN
- Save doctor to SQLite
- Set `onboarding_complete = true` in SharedPreferences
- Navigate to home screen

---

### SCREEN 2: PIN UNLOCK (`pin_screen.dart`)

- Shows on every app open after onboarding
- 4-dot display
- Numeric keypad (custom, no system keyboard)
- Wrong PIN: show "Incorrect PIN" in red, increment counter
- 3 wrong attempts: "Too many attempts. Try again in 30 seconds." — countdown shown
- Forgot PIN option: requires phone number re-entry + shows all data will be preserved

---

### SCREEN 3: HOME SCREEN (`home_screen.dart`)

Layout (top to bottom):
1. Header: "DocFlow" logo left, notification bell + settings icon right
2. Search bar — full width, always visible, placeholder "Search calculations..."
3. Greeting: "Good [morning/afternoon/evening], Dr. [FirstName]"
4. Two quick-action cards side by side:
   - "Quick Calculate" (⚡) — shows count of available calculators
   - "Patient Records" (👤) — shows count of saved patients
5. Categories section heading "Categories"
6. Category list — each row shows icon, name, calculator count
7. "Request a Feature" card at bottom — tapping opens feature_request_screen

Bottom navigation:
- Home | Saved | Settings

---

### SCREEN 4: SEARCH (`search_screen.dart`)

- Activated when user taps search bar on home
- Real-time search as user types
- Searches: calculator names, category names, search tags from registry
- Results grouped by category
- Each result shows: calculator name, category name, arrow to open
- Empty state: "No results for '[query]'" with suggestion to submit a feature request

---

### SCREEN 5: CATEGORY SCREEN (`category_screen.dart`)

- Shows when user taps a category from home
- Header: category icon + name
- List of calculators in that category
- Each item: name, one-line description, chevron right
- Tap → navigate to calculator_screen with calculator ID

---

### SCREEN 6: CALCULATOR SCREEN (`calculator_screen.dart`)

This is a **dynamic screen** driven by calculator ID. Each calculator defines its own input fields.

**Input field types available:**
- `NumberField` — numeric input with unit label
- `DropdownField` — select from preset options
- `ToggleField` — two options (e.g. Male/Female)
- `SliderField` — for percentage inputs (e.g. TBSA)

**Layout:**
1. Back arrow + calculator name + clipboard icon (to copy result)
2. Input fields (dynamically rendered from calculator definition)
3. Divider
4. Result card — large, prominent:
   - Main result value (large font, accent color)
   - Unit below result
   - Interpretation text below unit
5. Divider
6. "▶ How we calculated" — collapsed by default, expands to show transparency string in monospace font
7. Action buttons: "Save to Patient" | "Share Result"
8. Disclaimer: "Clinical interpretation is the responsibility of the attending clinician."

**Dual-formula calculators** (BSA, QTc):
- Show both results in the result card
- Label each clearly: "Mosteller (preferred)" and "DuBois (alternate)"

**Calculate button:**
- Validates all inputs before calculating
- Shows inline error messages per field if invalid
- Result updates in place (no navigation to new screen)

---

### SCREEN 7: SAVE TO PATIENT (`save_to_patient_screen.dart`)

Layout:
1. Search existing patients by name or hospital number
2. "Or create new patient" section:
   - Full name (required)
   - Hospital number (optional)
   - Age (required)
   - Sex toggle: Male / Female
   - Weight in kg (pre-filled if entered in calculator)
   - Diagnosis/notes (optional)
3. Summary of calculation being saved (calculator name + result)
4. Date shown automatically (today)
5. "Save" button

On save:
- If new patient: insert into patients table, then insert calculation
- If existing patient: insert calculation only, update patient `updated_at`
- Navigate back to result screen with "Saved ✓" confirmation

---

### SCREEN 8: PATIENT LIST (`patient_list_screen.dart`)

- Search bar at top
- Sorted by most recently updated
- Each card shows:
  - Patient name (Last, First format)
  - Sex / Age
  - Hospital number (if set)
  - Last calculation type + time ago
- Tap → patient_detail_screen
- FAB: "+ Add New Patient"

---

### SCREEN 9: PATIENT DETAIL (`patient_detail_screen.dart`)

Header:
- Patient name, sex, age
- Hospital number
- Diagnosis

Calculation history (newest first):
- Each entry: calculator name, result value + unit, date
- "Recalculate" button → opens calculator_screen with last input values pre-filled
- "Share" button → shares result as text

Bottom button: "+ New Calculation" → home screen search

---

### SCREEN 10: SETTINGS (`settings_screen.dart`)

Sections:
1. Profile — doctor name, phone, specialty (edit allowed)
2. Security — change PIN
3. Data — "Backup to Cloud" toggle, "Restore from Cloud" button
4. About — version number, disclaimer
5. Feedback — link to feature request

---

## 11. GITHUB ACTIONS (`.github/workflows/main.yml`)

```yaml
name: DocFlow CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.3'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter test

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.3'
          channel: 'stable'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: docflow-apk-${{ github.sha }}
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 12. BUILD ORDER FOR AI AGENT

Execute in this exact sequence. Do not skip steps. Run tests after each calculator file.

```
Step 1:  lib/calculators/cardiac.dart
Step 2:  test/calculators/cardiac_test.dart  → flutter test
Step 3:  lib/calculators/paediatrics.dart
Step 4:  test/calculators/paediatrics_test.dart  → flutter test
Step 5:  lib/utils/constants.dart
Step 6:  lib/utils/validators.dart
Step 7:  lib/utils/formatters.dart
Step 8:  lib/models/doctor.dart
Step 9:  lib/models/patient.dart
Step 10: lib/models/calculation.dart
Step 11: lib/models/category.dart
Step 12: lib/services/database_service.dart
Step 13: test/services/database_service_test.dart  → flutter test
Step 14: lib/services/auth_service.dart
Step 15: lib/services/cloud_sync_service.dart
Step 16: lib/services/analytics_service.dart
Step 17: lib/widgets/formula_display.dart
Step 18: lib/widgets/result_display.dart
Step 19: lib/widgets/calculator_input.dart
Step 20: lib/widgets/category_card.dart
Step 21: lib/widgets/patient_card.dart
Step 22: lib/screens/onboarding_screen.dart
Step 23: lib/screens/pin_screen.dart
Step 24: lib/screens/home_screen.dart
Step 25: lib/screens/search_screen.dart
Step 26: lib/screens/category_screen.dart
Step 27: lib/screens/calculator_screen.dart
Step 28: lib/screens/result_screen.dart
Step 29: lib/screens/save_to_patient_screen.dart
Step 30: lib/screens/patient_list_screen.dart
Step 31: lib/screens/patient_detail_screen.dart
Step 32: lib/screens/settings_screen.dart
Step 33: lib/screens/feature_request_screen.dart
Step 34: lib/app.dart
Step 35: lib/main.dart
Step 36: .github/workflows/main.yml
Step 37: flutter test (all tests)
Step 38: flutter build apk --release
```

---

## 13. CRITICAL RULES FOR EVERY FILE

1. All `import` statements at the **top of the file only**
2. Every calculator returns a result class — never raw primitives
3. Every result class includes a `transparency` field (String)
4. Transparency shows **full step-by-step working** with actual substituted values
5. No hardcoded colors anywhere — use design tokens from constants
6. Every input field validates before calculation runs
7. Patient data is **never** sent to analytics — only anonymized calculation metadata
8. PIN is **always** SHA-256 hashed before any storage operation
9. Cloud sync is **always** gated behind a connectivity check
10. Every screen has a medical disclaimer visible or accessible
