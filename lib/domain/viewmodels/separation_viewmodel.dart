import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';
import 'package:data7_expedicao/domain/repositories/separate_event_repository.dart';
import 'package:data7_expedicao/domain/models/event_model/basic_event_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/services/filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';

enum SeparationState { initial, loading, loaded, error }

class SeparationViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;
  final FiltersStorageService _filtersStorage;
  final BasicRepository<ExpeditionSectorStockModel> _sectorRepository;
  final SeparateEventRepository _eventRepository;
  final AudioService _audioService;

  SeparationViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateConsultationModel>>(),
      _filtersStorage = locator<FiltersStorageService>(),
      _sectorRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _eventRepository = locator<SeparateEventRepository>(),
      _audioService = locator<AudioService>();

  SeparationViewModel.withDependencies(
    this._repository,
    this._filtersStorage,
    this._sectorRepository,
    this._eventRepository,
    this._audioService,
  );

  SeparationState _state = SeparationState.initial;
  List<SeparateConsultationModel> _separations = [];
  String? _errorMessage;
  bool _disposed = false;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  bool _sectorsLoaded = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  String? _codSepararEstoqueFilter;
  String? _origemFilter;
  String? _codOrigemFilter;
  List<String>? _situacoesFilter;
  DateTime? _dataEmissaoFilter;
  ExpeditionSectorStockModel? _setorEstoqueFilter;

  final String _insertListenerId = 'separation_viewmodel_insert';
  final String _updateListenerId = 'separation_viewmodel_update';
  final String _deleteListenerId = 'separation_viewmodel_delete';
  final String _consultationListenerId = 'separation_viewmodel_consultation';
  final String _updateListListenerId = 'separation_viewmodel_update_list';
  bool _eventListenersRegistered = false;
  bool _consultationListenerRegistered = false;
  bool _updateListListenerRegistered = false;

  bool _isScreenVisible = false;

  bool get isScreenVisible => _isScreenVisible;

  void setScreenVisible(bool visible) {
    if (_disposed) return;
    _isScreenVisible = visible;
  }

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
      final dateString =
          '${_dataEmissaoFilter!.year}-'
          '${_dataEmissaoFilter!.month.toString().padLeft(2, '0')}-'
          '${_dataEmissaoFilter!.day.toString().padLeft(2, '0')}';
      queryBuilder.like('DataEmissao', '$dateString%');
    }

    if (_setorEstoqueFilter != null) {
      queryBuilder.like('CodSetoresEstoque', '%${_setorEstoqueFilter!.codSetorEstoque}%');
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

        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao carregar filtros salvos', tag: 'SeparationVM', error: e);
      }
    }
  }

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
      if (kDebugMode) {
        AppLogger.error('Erro ao salvar filtros salvos', tag: 'SeparationVM', error: e);
      }
    }
  }

  Future<void> _clearSavedFilters() async {
    try {
      await _filtersStorage.clearSeparationFilters();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao limpar filtros salvos', tag: 'SeparationVM', error: e);
      }
    }
  }

  SeparationFiltersModel get currentFilters => SeparationFiltersModel(
    codSepararEstoque: _codSepararEstoqueFilter,
    origem: _origemFilter,
    codOrigem: _codOrigemFilter,
    situacoes: _situacoesFilter,
    dataEmissao: _dataEmissaoFilter,
    setorEstoque: _setorEstoqueFilter,
  );

  void startEventMonitoring() {
    if (_disposed) return;
    _registerEventListener();
    _registerConsultationEventListener();
    _registerUpdateListEventListener();
  }

  void stopEventMonitoring() {
    if (_disposed) return;
    _unregisterEventListener();
    _unregisterConsultationEventListener();
    _unregisterUpdateListEventListener();
  }

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
      if (kDebugMode) {
        AppLogger.error('Erro ao registrar evento de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _registerConsultationEventListener() {
    if (_disposed || _consultationListenerRegistered) return;

    try {
      _eventRepository.addConsultationListener(
        EventListenerModel(
          id: _consultationListenerId,
          event: Event.insert,
          callback: _onConsultationEvent,
          allEvent: true,
        ),
      );
      _consultationListenerRegistered = true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao registrar evento de consulta de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _unregisterEventListener() {
    if (!_eventListenersRegistered) return;

    try {
      _eventRepository.removeListeners([_insertListenerId, _updateListenerId, _deleteListenerId]);
      _eventListenersRegistered = false;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao desregistrar evento de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _unregisterConsultationEventListener() {
    if (!_consultationListenerRegistered) return;

    try {
      _eventRepository.removeConsultationListener(_consultationListenerId);
      _consultationListenerRegistered = false;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao desregistrar evento de consulta de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _registerUpdateListEventListener() {
    if (_disposed || _updateListListenerRegistered) return;

    try {
      _eventRepository.addUpdateListener(
        EventListenerModel(
          id: _updateListListenerId,
          event: Event.update,
          callback: _onUpdateListEvent,
          allEvent: true,
        ),
      );
      _updateListListenerRegistered = true;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao registrar evento de atualização de lista', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _unregisterUpdateListEventListener() {
    if (!_updateListListenerRegistered) return;

    try {
      _eventRepository.removeUpdateListener(_updateListListenerId);
      _updateListListenerRegistered = false;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao desregistrar evento de atualização de lista', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _onSeparationEvent(BasicEventModel event) {
    if (_disposed) return;

    try {
      _processEventData(event);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

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
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _handleSeparationEvent(Event eventType, SeparateConsultationModel separationData) {
    if (_disposed) return;

    switch (eventType) {
      case Event.insert:
        _handleNewSeparation(separationData);
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

  void _handleNewSeparation(SeparateConsultationModel separationData) {
    if (!_isScreenVisible) {
      _playNotificationIfNeeded(separationData);
    }
    _separations.insert(0, separationData);
  }

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
      if (!separationData.codSetoresEstoque.contains(_setorEstoqueFilter!.codSetorEstoque)) {
        return false;
      }
    }

    return true;
  }

  void _onConsultationEvent(BasicEventModel event) {
    if (_disposed || event.data == null) return;

    try {
      _processConsultationEventData(event);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de consulta de separação', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _onUpdateListEvent(BasicEventModel event) {
    if (_disposed || event.data == null) return;

    try {
      _processUpdateListEventData(event);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Erro ao processar evento de atualização de lista', tag: 'SeparationVM', error: e);
      }
    }
  }

  void _processConsultationEventData(BasicEventModel event) {
    _processListEventData(event);
  }

  void _processUpdateListEventData(BasicEventModel event) {
    _processListEventData(event);
  }

  void _processListEventData(BasicEventModel event) {
    final dataMap = event.data as Map<String, dynamic>;

    if (!dataMap.containsKey('Data') || dataMap['Data'] is! List) return;

    final dataList = dataMap['Data'] as List;
    bool hasAnyUpdate = false;

    for (final item in dataList) {
      if (item is Map<String, dynamic>) {
        try {
          final separationData = SeparateConsultationModel.fromJson(item);
          if (_handleSeparationUpdate(separationData)) {
            hasAnyUpdate = true;
          }
        } catch (e) {
          if (kDebugMode) {
            AppLogger.error('Erro ao processar evento de separação', tag: 'SeparationVM', error: e);
          }
        }
      }
    }

    if (hasAnyUpdate && !_disposed) {
      notifyListeners();
    }
  }

  bool _handleSeparationUpdate(SeparateConsultationModel separationData) {
    if (_disposed) return false;

    final index = _findSeparationIndex(separationData);

    if (index != -1) {
      return _updateExistingSeparation(index, separationData);
    } else {
      return _addNewSeparation(separationData);
    }
  }

  int _findSeparationIndex(SeparateConsultationModel separationData) {
    return _separations.indexWhere(
      (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
    );
  }

  bool _updateExistingSeparation(int index, SeparateConsultationModel newData) {
    final currentData = _separations[index];

    if (_hasRelevantChanges(currentData, newData)) {
      _separations[index] = newData;
      return true;
    }

    return false;
  }

  bool _addNewSeparation(SeparateConsultationModel separationData) {
    if (_shouldAddToCurrentList(separationData)) {
      if (!_isScreenVisible) {
        _playNotificationIfNeeded(separationData);
      }
      _separations.insert(0, separationData);
      return true;
    }

    return false;
  }

  void _playNotificationIfNeeded(SeparateConsultationModel separationData) {
    if (_shouldAddToCurrentList(separationData)) {
      _audioService.playSuccess();
    }
  }

  bool _hasRelevantChanges(SeparateConsultationModel current, SeparateConsultationModel updated) {
    return current.situacao != updated.situacao ||
        current.nomeEntidade != updated.nomeEntidade ||
        current.nomeTipoOperacaoExpedicao != updated.nomeTipoOperacaoExpedicao ||
        current.nomePrioridade != updated.nomePrioridade ||
        current.horaEmissao != updated.horaEmissao ||
        current.historico != updated.historico ||
        current.observacao != updated.observacao ||
        !listEquals(current.codSetoresEstoque, updated.codSetoresEstoque);
  }
}
