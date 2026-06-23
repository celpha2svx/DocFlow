import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';

class SaveToPatientScreen extends StatelessWidget {
  const SaveToPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Save Result to Patient')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Save this calculation to a patient record for later review and treatment tracking.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Save-to-patient flow is not implemented yet.')),
                  );
                },
                child: const Text('Select patient and save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
