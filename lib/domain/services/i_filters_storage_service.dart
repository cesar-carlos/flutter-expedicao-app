import 'package:data7_expedicao/domain/models/filter/separation_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/separate_items_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/carts_filters_model.dart';
import 'package:data7_expedicao/domain/models/filter/pending_products_filters_model.dart';

abstract class IFiltersStorageService {
  Future<void> saveSeparationFilters(SeparationFiltersModel filters);
  Future<SeparationFiltersModel> loadSeparationFilters();
  Future<void> clearSeparationFilters();
  Future<bool> hasSavedSeparationFilters();

  Future<void> saveSeparateItemsFilters(SeparateItemsFiltersModel filters);
  Future<SeparateItemsFiltersModel> loadSeparateItemsFilters();
  Future<void> clearSeparateItemsFilters();
  Future<bool> hasSavedSeparateItemsFilters();

  Future<void> saveCartsFilters(CartsFiltersModel filters);
  Future<CartsFiltersModel> loadCartsFilters();
  Future<void> clearCartsFilters();
  Future<bool> hasSavedCartsFilters();

  Future<void> savePendingProductsFilters(PendingProductsFiltersModel filters);
  Future<PendingProductsFiltersModel?> loadPendingProductsFilters();
  Future<void> clearPendingProductsFilters();
  Future<bool> hasSavedPendingProductsFilters();
}
