import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';

class FiltersStorageService {
  static const String _separationFiltersKey = 'separation_filters';
  static const String _separateItemsFiltersKey = 'separate_items_filters';
  static const String _cartsFiltersKey = 'carts_filters';
  static const String _pendingProductsFiltersKey = 'pending_products_filters';

  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separationFiltersKey, filtersJson);
    } catch (e) {}
  }

  Future<SeparationFiltersModel> loadSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separationFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparationFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {}

    return const SeparationFiltersModel();
  }

  Future<void> clearSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separationFiltersKey);
    } catch (e) {}
  }

  Future<bool> hasSavedSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separationFiltersKey);
    } catch (e) {
      return false;
    }
  }

  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separateItemsFiltersKey, filtersJson);
    } catch (e) {}
  }

  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separateItemsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparateItemsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {}

    return const SeparateItemsFiltersModel();
  }

  Future<void> clearSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separateItemsFiltersKey);
    } catch (e) {}
  }

  Future<bool> hasSavedSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separateItemsFiltersKey);
    } catch (e) {
      return false;
    }
  }

  Future<void> saveCartsFilters(CartsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_cartsFiltersKey, filtersJson);
    } catch (e) {}
  }

  Future<CartsFiltersModel> loadCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_cartsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return CartsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {}

    return const CartsFiltersModel();
  }

  Future<void> clearCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartsFiltersKey);
    } catch (e) {}
  }

  Future<bool> hasSavedCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartsFiltersKey);
    } catch (e) {
      return false;
    }
  }

  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_pendingProductsFiltersKey, filtersJson);
    } catch (e) {}
  }

  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_pendingProductsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return PendingProductsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {}

    return null;
  }

  Future<void> clearPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingProductsFiltersKey);
    } catch (e) {}
  }

  Future<bool> hasSavedPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_pendingProductsFiltersKey);
    } catch (e) {
      return false;
    }
  }
}
