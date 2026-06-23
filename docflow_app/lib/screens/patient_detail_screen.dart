import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/models/calculation.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/screens/search_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  Future<List<Calculation>> _loadHistory(BuildContext context) async {
    final appState = AppStateProvider.maybeOf(context);
    if (appState == null) return <Calculation>[];
    return appState.databaseService.getPatientHistory(patient.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textColor,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (patient.sex != null) patient.sex!,
                          if (patient.age != null) '${patient.age} yrs',
                          if (patient.hospitalNumber != null && patient.hospitalNumber!.isNotEmpty)
                            'HN ${patient.hospitalNumber!}',
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.subtextColor,
                            ),
                      ),
                      if (patient.diagnosis != null && patient.diagnosis!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          patient.diagnosis!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Calculation history',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Calculation>>(
                  future: _loadHistory(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final history = snapshot.data ?? <Calculation>[];
                    if (history.isEmpty) {
                      return Center(
                        child: Text(
                          'No saved calculations yet.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppConstants.subtextColor,
                              ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final calc = history[index];
                        return Card(
                          child: ListTile(
                            title: Text(calc.resultLabel),
                            subtitle: Text(
                              '${calc.resultValue.toStringAsFixed(2)} ${calc.resultUnit}\n${calc.calculatorType} • ${calc.createdAt}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Recalculate flow can be connected from here.')),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Calculation'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
