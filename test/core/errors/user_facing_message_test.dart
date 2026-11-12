import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/errors/user_facing_message.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

void main() {
  group('UserFacingMessage.fromText', () {
    test('should keep the server business message', () {
      expect(
        UserFacingMessage.fromText('[50014] Carrinho 10 ja esta em uso no setor 3'),
        '[50014] Carrinho 10 ja esta em uso no setor 3',
      );
    });

    test('should strip Exception wrappers', () {
      expect(UserFacingMessage.fromText('Exception: DataError: quantidade excedida'), 'quantidade excedida');
    });

    test('should rewrite socket disconnected jargon', () {
      expect(
        UserFacingMessage.fromText('Socket nao esta conectado'),
        'Conexão em tempo real indisponível. Verifique o indicador de conexão e tente novamente.',
      );
    });

    test('should rewrite timeout jargon', () {
      expect(
        UserFacingMessage.fromText('Tempo limite excedido (0:00:30) ao aguardar resposta de separar.select'),
        'O servidor não respondeu a tempo. Tente novamente.',
      );
    });

    test('should rewrite SQL-CONN as a database unavailable message', () {
      expect(
        UserFacingMessage.fromText('[SQL-CONN] Falha de conexao com o banco.'),
        'O banco de dados do servidor está indisponível. Tente novamente em instantes.',
      );
    });

    test('should keep lost-connection message', () {
      expect(
        UserFacingMessage.fromText('Conexão com o servidor foi perdida. Tente novamente.'),
        'Conexão com o servidor foi perdida. Tente novamente.',
      );
    });

    test('should not hide a Portuguese connection phrase', () {
      expect(UserFacingMessage.fromText('Erro de conexão'), 'Erro de conexão');
    });
  });

  group('AppFailure.forUser', () {
    test('should show NetworkFailure cause instead of a generic internet text', () {
      const failure = NetworkFailure(message: 'Socket nao esta conectado');
      expect(
        AppFailure.forUser(failure),
        'Conexão em tempo real indisponível. Verifique o indicador de conexão e tente novamente.',
      );
    });

    test('should show DataError message', () {
      expect(AppFailure.forUser(DataError(message: '[50014] Carrinho em uso')), '[50014] Carrinho em uso');
    });

    test('should use fallback only when there is no usable text', () {
      expect(AppFailure.forUser(null, fallback: 'Operação falhou'), 'Operação falhou');
    });
  });
}
