import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';

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
  PendingProductsFiltersModel pendingProductsFilters = const PendingProductsFiltersModel();

  @override
  Future<void> clearCartsFilters() async {}

  @override
  Future<void> clearPendingProductsFilters() async {
    pendingProductsFilters = const PendingProductsFiltersModel();
  }

  @override
  Future<void> clearSeparateItemsFilters() async {}

  @override
  Future<void> clearSeparationFilters() async {}

  @override
  Future<bool> hasSavedCartsFilters() async => false;

  @override
  Future<bool> hasSavedPendingProductsFilters() async => pendingProductsFilters.isNotEmpty;

  @override
  Future<bool> hasSavedSeparateItemsFilters() async => false;

  @override
  Future<bool> hasSavedSeparationFilters() async => false;

  @override
  Future<CartsFiltersModel> loadCartsFilters() async => const CartsFiltersModel();

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async => pendingProductsFilters;

  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async => const SeparateItemsFiltersModel();

  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async => const SeparationFiltersModel();

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {}

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {
    pendingProductsFilters = filters;
  }

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {}

  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {}
}

class FakeUserSessionService implements IUserSessionService {
  AppUser? session;

  @override
  Future<void> clearUserSession() async {
    session = null;
  }

  @override
  Future<bool> hasActiveSession() async => session != null;

  @override
  Future<bool> isUserLoggedIn() async => session != null;

  @override
  Future<AppUser?> loadUserSession() async => session;

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    session = appUser;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    session = appUser;
  }
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
      if (listener.listensTo(event.eventType)) {
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

class QueuedAddItemSeparationUseCase extends AddItemSeparationUseCase {
  QueuedAddItemSeparationUseCase()
    : super(
        separateItemRepository: FakeBasicRepository<SeparateItemModel>(),
        separationItemRepository: FakeBasicRepository<SeparationItemModel>(),
        userSessionService: FakeUserSessionService(),
      );

  final List<Completer<Result<AddItemSeparationSuccess>>> pendingResponses =
      <Completer<Result<AddItemSeparationSuccess>>>[];
  int callCount = 0;

  @override
  Future<Result<AddItemSeparationSuccess>> call(AddItemSeparationParams params, {UserSystemModel? userSystem}) {
    callCount += 1;
    if (pendingResponses.isEmpty) {
      return Future<Result<AddItemSeparationSuccess>>.value(buildSuccess(params));
    }

    return pendingResponses.removeAt(0).future;
  }

  Result<AddItemSeparationSuccess> buildSuccess(AddItemSeparationParams params) {
    return Success(
      AddItemSeparationSuccess.create(
        createdSeparationItem: SeparationItemModel(
          codEmpresa: params.codEmpresa,
          codSepararEstoque: params.codSepararEstoque,
          item: params.itemSepararEstoque,
          sessionId: params.sessionId,
          situacao: ExpeditionItemSituation.separado,
          codCarrinhoPercurso: params.codCarrinhoPercurso,
          itemCarrinhoPercurso: params.itemCarrinhoPercurso,
          codSeparador: params.codSeparador,
          nomeSeparador: params.nomeSeparador,
          dataSeparacao: DateTime(2026, 5, 21, 10),
          horaSeparacao: '10:00:00',
          codProduto: params.codProduto,
          codUnidadeMedida: params.codUnidadeMedida,
          quantidade: params.quantidade,
        ),
        updatedSeparateItem: SeparateItemModel(
          codEmpresa: params.codEmpresa,
          codSepararEstoque: params.codSepararEstoque,
          item: params.itemSepararEstoque,
          origem: ExpeditionOrigem.separacaoEstoque,
          codOrigem: params.codSepararEstoque,
          codLocalArmazenagem: 1,
          codProduto: params.codProduto,
          codUnidadeMedida: params.codUnidadeMedida,
          quantidade: 10,
          quantidadeInterna: 10,
          quantidadeExterna: 0,
          quantidadeSeparacao: params.quantidade,
        ),
        addedQuantity: params.quantidade,
      ),
    );
  }
}

AddItemSeparationUseCase buildAddItemUseCase(FakeUserSessionService userSessionService) {
  return AddItemSeparationUseCase(
    separateItemRepository: FakeBasicRepository<SeparateItemModel>(),
    separationItemRepository: FakeBasicRepository<SeparationItemModel>(),
    userSessionService: userSessionService,
  );
}

SaveSeparationCartUseCase buildSaveCartUseCase(FakeUserSessionService userSessionService) {
  return SaveSeparationCartUseCase(
    cartRouteInternshipRepository: FakeBasicRepository<ExpeditionCartRouteInternshipModel>(),
    separationItemConsultationRepository: FakeConsultationRepository<SeparationItemConsultationModel>(
      onSelect: (_) async => <SeparationItemConsultationModel>[],
    ),
    separateItemRepository: FakeConsultationRepository<SeparateItemConsultationModel>(
      onSelect: (_) async => <SeparateItemConsultationModel>[],
    ),
    separateProgressRepository: FakeConsultationRepository<SeparateProgressConsultationModel>(
      onSelect: (_) async => <SeparateProgressConsultationModel>[],
    ),
    separationItemModelRepository: FakeBasicRepository<SeparationItemModel>(),
    cartRepository: FakeBasicRepository<ExpeditionCartModel>(),
    userSessionService: userSessionService,
  );
}

void main() {
  ExpeditionCartRouteInternshipConsultationModel buildCart({
    int codOrigem = 123,
    int codCarrinhoPercurso = 200,
    String item = '1',
    ExpeditionSituation situacao = ExpeditionSituation.separando,
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
      codCarrinho: 100,
      nomeCarrinho: 'Carrinho 100',
      codigoBarrasCarrinho: 'BC100',
      ativo: Situation.ativo,
      codUsuarioInicio: 10,
      nomeUsuarioInicio: 'Usuario',
      dataInicio: DateTime(2026, 5, 6, 10),
      horaInicio: '10:00:00',
      codSetorEstoque: 1,
      nomeSetorEstoque: 'Setor 1',
    );
  }

  SeparateItemConsultationModel buildPendingItem({
    String item = '1',
    int codProduto = 1,
    int? codSetorEstoque = 1,
    double quantidadeSeparacao = 0,
  }) {
    return SeparateItemConsultationModel(
      codEmpresa: 1,
      codSepararEstoque: 123,
      item: item,
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: 123,
      codProduto: codProduto,
      nomeProduto: 'Produto $codProduto',
      ativo: Situation.ativo,
      codTipoProduto: 'P',
      codUnidadeMedida: 'UN',
      nomeUnidadeMedida: 'Unidade',
      codGrupoProduto: 1,
      nomeGrupoProduto: 'Grupo',
      codSetorEstoque: codSetorEstoque,
      nomeSetorEstoque: codSetorEstoque == null ? null : 'Setor $codSetorEstoque',
      endereco: 'A1',
      enderecoDescricao: 'A1',
      codLocalArmazenagem: 1,
      nomeLocaArmazenagem: 'Endereco',
      quantidade: 10,
      quantidadeInterna: 10,
      quantidadeExterna: 0,
      quantidadeSeparacao: quantidadeSeparacao,
      unidadeMedidas: const <SeparateItemUnidadeMedidaConsultationModel>[],
    );
  }

  UserSystemModel buildUserModel({int? codSetorEstoque = 1}) {
    return UserSystemModel(
      codUsuario: 10,
      nomeUsuario: 'Usuario',
      ativo: Situation.ativo,
      codEmpresa: 1,
      codSetorEstoque: codSetorEstoque,
      nomeSetorEstoque: codSetorEstoque == null ? null : 'Setor $codSetorEstoque',
      permiteSepararForaSequencia: Situation.ativo,
      visualizaTodasSeparacoes: Situation.ativo,
      expedicaoObrigaEscanearPrateleira: Situation.inativo,
      permiteConferirForaSequencia: Situation.inativo,
      visualizaTodasConferencias: Situation.inativo,
      permiteArmazenarForaSequencia: Situation.inativo,
      visualizaTodasArmazenagem: Situation.inativo,
      editaCarrinhoOutroUsuario: Situation.ativo,
      salvaCarrinhoOutroUsuario: Situation.ativo,
      excluiCarrinhoOutroUsuario: Situation.ativo,
      expedicaoEntregaBalcaoPreVenda: Situation.inativo,
    );
  }

  group('CardPickingViewModel', () {
    late FakeConsultationRepository<SeparateItemConsultationModel> repository;
    late FakeBasicRepository<ExpeditionSectorStockModel> sectorStockRepository;
    late FakeFiltersStorageService filtersStorage;
    late FakeUserSessionService userSessionService;
    late FakeSeparateCartInternshipEventRepository eventRepository;
    late CardPickingViewModel viewModel;

    setUp(() {
      repository = FakeConsultationRepository<SeparateItemConsultationModel>(
        onSelect: (_) async => <SeparateItemConsultationModel>[],
      );
      sectorStockRepository = FakeBasicRepository<ExpeditionSectorStockModel>();
      filtersStorage = FakeFiltersStorageService();
      userSessionService = FakeUserSessionService();
      eventRepository = FakeSeparateCartInternshipEventRepository();

      viewModel = CardPickingViewModel.withDependencies(
        repository: repository,
        sectorStockRepository: sectorStockRepository,
        filtersStorage: filtersStorage,
        addItemSeparationUseCase: buildAddItemUseCase(userSessionService),
        saveSeparationCartUseCase: buildSaveCartUseCase(userSessionService),
        userSessionService: userSessionService,
        cartEventRepository: eventRepository,
        shelfScanningService: ShelfScanningService(),
        stateManager: PickingStateManager(),
        cartValidationService: CartValidationService(repository: repository),
      );
    });

    tearDown(() {
      viewModel.dispose();
      eventRepository.dispose();
    });

    test('resyncVisibleDataSilently updates items without entering loading state', () async {
      final cart = buildCart();
      final firstItem = buildPendingItem(item: '1', codProduto: 1);
      final secondItem = buildPendingItem(item: '2', codProduto: 2);

      var callCount = 0;
      repository.onSelect = (_) async {
        callCount += 1;
        if (callCount == 1) {
          return <SeparateItemConsultationModel>[firstItem];
        }
        return <SeparateItemConsultationModel>[firstItem, secondItem];
      };

      await viewModel.initializeCart(cart, userModel: buildUserModel());
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.items, hasLength(1));

      await viewModel.resyncVisibleDataSilently();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.items, hasLength(2));
    });

    test('cart event for current cart triggers authoritative resync even when status is unchanged', () async {
      final cart = buildCart(situacao: ExpeditionSituation.separando);
      final firstItem = buildPendingItem(item: '1', codProduto: 1);
      final secondItem = buildPendingItem(item: '2', codProduto: 2);

      var callCount = 0;
      repository.onSelect = (_) async {
        callCount += 1;
        if (callCount == 1) {
          return <SeparateItemConsultationModel>[firstItem];
        }
        return <SeparateItemConsultationModel>[firstItem, secondItem];
      };

      await viewModel.initializeCart(cart, userModel: buildUserModel());

      eventRepository.emit(
        BasicEventModel(
          timestamp: DateTime.now(),
          eventType: Event.update,
          data: <String, dynamic>{
            'Mutation': <Map<String, dynamic>>[buildCart().toJson()],
          },
        ),
      );

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.items, hasLength(2));
      expect(viewModel.hasCartStatusChanged, isFalse);
      expect(repository.selectCallCount, 2);
    });

    test('retry preserves the current user context when reloading items', () async {
      final cart = buildCart();
      final allowedItem = buildPendingItem(item: '1', codProduto: 1, codSetorEstoque: 1);
      final hiddenItem = buildPendingItem(item: '2', codProduto: 2, codSetorEstoque: 99);

      repository.onSelect = (queryBuilder) async {
        final where = queryBuilder.buildSqlWhere();
        if (where.contains('CodSetorEstoque = 1 OR CodSetorEstoque IS NULL')) {
          return <SeparateItemConsultationModel>[allowedItem];
        }
        return <SeparateItemConsultationModel>[allowedItem, hiddenItem];
      };

      await viewModel.initializeCart(cart, userModel: buildUserModel(codSetorEstoque: 1));
      expect(viewModel.items, hasLength(1));
      expect(viewModel.items.first.codProduto, 1);

      await viewModel.retry();

      expect(viewModel.items, hasLength(1));
      expect(viewModel.items.first.codProduto, 1);
    });

    test('updatePickedQuantityWithSync rejects quantity reductions that cannot be persisted', () async {
      final cart = buildCart();
      final item = buildPendingItem(item: '1', codProduto: 1);

      repository.onSelect = (_) async => <SeparateItemConsultationModel>[item];

      await viewModel.initializeCart(cart, userModel: buildUserModel());
      viewModel.updatePickedQuantity(item.item, 5);

      final result = await viewModel.updatePickedQuantityWithSync(item.item, 3);

      expect(result.isSuccess, isFalse);
      expect(result.message, contains('não é suportada'));
      expect(viewModel.getPickedQuantity(item.item), 5);
    });

    test('user-sector reload pushes sector filtering to the server query', () async {
      final cart = buildCart();
      final item = buildPendingItem(item: '1', codProduto: 1, codSetorEstoque: 1);
      var capturedWhere = '';

      repository.onSelect = (queryBuilder) async {
        capturedWhere = queryBuilder.buildSqlWhere();
        return <SeparateItemConsultationModel>[item];
      };

      await viewModel.initializeCart(cart, userModel: buildUserModel(codSetorEstoque: 1));

      expect(capturedWhere, contains('CodSetorEstoque = 1 OR CodSetorEstoque IS NULL'));
      expect(viewModel.items, hasLength(1));
    });

    test('switching scanned items does not wait for pending operations or trigger a full refresh', () async {
      final queuedAddUseCase = QueuedAddItemSeparationUseCase();
      final firstPendingResponse = Completer<Result<AddItemSeparationSuccess>>();
      final secondPendingResponse = Completer<Result<AddItemSeparationSuccess>>();
      queuedAddUseCase.pendingResponses.addAll(<Completer<Result<AddItemSeparationSuccess>>>[
        firstPendingResponse,
        secondPendingResponse,
      ]);

      viewModel.dispose();
      viewModel = CardPickingViewModel.withDependencies(
        repository: repository,
        sectorStockRepository: sectorStockRepository,
        filtersStorage: filtersStorage,
        addItemSeparationUseCase: queuedAddUseCase,
        saveSeparationCartUseCase: buildSaveCartUseCase(userSessionService),
        userSessionService: userSessionService,
        validateSocketState: () => SocketValidationResult.success('abcd12345678'),
        cartEventRepository: eventRepository,
        shelfScanningService: ShelfScanningService(),
        stateManager: PickingStateManager(),
        cartValidationService: CartValidationService(repository: repository),
      );

      userSessionService.session = AppUser(
        codLoginApp: 1,
        ativo: Situation.ativo,
        nome: 'Usuario',
        codUsuario: 10,
        userSystemModel: buildUserModel(),
      );

      final cart = buildCart();
      final firstItem = buildPendingItem(item: '1', codProduto: 1);
      final secondItem = buildPendingItem(item: '2', codProduto: 2);
      repository.onSelect = (_) async => <SeparateItemConsultationModel>[firstItem, secondItem];

      await viewModel.initializeCart(cart, userModel: buildUserModel());
      expect(repository.selectCallCount, equals(1));

      final firstResult = await viewModel.addScannedItem(itemId: firstItem.item, quantity: 1);
      expect(firstResult.isSuccess, isTrue);

      final secondResult = await viewModel
          .addScannedItem(itemId: secondItem.item, quantity: 1)
          .timeout(const Duration(milliseconds: 100));

      expect(secondResult.isSuccess, isTrue);
      expect(repository.selectCallCount, equals(1));
      expect(queuedAddUseCase.callCount, equals(2));
      expect(viewModel.getPickedQuantity(firstItem.item), equals(1));
      expect(viewModel.getPickedQuantity(secondItem.item), equals(1));

      firstPendingResponse.complete(queuedAddUseCase.buildSuccess(_buildAddParamsForItem(firstItem)));
      secondPendingResponse.complete(queuedAddUseCase.buildSuccess(_buildAddParamsForItem(secondItem)));
      await Future<void>.delayed(Duration.zero);
    });
  });
}

AddItemSeparationParams _buildAddParamsForItem(SeparateItemConsultationModel item) {
  return AddItemSeparationParams(
    codEmpresa: item.codEmpresa,
    codSepararEstoque: item.codSepararEstoque,
    sessionId: 'abcd12345678',
    codCarrinhoPercurso: 200,
    itemCarrinhoPercurso: '1',
    itemSepararEstoque: item.item,
    codSeparador: 10,
    nomeSeparador: 'Usuario',
    codProduto: item.codProduto,
    codUnidadeMedida: item.codUnidadeMedida,
    quantidade: 1,
  );
}
