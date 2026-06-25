import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:docflow_app/screens/save_to_patient_screen.dart';
import 'package:docflow_app/screens/select_patient_screen.dart';
import 'package:docflow_app/services/calculator_loader.dart';
import 'package:docflow_app/services/formula_evaluator.dart';
import 'package:docflow_app/widgets/result_display.dart';
import 'package:docflow_app/widgets/formula_display.dart';
import 'package:docflow_app/utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final CalculatorDefinition calculator;
  final Map<String, dynamic> inputValues;
  final Map<String, dynamic> resultValues;

  const ResultScreen({
    super.key,
    required this.calculator,
    required this.inputValues,
    required this.resultValues,
  });

  String _format(dynamic val, int decimals) {
    if (val is num) {
      return val.toStringAsFixed(decimals);
    }
    return val.toString();
  }

  InterpretationRule? _findInterpretation() {
    final primary = calculator.primaryResult;
    final vars = Map<String, dynamic>.from(inputValues)
      ..addAll(resultValues)
      ..['value'] = resultValues[primary.key];
    for (final rule in calculator.interpretations) {
      try {
        final evaluator = FormulaEvaluator(vars, rule.condition);
        if (evaluator.evaluate() == true) return rule;
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic> _buildTransparencyVars() {
    final vars = <String, dynamic>{};
    vars.addAll(inputValues);
    vars.addAll(resultValues);

    if (vars.containsKey('heightCm')) {
      final h = double.tryParse(vars['heightCm'].toString()) ?? 0;
      vars['heightM'] = (h / 100);
      vars['heightMSquared'] = (h / 100) * (h / 100);
    }
    if (vars.containsKey('heartRate')) {
      final hr = double.tryParse(vars['heartRate'].toString()) ?? 0;
      if (hr > 0) vars['rrInterval'] = 60 / hr;
    }
    if (resultValues.containsKey('total_24hr')) {
      vars['halfTotal'] = (resultValues['total_24hr'] as num) / 2;
    }
    if (vars.containsKey('isFemale')) {
      final isF = vars['isFemale'] == true || vars['isFemale'] == 'true';
      vars['sexFactor'] = isF ? 0.85 : 1.0;
    }
    if (vars.containsKey('isMale')) {
      final isM = vars['isMale'] == true || vars['isMale'] == 'true';
      vars['genderLabel'] = isM ? 'Male' : 'Female';
      vars['baseWt'] = isM ? 50 : 45.5;
    }
    if (resultValues.containsKey('ci') && (resultValues['ci'] as num?) != null) {
      final ci = resultValues['ci'] as num;
      vars['ciLine'] = ci > 0
          ? 'Cardiac Index: ${_format(ci, 2)} L/min/m²'
          : '';
    } else {
      vars['ciLine'] = '';
    }
    if (resultValues.containsKey('single_dose') && resultValues.containsKey('single_dose_capped')) {
      final sd = resultValues['single_dose'] as num;
      final cap = resultValues['single_dose_capped'] as num;
      if (cap < sd) {
        vars['capLine'] = 'Capped at max single dose: ${_format(cap, 1)} mg';
      } else {
        vars['capLine'] = '';
      }
      vars['singleDoseDisplay'] = _format(sd, 1);
    }
    if (vars.containsKey('weightKg')) {
      final w = double.tryParse(vars['weightKg'].toString()) ?? 0;
      if (w <= 10) {
        vars['tier1'] = '${w} × 4 = ${(w * 4).toStringAsFixed(1)}';
        vars['tier2'] = '—';
        vars['tier3'] = '—';
      } else if (w <= 20) {
        vars['tier1'] = '10 × 4 = 40';
        vars['tier2'] = '40 + (${w - 10}) × 2 = ${(40 + (w - 10) * 2).toStringAsFixed(1)}';
        vars['tier3'] = '—';
      } else {
        vars['tier1'] = '10 × 4 = 40';
        vars['tier2'] = '40 + 10 × 2 = 60';
        vars['tier3'] = '60 + (${w - 20}) × 1 = ${(60 + (w - 20) * 1).toStringAsFixed(1)}';
      }
    }

    return vars;
  }

  String get _calculationSummary {
    final primary = calculator.primaryResult;
    final val = _format(resultValues[primary.key], primary.decimals);
    final match = _findInterpretation();
    final label = match?.label ?? '';
    return '${calculator.name}: $val ${primary.unit} ($label)';
  }

  @override
  Widget build(BuildContext context) {
    final primary = calculator.primaryResult;
    final primaryVal = resultValues[primary.key];
    final valueStr = _format(primaryVal, primary.decimals);
    final match = _findInterpretation();
    final ruleLabel = match?.label ?? '';
    final detail = match?.detail;
    final primaryResultLabel = match?.label ?? 'Result';
    final isWarning = match?.severity == 'warning' || match?.severity == 'high';

    final transparencyVars = _buildTransparencyVars();
    final transparencyFilled = calculator.transparencyTemplate.isNotEmpty
        ? CalculatorLoader.fillTemplate(calculator.transparencyTemplate, transparencyVars)
        : '';

    final otherResults = calculator.results
        .where((r) => !r.isPrimary)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(calculator.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ResultDisplay(
                resultValue: valueStr,
                resultUnit: primary.unit,
                resultLabel: primaryResultLabel,
                interpretation: detail,
                isWarning: isWarning,
              ),
              if (otherResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...otherResults.map((r) {
                  final val = resultValues[r.key];
                  final str = _format(val, r.decimals);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppConstants.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppConstants.primaryColor.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600, color: AppConstants.textColor,
                          )),
                          Text('$str ${r.unit}', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: AppConstants.primaryColor,
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 16),
              if (transparencyFilled.isNotEmpty)
                FormulaDisplay(
                  formula: transparencyFilled,
                  formulaName: 'Formula Transparency',
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SaveToPatientScreen(
                        calculationSummary: _calculationSummary,
                        calculatorId: calculator.id,
                        category: calculator.category,
                        inputValues: inputValues,
                        resultValue: valueStr,
                        resultUnit: primary.unit,
                        resultLabel: ruleLabel,
                        transparency: transparencyFilled,
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
                        calculatorId: calculator.id,
                        category: calculator.category,
                        inputValues: inputValues,
                        resultValue: valueStr,
                        resultUnit: primary.unit,
                        resultLabel: ruleLabel,
                        transparency: transparencyFilled,
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
                      text: '$valueStr ${primary.unit} - $ruleLabel',
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
