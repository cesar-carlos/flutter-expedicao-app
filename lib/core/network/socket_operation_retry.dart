import 'dart:async';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/errors/socket_error_parser.dart';
import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

typedef SocketStateValidator = SocketValidationResult Function();

/// Retry só para falha de rede/conexão. Timeout de mutação que já gravou
/// não pode repetir o INSERT.
bool isRetriableSocketError(Object error) {
  if (error is StateError) {
    return false;
  }
  if (error is TimeoutException) {
    return true;
  }
  if (error is NetworkError) {
    return true;
  }
  if (error is! DataError) {
    return false;
  }

  final info = SocketErrorInfo(
    message: error.message,
    identifier: SocketErrorInfo.identifierOf(error.message) ?? error.code?.toUpperCase(),
    contractCode: error.code?.toUpperCase(),
  );
  if (info.isBusinessRule || info.isInvalidPayload || info.isNotFound || info.isUnauthorized) {
    return false;
  }
  if (info.isSqlUnavailable || info.isInternalError) {
    return false;
  }
  return info.isConnection;
}

class SocketOperationRetry {
  final RetryPolicy _retryPolicy;
  final SocketStateValidator _validateSocketState;

  SocketOperationRetry({RetryPolicy? retryPolicy, SocketStateValidator? validateSocketState})
    : _retryPolicy = _policyWithSocketFilter(
        retryPolicy ??
            RetryPolicy.withJitter(
              maxAttempts: 3,
              initialDelay: const Duration(seconds: 1),
              backoffMultiplier: 2.0,
              maxDelay: const Duration(seconds: 8),
            ),
      ),
      _validateSocketState = validateSocketState ?? SocketValidationHelper.validateSocketState;

  static RetryPolicy _policyWithSocketFilter(RetryPolicy policy) {
    return RetryPolicy.withJitter(
      maxAttempts: policy.maxAttempts,
      initialDelay: policy.initialDelay,
      backoffMultiplier: policy.backoffMultiplier,
      maxDelay: policy.maxDelay,
      shouldRetry: (error) {
        if (!isRetriableSocketError(error)) {
          return false;
        }
        return policy.shouldRetry?.call(error) ?? true;
      },
    );
  }

  Future<T> execute<T>(Future<T> Function() operation, {String? operationId}) async {
    final validation = _validateSocketState();
    if (!validation.isValid) {
      AppLogger.warning('Socket inválido antes da operação: ${validation.errorMessage}', tag: 'SocketOperationRetry');
      throw StateError(validation.errorMessage ?? 'Socket não está pronto para operações');
    }

    return _retryPolicy.execute(operation, tag: 'SocketOperationRetry${operationId != null ? '.$operationId' : ''}');
  }
}
