import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docflow_app/models/doctor.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/models/calculation.dart';

/// Service for syncing clinical data with Firebase Firestore.
/// All data is synced to the user's doctor phone number for identification.
class CloudSyncService {
  final FirebaseFirestore _firestore;

  /// Collection names
  static const String _collectionsPrefix = 'sync';
  static const String _doctorsCollection = 'doctors';
  static const String _patientsCollection = 'patients';
  static const String _calculationsCollection = 'calculations';

  CloudSyncService({FirebaseFirestore? firestore})
        : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sync doctor profile to the cloud.
  /// Uses doctor phone number as the document ID for easy retrieval.
  Future<void> syncDoctor(Doctor doctor) async {
    try {
      await _firestore
          .collection(_collectionsPrefix)
          .doc(doctor.phoneNumber)
          .collection(_doctorsCollection)
          .doc(doctor.id)
          .set({
            'id': doctor.id,
            'fullName': doctor.fullName,
            'phoneNumber': doctor.phoneNumber,
            'specialty': doctor.specialty,
            'pinHash': doctor.pinHash,
            'createdAt': doctor.createdAt.toIso8601String(),
            'syncedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow; // Let caller handle (likely offline)
    }
  }

  /// Sync a patient record to the cloud.
  /// Stored under doctor's phone number > patients collection.
  Future<void> syncPatient(Patient patient) async {
    try {
      await _firestore
          .collection(_collectionsPrefix)
          .doc(patient.doctorPhone)
          .collection(_patientsCollection)
          .doc(patient.id)
          .set({
            'id': patient.id,
            'doctorPhone': patient.doctorPhone,
            'fullName': patient.fullName,
            'hospitalNumber': patient.hospitalNumber,
            'age': patient.age,
            'sex': patient.sex,
            'weightKg': patient.weightKg,
            'diagnosis': patient.diagnosis,
            'createdAt': patient.createdAt.toIso8601String(),
            'updatedAt': patient.updatedAt.toIso8601String(),
            'syncedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Sync a calculation result to the cloud.
  /// Stored under doctor's phone number > patients > calculations.
  Future<void> syncCalculation(Calculation calculation) async {
    try {
      await _firestore
          .collection(_collectionsPrefix)
          .doc(calculation.doctorPhone)
          .collection(_patientsCollection)
          .doc(calculation.patientId)
          .collection(_calculationsCollection)
          .doc(calculation.id)
          .set({
            'id': calculation.id,
            'patientId': calculation.patientId,
            'doctorPhone': calculation.doctorPhone,
            'calculatorType': calculation.calculatorType,
            'category': calculation.category,
            'inputValues': calculation.inputValues,
            'resultValue': calculation.resultValue,
            'resultUnit': calculation.resultUnit,
            'resultLabel': calculation.resultLabel,
            'transparency': calculation.transparency,
            'createdAt': calculation.createdAt.toIso8601String(),
            'syncedAt': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Restore all patient data from the cloud for a given doctor.
  /// Returns a map of patient ID -> patient record.
  Future<Map<String, Patient>> restorePatientsFromCloud(
      String doctorPhone) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionsPrefix)
          .doc(doctorPhone)
          .collection(_patientsCollection)
          .get();

      final patients = <String, Patient>{};
      for (var doc in snapshot.docs) {
        final patient = _patientFromFirestore(doc.data());
        patients[patient.id] = patient;
      }
      return patients;
    } catch (e) {
      rethrow;
    }
  }

  /// Restore all calculations from the cloud for a given patient.
  /// Returns a list of calculation records sorted by date descending.
  Future<List<Calculation>> restoreCalculationsFromCloud(
      String doctorPhone, String patientId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionsPrefix)
          .doc(doctorPhone)
          .collection(_patientsCollection)
          .doc(patientId)
          .collection(_calculationsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      final calculations = <Calculation>[];
      for (var doc in snapshot.docs) {
        final calc = _calculationFromFirestore(doc.data());
        calculations.add(calc);
      }
      return calculations;
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctor profile from cloud (if exists).
  /// Useful for verifying sync status or restoring on reinstall.
  Future<Doctor?> getDoctorFromCloud(String doctorPhone) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionsPrefix)
          .doc(doctorPhone)
          .collection(_doctorsCollection)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return _doctorFromFirestore(snapshot.docs.first.data());
    } catch (e) {
      rethrow;
    }
  }

  /// Delete all patient data from cloud (e.g., for privacy/GDPR).
  /// Recursively deletes patient and all associated calculations.
  Future<void> deletePatientFromCloud(
      String doctorPhone, String patientId) async {
    try {
      final batch = _firestore.batch();

      // Delete all calculations first
      final calcsSnapshot = await _firestore
          .collection(_collectionsPrefix)
          .doc(doctorPhone)
          .collection(_patientsCollection)
          .doc(patientId)
          .collection(_calculationsCollection)
          .get();

      for (var doc in calcsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete patient record
      final patientRef = _firestore
          .collection(_collectionsPrefix)
          .doc(doctorPhone)
          .collection(_patientsCollection)
          .doc(patientId);
      batch.delete(patientRef);

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Convert Firestore patient data to Patient model.
  Patient _patientFromFirestore(Map<String, dynamic> data) {
    return Patient(
      id: data['id'] ?? '',
      doctorPhone: data['doctorPhone'] ?? '',
      fullName: data['fullName'] ?? '',
      hospitalNumber: data['hospitalNumber'],
      age: data['age'],
      sex: data['sex'],
      weightKg: data['weightKg'],
      diagnosis: data['diagnosis'],
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Helper: Convert Firestore calculation data to Calculation model.
  Calculation _calculationFromFirestore(Map<String, dynamic> data) {
    return Calculation(
      id: data['id'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorPhone: data['doctorPhone'] ?? '',
      calculatorType: data['calculatorType'] ?? '',
      category: data['category'] ?? '',
      inputValues: Map<String, dynamic>.from(data['inputValues'] ?? {}),
      resultValue: (data['resultValue'] as num?)?.toDouble() ?? 0.0,
      resultUnit: data['resultUnit'] ?? '',
      resultLabel: data['resultLabel'] ?? '',
      transparency: data['transparency'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Helper: Convert Firestore doctor data to Doctor model.
  Doctor _doctorFromFirestore(Map<String, dynamic> data) {
    return Doctor(
      id: data['id'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      specialty: data['specialty'],
      pinHash: data['pinHash'] ?? '',
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
