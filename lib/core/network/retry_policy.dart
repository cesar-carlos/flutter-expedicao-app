import 'dart:math' as math;

import 'package:data7_expedicao/core/utils/app_logger.dart';

class RetryPolicy {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 30),
  });

  Duration getDelayForAttempt(int attempt) {
    if (attempt <= 0) return Duration.zero;
    final ms = initialDelay.inMilliseconds * math.pow(backoffMultiplier, attempt - 1);
    final duration = Duration(milliseconds: ms.round());
    if (duration > maxDelay) return maxDelay;
    return duration;
  }

  Future<T> execute<T>(Future<T> Function() operation, {String? tag}) async {
    var lastError = Object();

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final result = await operation();
        if (attempt > 1) {
          AppLogger.info('Retry bem-sucedido na tentativa $attempt', tag: tag ?? 'RetryPolicy');
        }
        return result;
      } catch (e, stack) {
        lastError = e;
        if (attempt == maxAttempts) {
          AppLogger.error('Falha após $maxAttempts tentativas', tag: tag ?? 'RetryPolicy', error: e, stackTrace: stack);
          rethrow;
        }
        final delay = getDelayForAttempt(attempt);
        AppLogger.warning(
          'Tentativa $attempt/$maxAttempts falhou. Nova tentativa em ${delay.inMilliseconds}ms',
          tag: tag ?? 'RetryPolicy',
          error: e,
        );
        await Future<void>.delayed(delay);
      }
    }

    throw lastError;
  }
}
