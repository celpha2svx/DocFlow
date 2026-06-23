import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/services/database_service.dart';
import 'package:docflow_app/models/doctor.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/models/calculation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  late DatabaseService databaseService;
  late String databasePath;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use temp directory for testing with proper permissions
    final tempDir = await Directory.systemTemp.createTemp('docflow_test_');
    databasePath = join(tempDir.path, 'test_docflow.db');
    databaseService = DatabaseService();
  });

  tearDown(() async {
    // Clean up after each test
    if (await databaseExists(databasePath)) {
      await deleteDatabase(databasePath);
    }
    final dir = Directory(dirname(databasePath));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  test('Insert and retrieve doctor', () async {
    final doctor = Doctor(
      id: 'doc-test-1',
      fullName: 'Dr. Test',
      phoneNumber: '08012345678',
      specialty: 'Internal Medicine',
      pinHash: 'hash',
      createdAt: DateTime.now(),
    );

    await databaseService.saveDoctor(doctor);
    final loaded = await databaseService.getDoctor('08012345678');

    expect(loaded, isNotNull);
    expect(loaded!.fullName, 'Dr. Test');
  });

  test('Insert patient and search by name', () async {
    final patient = Patient(
      id: 'patient-test-1',
      doctorPhone: '08087654321',
      fullName: 'Jane Doe',
      hospitalNumber: 'H001',
      age: 10,
      sex: 'Female',
      weightKg: 30.0,
      diagnosis: 'Asthma',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await databaseService.insertPatient(patient);
    final results = await databaseService.searchPatients('Jane', '08087654321');

    expect(results.length, 1);
    expect(results.first.fullName, 'Jane Doe');
  });

  test('Save calculation and retrieve patient history', () async {
    final patient = Patient(
      id: 'patient-test-2',
      doctorPhone: '08011223344',
      fullName: 'John Smith',
      hospitalNumber: 'H002',
      age: 15,
      sex: 'Male',
      weightKg: 50.0,
      diagnosis: 'Fever',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await databaseService.insertPatient(patient);

    final calc = Calculation(
      id: 'calc-test-1',
      patientId: 'patient-test-2',
      doctorPhone: '08011223344',
      calculatorType: 'bmi',
      category: 'Body Metrics',
      inputValues: {'weightKg': 50.0, 'heightCm': 150.0},
      resultValue: 22.2,
      resultUnit: 'kg/m²',
      resultLabel: 'BMI',
      transparency: 'BMI = 50 / (1.5²) = 22.2',
      createdAt: DateTime.now(),
    );

    await databaseService.saveCalculation(calc);
    final history = await databaseService.getPatientHistory('patient-test-2');

    expect(history.length, 1);
    expect(history.first.calculatorType, 'bmi');
  });
}
