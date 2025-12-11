import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

class AddItemSeparationSuccess {
  final SeparationItemModel createdSeparationItem;
  final SeparateItemModel updatedSeparateItem;
  final double addedQuantity;

  const AddItemSeparationSuccess({
    required this.createdSeparationItem,
    required this.updatedSeparateItem,
    required this.addedQuantity,
  });

  factory AddItemSeparationSuccess.create({
    required SeparationItemModel createdSeparationItem,
    required SeparateItemModel updatedSeparateItem,
    required double addedQuantity,
  }) {
    return AddItemSeparationSuccess(
      createdSeparationItem: createdSeparationItem,
      updatedSeparateItem: updatedSeparateItem,
      addedQuantity: addedQuantity,
    );
  }

  String get message => 'Item adicionado à separação com sucesso';

  int get codProduto => createdSeparationItem.codProduto;

  String get situacaoDescription => createdSeparationItem.situacaoDescription;

  String get situacaoCode => createdSeparationItem.situacaoCode;

  double get newTotalSeparationQuantity => updatedSeparateItem.quantidadeSeparacao;

  double get remainingAvailableQuantity {
    return updatedSeparateItem.quantidade - updatedSeparateItem.quantidadeSeparacao;
  }

  String get createdItemInfo {
    return 'Item ${createdSeparationItem.item} - ${createdSeparationItem.quantidade.toStringAsFixed(4)} ${createdSeparationItem.codUnidadeMedida}';
  }

  String get updateInfo {
    return 'Quantidade de separação atualizada: ${updatedSeparateItem.quantidadeSeparacao.toStringAsFixed(4)}';
  }

  bool get hasRemainingQuantity => remainingAvailableQuantity > 0;

  double get separationPercentage {
    if (updatedSeparateItem.quantidade == 0) return 0.0;
    return (updatedSeparateItem.quantidadeSeparacao / updatedSeparateItem.quantidade) * 100;
  }

  bool get isFullySeparated => remainingAvailableQuantity <= 0;

  String get separatorName => createdSeparationItem.nomeSeparador;

  DateTime get separationDate => createdSeparationItem.dataSeparacao;

  String get operationSummary {
    return 'Produto $codProduto: +${addedQuantity.toStringAsFixed(4)} '
        '(Total: ${newTotalSeparationQuantity.toStringAsFixed(4)}/${updatedSeparateItem.quantidade.toStringAsFixed(4)})';
  }

  Map<String, dynamic> get auditInfo {
    return {
      'operation': 'ADD_ITEM_SEPARATION',
      'codProduto': codProduto,
      'quantidade_adicionada': addedQuantity,
      'quantidade_total_separada': newTotalSeparationQuantity,
      'quantidade_total_item': updatedSeparateItem.quantidade,
      'quantidade_restante': remainingAvailableQuantity,
      'percentual_separacao': separationPercentage,
      'separador': separatorName,
      'data_separacao': separationDate.toIso8601String(),
      'session_id': createdSeparationItem.sessionId,
      'item_carrinho': createdSeparationItem.itemCarrinhoPercurso,
      'completamente_separado': isFullySeparated,
    };
  }

  List<String> get warnings {
    final warnings = <String>[];

    if (separationPercentage >= 90 && !isFullySeparated) {
      warnings.add('Separação quase completa (${separationPercentage.toStringAsFixed(1)}%)');
    }

    if (isFullySeparated) {
      warnings.add('Item completamente separado');
    }

    if (addedQuantity < 1.0) {
      warnings.add('Quantidade separada muito pequena (${addedQuantity.toStringAsFixed(4)})');
    }

    return warnings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddItemSeparationSuccess &&
        other.createdSeparationItem == createdSeparationItem &&
        other.updatedSeparateItem == updatedSeparateItem &&
        other.addedQuantity == addedQuantity;
  }

  @override
  int get hashCode => Object.hash(createdSeparationItem, updatedSeparateItem, addedQuantity);

  @override
  String toString() {
    return 'AddItemSeparationSuccess('
        'codProduto: $codProduto, '
        'addedQuantity: $addedQuantity, '
        'newTotalSeparation: $newTotalSeparationQuantity, '
        'separationPercentage: ${separationPercentage.toStringAsFixed(1)}%'
        ')';
  }
}
