import 'package:flutter/material.dart';

import 'package:exp/core/results/index.dart';
import 'package:exp/domain/models/situation/expedition_situation_model.dart';

/// Modelo para consulta de separação por usuário e setor
class SeparationUserSectorConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionSituation separarEstoqueSituacao;
  final int codSetorEstoque;
  final String descricaoSetorEstoque;
  final int codPrioridade;
  final String descricaoPrioridade;
  final int prioridade;
  final int quantidadeItens;
  final int quantidadeItensSeparacao;
  final int quantidadeItensSetor;
  final int quantidadeItensSeparacaoSetor;
  final String carrinhosAbertosUsuario;
  final int? codUsuario;
  final String? nomeUsuario;
  final String? estacaoSeparacao;

  const SeparationUserSectorConsultationModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.separarEstoqueSituacao,
    required this.codSetorEstoque,
    required this.descricaoSetorEstoque,
    required this.codPrioridade,
    required this.descricaoPrioridade,
    required this.prioridade,
    required this.quantidadeItens,
    required this.quantidadeItensSeparacao,
    required this.quantidadeItensSetor,
    required this.quantidadeItensSeparacaoSetor,
    required this.carrinhosAbertosUsuario,
    this.codUsuario,
    this.nomeUsuario,
    this.estacaoSeparacao,
  });

  factory SeparationUserSectorConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparationUserSectorConsultationModel(
        codEmpresa: json['CodEmpresa'] as int,
        codSepararEstoque: json['CodSepararEstoque'] as int,
        separarEstoqueSituacao:
            ExpeditionSituation.fromCode(json['SepararEstoqueSituacao'] as String? ?? '') ??
            ExpeditionSituation.aguardando,
        codSetorEstoque: json['CodSetorEstoque'] as int,
        descricaoSetorEstoque: json['DescricaoSetorEstoque'] as String,
        codPrioridade: json['CodPrioridade'] as int,
        descricaoPrioridade: json['DescricaoPrioridade'] as String,
        prioridade: json['Prioridade'] as int,
        quantidadeItens: json['QuantidadeItens'] as int,
        quantidadeItensSeparacao: json['QuantidadeItensSeparacao'] as int,
        quantidadeItensSetor: json['QuantidadeItensSetor'] as int,
        quantidadeItensSeparacaoSetor: json['QuantidadeItensSeparacaoSetor'] as int,
        carrinhosAbertosUsuario: json['CarrinhosAbertosUsuario'] as String,
        codUsuario: json['CodUsuario'] as int?,
        nomeUsuario: json['NomeUsuario'] as String?,
        estacaoSeparacao: json['EstacaoSeparacao'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'SepararEstoqueSituacao': separarEstoqueSituacao.code,
      'CodSetorEstoque': codSetorEstoque,
      'DescricaoSetorEstoque': descricaoSetorEstoque,
      'CodPrioridade': codPrioridade,
      'DescricaoPrioridade': descricaoPrioridade,
      'Prioridade': prioridade,
      'QuantidadeItens': quantidadeItens,
      'QuantidadeItensSeparacao': quantidadeItensSeparacao,
      'QuantidadeItensSetor': quantidadeItensSetor,
      'QuantidadeItensSeparacaoSetor': quantidadeItensSeparacaoSetor,
      'CarrinhosAbertosUsuario': carrinhosAbertosUsuario,
      'CodUsuario': codUsuario,
      'NomeUsuario': nomeUsuario,
      'EstacaoSeparacao': estacaoSeparacao,
    };
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparationUserSectorConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparationUserSectorConsultationModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparationUserSectorConsultationModel &&
        other.codSepararEstoque == codSepararEstoque &&
        other.codEmpresa == codEmpresa &&
        other.codSetorEstoque == codSetorEstoque;
  }

  @override
  int get hashCode => codSepararEstoque.hashCode ^ codEmpresa.hashCode ^ codSetorEstoque.hashCode;

  /// Retorna o código da situação
  String get situacaoCode => separarEstoqueSituacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => separarEstoqueSituacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => separarEstoqueSituacao.color;

  @override
  String toString() {
    return '''SeparationUserSectorConsultationModel(
        codEmpresa: $codEmpresa,
        codSepararEstoque: $codSepararEstoque,
        separarEstoqueSituacao: $separarEstoqueSituacao,
        codSetorEstoque: $codSetorEstoque,
        descricaoSetorEstoque: $descricaoSetorEstoque,
        codPrioridade: $codPrioridade,
        descricaoPrioridade: $descricaoPrioridade,
        prioridade: $prioridade,
        quantidadeItens: $quantidadeItens,
        quantidadeItensSeparacao: $quantidadeItensSeparacao,
        quantidadeItensSetor: $quantidadeItensSetor,
        quantidadeItensSeparacaoSetor: $quantidadeItensSeparacaoSetor,
        carrinhosAbertosUsuario: $carrinhosAbertosUsuario,
        codUsuario: $codUsuario,
        nomeUsuario: $nomeUsuario,
        estacaoSeparacao: $estacaoSeparacao
)''';
  }
}
