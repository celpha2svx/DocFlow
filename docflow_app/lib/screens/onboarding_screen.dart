import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/screens/home_screen.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/utils/validators.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  final List<String> _specialties = const [
    'Medical Student',
    'Nurse / Midwife',
    'General Practice',
    'Internal Medicine',
    'Paediatrics',
    'Surgery',
    'Obstetrics & Gynaecology',
    'Emergency Medicine',
    'Cardiology',
    'Nephrology',
    'Other',
  ];

  String _selectedSpecialty = 'Medical Student';
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pinController.text.trim() != _confirmPinController.text.trim()) {
      setState(() {
        _error = 'PINs do not match.';
      });
      return;
    }

    final appState = AppStateProvider.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });

    final success = await appState.registerDoctor(
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      specialty: _selectedSpecialty,
      pin: _pinController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _submitting = false;
    });

    if (!success) {
      setState(() {
        _error = appState.authError ?? 'Unable to complete onboarding.';
      });
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Get Started')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Set up your DocFlow profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Access 50+ evidence-based medical calculators across 12 specialties. Each result shows its formula — so you can verify before you apply.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppConstants.subtextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                  TextFormField(
                    controller: _fullNameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name',
                      hintText: 'e.g. Dr. Okafor, Nurse Amadi, etc.',
                    ),
                  validator: (value) {
                    if (!isValidName(value ?? '')) {
                      return 'Enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixText: '+234 ',
                  ),
                  validator: (value) {
                    if (!isValidPhoneNumber(value ?? '')) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  items: _specialties
                      .map(
                        (specialty) => DropdownMenuItem<String>(
                          value: specialty,
                          child: Text(specialty),
                        ),
                      )
                      .toList(),
                  decoration: const InputDecoration(labelText: 'Specialty'),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedSpecialty = value);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'Create 4-digit PIN'),
                  validator: (value) {
                    if (!isValidPin(value ?? '')) {
                      return 'Enter exactly 4 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  validator: (value) {
                    if (!isValidPin(value ?? '')) {
                      return 'Confirm the 4-digit PIN';
                    }
                    if (value?.trim() != _pinController.text.trim()) {
                      return 'PINs must match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstants.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.lock_open_outlined),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _submitting ? null : _submit,
                    label: Text(_submitting ? 'Setting up...' : 'Get Started'),
                  ),
                ),
                const SizedBox(height: 16),
                  Text(
                    'DocFlow is a calculation aid. Clinical interpretation remains the responsibility of the attending clinician or supervising practitioner.',
                    style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstants.subtextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
