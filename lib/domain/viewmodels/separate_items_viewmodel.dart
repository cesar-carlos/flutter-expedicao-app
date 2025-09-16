import 'package:flutter/foundation.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/di/locator.dart';

enum SeparateItemsState { initial, loading, loaded, error }

/// ViewModel para separação de itens específicos
class SeparateItemsViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;

  SeparateItemsViewModel()
    : _repository =
          locator<BasicConsultationRepository<SeparateItemConsultationModel>>();

  // === ESTADO ===
  SeparateItemsState _state = SeparateItemsState.initial;
  String? _errorMessage;
  bool _disposed = false;

  // === DADOS DA SEPARAÇÃO ===
  SeparateConsultationModel? _separation;
  List<SeparateItemConsultationModel> _items = [];

  // === GETTERS ===
  SeparateItemsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SeparateItemsState.loading;
  bool get hasError => _state == SeparateItemsState.error;
  bool get hasData => _items.isNotEmpty;

  SeparateConsultationModel? get separation => _separation;
  List<SeparateItemConsultationModel> get items => List.unmodifiable(_items);

  // === ESTATÍSTICAS ===
  int get totalItems => _items.length;
  int get itemsSeparados =>
      _items.where((item) => item.quantidadeSeparacao > 0).length;
  int get itemsPendentes => totalItems - itemsSeparados;
  double get percentualConcluido =>
      totalItems > 0 ? (itemsSeparados / totalItems) * 100 : 0;

  // === MÉTODOS PÚBLICOS ===

  /// Carrega os itens de uma separação específica
  Future<void> loadSeparationItems(SeparateConsultationModel separation) async {
    if (_disposed) return;

    try {
      _setState(SeparateItemsState.loading);
      _clearError();

      _separation = separation;

      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', separation.codEmpresa.toString())
        ..equals('CodSepararEstoque', separation.codSepararEstoque.toString())
        ..orderBy('CodProduto');

      // Query construída corretamente

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;
      _items = items;
      _setState(SeparateItemsState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar itens da separação: ${_getErrorMessage(e)}');
    }
  }

  /// Atualiza os dados
  Future<void> refresh() async {
    if (_separation != null) {
      await loadSeparationItems(_separation!);
    }
  }

  /// Busca um item específico por código ou código de barras
  SeparateItemConsultationModel? findItem(String searchTerm) {
    final term = searchTerm.trim().toLowerCase();

    return _items.cast<SeparateItemConsultationModel?>().firstWhere((item) {
      if (item == null) return false;
      return item.codProduto.toString() == term ||
          (item.codigoBarras?.toLowerCase().contains(term) ?? false) ||
          item.nomeProduto.toLowerCase().contains(term);
    }, orElse: () => null);
  }

  /// Separa um item com validações de negócio
  Future<void> separateItem(
    SeparateItemConsultationModel item,
    double quantidade,
  ) async {
    if (_disposed) return;

    try {
      // Validações baseadas na implementação desktop

      // 1. Validação de quantidade
      if (quantidade <= 0) {
        throw 'Quantidade deve ser maior que zero';
      }

      if (quantidade > item.quantidade) {
        throw 'Quantidade não pode exceder a quantidade disponível (${item.quantidade})';
      }

      // 2. Validação de produto na lista
      if (!_items.any((i) => i.codProduto == item.codProduto)) {
        throw 'Produto não encontrado na lista de separação';
      }

      // TODO: Implementar validação de setor de estoque
      // TODO: Implementar conversão de unidades de medida
      // TODO: Implementar lógica real de separação via API

      await Future.delayed(const Duration(milliseconds: 500));

      // Simula atualização local (em produção seria via API)
      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao separar item: ${_getErrorMessage(e)}');
    }
  }

  /// Valida se produto existe na lista de separação por código ou código de barras
  bool validateProductInSeparation(String searchValue) {
    final trimmedValue = searchValue.trim();

    return _items.any(
      (item) =>
          item.codProduto.toString() == trimmedValue ||
          (item.codigoBarras?.trim() == trimmedValue),
    );
  }

  /// Verifica se separação está completa
  bool get isSeparationComplete {
    return _items.every((item) => item.quantidadeSeparacao > 0);
  }

  /// Separa todos os itens pendentes (equivalente ao F7 do desktop)
  Future<void> separateAllItems() async {
    if (_disposed) return;

    try {
      for (final _ in _items.where((i) => i.quantidadeSeparacao == 0)) {
        // TODO: Implementar separação automática de todos os itens
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _safeNotifyListeners();
    } catch (e) {
      _setError('Erro ao separar todos os itens: ${_getErrorMessage(e)}');
    }
  }

  // === MÉTODOS PRIVADOS ===

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
}
