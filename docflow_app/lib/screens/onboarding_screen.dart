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
  final _loginPhoneController = TextEditingController();
  final _loginPinController = TextEditingController();

  final List<String> _titles = const [
    'Dr.',
    'Nurse',
    'Prof.',
    'Mr.',
    'Mrs.',
    'Ms.',
  ];

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

  String _selectedTitle = 'Dr.';
  String _selectedSpecialty = 'Medical Student';
  bool _submitting = false;
  String? _error;
  bool _isLoginMode = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _loginPhoneController.dispose();
    _loginPinController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pinController.text.trim() != _confirmPinController.text.trim()) {
      setState(() => _error = 'PINs do not match.');
      return;
    }
    final appState = AppStateProvider.of(context);
    setState(() { _submitting = true; _error = null; });
    final success = await appState.registerDoctor(
      fullName: '$_selectedTitle ${_fullNameController.text.trim()}',
      phoneNumber: _phoneController.text.trim(),
      specialty: _selectedSpecialty,
      pin: _pinController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!success) {
      setState(() => _error = appState.authError ?? 'Unable to complete onboarding.');
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = AppStateProvider.of(context);
    setState(() { _submitting = true; _error = null; });
    final success = await appState.loginExistingUser(
      _loginPhoneController.text.trim(),
      _loginPinController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!success) {
      setState(() => _error = appState.authError);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_isLoginMode ? 'Welcome Back' : 'Get Started')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mode toggle
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: 'New User',
                        selected: !_isLoginMode,
                        onTap: _isLoginMode ? _toggleMode : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModeButton(
                        label: 'Returning User',
                        selected: _isLoginMode,
                        onTap: !_isLoginMode ? _toggleMode : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoginMode) _buildLoginForm() else _buildRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    final theme = Theme.of(context);
    return Column(
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
          'Access 50+ evidence-based medical calculators across 12 specialties.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstants.subtextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _selectedTitle,
          items: _titles
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) {
            if (v != null) setState(() => _selectedTitle = v);
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _fullNameController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Full name',
            hintText: 'e.g. Okafor, Amadi, Adebayo',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isValidName(value ?? '')) return 'Enter your full name';
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
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isValidPhoneNumber(value ?? '')) return 'Enter a valid phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedSpecialty,
          items: _specialties
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Specialty / Role',
            border: OutlineInputBorder(),
          ),
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
          decoration: const InputDecoration(
            labelText: 'Create 4-digit PIN',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isValidPin(value ?? '')) return 'Enter exactly 4 digits';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'Confirm PIN',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (!isValidPin(value ?? '')) return 'Confirm the 4-digit PIN';
            if (value?.trim() != _pinController.text.trim()) return 'PINs must match';
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
                    height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.lock_open_outlined),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _submitting ? null : _submitRegister,
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
    );
  }

  Widget _buildLoginForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome back',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your phone number and PIN to continue where you left off.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstants.subtextColor,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _loginPhoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            prefixText: '+234 ',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (!isValidPhoneNumber(v ?? '')) return 'Enter your registered phone number';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _loginPinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'PIN',
            border: OutlineInputBorder(),
          ),
          validator: (v) {
            if (!isValidPin(v ?? '')) return 'Enter your 4-digit PIN';
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
                    height: 16, width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.lock_open_outlined),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _submitting ? null : _submitLogin,
            label: Text(_submitting ? 'Signing in...' : 'Login'),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _ModeButton({
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppConstants.primaryColor : AppConstants.subtextColor.withOpacity(0.3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppConstants.subtextColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
