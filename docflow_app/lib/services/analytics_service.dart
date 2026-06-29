import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for collecting anonymous analytics about calculation usage.
/// IMPORTANT: Never captures patient data, doctor personal information, or input values.
/// Only tracks metadata: calculator type, category, timestamp for quality insights.
class AnalyticsService {
  final FirebaseFirestore? _firestore;

  static const String _analyticsCollection = 'analytics';
  static const String _usageCollection = 'usage';

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore;

  FirebaseFirestore? get _client {
    if (_firestore != null) return _firestore;
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  /// Record a calculation usage event (anonymous, no sensitive data).
  /// Captured: calculator type, category, timestamp only.
  /// NOT captured: patient data, input values, results, doctor info.
  Future<void> logCalculationUsage(
    String calculatorType,
    String category,
  ) async {
    try {
      final firestore = _client;
      if (firestore == null) return;
      await firestore
          .collection(_analyticsCollection)
          .doc('daily_usage')
          .collection(_usageCollection)
          .add({
            'calculatorType': calculatorType,
            'category': category,
            'timestamp': DateTime.now().toIso8601String(),
            'platform': 'mobile',
            'version': '1.2.2',
          });
    } catch (e) {
      // Silent fail for analytics - never disrupt app functionality
      print('Analytics logging failed: $e');
    }
  }

  /// Record an error event for debugging (no sensitive data).
  /// Captured: error type, calculator context, timestamp.
  /// NOT captured: actual error message if it contains sensitive data.
  Future<void> logError(
    String errorType,
    String calculatorType,
  ) async {
    try {
      final firestore = _client;
      if (firestore == null) return;
      await firestore
          .collection(_analyticsCollection)
          .doc('errors')
          .collection('log')
          .add({
            'errorType': errorType,
            'calculatorType': calculatorType,
            'timestamp': DateTime.now().toIso8601String(),
            'platform': 'mobile',
          });
    } catch (e) {
      print('Error logging failed: $e');
    }
  }

  /// Record feature usage request (category or calculator that was searched but not found).
  /// Helps identify missing calculators that doctors need.
  Future<void> logFeatureRequest(String searchTerm) async {
    try {
      final firestore = _client;
      if (firestore == null) return;
      await firestore
          .collection(_analyticsCollection)
          .doc('feature_requests')
          .collection('requests')
          .add({
            'searchTerm': searchTerm,
            'timestamp': DateTime.now().toIso8601String(),
            'platform': 'mobile',
          });
    } catch (e) {
      print('Feature request logging failed: $e');
    }
  }

  /// Get aggregated usage statistics (for dashboard/admin only).
  /// Returns count of calculations per type for the past N days.
  Future<Map<String, int>> getUsageStats(int daysBack) async {
    try {
      final firestore = _client;
      if (firestore == null) return {};
      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysBack)).toIso8601String();

      final snapshot = await firestore
          .collection(_analyticsCollection)
          .doc('daily_usage')
          .collection(_usageCollection)
          .where('timestamp', isGreaterThanOrEqualTo: cutoffDate)
          .get();

      final stats = <String, int>{};
      for (var doc in snapshot.docs) {
        final type = doc['calculatorType'] as String? ?? 'unknown';
        stats[type] = (stats[type] ?? 0) + 1;
      }
      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Get top feature requests (what doctors are looking for).
  /// Returns list of search terms with their frequencies.
  Future<List<Map<String, dynamic>>> getTopFeatureRequests(int limit) async {
    try {
      final firestore = _client;
      if (firestore == null) return [];
      final snapshot = await firestore
          .collection(_analyticsCollection)
          .doc('feature_requests')
          .collection('requests')
          .get();

      final requestCounts = <String, int>{};
      for (var doc in snapshot.docs) {
        final term = doc['searchTerm'] as String? ?? 'unknown';
        requestCounts[term] = (requestCounts[term] ?? 0) + 1;
      }

      // Sort by frequency and return top N
      final sorted = requestCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted
          .take(limit)
          .map((e) => {
                'searchTerm': e.key,
                'count': e.value,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get recent errors for debugging (admin only).
  /// Returns list of error types with timestamps.
  Future<List<Map<String, dynamic>>> getRecentErrors(int limit) async {
    try {
      final firestore = _client;
      if (firestore == null) return [];
      final snapshot = await firestore
          .collection(_analyticsCollection)
          .doc('errors')
          .collection('log')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'errorType': doc['errorType'],
                'calculatorType': doc['calculatorType'],
                'timestamp': doc['timestamp'],
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear old analytics data (data retention policy - keep 90 days).
  Future<void> clearOldData(int daysToKeep) async {
    try {
      final firestore = _client;
      if (firestore == null) return;
      final cutoffDate = DateTime.now()
          .subtract(Duration(days: daysToKeep))
          .toIso8601String();

      final batch = firestore.batch();

      // Clear old usage data
      final usageSnapshot = await firestore
          .collection(_analyticsCollection)
          .doc('daily_usage')
          .collection(_usageCollection)
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      for (var doc in usageSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Clear old error logs
      final errorSnapshot = await firestore
          .collection(_analyticsCollection)
          .doc('errors')
          .collection('log')
          .where('timestamp', isLessThan: cutoffDate)
          .get();

      for (var doc in errorSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Failed to clear old analytics: $e');
    }
  }
}
