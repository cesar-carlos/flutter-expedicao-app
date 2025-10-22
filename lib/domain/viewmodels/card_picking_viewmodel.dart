import 'dart:async' show Future, StreamController, Stream;
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
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// ViewModel para gerenciar o estado do picking de um carrinho
///
/// Responsabilidades:
/// - Gerenciar o ciclo de vida dos itens do carrinho durante o picking
/// - Coordenar a adição de itens através de UseCases (com atualização otimista)
/// - Manter o estado sincronizado com o servidor
/// - Monitorar eventos de atualização do carrinho em tempo real
/// - Gerenciar filtros e ordenação dos itens
/// - Gerenciar fila de operações pendentes e sincronização em background
///
/// Características de Performance:
/// - Cache O(1) para busca de itens por código de produto
/// - Estado consolidado para evitar recalculos
/// - Execução paralela de validações
/// - Atualização otimista (feedback instantâneo)
/// - Sincronização em background sem bloquear UI
/// - Detecção automática de mudança de produto com refresh
///
/// Os produtos são ordenados por endereço usando ordenação natural (01, 02, 10, 11, etc.)
class CardPickingViewModel extends ChangeNotifier {
  // === CONSTANTES ===

  /// ID único para listener de eventos de atualização do carrinho
  static const String _cartUpdateListenerId = 'card_picking_viewmodel_cart_update';

  /// Códigos de situação para carrinho em processo de separação
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
  final ShelfScanningService _shelfScanningService;

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

  /// 🚀 Cache para busca O(1) de itens por código de produto
  ///
  /// Este cache é reconstruído sempre que a lista de itens é atualizada
  /// para garantir performance na validação e adição de itens escaneados.
  Map<int, SeparateItemConsultationModel>? _itemsByCodProduto;

  /// Rastreamento do último produto escaneado para detectar mudança
  int? _lastScannedCodProduto;

  /// Rastreamento do último endereço escaneado para detectar mudança de prateleira
  String? get lastScannedAddress => _shelfScanningService.lastScannedAddress;

  /// Fila de operações pendentes por item (itemId para List de Future)
  final Map<String, List<Future<void>>> _pendingOperations = {};

  /// Stream controller para notificar erros de operação
  final StreamController<OperationError> _errorController = StreamController<OperationError>.broadcast();

  /// Stream de erros de operações assíncronas
  Stream<OperationError> get operationErrors => _errorController.stream;

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

  /// Verifica se o usuário deve escanear prateleira
  bool get requiresShelfScanning => _shelfScanningService.requiresShelfScanning(_userModel);

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

  // === VALIDAÇÃO DE PRATELEIRA ===

  /// Verifica se deve escanear prateleira para o próximo item
  bool shouldScanShelf(SeparateItemConsultationModel nextItem) {
    return _shelfScanningService.shouldScanShelf(nextItem, _userModel);
  }

  /// Atualiza o endereço escaneado
  void updateScannedAddress(String address) {
    _shelfScanningService.updateScannedAddress(address);
    _safeNotifyListeners();
  }

  /// Reseta o endereço escaneado
  void resetScannedAddress() {
    _shelfScanningService.resetScannedAddress();
  }

  // Construtor
  CardPickingViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _filtersStorage = locator<FiltersStorageService>(),
      _addItemSeparationUseCase = locator<AddItemSeparationUseCase>(),
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
      _shelfScanningService.resetScannedAddress(); // Resetar endereço escaneado
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

  /// Verifica se deve mostrar o modal de escaneamento de prateleira na inicialização
  ///
  /// Retorna o próximo item se o usuário precisa escanear prateleira e há um item com endereço
  SeparateItemConsultationModel? shouldShowInitialShelfScan() {
    return _shelfScanningService.shouldShowInitialShelfScan(
      _items,
      _userModel,
      () => PickingUtils.findNextItemToPick(_items, isItemCompleted, userSectorCode: _userModel?.codSetorEstoque),
    );
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

  /// Adiciona item escaneado na separação usando estratégia otimista
  ///
  /// Este método coordena a adição de um item com atualização imediata:
  /// 1. Validações rápidas (item na lista)
  /// 2. Validações paralelas (usuário, socket)
  /// 3. Detecta mudança de produto e aguarda operações pendentes
  /// 4. Atualização LOCAL IMEDIATA (otimista)
  /// 5. Execução do UseCase em BACKGROUND
  /// 6. Tratamento de erro com reversão automática
  ///
  /// Performance:
  /// - Retorno instantâneo (~0ms vs ~220ms)
  /// - Feedback imediato ao usuário
  /// - Enfileiramento de operações
  /// - Sincronização em background
  ///
  /// Returns: [AddItemSeparationResult] com sucesso otimista ou erro de validação
  Future<AddItemSeparationResult> addScannedItem({required int codProduto, required int quantity}) async {
    // Validações rápidas de estado
    if (_disposed) return AddItemSeparationResult.error('ViewModel foi descartado');
    if (_cart == null) return AddItemSeparationResult.error('Carrinho não inicializado');

    try {
      // Buscar o item do produto na lista usando cache O(1)
      final item = _findItemByCodProduto(codProduto);
      if (item == null) return AddItemSeparationResult.error('Produto não encontrado neste carrinho');

      // Executar validações em paralelo para melhor performance
      final futures = <Future<dynamic>>[
        _userSessionService.loadUserSession(),
        Future(() => SocketValidationHelper.validateSocketState()),
      ];

      final results = await Future.wait(futures);
      final appUser = results[0] as dynamic;
      final socketValidation = results[1] as SocketValidationResult;

      // Validar resultados
      if (appUser?.userSystemModel == null) {
        return AddItemSeparationResult.error('Usuário não autenticado');
      }

      if (!socketValidation.isValid) {
        return AddItemSeparationResult.error('Socket não está pronto: ${socketValidation.errorMessage}');
      }

      final userSystem = appUser.userSystemModel;
      final sessionId = socketValidation.sessionId!;

      // Detectar mudança de produto e sincronizar operações pendentes
      if (_lastScannedCodProduto != null && _lastScannedCodProduto != codProduto) {
        await _waitForPendingOperationsAndRefresh();
      }
      _lastScannedCodProduto = codProduto;

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

      // Atualização otimista: atualizar estado local imediatamente
      final timestamp = DateTime.now();
      _updateLocalPickingStateOptimistic(item.item, quantity, timestamp);

      // Disparar operação assíncrona sem await (background)
      _executeAsyncAddItem(params, userSystem, item.item, quantity, timestamp);

      // Retornar sucesso imediato (otimista)
      return AddItemSeparationResult.success('Item adicionado: $quantity unidades', addedQuantity: quantity.toDouble());
    } catch (e) {
      return AddItemSeparationResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  /// Atualiza o estado local do picking de forma otimista (antes do servidor)
  void _updateLocalPickingStateOptimistic(String itemId, int quantity, DateTime timestamp) {
    if (_disposed) return;

    // Calcular nova quantidade e atualizar estado com operação pendente
    final currentQuantity = _pickingState.getPickedQuantity(itemId);
    _pickingState = _pickingState
        .updateItemQuantity(itemId, currentQuantity + quantity)
        .addPendingOperation(itemId, quantity, timestamp);

    _safeNotifyListeners();
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

    // Resetar estado interno para garantir consistência
    _lastScannedCodProduto = null;
    _shelfScanningService.resetScannedAddress(); // Resetar endereço escaneado
    _itemsByCodProduto = null;

    // Preservar o userModel atual durante o refresh
    await initializeCart(_cart!, userModel: _userModel);
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

      // 🚀 Reconstruir cache de busca otimizada
      _rebuildItemsCache();

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

  /// Executa operação assíncrona de adição de item
  Future<void> _executeAsyncAddItem(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    // Criar Future e adicionar à fila
    final operation = _performAddItemOperation(params, userSystem, itemId, quantity, timestamp);

    // Adicionar à fila de operações pendentes
    _pendingOperations.putIfAbsent(itemId, () => []).add(operation);

    // Aguardar conclusão
    await operation;

    // Remover da fila
    _pendingOperations[itemId]?.remove(operation);
    if (_pendingOperations[itemId]?.isEmpty ?? false) {
      _pendingOperations.remove(itemId);
    }
  }

  /// Executa a operação real de adição no servidor
  Future<void> _performAddItemOperation(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    try {
      // Atualizar status para "syncing"
      _updateOperationStatus(itemId, timestamp, PendingOperationStatus.syncing);

      // Executar UseCase
      final result = await _addItemSeparationUseCase.call(params, userSystem: userSystem);

      await result.fold(
        (success) async {
          // Sucesso: marcar como sincronizado
          _updateOperationStatus(itemId, timestamp, PendingOperationStatus.synced);

          // Limpar operações sincronizadas após delay
          Future.delayed(const Duration(seconds: 2), () {
            if (!_disposed) {
              _pickingState = _pickingState.clearSyncedOperations(itemId);
              _safeNotifyListeners();
            }
          });
        },
        (failure) async {
          // Falha: reverter quantidade e marcar erro
          _handleAddItemFailure(itemId, quantity, timestamp, failure);
        },
      );
    } catch (e) {
      _handleAddItemFailure(itemId, quantity, timestamp, e);
    }
  }

  /// Trata falha na adição de item com reversão automática
  void _handleAddItemFailure(String itemId, int quantity, DateTime timestamp, dynamic error) {
    if (_disposed) return;

    // Reverter quantidade local
    final currentQuantity = _pickingState.getPickedQuantity(itemId);
    final revertedQuantity = currentQuantity - quantity;
    final errorMessage = error is AppFailure ? error.userMessage : error.toString();

    _pickingState = _pickingState
        .updateItemQuantity(itemId, revertedQuantity)
        .updateOperationStatus(itemId, timestamp, PendingOperationStatus.failed, errorMessage: errorMessage);

    _safeNotifyListeners();

    // Notificar erro via stream
    _notifyOperationError(itemId, errorMessage);
  }

  /// Atualiza o status de uma operação pendente
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

  /// Aguarda todas as operações pendentes e faz refresh completo
  Future<void> _waitForPendingOperationsAndRefresh() async {
    if (_pendingOperations.isEmpty) return;

    // Aguardar todas as operações pendentes
    final allOperations = _pendingOperations.values.expand((list) => list).toList();
    await Future.wait(allOperations, eagerError: false);

    // Fazer refresh completo
    await refresh();
  }

  /// Notifica erro de operação via stream
  void _notifyOperationError(String itemId, String errorMessage) {
    if (!_errorController.isClosed) {
      _errorController.add(OperationError(itemId, errorMessage));
    }
  }

  /// 🚀 Busca otimizada de item por código de produto usando cache
  SeparateItemConsultationModel? _findItemByCodProduto(int codProduto) {
    // Reconstruir cache se necessário
    if (_itemsByCodProduto == null || _itemsByCodProduto!.isEmpty) {
      _rebuildItemsCache();
    }

    return _itemsByCodProduto?[codProduto];
  }

  /// Reconstrói o cache de itens por código de produto
  void _rebuildItemsCache() {
    _itemsByCodProduto = {for (final item in _items) item.codProduto: item};
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

/// Modelo de erro de operação assíncrona
class OperationError {
  final String itemId;
  final String message;

  OperationError(this.itemId, this.message);
}
