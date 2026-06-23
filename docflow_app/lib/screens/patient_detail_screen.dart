import 'package:flutter/material.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/widgets/patient_card.dart';
import 'package:docflow_app/utils/constants.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

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
              PatientCard(
                patient: patient,
                recentCalculation: 'Latest calculation summary',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Text(
                'Patient history and saved calculations will appear here once patient management is implemented.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
