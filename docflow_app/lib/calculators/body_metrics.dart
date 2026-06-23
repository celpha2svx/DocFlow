// lib/calculators/body_metrics.dart

import 'dart:math';

class BMIResult {
  final double value;
  final String category;
  final String transparency;

  BMIResult({
    required this.value,
    required this.category,
    required this.transparency,
  });
}

class BSAResult {
  final double mosteller;
  final double dubois;
  final String transparency;

  BSAResult({
    required this.mosteller,
    required this.dubois,
    required this.transparency,
  });
}

class IBWResult {
  final double value;
  final String formula;
  final String transparency;

  IBWResult({
    required this.value,
    required this.formula,
    required this.transparency,
  });
}

class BodyMetrics {
  // ── BMI ──────────────────────────────────────────────
  static BMIResult calculateBMI({
    required double weightKg,
    required double heightCm,
  }) {
    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);
    final double rounded = double.parse(bmi.toStringAsFixed(1));

    String category;
    if (bmi < 18.5) {
      category = 'Underweight';
    } else if (bmi < 25.0) {
      category = 'Normal Weight';
    } else if (bmi < 30.0) {
      category = 'Overweight';
    } else {
      category = 'Obese';
    }

    final String transparency = '''
Formula:
  BMI = Weight (kg) ÷ Height (m)²

Step 1 — Convert height:
  ${heightCm}cm ÷ 100 = ${heightM}m

Step 2 — Square the height:
  ${heightM}m × ${heightM}m = ${(heightM * heightM).toStringAsFixed(4)}m²

Step 3 — Divide weight by height²:
  ${weightKg}kg ÷ ${(heightM * heightM).toStringAsFixed(4)} = $rounded kg/m²

Result: $rounded kg/m² → $category
''';

    return BMIResult(value: rounded, category: category, transparency: transparency);
  }

  // ── BSA ──────────────────────────────────────────────
  static BSAResult calculateBSA({
    required double weightKg,
    required double heightCm,
  }) {
    

    final double mosteller = sqrt((heightCm * weightKg) / 3600);
    final double dubois =
        0.007184 * pow(weightKg, 0.425) * pow(heightCm, 0.725);

    final double mostellerRounded = double.parse(mosteller.toStringAsFixed(2));
    final double duboisRounded = double.parse(dubois.toStringAsFixed(2));

    final String transparency = '''
Mosteller Formula (preferred):
  BSA = √[(Height (cm) × Weight (kg)) ÷ 3600]
  
  = √[(${heightCm} × ${weightKg}) ÷ 3600]
  = √[${(heightCm * weightKg).toStringAsFixed(1)} ÷ 3600]
  = √${((heightCm * weightKg) / 3600).toStringAsFixed(4)}
  = $mostellerRounded m²

DuBois Formula (alternate):
  BSA = 0.007184 × Weight⁰·⁴²⁵ × Height⁰·⁷²⁵

  = 0.007184 × ${weightKg}⁰·⁴²⁵ × ${heightCm}⁰·⁷²⁵
  = $duboisRounded m²
''';

    return BSAResult(
      mosteller: mostellerRounded,
      dubois: duboisRounded,
      transparency: transparency,
    );
  }

  // ── IBW ──────────────────────────────────────────────
  static IBWResult calculateIBW({
    required double heightCm,
    required bool isMale,
  }) {
    // Convert cm to inches, subtract 60 (5 feet)
    final double heightInches = heightCm / 2.54;
    final double inchesOver5ft = heightInches - 60;

    double ibw;
    String formula;

    if (isMale) {
      ibw = 50 + (2.3 * inchesOver5ft);
      formula = 'Male: 50 + 2.3 × (Height in inches − 60)';
    } else {
      ibw = 45.5 + (2.3 * inchesOver5ft);
      formula = 'Female: 45.5 + 2.3 × (Height in inches − 60)';
    }

    final double rounded = double.parse(ibw.toStringAsFixed(1));

    final String transparency = '''
Devine Formula:
  $formula

Step 1 — Convert height:
  ${heightCm}cm ÷ 2.54 = ${heightInches.toStringAsFixed(2)} inches

Step 2 — Inches over 5ft (60 inches):
  ${heightInches.toStringAsFixed(2)} − 60 = ${inchesOver5ft.toStringAsFixed(2)} inches

Step 3 — Apply formula:
  ${isMale ? '50' : '45.5'} + (2.3 × ${inchesOver5ft.toStringAsFixed(2)})
  = ${isMale ? '50' : '45.5'} + ${(2.3 * inchesOver5ft).toStringAsFixed(2)}
  = $rounded kg

Result: $rounded kg
''';

    return IBWResult(value: rounded, formula: formula, transparency: transparency);
  }
}