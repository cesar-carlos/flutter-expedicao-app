import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_request_helper.dart';

/// Testes para SocketRequestHelper.
///
/// Como o helper usa `SocketConfig.instance` (singleton estatico) para
/// emit/on/off, testar a integracao completa requer mockar SocketConfig
/// — fora do escopo destes testes unitarios. Aqui cobrimos os helpers
/// publicos `decodeResponse`, `extractDataList`, `extractMutationList`
/// e `parseItems` que encapsulam toda a logica defensiva de parsing
/// (origem dos bugs DDDDDD e similares).
void main() {
  group('SocketRequestHelper.decodeResponse', () {
    test('decodifica JSON String em Map<String, dynamic>', () {
      final result = SocketRequestHelper.decodeResponse('{"Data":[1,2,3],"Error":null}');
      expect(result['Data'], equals([1, 2, 3]));
      expect(result['Error'], isNull);
    });

    test('aceita Map ja decodificado e converte para Map<String, dynamic>', () {
      final input = <String, dynamic>{'Mutation': [], 'Error': null};
      final result = SocketRequestHelper.decodeResponse(input);
      expect(result, equals(input));
    });

    test('aceita Map<dynamic, dynamic> e converte', () {
      // Alguns transports do socket.io entregam Map<dynamic, dynamic>.
      final input = <dynamic, dynamic>{'Data': [], 'foo': 'bar'};
      final result = SocketRequestHelper.decodeResponse(input);
      expect(result, isA<Map<String, dynamic>>());
      expect(result['foo'], equals('bar'));
    });

    test('lanca FormatException se JSON String nao for objeto', () {
      expect(
        () => SocketRequestHelper.decodeResponse('[1,2,3]'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SocketRequestHelper.decodeResponse('"plain string"'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lanca FormatException se receiver nao for String nem Map', () {
      expect(
        () => SocketRequestHelper.decodeResponse(123),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SocketRequestHelper.decodeResponse(null),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SocketRequestHelper.decodeResponse([1, 2, 3]),
        throwsA(isA<FormatException>()),
      );
    });

    test('lanca FormatException em JSON malformado', () {
      expect(
        () => SocketRequestHelper.decodeResponse('{invalid json}'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SocketRequestHelper.extractDataList', () {
    test('retorna lista do campo "Data"', () {
      final list = SocketRequestHelper.extractDataList({
        'Data': [
          {'a': 1},
          {'b': 2},
        ],
      });
      expect(list.length, equals(2));
      expect(list.first['a'], equals(1));
    });

    test('retorna lista vazia quando campo "Data" e null', () {
      final list = SocketRequestHelper.extractDataList({'Data': null});
      expect(list, isEmpty);
    });

    test('retorna lista vazia quando campo "Data" e ausente', () {
      final list = SocketRequestHelper.extractDataList({'Other': 'value'});
      expect(list, isEmpty);
    });

    test('lanca FormatException quando "Data" nao e List', () {
      expect(
        () => SocketRequestHelper.extractDataList({'Data': 'not a list'}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SocketRequestHelper.extractDataList({'Data': {'k': 'v'}}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SocketRequestHelper.extractMutationList', () {
    test('retorna lista do campo "Mutation"', () {
      final list = SocketRequestHelper.extractMutationList({
        'Mutation': [
          {'a': 1},
        ],
      });
      expect(list.length, equals(1));
    });

    test('retorna lista vazia quando "Mutation" e null', () {
      final list = SocketRequestHelper.extractMutationList({'Mutation': null});
      expect(list, isEmpty);
    });

    test('retorna lista vazia quando "Mutation" e ausente', () {
      final list = SocketRequestHelper.extractMutationList({});
      expect(list, isEmpty);
    });

    test('lanca FormatException quando "Mutation" nao e List', () {
      expect(
        () => SocketRequestHelper.extractMutationList({'Mutation': 42}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SocketRequestHelper.parseItems', () {
    test('parseia todos os items validos', () {
      final input = [
        {'name': 'A'},
        {'name': 'B'},
        {'name': 'C'},
      ];
      final result = SocketRequestHelper.parseItems<String>(
        input,
        (m) => m['name'] as String,
      );
      expect(result, equals(['A', 'B', 'C']));
    });

    test('ignora items que nao sao Map (com log)', () {
      final input = [
        {'name': 'A'},
        'not a map', // ignorado
        42, // ignorado
        null, // ignorado
        {'name': 'B'},
      ];
      final result = SocketRequestHelper.parseItems<String>(
        input,
        (m) => m['name'] as String,
      );
      expect(result, equals(['A', 'B']));
    });

    test('ignora items que falham no fromJson (com log)', () {
      final input = [
        {'name': 'A'},
        {'wrong_key': 'X'}, // fromJson lanca TypeError aqui
        {'name': 'B'},
      ];
      final result = SocketRequestHelper.parseItems<String>(
        input,
        (m) => m['name'] as String, // lanca para 'wrong_key'
      );
      expect(result, equals(['A', 'B']));
    });

    test('retorna lista vazia para input vazio', () {
      final result = SocketRequestHelper.parseItems<String>(
        const [],
        (m) => m['name'] as String,
      );
      expect(result, isEmpty);
    });

    test('aceita Map<dynamic, dynamic> e converte', () {
      // Cenario real: alguns servidores retornam Map<dynamic, dynamic>.
      final input = <dynamic>[<dynamic, dynamic>{'name': 'A'}];
      final result = SocketRequestHelper.parseItems<String>(
        input,
        (m) => m['name'] as String,
      );
      expect(result, equals(['A']));
    });
  });

  group('SocketRequestHelper.defaultTimeout', () {
    test('e 30 segundos', () {
      expect(SocketRequestHelper.defaultTimeout, equals(const Duration(seconds: 30)));
    });
  });
}
