import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';

/// Resultado de sucesso ao cancelar itens de separação
class CancelCardItemSeparationSuccess {
  final List<SeparateItemModel> updatedSeparateItems;
  final List<SeparationItemModel> cancelledSeparationItems;
  final Map<int, double> cancelledQuantitiesByProduct;

  const CancelCardItemSeparationSuccess({
    required this.updatedSeparateItems,
    required this.cancelledSeparationItems,
    required this.cancelledQuantitiesByProduct,
  });

  /// Cria um resultado de sucesso
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

  /// Retorna uma mensagem de sucesso
  String get message => 'Itens cancelados com sucesso';

  /// Retorna o número de itens cancelados
  int get cancelledItemsCount => cancelledSeparationItems.length;

  /// Retorna o número de produtos afetados
  int get affectedProductsCount => cancelledQuantitiesByProduct.length;

  /// Retorna a quantidade total cancelada
  double get totalCancelledQuantity {
    return cancelledQuantitiesByProduct.values.fold(0.0, (sum, quantity) => sum + quantity);
  }

  /// Retorna uma lista dos códigos de produtos afetados
  List<int> get affectedProductCodes => cancelledQuantitiesByProduct.keys.toList();

  /// Retorna a quantidade cancelada para um produto específico
  double getCancelledQuantityForProduct(int codProduto) {
    return cancelledQuantitiesByProduct[codProduto] ?? 0.0;
  }

  /// Verifica se um produto foi afetado pelo cancelamento
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
