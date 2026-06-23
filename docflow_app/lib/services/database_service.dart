import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/calculation.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

class DatabaseService {
  static const _databaseName = 'docflow.db';
  static const _databaseVersion = 2;

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
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_submissions (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          payload TEXT NOT NULL,
          created_at TEXT NOT NULL,
          synced INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_pending_synced ON pending_submissions(synced)');
    }
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

    await db.execute('''
      CREATE TABLE pending_submissions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_patient_name ON patients(full_name)');
    await db.execute('CREATE INDEX idx_patient_hospital ON patients(hospital_number)');
    await db.execute('CREATE INDEX idx_calc_patient ON calculations(patient_id)');
    await db.execute('CREATE INDEX idx_calc_type ON calculations(calculator_type)');
    await db.execute('CREATE INDEX idx_calc_date ON calculations(created_at)');
    await db.execute('CREATE INDEX idx_pending_synced ON pending_submissions(synced)');
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
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Patient>> searchPatients(String query, String doctorPhone) async {
    final db = await database;
    final trimmed = query.trim();
    final rows = trimmed.isEmpty
        ? await db.query(
            'patients',
            where: 'doctor_phone = ?',
            whereArgs: [doctorPhone],
            orderBy: 'updated_at DESC',
          )
        : await db.query(
            'patients',
            where: 'doctor_phone = ? AND (full_name LIKE ? OR hospital_number LIKE ?)',
            whereArgs: [doctorPhone, '%$trimmed%', '%$trimmed%'],
            orderBy: 'updated_at DESC',
          );

    return rows.map(_patientFromMap).toList();
  }

  Future<List<Patient>> getPatientsForDoctor(String doctorPhone) async {
    final db = await database;
    final rows = await db.query(
      'patients',
      where: 'doctor_phone = ?',
      whereArgs: [doctorPhone],
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
    await db.transaction((txn) async {
      await txn.delete('calculations', where: 'patient_id = ?', whereArgs: [id]);
      await txn.delete('patients', where: 'id = ?', whereArgs: [id]);
    });
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
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> savePendingSubmission({
    required String id,
    required String type,
    required Map<String, dynamic> payload,
    DateTime? createdAt,
  }) async {
    final db = await database;
    await db.insert('pending_submissions', {
      'id': id,
      'type': type,
      'payload': jsonEncode(payload),
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      'synced': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSubmissions({bool onlyUnsynced = true}) async {
    final db = await database;
    final rows = await db.query(
      'pending_submissions',
      where: onlyUnsynced ? 'synced = 0' : null,
      orderBy: 'created_at ASC',
    );
    return rows
        .map(
          (row) => {
            'id': row['id'] as String,
            'type': row['type'] as String,
            'payload': jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            'created_at': row['created_at'] as String,
            'synced': row['synced'] as int? ?? 0,
          },
        )
        .toList();
  }

  Future<void> markPendingSubmissionSynced(String id) async {
    final db = await database;
    await db.update(
      'pending_submissions',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<List<Calculation>> getCalculationsForDoctor(String doctorPhone) async {
    final db = await database;
    final rows = await db.query(
      'calculations',
      where: 'doctor_phone = ?',
      whereArgs: [doctorPhone],
      orderBy: 'created_at DESC',
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
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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

  Future<void> updateDoctor(Doctor doctor) async {
    final db = await database;
    await db.update(
      'doctors',
      {
        'full_name': doctor.fullName,
        'specialty': doctor.specialty,
        'pin_hash': doctor.pinHash,
      },
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<void> deleteDoctor(String id) async {
    final db = await database;
    await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // Bulk operations
  Future<int> deleteCalculationsByPatient(String patientId) async {
    final db = await database;
    return await db.delete(
      'calculations',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  Future<int> getPatientCount(String doctorPhone) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM patients WHERE doctor_phone = ?',
      [doctorPhone],
    );
    return result.first['count'] as int? ?? 0;
  }

  Future<int> getCalculationCount(String patientId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM calculations WHERE patient_id = ?',
      [patientId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Clear all data (use with caution - useful for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('calculations');
    await db.delete('patients');
    await db.delete('doctors');
  }

  /// Close database connection
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Patient _patientFromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      doctorPhone: map['doctor_phone'] as String,
      fullName: map['full_name'] as String,
      hospitalNumber: map['hospital_number'] as String?,
      age: map['age'] as int?,
      sex: map['sex'] as String?,
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
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
      resultValue: (map['result_value'] as num).toDouble(),
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
