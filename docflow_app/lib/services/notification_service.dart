import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final int id;
  final String title;
  final String body;
  final String? actionUrl;
  final String? actionLabel;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.actionUrl,
    this.actionLabel,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      actionUrl: json['action_url'] as String?,
      actionLabel: json['action_label'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

class NotificationService {
  static const String _notificationsUrl =
      'https://raw.githubusercontent.com/celpha2svx/DocFlow/main/docs/notifications.json';
  static const String _lastSeenKey = 'last_seen_notification_id';

  static Future<List<AppNotification>> fetchNotifications() async {
    try {
      final response = await http
          .get(Uri.parse(_notificationsUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = (data['notifications'] as List)
            .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
    } catch (_) {}
    return [];
  }

  static Future<List<AppNotification>> getUnseenNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenId = prefs.getInt(_lastSeenKey) ?? 0;
    final all = await fetchNotifications();
    return all.where((n) => n.id > lastSeenId).toList();
  }

  static Future<void> markAsSeen(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_lastSeenKey) ?? 0;
    if (id > current) {
      await prefs.setInt(_lastSeenKey, id);
    }
  }

  static Future<void> markAllAsSeen() async {
    final all = await fetchNotifications();
    if (all.isEmpty) return;
    final maxId = all.map((n) => n.id).reduce((a, b) => a > b ? a : b);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSeenKey, maxId);
  }
}
