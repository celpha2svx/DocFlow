import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/models/patient.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;
  final String recentCalculation;
  final VoidCallback onTap;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.recentCalculation,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ageLabel = patient.age != null ? '${patient.age} yrs' : 'Age not set';
    final sexLabel = patient.sex ?? 'Sex unknown';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppConstants.textColor,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.hospitalNumber ?? 'No hospital number',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppConstants.subtextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$ageLabel · $sexLabel',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.subtextColor,
                          ),
                    ),
                  ),
                ],
              ),
              if (patient.diagnosis != null && patient.diagnosis!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  patient.diagnosis!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textColor,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: AppConstants.subtextColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      recentCalculation,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppConstants.subtextColor,
                          ),
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
