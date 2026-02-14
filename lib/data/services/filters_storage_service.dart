import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';
import 'package:data7_expedicao/domain/services/i_filters_storage_service.dart';

class FiltersStorageService implements IFiltersStorageService {
  static const String _separationFiltersKey = 'separation_filters';
  static const String _separateItemsFiltersKey = 'separate_items_filters';
  static const String _cartsFiltersKey = 'carts_filters';
  static const String _pendingProductsFiltersKey = 'pending_products_filters';

  @override
  Future<void> saveSeparationFilters(SeparationFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separationFiltersKey, filtersJson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeparationFiltersModel> loadSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separationFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparationFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      rethrow;
    }

    return const SeparationFiltersModel();
  }

  @override
  Future<void> clearSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separationFiltersKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasSavedSeparationFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separationFiltersKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_separateItemsFiltersKey, filtersJson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_separateItemsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return SeparateItemsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      rethrow;
    }

    return const SeparateItemsFiltersModel();
  }

  @override
  Future<void> clearSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_separateItemsFiltersKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasSavedSeparateItemsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_separateItemsFiltersKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveCartsFilters(CartsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_cartsFiltersKey, filtersJson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CartsFiltersModel> loadCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_cartsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return CartsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      rethrow;
    }

    return const CartsFiltersModel();
  }

  @override
  Future<void> clearCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartsFiltersKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasSavedCartsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_cartsFiltersKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = jsonEncode(filters.toJson());
      await prefs.setString(_pendingProductsFiltersKey, filtersJson);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString(_pendingProductsFiltersKey);

      if (filtersJson != null) {
        final filtersMap = jsonDecode(filtersJson) as Map<String, dynamic>;
        return PendingProductsFiltersModel.fromJson(filtersMap);
      }
    } catch (e) {
      rethrow;
    }

    return null;
  }

  @override
  Future<void> clearPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingProductsFiltersKey);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasSavedPendingProductsFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_pendingProductsFiltersKey);
    } catch (e) {
      return false;
    }
  }
}
