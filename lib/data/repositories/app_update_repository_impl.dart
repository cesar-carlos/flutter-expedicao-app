import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/data/services/github_api_service.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/models/app_version.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';

class AppUpdateRepositoryImpl implements IAppUpdateRepository {
  final GitHubApiService _githubApiService;

  AppUpdateRepositoryImpl({GitHubApiService? githubApiService})
    : _githubApiService = githubApiService ?? GitHubApiService(token: dotenv.env['GITHUB_TOKEN']);

  /// Trata exceções do Dio e retorna [AppFailure] apropriado.
  AppFailure _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return AppUpdateFailure.networkError('Tempo de conexão esgotado');
      case DioExceptionType.sendTimeout:
        return AppUpdateFailure.networkError('Tempo de envio esgotado');
      case DioExceptionType.receiveTimeout:
        return AppUpdateFailure.networkError('Tempo de resposta esgotado');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return AppUpdateFailure.versionCheckFailed('Recurso não encontrado');
        } else if (statusCode == 401 || statusCode == 403) {
          return AppUpdateFailure.versionCheckFailed('Acesso negado. Verifique suas credenciais');
        } else if (statusCode != null && statusCode >= 500) {
          return AppUpdateFailure.versionCheckFailed('Erro no servidor (HTTP $statusCode)');
        } else {
          return AppUpdateFailure.versionCheckFailed('Erro HTTP $statusCode');
        }
      case DioExceptionType.cancel:
        return AppUpdateFailure.downloadFailed('Download cancelado');
      case DioExceptionType.connectionError:
        return AppUpdateFailure.networkError('Sem conexão com a internet');
      case DioExceptionType.badCertificate:
        return AppUpdateFailure.networkError('Erro de certificado SSL');
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return AppUpdateFailure.networkError('Sem conexão com a internet');
        }
        return AppUpdateFailure.networkError('Erro de rede desconhecido: ${e.message}');
    }
  }

  @override
  Future<Result<AppVersion>> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      final buildNumber = int.tryParse(packageInfo.buildNumber) ?? 0;

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
    } on DioException catch (e) {
      return failure(_handleDioException(e));
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<GitHubRelease>> getLatestRelease(String owner, String repo) async {
    try {
      final releaseDto = await _githubApiService.getLatestRelease(owner, repo);
      return success(releaseDto.toDomain());
    } on DioException catch (e) {
      return failure(_handleDioException(e));
    } catch (e) {
      return unknownFailure(e);
    }
  }

  @override
  Future<Result<String>> downloadApk(
    String downloadUrl, {
    required String fileName,
    void Function(int received, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = path.join(directory.path, fileName);
      final dio = Dio();
      final file = File(savePath);
      final cancelToken = CancelToken();

      final response = await dio.download(
        downloadUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (isCancelled != null && isCancelled()) {
            cancelToken.cancel('Download cancelado pelo usuário');
            return;
          }
          if (onProgress != null && total > 0) {
            onProgress(received, total);
          }
        },
      );

      if (response.statusCode == 200 && await file.exists()) {
        return success(savePath);
      } else {
        return failure(DataFailure(message: 'Falha ao baixar APK', code: 'DOWNLOAD_FAILED'));
      }
    } on DioException catch (e) {
      return failure(_handleDioException(e));
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
