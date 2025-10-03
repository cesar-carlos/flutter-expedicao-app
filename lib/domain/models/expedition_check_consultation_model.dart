import 'package:flutter/material.dart';

import 'package:exp/core/utils/date_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:exp/domain/models/entity_type_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCheckConsultationModel {
  final int codEmpresa;
  final int codConferir;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionCartRouterSituation situacao;
  final int codCarrinhoPercurso;
  final DateTime dataLancamento;
  final String horaLancamento;
  final EntityType tipoEntidade;
  final int codEntidade;
  final String nomeEntidade;
  final int codPrioridade;
  final String nomePrioridade;
  final String? historico;
  final String? observacao;

  ExpeditionCheckConsultationModel({
    required this.codEmpresa,
    required this.codConferir,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.codCarrinhoPercurso,
    required this.dataLancamento,
    required this.horaLancamento,
    required this.tipoEntidade,
    required this.codEntidade,
    required this.nomeEntidade,
    required this.codPrioridade,
    required this.nomePrioridade,
    this.historico,
    this.observacao,
  });

  ExpeditionCheckConsultationModel copyWith({
    int? codEmpresa,
    int? codConferir,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionCartRouterSituation? situacao,
    int? codCarrinhoPercurso,
    DateTime? dataLancamento,
    String? horaLancamento,
    EntityType? tipoEntidade,
    int? codEntidade,
    String? nomeEntidade,
    int? codPrioridade,
    String? nomePrioridade,
    String? historico,
    String? observacao,
  }) {
    return ExpeditionCheckConsultationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codConferir: codConferir ?? this.codConferir,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      situacao: situacao ?? this.situacao,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      horaLancamento: horaLancamento ?? this.horaLancamento,
      tipoEntidade: tipoEntidade ?? this.tipoEntidade,
      codEntidade: codEntidade ?? this.codEntidade,
      nomeEntidade: nomeEntidade ?? this.nomeEntidade,
      codPrioridade: codPrioridade ?? this.codPrioridade,
      nomePrioridade: nomePrioridade ?? this.nomePrioridade,
      historico: historico ?? this.historico,
      observacao: observacao ?? this.observacao,
    );
  }

  factory ExpeditionCheckConsultationModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCheckConsultationModel(
        codEmpresa: json['CodEmpresa'],
        codConferir: json['CodConferir'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        codOrigem: json['CodOrigem'],
        situacao: ExpeditionCartRouterSituation.fromCode(json['Situacao']) ?? ExpeditionCartRouterSituation.vazio,
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        dataLancamento: DateHelper.tryStringToDate(json['DataLancamento']),
        horaLancamento: json['HoraLancamento'],
        tipoEntidade: EntityType.fromCode(json['TipoEntidade']) ?? EntityType.cliente,
        codEntidade: json['CodEntidade'],
        nomeEntidade: json['NomeEntidade'],
        codPrioridade: json['CodPrioridade'],
        nomePrioridade: json['NomePrioridade'],
        historico: json['Historico'],
        observacao: json['Observacao'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCheckConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCheckConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodConferir': codConferir,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'DataLancamento': dataLancamento.toIso8601String(),
      'HoraLancamento': horaLancamento,
      'TipoEntidade': tipoEntidade.code,
      'CodEntidade': codEntidade,
      'NomeEntidade': nomeEntidade,
      'CodPrioridade': codPrioridade,
      'NomePrioridade': nomePrioridade,
      'Historico': historico,
      'Observacao': observacao,
    };
  }

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => situacao.color;

  bool isSituacao(String situacaoToCheck) => situacao.code.toLowerCase() == situacaoToCheck.toLowerCase();

  /// Retorna o código do tipo de entidade
  String get tipoEntidadeCode => tipoEntidade.code;

  /// Retorna a descrição do tipo de entidade
  String get tipoEntidadeDescription => tipoEntidade.description;

  /// Retorna a cor do tipo de entidade
  Color get tipoEntidadeColor => tipoEntidade.color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCheckConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codConferir == codConferir;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codConferir.hashCode;

  @override
  String toString() {
    return '''ExpeditionCheckConsultationModel(
        codEmpresa: $codEmpresa, 
        codConferir: $codConferir, 
        origem: ${origem.description} (${origem.code}),
        codOrigem: $codOrigem, 
        situacao: ${situacao.description}, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        dataLancamento: $dataLancamento, 
        horaLancamento: $horaLancamento, 
        tipoEntidade: ${tipoEntidade.description} (${tipoEntidade.code}),
        codEntidade: $codEntidade, 
        nomeEntidade: $nomeEntidade, 
        codPrioridade: $codPrioridade, 
        nomePrioridade: $nomePrioridade, 
        historico: $historico, 
        observacao: $observacao
)''';
  }
}
