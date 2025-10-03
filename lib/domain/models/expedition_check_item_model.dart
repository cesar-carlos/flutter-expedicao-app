import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCheckItemModel {
  final int codEmpresa;
  final int codConferir;
  final String item;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codProduto;
  final String codUnidadeMedida;
  final double quantidade;
  final double quantidadeConferida;

  ExpeditionCheckItemModel({
    required this.codEmpresa,
    required this.codConferir,
    required this.item,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codProduto,
    required this.codUnidadeMedida,
    required this.quantidade,
    required this.quantidadeConferida,
  });

  ExpeditionCheckItemModel copyWith({
    int? codEmpresa,
    int? codConferir,
    String? item,
    int? codCarrinhoPercurso,
    String? itemCarrinhoPercurso,
    int? codProduto,
    String? codUnidadeMedida,
    double? quantidade,
    double? quantidadeConferida,
  }) {
    return ExpeditionCheckItemModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codConferir: codConferir ?? this.codConferir,
      item: item ?? this.item,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      codProduto: codProduto ?? this.codProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      quantidade: quantidade ?? this.quantidade,
      quantidadeConferida: quantidadeConferida ?? this.quantidadeConferida,
    );
  }

  factory ExpeditionCheckItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCheckItemModel(
        codEmpresa: json['CodEmpresa'],
        codConferir: json['CodConferir'],
        item: json['Item'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        codProduto: json['CodProduto'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
        quantidadeConferida: AppHelper.stringToDouble(json['QuantidadeConferida']),
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCheckItemModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCheckItemModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodConferir': codConferir,
      'Item': item,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'CodProduto': codProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'Quantidade': quantidade.toStringAsFixed(4),
      'QuantidadeConferida': quantidadeConferida.toStringAsFixed(4),
    };
  }

  /// Retorna a diferença entre quantidade conferida e quantidade original
  double get diferencaQuantidade => quantidadeConferida - quantidade;

  /// Retorna se a quantidade foi totalmente conferida
  bool get isTotalmenteConferido => quantidadeConferida >= quantidade;

  /// Retorna se há diferença na quantidade
  bool get temDiferenca => diferencaQuantidade != 0;

  /// Retorna a porcentagem de conferência
  double get porcentagemConferencia => quantidade > 0 ? (quantidadeConferida / quantidade) * 100 : 0;

  /// Retorna se o item está pendente de conferência
  bool get isPendenteConferencia => quantidadeConferida < quantidade;

  /// Retorna se o item foi conferido em excesso
  bool get isConferidoExcesso => quantidadeConferida > quantidade;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCheckItemModel &&
        other.codEmpresa == codEmpresa &&
        other.codConferir == codConferir &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codConferir.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''ExpeditionCheckItemModel(
        codEmpresa: $codEmpresa, 
        codConferir: $codConferir, 
        item: $item, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        codProduto: $codProduto, 
        codUnidadeMedida: $codUnidadeMedida, 
        quantidade: $quantidade, 
        quantidadeConferida: $quantidadeConferida,
        diferencaQuantidade: $diferencaQuantidade,
        porcentagemConferencia: ${porcentagemConferencia.toStringAsFixed(2)}%
)''';
  }
}
