import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/network/retry_policy.dart';
import 'package:data7_expedicao/core/network/socket_operation_retry.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

void main() {
  group('isRetriableSocketError', () {
    test('retenta timeout e queda de conexao', () {
      expect(isRetriableSocketError(DataError(message: 'Tempo limite excedido (0:00:30)')), isTrue);
      expect(
        isRetriableSocketError(DataError(message: 'Conexão com o servidor foi perdida. Tente novamente.')),
        isTrue,
      );
      expect(isRetriableSocketError(NetworkError(message: 'rede')), isTrue);
    });

    test('nao retenta regra de negocio nem payload invalido', () {
      expect(isRetriableSocketError(DataError(message: '[50014] Carrinho em uso', code: '50014')), isFalse);
      expect(isRetriableSocketError(DataError(message: 'payload', code: 'INVALID_PAYLOAD')), isFalse);
      expect(isRetriableSocketError(StateError('Socket não está pronto')), isFalse);
    });

    test('nao retenta SQL-CONN nem INTERNAL_ERROR', () {
      expect(
        isRetriableSocketError(DataError(message: '[SQL-CONN] Falha de conexao com o banco.', code: 'INTERNAL_ERROR')),
        isFalse,
      );
      expect(isRetriableSocketError(DataError(message: '[SQL-CONN] Falha de conexao com o banco.')), isFalse);
      expect(isRetriableSocketError(DataError(message: 'falha interna', code: 'INTERNAL_ERROR')), isFalse);
    });
  });

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

    test('nao retenta mutacao com erro de regra de negocio', () async {
      var attempts = 0;
      final retry = SocketOperationRetry(
        retryPolicy: const RetryPolicy(maxAttempts: 3, initialDelay: Duration.zero),
        validateSocketState: () => SocketValidationResult.success('sid'),
      );

      await expectLater(
        retry.execute(() async {
          attempts++;
          throw DataError(message: '[50014] Carrinho em uso', code: '50014');
        }),
        throwsA(isA<DataError>()),
      );
      expect(attempts, 1);
    });
  });
}
