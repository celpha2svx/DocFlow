import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/models/calculation.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/screens/save_to_patient_screen.dart';
import 'package:docflow_app/screens/search_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Patient _patient;

  @override
  void initState() {
    super.initState();
    _patient = widget.patient;
  }

  Future<List<Calculation>> _loadHistory() async {
    final appState = AppStateProvider.maybeOf(context);
    if (appState == null) return <Calculation>[];
    return appState.databaseService.getPatientHistory(_patient.id);
  }

  Future<void> _deletePatient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Delete ${_patient.fullName} and all their saved calculations?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppConstants.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final appState = AppStateProvider.maybeOf(context);
    if (appState == null) return;

    try {
      await appState.databaseService.deletePatient(_patient.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_patient.fullName} deleted')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit patient',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SaveToPatientScreen(existingPatient: _patient),
                ),
              ).then((_) {
                // Refresh patient data on return
                final appState = AppStateProvider.maybeOf(context);
                if (appState != null) {
                  appState.databaseService.getPatient(_patient.id).then((updated) {
                    if (updated != null && mounted) {
                      setState(() => _patient = updated);
                    }
                  });
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete patient',
            onPressed: _deletePatient,
          ),
        ],
      ),
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
                        _patient.fullName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppConstants.textColor,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        [
                          if (_patient.sex != null) _patient.sex!,
                          if (_patient.age != null) '${_patient.age} yrs',
                          if (_patient.hospitalNumber != null && _patient.hospitalNumber!.isNotEmpty)
                            'HN ${_patient.hospitalNumber!}',
                        ].join(' • '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppConstants.subtextColor,
                            ),
                      ),
                      if (_patient.diagnosis != null && _patient.diagnosis!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _patient.diagnosis!,
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
                  future: _loadHistory(),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final calc = history[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              '${calc.resultValue.toStringAsFixed(2)} ${calc.resultUnit}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${calc.resultLabel}\n${calc.calculatorType} • ${calc.createdAt}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${calc.calculatorType}: ${calc.resultValue.toStringAsFixed(2)} ${calc.resultUnit}',
                                  ),
                                ),
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
