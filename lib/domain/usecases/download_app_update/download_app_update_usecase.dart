import 'package:result_dart/result_dart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_params.dart';
import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

class DownloadAppUpdateUseCase {
  final IAppUpdateRepository repository;

  DownloadAppUpdateUseCase(this.repository);

  Future<Result<String>> call(DownloadAppUpdateParams params) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = path.join(directory.path, params.fileName);

      final downloadResult = await repository.downloadApk(params.downloadUrl, savePath);

      return downloadResult.fold((apkPath) => success(apkPath), (exception) {
        final errorMessage = exception is AppFailure ? exception.message : exception.toString();
        return failure(AppUpdateFailure.downloadFailed(errorMessage));
      });
    } catch (e) {
      return failure(AppUpdateFailure.downloadFailed(e.toString()));
    }
  }
}
