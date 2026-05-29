import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

/// Controller responsável pelos filtros de itens (produtos) da tela de
/// itens da separação.
///
/// Extraído de [SeparationItemsViewModel] para isolar:
/// - Estado do filtro ativo ([SeparateItemsFiltersModel])
/// - Persistência (load/save/clear via [IFiltersStorageService])
/// - Tradução do filtro para `QueryBuilder` (campos enviados ao backend)
/// - Filtragem em memória por situação (`applySituacaoLocal`)
///
/// Não é `ChangeNotifier`: o ViewModel proprietário continua responsável
/// por orquestrar o fluxo (recarregar a lista) e chamar `notifyListeners`.
class SeparationItemsFiltersController {
  final IFiltersStorageService _storage;

  SeparateItemsFiltersModel _current = const SeparateItemsFiltersModel();

  SeparationItemsFiltersController({required IFiltersStorageService storage}) : _storage = storage;

  SeparateItemsFiltersModel get current => _current;
  bool get hasActive => _current.isNotEmpty;

  /// Carrega filtros salvos e, se houver algum ativo, aplica ao
  /// `queryBuilder`. Espelha o comportamento original do ViewModel:
  /// só atualiza o estado e a query quando há filtro persistido.
  Future<void> loadSavedAndApplyToQuery(QueryBuilder queryBuilder) async {
    try {
      final saved = await _storage.loadSeparateItemsFilters();
      if (saved.isNotEmpty) {
        _current = saved;
        applyToQuery(queryBuilder);
      }
    } catch (e, s) {
      developer.log('Erro ao aplicar filtros salvos de itens', error: e, stackTrace: s);
    }
  }

  Future<void> apply(SeparateItemsFiltersModel filters) async {
    _current = filters;
    await _save();
  }

  Future<void> clear() async {
    _current = const SeparateItemsFiltersModel();
    await _clearStorage();
  }

  void applyToQuery(QueryBuilder queryBuilder) {
    if (_current.codProduto != null) {
      queryBuilder.like('CodProduto', _current.codProduto!);
    }
    if (_current.codigoBarras != null) {
      queryBuilder.like('CodigoBarras', _current.codigoBarras!);
    }
    if (_current.nomeProduto != null) {
      queryBuilder.like('NomeProduto', _current.nomeProduto!);
    }
    if (_current.enderecoDescricao != null) {
      queryBuilder.like('EnderecoDescricao', _current.enderecoDescricao!);
    }
    if (_current.setorEstoque != null) {
      queryBuilder.equals('CodSetorEstoque', _current.setorEstoque!.codSetorEstoque.toString());
    }
  }

  List<SeparateItemConsultationModel> applySituacaoLocal(List<SeparateItemConsultationModel> items) {
    if (_current.situacao == null) {
      return items;
    }

    return items.where((item) {
      final itemSituacao = item.situacaoSeparacao;
      return itemSituacao == _current.situacao;
    }).toList();
  }

  Future<void> _save() async {
    try {
      await _storage.saveSeparateItemsFilters(_current);
    } catch (e, s) {
      developer.log('Erro ao salvar filtros de itens', error: e, stackTrace: s);
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clearSeparateItemsFilters();
    } catch (e, s) {
      developer.log('Erro ao limpar filtros de itens', error: e, stackTrace: s);
    }
  }
}
