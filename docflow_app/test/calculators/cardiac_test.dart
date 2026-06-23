import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/calculators/cardiac.dart';

void main() {
  group('Cardiac —', () {
    group('Mean Arterial Pressure (MAP)', () {
      test('Normal MAP for 120/80', () {
        final r = Cardiac.calculateMAP(systolic: 120, diastolic: 80);
        expect(r.value, 93.3);
        expect(r.interpretation, 'Normal');
      });

      test('Critical MAP for 90/50', () {
        final r = Cardiac.calculateMAP(systolic: 90, diastolic: 50);
        expect(r.value, 63.3);
        expect(r.interpretation, 'Critical — immediate intervention required');
      });

      test('Elevated MAP for 180/110', () {
        final r = Cardiac.calculateMAP(systolic: 180, diastolic: 110);
        expect(r.value, 133.3);
        expect(r.interpretation, 'Elevated — assess for hypertensive emergency');
      });

      test('Transparency contains both formula forms', () {
        final r = Cardiac.calculateMAP(systolic: 120, diastolic: 80);
        expect(r.transparency, contains('Formula 1'));
        expect(r.transparency, contains('Formula 2'));
      });
    });

    group('Corrected QT Interval (QTc)', () {
      test('QT 400ms, HR 60 => Bazett 400ms', () {
        final r = Cardiac.calculateQTc(qtMs: 400, heartRate: 60);
        expect(r.bazett, 400.0);
        expect(r.interpretation, 'Normal');
      });

      test('QT 480ms, HR 72 => Bazett prolonged', () {
        final r = Cardiac.calculateQTc(qtMs: 480, heartRate: 72);
        expect(r.bazett, greaterThan(440.0));
        expect(r.fridericia, isNotNull);
      });

      test('Transparency contains both formula names', () {
        final r = Cardiac.calculateQTc(qtMs: 420, heartRate: 80);
        expect(r.transparency, contains("Bazett's Formula"));
        expect(r.transparency, contains("Fridericia's Formula"));
      });
    });

    group('Cardiac Output', () {
      test('CO 5.04 L/min normal range', () {
        final r = Cardiac.calculateCardiacOutput(heartRate: 72, strokeVolume: 70);
        expect(r.cardiacOutput, 5.04);
        expect(r.interpretation, 'Normal');
      });

      test('Low CO for HR 50, SV 40', () {
        final r = Cardiac.calculateCardiacOutput(heartRate: 50, strokeVolume: 40);
        expect(r.cardiacOutput, 2.0);
        expect(r.interpretation, 'Low — assess for cardiogenic shock');
      });

      test('Cardiac index with BSA 1.8', () {
        final r = Cardiac.calculateCardiacOutput(heartRate: 72, strokeVolume: 70, bsa: 1.8);
        expect(r.cardiacIndex, closeTo(2.8, 0.05));
      });
    });
  });
}
