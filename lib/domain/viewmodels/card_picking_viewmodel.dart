import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/picking_state.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/separation_item_status.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/pending_products_filters_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:exp/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/core/validation/common/socket_validation_helper.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/services/filters_storage_service.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/core/results/index.dart';
import 'package:exp/di/locator.dart';

/// ViewModel para gerenciar o estado do picking de um carrinho
/// Os produtos são ordenados por endereço usando ordenação natural (01, 02, 10, 11, etc.)
class CardPickingViewModel extends ChangeNotifier {
  // Repository para carregar os itens
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  final FiltersStorageService _filtersStorage;

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

  // Estado consolidado do picking
  PickingState _pickingState = const PickingState({});
  PickingState get pickingState => _pickingState;

  // Progresso do picking (delegado para PickingState)
  int get totalItems => _pickingState.totalItems;
  int get completedItems => _pickingState.completedItems;
  double get progress => _pickingState.progress;
  bool get isPickingComplete => _pickingState.isComplete;

  // Flag para evitar dispose durante operações
  bool _disposed = false;

  // === FILTROS ===
  PendingProductsFiltersModel _filters = const PendingProductsFiltersModel();
  PendingProductsFiltersModel get filters => _filters;
  bool get hasActiveFilters => _filters.isNotEmpty;

  // === SETORES DE ESTOQUE ===
  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;
  List<ExpeditionSectorStockModel> get availableSectors => List.unmodifiable(_availableSectors);
  bool get sectorsLoaded => _sectorsLoaded;

  // === OPÇÕES DE FILTRO DE SITUAÇÃO ===
  List<SeparationItemStatus> get situacaoFilterOptions => [
    SeparationItemStatus.pendente,
    SeparationItemStatus.separado,
    SeparationItemStatus.cancelado,
  ];

  // Construtor
  CardPickingViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _filtersStorage = locator<FiltersStorageService>(),
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

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _safeNotifyListeners();
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
      // Carregar filtros salvos primeiro
      await _loadSavedFilters();

      // Carregar itens com filtros aplicados
      await _loadFilteredItems();
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

      // Executar use case (passando userSystem para evitar recarga)
      final result = await _addItemSeparationUseCase.call(params, userSystem: userSystem);

      return result.fold(
        (success) {
          // Atualizar quantidade local usando PickingState
          final currentQuantity = _pickingState.getPickedQuantity(item.item);
          final newQuantity = currentQuantity + quantity;
          _pickingState = _pickingState.updateItemQuantity(item.item, newQuantity);

          // Notificar listeners para atualizar a UI
          _safeNotifyListeners();

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

    _pickingState = _pickingState.updateItemQuantity(itemId, quantity);
    _safeNotifyListeners();
  }

  /// Marca um item como completado
  void completeItem(String itemId) {
    if (_disposed) return;

    _pickingState = _pickingState.completeItem(itemId);
    _safeNotifyListeners();
  }

  /// Obtém a quantidade separada de um item
  int getPickedQuantity(String itemId) {
    return _pickingState.getPickedQuantity(itemId);
  }

  /// Verifica se um item foi completado
  bool isItemCompleted(String itemId) {
    return _pickingState.isItemCompleted(itemId);
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

  /// Ordena itens por endereço usando ordenação natural
  List<SeparateItemConsultationModel> _sortItemsByAddress(List<SeparateItemConsultationModel> items) {
    return List.from(items)..sort((a, b) {
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
  }

  // === MÉTODOS DE FILTROS ===

  /// Carrega setores de estoque disponíveis
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

  /// Aplica filtros aos produtos pendentes
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

  /// Limpa filtros
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

  /// Carrega itens com filtros aplicados
  Future<void> _loadFilteredItems() async {
    if (_cart == null) return;

    try {
      final codEmpresa = _cart!.codEmpresa;
      final codSepararEstoque = _cart!.codOrigem;
      final codSetorEstoqueUsuario = _userModel?.codSetorEstoque;

      List<SeparateItemConsultationModel> items = [];

      if (codSetorEstoqueUsuario != null) {
        // Implementar filtro OR: produtos do setor do usuário OU produtos sem setor específico (NULL)
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

      // Aplicar filtros locais
      items = _applyLocalFilters(items);

      // Aplicar ordenação natural por endereço
      _items = _sortItemsByAddress(items);

      // Inicializar estado consolidado do picking
      _pickingState = PickingState.initial(_items);

      // Notificar listeners após carregar os itens
      _safeNotifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  /// Aplica filtros locais aos itens
  List<SeparateItemConsultationModel> _applyLocalFilters(List<SeparateItemConsultationModel> items) {
    return items.where((item) {
      // Filtro por código do produto
      if (_filters.codProduto != null && _filters.codProduto!.isNotEmpty) {
        if (!item.codProduto.toString().toLowerCase().contains(_filters.codProduto!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por código de barras
      if (_filters.codigoBarras != null && _filters.codigoBarras!.isNotEmpty) {
        final barcode = item.codigoBarras?.toLowerCase() ?? '';
        if (!barcode.contains(_filters.codigoBarras!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por nome do produto
      if (_filters.nomeProduto != null && _filters.nomeProduto!.isNotEmpty) {
        if (!item.nomeProduto.toLowerCase().contains(_filters.nomeProduto!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por endereço/descrição
      if (_filters.enderecoDescricao != null && _filters.enderecoDescricao!.isNotEmpty) {
        final endereco = item.enderecoDescricao?.toLowerCase() ?? '';
        if (!endereco.contains(_filters.enderecoDescricao!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por setor de estoque
      if (_filters.setorEstoque != null) {
        if (item.codSetorEstoque != _filters.setorEstoque!.codSetorEstoque) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Salva filtros no armazenamento local
  Future<void> _saveFilters() async {
    try {
      await _filtersStorage.savePendingProductsFilters(_filters);
    } catch (e) {
      // Erro ao salvar filtros - não quebra a aplicação
    }
  }

  /// Limpa filtros salvos do armazenamento local
  Future<void> _clearFilters() async {
    try {
      await _filtersStorage.clearPendingProductsFilters();
    } catch (e) {
      // Erro ao limpar filtros - não quebra a aplicação
    }
  }

  /// Carrega filtros salvos do armazenamento local
  Future<void> _loadSavedFilters() async {
    try {
      final savedFilters = await _filtersStorage.loadPendingProductsFilters();
      if (savedFilters != null) {
        _filters = savedFilters;
        notifyListeners();
      }
    } catch (e) {
      // Log do erro, mas não quebra a aplicação
    }
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
