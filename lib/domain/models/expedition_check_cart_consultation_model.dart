import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/core/utils/date_helper.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCheckCartConsultationModel {
  final int codEmpresa;
  final int codConferir;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final ExpeditionCartRouterSituation situacao;
  final int codCarrinhoPercurso;
  final String itemCarrinhoPercurso;
  final int codPrioridade;
  final String nomePrioridade;
  final int codCarrinho;
  final String nomeCarrinho;
  final String codigoBarrasCarrinho;
  final ExpeditionCartSituation situacaoCarrinhoConferencia;
  final DateTime dataInicioPercurso;
  final String horaInicioPercurso;
  final int codPercursoEstagio;
  final String nomePercursoEstagio;
  final int codUsuarioInicioEstagio;
  final String nomeUsuarioInicioEstagio;
  final DateTime dataInicioEstagio;
  final String horaInicioEstagio;
  final int codUsuarioFinalizacaoEstagio;
  final String nomeUsuarioFinalizacaoEstagio;
  final DateTime dataFinalizacaoEstagio;
  final String horaFinalizacaoEstagio;
  final double totalItemConferir;
  final double totalItemConferido;

  ExpeditionCheckCartConsultationModel({
    required this.codEmpresa,
    required this.codConferir,
    required this.origem,
    required this.codOrigem,
    required this.situacao,
    required this.codCarrinhoPercurso,
    required this.itemCarrinhoPercurso,
    required this.codPrioridade,
    required this.nomePrioridade,
    required this.codCarrinho,
    required this.nomeCarrinho,
    required this.codigoBarrasCarrinho,
    required this.situacaoCarrinhoConferencia,
    required this.dataInicioPercurso,
    required this.horaInicioPercurso,
    required this.codPercursoEstagio,
    required this.nomePercursoEstagio,
    required this.codUsuarioInicioEstagio,
    required this.nomeUsuarioInicioEstagio,
    required this.dataInicioEstagio,
    required this.horaInicioEstagio,
    required this.codUsuarioFinalizacaoEstagio,
    required this.nomeUsuarioFinalizacaoEstagio,
    required this.dataFinalizacaoEstagio,
    required this.horaFinalizacaoEstagio,
    required this.totalItemConferir,
    required this.totalItemConferido,
  });

  ExpeditionCheckCartConsultationModel copyWith({
    int? codEmpresa,
    int? codConferir,
    ExpeditionOrigem? origem,
    int? codOrigem,
    ExpeditionCartRouterSituation? situacao,
    int? codCarrinhoPercurso,
    String? itemCarrinhoPercurso,
    int? codPrioridade,
    String? nomePrioridade,
    int? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    ExpeditionCartSituation? situacaoCarrinhoConferencia,
    DateTime? dataInicioPercurso,
    String? horaInicioPercurso,
    int? codPercursoEstagio,
    String? nomePercursoEstagio,
    int? codUsuarioInicioEstagio,
    String? nomeUsuarioInicioEstagio,
    DateTime? dataInicioEstagio,
    String? horaInicioEstagio,
    int? codUsuarioFinalizacaoEstagio,
    String? nomeUsuarioFinalizacaoEstagio,
    DateTime? dataFinalizacaoEstagio,
    String? horaFinalizacaoEstagio,
    double? totalItemConferir,
    double? totalItemConferido,
  }) {
    try {
      return ExpeditionCheckCartConsultationModel(
        codEmpresa: codEmpresa ?? this.codEmpresa,
        codConferir: codConferir ?? this.codConferir,
        origem: origem ?? this.origem,
        codOrigem: codOrigem ?? this.codOrigem,
        situacao: situacao ?? this.situacao,
        codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
        itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
        codPrioridade: codPrioridade ?? this.codPrioridade,
        nomePrioridade: nomePrioridade ?? this.nomePrioridade,
        codCarrinho: codCarrinho ?? this.codCarrinho,
        nomeCarrinho: nomeCarrinho ?? this.nomeCarrinho,
        codigoBarrasCarrinho: codigoBarrasCarrinho ?? this.codigoBarrasCarrinho,
        situacaoCarrinhoConferencia: situacaoCarrinhoConferencia ?? this.situacaoCarrinhoConferencia,
        dataInicioPercurso: dataInicioPercurso ?? this.dataInicioPercurso,
        horaInicioPercurso: horaInicioPercurso ?? this.horaInicioPercurso,
        codPercursoEstagio: codPercursoEstagio ?? this.codPercursoEstagio,
        nomePercursoEstagio: nomePercursoEstagio ?? this.nomePercursoEstagio,
        codUsuarioInicioEstagio: codUsuarioInicioEstagio ?? this.codUsuarioInicioEstagio,
        nomeUsuarioInicioEstagio: nomeUsuarioInicioEstagio ?? this.nomeUsuarioInicioEstagio,
        dataInicioEstagio: dataInicioEstagio ?? this.dataInicioEstagio,
        horaInicioEstagio: horaInicioEstagio ?? this.horaInicioEstagio,
        codUsuarioFinalizacaoEstagio: codUsuarioFinalizacaoEstagio ?? this.codUsuarioFinalizacaoEstagio,
        nomeUsuarioFinalizacaoEstagio: nomeUsuarioFinalizacaoEstagio ?? this.nomeUsuarioFinalizacaoEstagio,
        dataFinalizacaoEstagio: dataFinalizacaoEstagio ?? this.dataFinalizacaoEstagio,
        horaFinalizacaoEstagio: horaFinalizacaoEstagio ?? this.horaFinalizacaoEstagio,
        totalItemConferir: totalItemConferir ?? this.totalItemConferir,
        totalItemConferido: totalItemConferido ?? this.totalItemConferido,
      );
    } catch (_) {
      rethrow;
    }
  }

  factory ExpeditionCheckCartConsultationModel.fromJson(Map<String, dynamic> json) {
    return ExpeditionCheckCartConsultationModel(
      codEmpresa: json['CodEmpresa'],
      codConferir: json['CodConferir'],
      origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
      codOrigem: json['CodOrigem'],
      situacao: ExpeditionCartRouterSituation.fromCode(json['Situacao']) ?? ExpeditionCartRouterSituation.vazio,
      codCarrinhoPercurso: json['CodCarrinhoPercurso'],
      itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
      codPrioridade: json['CodPrioridade'],
      nomePrioridade: json['NomePrioridade'],
      codCarrinho: json['CodCarrinho'],
      nomeCarrinho: json['NomeCarrinho'],
      codigoBarrasCarrinho: json['CodigoBarrasCarrinho'],
      situacaoCarrinhoConferencia:
          ExpeditionCartSituation.fromCode(json['SituacaoCarrinhoConferencia']) ?? ExpeditionCartSituation.vazio,
      dataInicioPercurso: DateHelper.tryStringToDate(json['DataInicioPercurso']),
      horaInicioPercurso: json['HoraInicioPercurso'],
      codPercursoEstagio: json['CodPercursoEstagio'],
      nomePercursoEstagio: json['NomePercursoEstagio'],
      codUsuarioInicioEstagio: json['CodUsuarioInicioEstagio'],
      nomeUsuarioInicioEstagio: json['NomeUsuarioInicioEstagio'],
      dataInicioEstagio: DateHelper.tryStringToDate(json['DataInicioEstagio']),
      horaInicioEstagio: json['HoraInicioEstagio'],
      codUsuarioFinalizacaoEstagio: json['CodUsuarioFinalizacaoEstagio'],
      nomeUsuarioFinalizacaoEstagio: json['NomeUsuarioFinalizacaoEstagio'],
      dataFinalizacaoEstagio: DateHelper.tryStringToDate(json['DataFinalizacaoEstagio']),
      horaFinalizacaoEstagio: json['HoraFinalizacaoEstagio'],
      totalItemConferir: AppHelper.stringToDouble(json['TotalItemConferir']),
      totalItemConferido: AppHelper.stringToDouble(json['TotalItemConferido']),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCheckCartConsultationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCheckCartConsultationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodConferir': codConferir,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'Situacao': situacao.code,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'CodPrioridade': codPrioridade,
      'NomePrioridade': nomePrioridade,
      'CodCarrinho': codCarrinho,
      'NomeCarrinho': nomeCarrinho,
      'CodigoBarrasCarrinho': codigoBarrasCarrinho,
      'SituacaoCarrinhoConferencia': situacaoCarrinhoConferencia.code,
      'DataInicioPercurso': dataInicioPercurso.toIso8601String(),
      'HoraInicioPercurso': horaInicioPercurso,
      'CodPercursoEstagio': codPercursoEstagio,
      'NomePercursoEstagio': nomePercursoEstagio,
      'CodUsuarioInicioEstagio': codUsuarioInicioEstagio,
      'NomeUsuarioInicioEstagio': nomeUsuarioInicioEstagio,
      'DataInicioEstagio': dataInicioEstagio.toIso8601String(),
      'HoraInicioEstagio': horaInicioEstagio,
      'CodUsuarioFinalizacaoEstagio': codUsuarioFinalizacaoEstagio,
      'NomeUsuarioFinalizacaoEstagio': nomeUsuarioFinalizacaoEstagio,
      'DataFinalizacaoEstagio': dataFinalizacaoEstagio.toIso8601String(),
      'HoraFinalizacaoEstagio': horaFinalizacaoEstagio,
      'TotalItemConferir': totalItemConferir,
      'TotalItemConferido': totalItemConferido,
    };
  }

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => situacao.color;

  /// Retorna o código da situação do carrinho de conferência
  String get situacaoCarrinhoConferenciaCode => situacaoCarrinhoConferencia.code;

  /// Retorna a descrição da situação do carrinho de conferência
  String get situacaoCarrinhoConferenciaDescription => situacaoCarrinhoConferencia.description;

  /// Retorna a cor da situação do carrinho de conferência
  Color get situacaoCarrinhoConferenciaColor => situacaoCarrinhoConferencia.color;

  bool isSituacao(String situacaoToCheck) => situacao.code.toLowerCase() == situacaoToCheck.toLowerCase();

  bool isSituacaoCarrinhoConferencia(String situacaoToCheck) =>
      situacaoCarrinhoConferencia.code.toLowerCase() == situacaoToCheck.toLowerCase();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCheckCartConsultationModel &&
        other.codEmpresa == codEmpresa &&
        other.codConferir == codConferir;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codConferir.hashCode;

  @override
  String toString() {
    return '''ExpeditionCheckCartConsultationModel(
        codEmpresa: $codEmpresa, 
        codConferir: $codConferir, 
        origem: ${origem.description} (${origem.code}),
        codOrigem: $codOrigem, 
        situacao: ${situacao.description}, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        codPrioridade: $codPrioridade, 
        nomePrioridade: $nomePrioridade, 
        codCarrinho: $codCarrinho, 
        nomeCarrinho: $nomeCarrinho, 
        codigoBarrasCarrinho: $codigoBarrasCarrinho, 
        situacaoCarrinhoConferencia: ${situacaoCarrinhoConferencia.description},
        dataInicioPercurso: $dataInicioPercurso, 
        horaInicioPercurso: $horaInicioPercurso, 
        codPercursoEstagio: $codPercursoEstagio, 
        nomePercursoEstagio: $nomePercursoEstagio, 
        codUsuarioInicioEstagio: $codUsuarioInicioEstagio, 
        nomeUsuarioInicioEstagio: $nomeUsuarioInicioEstagio, 
        dataInicioEstagio: $dataInicioEstagio, 
        horaInicioEstagio: $horaInicioEstagio, 
        codUsuarioFinalizacaoEstagio: $codUsuarioFinalizacaoEstagio, 
        nomeUsuarioFinalizacaoEstagio: $nomeUsuarioFinalizacaoEstagio, 
        dataFinalizacaoEstagio: $dataFinalizacaoEstagio, 
        horaFinalizacaoEstagio: $horaFinalizacaoEstagio, 
        totalItemConferir: $totalItemConferir, 
        totalItemConferido: $totalItemConferido
)''';
  }
}
