import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_cart_internship_event_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_usecase.dart';
import 'package:data7_expedicao/domain/usecases/delete_item_separation/delete_item_separation_params.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

class SeparatedProductsViewModel extends ChangeNotifier {
  static const String _cartUpdateListenerId = 'separated_products_viewmodel_cart_update';
  static const String _cartInSeparationCode = 'EM SEPARACAO';
  static const String _cartSeparatingCode = 'SEPARANDO';

  static const String _errorCartNotInSeparation = 'Só é possível excluir itens quando o carrinho está em separação';
  static const String _errorDeleteItem = 'Erro ao excluir item';
  final BasicConsultationRepository<SeparationItemConsultationModel> _repository;
  final DeleteItemSeparationUseCase _deleteItemSeparationUseCase;
  final SeparateCartInternshipEventRepository _cartEventRepository;

  ExpeditionCartRouteInternshipConsultationModel? _cartRouteInternshipConsultation;
  ExpeditionCartRouteInternshipConsultationModel? get cartRouteInternshipConsultation =>
      _cartRouteInternshipConsultation;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SeparationItemConsultationModel> _items = [];
  List<SeparationItemConsultationModel> get items => List.unmodifiable(_items);
  bool get hasItems => _items.isNotEmpty;

  int get totalItems => _items.length;
  double get totalQuantity => _items.fold(0.0, (sum, item) => sum + item.quantidade);

  bool get isCartInSeparationStatus =>
      _cartRouteInternshipConsultation?.situacao.code == _cartInSeparationCode ||
      _cartRouteInternshipConsultation?.situacao.code == _cartSeparatingCode;

  bool get hasCartStatusChanged => _cartStatusChanged;

  bool _disposed = false;

  bool _isReadOnly = false;
  bool get isReadOnly => _isReadOnly;

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  String? _cancellingItemId;
  String? get cancellingItemId => _cancellingItemId;

  bool _cartEventListenersRegistered = false;
  bool _cartStatusChanged = false;

  SeparatedProductsViewModel()
    : _repository = locator<BasicConsultationRepository<SeparationItemConsultationModel>>(),
      _deleteItemSeparationUseCase = locator<DeleteItemSeparationUseCase>(),
      _cartEventRepository = locator<SeparateCartInternshipEventRepository>();

  @override
  void dispose() {
    _disposed = true;
    stopCartEventMonitoring();
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadSeparatedProducts(
    ExpeditionCartRouteInternshipConsultationModel cart, {
    bool isReadOnly = false,
  }) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _cartRouteInternshipConsultation = cart;
      _isReadOnly = isReadOnly;
      _cartStatusChanged = false;
      _safeNotifyListeners();

      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', cart.codEmpresa.toString())
        ..equals('CodSepararEstoque', cart.codOrigem.toString())
        ..equals('CodCarrinhoPercurso', cart.codCarrinhoPercurso.toString())
        ..equals('ItemCarrinhoPercurso', cart.item);

      final items = await _repository.selectConsultation(queryBuilder);

      items.sort((a, b) {
        final dateComparison = b.dataSeparacao.compareTo(a.dataSeparacao);
        if (dateComparison != 0) return dateComparison;

        return b.horaSeparacao.compareTo(a.horaSeparacao);
      });

      _items = items;

      startCartEventMonitoring();

      if (kDebugMode) {}
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao carregar produtos separados: ${e.toString()}';

      if (kDebugMode) {}
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed || _cartRouteInternshipConsultation == null) return;
    await loadSeparatedProducts(_cartRouteInternshipConsultation!);
  }

  Future<void> retry() async {
    if (_disposed || _cartRouteInternshipConsultation == null) return;

    _hasError = false;
    _errorMessage = null;
    await loadSeparatedProducts(_cartRouteInternshipConsultation!);
  }

  List<SeparationItemConsultationModel> getItemsBySeparador(int codSeparador) {
    return _items.where((item) => item.codSeparador == codSeparador).toList();
  }

  Map<String, List<SeparationItemConsultationModel>> groupBySeparador() {
    final Map<String, List<SeparationItemConsultationModel>> grouped = {};

    for (final item in _items) {
      final key = '${item.codSeparador} - ${item.nomeSeparador}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(item);
    }

    return grouped;
  }

  Map<String, Map<String, dynamic>> getStatsBySeparador() {
    final grouped = groupBySeparador();
    final Map<String, Map<String, dynamic>> stats = {};

    grouped.forEach((key, items) {
      stats[key] = {
        'totalItems': items.length,
        'totalQuantity': items.fold(0.0, (sum, item) => sum + item.quantidade),
        'items': items,
      };
    });

    return stats;
  }

  bool isItemBeingCancelled(String itemId) => _isCancelling && _cancellingItemId == itemId;

  bool get canCancelItems =>
      !_isReadOnly && _cartRouteInternshipConsultation?.situacao == ExpeditionSituation.separando;

  Future<bool> deleteItem(SeparationItemConsultationModel item) async {
    if (!_canPerformDeleteOperation()) return false;

    try {
      _setDeletingState(item.item);

      final params = _createDeleteParams(item);
      final result = await _deleteItemSeparationUseCase.call(params);

      return result.fold(
        (success) async {
          await refresh();
          return true;
        },
        (failure) {
          _setError(failure.toString());
          return false;
        },
      );
    } catch (e) {
      _setError('$_errorDeleteItem: ${e.toString()}');
      return false;
    } finally {
      _clearDeletingState();
    }
  }

  bool _canPerformDeleteOperation() {
    if (_disposed || _cartRouteInternshipConsultation == null) return false;
    if (_isCancelling) return false;
    if (!canCancelItems) {
      _errorMessage = _errorCartNotInSeparation;
      return false;
    }
    return true;
  }

  void _setDeletingState(String itemId) {
    _isCancelling = true;
    _cancellingItemId = itemId;
    _safeNotifyListeners();
  }

  void _clearDeletingState() {
    _isCancelling = false;
    _cancellingItemId = null;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
  }

  DeleteItemSeparationParams _createDeleteParams(SeparationItemConsultationModel item) {
    return DeleteItemSeparationParams(
      codEmpresa: _cartRouteInternshipConsultation!.codEmpresa,
      codSepararEstoque: _cartRouteInternshipConsultation!.codOrigem,
      item: item.item,
    );
  }

  void startCartEventMonitoring() {
    if (_disposed || _cartRouteInternshipConsultation == null) return;
    _registerCartEventListener();
  }

  void stopCartEventMonitoring() {
    if (_disposed) return;
    _unregisterCartEventListener();
  }

  void _registerCartEventListener() {
    if (_disposed || _cartEventListenersRegistered || _cartRouteInternshipConsultation == null) return;

    try {
      _cartEventRepository.addListener(
        EventListenerModel(id: _cartUpdateListenerId, event: Event.update, callback: _onCartEvent, allEvent: false),
      );

      _cartEventListenersRegistered = true;
    } catch (e) {}
  }

  void _unregisterCartEventListener() {
    if (!_cartEventListenersRegistered) return;

    try {
      _cartEventRepository.removeListener(_cartUpdateListenerId);
      _cartEventListenersRegistered = false;
    } catch (e) {}
  }

  void _onCartEvent(BasicEventModel event) {
    if (_disposed || _cartRouteInternshipConsultation == null) return;

    try {
      _processCartEventData(event);
    } catch (e) {}
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
    } catch (e) {}
  }

  void _handleCartUpdate(ExpeditionCartRouteInternshipConsultationModel cartData) {
    if (_disposed || _cartRouteInternshipConsultation == null) return;

    if (!_isSameCart(cartData)) return;

    final oldSituation = _cartRouteInternshipConsultation!.situacao.code;
    final newSituation = cartData.situacao.code;

    if (oldSituation != newSituation) {
      _cartStatusChanged = true;
      _cartRouteInternshipConsultation = cartData;
      _safeNotifyListeners();
    }
  }

  bool _isSameCart(ExpeditionCartRouteInternshipConsultationModel cartData) {
    return cartData.codEmpresa == _cartRouteInternshipConsultation!.codEmpresa &&
        cartData.codCarrinhoPercurso == _cartRouteInternshipConsultation!.codCarrinhoPercurso &&
        cartData.item == _cartRouteInternshipConsultation!.item;
  }
}
