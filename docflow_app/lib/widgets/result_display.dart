import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';

/// Widget for displaying calculation results with clinical interpretation.
/// Shows the numeric result, units, label (e.g., "Normal", "Elevated"), and clinical context.
class ResultDisplay extends StatelessWidget {
  /// Calculated numeric result
  final String resultValue;

  /// Unit of measurement (e.g., "mmHg", "mL/min", "mL/min/1.73m²")
  final String resultUnit;

  /// Clinical interpretation label (e.g., "Normal", "Elevated", "Critical")
  final String resultLabel;

  /// Color for the result badge (usually determined by interpretation)
  final Color? labelColor;

  /// Show a detailed explanation of what this result means
  final String? interpretation;

  /// Callback for copying result to clipboard
  final VoidCallback? onCopy;

  /// Whether result is in a warning/critical state
  final bool isWarning;

  const ResultDisplay({
    Key? key,
    required this.resultValue,
    required this.resultUnit,
    required this.resultLabel,
    this.labelColor,
    this.interpretation,
    this.onCopy,
    this.isWarning = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = labelColor ??
        (isWarning ? AppConstants.errorColor : AppConstants.successColor);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: isWarning
          ? AppConstants.errorColor.withOpacity(0.05)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Result value with unit
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  resultValue,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                ),
                const SizedBox(width: 8),
                Text(
                  resultUnit,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.subtextColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Clinical interpretation badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.1),
                border: Border.all(color: effectiveColor),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                resultLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: effectiveColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            // Interpretation text
            if (interpretation != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  interpretation!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textColor,
                        height: 1.6,
                      ),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            // Copy button
            if (onCopy != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onCopy,
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy Result'),
                style: TextButton.styleFrom(
                  foregroundColor: AppConstants.primaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying multiple results (e.g., Bazett and Fridericia QTc values).
class MultiResultDisplay extends StatelessWidget {
  /// List of results to display
  final List<Map<String, String>> results;

  /// Title for the result group
  final String title;

  /// Primary result index (highlighted/emphasized)
  final int primaryIndex;

  const MultiResultDisplay({
    Key? key,
    required this.results,
    required this.title,
    this.primaryIndex = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          results.length,
          (index) {
            final result = results[index];
            final isPrimary = index == primaryIndex;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < results.length - 1 ? 8 : 0,
              ),
              child: Opacity(
                opacity: isPrimary ? 1.0 : 0.8,
                child: ResultDisplay(
                  resultValue: result['value'] ?? '0',
                  resultUnit: result['unit'] ?? '',
                  resultLabel: result['label'] ?? 'Result',
                  labelColor: isPrimary ? AppConstants.successColor : null,
                  interpretation: result['interpretation'],
                  isWarning: result['warning'] == 'true',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
