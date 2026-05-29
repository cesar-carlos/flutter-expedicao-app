import 'dart:async';

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
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/core/services/notification_service.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/separation_event_coordinator.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/separation_filters_controller.dart';

enum SeparationState { initial, loading, loaded, error }

class SeparationViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;
  final IFiltersStorageService _filtersStorage;
  final BasicRepository<ExpeditionSectorStockModel> _sectorRepository;
  final SeparateEventRepository _eventRepository;
  final AudioService _audioService;
  final NotificationService _notificationService;

  SeparationViewModel()
    : _repository = locator<BasicConsultationRepository<SeparateConsultationModel>>(),
      _filtersStorage = locator<IFiltersStorageService>(),
      _sectorRepository = locator<BasicRepository<ExpeditionSectorStockModel>>(),
      _eventRepository = locator<SeparateEventRepository>(),
      _audioService = locator<AudioService>(),
      _notificationService = NotificationService() {
    _initControllers();
  }

  SeparationViewModel.withDependencies(
    this._repository,
    this._filtersStorage,
    this._sectorRepository,
    this._eventRepository,
    this._audioService,
    this._notificationService,
  ) {
    _initControllers();
  }

  late final SeparationEventCoordinator _eventCoordinator;
  late final SeparationFiltersController _filtersController;

  void _initControllers() {
    _filtersController = SeparationFiltersController(storage: _filtersStorage);
    _eventCoordinator = SeparationEventCoordinator(
      eventRepository: _eventRepository,
      isDisposed: () => _disposed,
      onSeparationEvent: _handleSeparationEvent,
      onListResyncRequested: () => unawaited(resyncVisibleSeparationsSilently()),
    );
  }

  SeparationState _state = SeparationState.initial;
  List<SeparateConsultationModel> _separations = [];
  String? _errorMessage;
  bool _disposed = false;

  List<ExpeditionSectorStockModel> _availableSectors = [];
  List<ExpeditionSectorStockModel>? _availableSectorsUnmodifiable;
  bool _sectorsLoaded = false;
  bool _isLoadingSectors = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  bool _isScreenVisible = false;
  Timer? _notificationDebounce;
  bool _silentResyncInFlight = false;
  bool _silentResyncQueued = false;

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

  String? get codSepararEstoqueFilter => _filtersController.codSepararEstoque;
  String? get origemFilter => _filtersController.origem;
  String? get codOrigemFilter => _filtersController.codOrigem;
  List<String>? get situacoesFilter => _filtersController.situacoes;
  DateTime? get dataEmissaoFilter => _filtersController.dataEmissao;
  ExpeditionSectorStockModel? get setorEstoqueFilter => _filtersController.setorEstoque;

  List<ExpeditionSectorStockModel> get availableSectors {
    _availableSectorsUnmodifiable ??= List.unmodifiable(_availableSectors);
    return _availableSectorsUnmodifiable!;
  }

  bool get sectorsLoaded => _sectorsLoaded;

  bool get hasActiveFilters => _filtersController.hasActive;

  Future<void> loadSeparations() async {
    if (_disposed || isLoading) return;

    try {
      _setState(SeparationState.loading);
      _clearError();

      if (await _filtersController.loadSaved()) {
        // Bug SSS: usar _safeNotifyListeners para nao chamar
        // notifyListeners apos dispose (esta funcao roda dentro de
        // loadSeparations que e async, e a tela pode ter sido fechada).
        _safeNotifyListeners();
      }

      _currentPage = 0;
      _hasMoreData = true;

      final queryBuilder = _buildQueryWithFilters(0);

      final separations = await _repository.selectConsultation(queryBuilder);
      final filteredSeparations = _filtersController.applyExactSetorFilter(separations);

      if (_disposed) return;
      _separations = filteredSeparations;
      _sortSeparationsNewestFirst();
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

  Future<void> resyncVisibleSeparationsSilently() async {
    if (_disposed) return;

    if (_silentResyncInFlight) {
      _silentResyncQueued = true;
      return;
    }

    if (isLoading || _isLoadingMore) {
      return;
    }

    _silentResyncInFlight = true;
    try {
      final loadedItemCount = (_currentPage + 1) * _pageSize;
      final queryBuilder = _buildQueryWithFilters(0, limitOverride: loadedItemCount);
      final separations = await _repository.selectConsultation(queryBuilder);
      if (_disposed) return;

      final previousKeys = {for (final separation in _separations) _separationKey(separation)};
      final filteredSeparations = _filtersController.applyExactSetorFilter(separations);
      final notificationCandidate = !_isScreenVisible
          ? _selectNewSeparationNotificationCandidate(previousKeys, filteredSeparations)
          : null;

      _separations = filteredSeparations;
      _sortSeparationsNewestFirst();
      _currentPage = filteredSeparations.isEmpty ? 0 : ((filteredSeparations.length - 1) ~/ _pageSize);
      _hasMoreData = separations.length == loadedItemCount;
      _clearError();
      _setState(SeparationState.loaded);

      if (!_disposed && notificationCandidate != null) {
        _playNotificationIfNeeded(notificationCandidate);
      }
    } catch (e, s) {
      if (_disposed) return;
      AppLogger.debug(
        'Falha no resync silencioso da lista de separações',
        tag: 'SeparationVM',
        error: e,
        stackTrace: s,
      );
    } finally {
      if (!_disposed) {
        _silentResyncInFlight = false;
        if (_silentResyncQueued) {
          _silentResyncQueued = false;
          unawaited(resyncVisibleSeparationsSilently());
        }
      }
    }
  }

  Future<void> clearFilters() async {
    await _filtersController.clear();
    await loadSeparations();
  }

  void setCodSepararEstoqueFilter(String? codigo) {
    if (_filtersController.setCodSepararEstoque(codigo)) {
      _safeNotifyListeners();
    }
  }

  void setOrigemFilter(String? origem) {
    if (_filtersController.setOrigem(origem)) {
      _safeNotifyListeners();
    }
  }

  void setCodOrigemFilter(String? codOrigem) {
    if (_filtersController.setCodOrigem(codOrigem)) {
      _safeNotifyListeners();
    }
  }

  void setSituacoesFilter(List<String>? situacoes) {
    if (_filtersController.setSituacoes(situacoes)) {
      _safeNotifyListeners();
    }
  }

  void setDataEmissaoFilter(DateTime? dataEmissao) {
    if (_filtersController.setDataEmissao(dataEmissao)) {
      _safeNotifyListeners();
    }
  }

  void setSetorEstoqueFilter(ExpeditionSectorStockModel? setorEstoque) {
    if (_filtersController.setSetorEstoque(setorEstoque)) {
      _safeNotifyListeners();
    }
  }

  Future<void> loadAvailableSectors() async {
    if (_sectorsLoaded || _disposed || _isLoadingSectors) return;

    try {
      _isLoadingSectors = true;
      final queryBuilder = QueryBuilder()..orderByAsc('Descricao');

      final sectors = await _sectorRepository.select(queryBuilder);

      if (_disposed) return;

      _availableSectorsUnmodifiable = null;
      _availableSectors = sectors;
      _sectorsLoaded = true;
      _safeNotifyListeners();
    } catch (e, s) {
      if (_disposed) return;
      // Bug NNN: antes era catch silencioso. Sem log, falha em
      // loadAvailableSectors deixava a lista vazia sem nenhum
      // feedback (nem para o usuario, nem para o desenvolvedor).
      AppLogger.error('Erro ao carregar setores disponiveis para filtro', tag: 'SeparationVM', error: e, stackTrace: s);
      _availableSectorsUnmodifiable = null;
      _availableSectors = [];
      _sectorsLoaded = false;
    } finally {
      _isLoadingSectors = false;
    }
  }

  Future<void> applyFilters() async {
    await _filtersController.save();
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
      final filteredSeparations = _filtersController.applyExactSetorFilter(moreSeparations);

      if (_disposed) return;

      if (moreSeparations.isNotEmpty) {
        _separations.addAll(filteredSeparations);
        _sortSeparationsNewestFirst();
        _hasMoreData = moreSeparations.length == _pageSize;
      } else {
        _hasMoreData = false;
      }

      _isLoadingMore = false;
      _safeNotifyListeners();
    } catch (e, s) {
      if (_disposed) return;
      // Bug OOO: antes era catch silencioso. Sem log, paginacao
      // falha era invisivel (usuario via skeleton infinito ou lista
      // que nao crescia, sem nenhuma pista do motivo).
      AppLogger.warning(
        'Erro ao carregar mais separacoes (pagina ${_currentPage + 1})',
        tag: 'SeparationVM',
        error: e,
        stackTrace: s,
      );
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
    _notificationDebounce?.cancel();
    _disposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  String _separationKey(SeparateConsultationModel separation) {
    return '${separation.codEmpresa}:${separation.codSepararEstoque}';
  }

  SeparateConsultationModel? _selectNewSeparationNotificationCandidate(
    Set<String> previousKeys,
    List<SeparateConsultationModel> separations,
  ) {
    final newSeparations = separations
        .where((separation) => !previousKeys.contains(_separationKey(separation)))
        .toList();
    if (newSeparations.isEmpty) return null;
    if (previousKeys.isEmpty && newSeparations.length != 1) return null;

    newSeparations.sort((a, b) {
      final byCod = b.codSepararEstoque.compareTo(a.codSepararEstoque);
      if (byCod != 0) return byCod;
      return a.codEmpresa.compareTo(b.codEmpresa);
    });

    return newSeparations.first;
  }

  /// Maior [codSepararEstoque] primeiro (últimas separações no topo).
  /// Também aplicado após carregar/atualizar lista — o socket nem sempre respeita ORDER BY.
  void _sortSeparationsNewestFirst() {
    _separations.sort((a, b) {
      final byCod = b.codSepararEstoque.compareTo(a.codSepararEstoque);
      if (byCod != 0) return byCod;
      return a.codEmpresa.compareTo(b.codEmpresa);
    });
  }

  QueryBuilder _buildQueryWithFilters(int page, {int? limitOverride}) {
    final limit = limitOverride ?? _pageSize;
    final offset = page * limit;

    final queryBuilder = QueryBuilder()
      ..paginate(limit: limit, offset: offset, page: page + 1)
      ..orderByAsc('CodEmpresa')
      ..orderByDesc('CodSepararEstoque');

    _filtersController.applyToQuery(queryBuilder);

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

  SeparationFiltersModel get currentFilters => _filtersController.current;

  void startEventMonitoring() {
    if (_disposed) return;
    _eventCoordinator.start();
  }

  void stopEventMonitoring() {
    if (_disposed) return;
    _eventCoordinator.stop();
  }

  void _handleSeparationEvent(Event eventType, SeparateConsultationModel separationData) {
    if (_disposed) return;

    var hasChanges = false;
    switch (eventType) {
      case Event.insert:
        hasChanges = _handleNewSeparation(separationData);
        break;
      case Event.update:
        hasChanges = _handleSeparationUpdate(separationData);
        break;
      case Event.delete:
        final previousLength = _separations.length;
        _separations.removeWhere(
          (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
        );
        hasChanges = previousLength != _separations.length;
        break;
    }

    if (hasChanges && !_disposed) {
      _sortSeparationsNewestFirst();
      _safeNotifyListeners();
    }
  }

  bool _handleNewSeparation(SeparateConsultationModel separationData) {
    final index = _findSeparationIndex(separationData);
    if (index != -1) {
      return _updateExistingSeparation(
        index,
        separationData,
        shouldBeVisible: _filtersController.shouldInclude(separationData),
      );
    }

    return _addNewSeparation(separationData, shouldBeVisible: _filtersController.shouldInclude(separationData));
  }

  bool _handleSeparationUpdate(SeparateConsultationModel separationData) {
    if (_disposed) return false;

    final index = _findSeparationIndex(separationData);
    final shouldBeVisible = _filtersController.shouldInclude(separationData);

    if (index != -1) {
      return _updateExistingSeparation(index, separationData, shouldBeVisible: shouldBeVisible);
    } else {
      return _addNewSeparation(separationData, shouldBeVisible: shouldBeVisible);
    }
  }

  int _findSeparationIndex(SeparateConsultationModel separationData) {
    return _separations.indexWhere(
      (s) => s.codEmpresa == separationData.codEmpresa && s.codSepararEstoque == separationData.codSepararEstoque,
    );
  }

  bool _updateExistingSeparation(int index, SeparateConsultationModel newData, {required bool shouldBeVisible}) {
    if (!shouldBeVisible) {
      _separations.removeAt(index);
      return true;
    }

    final currentData = _separations[index];

    if (_hasRelevantChanges(currentData, newData)) {
      _separations[index] = newData;
      return true;
    }

    return false;
  }

  bool _addNewSeparation(SeparateConsultationModel separationData, {required bool shouldBeVisible}) {
    if (!shouldBeVisible) return false;

    if (!_isScreenVisible) {
      _playNotificationIfNeeded(separationData);
    }
    _separations.insert(0, separationData);
    return true;
  }

  void _playNotificationIfNeeded(SeparateConsultationModel separationData) {
    if (!_filtersController.shouldInclude(separationData)) return;

    _notificationDebounce?.cancel();
    if (kDebugMode) {
      AppLogger.debug(
        'Som/notificação de nova separação agendados em 5s (cod ${separationData.codSepararEstoque})',
        tag: 'SeparationVM',
      );
    }
    _notificationDebounce = Timer(const Duration(seconds: 5), () {
      if (_disposed) return;

      if (kDebugMode) {
        AppLogger.debug(
          'Disparando som + notificação local (cod ${separationData.codSepararEstoque})',
          tag: 'SeparationVM',
        );
      }

      unawaited(
        _audioService.playNotification().catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha ao reproduzir notificação sonora (nova separação)',
            tag: 'SeparationViewModel',
            error: e,
            stackTrace: s,
          );
        }),
      );
      unawaited(
        _notificationService
            .showNewSeparationNotification(
              codSepararEstoque: separationData.codSepararEstoque,
              nomeEntidade: separationData.nomeEntidade,
              codSetoresEstoque: separationData.codSetoresEstoque,
            )
            .catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha ao exibir notificação de nova separação',
                tag: 'SeparationViewModel',
                error: e,
                stackTrace: s,
              );
            }),
      );
    });
  }

  bool _hasRelevantChanges(SeparateConsultationModel current, SeparateConsultationModel updated) {
    return current.situacao != updated.situacao ||
        current.origem != updated.origem ||
        current.codOrigem != updated.codOrigem ||
        current.nomeEntidade != updated.nomeEntidade ||
        current.tipoEntidade != updated.tipoEntidade ||
        current.nomeTipoOperacaoExpedicao != updated.nomeTipoOperacaoExpedicao ||
        current.nomePrioridade != updated.nomePrioridade ||
        current.dataEmissao != updated.dataEmissao ||
        current.horaEmissao != updated.horaEmissao ||
        current.historico != updated.historico ||
        current.observacao != updated.observacao ||
        !listEquals(current.codSetoresEstoque, updated.codSetoresEstoque);
  }
}
