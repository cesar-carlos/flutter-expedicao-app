import 'package:result_dart/result_dart.dart' hide Unit;

import 'package:data7_expedicao/core/results/app_result.dart' show Unit;
import 'package:data7_expedicao/domain/models/app_update_failure.dart';

extension ResultAppUpdateExtensions<T extends Object> on Result<T> {
  Result<T> mapFailureToAppUpdate(AppUpdateFailure Function(Exception) mapper) {
    return fold((s) => Success<T, Exception>(s), (err) => Failure<T, Exception>(mapper(err)));
  }
}

extension ResultVoidAppUpdateExtensions on Result<void> {
  Result<void> mapFailureToAppUpdate(AppUpdateFailure Function(Exception) mapper) {
    return fold(
      (_) => Success<Unit, Exception>(Unit.instance) as Result<void>,
      (err) => Failure<Unit, Exception>(mapper(err)) as Result<void>,
    );
  }
}
