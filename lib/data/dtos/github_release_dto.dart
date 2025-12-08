import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/models/release_asset.dart';

class ReleaseAssetDto {
  final String name;
  final String browserDownloadUrl;
  final int size;
  final String contentType;

  ReleaseAssetDto({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
    required this.contentType,
  });

  factory ReleaseAssetDto.fromJson(Map<String, dynamic> json) {
    return ReleaseAssetDto(
      name: json['name'] as String,
      browserDownloadUrl: json['browser_download_url'] as String,
      size: json['size'] as int? ?? 0,
      contentType: json['content_type'] as String? ?? 'application/vnd.android.package-archive',
    );
  }

  ReleaseAsset toDomain() {
    return ReleaseAsset(name: name, downloadUrl: browserDownloadUrl, size: size, contentType: contentType);
  }
}

class GitHubReleaseDto {
  final String tagName;
  final String name;
  final String? body;
  final String publishedAt;
  final List<dynamic> assets;

  GitHubReleaseDto({
    required this.tagName,
    required this.name,
    this.body,
    required this.publishedAt,
    required this.assets,
  });

  factory GitHubReleaseDto.fromJson(Map<String, dynamic> json) {
    return GitHubReleaseDto(
      tagName: json['tag_name'] as String,
      name: json['name'] as String? ?? json['tag_name'] as String,
      body: json['body'] as String?,
      publishedAt: json['published_at'] as String,
      assets: json['assets'] as List<dynamic>? ?? [],
    );
  }

  GitHubRelease toDomain() {
    return GitHubRelease(
      tagName: tagName,
      name: name,
      body: body,
      publishedAt: DateTime.parse(publishedAt),
      assets: assets.map((asset) => ReleaseAssetDto.fromJson(asset as Map<String, dynamic>).toDomain()).toList(),
    );
  }
}
