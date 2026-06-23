import 'dart:async';

import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/screens/home_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _pin = '';
  String? _error;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _appendDigit(String digit) {
    final appState = AppStateProvider.maybeOf(context);
    if (appState?.isLockedOut ?? false) return;
    if (_pin.length >= 4) return;

    setState(() {
      _pin += digit;
      _error = null;
    });

    if (_pin.length == 4) {
      _tryLogin();
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _tryLogin() async {
    final appState = AppStateProvider.of(context);
    final success = await appState.login(_pin);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
      return;
    }

    setState(() {
      _error = appState.authError ?? 'Incorrect PIN';
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.maybeOf(context);
    final locked = appState?.isLockedOut ?? false;
    final remaining = appState?.lockoutRemainingSeconds ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock DocFlow')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your 4-digit PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'DocFlow keeps your clinical notes protected on this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final filled = index < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? AppConstants.primaryColor : AppConstants.surfaceColor,
                      border: Border.all(color: AppConstants.primaryColor, width: 1.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              if (_error != null) ...[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              if (locked) ...[
                Text(
                  'Too many attempts. Try again in $remaining seconds.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              _buildKeypad(context, locked),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Forgot PIN'),
                      content: const Text(
                        'PIN recovery can be added through the settings flow. Your patient data remains preserved.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Forgot PIN?'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(BuildContext context, bool locked) {
    final buttons = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'clear',
      '0',
      'back',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (context, index) {
        final label = buttons[index];
        final isAction = label == 'back' || label == 'clear';

        return ElevatedButton(
          onPressed: locked
              ? null
              : () {
                  if (label == 'back') {
                    _backspace();
                  } else if (label == 'clear') {
                    setState(() {
                      _pin = '';
                      _error = null;
                    });
                  } else {
                    _appendDigit(label);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: isAction ? AppConstants.backgroundColor : AppConstants.surfaceColor,
            foregroundColor: AppConstants.textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: label == 'back'
              ? const Icon(Icons.backspace_outlined)
              : label == 'clear'
                  ? const Icon(Icons.delete_outline)
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
        );
      },
    );
  }
}
