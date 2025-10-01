import 'package:flutter/foundation.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_usecase.dart';
import 'package:exp/domain/usecases/cancel_item_separation/cancel_item_separation_params.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/expedition_item_situation_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';

/// ViewModel para gerenciar a lista de produtos separados
/// Os produtos são ordenados por ordem de inclusão decrescente (mais recente primeiro)
class SeparatedProductsViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparationItemConsultationModel> _repository;
  final CancelItemSeparationUseCase _cancelItemSeparationUseCase;

  ExpeditionCartRouteInternshipConsultationModel? _cartRouteInternshipConsultation;
  ExpeditionCartRouteInternshipConsultationModel? get cartRouteInternshipConsultation =>
      _cartRouteInternshipConsultation;

  // Estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de erro
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Lista de itens separados
  List<SeparationItemConsultationModel> _items = [];
  List<SeparationItemConsultationModel> get items => List.unmodifiable(_items);
  bool get hasItems => _items.isNotEmpty;

  // Contadores
  int get totalItems => _items.length;
  double get totalQuantity => _items.fold(0.0, (sum, item) => sum + item.quantidade);

  // Flag para evitar dispose durante operações
  bool _disposed = false;

  // Modo somente leitura
  bool _isReadOnly = false;
  bool get isReadOnly => _isReadOnly;

  // Estado de cancelamento
  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  String? _cancellingItemId;
  String? get cancellingItemId => _cancellingItemId;

  // Construtor
  SeparatedProductsViewModel()
    : _repository = locator<BasicConsultationRepository<SeparationItemConsultationModel>>(),
      _cancelItemSeparationUseCase = locator<CancelItemSeparationUseCase>();

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

  /// Carrega os produtos separados do carrinho
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
      _safeNotifyListeners();

      // Construir query com parâmetros do carrinho
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', cart.codEmpresa.toString())
        ..equals('CodSepararEstoque', cart.codOrigem.toString())
        ..equals('CodCarrinhoPercurso', cart.codCarrinhoPercurso.toString())
        ..equals('ItemCarrinhoPercurso', cart.item);

      // Buscar itens separados
      final items = await _repository.selectConsultation(queryBuilder);

      // Ordenação por ordem de inclusão decrescente (mais recente primeiro)
      items.sort((a, b) {
        // Primeiro, comparar por data de separação
        final dateComparison = b.dataSeparacao.compareTo(a.dataSeparacao);
        if (dateComparison != 0) return dateComparison;

        // Se as datas forem iguais, comparar por hora de separação
        return b.horaSeparacao.compareTo(a.horaSeparacao);
      });

      _items = items;

      if (kDebugMode) {
        // Produtos separados carregados
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao carregar produtos separados: ${e.toString()}';

      if (kDebugMode) {
        // Erro ao carregar produtos separados
      }
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Recarrega os dados
  Future<void> refresh() async {
    if (_disposed || _cartRouteInternshipConsultation == null) return;
    await loadSeparatedProducts(_cartRouteInternshipConsultation!);
  }

  /// Tenta novamente após erro
  Future<void> retry() async {
    if (_disposed || _cartRouteInternshipConsultation == null) return;

    _hasError = false;
    _errorMessage = null;
    await loadSeparatedProducts(_cartRouteInternshipConsultation!);
  }

  /// Filtra itens por separador
  List<SeparationItemConsultationModel> getItemsBySeparador(int codSeparador) {
    return _items.where((item) => item.codSeparador == codSeparador).toList();
  }

  /// Agrupa itens por separador
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

  /// Obtém estatísticas por separador
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

  /// Verifica se um item está sendo cancelado
  bool isItemBeingCancelled(String itemId) => _isCancelling && _cancellingItemId == itemId;

  /// Verifica se o carrinho está em situação que permite cancelamento
  bool get canCancelItems =>
      !_isReadOnly && _cartRouteInternshipConsultation?.situacao == ExpeditionSituation.separando;

  /// Cancela um item específico da separação
  Future<bool> cancelItem(SeparationItemConsultationModel item) async {
    if (_disposed || _cartRouteInternshipConsultation == null) return false;
    if (_isCancelling) return false;
    if (item.situacao == ExpeditionItemSituation.cancelado) return false;
    if (!canCancelItems) {
      _errorMessage = 'Só é possível cancelar itens quando o carrinho está em separação';
      return false;
    }

    try {
      _isCancelling = true;
      _cancellingItemId = item.item;
      _safeNotifyListeners();

      // Criar parâmetros para o use case
      final params = CancelItemSeparationParams(
        codEmpresa: _cartRouteInternshipConsultation!.codEmpresa,
        codSepararEstoque: _cartRouteInternshipConsultation!.codOrigem,
        item: item.item,
      );

      // Executar use case
      final result = await _cancelItemSeparationUseCase.call(params);

      return result.fold(
        (success) async {
          // Recarregar lista após cancelamento bem-sucedido
          await refresh();
          return true;
        },
        (failure) {
          _hasError = true;
          _errorMessage = failure.toString();
          return false;
        },
      );
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao cancelar item: ${e.toString()}';
      return false;
    } finally {
      _isCancelling = false;
      _cancellingItemId = null;
      _safeNotifyListeners();
    }
  }
}
