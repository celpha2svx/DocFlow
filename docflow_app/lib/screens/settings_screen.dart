import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/screens/feature_request_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _syncing = false;
  String? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getString('last_sync_time');
    if (mounted) {
      setState(() => _lastSyncTime = lastSync);
    }
  }

  Future<void> _saveLastSyncTime() async {
    final now = DateTime.now().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync_time', now);
    if (mounted) {
      setState(() => _lastSyncTime = now);
    }
  }

  Future<void> _syncToCloud() async {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return;

    setState(() => _syncing = true);
    try {
      await appState.cloudSyncService.syncToCloud(doctor.phoneNumber);
      await _saveLastSyncTime();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud sync completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _restoreFromCloud() async {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    if (appState == null || doctor == null) return;

    setState(() => _syncing = true);
    try {
      await appState.cloudSyncService.restoreFromCloud(doctor.phoneNumber);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloud restore completed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  String _formatSyncTime(String? iso) {
    if (iso == null) return 'Never';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

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
                    leading: _syncing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    title: const Text('Backup to Cloud'),
                    subtitle: Text('Last sync: ${_formatSyncTime(_lastSyncTime)}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _syncing ? null : _syncToCloud,
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.cloud_download_outlined),
                    title: const Text('Restore from Cloud'),
                    subtitle: const Text('Recover records on a new phone'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _syncing ? null : _restoreFromCloud,
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