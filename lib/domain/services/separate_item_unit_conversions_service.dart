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
/// O coletor busca `separar.item.unidade.medida.consulta` com `allRows`.
class SeparateItemUnitConversionsService {
  SeparateItemUnitConversionsService({
    required BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> repository,
  }) : _repository = repository;

  static const String loadFailedCode = 'UNIT_CONVERSIONS_LOAD_FAILED';
  static const String loadFailedMessage = 'Não foi possível carregar as unidades de medida dos itens. Tente novamente.';

  final BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> _repository;

  Future<List<SeparateItemUnidadeMedidaConsultationModel>> fetchForSeparation({
    required int codEmpresa,
    required int codSepararEstoque,
  }) async {
    try {
      return await _repository.selectConsultation(
        QueryBuilder()
          ..equals('CodEmpresa', codEmpresa)
          ..equals('CodSepararEstoque', codSepararEstoque)
          ..allRows(thenBy: ['ItemUnidadeMedida']),
      );
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

  /// Dispara a lista de itens e as conversões ao mesmo tempo.
  Future<List<SeparateItemConsultationModel>> attachInParallel({
    required Future<List<SeparateItemConsultationModel>> itemsFuture,
    required int codEmpresa,
    required int codSepararEstoque,
  }) async {
    try {
      final (items, units) = await (
        itemsFuture,
        fetchForSeparation(codEmpresa: codEmpresa, codSepararEstoque: codSepararEstoque),
      ).wait;
      if (items.isEmpty) {
        return items;
      }
      return merge(items, units);
    } on ParallelWaitError catch (error) {
      return _rethrowFirstParallelError(error);
    }
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

  static Never _rethrowFirstParallelError(ParallelWaitError<dynamic, dynamic> error) {
    final errors = error.errors;
    if (errors is (AsyncError?, AsyncError?)) {
      final first = errors.$1 ?? errors.$2;
      if (first != null) {
        Error.throwWithStackTrace(first.error, first.stackTrace);
      }
    }
    throw error;
  }
}
