import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

class CancelItemSeparationSuccess {
  final SeparationItemModel cancelledSeparationItem;
  final SeparateItemModel updatedSeparateItem;
  final double cancelledQuantity;

  const CancelItemSeparationSuccess({
    required this.cancelledSeparationItem,
    required this.updatedSeparateItem,
    required this.cancelledQuantity,
  });

  factory CancelItemSeparationSuccess.create({
    required SeparationItemModel cancelledSeparationItem,
    required SeparateItemModel updatedSeparateItem,
    required double cancelledQuantity,
  }) {
    return CancelItemSeparationSuccess(
      cancelledSeparationItem: cancelledSeparationItem,
      updatedSeparateItem: updatedSeparateItem,
      cancelledQuantity: cancelledQuantity,
    );
  }

  String get message => 'Item cancelado da separação com sucesso';

  int get codProduto => cancelledSeparationItem.codProduto;

  String get situacaoDescription => cancelledSeparationItem.situacaoDescription;

  String get situacaoCode => cancelledSeparationItem.situacaoCode;

  double get newTotalSeparationQuantity => updatedSeparateItem.quantidadeSeparacao;

  double get remainingAvailableQuantity {
    return updatedSeparateItem.quantidade - updatedSeparateItem.quantidadeSeparacao;
  }

  String get cancelledItemInfo {
    return 'Item ${cancelledSeparationItem.item} - ${cancelledSeparationItem.quantidade.toStringAsFixed(4)} ${cancelledSeparationItem.codUnidadeMedida}';
  }

  String get updateInfo {
    return 'Quantidade de separação atualizada: ${updatedSeparateItem.quantidadeSeparacao.toStringAsFixed(4)}';
  }

  bool get hasRemainingSeparation => updatedSeparateItem.quantidadeSeparacao > 0;

  double get remainingSeparationPercentage {
    if (updatedSeparateItem.quantidade == 0) return 0.0;
    return (updatedSeparateItem.quantidadeSeparacao / updatedSeparateItem.quantidade) * 100;
  }

  bool get isFullyCancelled => updatedSeparateItem.quantidadeSeparacao <= 0;

  String get separatorName => cancelledSeparationItem.nomeSeparador;

  DateTime get originalSeparationDate => cancelledSeparationItem.dataSeparacao;

  String get operationSummary {
    return 'Produto $codProduto: -${cancelledQuantity.toStringAsFixed(4)} '
        '(Restante: ${newTotalSeparationQuantity.toStringAsFixed(4)}/${updatedSeparateItem.quantidade.toStringAsFixed(4)})';
  }

  Map<String, dynamic> get auditInfo {
    return {
      'operation': 'CANCEL_ITEM_SEPARATION',
      'codProduto': codProduto,
      'quantidade_cancelada': cancelledQuantity,
      'quantidade_total_separada_restante': newTotalSeparationQuantity,
      'quantidade_total_item': updatedSeparateItem.quantidade,
      'quantidade_disponivel': remainingAvailableQuantity,
      'percentual_separacao_restante': remainingSeparationPercentage,
      'separador_original': separatorName,
      'data_separacao_original': originalSeparationDate.toIso8601String(),
      'session_id': cancelledSeparationItem.sessionId,
      'item_carrinho': cancelledSeparationItem.itemCarrinhoPercurso,
      'totalmente_cancelado': isFullyCancelled,
    };
  }

  List<String> get warnings {
    final warnings = <String>[];

    if (isFullyCancelled) {
      warnings.add('Toda a separação deste produto foi cancelada');
    }

    if (remainingSeparationPercentage > 0 && remainingSeparationPercentage < 10) {
      warnings.add('Pouca quantidade restante separada (${remainingSeparationPercentage.toStringAsFixed(1)}%)');
    }

    if (cancelledQuantity < 1.0) {
      warnings.add('Quantidade cancelada muito pequena (${cancelledQuantity.toStringAsFixed(4)})');
    }

    return warnings;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelItemSeparationSuccess &&
        other.cancelledSeparationItem == cancelledSeparationItem &&
        other.updatedSeparateItem == updatedSeparateItem &&
        other.cancelledQuantity == cancelledQuantity;
  }

  @override
  int get hashCode => Object.hash(cancelledSeparationItem, updatedSeparateItem, cancelledQuantity);

  @override
  String toString() {
    return 'CancelItemSeparationSuccess('
        'codProduto: $codProduto, '
        'cancelledQuantity: $cancelledQuantity, '
        'newTotalSeparation: $newTotalSeparationQuantity, '
        'remainingSeparationPercentage: ${remainingSeparationPercentage.toStringAsFixed(1)}%'
        ')';
  }
}
