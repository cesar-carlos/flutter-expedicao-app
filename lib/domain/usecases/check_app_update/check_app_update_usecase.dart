import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/result_extensions.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_params.dart';

class CheckAppUpdateUseCase {
  final IAppUpdateRepository repository;

  CheckAppUpdateUseCase(this.repository);

  Future<Result<GitHubRelease>> call(CheckAppUpdateParams params) async {
    final currentVersionResult = await repository.getCurrentVersion();

    if (currentVersionResult.isError()) {
      final errorMessage = currentVersionResult.getErrorMessageOrDefault('Erro ao obter versão atual');
      return failure(AppUpdateFailure.versionCheckFailed(errorMessage));
    }

    final currentVersion = currentVersionResult.get();

    final latestReleaseResult = await repository.getLatestRelease(params.owner, params.repo);

    if (latestReleaseResult.isError()) {
      final errorMessage = latestReleaseResult.getErrorMessageOrDefault('Erro ao obter releases');
      return failure(AppUpdateFailure.versionCheckFailed(errorMessage));
    }

    final latestRelease = latestReleaseResult.get();

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
  }
}
