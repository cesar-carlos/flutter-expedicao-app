import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

class SocketOperationRetry {
  final RetryPolicy _retryPolicy;

  SocketOperationRetry({RetryPolicy? retryPolicy})
    : _retryPolicy =
          retryPolicy ??
          const RetryPolicy(
            maxAttempts: 3,
            initialDelay: Duration(seconds: 1),
            backoffMultiplier: 2.0,
            maxDelay: Duration(seconds: 8),
          );

  Future<T> execute<T>(Future<T> Function() operation, {String? operationId}) async {
    final validation = SocketValidationHelper.validateSocketState();
    if (!validation.isValid) {
      AppLogger.warning('Socket inválido antes da operação: ${validation.errorMessage}', tag: 'SocketOperationRetry');
      throw StateError(validation.errorMessage ?? 'Socket não está pronto para operações');
    }

    return _retryPolicy.execute(operation, tag: 'SocketOperationRetry${operationId != null ? '.$operationId' : ''}');
  }
}
