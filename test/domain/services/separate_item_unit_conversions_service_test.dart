import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/services/separate_item_unit_conversions_service.dart';

void main() {
  group('SeparateItemUnitConversionsService', () {
    test('anexa conversoes paginadas no item correspondente', () async {
      final item = _buildItem(item: '1', codProduto: 10);
      final cx = _buildUnit(item: '1', codProduto: 10, itemUnidadeMedida: '2', codUnidadeMedida: 'CX');
      final captured = <QueryBuilder>[];
      final service = SeparateItemUnitConversionsService(
        repository: _FakeUnitRepository((query) async {
          captured.add(query);
          return [cx];
        }),
      );

      final result = await service.attachToItems(items: [item], codEmpresa: 1, codSepararEstoque: 123);

      expect(result.single.unidadeMedidas, hasLength(1));
      expect(result.single.unidadeMedidas.single.codUnidadeMedida, 'CX');
      expect(captured.single.fetchAllPages, isTrue);
      expect(captured.single.buildOrderByQuery(), 'order_by=Item,ItemUnidadeMedida&order_direction=ASC,ASC');
    });

    test('mantem unidades aninhadas quando a consulta paginada vem vazia', () {
      final nested = _buildUnit(item: '1', codProduto: 10, itemUnidadeMedida: '1', codUnidadeMedida: 'UN');
      final item = _buildItem(item: '1', codProduto: 10, units: [nested]);

      final merged = SeparateItemUnitConversionsService.merge([item], const []);

      expect(merged.single.unidadeMedidas.single.codUnidadeMedida, 'UN');
    });

    test('nao mistura conversao de outro item', () {
      final item = _buildItem(item: '1', codProduto: 10);
      final other = _buildUnit(item: '2', codProduto: 20, itemUnidadeMedida: '1', codUnidadeMedida: 'CX');

      final merged = SeparateItemUnitConversionsService.merge([item], [other]);

      expect(merged.single.unidadeMedidas, isEmpty);
    });

    test('propaga falha clara quando a consulta de conversoes falha', () async {
      final item = _buildItem(item: '1', codProduto: 10);
      final service = SeparateItemUnitConversionsService(
        repository: _FakeUnitRepository((_) async {
          throw Exception('socket caiu');
        }),
      );

      expect(
        () => service.attachToItems(items: [item], codEmpresa: 1, codSepararEstoque: 123),
        throwsA(
          isA<DataFailure>()
              .having((e) => e.code, 'code', SeparateItemUnitConversionsService.loadFailedCode)
              .having((e) => e.message, 'message', SeparateItemUnitConversionsService.loadFailedMessage),
        ),
      );
    });

    test('busca conversoes em paralelo com os itens', () async {
      final item = _buildItem(item: '1', codProduto: 10);
      final cx = _buildUnit(item: '1', codProduto: 10, itemUnidadeMedida: '2', codUnidadeMedida: 'CX');
      final itemsStarted = Completer<void>();
      final unitsStarted = Completer<void>();
      final service = SeparateItemUnitConversionsService(
        repository: _FakeUnitRepository((_) async {
          unitsStarted.complete();
          await itemsStarted.future;
          return [cx];
        }),
      );

      final itemsFuture = () async {
        itemsStarted.complete();
        await unitsStarted.future;
        return [item];
      }();

      final result = await service
          .attachInParallel(itemsFuture: itemsFuture, codEmpresa: 1, codSepararEstoque: 123)
          .timeout(const Duration(seconds: 2));

      expect(result.single.unidadeMedidas.single.codUnidadeMedida, 'CX');
    });
  });
}

class _FakeUnitRepository implements BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> {
  _FakeUnitRepository(this.onSelect);

  final Future<List<SeparateItemUnidadeMedidaConsultationModel>> Function(QueryBuilder query) onSelect;

  @override
  Future<List<SeparateItemUnidadeMedidaConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return onSelect(queryBuilder);
  }
}

SeparateItemConsultationModel _buildItem({
  required String item,
  required int codProduto,
  List<SeparateItemUnidadeMedidaConsultationModel> units = const [],
}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 123,
    item: item,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 123,
    codProduto: codProduto,
    nomeProduto: 'Produto',
    ativo: Situation.ativo,
    codTipoProduto: 'P',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Endereco',
    quantidade: 1,
    quantidadeInterna: 1,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: units,
  );
}

SeparateItemUnidadeMedidaConsultationModel _buildUnit({
  required String item,
  required int codProduto,
  required String itemUnidadeMedida,
  required String codUnidadeMedida,
}) {
  return SeparateItemUnidadeMedidaConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 123,
    item: item,
    codProduto: codProduto,
    itemUnidadeMedida: itemUnidadeMedida,
    codUnidadeMedida: codUnidadeMedida,
    unidadeMedidaDescricao: codUnidadeMedida,
    unidadeMedidaPadrao: Situation.inativo,
    tipoFatorConversao: TipoFatorConversao.multiplicacao,
    fatorConversao: 1,
  );
}
