import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/models/calculation.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/screens/patient_detail_screen.dart';
import 'package:docflow_app/services/cloud_sync_service.dart';
import 'package:docflow_app/utils/constants.dart';

class SelectPatientScreen extends StatefulWidget {
  final String calculatorId;
  final String category;
  final Map<String, dynamic> inputValues;
  final String resultValue;
  final String resultUnit;
  final String resultLabel;
  final String transparency;

  const SelectPatientScreen({
    super.key,
    required this.calculatorId,
    required this.category,
    required this.inputValues,
    required this.resultValue,
    required this.resultUnit,
    required this.resultLabel,
    required this.transparency,
  });

  @override
  State<SelectPatientScreen> createState() => _SelectPatientScreenState();
}

class _SelectPatientScreenState extends State<SelectPatientScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Patient>> _loadPatients(BuildContext context) async {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return <Patient>[];
    return appState.databaseService.searchPatients(_query, doctor.phoneNumber);
  }

  double _parseResultValue(String value) {
    final first = value.split('/').first.trim();
    return double.tryParse(first) ?? 0.0;
  }

  Future<void> _saveToPatient(Patient patient) async {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return;

    setState(() => _saving = true);
    final now = DateTime.now();

    try {
      final calc = Calculation(
        id: const Uuid().v4(),
        patientId: patient.id,
        doctorPhone: doctor.phoneNumber,
        calculatorType: widget.calculatorId,
        category: widget.category,
        inputValues: widget.inputValues,
        resultValue: _parseResultValue(widget.resultValue),
        resultUnit: widget.resultUnit,
        resultLabel: widget.resultLabel,
        transparency: widget.transparency,
        createdAt: now,
      );
      await appState.databaseService.saveCalculation(calc);

      if (!mounted) return;

      // Update patient's updatedAt timestamp
      final updated = patient.copyWith(updatedAt: now);
      await appState.databaseService.updatePatient(updated);

      // Best-effort cloud sync
      CloudSyncService(databaseService: appState.databaseService)
          .syncIfOnline(doctor.phoneNumber);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PatientDetailScreen(patient: updated),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save calculation: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Patient')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search patients by name or hospital number',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() => _query = value);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Patient>>(
                  future: _loadPatients(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final patients = snapshot.data ?? <Patient>[];
                    if (patients.isEmpty) {
                      return Center(
                        child: Text(
                          _query.isEmpty ? 'No patients saved yet.' : 'No patients found.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppConstants.subtextColor,
                              ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        final details = [
                          if (patient.sex != null) patient.sex!,
                          if (patient.age != null) '${patient.age} yrs',
                          if (patient.hospitalNumber != null && patient.hospitalNumber!.isNotEmpty)
                            patient.hospitalNumber!,
                        ].join(' • ');

                        return Card(
                          child: ListTile(
                            title: Text(patient.fullName),
                            subtitle: Text(details),
                            trailing: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.chevron_right),
                            onTap: _saving ? null : () => _saveToPatient(patient),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}