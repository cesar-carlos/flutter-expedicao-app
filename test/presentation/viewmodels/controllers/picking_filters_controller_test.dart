import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_filters_controller.dart';

void main() {
  late _FakeFiltersStorage storage;
  late int onChangedCalls;
  late PickingFiltersController controller;

  setUp(() {
    storage = _FakeFiltersStorage();
    onChangedCalls = 0;
    controller = PickingFiltersController(
      storage: storage,
      onChanged: () => onChangedCalls++,
    );
  });

  group('PickingFiltersController - estado e persistencia', () {
    test('comeca vazio e sem filtros ativos', () {
      expect(controller.current.isEmpty, isTrue);
      expect(controller.hasActive, isFalse);
    });

    test('apply atualiza estado, persiste e dispara onChanged', () async {
      final filters = const PendingProductsFiltersModel(nomeProduto: 'parafuso');

      await controller.apply(filters);

      expect(controller.current, equals(filters));
      expect(controller.hasActive, isTrue);
      expect(storage.savedCalls.length, equals(1));
      expect(storage.savedCalls.first, equals(filters));
      expect(onChangedCalls, equals(1));
    });

    test('clear reseta estado, remove persistencia e dispara onChanged', () async {
      await controller.apply(const PendingProductsFiltersModel(codProduto: '999'));
      onChangedCalls = 0;

      await controller.clear();

      expect(controller.current.isEmpty, isTrue);
      expect(storage.clearCalls, equals(1));
      expect(onChangedCalls, equals(1));
    });

    test('loadSaved carrega filtros do storage e dispara onChanged se mudou', () async {
      storage.stored = const PendingProductsFiltersModel(codigoBarras: '789');

      await controller.loadSaved();

      expect(controller.current, equals(const PendingProductsFiltersModel(codigoBarras: '789')));
      expect(onChangedCalls, equals(1));
    });

    test('loadSaved nao dispara onChanged se filtros sao iguais', () async {
      storage.stored = const PendingProductsFiltersModel();
      await controller.loadSaved();
      expect(onChangedCalls, equals(0));
    });

    test('loadSaved sem nada persistido nao altera estado', () async {
      storage.stored = null;
      await controller.loadSaved();
      expect(controller.current.isEmpty, isTrue);
      expect(onChangedCalls, equals(0));
    });

    test('erros do storage no apply/clear sao silenciados (logs only)', () async {
      storage.shouldThrow = true;
      // Nao deve lancar
      await controller.apply(const PendingProductsFiltersModel(codProduto: 'x'));
      await controller.clear();
      await controller.loadSaved();
    });
  });

  group('PickingFiltersController.applyLocal - filtragem em memoria', () {
    test('sem filtros: retorna a lista original (mesma instancia)', () {
      final items = [_buildItem(item: '1'), _buildItem(item: '2')];
      final result = controller.applyLocal(items);
      expect(identical(result, items), isTrue);
    });

    test('filtra por codProduto (substring)', () async {
      await controller.apply(const PendingProductsFiltersModel(codProduto: '99'));
      final items = [
        _buildItem(item: '1', codProduto: 100), // "100" nao contem "99"
        _buildItem(item: '2', codProduto: 999), // "999" contem "99"
        _buildItem(item: '3', codProduto: 990), // "990" contem "99"
        _buildItem(item: '4', codProduto: 200),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['2', '3']));
    });

    test('filtra por codigoBarras (substring case-insensitive)', () async {
      await controller.apply(const PendingProductsFiltersModel(codigoBarras: 'ABC'));
      final items = [
        _buildItem(item: '1', codigoBarras: 'XYZ123'),
        _buildItem(item: '2', codigoBarras: 'abc456'),
        _buildItem(item: '3', codigoBarras: null),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['2']));
    });

    test('filtra por nomeProduto (substring case-insensitive)', () async {
      await controller.apply(const PendingProductsFiltersModel(nomeProduto: 'PaRa'));
      final items = [
        _buildItem(item: '1', nomeProduto: 'Parafuso'),
        _buildItem(item: '2', nomeProduto: 'Porca'),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['1']));
    });

    test('filtra por enderecoDescricao', () async {
      await controller.apply(const PendingProductsFiltersModel(enderecoDescricao: '01'));
      final items = [
        _buildItem(item: '1', enderecoDescricao: '01-A'),
        _buildItem(item: '2', enderecoDescricao: '02-B'),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['1']));
    });

    test('filtra por setorEstoque (igualdade exata de codSetorEstoque)', () async {
      await controller.apply(PendingProductsFiltersModel(setorEstoque: _buildSector(codSetorEstoque: 5)));
      final items = [
        _buildItem(item: '1', codSetorEstoque: 5),
        _buildItem(item: '2', codSetorEstoque: 99),
        _buildItem(item: '3', codSetorEstoque: null),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['1']));
    });

    test('combina multiplos filtros (AND logico)', () async {
      await controller.apply(const PendingProductsFiltersModel(nomeProduto: 'parafuso', enderecoDescricao: '01'));
      final items = [
        _buildItem(item: '1', nomeProduto: 'Parafuso CG', enderecoDescricao: '01-A'),
        _buildItem(item: '2', nomeProduto: 'Parafuso Roda', enderecoDescricao: '02-B'),
        _buildItem(item: '3', nomeProduto: 'Porca', enderecoDescricao: '01-C'),
      ];
      final result = controller.applyLocal(items);
      expect(result.map((i) => i.item), equals(['1']));
    });
  });
}

SeparateItemConsultationModel _buildItem({
  String item = '1',
  int codProduto = 10,
  String nomeProduto = 'Produto',
  String? codigoBarras = '7891234567890',
  String? enderecoDescricao,
  int? codSetorEstoque,
}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 100,
    item: item,
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 100,
    codProduto: codProduto,
    nomeProduto: nomeProduto,
    ativo: Situation.ativo,
    codTipoProduto: '1',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codSetorEstoque: codSetorEstoque,
    codigoBarras: codigoBarras,
    enderecoDescricao: enderecoDescricao,
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Local',
    quantidade: 10,
    quantidadeInterna: 10,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: const [],
  );
}

ExpeditionSectorStockModel _buildSector({required int codSetorEstoque}) {
  return ExpeditionSectorStockModel(
    codSetorEstoque: codSetorEstoque,
    descricao: 'Setor $codSetorEstoque',
    ativo: Situation.ativo,
  );
}

class _FakeFiltersStorage implements IFiltersStorageService {
  PendingProductsFiltersModel? stored;
  bool shouldThrow = false;
  final List<PendingProductsFiltersModel> savedCalls = [];
  int clearCalls = 0;

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async {
    if (shouldThrow) throw Exception('boom');
    return stored;
  }

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {
    if (shouldThrow) throw Exception('boom');
    savedCalls.add(filters);
    stored = filters;
  }

  @override
  Future<void> clearPendingProductsFilters() async {
    if (shouldThrow) throw Exception('boom');
    clearCalls++;
    stored = null;
  }

  @override
  Future<bool> hasSavedPendingProductsFilters() async => stored != null;

  // Demais metodos da interface nao usados no controller — implementacao no-op.
  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {}
  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async => const SeparationFiltersModel();
  @override
  Future<void> clearSeparationFilters() async {}
  @override
  Future<bool> hasSavedSeparationFilters() async => false;

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {}
  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async => const SeparateItemsFiltersModel();
  @override
  Future<void> clearSeparateItemsFilters() async {}
  @override
  Future<bool> hasSavedSeparateItemsFilters() async => false;

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {}
  @override
  Future<CartsFiltersModel> loadCartsFilters() async => const CartsFiltersModel();
  @override
  Future<void> clearCartsFilters() async {}
  @override
  Future<bool> hasSavedCartsFilters() async => false;
}
