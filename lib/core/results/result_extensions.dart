import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';

extension ResultExtensions<T extends Object> on Result<T> {
  String getErrorMessageOrDefault(String fallback) {
    return fold((_) => fallback, (err) => err is AppFailure ? err.message : fallback);
  }

  T get() {
    final v = getOrNull();
    if (v != null) return v;
    throw exceptionOrNull() ?? StateError('Result has no value');
  }

  Exception getError() {
    final e = exceptionOrNull();
    if (e != null) return e;
    throw StateError('Result is success, no error');
  }
}

extension ResultVoidExtensions on Result<void> {
  Exception getError() {
    final e = exceptionOrNull();
    if (e != null) return e;
    throw StateError('Result is success, no error');
  }
}
