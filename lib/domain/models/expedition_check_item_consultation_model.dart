import 'package:flutter/material.dart';

import 'package:exp/core/utils/app_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCheckItemConsultationModel {
  final int codEmpresa;
  final int codConferir;
  final String item;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final ExpeditionCartSituation situacaoCarrinhoPercurso;
  final int codCarrinho;
  final int codProduto;
  final String nomeProduto;
  final String codUnidadeMedida;
  final String nomeUnidadeMedida;
  final int codGrupoProduto;
  final String nomeGrupoProduto;
  final int? codMarca;
  final String? nomeMarca;
  final int? codSetorEstoque;
  final String? nomeSetorEstoque;
  final String? codigoBarras;
  final String? codigoBarras2;
  final String? codigoReferencia;
  final String? codigoFornecedor;
  final String? codigoFabricante;
  final String? codigoOriginal;
  final String? endereco;
  final String? enderecoDescricao;
  final double quantidade;
  final double quantidadeConferida;

  ExpeditionCheckItemConsultationModel({
    required this.codEmpresa,
    required this.codConferir,
    required this.item,
    required this.origem,
    required this.codOrigem,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.situacaoCarrinhoPercurso,
    required this.codCarrinho,
    required this.codProduto,
    required this.nomeProduto,
    required this.codUnidadeMedida,
    required this.nomeUnidadeMedida,
    required this.codGrupoProduto,
    required this.nomeGrupoProduto,
    this.codMarca,
    this.nomeMarca,
    this.codSetorEstoque,
    this.nomeSetorEstoque,
    this.codigoBarras,
    this.codigoBarras2,
    this.codigoReferencia,
    this.codigoFornecedor,
    this.codigoFabricante,
    this.codigoOriginal,
    this.endereco,
    this.enderecoDescricao,
    required this.quantidade,
    required this.quantidadeConferida,
  });

  ExpeditionCheckItemConsultationModel copyWith({
    int? codEmpresa,
    int? codConferir,
    String? item,
    ExpeditionOrigem? origem,
    int? codOrigem,
    int? codCarrinhoPercurso,
    String? itemCarrinhoPercurso,
    ExpeditionCartSituation? situacaoCarrinhoPercurso,
    int? codCarrinho,
    int? codProduto,
    String? nomeProduto,
    String? codTipoProduto,
    String? codUnidadeMedida,
    String? nomeUnidadeMedida,
    int? codGrupoProduto,
    String? nomeGrupoProduto,
    int? codMarca,
    String? nomeMarca,
    int? codSetorEstoque,
    String? nomeSetorEstoque,
    String? codigoBarras,
    String? codigoBarras2,
    String? codigoReferencia,
    String? codigoFornecedor,
    String? codigoFabricante,
    String? codigoOriginal,
    String? endereco,
    String? enderecoDescricao,
    double? quantidade,
    double? quantidadeConferida,
  }) {
    return ExpeditionCheckItemConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codConferir: codConferir ?? this.codConferir,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      situacaoCarrinhoPercurso: situacaoCarrinhoPercurso ?? this.situacaoCarrinhoPercurso,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      codProduto: codProduto ?? this.codProduto,
      nomeProduto: nomeProduto ?? this.nomeProduto,
      codUnidadeMedida: codUnidadeMedida ?? this.codUnidadeMedida,
      nomeUnidadeMedida: nomeUnidadeMedida ?? this.nomeUnidadeMedida,
      codGrupoProduto: codGrupoProduto ?? this.codGrupoProduto,
      nomeGrupoProduto: nomeGrupoProduto ?? this.nomeGrupoProduto,
      codMarca: codMarca ?? this.codMarca,
      nomeMarca: nomeMarca ?? this.nomeMarca,
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      nomeSetorEstoque: nomeSetorEstoque ?? this.nomeSetorEstoque,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      codigoBarras2: codigoBarras2 ?? this.codigoBarras2,
      codigoReferencia: codigoReferencia ?? this.codigoReferencia,
      codigoFornecedor: codigoFornecedor ?? this.codigoFornecedor,
      codigoFabricante: codigoFabricante ?? this.codigoFabricante,
      codigoOriginal: codigoOriginal ?? this.codigoOriginal,
      endereco: endereco ?? this.endereco,
      enderecoDescricao: enderecoDescricao ?? this.enderecoDescricao,
      quantidade: quantidade ?? this.quantidade,
      quantidadeConferida: quantidadeConferida ?? this.quantidadeConferida,
    );
  }

  factory ExpeditionCheckItemConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCheckItemConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codConferir: json['CodConferir'],
        item: json['Item'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        codOrigem: json['CodOrigem'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        situacaoCarrinhoPercurso:
            ExpeditionCartSituation.fromCode(json['SituacaoCarrinhoPercurso']) ?? ExpeditionCartSituation.vazio,
        codCarrinho: json['CodCarrinho'],
        codProduto: json['CodProduto'],
        nomeProduto: json['NomeProduto'],
        codUnidadeMedida: json['CodUnidadeMedida'],
        nomeUnidadeMedida: json['NomeUnidadeMedida'],
        codGrupoProduto: json['CodGrupoProduto'],
        nomeGrupoProduto: json['NomeGrupoProduto'],
        codMarca: json['CodMarca'],
        nomeMarca: json['NomeMarca'],
        codSetorEstoque: json['CodSetorEstoque'],
        nomeSetorEstoque: json['NomeSetorEstoque'],
        codigoBarras: json['CodigoBarras'],
        codigoBarras2: json['CodigoBarras2'],
        codigoReferencia: json['CodigoReferencia'],
        codigoFornecedor: json['CodigoFornecedor'],
        codigoFabricante: json['CodigoFabricante'],
        codigoOriginal: json['CodigoOriginal'],
        endereco: json['Endereco'],
        enderecoDescricao: json['EnderecoDescricao'],
        quantidade: AppHelper.stringToDouble(json['Quantidade']),
        quantidadeConferida: AppHelper.stringToDouble(json['QuantidadeConferida']),
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCheckItemConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCheckItemConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodConferir': codConferir,
      'Item': item,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'SituacaoCarrinhoPercurso': situacaoCarrinhoPercurso.code,
      'CodCarrinho': codCarrinho,
      'CodProduto': codProduto,
      'NomeProduto': nomeProduto,
      'CodUnidadeMedida': codUnidadeMedida,
      'NomeUnidadeMedida': nomeUnidadeMedida,
      'CodGrupoProduto': codGrupoProduto,
      'NomeGrupoProduto': nomeGrupoProduto,
      'CodMarca': codMarca,
      'NomeMarca': nomeMarca,
      'CodSetorEstoque': codSetorEstoque,
      'NomeSetorEstoque': nomeSetorEstoque,
      'CodigoBarras': codigoBarras,
      'CodigoBarras2': codigoBarras2,
      'CodigoReferencia': codigoReferencia,
      'CodigoFornecedor': codigoFornecedor,
      'CodigoFabricante': codigoFabricante,
      'CodigoOriginal': codigoOriginal,
      'Endereco': endereco,
      'EnderecoDescricao': enderecoDescricao,
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

  /// Retorna o código da situação do carrinho percurso
  String get situacaoCarrinhoPercursoCode => situacaoCarrinhoPercurso.code;

  /// Retorna a descrição da situação do carrinho percurso
  String get situacaoCarrinhoPercursoDescription => situacaoCarrinhoPercurso.description;

  /// Retorna a cor da situação do carrinho percurso
  Color get situacaoCarrinhoPercursoColor => situacaoCarrinhoPercurso.color;

  bool isSituacaoCarrinhoPercurso(String situacaoToCheck) =>
      situacaoCarrinhoPercurso.code.toLowerCase() == situacaoToCheck.toLowerCase();

  /// Método legado - mantido para compatibilidade
  @Deprecated('Use isTotalmenteConferido em vez disso')
  bool isComplited() {
    return quantidade == quantidadeConferida;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCheckItemConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codConferir == codConferir &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codConferir.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''ExpeditionCheckItemConsultationModel(
        codEmpresa: $codEmpresa, 
        codConferir: $codConferir, 
        item: $item, 
        origem: ${origem.description} (${origem.code}),
        codOrigem: $codOrigem, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        situacaoCarrinhoPercurso: ${situacaoCarrinhoPercurso.description},
        codCarrinho: $codCarrinho, 
        codProduto: $codProduto, 
        nomeProduto: $nomeProduto, 
        codUnidadeMedida: $codUnidadeMedida, 
        nomeUnidadeMedida: $nomeUnidadeMedida, 
        codGrupoProduto: $codGrupoProduto, 
        nomeGrupoProduto: $nomeGrupoProduto, 
        codMarca: $codMarca, 
        nomeMarca: $nomeMarca, 
        codSetorEstoque: $codSetorEstoque, 
        nomeSetorEstoque: $nomeSetorEstoque, 
        codigoBarras: $codigoBarras, 
        codigoBarras2: $codigoBarras2, 
        codigoReferencia: $codigoReferencia, 
        codigoFornecedor: $codigoFornecedor, 
        codigoFabricante: $codigoFabricante, 
        codigoOriginal: $codigoOriginal, 
        endereco: $endereco, 
        enderecoDescricao: $enderecoDescricao, 
        quantidade: $quantidade, 
        quantidadeConferida: $quantidadeConferida,
        diferencaQuantidade: $diferencaQuantidade,
        porcentagemConferencia: ${porcentagemConferencia.toStringAsFixed(2)}%
)''';
  }
}
