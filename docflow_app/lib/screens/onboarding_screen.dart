import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/screens/pin_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to DocFlow')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical decision support with transparency',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'DocFlow helps doctors calculate patient-specific results and review formulas before making treatment decisions. Your data stays local until sync is enabled.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Start with a secure PIN and explore the calculator library.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textColor,
                    ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PinScreen(),
                      ),
                    );
                  },
                  child: const Text('Create PIN & Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
