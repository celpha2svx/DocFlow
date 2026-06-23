import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/widgets/patient_card.dart';
import 'package:docflow_app/models/patient.dart';

class PatientListScreen extends StatelessWidget {
  const PatientListScreen({super.key});

  static final List<Patient> _patients = [
    Patient(
      id: 'patient-001',
      doctorPhone: '+1234567890',
      fullName: 'Aisha Mbaye',
      hospitalNumber: 'HPL-5592',
      age: 7,
      sex: 'Female',
      weightKg: 24.5,
      diagnosis: 'Acute asthma exacerbation',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(18),
          itemCount: _patients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final patient = _patients[index];
            return PatientCard(
              patient: patient,
              recentCalculation: 'Latest QTc and MAP review',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Patient detail screen coming soon.')),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
