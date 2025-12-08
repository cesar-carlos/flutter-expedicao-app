import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_params.dart';

class CheckAppUpdateUseCase {
  final IAppUpdateRepository repository;

  CheckAppUpdateUseCase(this.repository);

  Future<Result<GitHubRelease>> call(CheckAppUpdateParams params) async {
    try {
      final currentVersionResult = await repository.getCurrentVersion();
      final currentVersion = currentVersionResult.fold((success) => success, (failure) => null);

      if (currentVersion == null) {
        final errorMessage = currentVersionResult.fold(
          (success) => 'Erro inesperado',
          (exception) => exception is AppFailure ? exception.message : exception.toString(),
        );
        return failure(AppUpdateFailure.versionCheckFailed(errorMessage));
      }

      final latestReleaseResult = await repository.getLatestRelease(params.owner, params.repo);
      final latestRelease = latestReleaseResult.fold((success) => success, (failure) => null);

      if (latestRelease == null) {
        final errorMessage = latestReleaseResult.fold(
          (success) => 'Erro inesperado',
          (exception) => exception is AppFailure ? exception.message : exception.toString(),
        );
        return failure(AppUpdateFailure.versionCheckFailed(errorMessage));
      }

      final releaseVersion = latestRelease.getVersion();
      if (releaseVersion == null) {
        return failure(AppUpdateFailure.invalidRelease('Tag name inválida: ${latestRelease.tagName}'));
      }

      if (releaseVersion.isNewerThan(currentVersion)) {
        final apkAsset = latestRelease.getApkAsset();
        if (apkAsset == null) {
          return failure(AppUpdateFailure.noApkFound());
        }
        return success(latestRelease);
      }

      return failure(AppUpdateFailure.noUpdateAvailable());
    } catch (e) {
      return failure(AppUpdateFailure.versionCheckFailed(e.toString()));
    }
  }
}
