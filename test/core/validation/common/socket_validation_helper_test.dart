import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

void main() {
  group('SocketValidationHelper.isValidSocketSessionId', () {
    test('aceita IDs do Socket.IO 4.x (20 chars alfanumericos)', () {
      expect(SocketValidationHelper.isValidSocketSessionId('GULuJ_h3GG3y0V0CAAAB'), isTrue);
      expect(SocketValidationHelper.isValidSocketSessionId('abcdefghij1234567890'), isTrue);
    });

    test('aceita IDs com hifen e underscore', () {
      expect(SocketValidationHelper.isValidSocketSessionId('socket-123_456-789'), isTrue);
      expect(SocketValidationHelper.isValidSocketSessionId('foo_bar-baz-12345'), isTrue);
    });

    test('aceita IDs com namespace prefixado (Bug Y)', () {
      // Alguns clusters/proxies do Socket.IO emitem IDs com namespace
      expect(SocketValidationHelper.isValidSocketSessionId('/admin#GULuJ_h3'), isTrue);
      expect(SocketValidationHelper.isValidSocketSessionId('app/v1#abc12345'), isTrue);
    });

    test('aceita IDs com pontos (Bug Y)', () {
      expect(SocketValidationHelper.isValidSocketSessionId('node.cluster.42_GULu'), isTrue);
    });

    test('rejeita IDs vazios', () {
      expect(SocketValidationHelper.isValidSocketSessionId(''), isFalse);
    });

    test('rejeita IDs muito curtos (< 8 chars)', () {
      expect(SocketValidationHelper.isValidSocketSessionId('abc'), isFalse);
      expect(SocketValidationHelper.isValidSocketSessionId('1234567'), isFalse);
    });

    test('aceita o limite minimo (8 chars)', () {
      expect(SocketValidationHelper.isValidSocketSessionId('abc12345'), isTrue);
    });

    test('rejeita IDs muito longos (> 64 chars)', () {
      final longId = 'a' * 65;
      expect(SocketValidationHelper.isValidSocketSessionId(longId), isFalse);
    });

    test('rejeita IDs com caracteres invalidos (espacos, simbolos)', () {
      expect(SocketValidationHelper.isValidSocketSessionId('abc 12345'), isFalse);
      expect(SocketValidationHelper.isValidSocketSessionId('abc@12345'), isFalse);
      expect(SocketValidationHelper.isValidSocketSessionId('abc!12345'), isFalse);
    });

    test('IDs antigos do regex restritivo (15-30 chars) continuam validos', () {
      // Garante que a refatoracao do Bug Y nao quebrou compatibilidade
      // com IDs que JÁ funcionavam antes.
      expect(SocketValidationHelper.isValidSocketSessionId('abcdefghijklmnop'), isTrue);
      expect(SocketValidationHelper.isValidSocketSessionId('abc123def456ghi789'), isTrue);
    });
  });

  group('SocketValidationResult', () {
    test('factory success expoe sessionId', () {
      final result = SocketValidationResult.success('abc12345');
      expect(result.isValid, isTrue);
      expect(result.sessionId, equals('abc12345'));
      expect(result.errorMessage, isNull);
    });

    test('factory error expoe mensagem', () {
      final result = SocketValidationResult.error('boom');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('boom'));
      expect(result.sessionId, isNull);
    });

    test('toString eh informativo', () {
      expect(SocketValidationResult.success('abc12345').toString(), contains('success'));
      expect(SocketValidationResult.error('falha').toString(), contains('error'));
    });
  });
}
