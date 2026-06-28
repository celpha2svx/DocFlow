import 'package:flutter/material.dart';
import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/services/calculator_loader.dart';
import 'package:docflow_app/services/notification_service.dart';
import 'package:docflow_app/services/update_service.dart';
import 'package:docflow_app/utils/constants.dart';
import 'package:docflow_app/widgets/category_card.dart';
import 'package:docflow_app/widgets/notification_banner.dart';
import 'package:docflow_app/screens/category_screen.dart';
import 'package:docflow_app/screens/feature_request_screen.dart';
import 'package:docflow_app/screens/patient_list_screen.dart';
import 'package:docflow_app/screens/search_screen.dart';
import 'package:docflow_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<AppNotification> _unseenNotifs = [];
  bool _notifsLoaded = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
    _loadNotifications();
  }

  Future<void> _checkForUpdates() async {
    try {
      final available = await UpdateService.isUpdateAvailable();
      if (!mounted || !available) return;
      final ignored = await UpdateService.getIgnoredVersion();
      final release = await UpdateService.fetchLatestRelease();
      final latestTag = (release?['tag_name'] as String? ?? '').replaceAll(RegExp(r'^v'), '');
      if (ignored == latestTag) return;

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Update Available'),
          content: Text('DocFlow $latestTag is now available. Would you like to download and install?'),
          actions: [
            TextButton(
              onPressed: () {
                UpdateService.ignoreVersion(latestTag);
                Navigator.of(ctx).pop();
              },
              child: const Text('Skip This Version'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Later'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _downloadAndInstall();
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    } catch (_) {}
  }

  Future<void> _downloadAndInstall() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading update...')),
    );
    final filePath = await UpdateService.downloadApk();
    if (filePath == null || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download failed. Try again later.')),
      );
      return;
    }
    final installed = await UpdateService.installApk(filePath);
    if (!mounted) return;
    if (installed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Installing update...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not install automatically. Open the file manually.')),
      );
    }
  }

  Future<void> _loadNotifications() async {
    final notifs = await NotificationService.getUnseenNotifications();
    if (mounted) {
      setState(() {
        _unseenNotifs = notifs;
        _notifsLoaded = true;
      });
    }
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.maybeOf(context);
    final doctor = appState?.currentDoctor;
    final doctorName = doctor == null ? 'Clinician' : doctor.fullName.trim();
    final doctorFirstName = doctorName.split(RegExp(r'\s+')).firstOrNull ?? 'Clinician';
    final categoryList = CalculatorLoader.instance.categoryList;
    final totalCalculators = categoryList.fold<int>(0, (sum, cat) => sum + cat.calculators.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DocFlow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _loadNotifications,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                readOnly: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Search calculations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppConstants.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppConstants.primaryColor.withOpacity(0.12)),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '${_greetingFor(DateTime.now())}, $doctorFirstName',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Access $totalCalculators evidence-based medical calculators across all specialties.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                      height: 1.4,
                    ),
              ),
              if (_unseenNotifs.isNotEmpty) ...[
                const SizedBox(height: 14),
                NotificationBanner(
                  notifications: _unseenNotifs,
                  onDismiss: () => setState(() => _unseenNotifs = []),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.flash_on_outlined,
                      title: 'Quick Calculate',
                      value: '$totalCalculators calculators',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SearchScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FutureBuilder<int>(
                      future: doctor == null
                          ? Future.value(0)
                          : appState!.databaseService.getPatientCount(doctor.phoneNumber),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        return _QuickActionCard(
                          icon: Icons.person_outline,
                          title: 'Patient Records',
                          value: '$count saved',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const PatientListScreen()),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
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
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoryList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  return CategoryCard(
                    category: category,
                    calculatorCount: category.calculators.length,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(category: category),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 18),
              Card(
                elevation: 1,
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Request a Feature'),
                  subtitle: const Text('Suggest a calculator or workflow improvement'),
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
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 1:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PatientListScreen()),
              );
              break;
            case 2:
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppConstants.primaryColor),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.subtextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
