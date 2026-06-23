import 'package:flutter/material.dart';
import 'package:docflow_app/widgets/result_display.dart';
import 'package:docflow_app/utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final String resultValue;
  final String resultUnit;
  final String resultLabel;
  final String interpretation;

  const ResultScreen({
    super.key,
    required this.resultValue,
    required this.resultUnit,
    required this.resultLabel,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: ResultDisplay(
            resultValue: resultValue,
            resultUnit: resultUnit,
            resultLabel: resultLabel,
            interpretation: interpretation,
          ),
        ),
      ),
    );
  }
}
