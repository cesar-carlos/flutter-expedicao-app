import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/data/repositories/expedition_item_print_consultation_repository_impl.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

void main() {
  group('ExpeditionItemPrintConsultationRepositoryImpl', () {
    test('deve retornar itens quando socket responder com sucesso', () async {
      final socket = _FakeSocketClient(id: 'session-1', autoRespond: true);
      final repository = ExpeditionItemPrintConsultationRepositoryImpl(
        socket: socket,
        uuid: const Uuid(),
      );

      final result = await repository.selectConsultation(QueryBuilder());

      expect(result, hasLength(1));
      expect(result.first, isA<ExpeditionItemPrintConsultationModel>());
      expect(result.first.codEmpresa, equals(1));
    });

    test(
      'deve retornar DataError quando sessao do socket estiver indisponivel',
      () async {
        final socket = _FakeSocketClient(id: null, autoRespond: true);
        final repository = ExpeditionItemPrintConsultationRepositoryImpl(
          socket: socket,
          uuid: const Uuid(),
        );

        expect(
          () => repository.selectConsultation(QueryBuilder()),
          throwsA(isA<DataError>()),
        );
      },
    );

    test('deve retornar DataError em timeout de resposta', () async {
      final socket = _FakeSocketClient(id: 'session-1', autoRespond: false);
      final repository = ExpeditionItemPrintConsultationRepositoryImpl(
        socket: socket,
        uuid: const Uuid(),
        responseTimeout: const Duration(milliseconds: 30),
      );

      await expectLater(
        repository.selectConsultation(QueryBuilder()),
        throwsA(
          isA<DataError>().having(
            (error) => error.message,
            'message',
            contains('Timeout aguardando retorno'),
          ),
        ),
      );
    });
  });
}

class _FakeSocketClient {
  final String? id;
  final bool autoRespond;
  final Map<String, void Function(dynamic)> _listeners = {};

  _FakeSocketClient({required this.id, required this.autoRespond});

  void on(String event, void Function(dynamic) callback) {
    _listeners[event] = callback;
  }

  void off(String event) {
    _listeners.remove(event);
  }

  void emit(String event, dynamic payload) {
    if (!autoRespond) {
      return;
    }

    final decodedPayload =
        jsonDecode(payload as String) as Map<String, dynamic>;
    final responseEvent = decodedPayload['ResponseIn'] as String;
    final callback = _listeners[responseEvent];

    if (callback == null) {
      return;
    }

    callback(
      jsonEncode({
        'Error': null,
        'Data': [
          {
            'CodEmpresa': 1,
            'CodSepararEstoque': 100,
            'Item': '1',
            'DataSepararEstoque': '2026-02-09',
            'HoraSepararEstoque': '10:00',
            'Situacao': 'S',
            'TipoEntidade': 'C',
            'CodEntidade': '20087',
            'NomeEntidade': 'CLIENTE TESTE',
            'CodPrioridade': 5,
            'DescricaoPrioridade': 'NORMAL',
            'CodLocalArmazenagem': 1,
            'NomeLocalArmazenagem': 'MEZANINO 1',
            'CodProduto': 16580,
            'NomeProduto': 'PRODUTO TESTE',
            'CodUnidadeMedida': 'UN',
            'DescricaoUnidadeMedida': 'UNIDADE',
            'Quantidade': 1,
            'QuantidadeInterna': 1,
            'QuantidadeExterna': 0,
            'QuantidadeSeparacao': 1,
          },
        ],
      }),
    );
  }
}
