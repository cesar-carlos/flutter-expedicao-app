import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/network/socket_operation_retry.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

void main() {
  group('SocketOperationRetry', () {
    test('execute lanca antes da operacao quando socket nao inicializado', () async {
      final retry = SocketOperationRetry(retryPolicy: const RetryPolicy(maxAttempts: 1, initialDelay: Duration.zero));

      await expectLater(retry.execute(() async => 42), throwsA(isA<StateError>()));
    });

    test('execute delega ao RetryPolicy quando validacao customizada ok', () async {
      var attempts = 0;
      final retry = SocketOperationRetry(
        retryPolicy: const RetryPolicy(maxAttempts: 1, initialDelay: Duration.zero),
        validateSocketState: () => SocketValidationResult.success('sid'),
      );

      final result = await retry.execute(() async {
        attempts++;
        return 7;
      });

      expect(result, 7);
      expect(attempts, 1);
    });
  });
}
