import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/calculators/fluids_drips.dart';

void main() {
  group('Fluids & Drips —', () {

    group('IV Drip Rate', () {
      test('500mL over 4hr, adult set (20 gtt/mL)', () {
        final r = FluidsAndDrips.calculateIVDrip(
          volumeMl: 500,
          timeHours: 4,
          dropFactor: 20,
        );
        expect(r.dropsPerMinute, 41.67);
        expect(r.rounded, 42);
      });

      test('1000mL over 8hr, adult set (20 gtt/mL)', () {
        final r = FluidsAndDrips.calculateIVDrip(
          volumeMl: 1000,
          timeHours: 8,
          dropFactor: 20,
        );
        expect(r.rounded, 42);
      });

      test('100mL over 2hr, paediatric set (60 gtt/mL)', () {
        final r = FluidsAndDrips.calculateIVDrip(
          volumeMl: 100,
          timeHours: 2,
          dropFactor: 60,
        );
        expect(r.rounded, 50);
      });

      test('Transparency is populated', () {
        final r = FluidsAndDrips.calculateIVDrip(
          volumeMl: 500,
          timeHours: 4,
          dropFactor: 20,
        );
        expect(r.transparency, contains('drops/min'));
      });
    });

    group('Maintenance Fluids (4-2-1)', () {
      test('10kg child — first bracket only', () {
        final r = FluidsAndDrips.calculateMaintenanceFluid(weightKg: 10);
        expect(r.hourlyRate, 40.0);
      });

      test('20kg child — first + second bracket', () {
        final r = FluidsAndDrips.calculateMaintenanceFluid(weightKg: 20);
        expect(r.hourlyRate, 60.0);
      });

      test('70kg adult — all three brackets', () {
        final r = FluidsAndDrips.calculateMaintenanceFluid(weightKg: 70);
        expect(r.hourlyRate, 110.0);
      });

      test('Daily rate = hourly × 24', () {
        final r = FluidsAndDrips.calculateMaintenanceFluid(weightKg: 20);
        expect(r.dailyRate, 1440.0);
      });
    });

    group('Parkland Formula', () {
      test('70kg, 40% TBSA', () {
        final r = FluidsAndDrips.calculateParkland(
          weightKg: 70,
          tbsaPercent: 40,
        );
        expect(r.total24hr, 11200.0);
        expect(r.first8hrTotal, 5600.0);
        expect(r.first8hrRate, 700.0);
        expect(r.next16hrRate, 350.0);
      });

      test('Transparency contains burn injury note', () {
        final r = FluidsAndDrips.calculateParkland(
          weightKg: 70,
          tbsaPercent: 40,
        );
        expect(r.transparency, contains('time of burn injury'));
      });
    });

  });
}