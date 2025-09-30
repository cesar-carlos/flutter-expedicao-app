import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/di/locator.dart';

/// ViewModel para gerenciar a lista de produtos separados
class SeparatedProductsViewModel extends ChangeNotifier {
  // Repository para carregar os itens separados
  final BasicConsultationRepository<SeparationItemConsultationModel> _repository;

  // Estado do carrinho
  ExpeditionCartRouteInternshipConsultationModel? _cart;
  ExpeditionCartRouteInternshipConsultationModel? get cart => _cart;

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

  // Construtor
  SeparatedProductsViewModel() : _repository = locator<BasicConsultationRepository<SeparationItemConsultationModel>>();

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
  Future<void> loadSeparatedProducts(ExpeditionCartRouteInternshipConsultationModel cart) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _cart = cart;
      _safeNotifyListeners();

      // Construir query com parâmetros do carrinho
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', cart.codEmpresa.toString())
        ..equals('CodSepararEstoque', cart.codOrigem.toString())
        ..equals('CodCarrinhoPercurso', cart.codCarrinhoPercurso.toString())
        ..equals('ItemCarrinhoPercurso', cart.item.toString());

      // Buscar itens separados
      final items = await _repository.selectConsultation(queryBuilder);

      // Ordenação natural dos endereços
      items.sort((a, b) {
        final endA = a.enderecoDescricao?.toLowerCase() ?? '';
        final endB = b.enderecoDescricao?.toLowerCase() ?? '';

        // Extrair números do início do endereço (01, 02, etc)
        final regExp = RegExp(r'^(\d+)');
        final matchA = regExp.firstMatch(endA);
        final matchB = regExp.firstMatch(endB);

        // Se ambos começam com números, comparar numericamente
        if (matchA != null && matchB != null) {
          final numA = int.parse(matchA.group(1)!);
          final numB = int.parse(matchB.group(1)!);
          if (numA != numB) return numA.compareTo(numB);
        }

        // Se um começa com número e outro não, priorizar o que começa com número
        if (matchA != null && matchB == null) return -1;
        if (matchA == null && matchB != null) return 1;

        // Caso contrário, ordenar alfabeticamente
        return endA.compareTo(endB);
      });

      _items = items;

      if (kDebugMode) {
        print('✅ Produtos separados carregados: ${_items.length} itens');
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao carregar produtos separados: ${e.toString()}';

      if (kDebugMode) {
        print('❌ Erro ao carregar produtos separados: $e');
      }
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Recarrega os dados
  Future<void> refresh() async {
    if (_disposed || _cart == null) return;
    await loadSeparatedProducts(_cart!);
  }

  /// Tenta novamente após erro
  Future<void> retry() async {
    if (_disposed || _cart == null) return;

    _hasError = false;
    _errorMessage = null;
    await loadSeparatedProducts(_cart!);
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
}
