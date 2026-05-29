import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_with_consistency_usecase.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/separation_items_filters_controller.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/separation_carts_filters_controller.dart';

enum SeparateItemsState { initial, loading, loaded, error }

class SeparationItemsViewModel extends ChangeNotifier {
  late final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  late final BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> _cartRepository;
  late final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  late final IFiltersStorageService _filtersStorage;
  late final SeparateCartInternshipEventRepository _cartEventRepository;
  late final SeparationItemsFiltersController _itemsFiltersController;
  late final SeparationCartsFiltersController _cartsFiltersController;

  SeparationItemsViewModel() {
    try {
      _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>();
      _cartRepository = locator<BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>>();
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>();
      _filtersStorage = locator<IFiltersStorageService>();
      _cartEventRepository = locator<SeparateCartInternshipEventRepository>();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao inicializar SeparationItemsViewModel', tag: 'SeparationItemsVM', error: e);
      }
      rethrow;
    }
    _initControllers();
  }

  SeparationItemsViewModel.withDependencies(
    BasicConsultationRepository<SeparateItemConsultationModel> repository,
    BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> cartRepository,
    BasicRepository<ExpeditionSectorStockModel> sectorStockRepository,
    IFiltersStorageService filtersStorage,
    SeparateCartInternshipEventRepository cartEventRepository,
  ) {
    _repository = repository;
    _cartRepository = cartRepository;
    _sectorStockRepository = sectorStockRepository;
    _filtersStorage = filtersStorage;
    _cartEventRepository = cartEventRepository;
    _initControllers();
  }

  void _initControllers() {
    _itemsFiltersController = SeparationItemsFiltersController(storage: _filtersStorage);
    _cartsFiltersController = SeparationCartsFiltersController(storage: _filtersStorage);
  }

  SeparateItemsState _state = SeparateItemsState.initial;
  String? _errorMessage;
  bool _disposed = false;

  SeparateConsultationModel? _separation;
  List<SeparateItemConsultationModel> _items = [];

  List<ExpeditionCartRouteInternshipConsultationModel> _carts = [];
  bool _cartsLoaded = false;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  List<ExpeditionSectorStockModel>? _availableSectorsUnmodifiable;
  bool _sectorsLoaded = false;

  bool _isCancelling = false;
  int? _cancellingCartId;
  String? _lastCancelError;

  static const String _cartInsertListenerId = 'separation_items_viewmodel_cart_insert';
  static const String _cartUpdateListenerId = 'separation_items_viewmodel_cart_update';
  static const String _cartDeleteListenerId = 'separation_items_viewmodel_cart_delete';
  bool _cartEventListenersRegistered = false;
  bool _isRefreshing = false;
  bool _silentResyncInFlight = false;
  bool _silentResyncQueued = false;

  SeparateItemsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SeparateItemsState.loading;
  bool get hasError => _state == SeparateItemsState.error;
  bool get hasData => _items.isNotEmpty;

  SeparateConsultationModel? get separation => _separation;
  List<SeparateItemConsultationModel> get items => List.unmodifiable(_items);
  List<ExpeditionCartRouteInternshipConsultationModel> get carts => List.unmodifiable(_carts);

  int get totalItems => _items.length;
  int get totalCarts => _carts.length;
  bool get hasCartsData => _carts.isNotEmpty;
  bool get cartsLoaded => _cartsLoaded;

  bool get isCancelling => _isCancelling;
  bool isCartBeingCancelled(int cartId) => _isCancelling && _cancellingCartId == cartId;
  String? get lastCancelError => _lastCancelError;
  int get itemsSeparados => _items.where((item) => item.quantidadeSeparacao > 0).length;
  int get itemsPendentes => totalItems - itemsSeparados;
  double get percentualConcluido => totalItems > 0 ? (itemsSeparados / totalItems) * 100 : 0;

  SeparateItemsFiltersModel get itemsFilters => _itemsFiltersController.current;
  CartsFiltersModel get cartsFilters => _cartsFiltersController.current;
  bool get hasActiveItemsFilters => _itemsFiltersController.hasActive;
  bool get hasActiveCartsFilters => _cartsFiltersController.hasActive;

  List<SeparationItemStatus> get situacaoFilterOptions => SeparationItemStatus.availableForFilter;

  List<ExpeditionSectorStockModel> get availableSectors {
    _availableSectorsUnmodifiable ??= List.unmodifiable(_availableSectors);
    return _availableSectorsUnmodifiable!;
  }

  bool get sectorsLoaded => _sectorsLoaded;

  ExpeditionCartRouteInternshipConsultationModel? getCartSnapshot({
    required int codEmpresa,
    required int codCarrinhoPercurso,
    required String item,
  }) {
    for (final cart in _carts) {
      if (cart.codEmpresa == codEmpresa && cart.codCarrinhoPercurso == codCarrinhoPercurso && cart.item == item) {
        return cart;
      }
    }
    return null;
  }

  Future<void> loadSeparationItems(SeparateConsultationModel separation) async {
    if (_disposed) return;

    try {
      _setState(SeparateItemsState.loading);
      _clearError();

      _separation = separation;

      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', separation.codEmpresa.toString())
        ..equals('CodSepararEstoque', separation.codSepararEstoque.toString());

      await _itemsFiltersController.loadSavedAndApplyToQuery(queryBuilder);

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      _items = items..sort(_compareItemsByAddress);

      if (_disposed) return;

      _items = _itemsFiltersController.applySituacaoLocal(items);
      _setState(SeparateItemsState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar itens da separação: ${_getErrorMessage(e)}');
    }
  }

  Future<void> loadSeparationCarts(SeparateConsultationModel separation) async {
    if (_disposed) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodOrigem', separation.codSepararEstoque.toString())
        ..equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
        ..orderByDesc('Item');

      await _cartsFiltersController.loadSavedAndApplyToQuery(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;

      final filteredCarts = _cartsFiltersController.applySituacaoLocal(carts);

      _carts = filteredCarts..sort((a, b) => b.item.compareTo(a.item));
      _cartsLoaded = true;
      _safeNotifyListeners();
    } catch (e, s) {
      if (_disposed) return;
      // Bug RRRR: antes era catch silencioso (sem log) que ainda
      // setava _cartsLoaded=true. Usuario via lista vazia sem
      // pista do motivo. Agora logamos e mantemos comportamento.
      AppLogger.warning('Erro ao carregar carrinhos da separacao', tag: 'SeparationItemsVM', error: e, stackTrace: s);
      _cartsLoaded = true;
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_isRefreshing || _disposed) return;
    _isRefreshing = true;
    try {
      if (_separation != null) {
        final sep = _separation!;
        await Future.wait([loadSeparationItems(sep), loadSeparationCarts(sep)]);
      }

      if (!_sectorsLoaded) {
        await loadAvailableSectors();
      }
    } finally {
      if (!_disposed) _isRefreshing = false;
    }
  }

  Future<void> refreshWithSeparation(SeparateConsultationModel? fresh) async {
    if (_isRefreshing || _disposed) return;
    _isRefreshing = true;
    try {
      if (fresh != null) _separation = fresh;

      if (_separation != null) {
        final sep = _separation!;
        await Future.wait([loadSeparationItems(sep), loadSeparationCarts(sep)]);
      }

      if (!_sectorsLoaded) {
        await loadAvailableSectors();
      }
    } finally {
      if (!_disposed) _isRefreshing = false;
    }
  }

  Future<void> resyncVisibleDataSilently() async {
    if (_disposed || _separation == null) return;

    if (_silentResyncInFlight) {
      _silentResyncQueued = true;
      return;
    }

    if (_isRefreshing || isLoading) {
      return;
    }

    _silentResyncInFlight = true;
    try {
      await Future.wait<void>([_loadFilteredItems(), _loadFilteredCarts()]);
      if (_disposed) return;

      _cartsLoaded = true;
      _clearError();
      _state = SeparateItemsState.loaded;
      _safeNotifyListeners();
    } catch (e, s) {
      if (_disposed) return;
      AppLogger.debug(
        'Falha no resync silencioso dos itens da separacao',
        tag: 'SeparationItemsVM',
        error: e,
        stackTrace: s,
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

  void updateSeparation(SeparateConsultationModel separation) {
    if (_disposed) return;
    _separation = separation;
    _safeNotifyListeners();
  }

  Future<void> loadAvailableSectors() async {
    if (_disposed || _sectorsLoaded) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('Ativo', Situation.ativo.code)
        ..orderBy('Descricao');

      final sectors = await _sectorStockRepository.select(queryBuilder);

      if (_disposed) return;
      _availableSectorsUnmodifiable = null;
      _availableSectors = sectors;
      _sectorsLoaded = true;
      _safeNotifyListeners();
    } catch (e) {
      if (_disposed) return;

      // Log fora do `if (kDebugMode)` para que erros tambem apareçam
      // em release builds (AppLogger ja respeita o nivel global).
      AppLogger.error('Erro ao carregar setores de estoque', tag: 'SeparationItemsVM', error: e);
      _sectorsLoaded = true;
      _safeNotifyListeners();
    }
  }

  SeparateItemConsultationModel? findItem(String searchTerm) {
    final term = searchTerm.trim().toLowerCase();

    return _items.cast<SeparateItemConsultationModel?>().firstWhere((item) {
      if (item == null) return false;
      return item.codProduto.toString() == term ||
          (item.codigoBarras?.toLowerCase().contains(term) ?? false) ||
          item.nomeProduto.toLowerCase().contains(term);
    }, orElse: () => null);
  }

  bool validateProductInSeparation(String searchValue) {
    final trimmedValue = searchValue.trim();

    return _items.any(
      (item) => item.codProduto.toString() == trimmedValue || (item.codigoBarras?.trim() == trimmedValue),
    );
  }

  bool get isSeparationComplete {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isCompletamenteSeparado);
  }

  Future<void> applyItemsFilters(SeparateItemsFiltersModel filters) async {
    if (_disposed) return;

    try {
      await _itemsFiltersController.apply(filters);
      await _loadFilteredItems();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros de produtos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> applyCartsFilters(CartsFiltersModel filters) async {
    if (_disposed) return;

    try {
      await _cartsFiltersController.apply(filters);
      await _loadFilteredCarts();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros de carrinhos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> clearItemsFilters() async {
    if (_disposed) return;

    try {
      await _itemsFiltersController.clear();
      await _loadFilteredItems();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao limpar filtros de produtos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> clearCartsFilters() async {
    if (_disposed) return;

    try {
      await _cartsFiltersController.clear();
      await _loadFilteredCarts();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao limpar filtros de carrinhos: ${_getErrorMessage(e)}');
    }
  }

  void _setState(SeparateItemsState newState) {
    if (_disposed) return;
    _state = newState;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    _setState(SeparateItemsState.error);
  }

  void _clearError() {
    if (_disposed) return;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';

    if (error is AppError) {
      return error.message;
    }

    if (error is String) {
      return error;
    }

    try {
      final message = error.toString();

      if (message.startsWith('Instance of ')) {
        return 'Erro interno do sistema';
      }
      return message;
    } catch (e) {
      return 'Erro interno do sistema';
    }
  }

  Future<void> _loadFilteredItems() async {
    if (_separation == null) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', _separation!.codEmpresa.toString())
        ..equals('CodSepararEstoque', _separation!.codSepararEstoque.toString());

      _itemsFiltersController.applyToQuery(queryBuilder);

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      items.sort(_compareItemsByAddress);

      _items = _itemsFiltersController.applySituacaoLocal(items);
    } catch (e) {
      if (_disposed) return;

      if (kDebugMode) {
        AppLogger.error('Erro ao carregar itens filtrados', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _loadFilteredCarts() async {
    if (_separation == null) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodOrigem', _separation!.codSepararEstoque.toString())
        ..equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
        ..orderByDesc('Item');

      _cartsFiltersController.applyToQueryWithoutSituacao(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;

      final filteredCarts = _cartsFiltersController.applySituacaoLocal(carts);

      _carts = filteredCarts..sort((a, b) => b.item.compareTo(a.item));
    } catch (e) {
      if (_disposed) return;

      if (kDebugMode) {
        AppLogger.error('Erro ao carregar carrinhos filtrados', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  // Ordena por endereço preservando o critério original desta tela:
  // itens COM endereço aparecem antes dos SEM endereço; dentro disso,
  // ordenação natural delegada a PickingUtils (RegExp compilada uma vez
  // e parsing seguro com int.tryParse). A ordem final é idêntica à
  // anterior para endereços realistas.
  static int _compareItemsByAddress(SeparateItemConsultationModel a, SeparateItemConsultationModel b) {
    final hasEnderecoA = a.enderecoDescricao?.isNotEmpty == true;
    final hasEnderecoB = b.enderecoDescricao?.isNotEmpty == true;

    if (hasEnderecoA && !hasEnderecoB) return -1;
    if (!hasEnderecoA && hasEnderecoB) return 1;

    return PickingUtils.compareByAddress(a.enderecoDescricao, b.enderecoDescricao);
  }

  Future<bool> cancelCart(int codCarrinho) async {
    if (_disposed || _isCancelling) return false;

    try {
      _isCancelling = true;
      _cancellingCartId = codCarrinho;
      _lastCancelError = null;
      _safeNotifyListeners();

      ExpeditionCartRouteInternshipConsultationModel? cartConsultation;
      for (final cart in _carts) {
        if (cart.codCarrinho == codCarrinho) {
          cartConsultation = cart;
          break;
        }
      }
      if (cartConsultation == null) {
        _lastCancelError = 'Carrinho não encontrado para cancelamento.';
        return false;
      }

      final cancelWithConsistencyUseCase = locator<CancelCartWithConsistencyUseCase>();

      final paramsCartUseCase = CancelCartParams(
        codEmpresa: cartConsultation.codEmpresa,
        codCarrinhoPercurso: cartConsultation.codCarrinhoPercurso,
        item: cartConsultation.item,
      );

      final paramsItemSeparationUseCase = CancelCardItemSeparationParams(
        codEmpresa: cartConsultation.codEmpresa,
        codSepararEstoque: cartConsultation.codOrigem,
        codCarrinhoPercurso: cartConsultation.codCarrinhoPercurso,
        itemCarrinhoPercurso: cartConsultation.item,
      );

      final resultCancelCart = await cancelWithConsistencyUseCase.call(
        cancelCartParams: paramsCartUseCase,
        cancelItemParams: paramsItemSeparationUseCase,
      );

      return resultCancelCart.fold(
        (success) async {
          _lastCancelError = null;

          if (_separation != null) {
            await loadSeparationCarts(_separation!);
          }
          return true;
        },
        (failure) {
          _lastCancelError = failure.toString();
          return false;
        },
      );
    } catch (e) {
      _lastCancelError = 'Erro inesperado ao cancelar carrinho.';
      return false;
    } finally {
      _isCancelling = false;
      _cancellingCartId = null;
      _safeNotifyListeners();
    }
  }

  void startCartEventMonitoring() {
    if (_disposed) return;
    _registerCartEventListener();
  }

  void stopCartEventMonitoring() {
    if (_disposed) return;
    _unregisterCartEventListener();
  }

  void _registerCartEventListener() {
    if (_disposed || _cartEventListenersRegistered) return;

    try {
      // Ver SeparationViewModel: [EventServiceImpl] filtra Session == socket atual se allEvent=false.
      _cartEventRepository.addListener(
        EventListenerModel(id: _cartInsertListenerId, event: Event.insert, callback: _onCartEvent, allEvent: true),
      );

      _cartEventRepository.addListener(
        EventListenerModel(id: _cartUpdateListenerId, event: Event.update, callback: _onCartEvent, allEvent: true),
      );

      _cartEventRepository.addListener(
        EventListenerModel(id: _cartDeleteListenerId, event: Event.delete, callback: _onCartEvent, allEvent: true),
      );

      _cartEventListenersRegistered = true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao registrar evento de carrinho', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  void _unregisterCartEventListener() {
    if (!_cartEventListenersRegistered) return;

    try {
      _cartEventRepository.removeListeners([_cartInsertListenerId, _cartUpdateListenerId, _cartDeleteListenerId]);
      _cartEventListenersRegistered = false;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao desregistrar evento de carrinho', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  void _onCartEvent(BasicEventModel event) {
    if (_disposed) return;

    try {
      _processCartEventData(event);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de carrinho', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  void _processCartEventData(BasicEventModel event) {
    if (event.data == null || _separation == null) return;

    try {
      if (event.data is Map<String, dynamic>) {
        final dataMap = event.data as Map<String, dynamic>;
        if (_eventAffectsCurrentVisibleCarts(dataMap)) {
          unawaited(resyncVisibleDataSilently());
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de carrinho', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  bool _eventAffectsCurrentVisibleCarts(Map<String, dynamic> dataMap) {
    final mutations = dataMap['Mutation'];
    if (mutations is List) {
      for (final mutation in mutations) {
        if (mutation is! Map<String, dynamic>) continue;
        final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(mutation);
        if (_affectsCurrentVisibleCarts(cartData)) {
          return true;
        }
      }
      return false;
    }

    final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(dataMap);
    return _affectsCurrentVisibleCarts(cartData);
  }

  bool _affectsCurrentVisibleCarts(ExpeditionCartRouteInternshipConsultationModel cartData) {
    final separation = _separation;
    if (separation == null) {
      return false;
    }

    if (_findCartIndex(cartData) != -1) {
      return true;
    }

    if (cartData.origem != ExpeditionOrigem.separacaoEstoque) {
      return false;
    }

    return cartData.codOrigem == separation.codSepararEstoque;
  }

  int _findCartIndex(ExpeditionCartRouteInternshipConsultationModel cartData) {
    return _carts.indexWhere(
      (c) =>
          c.codEmpresa == cartData.codEmpresa &&
          c.codCarrinhoPercurso == cartData.codCarrinhoPercurso &&
          c.item == cartData.item,
    );
  }
}
