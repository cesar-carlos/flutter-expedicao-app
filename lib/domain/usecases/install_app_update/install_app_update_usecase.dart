import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/extensions/result_app_update_extensions.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_params.dart';

class InstallAppUpdateUseCase {
  final IAppUpdateRepository repository;

  InstallAppUpdateUseCase(this.repository);

  Future<Result<void>> call(InstallAppUpdateParams params) async {
    final installResult = await repository.installApk(params.apkPath);

    return installResult.mapFailureToAppUpdate(
      (e) => AppUpdateFailure.installFailed(
        e is AppFailure ? e.message : e.toString(),
      ),
    );
  }
}
