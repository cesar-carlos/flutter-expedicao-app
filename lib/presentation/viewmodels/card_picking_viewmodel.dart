import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/cart_event_listener_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_filters_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_metrics_recorder.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_pending_operations_tracker.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/next_item_cache_manager.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_item_loader.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_add_item_coordinator.dart';
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
  final SocketValidationResult Function() _validateSocketStateFn;

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

  final NextItemCacheManager _nextItemCacheManager = NextItemCacheManager();

  String? get lastScannedAddress => _shelfScanningService.lastScannedAddress;

  SeparateItemConsultationModel? get nextItem => _nextItemCacheManager.current;

  final PickingPendingOperationsTracker _pendingOperations = PickingPendingOperationsTracker();
  late final PickingAddItemCoordinator _addItemCoordinator;

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

  /// Verdadeiro enquanto um salvamento de carrinho está em andamento.
  /// Usado para bloquear novas leituras de scan (em qualquer entry point)
  /// enquanto o save finaliza as entidades, evitando divergência UI/servidor.
  bool get isSavingCart => _isSavingCart;
  bool _silentResyncInFlight = false;
  bool _silentResyncQueued = false;

  // Debounce para coalescer eventos de atualização do carrinho em rajada
  // (cada evento de socket disparava um resync completo). Espelha o
  // padrão de `_notificationDebounce` do SeparationViewModel.
  Timer? _resyncDebounce;
  static const Duration _resyncDebounceDuration = Duration(milliseconds: 400);

  bool _validateSocketState() {
    final validation = _validateSocketStateFn();
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

    _isSavingCart = true;
    try {
      // Aguarda as operações de sincronização em andamento concluírem antes
      // de validar, fechando a janela TOCTOU em que uma operação terminava
      // entre a checagem de pendências e o início do save. O timeout evita
      // travar o save indefinidamente se uma sincronização ficar pendurada;
      // a checagem de `hasPendingOperations` abaixo ainda barra o save nesse
      // caso.
      await _pendingOperations.waitForAll(timeout: const Duration(seconds: 15));
      if (_disposed) {
        return Failure(BusinessFailure(message: 'Operação cancelada.'));
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
  late final PickingItemLoader _itemLoader;
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

  CardPickingViewModel.withDependencies({
    required BasicConsultationRepository<SeparateItemConsultationModel> repository,
    required BasicRepository<ExpeditionSectorStockModel> sectorStockRepository,
    required IFiltersStorageService filtersStorage,
    required AddItemSeparationUseCase addItemSeparationUseCase,
    required SaveSeparationCartUseCase saveSeparationCartUseCase,
    required IUserSessionService userSessionService,
    SocketValidationResult Function()? validateSocketState,
    required SeparateCartInternshipEventRepository cartEventRepository,
    required ShelfScanningService shelfScanningService,
    required PickingStateManager stateManager,
    required CartValidationService cartValidationService,
    MetricsCollector? metricsCollector,
  }) : _repository = repository,
       _sectorStockRepository = sectorStockRepository,
       _filtersStorage = filtersStorage,
       _addItemSeparationUseCase = addItemSeparationUseCase,
       _saveSeparationCartUseCase = saveSeparationCartUseCase,
       _userSessionService = userSessionService,
       _validateSocketStateFn = validateSocketState ?? SocketValidationHelper.validateSocketState,
       _cartEventRepository = cartEventRepository,
       _shelfScanningService = shelfScanningService,
       _stateManager = stateManager,
       _cartValidationService = cartValidationService,
       _metrics = PickingMetricsRecorder(collector: metricsCollector) {
    _cartEventController = CartEventListenerController(
      eventRepository: _cartEventRepository,
      onCartUpdated: _handleCartUpdate,
      onProcessingError: _setError,
    );
    _filtersController = PickingFiltersController(storage: _filtersStorage, onChanged: _safeNotifyListeners);
    _itemLoader = PickingItemLoader(repository: _repository, filtersController: _filtersController);
    _addItemCoordinator = _buildAddItemCoordinator();
  }

  PickingAddItemCoordinator _buildAddItemCoordinator() {
    return PickingAddItemCoordinator(
      addItemSeparationUseCase: _addItemSeparationUseCase,
      stateManager: _stateManager,
      pendingOperations: _pendingOperations,
      isDisposed: () => _disposed,
      notifyListeners: _safeNotifyListeners,
      scheduleQueuedResync: _scheduleQueuedResyncIfReady,
      notifyOperationError: _notifyOperationError,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _resyncDebounce?.cancel();
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
      _nextItemCacheManager.clear();

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
      () => _nextItemCacheManager.currentOrCompute(_items, isItemCompleted),
    );
  }

  /// Resolve um scan delegando ao [PickingScanResolver] (regra de negócio
  /// pura). O viewmodel apenas fornece o state atual via parâmetros.
  ScanProcessResult processScan({
    required String barcode,
    required int inputQuantity,
    required bool isCartInSeparation,
  }) {
    final nextItem = _nextItemCacheManager.currentOrCompute(_items, isItemCompleted);
    return _scanResolver.resolve(
      barcode: barcode,
      inputQuantity: inputQuantity,
      isCartInSeparation: isCartInSeparation,
      items: _items,
      nextItem: nextItem,
      userSectorCode: _userModel?.codSetorEstoque,
      requiresShelfScanning: requiresShelfScanning,
      shouldScanShelfFor: shouldScanShelf,
      lastScannedAddress: lastScannedAddress,
      onShelfAddressMatched: updateScannedAddress,
      isItemCompleted: isItemCompleted,
      getPickedQuantity: _stateManager.getPickedQuantity,
      onScanRecorded: (b, t, s, e) => _metrics.recordScan(barcode: b, startTime: t, success: s, errorMessage: e),
      allowOutOfSequence: _userModel?.canSeparateOutOfSequence ?? false,
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

  Future<AddItemSeparationResult> addScannedItem({required String itemId, required int quantity}) async {
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');
    if (_isSavingCart) return AddItemSeparationResult.error('Salvamento em andamento. Aguarde a conclusão.');

    try {
      final item = _findItemByItemId(itemId);
      if (item == null) return AddItemSeparationResult.error('Produto não encontrado neste carrinho');

      final futures = <Future<dynamic>>[
        _userSessionService.loadUserSession(),
        Future<SocketValidationResult>(_validateSocketStateFn),
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

      final params = AddItemSeparationParams(
        codEmpresa: _cart!.codEmpresa,
        codSepararEstoque: _cart!.codOrigem,
        sessionId: sessionId,
        codCarrinhoPercurso: _cart!.codCarrinhoPercurso,
        itemCarrinhoPercurso: _cart!.item,
        itemSepararEstoque: item.item,
        codSeparador: userSystem.codUsuario,
        nomeSeparador: userSystem.nomeUsuario,
        codProduto: item.codProduto,
        codUnidadeMedida: item.codUnidadeMedida,
        quantidade: quantity.toDouble(),
      );

      final timestamp = DateTime.now();
      _updateLocalPickingStateOptimistic(item.item, quantity, timestamp);
      _nextItemCacheManager.update(_items, isItemCompleted);

      _addItemCoordinator.executeAsyncAddItem(params, userSystem, item.item, quantity, timestamp);

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

    _nextItemCacheManager.update(_items, isItemCompleted);
    _safeNotifyListeners();
  }

  Future<AddItemSeparationResult> updatePickedQuantityWithSync(String itemId, int newQuantity) async {
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');
    if (_isSavingCart) return AddItemSeparationResult.error('Salvamento em andamento. Aguarde a conclusão.');

    final item = _findItemByItemId(itemId);
    if (item == null) return AddItemSeparationResult.error('Item não encontrado');

    final currentQuantity = _stateManager.getPickedQuantity(itemId);
    if (newQuantity == currentQuantity) {
      return AddItemSeparationResult.success('Quantidade mantida', addedQuantity: 0);
    }

    if (newQuantity < currentQuantity) {
      return AddItemSeparationResult.error(
        'Redução de quantidade não é suportada nesta tela. Exclua a separação e refaça com a nova quantidade.',
      );
    }

    final delta = newQuantity - currentQuantity;
    try {
      final futures = <Future<dynamic>>[
        _userSessionService.loadUserSession(),
        Future<SocketValidationResult>(_validateSocketStateFn),
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
      _nextItemCacheManager.update(_items, isItemCompleted);
      _safeNotifyListeners();

      final params = AddItemSeparationParams(
        codEmpresa: _cart!.codEmpresa,
        codSepararEstoque: _cart!.codOrigem,
        sessionId: sessionId,
        codCarrinhoPercurso: _cart!.codCarrinhoPercurso,
        itemCarrinhoPercurso: _cart!.item,
        itemSepararEstoque: item.item,
        codSeparador: userSystem.codUsuario,
        nomeSeparador: userSystem.nomeUsuario,
        codProduto: item.codProduto,
        codUnidadeMedida: item.codUnidadeMedida,
        quantidade: delta.toDouble(),
      );

      final timestamp = DateTime.now();
      _stateManager.addPendingOperation(itemId, delta, timestamp);
      _safeNotifyListeners();

      _addItemCoordinator.executeAsyncAddItem(params, userSystem, itemId, delta, timestamp);

      return AddItemSeparationResult.success(
        'Quantidade atualizada: +$delta unidades',
        addedQuantity: delta.toDouble(),
      );
    } catch (e) {
      _stateManager.updateItemQuantity(itemId, currentQuantity);
      _nextItemCacheManager.update(_items, isItemCompleted);
      _safeNotifyListeners();
      return AddItemSeparationResult.error('Erro ao sincronizar: ${e.toString()}');
    }
  }

  void completeItem(String itemId) {
    if (_disposed) return;
    _stateManager.completeItem(itemId);

    _nextItemCacheManager.update(_items, isItemCompleted);
    _safeNotifyListeners();
  }

  int getPickedQuantity(String itemId) => _stateManager.getPickedQuantity(itemId);

  bool isItemCompleted(String itemId) => _stateManager.isItemCompleted(itemId);

  int get maxQuantityForNextItem => _nextItemCacheManager.maxQuantity(getPickedQuantity);

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

    _shelfScanningService.resetScannedAddress();

    _nextItemCacheManager.clear();

    await initializeCart(_cart!, userModel: _userModel);
  }

  Future<void> retry() async {
    if (_disposed || _cart == null) return;

    _hasError = false;
    _errorMessage = null;
    await initializeCart(_cart!, userModel: _userModel);
  }

  Future<void> resyncVisibleDataSilently() async {
    if (_disposed || _cart == null) return;

    if (_silentResyncInFlight) {
      _silentResyncQueued = true;
      return;
    }

    if (_isLoading || hasPendingOperations) {
      _silentResyncQueued = true;
      return;
    }

    _silentResyncInFlight = true;
    try {
      final items = await _itemLoader.fetchFilteredItems(cart: _cart, userSectorCode: _userModel?.codSetorEstoque);
      if (_disposed) return;

      _hasError = false;
      _errorMessage = null;
      _applyLoadedItems(items);
    } catch (e, stackTrace) {
      if (_disposed) return;
      AppLogger.debug(
        'Falha no resync silencioso do picking',
        tag: 'CardPickingViewModel',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      if (!_disposed) {
        _silentResyncInFlight = false;
        if (_silentResyncQueued) {
          _silentResyncQueued = false;
          unawaited(resyncVisibleDataSilently());
        }
      }
    }
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
      final items = await _itemLoader.fetchFilteredItems(cart: _cart, userSectorCode: _userModel?.codSetorEstoque);
      if (_disposed) return;
      _applyLoadedItems(items);
    } catch (e) {
      developer.log('Failed to load filtered items', error: e);
    }
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
    final statusChanged = oldSituation != newSituation;

    _cart = cartData;
    _cartEventController.updateCurrentCart(cartData);

    if (statusChanged) {
      _cartStatusChanged = true;
      _safeNotifyListeners();
    }

    // Debounce: em rajadas de eventos, só dispara o resync após um curto
    // período de silêncio. `resyncVisibleDataSilently` continua tratando
    // o adiamento quando há operações pendentes/carregando e o
    // re-enfileiramento.
    _resyncDebounce?.cancel();
    _resyncDebounce = Timer(_resyncDebounceDuration, () {
      if (_disposed) return;
      unawaited(resyncVisibleDataSilently());
    });
  }

  void _notifyOperationError(String itemId, String errorMessage) {
    if (!_errorController.isClosed) {
      _errorController.add(OperationError(itemId, errorMessage));
    }
  }

  SeparateItemConsultationModel? _findItemByItemId(String itemId) {
    for (final i in _items) {
      if (i.item == itemId) return i;
    }
    return null;
  }

  void _scheduleQueuedResyncIfReady() {
    if (_disposed || !_silentResyncQueued || hasPendingOperations || _isLoading) {
      return;
    }

    unawaited(resyncVisibleDataSilently());
  }

  void _applyLoadedItems(List<SeparateItemConsultationModel> items) {
    _itemsUnmodifiable = null;
    _items = PickingUtils.sortItemsByAddress(items, userSectorCode: _userModel?.codSetorEstoque);
    _stateManager.initial(_items);
    _nextItemCacheManager.update(_items, isItemCompleted);
    _safeNotifyListeners();
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
