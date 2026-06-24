import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:docflow_app/screens/save_to_patient_screen.dart';
import 'package:docflow_app/screens/select_patient_screen.dart';
import 'package:docflow_app/widgets/result_display.dart';
import 'package:docflow_app/widgets/formula_display.dart';
import 'package:docflow_app/utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final String calculatorName;
  final String calculatorId;
  final String category;
  final Map<String, dynamic> inputValues;
  final String resultValue;
  final String resultUnit;
  final String resultLabel;
  final String interpretation;
  final String transparency;
  final String calculationSummary;

  const ResultScreen({
    super.key,
    required this.calculatorName,
    required this.calculatorId,
    required this.category,
    required this.inputValues,
    required this.resultValue,
    required this.resultUnit,
    required this.resultLabel,
    required this.interpretation,
    required this.transparency,
    required this.calculationSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(calculatorName)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResultDisplay(
                resultValue: resultValue,
                resultUnit: resultUnit,
                resultLabel: resultLabel,
                interpretation: interpretation,
              ),
              const SizedBox(height: 16),
              if (transparency.isNotEmpty)
                FormulaDisplay(
                  formula: transparency,
                  formulaName: 'Formula Transparency',
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SaveToPatientScreen(
                        calculationSummary: calculationSummary,
                        calculatorId: calculatorId,
                        category: category,
                        inputValues: inputValues,
                        resultValue: resultValue,
                        resultUnit: resultUnit,
                        resultLabel: resultLabel,
                        transparency: transparency,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Save to New Patient'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SelectPatientScreen(
                        calculatorId: calculatorId,
                        category: category,
                        inputValues: inputValues,
                        resultValue: resultValue,
                        resultUnit: resultUnit,
                        resultLabel: resultLabel,
                        transparency: transparency,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_search_outlined),
                label: const Text('Save to Existing Patient'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(
                      text: '$calculatorName: $resultValue $resultUnit - $resultLabel',
                    ),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share Result'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
