import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/calculation.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

class DatabaseService {
  static const _databaseName = 'docflow.db';
  static const _databaseVersion = 1;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE doctors (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        phone_number TEXT UNIQUE NOT NULL,
        specialty TEXT,
        pin_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY,
        doctor_phone TEXT NOT NULL,
        full_name TEXT NOT NULL,
        hospital_number TEXT,
        age INTEGER,
        sex TEXT,
        weight_kg REAL,
        diagnosis TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE calculations (
        id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        doctor_phone TEXT NOT NULL,
        calculator_type TEXT NOT NULL,
        category TEXT NOT NULL,
        input_values TEXT NOT NULL,
        result_value REAL NOT NULL,
        result_unit TEXT NOT NULL,
        result_label TEXT NOT NULL,
        transparency TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (patient_id) REFERENCES patients(id)
      )
    ''');

    await db.execute('CREATE INDEX idx_patient_name ON patients(full_name)');
    await db.execute('CREATE INDEX idx_patient_hospital ON patients(hospital_number)');
    await db.execute('CREATE INDEX idx_calc_patient ON calculations(patient_id)');
    await db.execute('CREATE INDEX idx_calc_type ON calculations(calculator_type)');
    await db.execute('CREATE INDEX idx_calc_date ON calculations(created_at)');
  }

  // Patients
  Future<void> insertPatient(Patient patient) async {
    final db = await database;
    await db.insert('patients', {
      'id': patient.id,
      'doctor_phone': patient.doctorPhone,
      'full_name': patient.fullName,
      'hospital_number': patient.hospitalNumber,
      'age': patient.age,
      'sex': patient.sex,
      'weight_kg': patient.weightKg,
      'diagnosis': patient.diagnosis,
      'created_at': patient.createdAt.toIso8601String(),
      'updated_at': patient.updatedAt.toIso8601String(),
    });
  }

  Future<List<Patient>> searchPatients(String query, String doctorPhone) async {
    final db = await database;
    final String likeQuery = '%${query.trim()}%';

    final rows = await db.query(
      'patients',
      where: 'doctor_phone = ? AND (full_name LIKE ? OR hospital_number LIKE ?)',
      whereArgs: [doctorPhone, likeQuery, likeQuery],
      orderBy: 'updated_at DESC',
    );

    return rows.map(_patientFromMap).toList();
  }

  Future<Patient?> getPatient(String id) async {
    final db = await database;
    final rows = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isNotEmpty ? _patientFromMap(rows.first) : null;
  }

  Future<void> updatePatient(Patient patient) async {
    final db = await database;
    await db.update(
      'patients',
      {
        'doctor_phone': patient.doctorPhone,
        'full_name': patient.fullName,
        'hospital_number': patient.hospitalNumber,
        'age': patient.age,
        'sex': patient.sex,
        'weight_kg': patient.weightKg,
        'diagnosis': patient.diagnosis,
        'created_at': patient.createdAt.toIso8601String(),
        'updated_at': patient.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<void> deletePatient(String id) async {
    final db = await database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // Calculations
  Future<void> saveCalculation(Calculation calc) async {
    final db = await database;
    await db.insert('calculations', {
      'id': calc.id,
      'patient_id': calc.patientId,
      'doctor_phone': calc.doctorPhone,
      'calculator_type': calc.calculatorType,
      'category': calc.category,
      'input_values': jsonEncode(calc.inputValues),
      'result_value': calc.resultValue,
      'result_unit': calc.resultUnit,
      'result_label': calc.resultLabel,
      'transparency': calc.transparency,
      'created_at': calc.createdAt.toIso8601String(),
    });
  }

  Future<List<Calculation>> getPatientHistory(String patientId) async {
    final db = await database;
    final rows = await db.query(
      'calculations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at DESC',
    );
    return rows.map(_calculationFromMap).toList();
  }

  Future<List<Calculation>> getRecentCalculations(String doctorPhone, {int limit = 20}) async {
    final db = await database;
    final rows = await db.query(
      'calculations',
      where: 'doctor_phone = ?',
      whereArgs: [doctorPhone],
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(_calculationFromMap).toList();
  }

  // Doctor
  Future<void> saveDoctor(Doctor doctor) async {
    final db = await database;
    await db.insert('doctors', {
      'id': doctor.id,
      'full_name': doctor.fullName,
      'phone_number': doctor.phoneNumber,
      'specialty': doctor.specialty,
      'pin_hash': doctor.pinHash,
      'created_at': doctor.createdAt.toIso8601String(),
    });
  }

  Future<Doctor?> getDoctor(String phoneNumber) async {
    final db = await database;
    final rows = await db.query(
      'doctors',
      where: 'phone_number = ?',
      whereArgs: [phoneNumber],
    );
    return rows.isNotEmpty ? _doctorFromMap(rows.first) : null;
  }

  Patient _patientFromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      doctorPhone: map['doctor_phone'] as String,
      fullName: map['full_name'] as String,
      hospitalNumber: map['hospital_number'] as String?,
      age: map['age'] as int?,
      sex: map['sex'] as String?,
      weightKg: map['weight_kg'] as double?,
      diagnosis: map['diagnosis'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Calculation _calculationFromMap(Map<String, dynamic> map) {
    return Calculation(
      id: map['id'] as String,
      patientId: map['patient_id'] as String,
      doctorPhone: map['doctor_phone'] as String,
      calculatorType: map['calculator_type'] as String,
      category: map['category'] as String,
      inputValues: jsonDecode(map['input_values'] as String) as Map<String, dynamic>,
      resultValue: map['result_value'] as double,
      resultUnit: map['result_unit'] as String,
      resultLabel: map['result_label'] as String,
      transparency: map['transparency'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Doctor _doctorFromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      phoneNumber: map['phone_number'] as String,
      specialty: map['specialty'] as String?,
      pinHash: map['pin_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
