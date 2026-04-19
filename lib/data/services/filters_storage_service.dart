import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

/// Implementacao de IFiltersStorageService usando SharedPreferences.
///
/// Bug GGGGG: a versao anterior tinha `try/catch + rethrow` (inuteis,
/// codigo morto) em TODAS as operacoes de save/load/clear. Pior:
/// loads usavam cast direto `as Map<String, dynamic>` SEM tratar
/// corrupcao. Se um schema mudasse ou os dados ficassem invalidos,
/// a chave corrompida fazia o load falhar PARA SEMPRE — proxima
/// abertura da tela cairia no mesmo erro.
///
/// Esta versao:
///   1. Remove os `try/rethrow` desnecessarios (saves propagam erro
///      naturalmente — caller decide).
///   2. Em loads: se houver erro de decode/parse, **limpa a chave**
///      corrompida via [_recoverFromCorruption], loga warning e
///      retorna o valor default. Auto-recovery — proxima carga ja
///      funciona normalmente.
class FiltersStorageService implements IFiltersStorageService {
  static const String _separationFiltersKey = 'separation_filters';
  static const String _separateItemsFiltersKey = 'separate_items_filters';
  static const String _cartsFiltersKey = 'carts_filters';
  static const String _pendingProductsFiltersKey = 'pending_products_filters';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Limpa uma chave corrompida e loga o motivo. Garante que a proxima
  /// leitura retorne o valor default em vez de cair no mesmo erro.
  Future<void> _recoverFromCorruption(String key, Object error, StackTrace stackTrace) async {
    AppLogger.warning(
      'FiltersStorage: chave "$key" corrompida — removendo e usando default',
      tag: 'FiltersStorage',
      error: error,
      stackTrace: stackTrace,
    );
    try {
      final prefs = await _prefs;
      await prefs.remove(key);
    } catch (e, s) {
      // Se ate o remove falhar, so logamos — nao queremos crashar a app
      // por causa de housekeeping de filtros salvos.
      AppLogger.error(
        'FiltersStorage: falha tambem ao remover chave corrompida "$key"',
        tag: 'FiltersStorage',
        error: e,
        stackTrace: s,
      );
    }
  }

  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {
    final prefs = await _prefs;
    await prefs.setString(_separationFiltersKey, jsonEncode(filters.toJson()));
  }

  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async {
    final prefs = await _prefs;
    final filtersJson = prefs.getString(_separationFiltersKey);

    if (filtersJson == null || filtersJson.isEmpty) {
      return const SeparationFiltersModel();
    }

    try {
      final decoded = jsonDecode(filtersJson);
      if (decoded is! Map<String, dynamic>) {
        await _recoverFromCorruption(
          _separationFiltersKey,
          FormatException('Esperado Map<String, dynamic>, recebido ${decoded.runtimeType}'),
          StackTrace.current,
        );
        return const SeparationFiltersModel();
      }
      return SeparationFiltersModel.fromJson(decoded);
    } catch (e, s) {
      await _recoverFromCorruption(_separationFiltersKey, e, s);
      return const SeparationFiltersModel();
    }
  }

  @override
  Future<void> clearSeparationFilters() async {
    final prefs = await _prefs;
    await prefs.remove(_separationFiltersKey);
  }

  @override
  Future<bool> hasSavedSeparationFilters() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_separationFiltersKey);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {
    final prefs = await _prefs;
    await prefs.setString(_separateItemsFiltersKey, jsonEncode(filters.toJson()));
  }

  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async {
    final prefs = await _prefs;
    final filtersJson = prefs.getString(_separateItemsFiltersKey);

    if (filtersJson == null || filtersJson.isEmpty) {
      return const SeparateItemsFiltersModel();
    }

    try {
      final decoded = jsonDecode(filtersJson);
      if (decoded is! Map<String, dynamic>) {
        await _recoverFromCorruption(
          _separateItemsFiltersKey,
          FormatException('Esperado Map<String, dynamic>, recebido ${decoded.runtimeType}'),
          StackTrace.current,
        );
        return const SeparateItemsFiltersModel();
      }
      return SeparateItemsFiltersModel.fromJson(decoded);
    } catch (e, s) {
      await _recoverFromCorruption(_separateItemsFiltersKey, e, s);
      return const SeparateItemsFiltersModel();
    }
  }

  @override
  Future<void> clearSeparateItemsFilters() async {
    final prefs = await _prefs;
    await prefs.remove(_separateItemsFiltersKey);
  }

  @override
  Future<bool> hasSavedSeparateItemsFilters() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_separateItemsFiltersKey);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {
    final prefs = await _prefs;
    await prefs.setString(_cartsFiltersKey, jsonEncode(filters.toJson()));
  }

  @override
  Future<CartsFiltersModel> loadCartsFilters() async {
    final prefs = await _prefs;
    final filtersJson = prefs.getString(_cartsFiltersKey);

    if (filtersJson == null || filtersJson.isEmpty) {
      return const CartsFiltersModel();
    }

    try {
      final decoded = jsonDecode(filtersJson);
      if (decoded is! Map<String, dynamic>) {
        await _recoverFromCorruption(
          _cartsFiltersKey,
          FormatException('Esperado Map<String, dynamic>, recebido ${decoded.runtimeType}'),
          StackTrace.current,
        );
        return const CartsFiltersModel();
      }
      return CartsFiltersModel.fromJson(decoded);
    } catch (e, s) {
      await _recoverFromCorruption(_cartsFiltersKey, e, s);
      return const CartsFiltersModel();
    }
  }

  @override
  Future<void> clearCartsFilters() async {
    final prefs = await _prefs;
    await prefs.remove(_cartsFiltersKey);
  }

  @override
  Future<bool> hasSavedCartsFilters() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_cartsFiltersKey);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {
    final prefs = await _prefs;
    await prefs.setString(_pendingProductsFiltersKey, jsonEncode(filters.toJson()));
  }

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async {
    final prefs = await _prefs;
    final filtersJson = prefs.getString(_pendingProductsFiltersKey);

    if (filtersJson == null || filtersJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(filtersJson);
      if (decoded is! Map<String, dynamic>) {
        await _recoverFromCorruption(
          _pendingProductsFiltersKey,
          FormatException('Esperado Map<String, dynamic>, recebido ${decoded.runtimeType}'),
          StackTrace.current,
        );
        return null;
      }
      return PendingProductsFiltersModel.fromJson(decoded);
    } catch (e, s) {
      await _recoverFromCorruption(_pendingProductsFiltersKey, e, s);
      return null;
    }
  }

  @override
  Future<void> clearPendingProductsFilters() async {
    final prefs = await _prefs;
    await prefs.remove(_pendingProductsFiltersKey);
  }

  @override
  Future<bool> hasSavedPendingProductsFilters() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_pendingProductsFiltersKey);
    } catch (_) {
      return false;
    }
  }
}
