import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';

class FakeConsultationRepository<T> implements BasicConsultationRepository<T> {
  FakeConsultationRepository({required this.onSelect});

  Future<List<T>> Function(QueryBuilder queryBuilder) onSelect;
  int selectCallCount = 0;

  @override
  Future<List<T>> selectConsultation(QueryBuilder queryBuilder) {
    selectCallCount += 1;
    return onSelect(queryBuilder);
  }
}

class FakeBasicRepository<T> implements BasicRepository<T> {
  FakeBasicRepository({Future<List<T>> Function(QueryBuilder queryBuilder)? onSelect})
    : onSelect = onSelect ?? ((_) async => <T>[]);

  Future<List<T>> Function(QueryBuilder queryBuilder) onSelect;

  @override
  Future<List<T>> delete(T entity) async => <T>[];

  @override
  Future<List<T>> insert(T entity) async => <T>[];

  @override
  Future<List<T>> select(QueryBuilder queryBuilder) => onSelect(queryBuilder);

  @override
  Future<List<T>> update(T entity) async => <T>[];
}

class FakeFiltersStorageService implements IFiltersStorageService {
  SeparateItemsFiltersModel separateItemsFilters = const SeparateItemsFiltersModel();
  CartsFiltersModel cartsFilters = const CartsFiltersModel();

  @override
  Future<void> clearCartsFilters() async {
    cartsFilters = const CartsFiltersModel();
  }

  @override
  Future<void> clearPendingProductsFilters() async {}

  @override
  Future<void> clearSeparateItemsFilters() async {
    separateItemsFilters = const SeparateItemsFiltersModel();
  }

  @override
  Future<void> clearSeparationFilters() async {}

  @override
  Future<bool> hasSavedCartsFilters() async => cartsFilters.isNotEmpty;

  @override
  Future<bool> hasSavedPendingProductsFilters() async => false;

  @override
  Future<bool> hasSavedSeparateItemsFilters() async => separateItemsFilters.isNotEmpty;

  @override
  Future<bool> hasSavedSeparationFilters() async => false;

  @override
  Future<CartsFiltersModel> loadCartsFilters() async => cartsFilters;

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async => null;

  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async => separateItemsFilters;

  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async => const SeparationFiltersModel();

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {
    cartsFilters = filters;
  }

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {}

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {
    separateItemsFilters = filters;
  }

  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {}
}

class FakeSeparateCartInternshipEventRepository implements SeparateCartInternshipEventRepository {
  final List<EventListenerModel> _listeners = <EventListenerModel>[];

  @override
  void addListener(EventListenerModel listener) {
    _listeners.removeWhere((existing) => existing.id == listener.id);
    _listeners.add(listener);
  }

  @override
  void dispose() {
    _listeners.clear();
  }

  void emit(BasicEventModel event) {
    final activeListeners = List<EventListenerModel>.from(_listeners);
    for (final listener in activeListeners) {
      if (listener.event == event.eventType) {
        listener.callback(event);
      }
    }
  }

  @override
  EventListenerModel? getListenerById(String listenerId) {
    for (final listener in _listeners) {
      if (listener.id == listenerId) {
        return listener;
      }
    }
    return null;
  }

  @override
  bool hasListener(String listenerId) => _listeners.any((listener) => listener.id == listenerId);

  @override
  List<EventListenerModel> get listeners => List<EventListenerModel>.unmodifiable(_listeners);

  @override
  void removeAllListeners() {
    _listeners.clear();
  }

  @override
  void removeListener(String listenerId) {
    _listeners.removeWhere((listener) => listener.id == listenerId);
  }

  @override
  void removeListeners(List<String> listenerIds) {
    _listeners.removeWhere((listener) => listenerIds.contains(listener.id));
  }
}

void main() {
  SeparateConsultationModel buildSeparation({int codSepararEstoque = 123}) {
    return SeparateConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: codSepararEstoque,
      origem: ExpeditionOrigem.orcamentoBalcao,
      codOrigem: 10,
      codTipoOperacaoExpedicao: 20,
      nomeTipoOperacaoExpedicao: 'Entrega Balcao',
      situacao: ExpeditionSituation.aguardando,
      tipoEntidade: EntityType.cliente,
      dataEmissao: DateTime(2026, 5, 6),
      horaEmissao: '10:00:00',
      codEntidade: 99,
      nomeEntidade: 'Cliente Teste',
      codPrioridade: 1,
      nomePrioridade: 'PRIORIDADE 1',
      codSetoresEstoque: const <int>[1],
      codUsuariosSeparacao: const <int>[7],
    );
  }

  SeparateItemConsultationModel buildItem({int codSepararEstoque = 123, int codProduto = 1}) {
    return SeparateItemConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: codSepararEstoque,
      item: '1',
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: codSepararEstoque,
      codProduto: codProduto,
      nomeProduto: 'Produto $codProduto',
      ativo: Situation.ativo,
      codTipoProduto: 'P',
      codUnidadeMedida: 'UN',
      nomeUnidadeMedida: 'Unidade',
      codGrupoProduto: 1,
      nomeGrupoProduto: 'Grupo',
      codSetorEstoque: 1,
      nomeSetorEstoque: 'Setor',
      codLocalArmazenagem: 1,
      nomeLocaArmazenagem: 'Endereco',
      quantidade: 10,
      quantidadeInterna: 10,
      quantidadeExterna: 0,
      quantidadeSeparacao: 0,
      unidadeMedidas: const [],
    );
  }

  ExpeditionCartRouteInternshipConsultationModel buildCart({
    int codOrigem = 123,
    int codCarrinho = 100,
    int codCarrinhoPercurso = 200,
    String item = '1',
    ExpeditionSituation situacao = ExpeditionSituation.aguardando,
  }) {
    return ExpeditionCartRouteInternshipConsultationModel(
      codEmpresa: 1,
      codCarrinhoPercurso: codCarrinhoPercurso,
      item: item,
      codPercursoEstagio: 1,
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: codOrigem,
      situacao: situacao,
      carrinhoAgrupador: Situation.inativo,
      codCarrinho: codCarrinho,
      nomeCarrinho: 'Carrinho $codCarrinho',
      codigoBarrasCarrinho: 'BC$codCarrinho',
      ativo: Situation.ativo,
      codUsuarioInicio: 10,
      nomeUsuarioInicio: 'Usuario',
      dataInicio: DateTime(2026, 5, 6, 10),
      horaInicio: '10:00:00',
      codSetorEstoque: 1,
      nomeSetorEstoque: 'Setor',
    );
  }

  group('SeparationItemsViewModel', () {
    late FakeConsultationRepository<SeparateItemConsultationModel> itemRepository;
    late FakeConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> cartRepository;
    late FakeBasicRepository<ExpeditionSectorStockModel> sectorStockRepository;
    late FakeFiltersStorageService filtersStorage;
    late FakeSeparateCartInternshipEventRepository eventRepository;
    late SeparationItemsViewModel viewModel;

    setUp(() {
      itemRepository = FakeConsultationRepository<SeparateItemConsultationModel>(
        onSelect: (_) async => <SeparateItemConsultationModel>[],
      );
      cartRepository = FakeConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>(
        onSelect: (_) async => <ExpeditionCartRouteInternshipConsultationModel>[],
      );
      sectorStockRepository = FakeBasicRepository<ExpeditionSectorStockModel>();
      filtersStorage = FakeFiltersStorageService();
      eventRepository = FakeSeparateCartInternshipEventRepository();

      viewModel = SeparationItemsViewModel.withDependencies(
        itemRepository,
        cartRepository,
        sectorStockRepository,
        filtersStorage,
        eventRepository,
      );
    });

    tearDown(() {
      viewModel.dispose();
      eventRepository.dispose();
    });

    test('resyncVisibleDataSilently updates carts without entering loading state', () async {
      final separation = buildSeparation();
      final item = buildItem();
      final firstCart = buildCart();
      final newerCart = buildCart(codCarrinho: 101, codCarrinhoPercurso: 201);

      itemRepository.onSelect = (_) async => <SeparateItemConsultationModel>[item];

      var cartCallCount = 0;
      cartRepository.onSelect = (_) async {
        cartCallCount += 1;
        if (cartCallCount == 1) {
          return <ExpeditionCartRouteInternshipConsultationModel>[firstCart];
        }
        return <ExpeditionCartRouteInternshipConsultationModel>[newerCart, firstCart];
      };

      await viewModel.loadSeparationItems(separation);
      await viewModel.loadSeparationCarts(separation);

      expect(viewModel.state, SeparateItemsState.loaded);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.carts, hasLength(1));

      await viewModel.resyncVisibleDataSilently();

      expect(viewModel.state, SeparateItemsState.loaded);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.carts.first.codCarrinho, 101);
      expect(viewModel.carts, hasLength(2));
    });

    test('cart event performs authoritative resync and removes stale carts that moved away', () async {
      final separation = buildSeparation();
      final item = buildItem();
      final existingCart = buildCart();

      itemRepository.onSelect = (_) async => <SeparateItemConsultationModel>[item];

      var cartResponses = <List<ExpeditionCartRouteInternshipConsultationModel>>[
        <ExpeditionCartRouteInternshipConsultationModel>[existingCart],
        <ExpeditionCartRouteInternshipConsultationModel>[],
      ];

      cartRepository.onSelect = (_) async {
        final next = cartResponses.first;
        if (cartResponses.length > 1) {
          cartResponses = cartResponses.sublist(1);
        }
        return next;
      };

      await viewModel.loadSeparationItems(separation);
      await viewModel.loadSeparationCarts(separation);
      viewModel.startCartEventMonitoring();

      eventRepository.emit(
        BasicEventModel(
          timestamp: DateTime.now(),
          eventType: Event.update,
          data: <String, dynamic>{
            'Mutation': <Map<String, dynamic>>[buildCart(codOrigem: 999).toJson()],
          },
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.carts, isEmpty);
    });

    test('cart event ignores unrelated carts from another separation', () async {
      final separation = buildSeparation();
      final item = buildItem();
      final existingCart = buildCart();

      itemRepository.onSelect = (_) async => <SeparateItemConsultationModel>[item];
      cartRepository.onSelect = (_) async => <ExpeditionCartRouteInternshipConsultationModel>[existingCart];

      await viewModel.loadSeparationItems(separation);
      await viewModel.loadSeparationCarts(separation);
      viewModel.startCartEventMonitoring();

      eventRepository.emit(
        BasicEventModel(
          timestamp: DateTime.now(),
          eventType: Event.insert,
          data: <String, dynamic>{
            'Mutation': <Map<String, dynamic>>[
              buildCart(codOrigem: 999, codCarrinho: 888, codCarrinhoPercurso: 999).toJson(),
            ],
          },
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cartRepository.selectCallCount, 1);
      expect(viewModel.carts, hasLength(1));
      expect(viewModel.carts.first.codCarrinho, existingCart.codCarrinho);
    });
  });
}
