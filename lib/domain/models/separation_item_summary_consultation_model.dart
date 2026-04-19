import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparationItemSummaryConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionSituation situacao;
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
    ExpeditionSituation? situacao,
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
    return SeparationItemSummaryConsultationModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codSepararEstoque: JsonParse.parseIntOr(json['CodSepararEstoque'], 0),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      situacao: ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ??
          ExpeditionSituation.naoLocalizada,
      codCarrinhoPercurso: JsonParse.parseIntOr(json['CodCarrinhoPercurso'], 0),
      itemCarrinhoPercurso: JsonParse.parseStringOr(json['ItemCarrinhoPercurso'], ''),
      codCarrinho: JsonParse.parseIntOr(json['CodCarrinho'], 0),
      descricaoCarrinho: JsonParse.parseStringOr(json['DescricaoCarrinho'], ''),
      codLocalArmazenagem: JsonParse.parseIntOr(json['CodLocalArmazenagem'], 0),
      codProduto: JsonParse.parseIntOr(json['CodProduto'], 0),
      nomeProduto: JsonParse.parseStringOr(json['NomeProduto'], ''),
      codUnidadeMedida: JsonParse.parseStringOr(json['CodUnidadeMedida'], ''),
      descricaoUnidadeMedida: JsonParse.parseStringOr(json['DescricaoUnidadeMedida'], ''),
      codigoBarras: JsonParse.parseStringOrNull(json['CodigoBarras']),
      codProdutoEndereco: JsonParse.parseStringOrNull(json['CodProdutoEndereco']),
      descricaoProdutoEndereco: JsonParse.parseStringOrNull(json['DescricaoProdutoEndereco']),
      quantidade: AppHelper.stringToDouble(json['Quantidade']),
    );
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
