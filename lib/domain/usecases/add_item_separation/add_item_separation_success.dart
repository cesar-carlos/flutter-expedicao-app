import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';

/// Resultado de sucesso ao adicionar itens na separação
class AddItemSeparationSuccess {
  final SeparationItemModel createdSeparationItem;
  final SeparateItemModel updatedSeparateItem;
  final double addedQuantity;

  const AddItemSeparationSuccess({
    required this.createdSeparationItem,
    required this.updatedSeparateItem,
    required this.addedQuantity,
  });

  /// Cria um resultado de sucesso
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

  /// Retorna uma mensagem de sucesso
  String get message => 'Item adicionado à separação com sucesso';

  /// Retorna o código do produto adicionado
  int get codProduto => createdSeparationItem.codProduto;

  /// Retorna a descrição da situação do item criado
  String get situacaoDescription => createdSeparationItem.situacaoDescription;

  /// Retorna o código da situação do item criado
  String get situacaoCode => createdSeparationItem.situacaoCode;

  /// Retorna a nova quantidade de separação total
  double get newTotalSeparationQuantity => updatedSeparateItem.quantidadeSeparacao;

  /// Retorna a quantidade disponível restante
  double get remainingAvailableQuantity {
    return updatedSeparateItem.quantidade - updatedSeparateItem.quantidadeSeparacao;
  }

  /// Retorna informações sobre o item criado
  String get createdItemInfo {
    return 'Item ${createdSeparationItem.item} - ${createdSeparationItem.quantidade.toStringAsFixed(4)} ${createdSeparationItem.codUnidadeMedida}';
  }

  /// Retorna informações sobre a atualização
  String get updateInfo {
    return 'Quantidade de separação atualizada: ${updatedSeparateItem.quantidadeSeparacao.toStringAsFixed(4)}';
  }

  /// Verifica se há quantidade ainda disponível para separação
  bool get hasRemainingQuantity => remainingAvailableQuantity > 0;

  /// Retorna o percentual de separação realizado
  double get separationPercentage {
    if (updatedSeparateItem.quantidade == 0) return 0.0;
    return (updatedSeparateItem.quantidadeSeparacao / updatedSeparateItem.quantidade) * 100;
  }

  /// Verifica se o item foi completamente separado
  bool get isFullySeparated => remainingAvailableQuantity <= 0;

  /// Retorna o nome do separador que realizou a operação
  String get separatorName => createdSeparationItem.nomeSeparador;

  /// Retorna a data da separação
  DateTime get separationDate => createdSeparationItem.dataSeparacao;

  /// Retorna um resumo da operação
  String get operationSummary {
    return 'Produto $codProduto: +${addedQuantity.toStringAsFixed(4)} '
        '(Total: ${newTotalSeparationQuantity.toStringAsFixed(4)}/${updatedSeparateItem.quantidade.toStringAsFixed(4)})';
  }

  /// Retorna informações detalhadas para auditoria
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

  /// Retorna alertas baseados no estado da separação
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
