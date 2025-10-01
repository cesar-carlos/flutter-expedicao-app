import 'package:flutter/foundation.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/domain/models/separation_item_status.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_items_filters_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_success.dart';
import 'package:exp/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:exp/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/services/filters_storage_service.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/domain/models/carts_filters_model.dart';

enum SeparateItemsState { initial, loading, loaded, error }

/// ViewModel para separação de itens específicos
class SeparateItemsViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateItemConsultationModel> _repository;
  final BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> _cartRepository;
  final BasicRepository<ExpeditionSectorStockModel> _sectorStockRepository;
  final FiltersStorageService _filtersStorage;

  SeparateItemsViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateItemConsultationModel>>(),
      _cartRepository = locator<BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel>>(),
      _sectorStockRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _filtersStorage = locator<FiltersStorageService>();

  // === ESTADO ===
  SeparateItemsState _state = SeparateItemsState.initial;
  String? _errorMessage;
  bool _disposed = false;

  // === DADOS DA SEPARAÇÃO ===
  SeparateConsultationModel? _separation;
  List<SeparateItemConsultationModel> _items = [];

  // === DADOS DOS CARRINHOS ===
  List<ExpeditionCartRouteInternshipConsultationModel> _carts = [];
  bool _cartsLoaded = false;

  // === DADOS DOS SETORES DE ESTOQUE ===
  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;

  // === CANCELAMENTO ===
  bool _isCancelling = false;
  int? _cancellingCartId;
  String? _lastCancelError;

  // === FILTROS ===
  SeparateItemsFiltersModel _itemsFilters = const SeparateItemsFiltersModel();
  CartsFiltersModel _cartsFilters = const CartsFiltersModel();

  // === GETTERS ===
  SeparateItemsState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SeparateItemsState.loading;
  bool get hasError => _state == SeparateItemsState.error;
  bool get hasData => _items.isNotEmpty;

  SeparateConsultationModel? get separation => _separation;
  List<SeparateItemConsultationModel> get items => List.unmodifiable(_items);
  List<ExpeditionCartRouteInternshipConsultationModel> get carts => List.unmodifiable(_carts);

  // === ESTATÍSTICAS ===
  int get totalItems => _items.length;
  int get totalCarts => _carts.length;
  bool get hasCartsData => _carts.isNotEmpty;
  bool get cartsLoaded => _cartsLoaded;

  // === CANCELAMENTO GETTERS ===
  bool get isCancelling => _isCancelling;
  bool isCartBeingCancelled(int cartId) => _isCancelling && _cancellingCartId == cartId;
  String? get lastCancelError => _lastCancelError;
  int get itemsSeparados => _items.where((item) => item.quantidadeSeparacao > 0).length;
  int get itemsPendentes => totalItems - itemsSeparados;
  double get percentualConcluido => totalItems > 0 ? (itemsSeparados / totalItems) * 100 : 0;

  // === FILTROS ===
  SeparateItemsFiltersModel get itemsFilters => _itemsFilters;
  CartsFiltersModel get cartsFilters => _cartsFilters;
  bool get hasActiveItemsFilters => _itemsFilters.isNotEmpty;
  bool get hasActiveCartsFilters => _cartsFilters.isNotEmpty;

  /// Retorna as opções de situação disponíveis para filtro
  List<SeparationItemStatus> get situacaoFilterOptions => SeparationItemStatus.availableForFilter;

  /// Retorna os setores de estoque disponíveis para filtro
  List<ExpeditionSectorStockModel> get availableSectors => List.unmodifiable(_availableSectors);
  bool get sectorsLoaded => _sectorsLoaded;

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
        ..equals('CodSepararEstoque', separation.codSepararEstoque.toString());

      // Aplica filtros salvos do usuário se existirem
      await _applySavedFiltersToQuery(queryBuilder);

      // Buscar itens sem ordenação para ordenar localmente
      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      // Ordenação natural dos endereços
      _items = items
        ..sort((a, b) {
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

      if (_disposed) return;

      // Aplica filtro de situação localmente
      _items = _applySituacaoFilter(items);
      _setState(SeparateItemsState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar itens da separação: ${_getErrorMessage(e)}');
    }
  }

  /// Carrega os carrinhos de uma separação específica
  Future<void> loadSeparationCarts(SeparateConsultationModel separation) async {
    if (_disposed) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodOrigem', separation.codSepararEstoque.toString())
        ..equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
        ..orderByDesc('Item');

      // Aplica filtros salvos de carrinhos se existirem
      await _applySavedCartsFiltersToQuery(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;
      // Ordena os carrinhos por item em ordem decrescente (mais recentes primeiro)
      _carts = carts..sort((a, b) => b.item.compareTo(a.item));
      _cartsLoaded = true;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _cartsLoaded = true;
      notifyListeners();
    }
  }

  /// Atualiza os dados
  Future<void> refresh() async {
    if (_separation != null) {
      await loadSeparationItems(_separation!);
      await loadSeparationCarts(_separation!);
    }
    // Carrega setores apenas uma vez
    if (!_sectorsLoaded) {
      await loadAvailableSectors();
    }
  }

  /// Carrega os setores de estoque disponíveis
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
      // Erro ao carregar setores de estoque
      _sectorsLoaded = true;
      notifyListeners();
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
  Future<void> separateItem(SeparateItemConsultationModel item, double quantidade) async {
    if (_disposed) return;

    try {
      // 1. Validação de quantidade
      if (quantidade <= 0) throw 'Quantidade deve ser maior que zero';

      if (quantidade > item.quantidade) {
        throw 'Quantidade não pode exceder a quantidade disponível (${item.quantidade})';
      }

      // 2. Validação de produto na lista
      if (!_items.any((i) => i.codProduto == item.codProduto)) {
        throw 'Produto não encontrado na lista de separação';
      }

      //await Future.delayed(const Duration(milliseconds: 100));

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
      (item) => item.codProduto.toString() == trimmedValue || (item.codigoBarras?.trim() == trimmedValue),
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

  // === MÉTODOS DE FILTROS ===

  /// Aplica filtros aos itens
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

  /// Aplica filtros aos carrinhos
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

  /// Limpa filtros de itens
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

  /// Limpa filtros de carrinhos
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

  /// Aplica filtros salvos do usuário à query (se existirem)
  Future<void> _applySavedFiltersToQuery(QueryBuilder queryBuilder) async {
    try {
      // Carrega filtros salvos de itens
      final savedItemsFilters = await _filtersStorage.loadSeparateItemsFilters();
      if (savedItemsFilters.isNotEmpty) {
        _itemsFilters = savedItemsFilters;
        _applyItemsFiltersToQuery(queryBuilder);
      }
    } catch (e) {
      // Erro ao aplicar filtros salvos de itens
      // Não quebra a aplicação se houver erro ao carregar filtros
    }
  }

  /// Aplica filtros salvos de carrinhos à query (se existirem)
  Future<void> _applySavedCartsFiltersToQuery(QueryBuilder queryBuilder) async {
    try {
      // Carrega filtros salvos de carrinhos
      final savedCartsFilters = await _filtersStorage.loadCartsFilters();
      if (savedCartsFilters.isNotEmpty) {
        _cartsFilters = savedCartsFilters;
        _applyCartsFiltersToQuery(queryBuilder);
      }
    } catch (e) {
      // Erro ao aplicar filtros salvos de carrinhos
      // Não quebra a aplicação se houver erro ao carregar filtros
    }
  }

  /// Carrega itens com filtros aplicados
  Future<void> _loadFilteredItems() async {
    if (_separation == null) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', _separation!.codEmpresa.toString())
        ..equals('CodSepararEstoque', _separation!.codSepararEstoque.toString());

      // Aplica filtros de itens
      _applyItemsFiltersToQuery(queryBuilder);

      final items = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

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

      // Aplica filtro de situação localmente
      _items = _applySituacaoFilter(items);
    } catch (e) {
      // Erro ao carregar itens filtrados
    }
  }

  /// Carrega carrinhos com filtros aplicados
  Future<void> _loadFilteredCarts() async {
    if (_separation == null) return;

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodOrigem', _separation!.codSepararEstoque.toString())
        ..equals('Origem', ExpeditionOrigem.separacaoEstoque.code)
        ..orderByDesc('Item');

      // Aplica filtros de carrinhos
      _applyCartsFiltersToQuery(queryBuilder);

      final carts = await _cartRepository.selectConsultation(queryBuilder);

      if (_disposed) return;
      // Ordena os carrinhos por item em ordem decrescente (mais recentes primeiro)
      _carts = carts..sort((a, b) => b.item.compareTo(a.item));
    } catch (e) {
      // Erro ao carregar carrinhos filtrados
    }
  }

  /// Aplica filtros de itens à query
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
    // Filtro de situação será aplicado após buscar os dados (filtro local)
  }

  /// Aplica filtro de situação localmente aos itens
  List<SeparateItemConsultationModel> _applySituacaoFilter(List<SeparateItemConsultationModel> items) {
    if (_itemsFilters.situacao == null) {
      return items;
    }

    return items.where((item) {
      final itemSituacao = item.situacaoSeparacao;
      return itemSituacao == _itemsFilters.situacao;
    }).toList();
  }

  /// Aplica filtros de carrinhos à query
  void _applyCartsFiltersToQuery(QueryBuilder queryBuilder) {
    if (_cartsFilters.codCarrinho != null) {
      queryBuilder.like('CodCarrinho', _cartsFilters.codCarrinho!);
    }
    if (_cartsFilters.nomeCarrinho != null) {
      queryBuilder.like('NomeCarrinho', _cartsFilters.nomeCarrinho!);
    }
    if (_cartsFilters.codigoBarrasCarrinho != null) {
      queryBuilder.like('CodigoBarrasCarrinho', _cartsFilters.codigoBarrasCarrinho!);
    }
    if (_cartsFilters.situacao != null) {
      queryBuilder.equals('Situacao', _cartsFilters.situacao!);
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
    queryBuilder.equals('CarrinhoAgrupador', _cartsFilters.carrinhoAgrupador);
  }

  /// Salva filtros de itens
  Future<void> _saveItemsFilters() async {
    try {
      await _filtersStorage.saveSeparateItemsFilters(_itemsFilters);
    } catch (e) {
      // Erro ao salvar filtros de itens
    }
  }

  /// Salva filtros de carrinhos
  Future<void> _saveCartsFilters() async {
    try {
      await _filtersStorage.saveCartsFilters(_cartsFilters);
    } catch (e) {
      // Erro ao salvar filtros de carrinhos
    }
  }

  /// Limpa filtros de itens salvos
  Future<void> _clearItemsFilters() async {
    try {
      await _filtersStorage.clearSeparateItemsFilters();
    } catch (e) {
      // Erro ao limpar filtros de itens
    }
  }

  /// Limpa filtros de carrinhos salvos
  Future<void> _clearCartsFilters() async {
    try {
      await _filtersStorage.clearCartsFilters();
    } catch (e) {
      // Erro ao limpar filtros de carrinhos
    }
  }

  /// Cancela um carrinho
  Future<bool> cancelCart(int codCarrinho) async {
    if (_disposed || _isCancelling) return false;

    try {
      _isCancelling = true;
      _cancellingCartId = codCarrinho;
      _safeNotifyListeners();

      // Buscar o carrinho
      final cartConsultation = _carts.firstWhere((c) => c.codCarrinho == codCarrinho);

      // Obter use case
      final cancelCartUseCase = locator<CancelCartUseCase>();
      final cancelItemSeparationUseCase = locator<CancelCardItemSeparationUseCase>();

      // Criar parâmetros
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

      // Executar cancelamentos em sequência
      // 1. Verificar se há itens para cancelar primeiro
      final hasItemsToCancel = await cancelItemSeparationUseCase.canCancelItems(paramsItemSeparationUseCase);

      CancelCardItemSeparationSuccess? itemSeparationSuccess;

      if (hasItemsToCancel) {
        // Há itens para cancelar - executa o cancelamento
        final resultItemSeparation = await cancelItemSeparationUseCase.call(paramsItemSeparationUseCase);

        itemSeparationSuccess = resultItemSeparation.fold((success) => success, (failure) {
          return null;
        });

        // Se falhou ao cancelar itens existentes, retorna false
        if (itemSeparationSuccess == null) {
          return false;
        }
      }

      // 2. Depois cancela o carrinho percurso
      final resultCancelCart = await cancelCartUseCase.call(paramsCartUseCase);

      return resultCancelCart.fold(
        (success) async {
          // Limpar erro anterior
          _lastCancelError = null;
          // Recarregar dados após sucesso
          if (_separation != null) {
            await loadSeparationCarts(_separation!);
          }
          return true;
        },
        (failure) {
          // Capturar mensagem específica do erro
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
}
