import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation_model.dart';

class SeparateItemConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final String? itemOrigem;
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
  final String? nomeSetorEstoque;
  final String? ncm;
  final String? codigoBarras;
  final String? codigoBarras2;
  final String? codigoReferencia;
  final String? codigoFornecedor;
  final String? codigoFabricante;
  final String? codigoOriginal;
  final String? endereco;
  final String? enderecoDescricao;
  final int codLocalArmazenagem;
  final String nomeLocaArmazenagem;
  final double quantidade;
  final double quantidadeInterna;
  final double quantidadeExterna;
  final double quantidadeSeparacao;

  SeparateItemConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    required this.origem,
    required this.codOrigem,
    this.itemOrigem,
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
    this.nomeSetorEstoque,
    this.ncm,
    this.codigoBarras,
    this.codigoBarras2,
    this.codigoReferencia,
    this.codigoFornecedor,
    this.codigoFabricante,
    this.codigoOriginal,
    this.endereco,
    this.enderecoDescricao,
    required this.codLocalArmazenagem,
    required this.nomeLocaArmazenagem,
    required this.quantidade,
    required this.quantidadeInterna,
    required this.quantidadeExterna,
    required this.quantidadeSeparacao,
  });

  SeparateItemConsultationModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    ExpeditionOrigem? origem,
    int? codOrigem,
    String? itemOrigem,
    int? codProduto,
    String? nomeProduto,
    Situation? ativo,
    String? codTipoProduto,
    String? codUnidadeMedida,
    String? nomeUnidadeMedida,
    int? codGrupoProduto,
    String? nomeGrupoProduto,
    int? codMarca,
    String? nomeMarca,
    int? codSetorEstoque,
    String? nomeSetorEstoque,
    String? ncm,
    String? codigoBarras,
    String? codigoBarras2,
    String? codigoReferencia,
    String? codigoFornecedor,
    String? codigoFabricante,
    String? codigoOriginal,
    String? endereco,
    String? enderecoDescricao,
    int? codLocalArmazenagem,
    String? nomeLocaArmazenagem,
    double? quantidade,
    double? quantidadeInterna,
    double? quantidadeExterna,
    double? quantidadeSeparacao,
  }) {
    return SeparateItemConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      itemOrigem: itemOrigem ?? this.itemOrigem,
      codProduto: codProduto ?? this.codProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      ativo: ativo ?? this.ativo,
      codTipoProduto: codTipoProduto ?? this.codTipoProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      nomeUnidadeMedida: nomeUnidadeMedida ?? this.nomeUnidadeMedida,
      codGrupoProduto: codGrupoProduto ?? this.codGrupoProduto,
      nomeGrupoProduto: nomeGrupoProduto ?? this.nomeGrupoProduto,
      codMarca: codMarca ?? this.codMarca,
      nomeMarca: nomeMarca ?? this.nomeMarca,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      nomeSetorEstoque: nomeSetorEstoque ?? this.nomeSetorEstoque,
      ncm: ncm ?? this.ncm,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      codigoBarras2: codigoBarras2 ?? this.codigoBarras2,
      codigoReferencia: codigoReferencia ?? this.codigoReferencia,
      codigoFornecedor: codigoFornecedor ?? this.codigoFornecedor,
      codigoFabricante: codigoFabricante ?? this.codigoFabricante,
      codigoOriginal: codigoOriginal ?? this.codigoOriginal,
      endereco: endereco ?? this.endereco,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
      codLocalArmazenagem: codLocalArmazenagem ?? this.codLocalArmazenagem,
      nomeLocaArmazenagem: nomeLocaArmazenagem ?? this.nomeLocaArmazenagem,
      quantidade: quantidade ?? this.quantidade,
      quantidadeInterna: quantidadeInterna ?? this.quantidadeInterna,
      quantidadeExterna: quantidadeExterna ?? this.quantidadeExterna,
      quantidadeSeparacao: quantidadeSeparacao ?? this.quantidadeSeparacao,
    );
  }

  factory SeparateItemConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateItemConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codSepararEstoque: json['CodSepararEstoque'],
        item: json['Item'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] ?? ''),
        codOrigem: json['CodOrigem'],
        itemOrigem: json['ItemOrigem'],
        codProduto: json['CodProduto'],
        nomeProduto: json['NomeProduto'],
        ativo: Situation.fromCodeWithFallback(json['Ativo'] ?? 'N'),
        codTipoProduto: json['CodTipoProduto'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        nomeUnidadeMedida: json['NomeUnidadeMedida'],
        codGrupoProduto: json['CodGrupoProduto'],
        nomeGrupoProduto: json['NomeGrupoProduto'],
        codMarca: json['CodMarca'],
        nomeMarca: json['NomeMarca'],
        codSetorEstoque: json['CodSetorEstoque'],
        nomeSetorEstoque: json['NomeSetorEstoque'],
        ncm: json['NCM'] ?? '00000000',
        codigoBarras: json['CodigoBarras'],
        codigoBarras2: json['CodigoBarras2'],
        codigoReferencia: json['CodigoReferencia'],
        codigoFornecedor: json['CodigoFornecedor'],
        codigoFabricante: json['CodigoFabricante'],
        codigoOriginal: json['CodigoOriginal'],
        endereco: json['Endereco'],
        enderecoDescricao: json['EnderecoDescricao'],
        codLocalArmazenagem: json['CodLocalArmazenagem'],
        nomeLocaArmazenagem: json['NomeLocaArmazenagem'],
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
        quantidadeInterna: AppHelper.stringToDouble(json['QuantidadeInterna']),
        quantidadeExterna: AppHelper.stringToDouble(json['QuantidadeExterna']),
        quantidadeSeparacao: AppHelper.stringToDouble(json['QuantidadeSeparacao']),
      );
    } catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Item': item,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'ItemOrigem': itemOrigem,
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
      'NomeSetorEstoque': nomeSetorEstoque,
      'NCM': ncm,
      'CodigoBarras': codigoBarras,
      'CodigoBarras2': codigoBarras2,
      'CodigoReferencia': codigoReferencia,
      'CodigoFornecedor': codigoFornecedor,
      'CodigoFabricante': codigoFabricante,
      'CodigoOriginal': codigoOriginal,
      'Endereco': endereco,
      'EnderecoDescricao': enderecoDescricao,
      'CodLocalArmazenagem': codLocalArmazenagem,
      'NomeLocaArmazenagem': nomeLocaArmazenagem,
      'Quantidade': quantidade.toStringAsFixed(4),
      'QuantidadeInterna': quantidadeInterna.toStringAsFixed(4),
      'QuantidadeExterna': quantidadeExterna.toStringAsFixed(4),
      'QuantidadeSeparacao': quantidadeSeparacao.toStringAsFixed(4),
    };
  }

  // === GETTERS PARA ENUMS ===

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
  String get origemDescription => origem.description;

  /// Retorna o código do ativo
  String get ativoCode => ativo.code;

  /// Retorna a descrição do ativo
  String get ativoDescription => ativo.description;

  /// Verifica se o produto está ativo
  bool get isAtivo => ativo == Situation.ativo;

  @override
  String toString() {
    return '''
      ExpedicaoSepararItemConsultaModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        item: $item, 
        origem: ${origem.description} (${origem.code}), 
        codOrigem: $codOrigem, 
        itemOrigem: $itemOrigem, 
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
        nomeSetorEstoque: $nomeSetorEstoque, 
        ncm: $ncm, 
        codigoBarras: $codigoBarras, 
        codigoBarras2: $codigoBarras2, 
        codigoReferencia: $codigoReferencia, 
        codigoFornecedor: $codigoFornecedor, 
        codigoFabricante: $codigoFabricante, 
        codigoOriginal: $codigoOriginal, 
        endereco: $endereco, 
        enderecoDescricao: $enderecoDescricao, 
        codLocalArmazenagem: $codLocalArmazenagem, 
        nomeLocaArmazenagem: $nomeLocaArmazenagem, 
        quantidade: $quantidade, 
        quantidadeInterna: $quantidadeInterna, 
        quantidadeExterna: $quantidadeExterna, 
        quantidadeSeparacao: $quantidadeSeparacao
    )''';
  }
}
