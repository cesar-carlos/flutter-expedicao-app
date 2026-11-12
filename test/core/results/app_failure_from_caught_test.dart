import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

void main() {
  group('AppFailure.fromCaught', () {
    test('should map business rule identifier to BusinessFailure', () {
      final failure = AppFailure.fromCaught(DataError(message: '[50014] Carrinho 10 ja esta em uso no setor 3'));

      expect(failure, isA<BusinessFailure>());
      expect(failure.userMessage, '[50014] Carrinho 10 ja esta em uso no setor 3');
      expect(failure.code, '50014');
    });

    test('should map INVALID_PAYLOAD to ValidationFailure', () {
      final failure = AppFailure.fromCaught(
        DataError(message: '[INVALID_PAYLOAD] Where deve ser uma lista de objetos'),
      );

      expect(failure, isA<ValidationFailure>());
      expect(failure.userMessage, contains('[INVALID_PAYLOAD]'));
    });

    test('should map socket disconnected to NetworkFailure with a clear user message', () {
      final failure = AppFailure.fromCaught(DataError(message: 'Socket nao esta conectado'));

      expect(failure, isA<NetworkFailure>());
      expect(
        failure.userMessage,
        'Conexão em tempo real indisponível. Verifique o indicador de conexão e tente novamente.',
      );
    });

    test('should map SQL-QUERY to DataFailure', () {
      final failure = AppFailure.fromCaught(DataError(message: '[SQL-QUERY] colunas invalidas'));

      expect(failure, isA<DataFailure>());
      expect(failure.userMessage, '[SQL-QUERY] colunas invalidas');
    });

    test('should map SQL-CONN to NetworkFailure with a clear user message', () {
      final failure = AppFailure.fromCaught(
        DataError(message: '[SQL-CONN] Falha de conexao com o banco.', code: 'INTERNAL_ERROR'),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, 'SQL-CONN');
      expect(failure.userMessage, 'O banco de dados do servidor está indisponível. Tente novamente em instantes.');
    });

    test('should keep an AppFailure already typed', () {
      const original = AuthFailure(message: 'sessao expirada');
      expect(AppFailure.fromCaught(original), same(original));
    });
  });
}
