import 'dart:convert';
import 'package:http/http.dart' as http;

/// Sends feature requests and feedback to the DocFlow Cloudflare Worker,
/// which creates GitHub Issues using a server-side PAT.
///
/// Update [_workerUrl] with your deployed worker URL.
class IssueReporter {
  IssueReporter._();

  static const String _workerUrl = 'https://docflow-issues.celpha2svx.workers.dev/submit';

  static Future<bool> submit({
    required String title,
    required String body,
    String? label,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_workerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': body,
          'label': label,
        }),
      );
      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
