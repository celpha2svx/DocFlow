import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';

/// Widget for displaying calculation formulas with step-by-step transparency.
/// Shows the mathematical formula and how values are substituted into it.
/// Designed for medical transparency - doctors need to verify calculations.
class FormulaDisplay extends StatelessWidget {
  /// Formula string with substituted values (e.g., "MAP = (120 + 2*80)/3 = 93")
  final String formula;

  /// Brief formula name (e.g., "MAP", "QTc Bazett", "Cardiac Output")
  final String formulaName;

  /// Full explanation of what the formula calculates
  final String? description;

  /// Show the formula in expanded view (shows more details)
  final bool expanded;

  /// Callback when user taps to expand/collapse
  final VoidCallback? onToggleExpand;

  const FormulaDisplay({
    Key? key,
    required this.formula,
    required this.formulaName,
    this.description,
    this.expanded = false,
    this.onToggleExpand,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onToggleExpand,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formulaName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                  ),
                  if (onToggleExpand != null)
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppConstants.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  border: Border.all(
                    color: AppConstants.primaryColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formula,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: AppConstants.textColor,
                      ),
                ),
              ),
              if (expanded && description != null) ...[
                const SizedBox(height: 12),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.subtextColor,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget for displaying multiple formulas with transparency (e.g., QTc with Bazett + Fridericia).
class MultiFormulaDisplay extends StatefulWidget {
  /// List of formulas to display (each with name and expression)
  final List<Map<String, String>> formulas;

  /// Title for the multi-formula display
  final String title;

  const MultiFormulaDisplay({
    Key? key,
    required this.formulas,
    required this.title,
  }) : super(key: key);

  @override
  State<MultiFormulaDisplay> createState() => _MultiFormulaDisplayState();
}

class _MultiFormulaDisplayState extends State<MultiFormulaDisplay> {
  late List<bool> _expandedStates;

  @override
  void initState() {
    super.initState();
    _expandedStates = List.filled(widget.formulas.length, false);
  }

  void _toggleExpanded(int index) {
    setState(() {
      _expandedStates[index] = !_expandedStates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          widget.formulas.length,
          (index) {
            final formula = widget.formulas[index];
            return FormulaDisplay(
              formula: formula['formula'] ?? '',
              formulaName: formula['name'] ?? 'Formula ${index + 1}',
              description: formula['description'],
              expanded: _expandedStates[index],
              onToggleExpand: () => _toggleExpanded(index),
            );
          },
        ),
      ],
    );
  }
}
