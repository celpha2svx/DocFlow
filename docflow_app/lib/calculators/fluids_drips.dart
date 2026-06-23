import 'dart:math';

class IVDripResult {
  final double dropsPerMinute;
  final int rounded;
  final String transparency;

  IVDripResult({
    required this.dropsPerMinute,
    required this.rounded,
    required this.transparency,
  });
}

class MaintenanceFluidResult {
  final double hourlyRate;
  final double dailyRate;
  final String transparency;

  MaintenanceFluidResult({
    required this.hourlyRate,
    required this.dailyRate,
    required this.transparency,
  });
}

class ParklandResult {
  final double total24hr;
  final double first8hrTotal;
  final double first8hrRate;
  final double next16hrTotal;
  final double next16hrRate;
  final String transparency;

  ParklandResult({
    required this.total24hr,
    required this.first8hrTotal,
    required this.first8hrRate,
    required this.next16hrTotal,
    required this.next16hrRate,
    required this.transparency,
  });
}

class FluidsAndDrips {
  // ── IV DRIP RATE ─────────────────────────────────────
  static IVDripResult calculateIVDrip({
    required double volumeMl,
    required double timeHours,
    required int dropFactor,
  }) {
    final double timeMinutes = timeHours * 60;
    final double drops = (volumeMl * dropFactor) / timeMinutes;
    final int roundedDrops = drops.round();

    final String transparency = '''
Formula:
  Drops/min = (Volume (mL) × Drop Factor) ÷ Time (min)

Step 1 — Convert time to minutes:
  ${timeHours}hr × 60 = ${timeMinutes.toStringAsFixed(0)} min

Step 2 — Multiply volume by drop factor:
  ${volumeMl}mL × $dropFactor gtt/mL = ${(volumeMl * dropFactor).toStringAsFixed(0)} gtt

Step 3 — Divide by time in minutes:
  ${(volumeMl * dropFactor).toStringAsFixed(0)} ÷ ${timeMinutes.toStringAsFixed(0)} = ${drops.toStringAsFixed(2)} gtt/min

Result: ≈ $roundedDrops drops/min
''';

    return IVDripResult(
      dropsPerMinute: double.parse(drops.toStringAsFixed(2)),
      rounded: roundedDrops,
      transparency: transparency,
    );
  }

  // ── MAINTENANCE FLUIDS (Holliday-Segar 4-2-1) ────────
  static MaintenanceFluidResult calculateMaintenanceFluid({
    required double weightKg,
  }) {
    double hourlyRate;
    String breakdown;

    if (weightKg <= 10) {
      hourlyRate = weightKg * 4;
      breakdown = '''
  Weight ≤ 10kg: 4 mL/kg/hr
  ${weightKg}kg × 4 = ${hourlyRate.toStringAsFixed(1)} mL/hr''';
    } else if (weightKg <= 20) {
      final double first10 = 10 * 4;
      final double remainder = (weightKg - 10) * 2;
      hourlyRate = first10 + remainder;
      breakdown = '''
  First 10kg:  10 × 4 = ${first10.toStringAsFixed(1)} mL/hr
  Next ${(weightKg - 10).toStringAsFixed(1)}kg: ${(weightKg - 10).toStringAsFixed(1)} × 2 = ${remainder.toStringAsFixed(1)} mL/hr
  Total: ${first10.toStringAsFixed(1)} + ${remainder.toStringAsFixed(1)} = ${hourlyRate.toStringAsFixed(1)} mL/hr''';
    } else {
      final double first10 = 10 * 4;
      final double next10 = 10 * 2;
      final double remainder = (weightKg - 20) * 1;
      hourlyRate = first10 + next10 + remainder;
      breakdown = '''
  First 10kg:  10 × 4 = ${first10.toStringAsFixed(1)} mL/hr
  Next 10kg:   10 × 2 = ${next10.toStringAsFixed(1)} mL/hr
  Remaining ${(weightKg - 20).toStringAsFixed(1)}kg: ${(weightKg - 20).toStringAsFixed(1)} × 1 = ${remainder.toStringAsFixed(1)} mL/hr
  Total: ${first10.toStringAsFixed(1)} + ${next10.toStringAsFixed(1)} + ${remainder.toStringAsFixed(1)} = ${hourlyRate.toStringAsFixed(1)} mL/hr''';
    }

    final double dailyRate = hourlyRate * 24;

    final String transparency = '''
Holliday-Segar Method (4-2-1 Rule):
  First 10kg:        4 mL/kg/hr
  Next 10kg (11-20): 2 mL/kg/hr
  Each kg over 20kg: 1 mL/kg/hr

Patient weight: ${weightKg}kg
$breakdown

Daily equivalent: ${hourlyRate.toStringAsFixed(1)} × 24 = ${dailyRate.toStringAsFixed(1)} mL/day
''';

    return MaintenanceFluidResult(
      hourlyRate: double.parse(hourlyRate.toStringAsFixed(1)),
      dailyRate: double.parse(dailyRate.toStringAsFixed(1)),
      transparency: transparency,
    );
  }

  // ── PARKLAND FORMULA (Burns) ──────────────────────────
  static ParklandResult calculateParkland({
    required double weightKg,
    required double tbsaPercent,
  }) {
    final double total = 4 * weightKg * tbsaPercent;
    final double first8hrTotal = total / 2;
    final double next16hrTotal = total / 2;
    final double first8hrRate = first8hrTotal / 8;
    final double next16hrRate = next16hrTotal / 16;

    final String transparency = '''
Parkland Formula:
  Total fluid (24hr) = 4 mL × Weight (kg) × % TBSA

  = 4 × ${weightKg}kg × ${tbsaPercent}% TBSA
  = ${total.toStringAsFixed(0)} mL over 24 hours

Administration (Ringer's Lactate):
  First 8 hours:
    ${total.toStringAsFixed(0)} ÷ 2 = ${first8hrTotal.toStringAsFixed(0)} mL
    Rate: ${first8hrTotal.toStringAsFixed(0)} ÷ 8 = ${first8hrRate.toStringAsFixed(0)} mL/hr

  Next 16 hours:
    ${next16hrTotal.toStringAsFixed(0)} mL
    Rate: ${next16hrTotal.toStringAsFixed(0)} ÷ 16 = ${next16hrRate.toStringAsFixed(0)} mL/hr

Note: Time zero = time of burn injury, not time of arrival.
''';

    return ParklandResult(
      total24hr: double.parse(total.toStringAsFixed(1)),
      first8hrTotal: double.parse(first8hrTotal.toStringAsFixed(1)),
      first8hrRate: double.parse(first8hrRate.toStringAsFixed(1)),
      next16hrTotal: double.parse(next16hrTotal.toStringAsFixed(1)),
      next16hrRate: double.parse(next16hrRate.toStringAsFixed(1)),
      transparency: transparency,
    );
  }
}