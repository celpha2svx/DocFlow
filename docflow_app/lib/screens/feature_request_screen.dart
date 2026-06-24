import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/services/cloud_sync_service.dart';
import 'package:docflow_app/utils/constants.dart';

class FeatureRequestScreen extends StatefulWidget {
  const FeatureRequestScreen({super.key});

  @override
  State<FeatureRequestScreen> createState() => _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends State<FeatureRequestScreen> with SingleTickerProviderStateMixin {
  final _requestFormKey = GlobalKey<FormState>();
  final _feedbackFormKey = GlobalKey<FormState>();
  final _calculatorNameController = TextEditingController();
  final _useCaseController = TextEditingController();
  final _feedbackMessageController = TextEditingController();
  final _relatedCalculatorController = TextEditingController();
  final _feedbackContactController = TextEditingController();

  late final TabController _tabController;
  final List<String> _specialties = const [
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
  String _priority = 'normal';
  String _feedbackType = 'Suggestion';
  String _selectedSpecialty = 'General Practice';
  bool _contactMe = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _calculatorNameController.dispose();
    _useCaseController.dispose();
    _feedbackMessageController.dispose();
    _relatedCalculatorController.dispose();
    _feedbackContactController.dispose();
    super.dispose();
  }

  Future<void> _submitCalculatorRequest() async {
    if (!_requestFormKey.currentState!.validate()) return;

    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return;

    setState(() => _submitting = true);
    final name = _calculatorNameController.text.trim();
    final useCase = _useCaseController.text.trim();
    try {
      await appState.databaseService.savePendingSubmission(
        id: const Uuid().v4(),
        type: 'feature_request',
        payload: {
          'type': 'calculator_request',
          'name': name,
          'use_case': useCase,
          'specialty': _selectedSpecialty,
          'priority': _priority,
          'doctor_phone': sha256.convert(utf8.encode(doctor.phoneNumber)).toString(),
          'status': 'pending',
          'votes': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Best-effort cloud submission
      appState.cloudSyncService.submitCalculatorRequest(
        name: name,
        useCase: useCase,
        specialty: _selectedSpecialty,
        priority: _priority,
        doctorPhone: doctor.phoneNumber,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted. Thank you.')),
      );
      _calculatorNameController.clear();
      _useCaseController.clear();
      setState(() => _priority = 'normal');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submitFeedback() async {
    if (!_feedbackFormKey.currentState!.validate()) return;

    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return;

    setState(() => _submitting = true);
    final message = _feedbackMessageController.text.trim();
    final relatedCalc = _relatedCalculatorController.text.trim();
    final contactPhone = _contactMe ? _feedbackContactController.text.trim() : null;
    try {
      await appState.databaseService.savePendingSubmission(
        id: const Uuid().v4(),
        type: 'feedback',
        payload: {
          'type': _feedbackType,
          'calculator_id': relatedCalc.isEmpty ? null : relatedCalc,
          'message': message,
          'contact': _contactMe,
          'doctor_phone': _contactMe
              ? sha256.convert(utf8.encode(contactPhone!)).toString()
              : null,
          'specialty': doctor.specialty ?? 'General Practice',
          'app_version': '1.0.0',
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Best-effort cloud submission
      appState.cloudSyncService.submitFeedback(
        feedbackType: _feedbackType,
        message: message,
        relatedCalculator: relatedCalc.isEmpty ? null : relatedCalc,
        contactPhone: contactPhone,
        doctorPhone: doctor.phoneNumber,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback received. Thank you.')),
      );
      _feedbackMessageController.clear();
      _relatedCalculatorController.clear();
      _feedbackContactController.clear();
      setState(() => _contactMe = false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = AppStateProvider.maybeOf(context)?.currentDoctor;
    final effectiveSpecialty = _selectedSpecialty == 'General Practice' && doctor?.specialty != null
        ? doctor!.specialty!
        : _selectedSpecialty;
    final doctorPhone = doctor?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request & Feedback'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'New Calculator'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _RequestTab(
              formKey: _requestFormKey,
              descriptionController: _calculatorNameController,
              useCaseController: _useCaseController,
              priority: _priority,
              selectedSpecialty: effectiveSpecialty,
              specialtyOptions: _specialties,
              onPriorityChanged: (value) => setState(() => _priority = value),
              onSpecialtyChanged: (value) => setState(() => _selectedSpecialty = value),
              onSubmit: _submitCalculatorRequest,
              isSubmitting: _submitting,
            ),
            _FeedbackTab(
              formKey: _feedbackFormKey,
              feedbackType: _feedbackType,
              onFeedbackTypeChanged: (value) => setState(() => _feedbackType = value),
              relatedCalculatorController: _relatedCalculatorController,
              messageController: _feedbackMessageController,
              contactController: _feedbackContactController,
              contactMe: _contactMe,
              onContactChanged: (value) {
                setState(() => _contactMe = value);
                if (value && _feedbackContactController.text.isEmpty && doctorPhone.isNotEmpty) {
                  _feedbackContactController.text = doctorPhone;
                }
                if (!value) {
                  _feedbackContactController.clear();
                }
              },
              onSubmit: _submitFeedback,
              isSubmitting: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController descriptionController;
  final TextEditingController useCaseController;
  final String priority;
  final String selectedSpecialty;
  final List<String> specialtyOptions;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onSpecialtyChanged;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  const _RequestTab({
    required this.formKey,
    required this.descriptionController,
    required this.useCaseController,
    required this.priority,
    required this.selectedSpecialty,
    required this.specialtyOptions,
    required this.onPriorityChanged,
    required this.onSpecialtyChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Request a new calculator',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppConstants.textColor,
              ),
        ),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Calculator name / description',
                  hintText: 'e.g. Corrected Calcium, Osmolality, MEWS Score',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Describe the calculator you need';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: useCaseController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Clinical use case',
                  hintText: 'When do you use this?',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Add a short clinical use case';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedSpecialty,
                items: specialtyOptions
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                decoration: const InputDecoration(labelText: 'Specialty'),
                onChanged: (value) {
                  if (value != null) onSpecialtyChanged(value);
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'normal', label: Text('Nice to have')),
                  ButtonSegment(value: 'urgent', label: Text('Urgent')),
                ],
                selected: {priority},
                onSelectionChanged: (value) => onPriorityChanged(value.first),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                child: Text(isSubmitting ? 'Submitting...' : 'Submit Request'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackTab extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String feedbackType;
  final ValueChanged<String> onFeedbackTypeChanged;
  final TextEditingController relatedCalculatorController;
  final TextEditingController messageController;
  final TextEditingController contactController;
  final bool contactMe;
  final ValueChanged<bool> onContactChanged;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  const _FeedbackTab({
    required this.formKey,
    required this.feedbackType,
    required this.onFeedbackTypeChanged,
    required this.relatedCalculatorController,
    required this.messageController,
    required this.contactController,
    required this.contactMe,
    required this.onContactChanged,
    required this.onSubmit,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'Send feedback',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppConstants.textColor,
              ),
        ),
        const SizedBox(height: 16),
        Form(
          key: formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: feedbackType,
                items: const [
                  DropdownMenuItem(value: 'Bug / Wrong result', child: Text('Bug / Wrong result')),
                  DropdownMenuItem(value: 'Suggestion', child: Text('Suggestion')),
                  DropdownMenuItem(value: 'Formula question', child: Text('Formula question')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                decoration: const InputDecoration(labelText: 'Type'),
                onChanged: (value) {
                  if (value != null) onFeedbackTypeChanged(value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: relatedCalculatorController,
                decoration: const InputDecoration(
                  labelText: 'Related calculator (optional)',
                  hintText: 'Calculator ID or name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Describe your feedback clearly...',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 20) {
                    return 'Please add at least 20 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: contactMe,
                onChanged: onContactChanged,
                title: const Text('Contact me back'),
                subtitle: const Text('Add your phone number for follow-up'),
              ),
              if (contactMe) ...[
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                  validator: (value) {
                    if (!contactMe) return null;
                    if (value == null || value.trim().length < 10) {
                      return 'Enter a contact phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                child: Text(isSubmitting ? 'Sending...' : 'Send Feedback'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
