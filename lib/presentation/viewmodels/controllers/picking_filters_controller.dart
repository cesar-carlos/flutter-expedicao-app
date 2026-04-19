import 'dart:developer' as developer;

import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

/// Controller responsável pelos filtros de produtos pendentes da tela de
/// picking.
///
/// Extraído de [CardPickingViewModel] (refator F4) para isolar:
/// - Estado dos filtros ativos
/// - Persistência (load/save/clear via `IFiltersStorageService`)
/// - Filtragem em memória (`applyLocal`) — busca por código de produto,
///   código de barras, nome, endereço e setor de estoque
///
/// Não é `ChangeNotifier`: o ViewModel proprietário recebe um callback
/// `onChanged` quando o conjunto muda (load saved, apply, clear), e fica
/// responsável por chamar `notifyListeners`.
class PickingFiltersController {
  final IFiltersStorageService _storage;
  final void Function()? _onChanged;

  PendingProductsFiltersModel _current = const PendingProductsFiltersModel();

  PickingFiltersController({
    required IFiltersStorageService storage,
    void Function()? onChanged,
  })  : _storage = storage,
        _onChanged = onChanged;

  PendingProductsFiltersModel get current => _current;
  bool get hasActive => _current.isNotEmpty;

  /// Carrega filtros previamente persistidos. Se não houver nada salvo,
  /// mantém o estado atual (vazio na primeira chamada).
  ///
  /// Notifica via `onChanged` se houver mudança.
  Future<void> loadSaved() async {
    try {
      final saved = await _storage.loadPendingProductsFilters();
      if (saved != null && saved != _current) {
        _current = saved;
        _onChanged?.call();
      }
    } catch (e, s) {
      developer.log('Failed to load pending products filters', error: e, stackTrace: s);
    }
  }

  /// Atualiza o conjunto de filtros e persiste.
  Future<void> apply(PendingProductsFiltersModel filters) async {
    _current = filters;
    await _save();
    _onChanged?.call();
  }

  /// Reseta para vazio e remove a persistência.
  Future<void> clear() async {
    _current = const PendingProductsFiltersModel();
    await _clearStorage();
    _onChanged?.call();
  }

  /// Aplica os filtros atuais em memória sobre `items`.
  /// Comparações case-insensitive via `contains` (substring), exceto setor
  /// que exige igualdade exata de `codSetorEstoque`.
  List<SeparateItemConsultationModel> applyLocal(List<SeparateItemConsultationModel> items) {
    if (_current.isEmpty) return items;

    return items.where((item) {
      if (_current.codProduto != null && _current.codProduto!.isNotEmpty) {
        if (!item.codProduto.toString().toLowerCase().contains(_current.codProduto!.toLowerCase())) {
          return false;
        }
      }

      if (_current.codigoBarras != null && _current.codigoBarras!.isNotEmpty) {
        final barcode = item.codigoBarras?.toLowerCase() ?? '';
        if (!barcode.contains(_current.codigoBarras!.toLowerCase())) {
          return false;
        }
      }

      if (_current.nomeProduto != null && _current.nomeProduto!.isNotEmpty) {
        if (!item.nomeProduto.toLowerCase().contains(_current.nomeProduto!.toLowerCase())) {
          return false;
        }
      }

      if (_current.enderecoDescricao != null && _current.enderecoDescricao!.isNotEmpty) {
        final endereco = item.enderecoDescricao?.toLowerCase() ?? '';
        if (!endereco.contains(_current.enderecoDescricao!.toLowerCase())) {
          return false;
        }
      }

      if (_current.setorEstoque != null) {
        if (item.codSetorEstoque != _current.setorEstoque!.codSetorEstoque) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _save() async {
    try {
      await _storage.savePendingProductsFilters(_current);
    } catch (e, s) {
      developer.log('Failed to save pending products filters', error: e, stackTrace: s);
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.clearPendingProductsFilters();
    } catch (e, s) {
      developer.log('Failed to clear pending products filters', error: e, stackTrace: s);
    }
  }
}
