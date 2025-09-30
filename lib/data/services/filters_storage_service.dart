import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exp/domain/models/separation_filters_model.dart';
import 'package:exp/domain/models/separate_items_filters_model.dart';
import 'package:exp/domain/models/carts_filters_model.dart';

class FiltersStorageService {
  static const String _separationFiltersKey = 'separation_filters';
  static const String _separateItemsFiltersKey = 'separate_items_filters';
  static const String _cartsFiltersKey = 'carts_filters';

  /// Salva os filtros da tela de separação
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separationFiltersKey, filtersJson);
    } catch (e) {
      // Log do erro, mas não quebra a aplicação
      // Erro ao salvar filtros de separação
    }
  }

  /// Carrega os filtros salvos da tela de separação
  Future<SeparationFiltersModel> loadSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separationFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparationFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      // Log do erro, mas retorna filtros vazios
      // Erro ao carregar filtros de separação
    }

    return const SeparationFiltersModel();
  }

  /// Remove os filtros salvos da tela de separação
  Future<void> clearSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separationFiltersKey);
    } catch (e) {
      // Erro ao limpar filtros de separação
    }
  }

  /// Verifica se existem filtros salvos
  Future<bool> hasSavedSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separationFiltersKey);
    } catch (e) {
      // Erro ao verificar filtros salvos
      return false;
    }
  }

  // === FILTROS DE PRODUTOS (SEPARATE ITEMS) ===

  /// Salva os filtros da tela de produtos
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separateItemsFiltersKey, filtersJson);
    } catch (e) {
      // Erro ao salvar filtros de produtos
    }
  }

  /// Carrega os filtros salvos da tela de produtos
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separateItemsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparateItemsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      // Erro ao carregar filtros de produtos
    }

    return const SeparateItemsFiltersModel();
  }

  /// Remove os filtros salvos da tela de produtos
  Future<void> clearSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separateItemsFiltersKey);
    } catch (e) {
      // Erro ao limpar filtros de produtos
    }
  }

  /// Verifica se existem filtros salvos de produtos
  Future<bool> hasSavedSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separateItemsFiltersKey);
    } catch (e) {
      // Erro ao verificar filtros salvos de produtos
      return false;
    }
  }

  // === FILTROS DE CARRINHOS ===

  /// Salva os filtros da tela de carrinhos
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_cartsFiltersKey, filtersJson);
    } catch (e) {
      // Erro ao salvar filtros de carrinhos
    }
  }

  /// Carrega os filtros salvos da tela de carrinhos
  Future<CartsFiltersModel> loadCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_cartsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return CartsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      // Erro ao carregar filtros de carrinhos
    }

    return const CartsFiltersModel();
  }

  /// Remove os filtros salvos da tela de carrinhos
  Future<void> clearCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartsFiltersKey);
    } catch (e) {
      // Erro ao limpar filtros de carrinhos
    }
  }

  /// Verifica se existem filtros salvos de carrinhos
  Future<bool> hasSavedCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartsFiltersKey);
    } catch (e) {
      // Erro ao verificar filtros salvos de carrinhos
      return false;
    }
  }
}
