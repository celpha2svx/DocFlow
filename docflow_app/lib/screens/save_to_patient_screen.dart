import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/utils/validators.dart';

class SaveToPatientScreen extends StatefulWidget {
  final String? calculationSummary;

  const SaveToPatientScreen({super.key, this.calculationSummary});

  @override
  State<SaveToPatientScreen> createState() => _SaveToPatientScreenState();
}

class _SaveToPatientScreenState extends State<SaveToPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _hospitalNumberController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _diagnosisController = TextEditingController();
  String _sex = 'Male';
  bool _saving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _hospitalNumberController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _diagnosisController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active doctor session found.')),
      );
      return;
    }

    setState(() => _saving = true);
    final now = DateTime.now();
    final patient = Patient(
      id: const Uuid().v4(),
      doctorPhone: doctor.phoneNumber,
      fullName: _fullNameController.text.trim(),
      hospitalNumber: _hospitalNumberController.text.trim().isEmpty ? null : _hospitalNumberController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      sex: _sex,
      weightKg: double.tryParse(_weightController.text.trim()),
      diagnosis: _diagnosisController.text.trim().isEmpty ? null : _diagnosisController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await appState.databaseService.insertPatient(patient);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient saved successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save patient: $e')),
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
      appBar: AppBar(title: const Text('Save Patient')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create a patient record to attach future calculations and notes.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.subtextColor,
                        height: 1.5,
                      ),
                ),
                if (widget.calculationSummary != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        widget.calculationSummary!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) {
                    if (!isValidName(value ?? '')) {
                      return 'Enter a patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hospitalNumberController,
                  decoration: const InputDecoration(labelText: 'Hospital number (optional)'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age'),
                  validator: (value) {
                    final age = int.tryParse(value ?? '');
                    if (age == null || age < 0 || age > 120) {
                      return 'Enter a valid age';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _sex,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  decoration: const InputDecoration(labelText: 'Sex'),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sex = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  validator: (value) {
                    final weight = double.tryParse(value ?? '');
                    if (weight == null || weight <= 0) {
                      return 'Enter a valid weight';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diagnosisController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Diagnosis / notes'),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
