import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/picking_state.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/separation_item_status.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/filter/pending_products_filters_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';
import 'package:exp/domain/models/event_model/basic_event_model.dart';
import 'package:exp/domain/repositories/separate_cart_internship_event_repository.dart';
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
  // === CONSTANTES ===
  static const String _cartUpdateListenerId = 'card_picking_viewmodel_cart_update';

  // Códigos de situação para carrinho em separação
  static const String _cartInSeparationCode = 'EM SEPARACAO';
  static const String _cartSeparatingCode = 'SEPARANDO';
  // Repository para carregar os itens
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  final FiltersStorageService _filtersStorage;

  // Use case para adicionar itens na separação
  final AddItemSeparationUseCase _addItemSeparationUseCase;

  // Service para obter sessão do usuário
  final UserSessionService _userSessionService;

  // Repository para eventos de carrinho
  final SeparateCartInternshipEventRepository _cartEventRepository;

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

  /// Verifica se há itens disponíveis para o setor do usuário
  bool get hasItemsForUserSector {
    if (_items.isEmpty) return false;

    final userSectorCode = _userModel?.codSetorEstoque;

    // Se usuário não tem setor, todos os itens estão disponíveis
    if (userSectorCode == null) return true;

    // Verificar se há itens sem setor ou do setor do usuário
    return _items.any((item) => item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode);
  }

  // Estado consolidado do picking
  PickingState _pickingState = const PickingState({});
  PickingState get pickingState => _pickingState;

  // Progresso do picking (delegado para PickingState)
  int get totalItems => _pickingState.totalItems;
  int get completedItems => _pickingState.completedItems;
  double get progress => _pickingState.progress;
  bool get isPickingComplete => _pickingState.isComplete;

  /// Verifica se o carrinho está em situação de separação
  bool get isCartInSeparationStatus {
    return _cart?.situacao.code == _cartInSeparationCode || _cart?.situacao.code == _cartSeparatingCode;
  }

  /// Verifica se o status do carrinho mudou durante a sessão
  bool get hasCartStatusChanged => _cartStatusChanged;

  // Flag para evitar dispose durante operações
  bool _disposed = false;

  // === MONITORAMENTO DE EVENTOS DE CARRINHO ===
  bool _cartEventListenersRegistered = false;
  bool _cartStatusChanged = false;

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
      _userSessionService = locator<UserSessionService>(),
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
      _cartStatusChanged = false;
      _safeNotifyListeners();

      // Carregar itens do carrinho através de use case
      await _loadCartItems();

      // Iniciar monitoramento de eventos de carrinho
      startCartEventMonitoring();
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

      return await result.fold(
        (success) async {
          // Atualizar estado local
          _updateLocalPickingState(item.item, quantity);

          // Sincronizar dados com servidor
          await _syncDataWithServer();

          return AddItemSeparationResult.success(
            'Item adicionado: ${success.addedQuantity} unidades',
            addedQuantity: success.addedQuantity,
          );
        },
        (failure) async {
          final errorMsg = failure is AppFailure ? failure.message : failure.toString();
          return AddItemSeparationResult.error(errorMsg);
        },
      );
    } catch (e) {
      return AddItemSeparationResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  /// Atualiza o estado local do picking após adicionar item
  void _updateLocalPickingState(String itemId, int quantity) {
    if (_disposed) return;

    final currentQuantity = _pickingState.getPickedQuantity(itemId);
    final newQuantity = currentQuantity + quantity;
    _pickingState = _pickingState.updateItemQuantity(itemId, newQuantity);
    _safeNotifyListeners();
  }

  /// Sincroniza dados com o servidor após operação bem-sucedida
  Future<void> _syncDataWithServer() async {
    try {
      await refresh();
    } catch (e) {
      // Log do erro mas não falha a operação principal
      if (kDebugMode) {
        debugPrint('Erro ao sincronizar dados com servidor: ${e.toString()}');
      }
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

  /// Ordena itens por setor de estoque e depois por endereço usando ordenação natural
  ///
  /// REGRA DE NEGÓCIO:
  /// 1. Produtos SEM setor (codSetorEstoque == null) aparecem PRIMEIRO para todos os usuários
  /// 2. Depois, produtos DO setor do usuário logado (se o usuário tiver setor)
  /// 3. Dentro de cada grupo (sem setor / com setor), ordenar por endereço (ordenação natural)
  List<SeparateItemConsultationModel> _sortItemsByAddress(List<SeparateItemConsultationModel> items) {
    final userSectorCode = _userModel?.codSetorEstoque;

    return List.from(items)..sort((a, b) {
      final sectorA = a.codSetorEstoque;
      final sectorB = b.codSetorEstoque;

      // Priorizar produtos sem setor definido (aparecem primeiro)
      if (sectorA == null && sectorB != null) return -1;
      if (sectorA != null && sectorB == null) return 1;

      // Se usuário tem setor definido, agrupar produtos do mesmo setor
      if (userSectorCode != null && sectorA != null && sectorB != null) {
        final isASameUserSector = sectorA == userSectorCode;
        final isBSameUserSector = sectorB == userSectorCode;

        // Priorizar produtos do setor do usuário
        if (isASameUserSector && !isBSameUserSector) return -1;
        if (!isASameUserSector && isBSameUserSector) return 1;
      }

      // Dentro do mesmo grupo (sem setor / mesmo setor), ordenar por endereço
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

  // === MÉTODOS DE MONITORAMENTO DE EVENTOS DE CARRINHO ===

  /// Inicia o monitoramento de eventos de carrinho
  void startCartEventMonitoring() {
    if (_disposed || _cart == null) return;
    _registerCartEventListener();
  }

  /// Para o monitoramento de eventos de carrinho
  void stopCartEventMonitoring() {
    if (_disposed) return;
    _unregisterCartEventListener();
  }

  /// Registra o listener para eventos de atualização de carrinho
  void _registerCartEventListener() {
    if (_disposed || _cartEventListenersRegistered || _cart == null) return;

    try {
      _cartEventRepository.addListener(
        EventListenerModel(id: _cartUpdateListenerId, event: Event.update, callback: _onCartEvent, allEvent: false),
      );

      _cartEventListenersRegistered = true;
    } catch (e) {
      // Erro ao registrar listener - continuar sem eventos
    }
  }

  /// Remove o listener de eventos de carrinho
  void _unregisterCartEventListener() {
    if (!_cartEventListenersRegistered) return;

    try {
      _cartEventRepository.removeListener(_cartUpdateListenerId);
      _cartEventListenersRegistered = false;
    } catch (e) {
      // Erro ao remover listener - continuar
    }
  }

  /// Callback chamado quando há evento de carrinho
  void _onCartEvent(BasicEventModel event) {
    if (_disposed || _cart == null) return;

    try {
      _processCartEventData(event);
    } catch (e) {
      // Erro ao processar evento - continuar
    }
  }

  /// Processa os dados do evento de carrinho
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
      // Erro ao processar dados - continuar
    }
  }

  /// Processa evento de atualização de carrinho
  void _handleCartUpdate(ExpeditionCartRouteInternshipConsultationModel cartData) {
    if (_disposed || _cart == null) return;

    // Verificar se é o mesmo carrinho
    if (!_isSameCart(cartData)) return;

    // Verificar se a situação mudou
    final oldSituation = _cart!.situacao.code;
    final newSituation = cartData.situacao.code;

    if (oldSituation != newSituation) {
      _cartStatusChanged = true;
      _cart = cartData;
      _safeNotifyListeners();
    }
  }

  /// Verifica se o carrinho do evento corresponde ao carrinho atual
  bool _isSameCart(ExpeditionCartRouteInternshipConsultationModel cartData) {
    return cartData.codEmpresa == _cart!.codEmpresa &&
        cartData.codCarrinhoPercurso == _cart!.codCarrinhoPercurso &&
        cartData.item == _cart!.item;
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
