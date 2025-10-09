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
  final String _consultationListenerId = 'separation_viewmodel_consultation';
  final String _updateListListenerId = 'separation_viewmodel_update_list';
  bool _eventListenersRegistered = false;
  bool _consultationListenerRegistered = false;
  bool _updateListListenerRegistered = false;

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
      // Usar LIKE para buscar o setor na lista CSV de setores
      // Ex: CodSetoresEstoque = "1,4" deve encontrar setor 1 ou setor 4
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
    _registerConsultationEventListener();
    _registerUpdateListEventListener();
  }

  /// Para o monitoramento de eventos
  void stopEventMonitoring() {
    if (_disposed) return;
    _unregisterEventListener();
    _unregisterConsultationEventListener();
    _unregisterUpdateListEventListener();
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

  /// Registra o listener para eventos de consulta
  void _registerConsultationEventListener() {
    if (_disposed || _consultationListenerRegistered) return;

    try {
      _eventRepository.addConsultationListener(
        EventListenerModel(
          id: _consultationListenerId,
          event: Event.insert, // Tipo não importa para este listener
          callback: _onConsultationEvent,
          allEvent: true, // Escutar eventos de todas as sessões
        ),
      );
      _consultationListenerRegistered = true;
    } catch (e) {
      // Erro ao registrar listener de consulta - continuar sem eventos
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

  /// Remove o listener de eventos de consulta
  void _unregisterConsultationEventListener() {
    if (!_consultationListenerRegistered) return;

    try {
      _eventRepository.removeConsultationListener(_consultationListenerId);
      _consultationListenerRegistered = false;
    } catch (e) {
      // Erro ao remover listener de consulta - continuar
    }
  }

  /// Registra o listener para eventos de atualização de lista (separar.update.listen)
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
      // Erro ao registrar listener de atualização - continuar sem eventos
    }
  }

  /// Remove o listener de eventos de atualização de lista
  void _unregisterUpdateListEventListener() {
    if (!_updateListListenerRegistered) return;

    try {
      _eventRepository.removeUpdateListener(_updateListListenerId);
      _updateListListenerRegistered = false;
    } catch (e) {
      // Erro ao remover listener de atualização - continuar
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
      // Verificar se o setor selecionado está na lista de setores da separação
      if (!separationData.codSetoresEstoque.contains(_setorEstoqueFilter!.codSetorEstoque)) {
        return false;
      }
    }

    return true;
  }

  /// Callback chamado quando há evento de consulta
  void _onConsultationEvent(BasicEventModel event) {
    if (_disposed || event.data == null) return;

    try {
      _processConsultationEventData(event);
    } catch (e) {
      // Erro ao processar evento de consulta
    }
  }

  /// Callback chamado quando há evento de atualização de lista (separar.update.listen)
  void _onUpdateListEvent(BasicEventModel event) {
    if (_disposed || event.data == null) return;

    try {
      _processUpdateListEventData(event);
    } catch (e) {
      // Erro ao processar evento de atualização
    }
  }

  /// Processa os dados do evento de consulta
  void _processConsultationEventData(BasicEventModel event) {
    _processListEventData(event);
  }

  /// Processa os dados do evento de atualização de lista (separar.update.listen)
  void _processUpdateListEventData(BasicEventModel event) {
    _processListEventData(event);
  }

  /// Processa eventos de lista (consulta e update) de forma genérica
  ///
  /// Este método centraliza o processamento de eventos que contêm arrays de separações,
  /// evitando duplicação de código e melhorando a manutenibilidade.
  void _processListEventData(BasicEventModel event) {
    final dataMap = event.data as Map<String, dynamic>;

    // Verificar se tem array 'Data'
    if (!dataMap.containsKey('Data') || dataMap['Data'] is! List) return;

    final dataList = dataMap['Data'] as List;
    bool hasAnyUpdate = false;

    // Processar cada item do array
    for (final item in dataList) {
      if (item is Map<String, dynamic>) {
        try {
          final separationData = SeparateConsultationModel.fromJson(item);
          if (_handleSeparationUpdate(separationData)) {
            hasAnyUpdate = true;
          }
        } catch (e) {
          // Erro ao parsear separação individual - continuar com próximo item
        }
      }
    }

    // Notificar listeners apenas uma vez se houve alguma mudança
    if (hasAnyUpdate && !_disposed) {
      notifyListeners();
    }
  }

  /// Processa uma separação recebida via evento de lista
  ///
  /// Retorna true se houve mudança na lista (adição ou atualização)
  bool _handleSeparationUpdate(SeparateConsultationModel separationData) {
    if (_disposed) return false;

    // Buscar índice da separação existente
    final index = _findSeparationIndex(separationData);

    if (index != -1) {
      // Separação já existe - verificar se há mudanças relevantes
      return _updateExistingSeparation(index, separationData);
    } else {
      // Separação não existe - verificar se deve adicionar
      return _addNewSeparation(separationData);
    }
  }

  /// Busca o índice de uma separação na lista
  int _findSeparationIndex(SeparateConsultationModel separationData) {
    return _separations.indexWhere(
      (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
    );
  }

  /// Atualiza uma separação existente se houver mudanças relevantes
  ///
  /// Retorna true se houve atualização
  bool _updateExistingSeparation(int index, SeparateConsultationModel newData) {
    final currentData = _separations[index];

    if (_hasRelevantChanges(currentData, newData)) {
      _separations[index] = newData;
      return true;
    }

    return false;
  }

  /// Adiciona uma nova separação se passar pelos filtros ativos
  ///
  /// Retorna true se houve adição
  bool _addNewSeparation(SeparateConsultationModel separationData) {
    if (_shouldAddToCurrentList(separationData)) {
      _separations.insert(0, separationData);
      return true;
    }

    return false;
  }

  /// Verifica se há mudanças relevantes entre duas separações
  ///
  /// Compara apenas os campos que impactam a visualização na UI,
  /// evitando atualizações desnecessárias quando dados irrelevantes mudam.
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
