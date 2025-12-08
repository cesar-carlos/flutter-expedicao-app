import 'package:result_dart/result_dart.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_params.dart';

class InstallAppUpdateUseCase {
  final IAppUpdateRepository repository;

  InstallAppUpdateUseCase(this.repository);

  Future<Result<void>> call(InstallAppUpdateParams params) async {
    try {
      final installResult = await repository.installApk(params.apkPath);

      return installResult.fold((_) => installResult, (exception) {
        final errorMessage = exception is AppFailure ? exception.message : exception.toString();
        return failure(AppUpdateFailure.installFailed(errorMessage));
      });
    } catch (e) {
      return failure(AppUpdateFailure.installFailed(e.toString()));
    }
  }
}
