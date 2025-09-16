import 'package:flutter/foundation.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/di/locator.dart';

enum SeparationState { initial, loading, loaded, error }

class SeparationViewModel extends ChangeNotifier {
  final BasicConsultationRepository<SeparateConsultationModel> _repository;

  SeparationViewModel()
    : _repository =
          locator<BasicConsultationRepository<SeparateConsultationModel>>();

  SeparationState _state = SeparationState.initial;
  List<SeparateConsultationModel> _separations = [];
  String? _errorMessage;
  bool _disposed = false;

  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  String? _codSepararEstoqueFilter;
  String? _origemFilter;
  String? _codOrigemFilter;
  String? _situacaoFilter;
  DateTime? _dataEmissaoFilter;

  SeparationState get state => _state;

  List<SeparateConsultationModel> get separations =>
      List.unmodifiable(_separations);

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
  String? get situacaoFilter => _situacaoFilter;
  DateTime? get dataEmissaoFilter => _dataEmissaoFilter;

  bool get hasActiveFilters =>
      _codSepararEstoqueFilter != null ||
      _origemFilter != null ||
      _codOrigemFilter != null ||
      _situacaoFilter != null ||
      _dataEmissaoFilter != null;

  Future<void> loadSeparations() async {
    if (_disposed) return;

    try {
      _setState(SeparationState.loading);
      _clearError();

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
    _situacaoFilter = null;
    _dataEmissaoFilter = null;
    await loadSeparations();
  }

  void setCodSepararEstoqueFilter(String? codigo) {
    final cleanCodigo = codigo?.trim();
    if (_codSepararEstoqueFilter != cleanCodigo) {
      _codSepararEstoqueFilter = cleanCodigo?.isNotEmpty == true
          ? cleanCodigo
          : null;
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
      _codOrigemFilter = cleanCodOrigem?.isNotEmpty == true
          ? cleanCodOrigem
          : null;
      _safeNotifyListeners();
    }
  }

  void setSituacaoFilter(String? situacao) {
    if (_situacaoFilter != situacao) {
      _situacaoFilter = situacao?.isNotEmpty == true ? situacao : null;
      _safeNotifyListeners();
    }
  }

  void setDataEmissaoFilter(DateTime? dataEmissao) {
    if (_dataEmissaoFilter != dataEmissao) {
      _dataEmissaoFilter = dataEmissao;
      _safeNotifyListeners();
    }
  }

  Future<void> applyFilters() async {
    await loadSeparations();
  }

  Future<void> loadMoreSeparations() async {
    if (!_hasMoreData || _isLoadingMore || isLoading || _disposed) return;

    try {
      _isLoadingMore = true;
      _safeNotifyListeners();

      _currentPage++;
      final queryBuilder = _buildQueryWithFilters(_currentPage);

      final moreSeparations = await _repository.selectConsultation(
        queryBuilder,
      );

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

    if (_situacaoFilter != null) {
      queryBuilder.equals('Situacao', _situacaoFilter!);
    }

    if (_dataEmissaoFilter != null) {
      // Formatar data como string no formato que o banco espera
      final dateString =
          '${_dataEmissaoFilter!.year}-'
          '${_dataEmissaoFilter!.month.toString().padLeft(2, '0')}-'
          '${_dataEmissaoFilter!.day.toString().padLeft(2, '0')}';
      queryBuilder.like('DataEmissao', '$dateString%');
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
}
