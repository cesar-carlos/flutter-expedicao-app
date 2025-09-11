import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/query_builder_extension.dart';
import 'package:exp/domain/repositories/separate_repository.dart';
import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/di/locator.dart';

/// Estados possíveis para a tela de consultas de separação
enum SeparateConsultationState { initial, loading, loaded, error }

/// ViewModel para gerenciar o estado da tela de consultas de separação
class ShipmentSeparateConsultationViewModel extends ChangeNotifier {
  final SeparateRepository _repository = locator<SeparateRepository>();

  SeparateConsultationState _state = SeparateConsultationState.initial;
  List<SeparateConsultationModel> _consultations = [];
  String _searchQuery = '';
  String? _situacaoFilter;
  String? _errorMessage;
  int _currentPage = 0;
  int _pageSize = 20;
  bool _hasMoreData = true;
  bool _disposed = false;

  // Getters
  SeparateConsultationState get state => _state;
  List<SeparateConsultationModel> get consultations => _consultations;
  String get searchQuery => _searchQuery;
  String? get selectedSituacaoFilter => _situacaoFilter;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SeparateConsultationState.loading;
  bool get hasError => _state == SeparateConsultationState.error;
  bool get hasData => _consultations.isNotEmpty;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMoreData => _hasMoreData;

  /// Consultas filtradas baseadas na pesquisa e filtros
  List<SeparateConsultationModel> get filteredConsultations {
    var filtered = _consultations;

    // Aplicar filtro de situação
    if (_situacaoFilter != null) {
      filtered = filtered.where((consultation) {
        return consultation.situacao.toUpperCase() ==
            _situacaoFilter!.toUpperCase();
      }).toList();
    }

    // Aplicar filtro de pesquisa
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((consultation) {
        return _matchesSearchQuery(consultation, query);
      }).toList();
    }

    return filtered;
  }

  /// Verifica se uma consulta corresponde à query de pesquisa
  bool _matchesSearchQuery(
    SeparateConsultationModel consultation,
    String query,
  ) {
    return consultation.codSepararEstoque.toString().contains(query) ||
        consultation.nomeTipoOperacaoExpedicao.toLowerCase().contains(query) ||
        consultation.nomeEntidade.toLowerCase().contains(query) ||
        (consultation.observacao?.toLowerCase().contains(query) ?? false) ||
        (consultation.historico?.toLowerCase().contains(query) ?? false);
  }

  /// Carrega as consultas do repositório
  Future<void> loadConsultations() async {
    if (_disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // Reset pagination
      _currentPage = 0;
      _hasMoreData = true;

      // Cria um QueryBuilder com paginação padrão
      final queryBuilder = QueryBuilderExtension.withDefaultPagination(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final consultations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      _consultations = consultations;
      _hasMoreData = consultations.length == _pageSize;
      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar consultas: ${e.toString()}');
    }
  }

  /// Executa uma consulta com parâmetros específicos
  Future<void> performConsultation([QueryBuilder? queryBuilder]) async {
    if (_disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // Reset pagination
      _currentPage = 0;
      _hasMoreData = true;

      // Se não foi fornecido um QueryBuilder, cria um com paginação padrão
      final builder =
          queryBuilder ??
          QueryBuilderExtension.withDefaultPagination(
            limit: _pageSize,
            offset: _currentPage * _pageSize,
          );

      final consultations = await _repository.selectConsultation(builder);

      if (_disposed) return;

      _consultations = consultations;
      _hasMoreData = consultations.length == _pageSize;
      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao executar consulta: ${e.toString()}');
    }
  }

  /// Define a query de pesquisa
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _safeNotifyListeners();
    }
  }

  /// Define o filtro de situação
  void setSituacaoFilter(String? situacao) {
    if (_situacaoFilter != situacao) {
      _situacaoFilter = situacao;
      _safeNotifyListeners();
    }
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchQuery = '';
    _situacaoFilter = null;
    _safeNotifyListeners();
  }

  /// Limpa apenas a pesquisa
  void clearSearch() {
    _searchQuery = '';
    _safeNotifyListeners();
  }

  /// Limpa apenas o filtro de situação
  void clearSituacaoFilter() {
    _situacaoFilter = null;
    _safeNotifyListeners();
  }

  /// Carrega a próxima página de dados
  Future<void> loadNextPage() async {
    if (!_hasMoreData || isLoading || _disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      _currentPage++;
      final queryBuilder = QueryBuilderExtension.withDefaultPagination(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final consultations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      if (consultations.isNotEmpty) {
        _consultations.addAll(consultations);
        _hasMoreData = consultations.length == _pageSize;
      } else {
        _hasMoreData = false;
      }

      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _currentPage--; // Revert page increment on error
      _setError('Erro ao carregar próxima página: ${e.toString()}');
    }
  }

  /// Carrega uma página específica
  Future<void> loadPage(int page) async {
    if (page < 0 || isLoading || _disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      _currentPage = page;
      final queryBuilder = QueryBuilderExtension.withDefaultPagination(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      final consultations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;

      _consultations = consultations;
      _hasMoreData = consultations.length == _pageSize;
      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar página $page: ${e.toString()}');
    }
  }

  /// Define o tamanho da página
  void setPageSize(int size) {
    if (size > 0 && _pageSize != size) {
      _pageSize = size;
      _currentPage = 0;
      _hasMoreData = true;
      _safeNotifyListeners();
    }
  }

  /// Atualiza uma consulta específica
  Future<void> updateConsultation(
    SeparateConsultationModel consultation,
  ) async {
    if (_disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar atualização quando o método estiver disponível no repositório
      // await _repository.updateConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao atualizar consulta: ${e.toString()}');
    }
  }

  /// Remove uma consulta específica
  Future<void> deleteConsultation(
    SeparateConsultationModel consultation,
  ) async {
    if (_disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar remoção quando o método estiver disponível no repositório
      // await _repository.deleteConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao remover consulta: ${e.toString()}');
    }
  }

  /// Cria uma nova consulta
  Future<void> createConsultation(
    SeparateConsultationModel consultation,
  ) async {
    if (_disposed) return;

    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar criação quando o método estiver disponível no repositório
      // await _repository.createConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao criar consulta: ${e.toString()}');
    }
  }

  /// Define o estado atual
  void _setState(SeparateConsultationState newState) {
    if (_state != newState) {
      _state = newState;
      _safeNotifyListeners();
    }
  }

  /// Define um erro
  void _setError(String message) {
    _errorMessage = message;
    _setState(SeparateConsultationState.error);
  }

  /// Limpa o erro atual
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
    }
  }

  /// Reseta o estado do ViewModel
  void resetState() {
    _state = SeparateConsultationState.initial;
    _consultations = [];
    _searchQuery = '';
    _situacaoFilter = null;
    _errorMessage = null;
    _currentPage = 0;
    _pageSize = 20;
    _hasMoreData = true;
    _safeNotifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Notifica os listeners apenas se o ViewModel não foi descartado
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }
}
