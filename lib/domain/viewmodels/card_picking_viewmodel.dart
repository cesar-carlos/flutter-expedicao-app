import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/core/results/index.dart';
import 'package:exp/core/validation/common/socket_validation_helper.dart';
import 'package:exp/di/locator.dart';

class CardPickingViewModel extends ChangeNotifier {
  // Repository para carregar os itens
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;

  // Use case para adicionar itens na separação
  final AddItemSeparationUseCase _addItemSeparationUseCase;

  // Service para obter sessão do usuário
  final UserSessionService _userSessionService;

  // Estado do carrinho
  ExpeditionCartRouteInternshipConsultationModel? _cart;
  ExpeditionCartRouteInternshipConsultationModel? get cart => _cart;

  // Modelo do usuário para filtros
  UserSystemModel? _userModel;
  UserSystemModel? get userModel => _userModel;

  // Estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de erro
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Lista de itens do picking
  List<SeparateItemConsultationModel> _items = [];
  List<SeparateItemConsultationModel> get items => List.unmodifiable(_items);
  bool get hasItems => _items.isNotEmpty;

  // Estado do picking
  final Map<String, int> _pickedQuantities = {}; // Quantidade separada por item
  final Map<String, bool> _itemsCompleted = {}; // Itens completados

  // Progresso do picking
  int get totalItems => _items.length;
  int get completedItems => _itemsCompleted.values.where((completed) => completed).length;
  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;
  bool get isPickingComplete => completedItems == totalItems && totalItems > 0;

  // Flag para evitar dispose durante operações
  bool _disposed = false;

  // Construtor
  CardPickingViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      _addItemSeparationUseCase = locator<AddItemSeparationUseCase>(),
      _userSessionService = locator<UserSessionService>();

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

  /// Inicializa o carrinho e carrega os dados necessários
  Future<void> initializeCart(ExpeditionCartRouteInternshipConsultationModel cart, {UserSystemModel? userModel}) async {
    if (_disposed) return;

    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _cart = cart;
      _userModel = userModel;
      _safeNotifyListeners();

      // Carregar itens do carrinho através de use case
      await _loadCartItems();
    } catch (e) {
      _hasError = true;
      _errorMessage = 'Erro ao inicializar dados do picking: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Carrega os itens do carrinho para picking
  Future<void> _loadCartItems() async {
    if (_cart == null) return;

    try {
      final codEmpresa = _cart!.codEmpresa;
      final codSepararEstoque = _cart!.codOrigem; // Usando codOrigem como codSepararEstoque
      final codSetorEstoqueUsuario = _userModel?.codSetorEstoque;

      List<SeparateItemConsultationModel> items = [];

      if (codSetorEstoqueUsuario != null) {
        // Implementar filtro OR: produtos do setor do usuário OU produtos sem setor específico (NULL)
        // Buscar todos os produtos e filtrar manualmente
        final queryNoSector = QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codSepararEstoque.toString())
          ..orderBy('EnderecoDescricao');

        final allItems = await _repository.selectConsultation(queryNoSector);

        // Filtrar manualmente produtos que não têm setor definido ou têm o setor do usuário
        final filteredItems = allItems.where((item) {
          return item.codSetorEstoque == null || item.codSetorEstoque == codSetorEstoqueUsuario;
        }).toList();

        items = filteredItems;
      } else {
        // Se o usuário não tem setor definido, busca todos os produtos
        final queryBuilder = QueryBuilder()
          ..equals('CodEmpresa', codEmpresa.toString())
          ..equals('CodSepararEstoque', codSepararEstoque.toString())
          ..orderBy('EnderecoDescricao');

        items = await _repository.selectConsultation(queryBuilder);
      }

      if (_disposed) return;

      _items = items;

      // Inicializar estado dos itens
      for (var item in _items) {
        final itemId = item.item;
        _pickedQuantities[itemId] = item.quantidadeSeparacao.toInt();
        _itemsCompleted[itemId] = item.isCompletamenteSeparado;
      }

      print('🚀 Carrinho inicializado: ${_items.length} itens');
      print('📊 Progresso inicial: $completedItems/$totalItems (${(progress * 100).toInt()}%)');

      // Notificar listeners após carregar os itens
      _safeNotifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Adiciona item escaneado na separação usando o use case
  Future<AddItemSeparationResult> addScannedItem({required int codProduto, required int quantity}) async {
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');

    try {
      // Buscar o item do produto na lista
      final item = _items.where((item) => item.codProduto == codProduto).firstOrNull;
      if (item == null) {
        return AddItemSeparationResult.error('Produto não encontrado neste carrinho');
      }

      // Obter sessão do usuário
      final appUser = await _userSessionService.loadUserSession();

      if (appUser?.userSystemModel == null) {
        return AddItemSeparationResult.error('Usuário não autenticado');
      }

      final userSystem = appUser!.userSystemModel!;

      // Obter sessionId do socket atual
      final socketValidation = SocketValidationHelper.validateSocketState();
      if (!socketValidation.isValid) {
        return AddItemSeparationResult.error('Socket não está pronto: ${socketValidation.errorMessage}');
      }

      final sessionId = socketValidation.sessionId!;

      // Criar parâmetros para o use case
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

      // Executar use case
      final result = await _addItemSeparationUseCase.call(params);

      return result.fold(
        (success) {
          // Atualizar quantidade local
          final currentQuantity = _pickedQuantities[item.item] ?? 0;
          final newQuantity = currentQuantity + quantity;
          updatePickedQuantity(item.item, newQuantity);

          return AddItemSeparationResult.success(
            'Item adicionado: ${success.addedQuantity} unidades',
            addedQuantity: success.addedQuantity,
          );
        },
        (failure) {
          final errorMsg = failure is AppFailure ? failure.message : failure.toString();
          return AddItemSeparationResult.error(errorMsg);
        },
      );
    } catch (e) {
      return AddItemSeparationResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  /// Atualiza a quantidade separada de um item (uso interno)
  void updatePickedQuantity(String itemId, int quantity) {
    if (_disposed) return;

    _pickedQuantities[itemId] = quantity;

    // Verificar se o item foi completado
    final item = _items.firstWhere((item) => item.item == itemId);
    final totalQuantity = item.quantidade.toInt();
    _itemsCompleted[itemId] = quantity >= totalQuantity;

    print('🔄 Progresso atualizado: $itemId - $quantity/$totalQuantity - Completo: ${_itemsCompleted[itemId]}');
    print('📊 Total: $completedItems/$totalItems (${(progress * 100).toInt()}%)');

    _safeNotifyListeners();
  }

  /// Marca um item como completado
  void completeItem(String itemId) {
    if (_disposed) return;

    final item = _items.firstWhere((item) => item.item == itemId);
    final totalQuantity = item.quantidade.toInt();

    _pickedQuantities[itemId] = totalQuantity;
    _itemsCompleted[itemId] = true;

    _safeNotifyListeners();
  }

  /// Obtém a quantidade separada de um item
  int getPickedQuantity(String itemId) {
    return _pickedQuantities[itemId] ?? 0;
  }

  /// Verifica se um item foi completado
  bool isItemCompleted(String itemId) {
    return _itemsCompleted[itemId] ?? false;
  }

  /// Finaliza o picking do carrinho
  Future<bool> finalizePicking() async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      // Validar se todos os itens foram completados
      if (!isPickingComplete) {
        _hasError = true;
        _errorMessage = 'Não é possível finalizar: ainda há itens pendentes de separação';
        return false;
      }

      // Validar estado do socket para operações de finalização
      final socketValidation = SocketValidationHelper.validateSocketState();
      if (!socketValidation.isValid) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado: ${socketValidation.errorMessage}';
        return false;
      }

      // Validar usuário autenticado
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        _hasError = true;
        _errorMessage = 'Usuário não autenticado';
        return false;
      }

      // TODO: Implementar use case específico para finalização quando necessário
      // Por enquanto, apenas validamos que todos os itens foram separados

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

  /// Cancela o picking do carrinho
  Future<bool> cancelPicking() async {
    if (_disposed) return false;

    try {
      _isLoading = true;
      _safeNotifyListeners();

      // Validar estado do socket para operações de cancelamento
      final socketValidation = SocketValidationHelper.validateSocketState();
      if (!socketValidation.isValid) {
        _hasError = true;
        _errorMessage = 'Socket não está conectado: ${socketValidation.errorMessage}';
        return false;
      }

      // Validar usuário autenticado
      final appUser = await _userSessionService.loadUserSession();
      if (appUser?.userSystemModel == null) {
        _hasError = true;
        _errorMessage = 'Usuário não autenticado';
        return false;
      }

      // TODO: Implementar use case específico para cancelamento quando necessário
      // Por enquanto, apenas validamos as condições básicas

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

  /// Recarrega os dados
  Future<void> refresh() async {
    if (_disposed || _cart == null) return;

    await initializeCart(_cart!);
  }

  /// Tenta novamente após erro
  Future<void> retry() async {
    if (_disposed || _cart == null) return;

    _hasError = false;
    _errorMessage = null;
    await initializeCart(_cart!);
  }
}

/// Resultado da operação de adicionar item
class AddItemSeparationResult {
  final bool isSuccess;
  final String message;
  final double? addedQuantity;

  AddItemSeparationResult.success(this.message, {this.addedQuantity}) : isSuccess = true;

  AddItemSeparationResult.error(this.message) : isSuccess = false, addedQuantity = null;
}
