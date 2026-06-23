import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/calculators/renal.dart';

void main() {
  group('Renal —', () {

    group('eGFR (Cockcroft-Gault)', () {
      test('Male, 45yr, 70kg, creatinine 1.0', () {
        final r = Renal.calculateEGFR(
          age: 45,
          weightKg: 70,
          serumCreatinine: 1.0,
          isFemale: false,
        );
        expect(r.egfr, closeTo(92.4, 0.5));
        expect(r.stage, contains('G1'));
      });

      test('Female correction applies (× 0.85)', () {
        final male = Renal.calculateEGFR(
          age: 45,
          weightKg: 70,
          serumCreatinine: 1.0,
          isFemale: false,
        );
        final female = Renal.calculateEGFR(
          age: 45,
          weightKg: 70,
          serumCreatinine: 1.0,
          isFemale: true,
        );
        expect(female.egfr, closeTo(male.egfr * 0.85, 0.5));
      });

      test('CKD Stage G4 assigned correctly', () {
        final r = Renal.calculateEGFR(
          age: 70,
          weightKg: 55,
          serumCreatinine: 3.5,
          isFemale: false,
        );
        expect(r.stage, contains('G4'));
      });

      test('Transparency contains formula', () {
        final r = Renal.calculateEGFR(
          age: 45,
          weightKg: 70,
          serumCreatinine: 1.0,
          isFemale: false,
        );
        expect(r.transparency, contains('Cockcroft-Gault'));
      });
    });

    group('Anion Gap', () {
      test('Normal anion gap', () {
        final r = Renal.calculateAnionGap(
          sodium: 140,
          chloride: 102,
          bicarbonate: 26,
        );
        expect(r.value, 12.0);
        expect(r.elevated, false);
      });

      test('Elevated anion gap (DKA pattern)', () {
        final r = Renal.calculateAnionGap(
          sodium: 138,
          chloride: 98,
          bicarbonate: 10,
        );
        expect(r.value, 30.0);
        expect(r.elevated, true);
        expect(r.transparency, contains('MUDPILES'));
      });
    });

    group('FeNa', () {
      test('Pre-renal — FeNa < 1%', () {
        final r = Renal.calculateFeNa(
          urineNa: 10,
          serumCreatinine: 2.0,
          serumNa: 140,
          urineCreatinine: 150,
        );
        expect(r.value, lessThan(1.0));
        expect(r.interpretation, contains('Pre-renal'));
      });

      test('ATN — FeNa > 2%', () {
        final r = Renal.calculateFeNa(
          urineNa: 80,
          serumCreatinine: 3.0,
          serumNa: 140,
          urineCreatinine: 60,
        );
        expect(r.value, greaterThan(2.0));
        expect(r.interpretation, contains('ATN'));
      });
    });

  });
}