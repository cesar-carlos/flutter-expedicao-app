import 'dart:async' show Future, StreamController, Stream;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/core/services/shelf_scanning_service.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';
import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/services/cart_validation_service.dart';

class CardPickingViewModel extends ChangeNotifier {
  static const String _cartUpdateListenerId = 'card_picking_viewmodel_cart_update';

  static const String _cartInSeparationCode = 'EM SEPARACAO';
  static const String _cartSeparatingCode = 'SEPARANDO';

  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  final FiltersStorageService _filtersStorage;

  final AddItemSeparationUseCase _addItemSeparationUseCase;
  final SaveSeparationCartUseCase _saveSeparationCartUseCase;

  final UserSessionService _userSessionService;

  final SeparateCartInternshipEventRepository _cartEventRepository;
  final ShelfScanningService _shelfScanningService;

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
  List<SeparateItemConsultationModel> get items => List.unmodifiable(_items);
  bool get hasItems => _items.isNotEmpty;

  Map<int, SeparateItemConsultationModel>? _itemsByCodProduto;

  int? _lastScannedCodProduto;

  String? get lastScannedAddress => _shelfScanningService.lastScannedAddress;

  final Map<String, List<Future<void>>> _pendingOperations = {};

  final StreamController<OperationError> _errorController = StreamController<OperationError>.broadcast();

  Stream<OperationError> get operationErrors => _errorController.stream;

  bool get hasItemsForUserSector {
    if (_items.isEmpty) return false;

    final userSectorCode = _userModel?.codSetorEstoque;

    if (userSectorCode == null) return true;

    return _items.any((item) => item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode);
  }

  PickingState _pickingState = const PickingState({});
  PickingState get pickingState => _pickingState;

  int get totalItems => _pickingState.totalItems;
  int get completedItems => _pickingState.completedItems;
  double get progress => _pickingState.progress;
  bool get isPickingComplete => _pickingState.isComplete;

  bool get isCartInSeparationStatus {
    return _cart?.situacao.code == _cartInSeparationCode || _cart?.situacao.code == _cartSeparatingCode;
  }

  bool get hasCartStatusChanged => _cartStatusChanged;

  bool get requiresShelfScanning => _shelfScanningService.requiresShelfScanning(_userModel);

  bool _disposed = false;

  Future<Result<SaveSeparationCartSuccess>> saveCart() async {
    if (_cart == null) {
      return Failure(DataFailure(message: 'Carrinho não carregado'));
    }

    if (_userModel == null) {
      return Failure(AuthFailure.unauthenticated());
    }

    final validationResult = CartValidationService.validateCartAccess(
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
  }

  bool _cartEventListenersRegistered = false;
  bool _cartStatusChanged = false;

  PendingProductsFiltersModel _filters = const PendingProductsFiltersModel();
  PendingProductsFiltersModel get filters => _filters;
  bool get hasActiveFilters => _filters.isNotEmpty;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;
  List<ExpeditionSectorStockModel> get availableSectors => List.unmodifiable(_availableSectors);
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
      _filtersStorage = locator<FiltersStorageService>(),
      _addItemSeparationUseCase = locator<AddItemSeparationUseCase>(),
      _saveSeparationCartUseCase = locator<SaveSeparationCartUseCase>(),
      _userSessionService = locator<UserSessionService>(),
      _cartEventRepository = locator<SeparateCartInternshipEventRepository>(),
      _shelfScanningService = locator<ShelfScanningService>();

  @override
  void dispose() {
    _disposed = true;
    stopCartEventMonitoring();
    _errorController.close();
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
      _safeNotifyListeners();

      await _loadCartItems();

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

  ScanProcessResult processScan({
    required String barcode,
    required int inputQuantity,
    required bool isCartInSeparation,
  }) {
    final trimmedBarcode = barcode.trim();

    if (trimmedBarcode.isEmpty) {
      return const ScanProcessResult(status: ScanProcessStatus.ignored);
    }

    if (!isCartInSeparation) {
      return const ScanProcessResult(status: ScanProcessStatus.cartNotInSeparation);
    }

    final validationResult = BarcodeValidationService.validateScannedBarcode(
      trimmedBarcode,
      _items,
      isItemCompleted,
      userSectorCode: _userModel?.codSetorEstoque,
    );

    if (validationResult.isEmpty) {
      return const ScanProcessResult(status: ScanProcessStatus.ignored);
    }

    if (validationResult.noItemsForSector) {
      return ScanProcessResult.noItemsForSector(validationResult.userSectorCode);
    }

    if (validationResult.allItemsCompleted) {
      return const ScanProcessResult(status: ScanProcessStatus.allItemsCompleted);
    }

    if (validationResult.isWrongSector && validationResult.scannedItem != null) {
      return ScanProcessResult.wrongSector(validationResult.scannedItem!, validationResult.userSectorCode);
    }

    if (validationResult.isValid && validationResult.expectedItem != null) {
      final convertedQuantity = _convertQuantityWithBarcode(
        validationResult.expectedItem!,
        trimmedBarcode,
        inputQuantity,
      );
      return ScanProcessResult.success(validationResult.expectedItem!, convertedQuantity);
    }

    if (validationResult.expectedItem != null) {
      return ScanProcessResult.wrongProduct(validationResult.expectedItem!);
    }

    return const ScanProcessResult(status: ScanProcessStatus.ignored);
  }

  int _convertQuantityWithBarcode(SeparateItemConsultationModel item, String barcode, int inputQuantity) {
    try {
      if (item.unidadeMedidas.length <= 1) {
        return inputQuantity;
      }

      final convertedQuantity = item.converterQuantidadePorCodigoBarras(barcode, inputQuantity.toDouble());

      if (convertedQuantity != null && convertedQuantity > 0) {
        return convertedQuantity.round();
      }

      return inputQuantity;
    } catch (_) {
      return inputQuantity;
    }
  }

  Future<void> _loadCartItems() async {
    if (_cart == null) return;

    try {
      await _loadSavedFilters();

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

      if (_lastScannedCodProduto != null && _lastScannedCodProduto != codProduto) {
        await _waitForPendingOperationsAndRefresh();
      }
      _lastScannedCodProduto = codProduto;

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

      _executeAsyncAddItem(params, userSystem, item.item, quantity, timestamp);

      return AddItemSeparationResult.success('Item adicionado: $quantity unidades', addedQuantity: quantity.toDouble());
    } catch (e) {
      return AddItemSeparationResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  void _updateLocalPickingStateOptimistic(String itemId, int quantity, DateTime timestamp) {
    if (_disposed) return;

    final currentQuantity = _pickingState.getPickedQuantity(itemId);
    _pickingState = _pickingState
        .updateItemQuantity(itemId, currentQuantity + quantity)
        .addPendingOperation(itemId, quantity, timestamp);

    _safeNotifyListeners();
  }

  void updatePickedQuantity(String itemId, int quantity) {
    if (_disposed) return;

    _pickingState = _pickingState.updateItemQuantity(itemId, quantity);
    _safeNotifyListeners();
  }

  void completeItem(String itemId) {
    if (_disposed) return;

    _pickingState = _pickingState.completeItem(itemId);
    _safeNotifyListeners();
  }

  int getPickedQuantity(String itemId) {
    return _pickingState.getPickedQuantity(itemId);
  }

  bool isItemCompleted(String itemId) {
    return _pickingState.isItemCompleted(itemId);
  }

  Future<bool> finalizePicking() async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      if (!isPickingComplete) {
        _hasError = true;
        _errorMessage = 'Não é possível finalizar: ainda há itens pendentes de separação';
        return false;
      }

      final socketValidation = SocketValidationHelper.validateSocketState();
      if (!socketValidation.isValid) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado: ${socketValidation.errorMessage}';
        return false;
      }

      final appUser = await _userSessionService.loadUserSession();
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
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> cancelPicking() async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      final socketValidation = SocketValidationHelper.validateSocketState();
      if (!socketValidation.isValid) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado: ${socketValidation.errorMessage}';
        return false;
      }

      final appUser = await _userSessionService.loadUserSession();
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
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed || _cart == null) return;

    _lastScannedCodProduto = null;
    _shelfScanningService.resetScannedAddress();
    _itemsByCodProduto = null;

    await initializeCart(_cart!, userModel: _userModel);
  }

  Future<void> retry() async {
    if (_disposed || _cart == null) return;

    _hasError = false;
    _errorMessage = null;
    await initializeCart(_cart!);
  }

  List<SeparateItemConsultationModel> _sortItemsByAddress(List<SeparateItemConsultationModel> items) {
    final userSectorCode = _userModel?.codSetorEstoque;

    return List.from(items)..sort((a, b) {
      final sectorA = a.codSetorEstoque;
      final sectorB = b.codSetorEstoque;

      if (sectorA == null && sectorB != null) return -1;
      if (sectorA != null && sectorB == null) return 1;

      if (userSectorCode != null && sectorA != null && sectorB != null) {
        final isASameUserSector = sectorA == userSectorCode;
        final isBSameUserSector = sectorB == userSectorCode;

        if (isASameUserSector && !isBSameUserSector) return -1;
        if (!isASameUserSector && isBSameUserSector) return 1;
      }

      final endA = a.enderecoDescricao?.toLowerCase() ?? '';
      final endB = b.enderecoDescricao?.toLowerCase() ?? '';

      final regExp = RegExp(r'^(\d+)');
      final matchA = regExp.firstMatch(endA);
      final matchB = regExp.firstMatch(endB);

      if (matchA != null && matchB != null) {
        final numA = int.parse(matchA.group(1)!);
        final numB = int.parse(matchB.group(1)!);
        if (numA != numB) return numA.compareTo(numB);
      }

      if (matchA != null && matchB == null) return -1;
      if (matchA == null && matchB != null) return 1;

      return endA.compareTo(endB);
    });
  }

  Future<void> loadAvailableSectors() async {
    if (_disposed || _sectorsLoaded) return;

    try {
      final sectors = await _sectorStockRepository.select(QueryBuilder());
      if (_disposed) return;

      _availableSectors = sectors;
      _sectorsLoaded = true;
      _safeNotifyListeners();
    } catch (e) {
      _availableSectors = [];
      _sectorsLoaded = false;
    }
  }

  Future<void> applyFilters(PendingProductsFiltersModel filters) async {
    if (_disposed) return;

    try {
      _filters = filters;
      await _saveFilters();
      await _loadFilteredItems();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros: ${e.toString()}');
    }
  }

  Future<void> clearFilters() async {
    if (_disposed) return;

    try {
      _filters = const PendingProductsFiltersModel();
      await _clearFilters();
      await _loadFilteredItems();
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

      items = _applyLocalFilters(items);

      _items = _sortItemsByAddress(items);

      _rebuildItemsCache();

      _pickingState = PickingState.initial(_items);

      _safeNotifyListeners();
    } catch (e) {
      developer.log('Failed to load filtered items', error: e);
    }
  }

  List<SeparateItemConsultationModel> _applyLocalFilters(List<SeparateItemConsultationModel> items) {
    return items.where((item) {
      if (_filters.codProduto != null && _filters.codProduto!.isNotEmpty) {
        if (!item.codProduto.toString().toLowerCase().contains(_filters.codProduto!.toLowerCase())) {
          return false;
        }
      }

      if (_filters.codigoBarras != null && _filters.codigoBarras!.isNotEmpty) {
        final barcode = item.codigoBarras?.toLowerCase() ?? '';
        if (!barcode.contains(_filters.codigoBarras!.toLowerCase())) {
          return false;
        }
      }

      if (_filters.nomeProduto != null && _filters.nomeProduto!.isNotEmpty) {
        if (!item.nomeProduto.toLowerCase().contains(_filters.nomeProduto!.toLowerCase())) {
          return false;
        }
      }

      if (_filters.enderecoDescricao != null && _filters.enderecoDescricao!.isNotEmpty) {
        final endereco = item.enderecoDescricao?.toLowerCase() ?? '';
        if (!endereco.contains(_filters.enderecoDescricao!.toLowerCase())) {
          return false;
        }
      }

      if (_filters.setorEstoque != null) {
        if (item.codSetorEstoque != _filters.setorEstoque!.codSetorEstoque) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _saveFilters() async {
    try {
      await _filtersStorage.savePendingProductsFilters(_filters);
    } catch (e, s) {
      developer.log('Failed to save pending products filters', error: e, stackTrace: s);
    }
  }

  Future<void> _clearFilters() async {
    try {
      await _filtersStorage.clearPendingProductsFilters();
    } catch (e, s) {
      developer.log('Failed to clear pending products filters', error: e, stackTrace: s);
    }
  }

  Future<void> _loadSavedFilters() async {
    try {
      final savedFilters = await _filtersStorage.loadPendingProductsFilters();
      if (savedFilters != null) {
        _filters = savedFilters;
        notifyListeners();
      }
    } catch (e, s) {
      developer.log('Failed to load pending products filters', error: e, stackTrace: s);
    }
  }

  void startCartEventMonitoring() {
    if (_disposed || _cart == null) return;
    _registerCartEventListener();
  }

  void stopCartEventMonitoring() {
    if (_disposed) return;
    _unregisterCartEventListener();
  }

  void _registerCartEventListener() {
    if (_disposed || _cartEventListenersRegistered || _cart == null) return;

    try {
      _cartEventRepository.addListener(
        EventListenerModel(id: _cartUpdateListenerId, event: Event.update, callback: _onCartEvent, allEvent: false),
      );

      _cartEventListenersRegistered = true;
    } catch (e) {
      developer.log('Failed to register cart event listener', error: e);
    }
  }

  void _unregisterCartEventListener() {
    if (!_cartEventListenersRegistered) return;

    try {
      _cartEventRepository.removeListener(_cartUpdateListenerId);
      _cartEventListenersRegistered = false;
    } catch (e) {
      developer.log('Failed to unregister cart event listener', error: e);
    }
  }

  void _onCartEvent(BasicEventModel event) {
    if (_disposed || _cart == null) return;

    try {
      _processCartEventData(event);
    } catch (e) {
      developer.log('Failed to process cart event', error: e);
    }
  }

  void _processCartEventData(BasicEventModel event) {
    if (event.data == null) return;

    try {
      if (event.data is Map<String, dynamic>) {
        final dataMap = event.data as Map<String, dynamic>;

        if (dataMap.containsKey('Mutation') && dataMap['Mutation'] is List) {
          final mutations = dataMap['Mutation'] as List;

          for (final mutation in mutations) {
            if (mutation is Map<String, dynamic>) {
              final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(mutation);
              _handleCartUpdate(cartData);
            }
          }
        } else {
          final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(dataMap);
          _handleCartUpdate(cartData);
        }
      }
    } catch (e) {
      developer.log('Failed to process cart event data', error: e);
    }
  }

  void _handleCartUpdate(ExpeditionCartRouteInternshipConsultationModel cartData) {
    if (_disposed || _cart == null) return;

    if (!_isSameCart(cartData)) return;

    final oldSituation = _cart!.situacao.code;
    final newSituation = cartData.situacao.code;

    if (oldSituation != newSituation) {
      _cartStatusChanged = true;
      _cart = cartData;
      _safeNotifyListeners();
    }
  }

  bool _isSameCart(ExpeditionCartRouteInternshipConsultationModel cartData) {
    return cartData.codEmpresa == _cart!.codEmpresa &&
        cartData.codCarrinhoPercurso == _cart!.codCarrinhoPercurso &&
        cartData.item == _cart!.item;
  }

  Future<void> _executeAsyncAddItem(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    final operation = _performAddItemOperation(params, userSystem, itemId, quantity, timestamp);

    _pendingOperations.putIfAbsent(itemId, () => []).add(operation);

    await operation;

    _pendingOperations[itemId]?.remove(operation);
    if (_pendingOperations[itemId]?.isEmpty ?? false) {
      _pendingOperations.remove(itemId);
    }
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
              _pickingState = _pickingState.clearSyncedOperations(itemId);
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

    final currentQuantity = _pickingState.getPickedQuantity(itemId);
    final revertedQuantity = currentQuantity - quantity;
    final errorMessage = error is AppFailure ? error.userMessage : error.toString();

    _pickingState = _pickingState
        .updateItemQuantity(itemId, revertedQuantity)
        .updateOperationStatus(itemId, timestamp, PendingOperationStatus.failed, errorMessage: errorMessage);

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

    _pickingState = _pickingState.updateOperationStatus(itemId, timestamp, status, errorMessage: errorMessage);
    _safeNotifyListeners();
  }

  Future<void> _waitForPendingOperationsAndRefresh() async {
    if (_pendingOperations.isEmpty) return;

    final allOperations = _pendingOperations.values.expand((list) => list).toList();
    await Future.wait(allOperations, eagerError: false);

    await refresh();
  }

  void _notifyOperationError(String itemId, String errorMessage) {
    if (!_errorController.isClosed) {
      _errorController.add(OperationError(itemId, errorMessage));
    }
  }

  SeparateItemConsultationModel? _findItemByCodProduto(int codProduto) {
    if (_itemsByCodProduto == null || _itemsByCodProduto!.isEmpty) {
      _rebuildItemsCache();
    }

    return _itemsByCodProduto?[codProduto];
  }

  void _rebuildItemsCache() {
    _itemsByCodProduto = {for (final item in _items) item.codProduto: item};
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

enum ScanProcessStatus {
  ignored,
  cartNotInSeparation,
  noItemsForSector,
  allItemsCompleted,
  wrongSector,
  wrongProduct,
  success,
}

class ScanProcessResult {
  final ScanProcessStatus status;
  final SeparateItemConsultationModel? expectedItem;
  final SeparateItemConsultationModel? scannedItem;
  final int? convertedQuantity;
  final int? userSectorCode;

  const ScanProcessResult({
    required this.status,
    this.expectedItem,
    this.scannedItem,
    this.convertedQuantity,
    this.userSectorCode,
  });

  const ScanProcessResult.success(SeparateItemConsultationModel item, int convertedQuantity)
    : this(status: ScanProcessStatus.success, expectedItem: item, convertedQuantity: convertedQuantity);

  const ScanProcessResult.noItemsForSector(int? userSectorCode)
    : this(status: ScanProcessStatus.noItemsForSector, userSectorCode: userSectorCode);

  const ScanProcessResult.wrongSector(SeparateItemConsultationModel scannedItem, int? userSectorCode)
    : this(status: ScanProcessStatus.wrongSector, scannedItem: scannedItem, userSectorCode: userSectorCode);

  const ScanProcessResult.wrongProduct(SeparateItemConsultationModel expectedItem)
    : this(status: ScanProcessStatus.wrongProduct, expectedItem: expectedItem);
}
