import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/core/results/index.dart';

class SeparationItemSummaryConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionCartSituation situacao;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codCarrinho;
  final String descricaoCarrinho;
  final int codLocalArmazenagem;
  final int codProduto;
  final String nomeProduto;
  final String codUnidadeMedida;
  final String descricaoUnidadeMedida;
  final String? codigoBarras;
  final String? codProdutoEndereco;
  final String? descricaoProdutoEndereco;
  final double quantidade;

  SeparationItemSummaryConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codCarrinho,
    required this.descricaoCarrinho,
    required this.codLocalArmazenagem,
    required this.codProduto,
    required this.nomeProduto,
    required this.codUnidadeMedida,
    required this.descricaoUnidadeMedida,
    this.codigoBarras,
    this.codProdutoEndereco,
    this.descricaoProdutoEndereco,
    required this.quantidade,
  });

  SeparationItemSummaryConsultationModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionCartSituation? situacao,
    int? codCarrinhoPercurso,
    String? itemCarrinhoPercurso,
    int? codCarrinho,
    String? descricaoCarrinho,
    int? codLocalArmazenagem,
    int? codProduto,
    String? nomeProduto,
    String? codUnidadeMedida,
    String? descricaoUnidadeMedida,
    String? codigoBarras,
    String? codProdutoEndereco,
    String? descricaoProdutoEndereco,
    double? quantidade,
  }) {
    return SeparationItemSummaryConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      descricaoCarrinho: descricaoCarrinho ?? this.descricaoCarrinho,
      codLocalArmazenagem: codLocalArmazenagem ?? this.codLocalArmazenagem,
      codProduto: codProduto ?? this.codProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      descricaoUnidadeMedida: descricaoUnidadeMedida ?? this.descricaoUnidadeMedida,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      codProdutoEndereco: codProdutoEndereco ?? this.codProdutoEndereco,
      descricaoProdutoEndereco: descricaoProdutoEndereco ?? this.descricaoProdutoEndereco,
      quantidade: quantidade ?? this.quantidade,
    );
  }

  factory SeparationItemSummaryConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparationItemSummaryConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codSepararEstoque: json['CodSepararEstoque'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String? ?? ''),
        codOrigem: json['CodOrigem'],
        situacao: ExpeditionCartSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionCartSituation.vazio,
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        codCarrinho: json['CodCarrinho'],
        descricaoCarrinho: json['DescricaoCarrinho'],
        codLocalArmazenagem: json['CodLocalArmazenagem'],
        codProduto: json['CodProduto'],
        nomeProduto: json['NomeProduto'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        descricaoUnidadeMedida: json['DescricaoUnidadeMedida'],
        codigoBarras: json['CodigoBarras'],
        codProdutoEndereco: json['CodProdutoEndereco'],
        descricaoProdutoEndereco: json['DescricaoProdutoEndereco'],
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparationItemSummaryConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparationItemSummaryConsultationModel.fromJson(json));
  }

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationItemSummaryConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.itemCarrinhoPercurso == itemCarrinhoPercurso;
  }

  @override
  int get hashCode =>
      codEmpresa.hashCode ^ codSepararEstoque.hashCode ^ codCarrinhoPercurso.hashCode ^ itemCarrinhoPercurso.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'CodCarrinho': codCarrinho,
      'DescricaoCarrinho': descricaoCarrinho,
      'CodLocalArmazenagem': codLocalArmazenagem,
      'CodProduto': codProduto,
      'NomeProduto': nomeProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'DescricaoUnidadeMedida': descricaoUnidadeMedida,
      'CodigoBarras': codigoBarras,
      'CodProdutoEndereco': codProdutoEndereco,
      'DescricaoProdutoEndereco': descricaoProdutoEndereco,
      'Quantidade': quantidade,
    };
  }
}
