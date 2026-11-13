import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/services/separate_item_unit_conversions_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_filters_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_item_loader.dart';

void main() {
  group('PickingItemLoader', () {
    test('should fetch sector item queries one after another', () async {
      var inFlight = 0;
      var maxInFlight = 0;
      final itemRepository = _FakeItemRepository((_) async {
        inFlight += 1;
        if (inFlight > maxInFlight) {
          maxInFlight = inFlight;
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
        inFlight -= 1;
        return const <SeparateItemConsultationModel>[];
      });
      final loader = PickingItemLoader(
        repository: itemRepository,
        unitConversions: SeparateItemUnitConversionsService(repository: _FakeUnitRepository((_) async => const [])),
        filtersController: PickingFiltersController(storage: _FakeFiltersStorage()),
      );

      await loader.fetchFilteredItems(cart: _buildCart(), userSectorCode: 1, includeUnitConversions: false);

      expect(itemRepository.selectCallCount, 2);
      expect(maxInFlight, 1);
    });
  });
}

class _FakeItemRepository implements BasicConsultationRepository<SeparateItemConsultationModel> {
  _FakeItemRepository(this.onSelect);

  final Future<List<SeparateItemConsultationModel>> Function(QueryBuilder query) onSelect;
  int selectCallCount = 0;

  @override
  Future<List<SeparateItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    selectCallCount += 1;
    return onSelect(queryBuilder);
  }
}

class _FakeUnitRepository implements BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> {
  _FakeUnitRepository(this.onSelect);

  final Future<List<SeparateItemUnidadeMedidaConsultationModel>> Function(QueryBuilder query) onSelect;

  @override
  Future<List<SeparateItemUnidadeMedidaConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return onSelect(queryBuilder);
  }
}

class _FakeFiltersStorage implements IFiltersStorageService {
  @override
  Future<void> clearCartsFilters() async {}

  @override
  Future<void> clearPendingProductsFilters() async {}

  @override
  Future<void> clearSeparateItemsFilters() async {}

  @override
  Future<void> clearSeparationFilters() async {}

  @override
  Future<bool> hasSavedCartsFilters() async => false;

  @override
  Future<bool> hasSavedPendingProductsFilters() async => false;

  @override
  Future<bool> hasSavedSeparateItemsFilters() async => false;

  @override
  Future<bool> hasSavedSeparationFilters() async => false;

  @override
  Future<CartsFiltersModel> loadCartsFilters() async => const CartsFiltersModel();

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async => null;

  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async => const SeparateItemsFiltersModel();

  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async => const SeparationFiltersModel();

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {}

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {}

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {}

  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {}
}

ExpeditionCartRouteInternshipConsultationModel _buildCart() {
  return ExpeditionCartRouteInternshipConsultationModel(
    codEmpresa: 1,
    codCarrinhoPercurso: 200,
    item: '1',
    codPercursoEstagio: 1,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 123,
    situacao: ExpeditionSituation.separando,
    carrinhoAgrupador: Situation.inativo,
    codCarrinho: 100,
    nomeCarrinho: 'Carrinho 100',
    codigoBarrasCarrinho: 'BC100',
    ativo: Situation.ativo,
    codUsuarioInicio: 10,
    nomeUsuarioInicio: 'Usuario',
    dataInicio: DateTime(2026, 5, 6, 10),
    horaInicio: '10:00:00',
  );
}
