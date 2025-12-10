import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';

enum SeparateItemsState { initial, loading, loaded, error }

class SeparationItemsViewModel extends ChangeNotifier {
  late final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  late final BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> _cartRepository;
  late final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  late final FiltersStorageService _filtersStorage;
  late final SeparateCartInternshipEventRepository _cartEventRepository;

  SeparationItemsViewModel() {
    try {
      _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>();
      _cartRepository = locator<BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>>();
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>();
      _filtersStorage = locator<FiltersStorageService>();
      _cartEventRepository = locator<SeparateCartInternshipEventRepository>();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao inicializar SeparationItemsViewModel', tag: 'SeparationItemsVM', error: e);
      }
      rethrow;
    }
  }

  SeparateItemsState _state = SeparateItemsState.initial;
  String? _errorMessage;
  bool _disposed = false;

  SeparateConsultationModel? _separation;
  List<SeparateItemConsultationModel> _items = [];

  List<ExpeditionCartRouteInternshipConsultationModel> _carts = [];
  bool _cartsLoaded = false;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;

  bool _isCancelling = false;
  int? _cancellingCartId;
  String? _lastCancelError;

  SeparateItemsFiltersModel _itemsFilters = const SeparateItemsFiltersModel();
  CartsFiltersModel _cartsFilters = const CartsFiltersModel();

  static const String _cartInsertListenerId = 'separation_items_viewmodel_cart_insert';
  static const String _cartUpdateListenerId = 'separation_items_viewmodel_cart_update';
  static const String _cartDeleteListenerId = 'separation_items_viewmodel_cart_delete';
  bool _cartEventListenersRegistered = false;

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

  SeparateItemsFiltersModel get itemsFilters => _itemsFilters;
  CartsFiltersModel get cartsFilters => _cartsFilters;
  bool get hasActiveItemsFilters => _itemsFilters.isNotEmpty;
  bool get hasActiveCartsFilters => _cartsFilters.isNotEmpty;

  List<SeparationItemStatus> get situacaoFilterOptions => SeparationItemStatus.availableForFilter;

  List<ExpeditionSectorStockModel> get availableSectors => List.unmodifiable(_availableSectors);
  bool get sectorsLoaded => _sectorsLoaded;

  Future<void> loadSeparationItems(SeparateConsultationModel separation) async {
    if (_disposed) return;

    try {
      _setState(SeparateItemsState.loading);
      _clearError();

      _separation = separation;

      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', separation.codEmpresa.toString())
        ..equals('CodSepararEstoque', separation.codSepararEstoque.toString());

      await _applySavedFiltersToQuery(queryBuilder);

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      _items = items
        ..sort((a, b) {
          final hasEnderecoA = a.enderecoDescricao?.isNotEmpty == true;
          final hasEnderecoB = b.enderecoDescricao?.isNotEmpty == true;

          if (hasEnderecoA && !hasEnderecoB) return -1;
          if (!hasEnderecoA && hasEnderecoB) return 1;

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

      if (_disposed) return;

      _items = _applySituacaoFilter(items);
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

      await _applySavedCartsFiltersToQuery(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;

      final filteredCarts = _applySituacaoFilterToCarts(carts);

      _carts = filteredCarts..sort((a, b) => b.item.compareTo(a.item));
      _cartsLoaded = true;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _cartsLoaded = true;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_separation != null) {
      await loadSeparationItems(_separation!);
      await loadSeparationCarts(_separation!);
    }

    if (!_sectorsLoaded) {
      await loadAvailableSectors();
    }
  }

  Future<void> loadAvailableSectors() async {
    if (_disposed || _sectorsLoaded) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('Ativo', Situation.ativo.code)
        ..orderBy('Descricao');

      final sectors = await _sectorStockRepository.select(queryBuilder);

      if (_disposed) return;
      _availableSectors = sectors;
      _sectorsLoaded = true;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      if (kDebugMode) {
        AppLogger.error('Erro ao carregar setores de estoque', tag: 'SeparationItemsVM', error: e);
      }
      _sectorsLoaded = true;
      notifyListeners();
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

  Future<void> separateItem(SeparateItemConsultationModel item, double quantidade) async {
    if (_disposed) return;

    try {
      if (quantidade <= 0) throw 'Quantidade deve ser maior que zero';

      if (quantidade > item.quantidade) {
        throw 'Quantidade não pode exceder a quantidade disponível (${item.quantidade})';
      }

      if (!_items.any((i) => i.codProduto == item.codProduto)) {
        throw 'Produto não encontrado na lista de separação';
      }

      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao separar item: ${_getErrorMessage(e)}');
    }
  }

  bool validateProductInSeparation(String searchValue) {
    final trimmedValue = searchValue.trim();

    return _items.any(
      (item) => item.codProduto.toString() == trimmedValue || (item.codigoBarras?.trim() == trimmedValue),
    );
  }

  bool get isSeparationComplete {
    return _items.every((item) => item.quantidadeSeparacao > 0);
  }

  Future<void> separateAllItems() async {
    if (_disposed) return;

    try {
      for (final _ in _items.where((i) => i.quantidadeSeparacao == 0)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao separar todos os itens: ${_getErrorMessage(e)}');
    }
  }

  Future<void> applyItemsFilters(SeparateItemsFiltersModel filters) async {
    if (_disposed) return;

    try {
      _itemsFilters = filters;
      await _saveItemsFilters();
      await _loadFilteredItems();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros de produtos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> applyCartsFilters(CartsFiltersModel filters) async {
    if (_disposed) return;

    try {
      _cartsFilters = filters;
      await _saveCartsFilters();
      await _loadFilteredCarts();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao aplicar filtros de carrinhos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> clearItemsFilters() async {
    if (_disposed) return;

    try {
      _itemsFilters = const SeparateItemsFiltersModel();
      await _clearItemsFilters();
      await _loadFilteredItems();
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao limpar filtros de produtos: ${_getErrorMessage(e)}');
    }
  }

  Future<void> clearCartsFilters() async {
    if (_disposed) return;

    try {
      _cartsFilters = const CartsFiltersModel();
      await _clearCartsFilters();
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

  Future<void> _applySavedFiltersToQuery(QueryBuilder queryBuilder) async {
    try {
      final savedItemsFilters = await _filtersStorage.loadSeparateItemsFilters();
      if (savedItemsFilters.isNotEmpty) {
        _itemsFilters = savedItemsFilters;
        _applyItemsFiltersToQuery(queryBuilder);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao aplicar filtros salvos de itens', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _applySavedCartsFiltersToQuery(QueryBuilder queryBuilder) async {
    try {
      final savedCartsFilters = await _filtersStorage.loadCartsFilters();
      if (savedCartsFilters.isNotEmpty) {
        _cartsFilters = savedCartsFilters;

        _applyCartsFiltersToQueryWithoutSituacao(queryBuilder);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao aplicar filtros salvos de carrinhos', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _loadFilteredItems() async {
    if (_separation == null) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', _separation!.codEmpresa.toString())
        ..equals('CodSepararEstoque', _separation!.codSepararEstoque.toString());

      _applyItemsFiltersToQuery(queryBuilder);

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      items.sort((a, b) {
        final hasEnderecoA = a.enderecoDescricao?.isNotEmpty == true;
        final hasEnderecoB = b.enderecoDescricao?.isNotEmpty == true;

        if (hasEnderecoA && !hasEnderecoB) return -1;
        if (!hasEnderecoA && hasEnderecoB) return 1;

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

      _items = _applySituacaoFilter(items);
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

      _applyCartsFiltersToQueryWithoutSituacao(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;

      final filteredCarts = _applySituacaoFilterToCarts(carts);

      _carts = filteredCarts..sort((a, b) => b.item.compareTo(a.item));
    } catch (e) {
      if (_disposed) return;

      if (kDebugMode) {
        AppLogger.error('Erro ao carregar carrinhos filtrados', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  void _applyItemsFiltersToQuery(QueryBuilder queryBuilder) {
    if (_itemsFilters.codProduto != null) {
      queryBuilder.like('CodProduto', _itemsFilters.codProduto!);
    }
    if (_itemsFilters.codigoBarras != null) {
      queryBuilder.like('CodigoBarras', _itemsFilters.codigoBarras!);
    }
    if (_itemsFilters.nomeProduto != null) {
      queryBuilder.like('NomeProduto', _itemsFilters.nomeProduto!);
    }
    if (_itemsFilters.enderecoDescricao != null) {
      queryBuilder.like('EnderecoDescricao', _itemsFilters.enderecoDescricao!);
    }
    if (_itemsFilters.setorEstoque != null) {
      queryBuilder.equals('CodSetorEstoque', _itemsFilters.setorEstoque!.codSetorEstoque.toString());
    }
  }

  List<SeparateItemConsultationModel> _applySituacaoFilter(List<SeparateItemConsultationModel> items) {
    if (_itemsFilters.situacao == null) {
      return items;
    }

    return items.where((item) {
      final itemSituacao = item.situacaoSeparacao;
      return itemSituacao == _itemsFilters.situacao;
    }).toList();
  }

  void _applyCartsFiltersToQueryWithoutSituacao(QueryBuilder queryBuilder) {
    if (_cartsFilters.codCarrinho != null) {
      queryBuilder.like('CodCarrinho', _cartsFilters.codCarrinho!);
    }
    if (_cartsFilters.nomeCarrinho != null) {
      queryBuilder.like('NomeCarrinho', _cartsFilters.nomeCarrinho!);
    }
    if (_cartsFilters.codigoBarrasCarrinho != null) {
      queryBuilder.like('CodigoBarrasCarrinho', _cartsFilters.codigoBarrasCarrinho!);
    }
    if (_cartsFilters.nomeUsuarioInicio != null) {
      queryBuilder.like('NomeUsuarioInicio', _cartsFilters.nomeUsuarioInicio!);
    }
    if (_cartsFilters.dataInicioInicial != null) {
      queryBuilder.greaterThan('DataInicio', _cartsFilters.dataInicioInicial!.toIso8601String());
    }
    if (_cartsFilters.dataInicioFinal != null) {
      queryBuilder.lessThan('DataInicio', _cartsFilters.dataInicioFinal!.toIso8601String());
    }
    queryBuilder.equals('CarrinhoAgrupador', _cartsFilters.carrinhoAgrupador.code);
  }

  List<ExpeditionCartRouteInternshipConsultationModel> _applySituacaoFilterToCarts(
    List<ExpeditionCartRouteInternshipConsultationModel> carts,
  ) {
    if (_cartsFilters.situacoes == null || _cartsFilters.situacoes!.isEmpty) {
      return carts;
    }

    return carts.where((cart) {
      final cartSituacao = cart.situacao.code;
      return _cartsFilters.situacoes!.contains(cartSituacao);
    }).toList();
  }

  Future<void> _saveItemsFilters() async {
    try {
      await _filtersStorage.saveSeparateItemsFilters(_itemsFilters);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao salvar filtros de itens', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _saveCartsFilters() async {
    try {
      await _filtersStorage.saveCartsFilters(_cartsFilters);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao salvar filtros de carrinhos', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _clearItemsFilters() async {
    try {
      await _filtersStorage.clearSeparateItemsFilters();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao limpar filtros de itens', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<void> _clearCartsFilters() async {
    try {
      await _filtersStorage.clearCartsFilters();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao limpar filtros de carrinhos', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  Future<bool> cancelCart(int codCarrinho) async {
    if (_disposed || _isCancelling) return false;

    try {
      _isCancelling = true;
      _cancellingCartId = codCarrinho;
      _safeNotifyListeners();

      final cartConsultation = _carts.firstWhere((c) => c.codCarrinho == codCarrinho);

      final cancelCartUseCase = locator<CancelCartUseCase>();
      final cancelItemSeparationUseCase = locator<CancelCardItemSeparationUseCase>();

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

      final hasItemsToCancel = await cancelItemSeparationUseCase.canCancelItems(paramsItemSeparationUseCase);

      CancelCardItemSeparationSuccess? itemSeparationSuccess;

      if (hasItemsToCancel) {
        final resultItemSeparation = await cancelItemSeparationUseCase.call(paramsItemSeparationUseCase);

        itemSeparationSuccess = resultItemSeparation.fold((success) => success, (failure) {
          return null;
        });

        if (itemSeparationSuccess == null) {
          return false;
        }
      }

      final resultCancelCart = await cancelCartUseCase.call(paramsCartUseCase);

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
      _cartEventRepository.addListener(
        EventListenerModel(id: _cartInsertListenerId, event: Event.insert, callback: _onCartEvent, allEvent: false),
      );

      _cartEventRepository.addListener(
        EventListenerModel(id: _cartUpdateListenerId, event: Event.update, callback: _onCartEvent, allEvent: false),
      );

      _cartEventRepository.addListener(
        EventListenerModel(id: _cartDeleteListenerId, event: Event.delete, callback: _onCartEvent, allEvent: false),
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
    if (event.data == null) return;

    try {
      if (event.data is Map<String, dynamic>) {
        final dataMap = event.data as Map<String, dynamic>;

        if (dataMap.containsKey('Mutation') && dataMap['Mutation'] is List) {
          final mutations = dataMap['Mutation'] as List;

          for (final mutation in mutations) {
            if (mutation is Map<String, dynamic>) {
              final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(mutation);
              _handleCartEvent(event.eventType, cartData);
            }
          }
        } else {
          final cartData = ExpeditionCartRouteInternshipConsultationModel.fromJson(dataMap);
          _handleCartEvent(event.eventType, cartData);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de carrinho', tag: 'SeparationItemsVM', error: e);
      }
    }
  }

  void _handleCartEvent(Event eventType, ExpeditionCartRouteInternshipConsultationModel cartData) {
    if (_disposed) return;

    if (!_isCartValidForCurrentSeparation(cartData)) {
      return;
    }

    switch (eventType) {
      case Event.insert:
        _handleCartInsert(cartData);
        break;
      case Event.update:
        _handleCartUpdate(cartData);
        break;
      case Event.delete:
        _handleCartDelete(cartData);
        break;
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  bool _isCartValidForCurrentSeparation(ExpeditionCartRouteInternshipConsultationModel cartData) {
    final existingCartIndex = _findCartIndex(cartData);
    if (existingCartIndex != -1) {
      return true;
    }

    if (_separation != null && cartData.codOrigem != _separation!.codSepararEstoque) {
      return false;
    }

    return true;
  }

  int _findCartIndex(ExpeditionCartRouteInternshipConsultationModel cartData) {
    return _carts.indexWhere(
      (c) =>
          c.codEmpresa == cartData.codEmpresa &&
          c.codCarrinhoPercurso == cartData.codCarrinhoPercurso &&
          c.item == cartData.item,
    );
  }

  void _handleCartInsert(ExpeditionCartRouteInternshipConsultationModel cartData) {
    _carts.insert(0, cartData);
  }

  void _handleCartUpdate(ExpeditionCartRouteInternshipConsultationModel cartData) {
    final index = _findCartIndex(cartData);

    if (index != -1) {
      _carts[index] = cartData;
    } else {
      _carts.insert(0, cartData);
    }
  }

  void _handleCartDelete(ExpeditionCartRouteInternshipConsultationModel cartData) {
    _carts.removeWhere(
      (c) =>
          c.codEmpresa == cartData.codEmpresa &&
          c.codCarrinhoPercurso == cartData.codCarrinhoPercurso &&
          c.item == cartData.item,
    );
  }
}
