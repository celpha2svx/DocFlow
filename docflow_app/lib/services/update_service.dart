import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static const String _githubApiUrl =
      'https://api.github.com/repos/celpha2svx/DocFlow/releases/latest';
  static const String _downloadBaseUrl =
      'https://github.com/celpha2svx/DocFlow/releases/latest/download';
  static const String _channel = 'com.example.docflow_app/installer';

  static const _ignoreVersionKey = 'ignored_update_version';

  static Future<String?> getCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchLatestRelease() async {
    try {
      final response = await http
          .get(Uri.parse(_githubApiUrl), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> isUpdateAvailable() async {
    try {
      final release = await fetchLatestRelease();
      if (release == null) return false;
      final latestTag = release['tag_name'] as String? ?? '';
      final current = await getCurrentVersion();
      if (current == null || latestTag.isEmpty) return false;
      return _compareVersions(latestTag.replaceAll(RegExp(r'^v'), ''), current) > 0;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> downloadApk() async {
    final url = '$_downloadBaseUrl/app-release.apk';
    final dir = await getApplicationCacheDirectory();
    final file = File('${dir.path}/docflow_update.apk');

    try {
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request).timeout(const Duration(seconds: 120));
        if (response.statusCode == 200) {
          final sink = file.openWrite();
          await response.stream.pipe(sink);
          await sink.flush();
          await sink.close();
          return file.path;
        }
      } finally {
        client.close();
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> installApk(String filePath) async {
    try {
      await MethodChannel(_channel).invokeMethod('installApk', {'filePath': filePath});
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> ignoreVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ignoreVersionKey, version);
  }

  static Future<String?> getIgnoredVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ignoreVersionKey);
  }

  static int _compareVersions(String a, String b) {
    final partsA = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final va = i < partsA.length ? partsA[i] : 0;
      final vb = i < partsB.length ? partsB[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }
}
