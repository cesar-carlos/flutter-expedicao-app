import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

/// Controller responsável pelos filtros da lista de separações.
///
/// Extraído de [SeparationViewModel] para isolar:
/// - Estado dos filtros ativos (6 campos)
/// - Persistência (load/save/clear via [IFiltersStorageService])
/// - Tradução dos filtros para `QueryBuilder`
/// - Filtragem exata por setor em memória (`applyExactSetorFilter`)
/// - Decisão de pertencimento de uma separação ao conjunto filtrado
///   (`shouldInclude`)
///
/// Não é `ChangeNotifier`: os setters retornam `true` quando houve
/// mudança que exige `notifyListeners`, e o ViewModel proprietário fica
/// responsável por notificar.
class SeparationFiltersController {
  final IFiltersStorageService _storage;

  String? _codSepararEstoque;
  String? _origem;
  String? _codOrigem;
  List<String>? _situacoes;
  DateTime? _dataEmissao;
  ExpeditionSectorStockModel? _setorEstoque;

  SeparationFiltersController({required IFiltersStorageService storage}) : _storage = storage;

  String? get codSepararEstoque => _codSepararEstoque;
  String? get origem => _origem;
  String? get codOrigem => _codOrigem;
  List<String>? get situacoes => _situacoes;
  DateTime? get dataEmissao => _dataEmissao;
  ExpeditionSectorStockModel? get setorEstoque => _setorEstoque;

  bool get hasActive =>
      _codSepararEstoque != null ||
      _origem != null ||
      _codOrigem != null ||
      (_situacoes != null && _situacoes!.isNotEmpty) ||
      _dataEmissao != null ||
      _setorEstoque != null;

  SeparationFiltersModel get current => SeparationFiltersModel(
    codSepararEstoque: _codSepararEstoque,
    origem: _origem,
    codOrigem: _codOrigem,
    situacoes: _situacoes,
    dataEmissao: _dataEmissao,
    setorEstoque: _setorEstoque,
  );

  bool setCodSepararEstoque(String? codigo) {
    final cleanCodigo = codigo?.trim();
    if (_codSepararEstoque != cleanCodigo) {
      _codSepararEstoque = cleanCodigo?.isNotEmpty == true ? cleanCodigo : null;
      return true;
    }
    return false;
  }

  bool setOrigem(String? origem) {
    if (_origem != origem) {
      _origem = origem?.isNotEmpty == true ? origem : null;
      return true;
    }
    return false;
  }

  bool setCodOrigem(String? codOrigem) {
    final cleanCodOrigem = codOrigem?.trim();
    if (_codOrigem != cleanCodOrigem) {
      _codOrigem = cleanCodOrigem?.isNotEmpty == true ? cleanCodOrigem : null;
      return true;
    }
    return false;
  }

  bool setSituacoes(List<String>? situacoes) {
    _situacoes = situacoes;
    return true;
  }

  bool setDataEmissao(DateTime? dataEmissao) {
    if (_dataEmissao != dataEmissao) {
      _dataEmissao = dataEmissao;
      return true;
    }
    return false;
  }

  bool setSetorEstoque(ExpeditionSectorStockModel? setorEstoque) {
    if (_setorEstoque != setorEstoque) {
      _setorEstoque = setorEstoque;
      return true;
    }
    return false;
  }

  /// Limpa os filtros em memória e remove a persistência.
  Future<void> clear() async {
    _codSepararEstoque = null;
    _origem = null;
    _codOrigem = null;
    _situacoes = null;
    _dataEmissao = null;
    _setorEstoque = null;
    await _clearStorage();
  }

  /// Carrega filtros salvos. Retorna `true` quando havia filtro
  /// persistido (e portanto o ViewModel deve notificar).
  Future<bool> loadSaved() async {
    try {
      final savedFilters = await _storage.loadSeparationFilters();

      if (savedFilters.isNotEmpty) {
        _codSepararEstoque = savedFilters.codSepararEstoque;
        _origem = savedFilters.origem;
        _codOrigem = savedFilters.codOrigem;
        _situacoes = savedFilters.situacoes;
        _dataEmissao = savedFilters.dataEmissao;
        _setorEstoque = savedFilters.setorEstoque;
        return true;
      }
    } catch (e, s) {
      developer.log('Erro ao carregar filtros salvos', error: e, stackTrace: s);
    }
    return false;
  }

  Future<void> save() async {
    try {
      await _storage.saveSeparationFilters(current);
    } catch (e, s) {
      developer.log('Erro ao salvar filtros salvos', error: e, stackTrace: s);
    }
  }

  void applyToQuery(QueryBuilder queryBuilder) {
    if (_codSepararEstoque != null) {
      queryBuilder.equals('CodSepararEstoque', _codSepararEstoque!);
    }

    if (_origem != null) {
      queryBuilder.equals('Origem', _origem!);
    }

    if (_codOrigem != null) {
      queryBuilder.equals('CodOrigem', _codOrigem!);
    }

    if (_situacoes != null && _situacoes!.isNotEmpty) {
      queryBuilder.inList('Situacao', _situacoes!);
    }

    if (_dataEmissao != null) {
      final dateString =
          '${_dataEmissao!.year}-'
          '${_dataEmissao!.month.toString().padLeft(2, '0')}-'
          '${_dataEmissao!.day.toString().padLeft(2, '0')}';
      queryBuilder.like('DataEmissao', '$dateString%');
    }

    if (_setorEstoque != null) {
      queryBuilder.like('CodSetoresEstoque', '%${_setorEstoque!.codSetorEstoque}%');
    }
  }

  List<SeparateConsultationModel> applyExactSetorFilter(List<SeparateConsultationModel> separations) {
    final setorEstoqueFilter = _setorEstoque;
    if (setorEstoqueFilter == null) {
      return separations;
    }

    return separations
        .where((separation) => separation.codSetoresEstoque.contains(setorEstoqueFilter.codSetorEstoque))
        .toList();
  }

  bool shouldInclude(SeparateConsultationModel separationData) {
    if (!hasActive) return true;

    if (_codSepararEstoque != null && separationData.codSepararEstoque.toString() != _codSepararEstoque) {
      return false;
    }

    if (_origem != null && separationData.origem.name != _origem) {
      return false;
    }

    if (_codOrigem != null && separationData.codOrigem.toString() != _codOrigem) {
      return false;
    }

    if (_situacoes != null && _situacoes!.isNotEmpty && !_situacoes!.contains(separationData.situacao.code)) {
      return false;
    }

    if (_dataEmissao != null) {
      final separationDate = separationData.dataEmissao;
      if (separationDate.year != _dataEmissao!.year ||
          separationDate.month != _dataEmissao!.month ||
          separationDate.day != _dataEmissao!.day) {
        return false;
      }
    }

    if (_setorEstoque != null) {
      if (!separationData.codSetoresEstoque.contains(_setorEstoque!.codSetorEstoque)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clearSeparationFilters();
    } catch (e, s) {
      developer.log('Erro ao limpar filtros salvos', error: e, stackTrace: s);
    }
  }
}
