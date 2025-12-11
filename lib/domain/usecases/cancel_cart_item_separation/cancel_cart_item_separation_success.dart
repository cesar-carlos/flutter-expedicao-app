import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

class CancelCardItemSeparationSuccess {
  final List<SeparateItemModel> updatedSeparateItems;
  final List<SeparationItemModel> cancelledSeparationItems;
  final Map<int, double> cancelledQuantitiesByProduct;

  const CancelCardItemSeparationSuccess({
    required this.updatedSeparateItems,
    required this.cancelledSeparationItems,
    required this.cancelledQuantitiesByProduct,
  });

  factory CancelCardItemSeparationSuccess.create({
    required List<SeparateItemModel> updatedSeparateItems,
    required List<SeparationItemModel> cancelledSeparationItems,
    required Map<int, double> cancelledQuantitiesByProduct,
  }) {
    return CancelCardItemSeparationSuccess(
      updatedSeparateItems: updatedSeparateItems,
      cancelledSeparationItems: cancelledSeparationItems,
      cancelledQuantitiesByProduct: cancelledQuantitiesByProduct,
    );
  }

  String get message => 'Itens cancelados com sucesso';

  int get cancelledItemsCount => cancelledSeparationItems.length;

  int get affectedProductsCount => cancelledQuantitiesByProduct.length;

  double get totalCancelledQuantity {
    return cancelledQuantitiesByProduct.values.fold(0.0, (sum, quantity) => sum + quantity);
  }

  List<int> get affectedProductCodes => cancelledQuantitiesByProduct.keys.toList();

  double getCancelledQuantityForProduct(int codProduto) {
    return cancelledQuantitiesByProduct[codProduto] ?? 0.0;
  }

  bool isProductAffected(int codProduto) {
    return cancelledQuantitiesByProduct.containsKey(codProduto);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelCardItemSeparationSuccess &&
        other.updatedSeparateItems.length == updatedSeparateItems.length &&
        other.cancelledSeparationItems.length == cancelledSeparationItems.length &&
        other.cancelledQuantitiesByProduct.length == cancelledQuantitiesByProduct.length;
  }

  @override
  int get hashCode =>
      Object.hash(updatedSeparateItems.length, cancelledSeparationItems.length, cancelledQuantitiesByProduct.length);

  @override
  String toString() {
    return 'CancelCardItemSeparationSuccess('
        'cancelledItems: $cancelledItemsCount, '
        'affectedProducts: $affectedProductsCount, '
        'totalCancelledQuantity: $totalCancelledQuantity'
        ')';
  }
}
