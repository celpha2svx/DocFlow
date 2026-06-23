import 'package:flutter/material.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/screens/feature_request_screen.dart';
import 'package:docflow_app/services/cloud_sync_service.dart';
import 'package:docflow_app/utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    final doctorPhone = doctor?.phoneNumber;
    final specialty = doctor?.specialty;
    final profileDetails = <String>[
      if (doctorPhone != null && doctorPhone.isNotEmpty) doctorPhone,
      if (specialty != null && specialty.isNotEmpty) specialty,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _SectionTitle(title: 'Profile'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(doctor?.fullName ?? 'Doctor profile'),
                  subtitle: Text(profileDetails.join(' • ')),
                ),
              ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Security'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Change PIN'),
                    subtitle: const Text('Update the 4-digit unlock PIN'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN change flow can be added here.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Data'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.cloud_upload_outlined),
                    title: const Text('Backup to Cloud'),
                    subtitle: const Text('Sync patient records to Firestore'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final doctor = appState?.currentDoctor;
                      if (doctor == null || appState == null) return;
                      final sync = CloudSyncService(databaseService: appState.databaseService);
                      await sync.syncToCloud(doctor.phoneNumber);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Backup attempted. Firebase will work once configured.')),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_outlined),
                    title: const Text('Restore from Cloud'),
                    subtitle: const Text('Recover records on a new phone'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final doctor = appState?.currentDoctor;
                      if (doctor == null || appState == null) return;
                      final sync = CloudSyncService(databaseService: appState.databaseService);
                      await sync.restoreFromCloud(doctor.phoneNumber);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restore attempted. Firebase will work once configured.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'About'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('DocFlow'),
                subtitle: const Text('Version 1.0.0'),
              ),
            ),
            const SizedBox(height: 18),
            _SectionTitle(title: 'Feedback'),
            Card(
              child: ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: const Text('Request a feature'),
                subtitle: const Text('Suggest calculators or workflow improvements'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FeatureRequestScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppConstants.textColor,
            ),
      ),
    );
  }
}
