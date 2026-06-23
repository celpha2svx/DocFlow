import 'dart:math';

class MAPResult {
  final double value;
  final String interpretation;
  final String transparency;

  MAPResult({
    required this.value,
    required this.interpretation,
    required this.transparency,
  });
}

class QTcResult {
  final double bazett;
  final double fridericia;
  final String interpretation;
  final String transparency;

  QTcResult({
    required this.bazett,
    required this.fridericia,
    required this.interpretation,
    required this.transparency,
  });
}

class CardiacOutputResult {
  final double cardiacOutput;
  final double? cardiacIndex;
  final String interpretation;
  final String transparency;

  CardiacOutputResult({
    required this.cardiacOutput,
    required this.cardiacIndex,
    required this.interpretation,
    required this.transparency,
  });
}

class Cardiac {
  // ── Mean Arterial Pressure (MAP) ──────────────────────
  static MAPResult calculateMAP({
    required double systolic,
    required double diastolic,
  }) {
    final double map = diastolic + (systolic - diastolic) / 3;
    final double rounded = double.parse(map.toStringAsFixed(1));

    String interpretation;
    if (rounded < 65.0) {
      interpretation = 'Critical — immediate intervention required';
    } else if (rounded < 70.0) {
      interpretation = 'Low normal — monitor closely';
    } else if (rounded <= 100.0) {
      interpretation = 'Normal';
    } else {
      interpretation = 'Elevated — assess for hypertensive emergency';
    }

    final String transparency = '''
Formula 1:
  MAP = Diastolic + (Systolic − Diastolic) ÷ 3

Formula 2 (equivalent):
  MAP = (Systolic + 2 × Diastolic) ÷ 3

Substitution:
  MAP = ${diastolic} + (${systolic} − ${diastolic}) ÷ 3
      = ${diastolic} + ${(systolic - diastolic).toStringAsFixed(1)} ÷ 3
      = ${diastolic} + ${(systolic - diastolic) / 3}
      = $rounded mmHg

Equivalent substitution:
  MAP = (${systolic} + 2 × ${diastolic}) ÷ 3
      = (${systolic} + ${2 * diastolic}) ÷ 3
      = ${systolic + 2 * diastolic} ÷ 3
      = $rounded mmHg

Result: $rounded mmHg — $interpretation
''';

    return MAPResult(
      value: rounded,
      interpretation: interpretation,
      transparency: transparency,
    );
  }

  // ── Corrected QT Interval (QTc) ──────────────────────
  static QTcResult calculateQTc({
    required double qtMs,
    required double heartRate,
  }) {
    final double rr = 60.0 / heartRate;
    final double bazettValue = qtMs / sqrt(rr);
    final double fridericiaValue = qtMs / pow(rr, 1 / 3);
    final double bazettRounded = double.parse(bazettValue.toStringAsFixed(1));
    final double fridericiaRounded = double.parse(fridericiaValue.toStringAsFixed(1));

    String interpretation;
    if (bazettRounded > 500.0) {
      interpretation = 'Critically prolonged — high risk of Torsades de Pointes';
    } else if (bazettRounded >= 440.0) {
      interpretation = 'Borderline prolonged — review QT-prolonging medications';
    } else {
      interpretation = 'Normal';
    }

    final String transparency = '''
Bazett's Formula:
  QTc = QT ÷ √(RR)
  RR = 60 ÷ Heart Rate

Step 1 — RR interval:
  RR = 60 ÷ ${heartRate.toStringAsFixed(1)}
     = ${rr.toStringAsFixed(4)} seconds

Step 2 — Bazett correction:
  QTc = ${qtMs.toStringAsFixed(1)} ÷ √(${rr.toStringAsFixed(4)})
      = ${qtMs.toStringAsFixed(1)} ÷ ${sqrt(rr).toStringAsFixed(4)}
      = $bazettRounded ms

Fridericia's Formula:
  QTc = QT ÷ ∛(RR)
  QTc = ${qtMs.toStringAsFixed(1)} ÷ ${pow(rr, 1 / 3).toStringAsFixed(4)}
      = $fridericiaRounded ms

Interpretation (Bazett): $interpretation
''';

    return QTcResult(
      bazett: bazettRounded,
      fridericia: fridericiaRounded,
      interpretation: interpretation,
      transparency: transparency,
    );
  }

  // ── Cardiac Output (CO) ─────────────────────────────
  static CardiacOutputResult calculateCardiacOutput({
    required double heartRate,
    required double strokeVolume,
    double? bsa,
  }) {
    final double cardiacOutputMl = heartRate * strokeVolume;
    final double cardiacOutputL = cardiacOutputMl / 1000.0;
    final double roundedCO = double.parse(cardiacOutputL.toStringAsFixed(2));
    final double? index = (bsa != null && bsa > 0)
        ? double.parse((roundedCO / bsa).toStringAsFixed(2))
        : null;

    String interpretation;
    if (roundedCO < 4.0) {
      interpretation = 'Low — assess for cardiogenic shock';
    } else if (roundedCO <= 8.0) {
      interpretation = 'Normal';
    } else {
      interpretation = 'Elevated — assess for high-output state';
    }

    final String cardiacIndexTransparency = index != null
        ? '''Step 2 — Cardiac index:
  CI = $roundedCO ÷ ${bsa!.toStringAsFixed(2)}
     = ${index.toStringAsFixed(2)} L/min/m²

'''
        : '';

    final String transparency = '''
Formula:
  CO = Heart Rate × Stroke Volume
  Cardiac Index = CO ÷ BSA (if provided)

Step 1 — Cardiac output:
  CO = ${heartRate.toStringAsFixed(1)} × ${strokeVolume.toStringAsFixed(1)}
     = ${cardiacOutputMl.toStringAsFixed(1)} mL/min
     = $roundedCO L/min

$cardiacIndexTransparency
Result: $roundedCO L/min — $interpretation
''';

    return CardiacOutputResult(
      cardiacOutput: roundedCO,
      cardiacIndex: index,
      interpretation: interpretation,
      transparency: transparency,
    );
  }
}
