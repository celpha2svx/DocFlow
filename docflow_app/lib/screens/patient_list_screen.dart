import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/models/calculation.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/screens/patient_detail_screen.dart';
import 'package:docflow_app/screens/save_to_patient_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patients')),
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
                          'No patients found.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppConstants.subtextColor,
                              ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        return Card(
                          child: ListTile(
                            title: Text(patient.fullName),
                            subtitle: FutureBuilder<List<Calculation>>(
                              future: AppStateProvider.of(context).databaseService.getPatientHistory(patient.id),
                              builder: (context, historySnapshot) {
                                final latest = historySnapshot.data?.isNotEmpty == true
                                    ? historySnapshot.data!.first
                                    : null;
                                final details = [
                                  if (patient.sex != null) patient.sex!,
                                  if (patient.age != null) '${patient.age} yrs',
                                  if (patient.hospitalNumber != null && patient.hospitalNumber!.isNotEmpty)
                                    patient.hospitalNumber!,
                                ].join(' • ');
                                final lastCalc = latest == null
                                    ? 'No saved calculations yet'
                                    : 'Last: ${latest.resultLabel} • ${latest.createdAt}';
                                return Text('$details\n$lastCalc');
                              },
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patient: patient),
                                ),
                              );
                              setState(() {});
                            },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SaveToPatientScreen()),
          );
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Patient'),
      ),
    );
  }
}
