import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionItemPrintConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final String item;
  final String? origem;
  final int? codOrigem;
  final String? itemOrigem;
  final int? codProdutoVendido;
  final DateTime dataSepararEstoque;
  final String horaSepararEstoque;
  final String situacao;
  final int? codTipoOperacaoSaida;
  final String? descricaoTipoOperacaoSaida;
  final int? codVendedor;
  final String? nomeVendedor;
  final String tipoEntidade;
  final String codEntidade;
  final String nomeEntidade;
  final int codPrioridade;
  final String descricaoPrioridade;
  final int? codCliente;
  final String? nomeCliente;
  final String? nomeFantasiaCliente;
  final int? codTransportadora;
  final String? nomeFantasiaTransportadora;
  final String? razaoSocialTransportadora;
  final int? codMunicipioEntrega;
  final String? nomeMunicipioEntrega;
  final int codLocalArmazenagem;
  final String nomeLocalArmazenagem;
  final int? codSetorEstoque;
  final String? descricaoSetorEstoque;
  final int codProduto;
  final String nomeProduto;
  final String? descricaoProduto;
  final int? codGrupoProduto;
  final String? nomeGrupoProduto;
  final int? codMarca;
  final String? nomeMarca;
  final String? codigoFabricante;
  final String? codigoFornecedor;
  final String? codigoReferencia;
  final String? codigoBarras;
  final String? descricaoEnderecoProduto;
  final String codUnidadeMedida;
  final String descricaoUnidadeMedida;
  final double quantidade;
  final double quantidadeInterna;
  final double quantidadeExterna;
  final double quantidadeSeparacao;
  final String? historicoSepararEstoque;
  final String? observacaoSepararEstoque;
  final String? orcamentoObservacao;

  const ExpeditionItemPrintConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.item,
    this.origem,
    this.codOrigem,
    this.itemOrigem,
    this.codProdutoVendido,
    required this.dataSepararEstoque,
    required this.horaSepararEstoque,
    required this.situacao,
    this.codTipoOperacaoSaida,
    this.descricaoTipoOperacaoSaida,
    this.codVendedor,
    this.nomeVendedor,
    required this.tipoEntidade,
    required this.codEntidade,
    required this.nomeEntidade,
    required this.codPrioridade,
    required this.descricaoPrioridade,
    this.codCliente,
    this.nomeCliente,
    this.nomeFantasiaCliente,
    this.codTransportadora,
    this.nomeFantasiaTransportadora,
    this.razaoSocialTransportadora,
    this.codMunicipioEntrega,
    this.nomeMunicipioEntrega,
    required this.codLocalArmazenagem,
    required this.nomeLocalArmazenagem,
    this.codSetorEstoque,
    this.descricaoSetorEstoque,
    required this.codProduto,
    required this.nomeProduto,
    this.descricaoProduto,
    this.codGrupoProduto,
    this.nomeGrupoProduto,
    this.codMarca,
    this.nomeMarca,
    this.codigoFabricante,
    this.codigoFornecedor,
    this.codigoReferencia,
    this.codigoBarras,
    this.descricaoEnderecoProduto,
    required this.codUnidadeMedida,
    required this.descricaoUnidadeMedida,
    required this.quantidade,
    required this.quantidadeInterna,
    required this.quantidadeExterna,
    required this.quantidadeSeparacao,
    this.historicoSepararEstoque,
    this.observacaoSepararEstoque,
    this.orcamentoObservacao,
  });

  ExpeditionItemPrintConsultationModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    String? item,
    String? origem,
    int? codOrigem,
    String? itemOrigem,
    int? codProdutoVendido,
    DateTime? dataSepararEstoque,
    String? horaSepararEstoque,
    String? situacao,
    int? codTipoOperacaoSaida,
    String? descricaoTipoOperacaoSaida,
    int? codVendedor,
    String? nomeVendedor,
    String? tipoEntidade,
    String? codEntidade,
    String? nomeEntidade,
    int? codPrioridade,
    String? descricaoPrioridade,
    int? codCliente,
    String? nomeCliente,
    String? nomeFantasiaCliente,
    int? codTransportadora,
    String? nomeFantasiaTransportadora,
    String? razaoSocialTransportadora,
    int? codMunicipioEntrega,
    String? nomeMunicipioEntrega,
    int? codLocalArmazenagem,
    String? nomeLocalArmazenagem,
    int? codSetorEstoque,
    String? descricaoSetorEstoque,
    int? codProduto,
    String? nomeProduto,
    String? descricaoProduto,
    int? codGrupoProduto,
    String? nomeGrupoProduto,
    int? codMarca,
    String? nomeMarca,
    String? codigoFabricante,
    String? codigoFornecedor,
    String? codigoReferencia,
    String? codigoBarras,
    String? descricaoEnderecoProduto,
    String? codUnidadeMedida,
    String? descricaoUnidadeMedida,
    double? quantidade,
    double? quantidadeInterna,
    double? quantidadeExterna,
    double? quantidadeSeparacao,
    String? historicoSepararEstoque,
    String? observacaoSepararEstoque,
    String? orcamentoObservacao,
  }) {
    return ExpeditionItemPrintConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      itemOrigem: itemOrigem ?? this.itemOrigem,
      codProdutoVendido: codProdutoVendido ?? this.codProdutoVendido,
      dataSepararEstoque: dataSepararEstoque ?? this.dataSepararEstoque,
      horaSepararEstoque: horaSepararEstoque ?? this.horaSepararEstoque,
      situacao: situacao ?? this.situacao,
      codTipoOperacaoSaida: codTipoOperacaoSaida ?? this.codTipoOperacaoSaida,
      descricaoTipoOperacaoSaida: descricaoTipoOperacaoSaida ?? this.descricaoTipoOperacaoSaida,
      codVendedor: codVendedor ?? this.codVendedor,
      nomeVendedor: nomeVendedor ?? this.nomeVendedor,
      tipoEntidade: tipoEntidade ?? this.tipoEntidade,
      codEntidade: codEntidade ?? this.codEntidade,
      nomeEntidade: nomeEntidade ?? this.nomeEntidade,
      codPrioridade: codPrioridade ?? this.codPrioridade,
      descricaoPrioridade: descricaoPrioridade ?? this.descricaoPrioridade,
      codCliente: codCliente ?? this.codCliente,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      nomeFantasiaCliente: nomeFantasiaCliente ?? this.nomeFantasiaCliente,
      codTransportadora: codTransportadora ?? this.codTransportadora,
      nomeFantasiaTransportadora: nomeFantasiaTransportadora ?? this.nomeFantasiaTransportadora,
      razaoSocialTransportadora: razaoSocialTransportadora ?? this.razaoSocialTransportadora,
      codMunicipioEntrega: codMunicipioEntrega ?? this.codMunicipioEntrega,
      nomeMunicipioEntrega: nomeMunicipioEntrega ?? this.nomeMunicipioEntrega,
      codLocalArmazenagem: codLocalArmazenagem ?? this.codLocalArmazenagem,
      nomeLocalArmazenagem: nomeLocalArmazenagem ?? this.nomeLocalArmazenagem,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      descricaoSetorEstoque: descricaoSetorEstoque ?? this.descricaoSetorEstoque,
      codProduto: codProduto ?? this.codProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      descricaoProduto: descricaoProduto ?? this.descricaoProduto,
      codGrupoProduto: codGrupoProduto ?? this.codGrupoProduto,
      nomeGrupoProduto: nomeGrupoProduto ?? this.nomeGrupoProduto,
      codMarca: codMarca ?? this.codMarca,
      nomeMarca: nomeMarca ?? this.nomeMarca,
      codigoFabricante: codigoFabricante ?? this.codigoFabricante,
      codigoFornecedor: codigoFornecedor ?? this.codigoFornecedor,
      codigoReferencia: codigoReferencia ?? this.codigoReferencia,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      descricaoEnderecoProduto: descricaoEnderecoProduto ?? this.descricaoEnderecoProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      descricaoUnidadeMedida: descricaoUnidadeMedida ?? this.descricaoUnidadeMedida,
      quantidade: quantidade ?? this.quantidade,
      quantidadeInterna: quantidadeInterna ?? this.quantidadeInterna,
      quantidadeExterna: quantidadeExterna ?? this.quantidadeExterna,
      quantidadeSeparacao: quantidadeSeparacao ?? this.quantidadeSeparacao,
      historicoSepararEstoque: historicoSepararEstoque ?? this.historicoSepararEstoque,
      observacaoSepararEstoque: observacaoSepararEstoque ?? this.observacaoSepararEstoque,
      orcamentoObservacao: orcamentoObservacao ?? this.orcamentoObservacao,
    );
  }

  factory ExpeditionItemPrintConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionItemPrintConsultationModel(
        codEmpresa: AppHelper.stringToInt(json['CodEmpresa']),
        codSepararEstoque: AppHelper.stringToInt(json['CodSepararEstoque']),
        item: json['Item'] as String? ?? '',
        origem: json['Origem'] as String?,
        codOrigem: json['CodOrigem'] != null ? AppHelper.stringToInt(json['CodOrigem']) : null,
        itemOrigem: json['ItemOrigem'] as String?,
        codProdutoVendido: json['CodProdutoVendido'] != null ? AppHelper.stringToInt(json['CodProdutoVendido']) : null,
        dataSepararEstoque: AppHelper.tryStringToDate(json['DataSepararEstoque']),
        horaSepararEstoque: json['HoraSepararEstoque'] as String? ?? '',
        situacao: json['Situacao'] as String? ?? '',
        codTipoOperacaoSaida: json['CodTipoOperacaoSaida'] != null
            ? AppHelper.stringToInt(json['CodTipoOperacaoSaida'])
            : null,
        descricaoTipoOperacaoSaida: json['DescricaoTipoOperacaoSaida'] as String?,
        codVendedor: json['CodVendedor'] != null ? AppHelper.stringToInt(json['CodVendedor']) : null,
        nomeVendedor: json['NomeVendedor'] as String?,
        tipoEntidade: json['TipoEntidade'] as String? ?? '',
        codEntidade: json['CodEntidade']?.toString() ?? '',
        nomeEntidade: json['NomeEntidade'] as String? ?? '',
        codPrioridade: AppHelper.stringToInt(json['CodPrioridade']),
        descricaoPrioridade: json['DescricaoPrioridade'] as String? ?? '',
        codCliente: json['CodCliente'] != null ? AppHelper.stringToInt(json['CodCliente']) : null,
        nomeCliente: json['NomeCliente'] as String?,
        nomeFantasiaCliente: json['NomeFantasiaCliente'] as String?,
        codTransportadora: json['CodTransportadora'] != null ? AppHelper.stringToInt(json['CodTransportadora']) : null,
        nomeFantasiaTransportadora: json['NomeFantasiaTransportadora'] as String?,
        razaoSocialTransportadora: json['RazaoSocialTransportadora'] as String?,
        codMunicipioEntrega: json['CodMunicipioEntrega'] != null
            ? AppHelper.stringToInt(json['CodMunicipioEntrega'])
            : null,
        nomeMunicipioEntrega: json['NomeMunicipioEntrega'] as String?,
        codLocalArmazenagem: AppHelper.stringToInt(json['CodLocalArmazenagem']),
        nomeLocalArmazenagem: json['NomeLocalArmazenagem'] as String? ?? '',
        codSetorEstoque: json['CodSetorEstoque'] != null ? AppHelper.stringToInt(json['CodSetorEstoque']) : null,
        descricaoSetorEstoque: json['DescricaoSetorEstoque'] as String?,
        codProduto: AppHelper.stringToInt(json['CodProduto']),
        nomeProduto: json['NomeProduto'] as String? ?? '',
        descricaoProduto: json['DescricaoProduto'] as String?,
        codGrupoProduto: json['CodGrupoProduto'] != null ? AppHelper.stringToInt(json['CodGrupoProduto']) : null,
        nomeGrupoProduto: json['NomeGrupoProduto'] as String?,
        codMarca: json['CodMarca'] != null ? AppHelper.stringToInt(json['CodMarca']) : null,
        nomeMarca: json['NomeMarca'] as String?,
        codigoFabricante: json['CodigoFabricante'] as String?,
        codigoFornecedor: json['CodigoFornecedor'] as String?,
        codigoReferencia: json['CodigoReferencia'] as String?,
        codigoBarras: json['CodigoBarras'] as String?,
        descricaoEnderecoProduto: json['DescricaoEnderecoProduto'] as String?,
        codUnidadeMedida: json['CodUnidadeMedida'] as String? ?? '',
        descricaoUnidadeMedida: json['DescricaoUnidadeMedida'] as String? ?? '',
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
        quantidadeInterna: AppHelper.stringToDouble(json['QuantidadeInterna']),
        quantidadeExterna: AppHelper.stringToDouble(json['QuantidadeExterna']),
        quantidadeSeparacao: AppHelper.stringToDouble(json['QuantidadeSeparacao']),
        historicoSepararEstoque: json['HistoricoSepararEstoque'] as String?,
        observacaoSepararEstoque: json['ObservacaoSepararEstoque'] as String?,
        orcamentoObservacao: json['OrcamentoObservacao'] as String?,
      );
    } catch (_) {
      rethrow;
    }
  }

  static Result<ExpeditionItemPrintConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionItemPrintConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Item': item,
      'Origem': origem,
      'CodOrigem': codOrigem,
      'ItemOrigem': itemOrigem,
      'CodProdutoVendido': codProdutoVendido,
      'DataSepararEstoque': dataSepararEstoque.toIso8601String(),
      'HoraSepararEstoque': horaSepararEstoque,
      'Situacao': situacao,
      'CodTipoOperacaoSaida': codTipoOperacaoSaida,
      'DescricaoTipoOperacaoSaida': descricaoTipoOperacaoSaida,
      'CodVendedor': codVendedor,
      'NomeVendedor': nomeVendedor,
      'TipoEntidade': tipoEntidade,
      'CodEntidade': codEntidade,
      'NomeEntidade': nomeEntidade,
      'CodPrioridade': codPrioridade,
      'DescricaoPrioridade': descricaoPrioridade,
      'CodCliente': codCliente,
      'NomeCliente': nomeCliente,
      'NomeFantasiaCliente': nomeFantasiaCliente,
      'CodTransportadora': codTransportadora,
      'NomeFantasiaTransportadora': nomeFantasiaTransportadora,
      'RazaoSocialTransportadora': razaoSocialTransportadora,
      'CodMunicipioEntrega': codMunicipioEntrega,
      'NomeMunicipioEntrega': nomeMunicipioEntrega,
      'CodLocalArmazenagem': codLocalArmazenagem,
      'NomeLocalArmazenagem': nomeLocalArmazenagem,
      'CodSetorEstoque': codSetorEstoque,
      'DescricaoSetorEstoque': descricaoSetorEstoque,
      'CodProduto': codProduto,
      'NomeProduto': nomeProduto,
      'DescricaoProduto': descricaoProduto,
      'CodGrupoProduto': codGrupoProduto,
      'NomeGrupoProduto': nomeGrupoProduto,
      'CodMarca': codMarca,
      'NomeMarca': nomeMarca,
      'CodigoFabricante': codigoFabricante,
      'CodigoFornecedor': codigoFornecedor,
      'CodigoReferencia': codigoReferencia,
      'CodigoBarras': codigoBarras,
      'DescricaoEnderecoProduto': descricaoEnderecoProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'DescricaoUnidadeMedida': descricaoUnidadeMedida,
      'Quantidade': quantidade,
      'QuantidadeInterna': quantidadeInterna,
      'QuantidadeExterna': quantidadeExterna,
      'QuantidadeSeparacao': quantidadeSeparacao,
      'HistoricoSepararEstoque': historicoSepararEstoque,
      'ObservacaoSepararEstoque': observacaoSepararEstoque,
      'OrcamentoObservacao': orcamentoObservacao,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionItemPrintConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codSepararEstoque.hashCode ^ item.hashCode;

  @override
  String toString() {
    return 'ExpeditionItemPrintConsultationModel(codEmpresa: $codEmpresa, codSepararEstoque: $codSepararEstoque, item: $item, nomeEntidade: $nomeEntidade, nomeProduto: $nomeProduto)';
  }
}
