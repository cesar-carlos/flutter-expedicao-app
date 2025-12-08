import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:result_dart/result_dart.dart';
import 'package:data7_expedicao/domain/models/app_version.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/data/services/github_api_service.dart';
import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppUpdateRepositoryImpl implements IAppUpdateRepository {
  final GitHubApiService _githubApiService;

  AppUpdateRepositoryImpl({GitHubApiService? githubApiService})
    : _githubApiService = githubApiService ?? GitHubApiService(token: dotenv.env['GITHUB_TOKEN']);

  @override
  Future<Result<AppVersion>> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionParts = packageInfo.version.split('+');
      final version = versionParts[0];
      final buildNumber = versionParts.length > 1
          ? int.tryParse(versionParts[1]) ?? 0
          : int.tryParse(packageInfo.buildNumber) ?? 0;

      return success(AppVersion(version: version, buildNumber: buildNumber));
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<List<GitHubRelease>>> getReleases(String owner, String repo) async {
    try {
      final releasesDto = await _githubApiService.getReleases(owner, repo);
      final releases = releasesDto.map((dto) => dto.toDomain()).toList();
      return success(releases);
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<GitHubRelease>> getLatestRelease(String owner, String repo) async {
    try {
      final releaseDto = await _githubApiService.getLatestRelease(owner, repo);
      return success(releaseDto.toDomain());
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<String>> downloadApk(String downloadUrl, String savePath) async {
    try {
      final dio = Dio();
      final file = File(savePath);

      final response = await dio.download(downloadUrl, savePath);

      if (response.statusCode == 200 && await file.exists()) {
        return success(savePath);
      } else {
        return failure(DataFailure(message: 'Falha ao baixar APK', code: 'DOWNLOAD_FAILED'));
      }
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<void>> installApk(String apkPath) async {
    try {
      final file = File(apkPath);
      if (!await file.exists()) {
        return failure(DataFailure(message: 'Arquivo APK não encontrado', code: 'APK_NOT_FOUND'));
      }

      final result = await OpenFilex.open(apkPath);
      if (result.type == ResultType.done) {
        return successVoid();
      } else {
        return failure(DataFailure(message: 'Falha ao abrir instalador: ${result.message}', code: 'INSTALL_FAILED'));
      }
    } catch (e) {
      return unknownFailure(e);
    }
  }
}
