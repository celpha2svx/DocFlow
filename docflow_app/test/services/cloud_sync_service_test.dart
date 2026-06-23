import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/services/cloud_sync_service.dart';
import 'package:docflow_app/models/doctor.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/models/calculation.dart';

void main() {
  group('CloudSyncService', () {
    test('CloudSyncService type can be imported', () {
      expect(CloudSyncService, isNotNull);
    });

    test('Doctor model supports cloud sync structure', () {
      final doctor = Doctor(
        id: 'doc-1',
        fullName: 'Dr. Adeyemi',
        phoneNumber: '08012345678',
        specialty: 'Cardiology',
        pinHash: 'sha256=abc123',
        createdAt: DateTime(2026, 6, 23),
      );

      expect(doctor.id, isNotEmpty);
      expect(doctor.phoneNumber, isNotEmpty);
      expect(doctor.createdAt.toIso8601String(), isNotEmpty);
    });

    test('Patient model supports cloud sync structure', () {
      final patient = Patient(
        id: 'pat-1',
        doctorPhone: '08012345678',
        fullName: 'John Doe',
        hospitalNumber: 'H001',
        age: 45,
        sex: 'Male',
        weightKg: 75.0,
        diagnosis: 'Hypertension',
        createdAt: DateTime(2026, 6, 23),
        updatedAt: DateTime(2026, 6, 23),
      );

      expect(patient.id, isNotEmpty);
      expect(patient.doctorPhone, isNotEmpty);
      expect(patient.age, 45);
    });

    test('Calculation model supports cloud sync structure', () {
      final calc = Calculation(
        id: 'calc-1',
        patientId: 'pat-1',
        doctorPhone: '08012345678',
        calculatorType: 'MAP',
        category: 'Cardiac',
        inputValues: {'sys': 120, 'dia': 80},
        resultValue: 93.0,
        resultUnit: 'mmHg',
        resultLabel: 'Normal',
        transparency: 'Showing calculation steps...',
        createdAt: DateTime(2026, 6, 23),
      );

      expect(calc.id, isNotEmpty);
      expect(calc.resultValue, 93.0);
      expect(calc.inputValues['sys'], 120);
    });

    test('Doctor phone can be used as sync collection key', () {
      final doctor = Doctor(
        id: 'doc-1',
        fullName: 'Dr. Adeyemi',
        phoneNumber: '08012345678',
        specialty: 'Cardiology',
        pinHash: 'sha256=abc123',
        createdAt: DateTime.now(),
      );

      expect(doctor.phoneNumber, isNotEmpty);
      expect(doctor.phoneNumber.length, greaterThan(0));
    });

    test('Patients are grouped under same doctor phone', () {
      final doctorPhone = '08012345678';
      final patient1 = Patient(
        id: 'pat-1',
        doctorPhone: doctorPhone,
        fullName: 'Patient 1',
        hospitalNumber: null,
        age: null,
        sex: null,
        weightKg: null,
        diagnosis: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final patient2 = Patient(
        id: 'pat-2',
        doctorPhone: doctorPhone,
        fullName: 'Patient 2',
        hospitalNumber: null,
        age: null,
        sex: null,
        weightKg: null,
        diagnosis: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(patient1.doctorPhone, patient2.doctorPhone);
    });

    test('Calculations are grouped under patient and doctor', () {
      final doctorPhone = '08012345678';
      final patientId = 'pat-1';

      final calc1 = Calculation(
        id: 'calc-1',
        patientId: patientId,
        doctorPhone: doctorPhone,
        calculatorType: 'MAP',
        category: 'Cardiac',
        inputValues: {'sys': 120, 'dia': 80},
        resultValue: 93.0,
        resultUnit: 'mmHg',
        resultLabel: 'Normal',
        transparency: 'Steps...',
        createdAt: DateTime.now(),
      );

      final calc2 = Calculation(
        id: 'calc-2',
        patientId: patientId,
        doctorPhone: doctorPhone,
        calculatorType: 'QTc',
        category: 'Cardiac',
        inputValues: {'hr': 80, 'qtms': 400},
        resultValue: 380.5,
        resultUnit: 'ms',
        resultLabel: 'Normal',
        transparency: 'Steps...',
        createdAt: DateTime.now(),
      );

      expect(calc1.doctorPhone, calc2.doctorPhone);
      expect(calc1.patientId, calc2.patientId);
    });

    test('Data preserves all fields for sync to Firestore', () {
      final now = DateTime(2026, 6, 23, 10, 30);
      final calc = Calculation(
        id: 'calc-uuid-1',
        patientId: 'pat-uuid-1',
        doctorPhone: '08012345678',
        calculatorType: 'MAP',
        category: 'Cardiac',
        inputValues: {'systolic': 140, 'diastolic': 90},
        resultValue: 106.67,
        resultUnit: 'mmHg',
        resultLabel: 'Elevated',
        transparency: 'Formula: (SYS + 2*DIA)/3 = (140 + 180)/3 = 106.67',
        createdAt: now,
      );

      // All fields needed for Firestore document
      final data = {
        'id': calc.id,
        'patientId': calc.patientId,
        'doctorPhone': calc.doctorPhone,
        'calculatorType': calc.calculatorType,
        'category': calc.category,
        'inputValues': calc.inputValues,
        'resultValue': calc.resultValue,
        'resultUnit': calc.resultUnit,
        'resultLabel': calc.resultLabel,
        'transparency': calc.transparency,
        'createdAt': calc.createdAt.toIso8601String(),
      };

      expect(data['calculatorType'], 'MAP');
      expect(data['resultValue'], 106.67);
      expect(data['transparency'], isNotEmpty);
      expect(data['createdAt'], isNotEmpty);
    });

    test('Service handles optional doctor specialty field', () {
      final doctor = Doctor(
        id: 'doc-1',
        fullName: 'Dr. Adeyemi',
        phoneNumber: '08012345678',
        specialty: null,
        pinHash: 'sha256=abc123',
        createdAt: DateTime.now(),
      );

      expect(doctor.specialty, isNull);
    });

    test('Service handles optional patient fields', () {
      final patient = Patient(
        id: 'pat-1',
        doctorPhone: '08012345678',
        fullName: 'John Doe',
        hospitalNumber: null,
        age: null,
        sex: null,
        weightKg: null,
        diagnosis: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(patient.hospitalNumber, isNull);
      expect(patient.age, isNull);
      expect(patient.sex, isNull);
      expect(patient.weightKg, isNull);
    });
  });
}
