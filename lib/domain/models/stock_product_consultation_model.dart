import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class StockProductConsultationModel {
  final int codProduto;
  final String nomeProduto;
  final Situation ativo;
  final String codTipoProduto;
  final String codUnidadeMedida;
  final String nomeUnidadeMedida;
  final int codGrupoProduto;
  final String nomeGrupoProduto;
  final int? codMarca;
  final String? nomeMarca;
  final int? codSetorEstoque;
  final String? ncm;
  final String? codigoBarras;
  final String? codigoBarras2;
  final String? codigoReferencia;
  final String? codigoFornecedor;
  final String? codigoFabricante;
  final String? codigoOriginal;
  final String? endereco;
  final String? enderecoDescricao;

  StockProductConsultationModel({
    required this.codProduto,
    required this.nomeProduto,
    required this.ativo,
    required this.codTipoProduto,
    required this.codUnidadeMedida,
    required this.nomeUnidadeMedida,
    required this.codGrupoProduto,
    required this.nomeGrupoProduto,
    this.codMarca,
    this.nomeMarca,
    this.codSetorEstoque,
    this.ncm,
    this.codigoBarras,
    this.codigoBarras2,
    this.codigoReferencia,
    this.codigoFornecedor,
    this.codigoFabricante,
    this.codigoOriginal,
    this.endereco,
    this.enderecoDescricao,
  });

  factory StockProductConsultationModel.fromJson(Map<String, dynamic> json) {
    return StockProductConsultationModel(
      codProduto: JsonParse.parseIntOr(json['CodProduto'], 0),
      nomeProduto: JsonParse.parseStringOr(json['NomeProduto'], ''),
      ativo: Situation.fromCodeWithFallback(JsonParse.parseStringOr(json['Ativo'], '')),
      codTipoProduto: JsonParse.parseStringOr(json['CodTipoProduto'], ''),
      codUnidadeMedida: JsonParse.parseStringOr(json['CodUnidadeMedida'], ''),
      nomeUnidadeMedida: JsonParse.parseStringOr(json['NomeUnidadeMedida'], ''),
      codGrupoProduto: JsonParse.parseIntOr(json['CodGrupoProduto'], 0),
      nomeGrupoProduto: JsonParse.parseStringOr(json['NomeGrupoProduto'], ''),
      codMarca: JsonParse.parseInt(json['CodMarca']),
      nomeMarca: JsonParse.parseStringOrNull(json['NomeMarca']),
      codSetorEstoque: JsonParse.parseInt(json['CodSetorEstoque']),
      ncm: JsonParse.parseStringOrNull(json['NCM']),
      codigoBarras: JsonParse.parseStringOrNull(json['CodigoBarras']),
      codigoBarras2: JsonParse.parseStringOrNull(json['CodigoBarras2']),
      codigoReferencia: JsonParse.parseStringOrNull(json['CodigoReferencia']),
      codigoFornecedor: JsonParse.parseStringOrNull(json['CodigoFornecedor']),
      codigoFabricante: JsonParse.parseStringOrNull(json['CodigoFabricante']),
      codigoOriginal: JsonParse.parseStringOrNull(json['CodigoOriginal']),
      endereco: JsonParse.parseStringOrNull(json['Endereco']),
      enderecoDescricao: JsonParse.parseStringOrNull(json['EnderecoDescricao']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CodProduto': codProduto,
      'NomeProduto': nomeProduto,
      'Ativo': ativo.code,
      'CodTipoProduto': codTipoProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'NomeUnidadeMedida': nomeUnidadeMedida,
      'CodGrupoProduto': codGrupoProduto,
      'NomeGrupoProduto': nomeGrupoProduto,
      'CodMarca': codMarca,
      'NomeMarca': nomeMarca,
      'CodSetorEstoque': codSetorEstoque,
      'NCM': ncm,
      'CodigoBarras': codigoBarras,
      'CodigoBarras2': codigoBarras2,
      'CodigoReferencia': codigoReferencia,
      'CodigoFornecedor': codigoFornecedor,
      'CodigoFabricante': codigoFabricante,
      'CodigoOriginal': codigoOriginal,
      'Endereco': endereco,
      'EnderecoDescricao': enderecoDescricao,
    };
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<StockProductConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => StockProductConsultationModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockProductConsultationModel && other.codProduto == codProduto;
  }

  @override
  int get hashCode => codProduto.hashCode;

  @override
  String toString() {
    return '''
      StockProductConsultationModel(
          codProduto: $codProduto, 
          nomeProduto: $nomeProduto, 
          ativo: ${ativo.description} (${ativo.code}), 
          codTipoProduto: $codTipoProduto, 
          codUnidadeMedida: $codUnidadeMedida, 
          nomeUnidadeMedida: $nomeUnidadeMedida, 
          codGrupoProduto: $codGrupoProduto, 
          nomeGrupoProduto: $nomeGrupoProduto, 
          codMarca: $codMarca, 
          nomeMarca: $nomeMarca, 
          codSetorEstoque: $codSetorEstoque, 
          ncm: $ncm, 
          codigoBarras: $codigoBarras, 
          codigoBarras2: $codigoBarras2, 
          codigoReferencia: $codigoReferencia, 
          codigoFornecedor: $codigoFornecedor, 
          codigoFabricante: $codigoFabricante, 
          codigoOriginal: $codigoOriginal, 
          endereco: $endereco, 
          enderecoDescricao: $enderecoDescricao
    )''';
  }
}
