import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/separate_item_model.dart';

/// Resultado de sucesso da exclusão de item de separação
class DeleteItemSeparationSuccess {
  final SeparationItemModel deletedSeparationItem;
  final SeparateItemModel? updatedSeparateItem;
  final double deletedQuantity;

  const DeleteItemSeparationSuccess({
    required this.deletedSeparationItem,
    this.updatedSeparateItem,
    required this.deletedQuantity,
  });

  /// Factory para criar sucesso com item de separação excluído
  factory DeleteItemSeparationSuccess.create({
    required SeparationItemModel deletedSeparationItem,
    SeparateItemModel? updatedSeparateItem,
    required double deletedQuantity,
  }) {
    return DeleteItemSeparationSuccess(
      deletedSeparationItem: deletedSeparationItem,
      updatedSeparateItem: updatedSeparateItem,
      deletedQuantity: deletedQuantity,
    );
  }

  /// Verifica se houve atualização no separate_item
  bool get hasUpdatedSeparateItem => updatedSeparateItem != null;

  @override
  String toString() {
    return 'DeleteItemSeparationSuccess(deletedSeparationItem: $deletedSeparationItem, '
        'updatedSeparateItem: $updatedSeparateItem, deletedQuantity: $deletedQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteItemSeparationSuccess &&
        other.deletedSeparationItem == deletedSeparationItem &&
        other.updatedSeparateItem == updatedSeparateItem &&
        other.deletedQuantity == deletedQuantity;
  }

  @override
  int get hashCode {
    return deletedSeparationItem.hashCode ^ updatedSeparateItem.hashCode ^ deletedQuantity.hashCode;
  }
}
