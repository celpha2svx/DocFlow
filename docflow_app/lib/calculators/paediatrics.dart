class WeightEstimationResult {
  final double apls;
  final double? nelsons;
  final double recommended;
  final String transparency;

  WeightEstimationResult({
    required this.apls,
    required this.nelsons,
    required this.recommended,
    required this.transparency,
  });
}

class SchwartzResult {
  final double egfr;
  final String stage;
  final String transparency;

  SchwartzResult({
    required this.egfr,
    required this.stage,
    required this.transparency,
  });
}

class PaedDoseResult {
  final double singleDoseMg;
  final double dailyTotalMg;
  final String transparency;

  PaedDoseResult({
    required this.singleDoseMg,
    required this.dailyTotalMg,
    required this.transparency,
  });
}

class Paediatrics {
  static WeightEstimationResult estimateWeight({
    required int age,
  }) {
    if (age < 1 || age > 12) {
      throw ArgumentError('Age must be between 1 and 12 years.');
    }

    final double apls = double.parse(((age + 4) * 2).toStringAsFixed(1));
    final double? nelsons = age <= 5
        ? double.parse(((age * 2) + 8).toStringAsFixed(1))
        : null;
    final double recommended = age <= 5 ? nelsons! : apls;

    final String transparency = '''
APLS Formula:
  Weight = (Age + 4) × 2
  = (${age} + 4) × 2
  = ${age + 4} × 2
  = $apls kg

${nelsons != null ? '''Nelson's Formula:
  Weight = (Age × 2) + 8
  = (${age} × 2) + 8
  = ${age * 2} + 8
  = ${nelsons.toStringAsFixed(1)} kg

''' : ''}Recommended weight: ${recommended.toStringAsFixed(1)} kg
''';

    return WeightEstimationResult(
      apls: apls,
      nelsons: nelsons,
      recommended: recommended,
      transparency: transparency,
    );
  }

  static final List<Map<String, dynamic>> _ckdStages = [
    {'min': 90.0, 'stage': 'G1 — Normal or high (≥90 mL/min/1.73m²)'},
    {'min': 60.0, 'stage': 'G2 — Mildly decreased (60–89 mL/min/1.73m²)'},
    {'min': 45.0, 'stage': 'G3a — Mildly to moderately decreased (45–59 mL/min/1.73m²)'},
    {'min': 30.0, 'stage': 'G3b — Moderately to severely decreased (30–44 mL/min/1.73m²)'},
    {'min': 15.0, 'stage': 'G4 — Severely decreased (15–29 mL/min/1.73m²)'},
  ];

  static SchwartzResult calculateSchwartz({
    required double heightCm,
    required double serumCreatinine,
  }) {
    if (heightCm <= 0 || serumCreatinine <= 0) {
      throw ArgumentError('Height and serum creatinine must be positive.');
    }

    final double numerator = 413 * heightCm;
    final double denominator = 1000 * serumCreatinine;
    final double egfrValue = numerator / denominator;
    final double roundedEgfr = ((egfrValue * 10) + 0.5).floorToDouble() / 10;

    String stage;
    if (roundedEgfr >= 90.0) {
      stage = _ckdStages[0]['stage'] as String;
    } else if (roundedEgfr >= 60.0) {
      stage = _ckdStages[1]['stage'] as String;
    } else if (roundedEgfr >= 45.0) {
      stage = _ckdStages[2]['stage'] as String;
    } else if (roundedEgfr >= 30.0) {
      stage = _ckdStages[3]['stage'] as String;
    } else if (roundedEgfr >= 15.0) {
      stage = _ckdStages[4]['stage'] as String;
    } else {
      stage = 'G5 — Kidney failure (<15 mL/min/1.73m²)';
    }

    final String transparency = '''
Modified Schwartz Formula:
  eGFR = (0.413 × Height (cm)) ÷ Serum Creatinine (mg/dL)

  = (413 ÷ 1000) × ${heightCm.toStringAsFixed(1)} ÷ ${serumCreatinine.toStringAsFixed(2)}
  = ${numerator.toStringAsFixed(1)} ÷ ${denominator.toStringAsFixed(1)}
  = $roundedEgfr mL/min/1.73m²

CKD Stage: $stage
''';

    return SchwartzResult(
      egfr: roundedEgfr,
      stage: stage,
      transparency: transparency,
    );
  }

  static PaedDoseResult calculateDose({
    required double doseMgPerKg,
    required double weightKg,
    required int frequencyPerDay,
    double? maxSingleDoseMg,
  }) {
    if (doseMgPerKg <= 0 || weightKg <= 0 || frequencyPerDay <= 0) {
      throw ArgumentError('Dose, weight, and frequency must be positive values.');
    }

    final double initialSingle = doseMgPerKg * weightKg;
    final double singleDose = maxSingleDoseMg != null
        ? (initialSingle > maxSingleDoseMg ? maxSingleDoseMg : initialSingle)
        : initialSingle;
    final double dailyTotal = singleDose * frequencyPerDay;

    final double roundedSingle = double.parse(singleDose.toStringAsFixed(1));
    final double roundedDaily = double.parse(dailyTotal.toStringAsFixed(1));

    final String maximumDoseText = maxSingleDoseMg != null
        ? '  Maximum allowed single dose = ${maxSingleDoseMg.toStringAsFixed(1)} mg\n'
          '  Applied capped single dose = ${roundedSingle.toStringAsFixed(1)} mg\n'
        : '';

    final String transparency = '''
Single dose formula:
  Single dose = Dose (mg/kg) × Weight (kg)
  = ${doseMgPerKg.toStringAsFixed(1)} × ${weightKg.toStringAsFixed(1)}
  = ${initialSingle.toStringAsFixed(1)} mg
$maximumDoseText
Daily total formula:
  Daily total = ${roundedSingle.toStringAsFixed(1)} × $frequencyPerDay
  = $roundedDaily mg
''';

    return PaedDoseResult(
      singleDoseMg: roundedSingle,
      dailyTotalMg: roundedDaily,
      transparency: transparency,
    );
  }
}
