import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';

class SeparationUserSectorConsultationModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionSituation separarEstoqueSituacao;
  final int codSetorEstoque;
  final String descricaoSetorEstoque;
  final int codPrioridade;
  final String descricaoPrioridade;
  final int prioridade;
  final double quantidadeItens;
  final double quantidadeItensSeparacao;
  final double quantidadeItensSetor;
  final double quantidadeItensSeparacaoSetor;
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

  SeparationUserSectorConsultationModel copyWith({
    int? codUsuario,
    String? nomeUsuario,
    String? estacaoSeparacao,
  }) {
    return SeparationUserSectorConsultationModel(
      codEmpresa: codEmpresa,
      codSepararEstoque: codSepararEstoque,
      separarEstoqueSituacao: separarEstoqueSituacao,
      codSetorEstoque: codSetorEstoque,
      descricaoSetorEstoque: descricaoSetorEstoque,
      codPrioridade: codPrioridade,
      descricaoPrioridade: descricaoPrioridade,
      prioridade: prioridade,
      quantidadeItens: quantidadeItens,
      quantidadeItensSeparacao: quantidadeItensSeparacao,
      quantidadeItensSetor: quantidadeItensSetor,
      quantidadeItensSeparacaoSetor: quantidadeItensSeparacaoSetor,
      carrinhosAbertosUsuario: carrinhosAbertosUsuario,
      codUsuario: codUsuario ?? this.codUsuario,
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      estacaoSeparacao: estacaoSeparacao ?? this.estacaoSeparacao,
    );
  }

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
        quantidadeItens: AppHelper.stringToDouble(json['QuantidadeItens']),
        quantidadeItensSeparacao: AppHelper.stringToDouble(json['QuantidadeItensSeparacao']),
        quantidadeItensSetor: AppHelper.stringToDouble(json['QuantidadeItensSetor']),
        quantidadeItensSeparacaoSetor: AppHelper.stringToDouble(json['QuantidadeItensSeparacaoSetor']),
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

  String get situacaoCode => separarEstoqueSituacao.code;

  String get situacaoDescription => separarEstoqueSituacao.description;

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
