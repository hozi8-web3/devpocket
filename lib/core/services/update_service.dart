import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class UpdateService {
  static const String _repoReleasesUrl =
      'https://api.github.com/repos/hozi8-web3/devpocket/releases/latest';

  static Future<UpdateInfo?> checkForUpdates() async {
    try {
      final dio = Dio();
      final response = await dio.get(_repoReleasesUrl);

      if (response.statusCode == 200) {
        final data = response.data;
        final latestTag = data['tag_name'] as String;
        final releaseNotes = data['body'] as String?;
        final assets = data['assets'] as List;

        String? downloadUrl;
        if (assets.isNotEmpty) {
          // Find the APK asset
          for (var asset in assets) {
            if (asset['name'].toString().endsWith('.apk')) {
              downloadUrl = asset['browser_download_url'];
              break;
            }
          }
        }

        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;

        // Strip 'v' prefix for comparison if present
        final cleanLatest =
            latestTag.startsWith('v') ? latestTag.substring(1) : latestTag;
        final cleanCurrent = currentVersion.startsWith('v')
            ? currentVersion.substring(1)
            : currentVersion;

        if (_isNewerVersion(cleanLatest, cleanCurrent)) {
          return UpdateInfo(
            version: latestTag,
            releaseNotes: releaseNotes ?? 'No release notes provided.',
            downloadUrl: downloadUrl,
          );
        }
      }
    } catch (e) {
      // Silently fail on network/parsing errors so we don't disrupt the user experience
      debugPrint('Update check failed: $e');
    }
    return null;
  }

  static bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      for (var i = 0; i < 3; i++) {
        final l = i < latestParts.length ? latestParts[i] : 0;
        final c = i < currentParts.length ? currentParts[i] : 0;
        if (l > c) return true;
        if (l < c) return false;
      }
    } catch (_) {}
    return false;
  }
}

class UpdateInfo {
  final String version;
  final String releaseNotes;
  final String? downloadUrl;

  UpdateInfo({
    required this.version,
    required this.releaseNotes,
    this.downloadUrl,
  });
}
