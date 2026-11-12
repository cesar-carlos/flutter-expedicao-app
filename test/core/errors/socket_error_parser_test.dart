import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/socket_error_parser.dart';

void main() {
  group('SocketErrorInfo.fromResponse', () {
    test('should return null when Error is null or empty', () {
      expect(SocketErrorInfo.fromResponse({'Error': null}), isNull);
      expect(SocketErrorInfo.fromResponse({'Error': <String>[]}), isNull);
      expect(SocketErrorInfo.fromResponse({'Error': ''}), isNull);
    });

    test('should parse first Error line and Code', () {
      final info = SocketErrorInfo.fromResponse({
        'Error': ['[50014] Carrinho 10 ja esta em uso', 'detalhe interno'],
        'Code': 'BUSINESS_RULE_VIOLATION',
      });

      expect(info, isNotNull);
      expect(info!.message, '[50014] Carrinho 10 ja esta em uso');
      expect(info.identifier, '50014');
      expect(info.contractCode, 'BUSINESS_RULE_VIOLATION');
      expect(info.isBusinessRule, isTrue);
    });

    test('should parse Error as a single string', () {
      final info = SocketErrorInfo.fromResponse({'Error': '[INVALID_PAYLOAD] Where deve ser uma lista de objetos'});

      expect(info!.identifier, 'INVALID_PAYLOAD');
      expect(info.isInvalidPayload, isTrue);
    });

    test('should classify SQL-CONN as sql unavailable, not a retriable socket drop', () {
      final info = SocketErrorInfo.fromResponse({
        'Error': ['[SQL-CONN] Falha de conexao com o banco.'],
        'Code': 'INTERNAL_ERROR',
      });

      expect(info!.identifier, 'SQL-CONN');
      expect(info.contractCode, 'INTERNAL_ERROR');
      expect(info.isSqlUnavailable, isTrue);
      expect(info.isInternalError, isTrue);
      expect(info.isConnection, isTrue);
    });
  });
}
