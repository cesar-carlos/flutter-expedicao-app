import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/repositories/separate_repository.dart';
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

  // Getters
  SeparateConsultationState get state => _state;
  List<SeparateConsultationModel> get consultations => _consultations;
  String get searchQuery => _searchQuery;
  String? get selectedSituacaoFilter => _situacaoFilter;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == SeparateConsultationState.loading;
  bool get hasError => _state == SeparateConsultationState.error;
  bool get hasData => _consultations.isNotEmpty;

  /// Consultas filtradas baseadas na pesquisa e filtros
  List<SeparateConsultationModel> get filteredConsultations {
    var filtered = _consultations;

    // Aplicar filtro de situação
    if (_situacaoFilter != null) {
      filtered = filtered.where((consultation) {
        return consultation.status?.toUpperCase() ==
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
    return (consultation.codigo?.toLowerCase().contains(query) ?? false) ||
        (consultation.descricao?.toLowerCase().contains(query) ?? false) ||
        (consultation.usuario?.toLowerCase().contains(query) ?? false) ||
        (consultation.observacoes?.toLowerCase().contains(query) ?? false);
  }

  /// Carrega as consultas do repositório
  Future<void> loadConsultations() async {
    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      final consultations = await _repository.selectConsultation();

      _consultations = consultations;
      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      _setError('Erro ao carregar consultas: ${e.toString()}');
    }
  }

  /// Executa uma consulta com parâmetros específicos
  Future<void> performConsultation([String params = '']) async {
    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      final consultations = await _repository.selectConsultation(params);

      _consultations = consultations;
      _setState(SeparateConsultationState.loaded);
    } catch (e) {
      _setError('Erro ao executar consulta: ${e.toString()}');
    }
  }

  /// Define a query de pesquisa
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      notifyListeners();
    }
  }

  /// Define o filtro de situação
  void setSituacaoFilter(String? situacao) {
    if (_situacaoFilter != situacao) {
      _situacaoFilter = situacao;
      notifyListeners();
    }
  }

  /// Limpa todos os filtros
  void clearFilters() {
    _searchQuery = '';
    _situacaoFilter = null;
    notifyListeners();
  }

  /// Limpa apenas a pesquisa
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Limpa apenas o filtro de situação
  void clearSituacaoFilter() {
    _situacaoFilter = null;
    notifyListeners();
  }

  /// Atualiza uma consulta específica
  Future<void> updateConsultation(
    SeparateConsultationModel consultation,
  ) async {
    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar atualização quando o método estiver disponível no repositório
      // await _repository.updateConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      _setError('Erro ao atualizar consulta: ${e.toString()}');
    }
  }

  /// Remove uma consulta específica
  Future<void> deleteConsultation(
    SeparateConsultationModel consultation,
  ) async {
    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar remoção quando o método estiver disponível no repositório
      // await _repository.deleteConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      _setError('Erro ao remover consulta: ${e.toString()}');
    }
  }

  /// Cria uma nova consulta
  Future<void> createConsultation(
    SeparateConsultationModel consultation,
  ) async {
    try {
      _setState(SeparateConsultationState.loading);
      _clearError();

      // TODO: Implementar criação quando o método estiver disponível no repositório
      // await _repository.createConsultation(consultation);

      // Por enquanto, apenas recarrega os dados
      await loadConsultations();
    } catch (e) {
      _setError('Erro ao criar consulta: ${e.toString()}');
    }
  }

  /// Define o estado atual
  void _setState(SeparateConsultationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
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
    notifyListeners();
  }
}
