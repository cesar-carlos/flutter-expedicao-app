import 'dart:async';

import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/services/separate_item_unit_conversions_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_filters_controller.dart';

/// Responsável por carregar os itens filtrados do carrinho de picking.
///
/// Extraído de [CardPickingViewModel] (refator F9) para isolar:
/// - A montagem da query de filtros por empresa/estoque/setor.
/// - A consulta ao [BasicConsultationRepository].
/// - A aplicação dos filtros locais (via [PickingFiltersController]).
/// - A geração das unidades sintéticas por `codProduto` para scan, com o
///   cache por identidade da lista de entrada.
///
/// O ViewModel proprietário continua dono de `_items`/`_itemsUnmodifiable`,
/// da ordenação final e das notificações — este loader apenas devolve a
/// lista pronta para ser aplicada.
class PickingItemLoader {
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final SeparateItemUnitConversionsService _unitConversions;
  final PickingFiltersController _filtersController;

  // Cache simples por identidade da lista de entrada: evita refazer o
  // map + copyWith das unidades sintéticas quando a mesma lista é
  // reprocessada (ex.: resyncs em rajada que reusam a referência). Não
  // altera o resultado — só pula o recomputo quando a entrada é idêntica.
  List<SeparateItemConsultationModel>? _syntheticUnitsInput;
  List<SeparateItemConsultationModel>? _syntheticUnitsOutput;

  PickingItemLoader({
    required BasicConsultationRepository<SeparateItemConsultationModel> repository,
    required SeparateItemUnitConversionsService unitConversions,
    required PickingFiltersController filtersController,
  }) : _repository = repository,
       _unitConversions = unitConversions,
       _filtersController = filtersController;

  /// Busca os itens do carrinho aplicando o filtro de setor do usuário no
  /// servidor (quando houver), os filtros locais em memória e as unidades
  /// sintéticas para scan. Retorna lista vazia quando `cart` é nulo.
  Future<List<SeparateItemConsultationModel>> fetchFilteredItems({
    required ExpeditionCartRouteInternshipConsultationModel? cart,
    required int? userSectorCode,
    bool includeUnitConversions = true,
  }) async {
    if (cart == null) {
      return <SeparateItemConsultationModel>[];
    }

    final codEmpresa = cart.codEmpresa;
    final codSepararEstoque = cart.codOrigem;

    final itemsFuture = userSectorCode != null
        ? _fetchItemsForUserSector(
            codEmpresa: codEmpresa,
            codSepararEstoque: codSepararEstoque,
            userSectorCode: userSectorCode,
          )
        : _repository.selectConsultation(
            QueryBuilder()
              ..equals('CodEmpresa', codEmpresa)
              ..equals('CodSepararEstoque', codSepararEstoque)
              ..allRows(orderField: 'EnderecoDescricao', thenBy: ['Item']),
          );

    var items = includeUnitConversions
        ? await _unitConversions.attachInParallel(
            itemsFuture: itemsFuture,
            codEmpresa: codEmpresa,
            codSepararEstoque: codSepararEstoque,
          )
        : await itemsFuture;
    items = _filtersController.applyLocal(items);
    return _addSyntheticCodProdutoUnitsForScan(items);
  }

  /// O servidor AND-a as cláusulas de Where e rejeita SQL bruto, então o
  /// antigo `OR CodSetorEstoque IS NULL` vira duas consultas mescladas.
  Future<List<SeparateItemConsultationModel>> _fetchItemsForUserSector({
    required int codEmpresa,
    required int codSepararEstoque,
    required int userSectorCode,
  }) async {
    final bySector = QueryBuilder()
      ..equals('CodEmpresa', codEmpresa)
      ..equals('CodSepararEstoque', codSepararEstoque)
      ..equals('CodSetorEstoque', userSectorCode)
      ..allRows(orderField: 'EnderecoDescricao', thenBy: ['Item']);
    final withoutSector = QueryBuilder()
      ..equals('CodEmpresa', codEmpresa)
      ..equals('CodSepararEstoque', codSepararEstoque)
      ..isNull('CodSetorEstoque')
      ..allRows(orderField: 'EnderecoDescricao', thenBy: ['Item']);

    final assigned = await _repository.selectConsultation(bySector);
    await Future<void>.delayed(Duration.zero);
    final unassigned = await _repository.selectConsultation(withoutSector);
    return _mergeUniqueItems(assigned, unassigned);
  }

  List<SeparateItemConsultationModel> _mergeUniqueItems(
    List<SeparateItemConsultationModel> assigned,
    List<SeparateItemConsultationModel> unassigned,
  ) {
    final seen = <String>{};
    final merged = <SeparateItemConsultationModel>[];
    for (final item in [...assigned, ...unassigned]) {
      final key = '${item.item}|${item.codProduto}';
      if (seen.add(key)) {
        merged.add(item);
      }
    }
    return merged;
  }

  List<SeparateItemConsultationModel> _addSyntheticCodProdutoUnitsForScan(List<SeparateItemConsultationModel> items) {
    final cachedInput = _syntheticUnitsInput;
    final cachedOutput = _syntheticUnitsOutput;
    if (cachedInput != null && cachedOutput != null && identical(cachedInput, items)) {
      return cachedOutput;
    }

    final result = items.map((item) {
      final str = item.codProduto.toString();
      final alreadyHasUnit = item.unidadeMedidas.any((u) => u.codigoBarras?.trim() == str);
      if (alreadyHasUnit) return item;

      final SeparateItemUnidadeMedidaConsultationModel synthetic;
      if (item.unidadeMedidas.isNotEmpty) {
        final base = item.unidadeMedidas.first;
        synthetic = base.copyWith(
          codigoBarras: str,
          itemUnidadeMedida: '${base.itemUnidadeMedida}_cod${item.codProduto}',
          tipoFatorConversao: TipoFatorConversao.multiplicacao,
          fatorConversao: 1.0,
        );
      } else {
        synthetic = SeparateItemUnidadeMedidaConsultationModel(
          codEmpresa: item.codEmpresa,
          codSepararEstoque: item.codSepararEstoque,
          item: item.item,
          codProduto: item.codProduto,
          itemUnidadeMedida: '${item.item}_${item.codUnidadeMedida}_cod${item.codProduto}',
          codUnidadeMedida: item.codUnidadeMedida,
          unidadeMedidaDescricao: item.nomeUnidadeMedida,
          unidadeMedidaPadrao: Situation.inativo,
          tipoFatorConversao: TipoFatorConversao.multiplicacao,
          fatorConversao: 1.0,
          codigoBarras: str,
        );
      }
      return item.copyWith(unidadeMedidas: [...item.unidadeMedidas, synthetic]);
    }).toList();

    _syntheticUnitsInput = items;
    _syntheticUnitsOutput = result;
    return result;
  }
}
