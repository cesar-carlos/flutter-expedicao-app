import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';

class DeleteItemSeparationSuccess {
  final SeparationItemModel deletedSeparationItem;
  final SeparateItemModel? updatedSeparateItem;
  final double deletedQuantity;

  const DeleteItemSeparationSuccess({
    required this.deletedSeparationItem,
    this.updatedSeparateItem,
    required this.deletedQuantity,
  });

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
