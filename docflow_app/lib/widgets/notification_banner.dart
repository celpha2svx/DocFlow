import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:docflow_app/services/notification_service.dart';
import 'package:docflow_app/utils/constants.dart';

class NotificationBanner extends StatefulWidget {
  final List<AppNotification> notifications;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    super.key,
    required this.notifications,
    this.onDismiss,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  int _currentIndex = 0;

  List<AppNotification> get _notifs => widget.notifications;
  bool get _hasMore => _currentIndex < _notifs.length - 1;

  AppNotification? get _current =>
      _currentIndex < _notifs.length ? _notifs[_currentIndex] : null;

  Future<void> _handleAction(AppNotification notif) async {
    if (notif.actionUrl != null) {
      final uri = Uri.tryParse(notif.actionUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _dismiss() async {
    final notif = _current;
    if (notif != null) {
      await NotificationService.markAsSeen(notif.id);
    }
    if (_hasMore) {
      setState(() => _currentIndex++);
    } else {
      widget.onDismiss?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final notif = _current;
    if (notif == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.secondaryColor, AppConstants.primaryColor],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notif.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _dismiss,
                  child: const Icon(Icons.close, color: Colors.white70, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              notif.body,
              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
            ),
            if (notif.actionUrl != null || notif.actionLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _handleAction(notif),
                    icon: const Icon(Icons.open_in_new, size: 16, color: Colors.white),
                    label: Text(
                      notif.actionLabel ?? 'Learn More',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
