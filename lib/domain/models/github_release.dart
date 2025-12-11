import 'package:data7_expedicao/domain/models/app_version.dart';
import 'package:data7_expedicao/domain/models/release_asset.dart';

class GitHubRelease {
  final String tagName;
  final String name;
  final String? body;
  final DateTime publishedAt;
  final List<ReleaseAsset> assets;

  const GitHubRelease({
    required this.tagName,
    required this.name,
    this.body,
    required this.publishedAt,
    required this.assets,
  });

  ReleaseAsset? getApkAsset() {
    try {
      return assets.firstWhere((asset) => asset.isApk);
    } catch (e) {
      return null;
    }
  }

  AppVersion? getVersion() {
    try {
      final cleanTag = tagName.replaceFirst(RegExp(r'^v'), '');
      final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(cleanTag);
      if (versionMatch == null) return null;

      final version = versionMatch.group(1)!;
      final buildMatch = RegExp(r'\+(\d+)').firstMatch(cleanTag);
      final buildNumber = buildMatch != null ? int.tryParse(buildMatch.group(1)!) ?? 0 : 0;

      return AppVersion(version: version, buildNumber: buildNumber, releaseDate: publishedAt);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GitHubRelease && other.tagName == tagName;
  }

  @override
  int get hashCode => tagName.hashCode;

  @override
  String toString() => 'GitHubRelease(tagName: $tagName, name: $name)';
}
