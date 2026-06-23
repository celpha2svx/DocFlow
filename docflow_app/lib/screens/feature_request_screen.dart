import 'package:flutter/material.dart';
import 'package:docflow_app/utils/constants.dart';

class FeatureRequestScreen extends StatefulWidget {
  const FeatureRequestScreen({super.key});

  @override
  State<FeatureRequestScreen> createState() => _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends State<FeatureRequestScreen> {
  final TextEditingController _requestController = TextEditingController();
  bool _submitted = false;

  void _submitRequest() {
    if (_requestController.text.trim().isEmpty) return;

    setState(() {
      _submitted = true;
    });
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Feature Request')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Help us improve DocFlow by requesting new calculators or workflow enhancements.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _requestController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe the feature or clinical calculator you need',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitRequest,
                child: const Text('Submit request'),
              ),
              if (_submitted) ...[
                const SizedBox(height: 18),
                Text(
                  'Thank you. Your request has been recorded and will help shape future DocFlow features.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.successColor,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
