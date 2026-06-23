import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/calculators/body_metrics.dart';

void main() {
  group('Body Metrics —', () {

    group('BMI', () {
      test('Normal weight male', () {
        final r = BodyMetrics.calculateBMI(weightKg: 70, heightCm: 170);
        expect(r.value, 24.2);
        expect(r.category, 'Normal Weight');
      });

      test('Underweight', () {
        final r = BodyMetrics.calculateBMI(weightKg: 45, heightCm: 170);
        expect(r.category, 'Underweight');
      });

      test('Obese', () {
        final r = BodyMetrics.calculateBMI(weightKg: 100, heightCm: 165);
        expect(r.category, 'Obese');
      });

      test('Transparency string is populated', () {
        final r = BodyMetrics.calculateBMI(weightKg: 70, heightCm: 170);
        expect(r.transparency, contains('Formula'));
        expect(r.transparency, contains('24.2'));
      });
    });

    group('BSA', () {
      test('Mosteller result for average adult', () {
        final r = BodyMetrics.calculateBSA(weightKg: 70, heightCm: 170);
        expect(r.mosteller, closeTo(1.81, 0.05));
      });

      test('DuBois result for average adult', () {
        final r = BodyMetrics.calculateBSA(weightKg: 70, heightCm: 170);
        expect(r.dubois, closeTo(1.82, 0.05));
      });
    });

    group('IBW', () {
      test('Male 180cm', () {
        final r = BodyMetrics.calculateIBW(heightCm: 180, isMale: true);
        expect(r.value, closeTo(75.0, 0.5));
      });

      test('Female 165cm', () {
        final r = BodyMetrics.calculateIBW(heightCm: 165, isMale: false);
        expect(r.value, closeTo(57.4, 0.5));
      });

      test('Transparency contains formula', () {
        final r = BodyMetrics.calculateIBW(heightCm: 175, isMale: true);
        expect(r.transparency, contains('Devine Formula'));
      });
    });

  });
}