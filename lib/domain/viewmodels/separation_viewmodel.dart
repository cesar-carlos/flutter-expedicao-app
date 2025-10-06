import 'package:flutter/foundation.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/expedition_sector_stock_model.dart';
import 'package:exp/domain/models/filter/separation_filters_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/event_model/event_listener_model.dart';
import 'package:exp/domain/repositories/separate_event_repository.dart';
import 'package:exp/domain/models/event_model/basic_event_model.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/services/filters_storage_service.dart';
import 'package:exp/domain/repositories/basic_repository.dart';

enum SeparationState { initial, loading, loaded, error }

class SeparationViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;
  final FiltersStorageService _filtersStorage;
  final BasicRepository<ExpeditionSectorStockModel> _sectorRepository;
  final SeparateEventRepository _eventRepository;

  SeparationViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateConsultationModel>>(),
      _filtersStorage = locator<FiltersStorageService>(),
      _sectorRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _eventRepository = locator<SeparateEventRepository>();

  // Construtor para testes - permite injeção de dependências
  SeparationViewModel.withDependencies(
    this._repository,
    this._filtersStorage,
    this._sectorRepository,
    this._eventRepository,
  );

  SeparationState _state = SeparationState.initial;
  List<SeparateConsultationModel> _separations = [];
  String? _errorMessage;
  bool _disposed = false;

  // Lista de setores disponíveis
  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  String? _codSepararEstoqueFilter;
  String? _origemFilter;
  String? _codOrigemFilter;
  List<String>? _situacoesFilter; // Mudado de String? para List<String>?
  DateTime? _dataEmissaoFilter;
  ExpeditionSectorStockModel? _setorEstoqueFilter;

  // === CAMPOS DE EVENTOS ===
  final String _insertListenerId = 'separation_viewmodel_insert';
  final String _updateListenerId = 'separation_viewmodel_update';
  final String _deleteListenerId = 'separation_viewmodel_delete';
  bool _eventListenersRegistered = false;

  SeparationState get state => _state;

  List<SeparateConsultationModel> get separations => List.unmodifiable(_separations);

  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == SeparationState.loading;

  bool get hasError => _state == SeparationState.error;

  bool get hasData => _separations.isNotEmpty;

  bool get hasMoreData => _hasMoreData;

  bool get isLoadingMore => _isLoadingMore;

  int get currentPage => _currentPage;

  int get pageSize => _pageSize;

  String? get codSepararEstoqueFilter => _codSepararEstoqueFilter;
  String? get origemFilter => _origemFilter;
  String? get codOrigemFilter => _codOrigemFilter;
  List<String>? get situacoesFilter => _situacoesFilter;
  DateTime? get dataEmissaoFilter => _dataEmissaoFilter;
  ExpeditionSectorStockModel? get setorEstoqueFilter => _setorEstoqueFilter;

  List<ExpeditionSectorStockModel> get availableSectors => List.unmodifiable(_availableSectors);
  bool get sectorsLoaded => _sectorsLoaded;

  bool get hasActiveFilters =>
      _codSepararEstoqueFilter != null ||
      _origemFilter != null ||
      _codOrigemFilter != null ||
      (_situacoesFilter != null && _situacoesFilter!.isNotEmpty) ||
      _dataEmissaoFilter != null ||
      _setorEstoqueFilter != null;

  Future<void> loadSeparations() async {
    if (_disposed) return;

    try {
      _setState(SeparationState.loading);
      _clearError();

      // Carrega filtros salvos antes de fazer a consulta
      await _loadSavedFilters();

      _currentPage = 0;
      _hasMoreData = true;

      final queryBuilder = _buildQueryWithFilters(0);

      final separations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;
      _separations = separations;
      _hasMoreData = separations.length == _pageSize;
      _setState(SeparationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar separações: ${_getErrorMessage(e)}');
    }
  }

  Future<void> refresh() async {
    await loadSeparations();
  }

  Future<void> clearFilters() async {
    _codSepararEstoqueFilter = null;
    _origemFilter = null;
    _codOrigemFilter = null;
    _situacoesFilter = null;
    _dataEmissaoFilter = null;
    _setorEstoqueFilter = null;

    // Limpa os filtros salvos também
    await _clearSavedFilters();
    await loadSeparations();
  }

  void setCodSepararEstoqueFilter(String? codigo) {
    final cleanCodigo = codigo?.trim();
    if (_codSepararEstoqueFilter != cleanCodigo) {
      _codSepararEstoqueFilter = cleanCodigo?.isNotEmpty == true ? cleanCodigo : null;
      _safeNotifyListeners();
    }
  }

  void setOrigemFilter(String? origem) {
    if (_origemFilter != origem) {
      _origemFilter = origem?.isNotEmpty == true ? origem : null;
      _safeNotifyListeners();
    }
  }

  void setCodOrigemFilter(String? codOrigem) {
    final cleanCodOrigem = codOrigem?.trim();
    if (_codOrigemFilter != cleanCodOrigem) {
      _codOrigemFilter = cleanCodOrigem?.isNotEmpty == true ? cleanCodOrigem : null;
      _safeNotifyListeners();
    }
  }

  void setSituacoesFilter(List<String>? situacoes) {
    _situacoesFilter = situacoes;
    _safeNotifyListeners();
  }

  void setDataEmissaoFilter(DateTime? dataEmissao) {
    if (_dataEmissaoFilter != dataEmissao) {
      _dataEmissaoFilter = dataEmissao;
      _safeNotifyListeners();
    }
  }

  void setSetorEstoqueFilter(ExpeditionSectorStockModel? setorEstoque) {
    if (_setorEstoqueFilter != setorEstoque) {
      _setorEstoqueFilter = setorEstoque;
      _safeNotifyListeners();
    }
  }

  /// Carrega os setores de estoque disponíveis
  Future<void> loadAvailableSectors() async {
    if (_sectorsLoaded || _disposed) return;

    try {
      final queryBuilder = QueryBuilder()..orderByAsc('Descricao');

      final sectors = await _sectorRepository.select(queryBuilder);

      if (_disposed) return;

      _availableSectors = sectors;
      _sectorsLoaded = true;
      _safeNotifyListeners();
    } catch (e) {
      _availableSectors = [];
      _sectorsLoaded = false;
    }
  }

  Future<void> applyFilters() async {
    // Salva os filtros atuais antes de aplicar
    await _saveCurrentFilters();
    await loadSeparations();
  }

  Future<void> loadMoreSeparations() async {
    if (!_hasMoreData || _isLoadingMore || isLoading || _disposed) return;

    try {
      _isLoadingMore = true;
      _safeNotifyListeners();

      _currentPage++;
      final queryBuilder = _buildQueryWithFilters(_currentPage);

      final moreSeparations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      if (moreSeparations.isNotEmpty) {
        _separations.addAll(moreSeparations);
        _hasMoreData = moreSeparations.length == _pageSize;
      } else {
        _hasMoreData = false;
      }

      _isLoadingMore = false;
      _safeNotifyListeners();
    } catch (e) {
      if (_disposed) return;
      _currentPage--;
      _isLoadingMore = false;
      _safeNotifyListeners();
    }
  }

  void _setState(SeparationState newState) {
    if (_disposed) return;
    _state = newState;
    _safeNotifyListeners();
  }

  void _setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    _setState(SeparationState.error);
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

  QueryBuilder _buildQueryWithFilters(int page) {
    final queryBuilder = QueryBuilder()
      ..paginate(limit: _pageSize, offset: page * _pageSize, page: page + 1)
      ..orderByDesc('CodSepararEstoque');

    if (_codSepararEstoqueFilter != null) {
      queryBuilder.equals('CodSepararEstoque', _codSepararEstoqueFilter!);
    }

    if (_origemFilter != null) {
      queryBuilder.equals('Origem', _origemFilter!);
    }

    if (_codOrigemFilter != null) {
      queryBuilder.equals('CodOrigem', _codOrigemFilter!);
    }

    if (_situacoesFilter != null && _situacoesFilter!.isNotEmpty) {
      queryBuilder.inList('Situacao', _situacoesFilter!);
    }

    if (_dataEmissaoFilter != null) {
      // Formatar data como string no formato que o banco espera
      final dateString =
          '${_dataEmissaoFilter!.year}-'
          '${_dataEmissaoFilter!.month.toString().padLeft(2, '0')}-'
          '${_dataEmissaoFilter!.day.toString().padLeft(2, '0')}';
      queryBuilder.like('DataEmissao', '$dateString%');
    }

    if (_setorEstoqueFilter != null) {
      queryBuilder.equals('CodSetorEstoque', _setorEstoqueFilter!.codSetorEstoque.toString());
    }

    return queryBuilder;
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

  /// Carrega filtros salvos do armazenamento local
  Future<void> _loadSavedFilters() async {
    try {
      final savedFilters = await _filtersStorage.loadSeparationFilters();

      if (savedFilters.isNotEmpty) {
        _codSepararEstoqueFilter = savedFilters.codSepararEstoque;
        _origemFilter = savedFilters.origem;
        _codOrigemFilter = savedFilters.codOrigem;
        _situacoesFilter = savedFilters.situacoes;
        _dataEmissaoFilter = savedFilters.dataEmissao;
        _setorEstoqueFilter = savedFilters.setorEstoque;

        // Notifica os listeners que os filtros foram carregados
        notifyListeners();
      }
    } catch (e) {
      // Log do erro, mas não quebra a aplicação
    }
  }

  /// Salva os filtros atuais no armazenamento local
  Future<void> _saveCurrentFilters() async {
    try {
      final currentFilters = SeparationFiltersModel(
        codSepararEstoque: _codSepararEstoqueFilter,
        origem: _origemFilter,
        codOrigem: _codOrigemFilter,
        situacoes: _situacoesFilter,
        dataEmissao: _dataEmissaoFilter,
        setorEstoque: _setorEstoqueFilter,
      );

      await _filtersStorage.saveSeparationFilters(currentFilters);
    } catch (e) {
      // Erro ao salvar filtros - não quebra a aplicação
    }
  }

  /// Limpa filtros salvos do armazenamento local
  Future<void> _clearSavedFilters() async {
    try {
      await _filtersStorage.clearSeparationFilters();
    } catch (e) {
      // Erro ao limpar filtros - não quebra a aplicação
    }
  }

  /// Obtém os filtros atuais como modelo
  SeparationFiltersModel get currentFilters => SeparationFiltersModel(
    codSepararEstoque: _codSepararEstoqueFilter,
    origem: _origemFilter,
    codOrigem: _codOrigemFilter,
    situacoes: _situacoesFilter,
    dataEmissao: _dataEmissaoFilter,
    setorEstoque: _setorEstoqueFilter,
  );

  // === MÉTODOS DE EVENTOS ===

  /// Inicia o monitoramento de eventos
  void startEventMonitoring() {
    if (_disposed) return;
    _registerEventListener();
  }

  /// Para o monitoramento de eventos
  void stopEventMonitoring() {
    if (_disposed) return;
    _unregisterEventListener();
  }

  /// Registra os listeners para todos os eventos de separação
  void _registerEventListener() {
    if (_disposed || _eventListenersRegistered) return;

    try {
      _eventRepository.addListener(
        EventListenerModel(id: _insertListenerId, event: Event.insert, callback: _onSeparationEvent, allEvent: false),
      );

      _eventRepository.addListener(
        EventListenerModel(id: _updateListenerId, event: Event.update, callback: _onSeparationEvent, allEvent: false),
      );

      _eventRepository.addListener(
        EventListenerModel(id: _deleteListenerId, event: Event.delete, callback: _onSeparationEvent, allEvent: false),
      );

      _eventListenersRegistered = true;
    } catch (e) {
      // Erro ao registrar listeners - continuar sem eventos
    }
  }

  /// Remove os listeners de eventos
  void _unregisterEventListener() {
    if (!_eventListenersRegistered) return;

    try {
      _eventRepository.removeListeners([_insertListenerId, _updateListenerId, _deleteListenerId]);
      _eventListenersRegistered = false;
    } catch (e) {
      // Erro ao remover listeners - continuar
    }
  }

  /// Callback chamado quando há qualquer evento de separação
  void _onSeparationEvent(BasicEventModel event) {
    if (_disposed) return;

    try {
      _processEventData(event);
    } catch (e) {
      // Erro ao processar evento - continuar
    }
  }

  /// Processa os dados do evento baseado na estrutura recebida
  void _processEventData(BasicEventModel event) {
    if (event.data == null) return;

    try {
      if (event.data is Map<String, dynamic>) {
        final dataMap = event.data as Map<String, dynamic>;

        if (dataMap.containsKey('Mutation') && dataMap['Mutation'] is List) {
          final mutations = dataMap['Mutation'] as List;

          for (final mutation in mutations) {
            if (mutation is Map<String, dynamic>) {
              final separationData = SeparateConsultationModel.fromJson(mutation);
              _handleSeparationEvent(event.eventType, separationData);
            }
          }
        } else {
          final separationData = SeparateConsultationModel.fromJson(dataMap);
          _handleSeparationEvent(event.eventType, separationData);
        }
      }
    } catch (e) {
      // Erro ao processar dados - continuar
    }
  }

  /// Processa eventos de separação baseado no tipo
  void _handleSeparationEvent(Event eventType, SeparateConsultationModel separationData) {
    if (_disposed) return;

    switch (eventType) {
      case Event.insert:
        _separations.insert(0, separationData);
        break;
      case Event.update:
        final index = _separations.indexWhere(
          (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
        );
        if (index != -1) {
          _separations[index] = separationData;
        } else if (_shouldAddToCurrentList(separationData)) {
          _separations.insert(0, separationData);
        }
        break;
      case Event.delete:
        _separations.removeWhere(
          (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
        );
        break;
    }

    if (!_disposed) {
      notifyListeners();
    }
  }

  /// Verifica se uma separação deve ser adicionada à lista atual baseada nos filtros aplicados
  bool _shouldAddToCurrentList(SeparateConsultationModel separationData) {
    if (!hasActiveFilters) return true;

    if (_codSepararEstoqueFilter != null && separationData.codSepararEstoque.toString() != _codSepararEstoqueFilter) {
      return false;
    }

    if (_origemFilter != null && separationData.origem.name != _origemFilter) {
      return false;
    }

    if (_codOrigemFilter != null && separationData.codOrigem.toString() != _codOrigemFilter) {
      return false;
    }

    if (_situacoesFilter != null &&
        _situacoesFilter!.isNotEmpty &&
        !_situacoesFilter!.contains(separationData.situacao.code)) {
      return false;
    }

    if (_dataEmissaoFilter != null) {
      final separationDate = separationData.dataEmissao;
      if (separationDate.year != _dataEmissaoFilter!.year ||
          separationDate.month != _dataEmissaoFilter!.month ||
          separationDate.day != _dataEmissaoFilter!.day) {
        return false;
      }
    }

    if (_setorEstoqueFilter != null) {
      return false; // SeparateConsultationModel não possui codSetorEstoque
    }

    return true;
  }
}
