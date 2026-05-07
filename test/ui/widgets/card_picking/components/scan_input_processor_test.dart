import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
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
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scan_input_processor.dart';

class _RecordingAudioService extends Fake implements AudioService {
  int barcodeScanCount = 0;
  int itemCompletedCount = 0;

  @override
  Future<void> playBarcodeScan() async {
    barcodeScanCount += 1;
  }

  @override
  Future<void> playItemCompleted() async {
    itemCompletedCount += 1;
  }
}

class _FakeConsultationRepository<T> implements BasicConsultationRepository<T> {
  _FakeConsultationRepository({required this.onSelect});

  final Future<List<T>> Function(QueryBuilder queryBuilder) onSelect;

  @override
  Future<List<T>> selectConsultation(QueryBuilder queryBuilder) => onSelect(queryBuilder);
}

class _FakeBasicRepository<T> implements BasicRepository<T> {
  _FakeBasicRepository({Future<List<T>> Function(QueryBuilder queryBuilder)? onSelect})
    : _onSelect = onSelect ?? ((_) async => <T>[]);

  final Future<List<T>> Function(QueryBuilder queryBuilder) _onSelect;

  @override
  Future<List<T>> delete(T entity) async => <T>[];

  @override
  Future<List<T>> insert(T entity) async => <T>[];

  @override
  Future<List<T>> select(QueryBuilder queryBuilder) => _onSelect(queryBuilder);

  @override
  Future<List<T>> update(T entity) async => <T>[];
}

class _FakeFiltersStorageService implements IFiltersStorageService {
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
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async => const PendingProductsFiltersModel();

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

class _FakeUserSessionService implements IUserSessionService {
  @override
  Future<void> clearUserSession() async {}

  @override
  Future<bool> hasActiveSession() async => true;

  @override
  Future<bool> isUserLoggedIn() async => true;

  @override
  Future<AppUser?> loadUserSession() async => null;

  @override
  Future<void> saveUserSession(AppUser appUser) async {}

  @override
  Future<void> updateUserSession(AppUser appUser) async {}
}

class _FakeSeparateCartInternshipEventRepository implements SeparateCartInternshipEventRepository {
  @override
  void addListener(listener) {}

  @override
  void dispose() {}

  @override
  EventListenerModel? getListenerById(String listenerId) => null;

  @override
  bool hasListener(String listenerId) => false;

  @override
  List<EventListenerModel> get listeners => const <EventListenerModel>[];

  @override
  void removeAllListeners() {}

  @override
  void removeListener(String listenerId) {}

  @override
  void removeListeners(List<String> listenerIds) {}
}

AddItemSeparationUseCase _buildAddItemUseCase(_FakeUserSessionService userSessionService) {
  return AddItemSeparationUseCase(
    separateItemRepository: _FakeBasicRepository<SeparateItemModel>(),
    separationItemRepository: _FakeBasicRepository<SeparationItemModel>(),
    userSessionService: userSessionService,
  );
}

SaveSeparationCartUseCase _buildSaveCartUseCase(_FakeUserSessionService userSessionService) {
  return SaveSeparationCartUseCase(
    cartRouteInternshipRepository: _FakeBasicRepository<ExpeditionCartRouteInternshipModel>(),
    separationItemConsultationRepository: _FakeConsultationRepository<SeparationItemConsultationModel>(
      onSelect: (_) async => <SeparationItemConsultationModel>[],
    ),
    separateItemRepository: _FakeConsultationRepository<SeparateItemConsultationModel>(
      onSelect: (_) async => <SeparateItemConsultationModel>[],
    ),
    separateProgressRepository: _FakeConsultationRepository<SeparateProgressConsultationModel>(
      onSelect: (_) async => <SeparateProgressConsultationModel>[],
    ),
    separationItemModelRepository: _FakeBasicRepository<SeparationItemModel>(),
    cartRepository: _FakeBasicRepository<ExpeditionCartModel>(),
    userSessionService: userSessionService,
  );
}

SeparateItemConsultationModel _buildItem({required double quantidadeSeparacao, double quantidade = 10}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 123,
    item: '1',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 123,
    codProduto: 1,
    nomeProduto: 'Produto 1',
    ativo: Situation.ativo,
    codTipoProduto: 'P',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codSetorEstoque: 1,
    nomeSetorEstoque: 'Setor 1',
    endereco: 'A1',
    enderecoDescricao: 'A1',
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Endereco',
    quantidade: quantidade,
    quantidadeInterna: quantidade,
    quantidadeExterna: 0,
    quantidadeSeparacao: quantidadeSeparacao,
    unidadeMedidas: const <SeparateItemUnidadeMedidaConsultationModel>[],
  );
}

UserSystemModel _buildUserModel() {
  return UserSystemModel(
    codUsuario: 10,
    nomeUsuario: 'Usuario',
    ativo: Situation.ativo,
    codEmpresa: 1,
    codSetorEstoque: 1,
    nomeSetorEstoque: 'Setor 1',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScanInputProcessor', () {
    late _FakeConsultationRepository<SeparateItemConsultationModel> repository;
    late _FakeUserSessionService userSessionService;
    late CardPickingViewModel viewModel;

    setUp(() {
      userSessionService = _FakeUserSessionService();
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('plays the standard success beep for a successful partial scan', () async {
      final item = _buildItem(quantidadeSeparacao: 2, quantidade: 10);
      repository = _FakeConsultationRepository<SeparateItemConsultationModel>(
        onSelect: (_) async => <SeparateItemConsultationModel>[item],
      );

      viewModel = CardPickingViewModel.withDependencies(
        repository: repository,
        sectorStockRepository: _FakeBasicRepository<ExpeditionSectorStockModel>(),
        filtersStorage: _FakeFiltersStorageService(),
        addItemSeparationUseCase: _buildAddItemUseCase(userSessionService),
        saveSeparationCartUseCase: _buildSaveCartUseCase(userSessionService),
        userSessionService: userSessionService,
        cartEventRepository: _FakeSeparateCartInternshipEventRepository(),
        shelfScanningService: ShelfScanningService(),
        stateManager: PickingStateManager(),
        cartValidationService: CartValidationService(repository: repository),
      );

      await viewModel.initializeCart(
        ExpeditionCartRouteInternshipConsultationModel(
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
          codSetorEstoque: 1,
          nomeSetorEstoque: 'Setor 1',
        ),
        userModel: _buildUserModel(),
      );

      final audioService = _RecordingAudioService();
      final processor = ScanInputProcessor(viewModel: viewModel, audioService: audioService);

      await processor.handleSuccessfulItemAddition(item, 1, () {}, () {}, () async {});

      expect(audioService.barcodeScanCount, 1);
      expect(audioService.itemCompletedCount, 0);
    });

    test('plays the completion sound instead of the standard beep when the scan finishes the item', () async {
      final item = _buildItem(quantidadeSeparacao: 9, quantidade: 10);
      repository = _FakeConsultationRepository<SeparateItemConsultationModel>(
        onSelect: (_) async => <SeparateItemConsultationModel>[item],
      );

      viewModel = CardPickingViewModel.withDependencies(
        repository: repository,
        sectorStockRepository: _FakeBasicRepository<ExpeditionSectorStockModel>(),
        filtersStorage: _FakeFiltersStorageService(),
        addItemSeparationUseCase: _buildAddItemUseCase(userSessionService),
        saveSeparationCartUseCase: _buildSaveCartUseCase(userSessionService),
        userSessionService: userSessionService,
        cartEventRepository: _FakeSeparateCartInternshipEventRepository(),
        shelfScanningService: ShelfScanningService(),
        stateManager: PickingStateManager(),
        cartValidationService: CartValidationService(repository: repository),
      );

      await viewModel.initializeCart(
        ExpeditionCartRouteInternshipConsultationModel(
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
          codSetorEstoque: 1,
          nomeSetorEstoque: 'Setor 1',
        ),
        userModel: _buildUserModel(),
      );
      viewModel.updatePickedQuantity(item.item, 10);

      final audioService = _RecordingAudioService();
      final processor = ScanInputProcessor(viewModel: viewModel, audioService: audioService);

      await processor.handleSuccessfulItemAddition(item, 1, () {}, () {}, () async {});

      expect(audioService.barcodeScanCount, 0);
      expect(audioService.itemCompletedCount, 1);
    });
  });
}
