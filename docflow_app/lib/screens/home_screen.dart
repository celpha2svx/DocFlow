import 'package:flutter/material.dart';
import 'package:docflow_app/models/patient.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/widgets/category_card.dart';
import 'package:docflow_app/widgets/patient_card.dart';
import 'package:docflow_app/screens/calculator_category_screen.dart';
import 'package:docflow_app/screens/search_screen.dart';
import 'package:docflow_app/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final _featuredPatient = Patient(
    id: 'patient-001',
    doctorPhone: '+1234567890',
    fullName: 'Aisha Mbaye',
    hospitalNumber: 'HPL-5592',
    age: 7,
    sex: 'Female',
    weightKg: 24.5,
    diagnosis: 'Acute asthma exacerbation',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DocFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical calculators with trusted transparency',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Use patient-specific calculations and review the formula steps before applying clinical decisions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Recent patient',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 12),
              PatientCard(
                patient: _featuredPatient,
                recentCalculation: 'QTc and MAP for treatment decisions',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient detail view coming soon.')),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Categories',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    calculatorCount: category.calculators.length,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CalculatorCategoryScreen(category: category),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
