import 'package:flutter/material.dart';
import 'package:docflow_app/models/category.dart';
import 'package:docflow_app/utils/constants.dart';

class CalculatorPlaceholderScreen extends StatelessWidget {
  final CalculatorMeta calculator;

  const CalculatorPlaceholderScreen({super.key, required this.calculator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calculator.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              calculator.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Category: ${calculator.category}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.subtextColor,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  'Calculator screens are being built next.\nTap back to return to the category list.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppConstants.textColor,
                        height: 1.6,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
