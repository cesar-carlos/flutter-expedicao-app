import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

/// Resultado de sucesso ao cancelar um item específico da separação
class CancelItemSeparationSuccess {
  final SeparationItemModel cancelledSeparationItem;
  final SeparateItemModel updatedSeparateItem;
  final double cancelledQuantity;

  const CancelItemSeparationSuccess({
    required this.cancelledSeparationItem,
    required this.updatedSeparateItem,
    required this.cancelledQuantity,
  });

  /// Cria um resultado de sucesso
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

  /// Retorna uma mensagem de sucesso
  String get message => 'Item cancelado da separação com sucesso';

  /// Retorna o código do produto cancelado
  int get codProduto => cancelledSeparationItem.codProduto;

  /// Retorna a descrição da situação do item cancelado
  String get situacaoDescription => cancelledSeparationItem.situacaoDescription;

  /// Retorna o código da situação do item cancelado
  String get situacaoCode => cancelledSeparationItem.situacaoCode;

  /// Retorna a nova quantidade de separação total
  double get newTotalSeparationQuantity => updatedSeparateItem.quantidadeSeparacao;

  /// Retorna a quantidade disponível restante
  double get remainingAvailableQuantity {
    return updatedSeparateItem.quantidade - updatedSeparateItem.quantidadeSeparacao;
  }

  /// Retorna informações sobre o item cancelado
  String get cancelledItemInfo {
    return 'Item ${cancelledSeparationItem.item} - ${cancelledSeparationItem.quantidade.toStringAsFixed(4)} ${cancelledSeparationItem.codUnidadeMedida}';
  }

  /// Retorna informações sobre a atualização
  String get updateInfo {
    return 'Quantidade de separação atualizada: ${updatedSeparateItem.quantidadeSeparacao.toStringAsFixed(4)}';
  }

  /// Verifica se há quantidade ainda separada para este produto
  bool get hasRemainingSeparation => updatedSeparateItem.quantidadeSeparacao > 0;

  /// Retorna o percentual de separação restante
  double get remainingSeparationPercentage {
    if (updatedSeparateItem.quantidade == 0) return 0.0;
    return (updatedSeparateItem.quantidadeSeparacao / updatedSeparateItem.quantidade) * 100;
  }

  /// Verifica se toda a separação foi cancelada
  bool get isFullyCancelled => updatedSeparateItem.quantidadeSeparacao <= 0;

  /// Retorna o nome do separador que realizou a operação original
  String get separatorName => cancelledSeparationItem.nomeSeparador;

  /// Retorna a data da separação original
  DateTime get originalSeparationDate => cancelledSeparationItem.dataSeparacao;

  /// Retorna um resumo da operação
  String get operationSummary {
    return 'Produto $codProduto: -${cancelledQuantity.toStringAsFixed(4)} '
        '(Restante: ${newTotalSeparationQuantity.toStringAsFixed(4)}/${updatedSeparateItem.quantidade.toStringAsFixed(4)})';
  }

  /// Retorna informações detalhadas para auditoria
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

  /// Retorna alertas baseados no estado da separação
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
