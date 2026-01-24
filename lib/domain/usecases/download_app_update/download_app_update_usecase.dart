import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/extensions/result_app_update_extensions.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_params.dart';

class DownloadAppUpdateUseCase {
  final IAppUpdateRepository repository;

  DownloadAppUpdateUseCase(this.repository);

  Future<Result<String>> call(DownloadAppUpdateParams params) async {
    final downloadResult = await repository.downloadApk(
      params.downloadUrl,
      fileName: params.fileName,
      onProgress: params.onProgress,
      isCancelled: params.isCancelled,
    );

    return downloadResult.mapFailureToAppUpdate(
      (e) => AppUpdateFailure.downloadFailed(
        e is AppFailure ? e.message : e.toString(),
      ),
    );
  }
}
