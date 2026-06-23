import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/calculators/paediatrics.dart';

void main() {
  group('Paediatrics —', () {
    group('Weight Estimation by Age', () {
      test('Age 3 returns APLS and Nelson equal at 14kg', () {
        final r = Paediatrics.estimateWeight(age: 3);
        expect(r.apls, 14.0);
        expect(r.nelsons, 14.0);
        expect(r.recommended, 14.0);
      });

      test('Age 8 returns APLS 24kg and null Nelson', () {
        final r = Paediatrics.estimateWeight(age: 8);
        expect(r.apls, 24.0);
        expect(r.nelsons, isNull);
        expect(r.recommended, 24.0);
      });

      test('Age 0 throws argument error', () {
        expect(() => Paediatrics.estimateWeight(age: 0), throwsArgumentError);
      });

      test('Age 13 throws argument error', () {
        expect(() => Paediatrics.estimateWeight(age: 13), throwsArgumentError);
      });
    });

    group('Schwartz eGFR', () {
      test('Height 120cm, creatinine 0.5 returns 99.1 and G1', () {
        final r = Paediatrics.calculateSchwartz(heightCm: 120, serumCreatinine: 0.5);
        expect(r.egfr, 99.1);
        expect(r.stage, contains('G1'));
      });

      test('Height 100cm, creatinine 2.0 returns 20.7 and G4', () {
        final r = Paediatrics.calculateSchwartz(heightCm: 100, serumCreatinine: 2.0);
        expect(r.egfr, 20.7);
        expect(r.stage, contains('G4'));
      });
    });

    group('Paediatric Drug Dosing', () {
      test('Paracetamol 15mg/kg, 20kg => 300mg single, 1200mg daily', () {
        final r = Paediatrics.calculateDose(
          doseMgPerKg: 15.0,
          weightKg: 20.0,
          frequencyPerDay: 4,
        );
        expect(r.singleDoseMg, 300.0);
        expect(r.dailyTotalMg, 1200.0);
      });

      test('Amoxicillin 25mg/kg, 15kg => 375mg single dose', () {
        final r = Paediatrics.calculateDose(
          doseMgPerKg: 25.0,
          weightKg: 15.0,
          frequencyPerDay: 3,
        );
        expect(r.singleDoseMg, 375.0);
      });

      test('Max dose cap applies for 25mg/kg × 100kg not exceeding maxSingleDose', () {
        final r = Paediatrics.calculateDose(
          doseMgPerKg: 25.0,
          weightKg: 100.0,
          frequencyPerDay: 3,
          maxSingleDoseMg: 500.0,
        );
        expect(r.singleDoseMg, 500.0);
      });
    });
  });
}
