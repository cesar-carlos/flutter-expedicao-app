import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

/// Controller responsável pelos filtros de carrinhos da tela de itens da
/// separação.
///
/// Extraído de [SeparationItemsViewModel] para isolar:
/// - Estado do filtro ativo ([CartsFiltersModel])
/// - Persistência (load/save/clear via [IFiltersStorageService])
/// - Tradução do filtro para `QueryBuilder` (sem a situação, que é
///   aplicada em memória)
/// - Filtragem em memória por situação (`applySituacaoLocal`)
///
/// Não é `ChangeNotifier`: o ViewModel proprietário continua responsável
/// por orquestrar o fluxo (recarregar a lista) e chamar `notifyListeners`.
class SeparationCartsFiltersController {
  final IFiltersStorageService _storage;

  CartsFiltersModel _current = const CartsFiltersModel();

  SeparationCartsFiltersController({required IFiltersStorageService storage}) : _storage = storage;

  CartsFiltersModel get current => _current;
  bool get hasActive => _current.isNotEmpty;

  /// Carrega filtros salvos e, se houver algum ativo, aplica ao
  /// `queryBuilder`. Espelha o comportamento original do ViewModel:
  /// só atualiza o estado e a query quando há filtro persistido.
  Future<void> loadSavedAndApplyToQuery(QueryBuilder queryBuilder) async {
    try {
      final saved = await _storage.loadCartsFilters();
      if (saved.isNotEmpty) {
        _current = saved;
        applyToQueryWithoutSituacao(queryBuilder);
      }
    } catch (e, s) {
      developer.log('Erro ao aplicar filtros salvos de carrinhos', error: e, stackTrace: s);
    }
  }

  Future<void> apply(CartsFiltersModel filters) async {
    _current = filters;
    await _save();
  }

  Future<void> clear() async {
    _current = const CartsFiltersModel();
    await _clearStorage();
  }

  void applyToQueryWithoutSituacao(QueryBuilder queryBuilder) {
    if (_current.codCarrinho != null) {
      queryBuilder.like('CodCarrinho', _current.codCarrinho!);
    }
    if (_current.nomeCarrinho != null) {
      queryBuilder.like('NomeCarrinho', _current.nomeCarrinho!);
    }
    if (_current.codigoBarrasCarrinho != null) {
      queryBuilder.like('CodigoBarrasCarrinho', _current.codigoBarrasCarrinho!);
    }
    if (_current.nomeUsuarioInicio != null) {
      queryBuilder.like('NomeUsuarioInicio', _current.nomeUsuarioInicio!);
    }
    if (_current.dataInicioInicial != null) {
      queryBuilder.greaterThan('DataInicio', _current.dataInicioInicial!.toIso8601String());
    }
    if (_current.dataInicioFinal != null) {
      queryBuilder.lessThan('DataInicio', _current.dataInicioFinal!.toIso8601String());
    }
    queryBuilder.equals('CarrinhoAgrupador', _current.carrinhoAgrupador.code);
  }

  List<ExpeditionCartRouteInternshipConsultationModel> applySituacaoLocal(
    List<ExpeditionCartRouteInternshipConsultationModel> carts,
  ) {
    if (_current.situacoes == null || _current.situacoes!.isEmpty) {
      return carts;
    }

    return carts.where((cart) {
      final cartSituacao = cart.situacao.code;
      return _current.situacoes!.contains(cartSituacao);
    }).toList();
  }

  Future<void> _save() async {
    try {
      await _storage.saveCartsFilters(_current);
    } catch (e, s) {
      developer.log('Erro ao salvar filtros de carrinhos', error: e, stackTrace: s);
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clearCartsFilters();
    } catch (e, s) {
      developer.log('Erro ao limpar filtros de carrinhos', error: e, stackTrace: s);
    }
  }
}
