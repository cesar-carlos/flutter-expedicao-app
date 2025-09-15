import 'package:flutter/foundation.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/di/locator.dart';

/// Estados possíveis para a tela de separação
enum SeparationState { initial, loading, loaded, error }

/// ViewModel para gerenciar o estado da tela de separação
class SeparationViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;

  SeparationViewModel()
    : _repository =
          locator<BasicConsultationRepository<SeparateConsultationModel>>();

  SeparationState _state = SeparationState.initial;
  List<SeparateConsultationModel> _separations = [];
  String? _errorMessage;
  bool _disposed = false;

  /// Estado atual da tela
  SeparationState get state => _state;

  /// Lista de separações carregadas
  List<SeparateConsultationModel> get separations =>
      List.unmodifiable(_separations);

  /// Mensagem de erro atual
  String? get errorMessage => _errorMessage;

  /// Indica se está carregando
  bool get isLoading => _state == SeparationState.loading;

  /// Indica se há erro
  bool get hasError => _state == SeparationState.error;

  /// Indica se há dados carregados
  bool get hasData => _separations.isNotEmpty;

  /// Carrega as últimas 50 separações ordenadas por CodSepararEstoque DESC
  Future<void> loadSeparations() async {
    if (_disposed) return;

    try {
      _setState(SeparationState.loading);
      _clearError();

      // QueryBuilder para buscar as últimas 50 separações ordenadas por CodSepararEstoque DESC
      final queryBuilder = QueryBuilder()
        ..paginate(limit: 50, offset: 0, page: 1)
        ..orderByDesc('CodSepararEstoque');

      final separations = await _repository.selectConsultation(queryBuilder);

      if (_disposed) return;
      _separations = separations;
      _setState(SeparationState.loaded);
    } catch (e) {
      if (_disposed) return;
      _setError('Erro ao carregar separações: ${_getErrorMessage(e)}');
    }
  }

  /// Atualiza os dados
  Future<void> refresh() async {
    await loadSeparations();
  }

  /// Limpa os filtros e recarrega
  Future<void> clearFilters() async {
    await loadSeparations();
  }

  /// Define o estado e notifica os listeners
  void _setState(SeparationState newState) {
    if (_disposed) return;
    _state = newState;
    _safeNotifyListeners();
  }

  /// Define uma mensagem de erro e muda o estado para error
  void _setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    _setState(SeparationState.error);
  }

  /// Limpa a mensagem de erro
  void _clearError() {
    if (_disposed) return;
    _errorMessage = null;
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

  /// Extrai uma mensagem de erro legível de qualquer exceção
  String _getErrorMessage(dynamic error) {
    if (error == null) return 'Erro desconhecido';

    // Se for uma instância de AppError, usa a mensagem diretamente
    if (error is AppError) {
      return error.message;
    }

    // Se for uma String, retorna ela
    if (error is String) {
      return error;
    }

    // Para outros tipos, tenta toString() mas com fallback
    try {
      final message = error.toString();
      // Se toString() retorna "Instance of...", usa uma mensagem genérica
      if (message.startsWith('Instance of ')) {
        return 'Erro interno do sistema';
      }
      return message;
    } catch (e) {
      return 'Erro interno do sistema';
    }
  }
}
