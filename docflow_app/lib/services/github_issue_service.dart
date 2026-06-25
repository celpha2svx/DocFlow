import 'dart:convert';
import 'package:http/http.dart' as http;

import 'github_config.dart';

class GitHubIssueService {
  static const String _apiBase = 'https://api.github.com';

  static bool get isConfigured => GitHubConfig.token.isNotEmpty;

  /// Submit a feature request as a GitHub Issue
  static Future<bool> submitFeatureRequest({
    required String title,
    required String body,
    required String label,
  }) async {
    if (!isConfigured) return false;
    try {
      final response = await http.post(
        Uri.parse('$_apiBase/repos/${GitHubConfig.repoOwner}/${GitHubConfig.repoName}/issues'),
        headers: {
          'Authorization': 'Bearer ${GitHubConfig.token}',
          'Accept': 'application/vnd.github+json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
          'labels': [label],
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
