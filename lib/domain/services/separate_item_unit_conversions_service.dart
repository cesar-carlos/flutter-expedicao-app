import 'dart:async';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Carrega conversões de unidade em páginas e anexa em cada item.
///
/// `separar.item.consulta` não manda mais `UnidadeMedidas` preenchidas.
/// O coletor busca `separar.item.unidade.medida.consulta` só dos itens
/// já carregados — o `allRows` da separação inteira travava a UI.
class SeparateItemUnitConversionsService {
  SeparateItemUnitConversionsService({
    required BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> repository,
  }) : _repository = repository;

  static const String loadFailedCode = 'UNIT_CONVERSIONS_LOAD_FAILED';
  static const String loadFailedMessage = 'Não foi possível carregar as unidades de medida dos itens. Tente novamente.';
  static const int itemInBatchSize = 100;

  final BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> _repository;

  Future<List<SeparateItemUnidadeMedidaConsultationModel>> fetchForSeparation({
    required int codEmpresa,
    required int codSepararEstoque,
    Iterable<String> itemCodes = const [],
  }) async {
    try {
      final codes = itemCodes.toSet().where((item) => item.isNotEmpty).toList();
      if (codes.isEmpty) {
        return await _selectConversions(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque);
      }

      if (codes.length <= itemInBatchSize) {
        return await _selectConversions(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque, itemCodes: codes);
      }

      final units = <SeparateItemUnidadeMedidaConsultationModel>[];
      for (var offset = 0; offset < codes.length; offset += itemInBatchSize) {
        final end = offset + itemInBatchSize > codes.length ? codes.length : offset + itemInBatchSize;
        units.addAll(
          await _selectConversions(
            codEmpresa: codEmpresa,
            codSepararEstoque: codSepararEstoque,
            itemCodes: codes.sublist(offset, end),
          ),
        );
        if (end < codes.length) {
          await Future<void>.delayed(Duration.zero);
        }
      }
      return units;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Falha ao carregar conversoes de unidade paginadas.',
        tag: 'SeparateItemUnitConversions',
        error: e,
        stackTrace: stackTrace,
      );
      Error.throwWithStackTrace(
        DataFailure(message: loadFailedMessage, code: loadFailedCode, exception: e),
        stackTrace,
      );
    }
  }

  Future<List<SeparateItemUnidadeMedidaConsultationModel>> _selectConversions({
    required int codEmpresa,
    required int codSepararEstoque,
    List<String> itemCodes = const [],
  }) {
    final query = QueryBuilder()
      ..equals('CodEmpresa', codEmpresa)
      ..equals('CodSepararEstoque', codSepararEstoque);
    if (itemCodes.isNotEmpty) {
      query.inList('Item', itemCodes);
    }
    query.allRows(thenBy: ['ItemUnidadeMedida']);
    return _repository.selectConsultation(query);
  }

  /// Aguarda os itens e só então busca conversões.
  ///
  /// Lista vazia não dispara `separar.item.unidade.medida.consulta`. Esse
  /// `allRows` no isolate de UI travava o coletor (ANR) ao abrir um
  /// carrinho sem itens — típico de carrinho já fora de separação.
  Future<List<SeparateItemConsultationModel>> attachInParallel({
    required Future<List<SeparateItemConsultationModel>> itemsFuture,
    required int codEmpresa,
    required int codSepararEstoque,
  }) async {
    final items = await itemsFuture;
    if (items.isEmpty) {
      return items;
    }

    final units = await fetchForSeparation(
      codEmpresa: codEmpresa,
      codSepararEstoque: codSepararEstoque,
      itemCodes: [for (final item in items) item.item],
    );
    return merge(items, units);
  }

  Future<List<SeparateItemConsultationModel>> attachToItems({
    required List<SeparateItemConsultationModel> items,
    required int codEmpresa,
    required int codSepararEstoque,
  }) {
    if (items.isEmpty) {
      return Future<List<SeparateItemConsultationModel>>.value(items);
    }
    return attachInParallel(
      itemsFuture: Future<List<SeparateItemConsultationModel>>.value(items),
      codEmpresa: codEmpresa,
      codSepararEstoque: codSepararEstoque,
    );
  }

  static List<SeparateItemConsultationModel> merge(
    List<SeparateItemConsultationModel> items,
    List<SeparateItemUnidadeMedidaConsultationModel> units,
  ) {
    if (units.isEmpty) {
      return items;
    }

    final byItem = <String, List<SeparateItemUnidadeMedidaConsultationModel>>{};
    for (final unit in units) {
      final key = _itemKey(unit.item, unit.codProduto);
      (byItem[key] ??= <SeparateItemUnidadeMedidaConsultationModel>[]).add(unit);
    }

    return items.map((item) {
      final attached = byItem[_itemKey(item.item, item.codProduto)];
      if (attached == null || attached.isEmpty) {
        return item;
      }
      return item.copyWith(unidadeMedidas: attached);
    }).toList();
  }

  static String _itemKey(String item, int codProduto) => '$item|$codProduto';
}
