class CockcroftGaultResult {
  final double egfr;
  final String stage;
  final String transparency;

  CockcroftGaultResult({
    required this.egfr,
    required this.stage,
    required this.transparency,
  });
}

class AnionGapResult {
  final double value;
  final bool elevated;
  final String transparency;

  AnionGapResult({
    required this.value,
    required this.elevated,
    required this.transparency,
  });
}

class FeNaResult {
  final double value;
  final String interpretation;
  final String transparency;

  FeNaResult({
    required this.value,
    required this.interpretation,
    required this.transparency,
  });
}

class Renal {
  // ── eGFR (Cockcroft-Gault) ───────────────────────────
  static CockcroftGaultResult calculateEGFR({
    required int age,
    required double weightKg,
    required double serumCreatinine,
    required bool isFemale,
  }) {
    double egfr = ((140 - age) * weightKg) / (72 * serumCreatinine);
    if (isFemale) egfr *= 0.85;

    final double rounded = double.parse(egfr.toStringAsFixed(1));

    String stage;
    if (rounded >= 90) {
      stage = 'G1 — Normal or high (≥90 mL/min)';
    } else if (rounded >= 60) {
      stage = 'G2 — Mildly decreased (60–89 mL/min)';
    } else if (rounded >= 45) {
      stage = 'G3a — Mildly to moderately decreased (45–59 mL/min)';
    } else if (rounded >= 30) {
      stage = 'G3b — Moderately to severely decreased (30–44 mL/min)';
    } else if (rounded >= 15) {
      stage = 'G4 — Severely decreased (15–29 mL/min)';
    } else {
      stage = 'G5 — Kidney failure (<15 mL/min)';
    }

    final double numerator = (140 - age) * weightKg;
    final double denominator = 72 * serumCreatinine;

    final String transparency = '''
Cockcroft-Gault Equation:
  eGFR = [(140 − Age) × Weight (kg)] ÷ [72 × Serum Creatinine (mg/dL)]
         × 0.85 if female

Step 1 — Numerator:
  (140 − $age) × ${weightKg}kg
  = ${140 - age} × $weightKg
  = ${numerator.toStringAsFixed(1)}

Step 2 — Denominator:
  72 × ${serumCreatinine} mg/dL
  = ${denominator.toStringAsFixed(1)}

Step 3 — Divide:
  ${numerator.toStringAsFixed(1)} ÷ ${denominator.toStringAsFixed(1)}
  = ${(numerator / denominator).toStringAsFixed(2)} mL/min
${isFemale ? '''
Step 4 — Female correction (× 0.85):
  ${(numerator / denominator).toStringAsFixed(2)} × 0.85
  = $rounded mL/min''' : ''}
Result: $rounded mL/min
CKD Stage: $stage
''';

    return CockcroftGaultResult(
      egfr: rounded,
      stage: stage,
      transparency: transparency,
    );
  }

  // ── ANION GAP ────────────────────────────────────────
  static AnionGapResult calculateAnionGap({
    required double sodium,
    required double chloride,
    required double bicarbonate,
  }) {
    final double ag = sodium - (chloride + bicarbonate);
    final double rounded = double.parse(ag.toStringAsFixed(1));
    final bool elevated = rounded > 12;

    final String transparency = '''
Formula:
  Anion Gap = Na⁺ − (Cl⁻ + HCO₃⁻)

  = $sodium − ($chloride + $bicarbonate)
  = $sodium − ${(chloride + bicarbonate).toStringAsFixed(1)}
  = $rounded mEq/L

Reference range: 8–12 mEq/L
Result: $rounded mEq/L — ${elevated ? 'ELEVATED (>12)' : 'Normal'}

${elevated ? 'Elevated anion gap consider: DKA, lactic acidosis, uraemia, toxic ingestion (MUDPILES).' : 'Normal anion gap: consider hyperchloraemic metabolic acidosis.'}
''';

    return AnionGapResult(
      value: rounded,
      elevated: elevated,
      transparency: transparency,
    );
  }

  // ── FeNa ─────────────────────────────────────────────
  static FeNaResult calculateFeNa({
    required double urineNa,
    required double serumCreatinine,
    required double serumNa,
    required double urineCreatinine,
  }) {
    final double fena =
        ((urineNa * serumCreatinine) / (serumNa * urineCreatinine)) * 100;
    final double rounded = double.parse(fena.toStringAsFixed(2));

    String interpretation;
    if (rounded < 1.0) {
      interpretation = '<1% — Pre-renal AKI (kidneys conserving sodium)';
    } else if (rounded <= 2.0) {
      interpretation = '1–2% — Indeterminate. Correlate clinically.';
    } else {
      interpretation = '>2% — Intrinsic renal injury (ATN likely)';
    }

    final String transparency = '''
Formula:
  FeNa (%) = [(Urine Na × Serum Creatinine) ÷ (Serum Na × Urine Creatinine)] × 100

  Numerator:
    Urine Na × Serum Creatinine
    = $urineNa × $serumCreatinine
    = ${(urineNa * serumCreatinine).toStringAsFixed(2)}

  Denominator:
    Serum Na × Urine Creatinine
    = $serumNa × $urineCreatinine
    = ${(serumNa * urineCreatinine).toStringAsFixed(2)}

  FeNa = (${(urineNa * serumCreatinine).toStringAsFixed(2)} ÷ ${(serumNa * urineCreatinine).toStringAsFixed(2)}) × 100
       = $rounded%

Interpretation: $interpretation
''';

    return FeNaResult(
      value: rounded,
      interpretation: interpretation,
      transparency: transparency,
    );
  }
}