import 'dart:async' show Future, StreamController, Stream;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/tipo_fator_conversao_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/cart_event_listener_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_filters_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_metrics_recorder.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_pending_operations_tracker.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/picking_scan_result.dart';
export 'package:data7_expedicao/presentation/viewmodels/picking_scan_result.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_scan_resolver.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';

class CardPickingViewModel extends ChangeNotifier {
  static const String _cartInSeparationCode = 'EM SEPARACAO';
  static const String _cartSeparatingCode = 'SEPARANDO';

  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  final IFiltersStorageService _filtersStorage;

  final AddItemSeparationUseCase _addItemSeparationUseCase;
  final SaveSeparationCartUseCase _saveSeparationCartUseCase;

  final IUserSessionService _userSessionService;

  final SeparateCartInternshipEventRepository _cartEventRepository;
  late final CartEventListenerController _cartEventController;
  final ShelfScanningService _shelfScanningService;
  final PickingStateManager _stateManager;
  final CartValidationService _cartValidationService;
  final PickingMetricsRecorder _metrics;
  final PickingScanResolver _scanResolver = const PickingScanResolver();

  ExpeditionCartRouteInternshipConsultationModel? _cart;
  ExpeditionCartRouteInternshipConsultationModel? get cart => _cart;

  UserSystemModel? _userModel;
  UserSystemModel? get userModel => _userModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SeparateItemConsultationModel> _items = [];
  List<SeparateItemConsultationModel>? _itemsUnmodifiable;

  List<SeparateItemConsultationModel> get items {
    _itemsUnmodifiable ??= List.unmodifiable(_items);
    return _itemsUnmodifiable!;
  }

  bool get hasItems => _items.isNotEmpty;

  Map<int, SeparateItemConsultationModel>? _itemsByCodProduto;

  int? _lastScannedCodProduto;

  SeparateItemConsultationModel? _nextItemCache;

  String? get lastScannedAddress => _shelfScanningService.lastScannedAddress;

  SeparateItemConsultationModel? get nextItem => _nextItemCache;

  final PickingPendingOperationsTracker _pendingOperations = PickingPendingOperationsTracker();

  final StreamController<OperationError> _errorController = StreamController<OperationError>.broadcast();

  Stream<OperationError> get operationErrors => _errorController.stream;

  bool get hasItemsForUserSector {
    if (_items.isEmpty) return false;

    final userSectorCode = _userModel?.codSetorEstoque;

    if (userSectorCode == null) return true;

    return _items.any((item) => item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode);
  }

  PickingState get pickingState => _stateManager.pickingState;

  int get totalItems => _stateManager.totalItems;
  int get completedItems => _stateManager.completedItems;
  double get progress => _stateManager.progress;
  bool get isPickingComplete => _stateManager.isComplete;

  bool get isCartInSeparationStatus {
    return _cart?.situacao.code == _cartInSeparationCode || _cart?.situacao.code == _cartSeparatingCode;
  }

  bool get hasCartStatusChanged => _cartStatusChanged;

  bool get requiresShelfScanning => _shelfScanningService.requiresShelfScanning(_userModel);

  bool get hasPendingOperations {
    if (_items.isEmpty) return false;

    return pickingState.hasAnyPendingOperations() || _pendingOperations.isNotEmpty;
  }

  int _countPendingOperations() {
    if (_items.isEmpty) return 0;

    return pickingState.getTotalPendingOperations();
  }

  bool _disposed = false;

  // B12: locks contra reentrancy em operacoes irreversiveis.
  // Dart eh single-threaded — a checagem `if (_x)` + atribuicao `_x = true`
  // sao atomicas (nao ha preempcao entre elas). Isso impede que dois
  // toques rapidos no botao "Salvar/Finalizar/Cancelar" disparem duas
  // execucoes em paralelo (que poderia causar double-update no servidor
  // ou rollbacks inconsistentes em caso de falha).
  bool _isSavingCart = false;
  bool _isFinalizingPicking = false;
  bool _isCancelingPicking = false;

  bool _validateSocketState() {
    final validation = SocketValidationHelper.validateSocketState();
    return validation.isValid;
  }

  Future<Result<SaveSeparationCartSuccess>> saveCart() async {
    // B12: lock contra double-save (toques rapidos no botao).
    if (_isSavingCart) {
      return Failure(BusinessFailure(message: 'Salvamento em andamento. Aguarde a conclusão.'));
    }

    if (_cart == null) {
      return Failure(DataFailure(message: 'Carrinho não carregado'));
    }

    if (_userModel == null) {
      return Failure(AuthFailure.unauthenticated());
    }

    if (hasPendingOperations) {
      final pendingCount = _countPendingOperations();
      return Failure(
        BusinessFailure(
          message:
              'Existem $pendingCount operação${pendingCount == 1 ? '' : 'es'} pendente${pendingCount == 1 ? '' : 's'} de sincronização. Aguarde a conclusão antes de salvar.',
        ),
      );
    }

    final validationResult = _cartValidationService.validateCartAccess(
      currentUserCode: _userModel!.codUsuario,
      cart: _cart!,
      userModel: _userModel!,
      accessType: CartAccessType.save,
    );

    if (!validationResult.canAccess) {
      var errorMessage = 'Você não tem permissão para salvar este carrinho.';

      if (validationResult.reason == CartAccessDeniedReason.differentUser) {
        errorMessage =
            'Este carrinho pertence a ${validationResult.cartOwnerName}. Você não tem permissão para salvá-lo.';
      }

      return Failure(BusinessFailure(message: errorMessage));
    }

    _isSavingCart = true;
    try {
      final saveParams = SaveSeparationCartParams(
        codEmpresa: _cart!.codEmpresa,
        codCarrinhoPercurso: _cart!.codCarrinhoPercurso,
        itemCarrinhoPercurso: _cart!.item,
        codSepararEstoque: _cart!.codOrigem,
      );

      final result = await _saveSeparationCartUseCase(saveParams);
      return result;
    } finally {
      _isSavingCart = false;
    }
  }

  bool _cartStatusChanged = false;

  late final PickingFiltersController _filtersController;
  PendingProductsFiltersModel get filters => _filtersController.current;
  bool get hasActiveFilters => _filtersController.hasActive;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  List<ExpeditionSectorStockModel>? _availableSectorsUnmodifiable;
  bool _sectorsLoaded = false;

  List<ExpeditionSectorStockModel> get availableSectors {
    _availableSectorsUnmodifiable ??= List.unmodifiable(_availableSectors);
    return _availableSectorsUnmodifiable!;
  }

  bool get sectorsLoaded => _sectorsLoaded;

  List<SeparationItemStatus> get situacaoFilterOptions => [
    SeparationItemStatus.pendente,
    SeparationItemStatus.separado,
    SeparationItemStatus.cancelado,
  ];

  bool shouldScanShelf(SeparateItemConsultationModel nextItem) {
    return _shelfScanningService.shouldScanShelf(nextItem, _userModel);
  }

  void updateScannedAddress(String address) {
    _shelfScanningService.updateScannedAddress(address);
    _safeNotifyListeners();
  }

  void resetScannedAddress() {
    _shelfScanningService.resetScannedAddress();
  }

  CardPickingViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _filtersStorage = locator<IFiltersStorageService>(),
      _addItemSeparationUseCase = locator<AddItemSeparationUseCase>(),
      _saveSeparationCartUseCase = locator<SaveSeparationCartUseCase>(),
      _userSessionService = locator<IUserSessionService>(),
      _cartEventRepository = locator<SeparateCartInternshipEventRepository>(),
      _shelfScanningService = locator<ShelfScanningService>(),
      _stateManager = locator<PickingStateManager>(),
      _cartValidationService = locator<CartValidationService>(),
      _metrics = PickingMetricsRecorder(collector: _initMetricsCollector()) {
    _cartEventController = CartEventListenerController(
      eventRepository: _cartEventRepository,
      onCartUpdated: _handleCartUpdate,
      onProcessingError: _setError,
    );
    _filtersController = PickingFiltersController(
      storage: _filtersStorage,
      onChanged: _safeNotifyListeners,
    );
  }

  static MetricsCollector? _initMetricsCollector() {
    try {
      return locator<MetricsCollector>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _cartEventController.dispose();
    _errorController.close();
    BarcodeValidationService.clearCaches();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _safeNotifyListeners();
  }

  Future<void> initializeCart(ExpeditionCartRouteInternshipConsultationModel cart, {UserSystemModel? userModel}) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _cart = cart;
      _userModel = userModel;
      _cartStatusChanged = false;
      _shelfScanningService.resetScannedAddress();

      BarcodeValidationService.clearCaches();
      _clearNextItemCache();

      _safeNotifyListeners();

      await _loadCartItems();
      if (_disposed) return;

      startCartEventMonitoring();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao inicializar dados do picking: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  SeparateItemConsultationModel? shouldShowInitialShelfScan() {
    return _shelfScanningService.shouldShowInitialShelfScan(
      _items,
      _userModel,
      () => PickingUtils.findNextItemToPick(_items, isItemCompleted, userSectorCode: _userModel?.codSetorEstoque),
    );
  }

  /// Resolve um scan delegando ao [PickingScanResolver] (regra de negócio
  /// pura). O viewmodel apenas fornece o state atual via parâmetros.
  ScanProcessResult processScan({
    required String barcode,
    required int inputQuantity,
    required bool isCartInSeparation,
  }) {
    return _scanResolver.resolve(
      barcode: barcode,
      inputQuantity: inputQuantity,
      isCartInSeparation: isCartInSeparation,
      items: _items,
      userSectorCode: _userModel?.codSetorEstoque,
      requiresShelfScanning: requiresShelfScanning,
      shouldScanShelfFor: shouldScanShelf,
      lastScannedAddress: lastScannedAddress,
      onShelfAddressMatched: updateScannedAddress,
      isItemCompleted: isItemCompleted,
      getPickedQuantity: _stateManager.getPickedQuantity,
      onScanRecorded: (b, t, s, e) => _metrics.recordScan(
        barcode: b,
        startTime: t,
        success: s,
        errorMessage: e,
      ),
    );
  }

  Future<void> _loadCartItems() async {
    if (_cart == null) return;

    try {
      await _filtersController.loadSaved();
      await _loadFilteredItems();
    } catch (e) {
      developer.log('Failed to load cart items', error: e);
    }
  }

  Future<AddItemSeparationResult> addScannedItem({required int codProduto, required int quantity}) async {
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');

    try {
      final item = _findItemByCodProduto(codProduto);
      if (item == null) return AddItemSeparationResult.error('Produto não encontrado neste carrinho');

      final futures = <Future<dynamic>>[
        _userSessionService.loadUserSession(),
        Future(() => SocketValidationHelper.validateSocketState()),
      ];

      final results = await Future.wait(futures);
      final appUser = results[0] as dynamic;
      final socketValidation = results[1] as SocketValidationResult;

      if (appUser?.userSystemModel == null) {
        return AddItemSeparationResult.error('Usuário não autenticado');
      }

      if (!socketValidation.isValid) {
        return AddItemSeparationResult.error('Socket não está pronto: ${socketValidation.errorMessage}');
      }

      final userSystem = appUser.userSystemModel;
      final sessionId = socketValidation.sessionId!;

      final lastScanned = _lastScannedCodProduto;
      _lastScannedCodProduto = codProduto;

      if (lastScanned != null && lastScanned != codProduto) {
        await _waitForPendingOperationsAndRefresh();
      }

      final params = AddItemSeparationParams(
        codEmpresa: _cart!.codEmpresa,
        codSepararEstoque: _cart!.codOrigem,
        sessionId: sessionId,
        codCarrinhoPercurso: _cart!.codCarrinhoPercurso,
        itemCarrinhoPercurso: _cart!.item,
        codSeparador: userSystem.codUsuario,
        nomeSeparador: userSystem.nomeUsuario,
        codProduto: codProduto,
        codUnidadeMedida: item.codUnidadeMedida,
        quantidade: quantity.toDouble(),
      );

      final timestamp = DateTime.now();
      _updateLocalPickingStateOptimistic(item.item, quantity, timestamp);
      _updateNextItemCache();

      _executeAsyncAddItem(params, userSystem, item.item, quantity, timestamp);

      return AddItemSeparationResult.success('Item adicionado: $quantity unidades', addedQuantity: quantity.toDouble());
    } catch (e) {
      return AddItemSeparationResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  void _updateLocalPickingStateOptimistic(String itemId, int quantity, DateTime timestamp) {
    if (_disposed) return;
    _stateManager.updateItemQuantityAndAddPending(itemId, quantity, timestamp);
    _safeNotifyListeners();
  }

  void updatePickedQuantity(String itemId, int quantity) {
    if (_disposed) return;
    _stateManager.updateItemQuantity(itemId, quantity);

    _updateNextItemCache();
    _safeNotifyListeners();
  }

  Future<AddItemSeparationResult> updatePickedQuantityWithSync(String itemId, int newQuantity) async {
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');

    final item = _findItemByItemId(itemId);
    if (item == null) return AddItemSeparationResult.error('Item não encontrado');

    final currentQuantity = _stateManager.getPickedQuantity(itemId);
    if (newQuantity == currentQuantity) {
      return AddItemSeparationResult.success('Quantidade mantida', addedQuantity: 0);
    }

    if (newQuantity < currentQuantity) {
      _stateManager.updateItemQuantity(itemId, newQuantity);
      _updateNextItemCache();
      _safeNotifyListeners();
      return AddItemSeparationResult.success('Redução aplicada localmente', addedQuantity: 0);
    }

    final delta = newQuantity - currentQuantity;
    try {
      final futures = <Future<dynamic>>[
        _userSessionService.loadUserSession(),
        Future(() => SocketValidationHelper.validateSocketState()),
      ];
      final results = await Future.wait(futures);
      final appUser = results[0] as dynamic;
      final socketValidation = results[1] as SocketValidationResult;

      if (appUser?.userSystemModel == null) {
        return AddItemSeparationResult.error('Usuário não autenticado');
      }
      if (!socketValidation.isValid) {
        return AddItemSeparationResult.error('Socket não está pronto: ${socketValidation.errorMessage}');
      }

      final userSystem = appUser.userSystemModel;
      final sessionId = socketValidation.sessionId!;

      _stateManager.updateItemQuantity(itemId, newQuantity);
      _updateNextItemCache();
      _safeNotifyListeners();

      final params = AddItemSeparationParams(
        codEmpresa: _cart!.codEmpresa,
        codSepararEstoque: _cart!.codOrigem,
        sessionId: sessionId,
        codCarrinhoPercurso: _cart!.codCarrinhoPercurso,
        itemCarrinhoPercurso: _cart!.item,
        codSeparador: userSystem.codUsuario,
        nomeSeparador: userSystem.nomeUsuario,
        codProduto: item.codProduto,
        codUnidadeMedida: item.codUnidadeMedida,
        quantidade: delta.toDouble(),
      );

      final timestamp = DateTime.now();
      _stateManager.addPendingOperation(itemId, delta, timestamp);
      _safeNotifyListeners();

      _executeAsyncAddItem(params, userSystem, itemId, delta, timestamp);

      return AddItemSeparationResult.success(
        'Quantidade atualizada: +$delta unidades',
        addedQuantity: delta.toDouble(),
      );
    } catch (e) {
      _stateManager.updateItemQuantity(itemId, currentQuantity);
      _updateNextItemCache();
      _safeNotifyListeners();
      return AddItemSeparationResult.error('Erro ao sincronizar: ${e.toString()}');
    }
  }

  void completeItem(String itemId) {
    if (_disposed) return;
    _stateManager.completeItem(itemId);

    _updateNextItemCache();
    _safeNotifyListeners();
  }

  int getPickedQuantity(String itemId) => _stateManager.getPickedQuantity(itemId);

  bool isItemCompleted(String itemId) => _stateManager.isItemCompleted(itemId);

  int get maxQuantityForNextItem {
    final nextItem = _nextItemCache;
    if (nextItem == null) return 999;
    final totalQuantity = nextItem.quantidade.toInt();
    final pickedQuantity = getPickedQuantity(nextItem.item);
    final remainingQuantity = totalQuantity - pickedQuantity;
    return remainingQuantity > 0 ? remainingQuantity : 1;
  }

  Future<bool> finalizePicking() async {
    if (_disposed) return false;
    // B12: lock contra reentrancy (toques rapidos no botao).
    if (_isFinalizingPicking) return false;
    _isFinalizingPicking = true;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      if (!isPickingComplete) {
        _hasError = true;
        _errorMessage = 'Não é possível finalizar: ainda há itens pendentes de separação';
        return false;
      }

      if (!_validateSocketState()) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado. Verifique sua conexão.';
        return false;
      }

      final appUser = await _userSessionService.loadUserSession();
      if (_disposed) return false;
      if (appUser?.userSystemModel == null) {
        _hasError = true;
        _errorMessage = 'Usuário não autenticado';
        return false;
      }

      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao finalizar picking: ${e.toString()}';
      return false;
    } finally {
      _isFinalizingPicking = false;
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> cancelPicking() async {
    if (_disposed) return false;
    // B12: lock contra reentrancy (toques rapidos no botao).
    if (_isCancelingPicking) return false;
    _isCancelingPicking = true;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      if (!_validateSocketState()) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado. Verifique sua conexão.';
        return false;
      }

      final appUser = await _userSessionService.loadUserSession();
      if (_disposed) return false;
      if (appUser?.userSystemModel == null) {
        _hasError = true;
        _errorMessage = 'Usuário não autenticado';
        return false;
      }

      return true;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao cancelar picking: ${e.toString()}';
      return false;
    } finally {
      _isCancelingPicking = false;
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed || _cart == null) return;

    _lastScannedCodProduto = null;
    _shelfScanningService.resetScannedAddress();
    _itemsByCodProduto = null;

    _clearNextItemCache();

    await initializeCart(_cart!, userModel: _userModel);
  }

  Future<void> retry() async {
    if (_disposed || _cart == null) return;

    _hasError = false;
    _errorMessage = null;
    await initializeCart(_cart!);
  }

  Future<void> loadAvailableSectors() async {
    if (_disposed || _sectorsLoaded) return;

    try {
      final sectors = await _sectorStockRepository.select(QueryBuilder());
      if (_disposed) return;

      _availableSectorsUnmodifiable = null;
      _availableSectors = sectors;
      _sectorsLoaded = true;
      _safeNotifyListeners();
    } catch (e) {
      _availableSectorsUnmodifiable = null;
      _availableSectors = [];
      _sectorsLoaded = false;
    }
  }

  Future<void> applyFilters(PendingProductsFiltersModel filters) async {
    if (_disposed) return;

    try {
      await _filtersController.apply(filters);
      await _loadFilteredItems();
      if (_disposed) return;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros: ${e.toString()}');
    }
  }

  Future<void> clearFilters() async {
    if (_disposed) return;

    try {
      await _filtersController.clear();
      await _loadFilteredItems();
      if (_disposed) return;
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao limpar filtros: ${e.toString()}');
    }
  }

  Future<void> _loadFilteredItems() async {
    if (_cart == null) return;

    try {
      final codEmpresa = _cart!.codEmpresa;
      final codSepararEstoque = _cart!.codOrigem;
      final codSetorEstoqueUsuario = _userModel?.codSetorEstoque;

      List<SeparateItemConsultationModel> items = [];

      if (codSetorEstoqueUsuario != null) {
        final queryNoSector = QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codSepararEstoque.toString())
          ..orderBy('EnderecoDescricao');

        final allItems = await _repository.selectConsultation(queryNoSector);

        final filteredItems = allItems.where((item) {
          return item.codSetorEstoque == null || item.codSetorEstoque == codSetorEstoqueUsuario;
        }).toList();

        items = filteredItems;
      } else {
        final queryBuilder = QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codSepararEstoque.toString())
          ..orderBy('EnderecoDescricao');

        items = await _repository.selectConsultation(queryBuilder);
      }

      if (_disposed) return;

      items = _filtersController.applyLocal(items);

      items = _addSyntheticCodProdutoUnitsForScan(items);

      _itemsUnmodifiable = null;
      _items = PickingUtils.sortItemsByAddress(items, userSectorCode: _userModel?.codSetorEstoque);

      _rebuildItemsCache();

      _stateManager.initial(_items);

      _updateNextItemCache();

      _safeNotifyListeners();
    } catch (e) {
      developer.log('Failed to load filtered items', error: e);
    }
  }

  List<SeparateItemConsultationModel> _addSyntheticCodProdutoUnitsForScan(List<SeparateItemConsultationModel> items) {
    return items.map((item) {
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
  }

  void startCartEventMonitoring() {
    if (_disposed || _cart == null) return;
    _cartEventController.start(_cart!);
  }

  void stopCartEventMonitoring() {
    if (_disposed) return;
    _cartEventController.stop();
  }

  /// Callback do `CartEventListenerController` quando chega evento de
  /// atualização do mesmo carrinho (filtrado pelo controller).
  /// Aqui aplicamos a regra de UI: só notificamos se a situação mudou.
  void _handleCartUpdate(ExpeditionCartRouteInternshipConsultationModel cartData) {
    if (_disposed || _cart == null) return;

    final oldSituation = _cart!.situacao.code;
    final newSituation = cartData.situacao.code;

    if (oldSituation != newSituation) {
      _cartStatusChanged = true;
      _cart = cartData;
      _cartEventController.updateCurrentCart(cartData);
      _safeNotifyListeners();
    }
  }

  Future<void> _executeAsyncAddItem(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    final operation = _performAddItemOperation(params, userSystem, itemId, quantity, timestamp);
    _pendingOperations.track(itemId, operation);
    await operation;
  }

  Future<void> _performAddItemOperation(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    try {
      _updateOperationStatus(itemId, timestamp, PendingOperationStatus.syncing);

      final result = await _addItemSeparationUseCase.call(params, userSystem: userSystem);

      await result.fold(
        (success) async {
          _updateOperationStatus(itemId, timestamp, PendingOperationStatus.synced);

          Future.delayed(const Duration(seconds: 2), () {
            if (!_disposed) {
              _stateManager.clearSyncedOperations(itemId);
              _safeNotifyListeners();
            }
          });
        },
        (failure) async {
          _handleAddItemFailure(itemId, quantity, timestamp, failure);
        },
      );
    } catch (e) {
      _handleAddItemFailure(itemId, quantity, timestamp, e);
    }
  }

  void _handleAddItemFailure(String itemId, int quantity, DateTime timestamp, dynamic error) {
    if (_disposed) return;
    final errorMessage = error is AppFailure ? error.userMessage : error.toString();
    _stateManager.revertQuantityAndMarkOperationFailed(itemId, quantity, timestamp, errorMessage);
    _safeNotifyListeners();
    _notifyOperationError(itemId, errorMessage);
  }

  void _updateOperationStatus(
    String itemId,
    DateTime timestamp,
    PendingOperationStatus status, {
    String? errorMessage,
  }) {
    if (_disposed) return;
    _stateManager.updateOperationStatus(itemId, timestamp, status, errorMessage: errorMessage);
    _safeNotifyListeners();
  }

  Future<void> _waitForPendingOperationsAndRefresh() async {
    if (_pendingOperations.isEmpty) return;

    await _pendingOperations.waitForAll();
    if (_disposed) return;

    await refresh();
  }

  void _notifyOperationError(String itemId, String errorMessage) {
    if (!_errorController.isClosed) {
      _errorController.add(OperationError(itemId, errorMessage));
    }
  }

  SeparateItemConsultationModel? _findItemByCodProduto(int codProduto) {
    return _itemsByCodProduto?[codProduto];
  }

  SeparateItemConsultationModel? _findItemByItemId(String itemId) {
    for (final i in _items) {
      if (i.item == itemId) return i;
    }
    return null;
  }

  void _rebuildItemsCache() {
    _itemsByCodProduto = {for (final item in _items) item.codProduto: item};
  }

  void _clearNextItemCache() {
    _nextItemCache = null;
  }

  void _updateNextItemCache() {
    _nextItemCache = PickingUtils.findNextItemToPick(
      _items,
      isItemCompleted,
      userSectorCode: _userModel?.codSetorEstoque,
    );
  }

}

class AddItemSeparationResult {
  final bool isSuccess;
  final String message;
  final double? addedQuantity;

  AddItemSeparationResult.success(this.message, {this.addedQuantity}) : isSuccess = true;

  AddItemSeparationResult.error(this.message) : isSuccess = false, addedQuantity = null;
}

class OperationError {
  final String itemId;
  final String message;

  OperationError(this.itemId, this.message);
}

