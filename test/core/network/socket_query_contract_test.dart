import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/data/repositories/expedition_check_item_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

class _Socket {
  final String id = 'test-session';
  Map<String, dynamic> response = {'Data': <Object>[]};
  final Map<String, void Function(dynamic)> listeners = {};
  final List<Map<String, dynamic>> requests = [];

  void on(String event, void Function(dynamic) callback) => listeners[event] = callback;
  void off(String event) => listeners.remove(event);
  void emit(String event, dynamic data) {
    final request = jsonDecode(data as String) as Map<String, dynamic>;
    requests.add(request);
    expect(event, startsWith('$id '));
    listeners[request['ResponseIn']]!(jsonEncode(response));
  }
}

Future<List<Map<String, dynamic>>> _select(_Socket socket, QueryBuilder query, {String event = 'separar.consulta'}) {
  return SocketRequestHelper.select(baseEvent: event, queryBuilder: query, fromJson: (row) => row, socket: socket);
}

void main() {
  for (final mutation in [false, true]) {
    final field = mutation ? 'Mutation' : 'Data';
    test('should fail incomplete $field responses and remove the response listener', () async {
      for (final response in [
        <String, dynamic>{},
        {field: null},
      ]) {
        final socket = _Socket()..response = response;
        final request = mutation
            ? SocketRequestHelper.mutation<Map<String, dynamic>>(
                baseEvent: 'separacao.item.update',
                entityJson: {'Item': '1'},
                fromJson: (row) => row,
                socket: socket,
              )
            : _select(socket, QueryBuilder());
        await expectLater(request, throwsA(isA<DataError>().having((e) => e.message, 'message', contains(field))));
        expect(socket.listeners, isEmpty);
        expect(socket.requests, hasLength(1));
      }
    });
    test('should accept an explicit empty $field response', () async {
      final socket = _Socket()..response = {field: <Object>[]};
      final result = mutation
          ? await SocketRequestHelper.mutation<Map<String, dynamic>>(
              baseEvent: 'separacao.item.update',
              entityJson: {'Item': '1'},
              fromJson: (row) => row,
              socket: socket,
            )
          : await _select(socket, QueryBuilder());
      expect(result, isEmpty);
      expect(socket.listeners, isEmpty);
    });
  }

  test('should send empty IN and keep other filters unchanged', () async {
    final socket = _Socket();
    await _select(socket, QueryBuilder().equals('CodEmpresa', 1).inList('Item', <String>[]));
    expect(socket.requests.single['Where'], [
      {'key': 'CodEmpresa', 'value': 1},
      {'key': 'Item', 'operator': 'IN', 'value': <String>[]},
    ]);
    expect(socket.listeners, isEmpty);
  });

  for (final allRows in [false, true]) {
    test('should send explicit ordering for ${allRows ? 'all rows' : 'one page'}', () async {
      final socket = _Socket();
      final query = QueryBuilder().orderByDesc('DataEmissao').orderByAsc('CodSepararEstoque');
      if (allRows) {
        query.allRows();
      } else {
        query.paginate(limit: 20, offset: 40, page: 3);
      }
      await _select(socket, query);
      expect(socket.requests.single['OrderBy'], 'order_by=DataEmissao,CodSepararEstoque&order_direction=DESC,ASC');
      expect(socket.requests.single['Pagination'], allRows ? 'LIMIT=200&OFFSET=0&PAGE=1' : 'LIMIT=20&OFFSET=40&PAGE=3');
    });
  }

  test('should omit ordering when none was requested', () async {
    final socket = _Socket();
    await _select(socket, QueryBuilder().equals('CodEmpresa', 1));
    expect(socket.requests.single.containsKey('OrderBy'), isFalse);
  });

  for (final query in [
    QueryBuilder().fieldEquals('Quantidade', 'QuantidadeSeparacao'),
    QueryBuilder().fieldGreaterThan('Quantidade', 'QuantidadeSeparacao'),
    QueryBuilder().fieldLessThan('Quantidade', 'QuantidadeSeparacao'),
  ]) {
    test('should reject ${query.params.single.operator} field comparison before sending', () async {
      final socket = _Socket();
      await expectLater(_select(socket, query), throwsStateError);
      expect(socket.requests, isEmpty);
    });
  }

  test('should preserve literal string comparisons', () async {
    final socket = _Socket();
    await _select(socket, QueryBuilder().equals('NomeProduto', 'Quantidade'));
    expect(socket.requests.single['Where'], [
      {'key': 'NomeProduto', 'value': 'Quantidade'},
    ]);
  });

  for (final event in ['conferir.item.consulta', 'conferencia.item.consulta']) {
    test('should reject missing or invalid cart filters before sending $event', () async {
      for (final query in [
        QueryBuilder(),
        QueryBuilder().equals('CodCarrinho', 0),
        QueryBuilder().equals('CodCarrinho', -1),
        QueryBuilder().equals('CodCarrinho', '5'),
        QueryBuilder().isNull('CodCarrinho'),
        QueryBuilder().greaterThan('CodCarrinho', 5),
        QueryBuilder().fieldEquals('CodCarrinho', 'OutroCarrinho'),
      ]) {
        final socket = _Socket();
        await expectLater(
          _select(socket, query, event: event),
          throwsA(isA<DataError>().having((e) => e.code, 'code', 'INVALID_PAYLOAD')),
        );
        expect(socket.requests, isEmpty);
      }
    });
    test('should accept positive cart equality for $event', () async {
      final socket = _Socket();
      await _select(socket, QueryBuilder().equals('CodCarrinho', 5), event: event);
      expect(socket.requests.single['Where'], [
        {'key': 'CodCarrinho', 'value': 5},
      ]);
    });
  }

  test('should validate the cart when called through the conference repository', () async {
    await expectLater(
      ExpeditionCheckItemConsultationRepositoryImpl().selectConsultation(QueryBuilder()),
      throwsA(isA<DataError>().having((e) => e.code, 'code', 'INVALID_PAYLOAD')),
    );
  });
}
