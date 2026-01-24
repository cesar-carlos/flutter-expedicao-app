import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:data7_expedicao/data/dtos/github_release_dto.dart';
import 'package:data7_expedicao/data/services/github_api_service.dart';

class GitHubReleaseJsonAdapter {
  final GitHubApiService _githubApiService;
  final Dio _dio;

  GitHubReleaseJsonAdapter({GitHubApiService? githubApiService, Dio? dio})
    : _githubApiService = githubApiService ?? GitHubApiService(),
      _dio = dio ?? Dio();

  Future<String> createVersionJsonFile(String owner, String repo) async {
    final releases = await _githubApiService.getReleases(owner, repo);
    final jsonData = await _convertReleasesToJson(releases);

    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, 'versions.json');
    final file = File(filePath);
    await file.writeAsString(jsonData);

    return filePath;
  }

  Future<String> _convertReleasesToJson(List<GitHubReleaseDto> releases) async {
    final List<Map<String, dynamic>> versionList = [];

    for (final releaseDto in releases) {
      final release = releaseDto.toDomain();
      final apkAsset = release.getApkAsset();

      if (apkAsset == null) continue;

      final version = release.getVersion();
      if (version == null) continue;

      String sha512;
      try {
        sha512 = await _calculateSha512(apkAsset.downloadUrl);
      } catch (e) {
        sha512 = '';
      }

      versionList.add({
        'version': version.version,
        'url': apkAsset.downloadUrl,
        'releaseNotes': release.body ?? release.name,
        'releaseDate': release.publishedAt.toUtc().toIso8601String(),
        'sha512': sha512,
      });
    }

    return jsonEncode(versionList);
  }

  Future<String> _calculateSha512(String url) async {
    try {
      final response = await _dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));

      if (response.data == null) {
        return '';
      }

      final bytes = response.data!;
      final digest = sha512.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, dynamic>?> getLatestVersionJson(String owner, String repo) async {
    try {
      final latestReleaseDto = await _githubApiService.getLatestRelease(owner, repo);
      final release = latestReleaseDto.toDomain();
      final apkAsset = release.getApkAsset();

      if (apkAsset == null) return null;

      final version = release.getVersion();
      if (version == null) return null;

      String sha512;
      try {
        sha512 = await _calculateSha512(apkAsset.downloadUrl);
      } catch (e) {
        sha512 = '';
      }

      return {
        'version': version.version,
        'url': apkAsset.downloadUrl,
        'releaseNotes': release.body ?? release.name,
        'releaseDate': release.publishedAt.toUtc().toIso8601String(),
        'sha512': sha512,
      };
    } catch (e) {
      return null;
    }
  }
}
