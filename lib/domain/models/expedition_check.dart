import 'package:flutter/material.dart';

import 'package:exp/core/utils/date_helper.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCheckModel {
  final int codEmpresa;
  final int codConferir;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codPrioridade;
  final ExpeditionCartRouterSituation situacao;
  final DateTime data;
  final String hora;
  final String? historico;
  final String? observacao;
  final int? codMotivoCancelamento;
  final DateTime? dataCancelamento;
  final String? horaCancelamento;
  final int? codUsuarioCancelamento;
  final String? nomeUsuarioCancelamento;
  final String? observacaoCancelamento;

  ExpeditionCheckModel({
    required this.codEmpresa,
    required this.codConferir,
    required this.origem,
    required this.codOrigem,
    required this.codPrioridade,
    required this.situacao,
    required this.data,
    required this.hora,
    this.historico,
    this.observacao,
    this.codMotivoCancelamento,
    this.dataCancelamento,
    this.horaCancelamento,
    this.codUsuarioCancelamento,
    this.nomeUsuarioCancelamento,
    this.observacaoCancelamento,
  });

  ExpeditionCheckModel copyWith({
    int? codEmpresa,
    int? codConferir,
    ExpeditionOrigem? origem,
    int? codOrigem,
    int? codPrioridade,
    ExpeditionCartRouterSituation? situacao,
    DateTime? data,
    String? hora,
    String? historico,
    String? observacao,
    int? codMotivoCancelamento,
    DateTime? dataCancelamento,
    String? horaCancelamento,
    int? codUsuarioCancelamento,
    String? nomeUsuarioCancelamento,
    String? observacaoCancelamento,
  }) {
    return ExpeditionCheckModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codConferir: codConferir ?? this.codConferir,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      codPrioridade: codPrioridade ?? this.codPrioridade,
      situacao: situacao ?? this.situacao,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      historico: historico ?? this.historico,
      observacao: observacao ?? this.observacao,
      codMotivoCancelamento: codMotivoCancelamento ?? this.codMotivoCancelamento,
      dataCancelamento: dataCancelamento ?? this.dataCancelamento,
      horaCancelamento: horaCancelamento ?? this.horaCancelamento,
      codUsuarioCancelamento: codUsuarioCancelamento ?? this.codUsuarioCancelamento,
      nomeUsuarioCancelamento: nomeUsuarioCancelamento ?? this.nomeUsuarioCancelamento,
      observacaoCancelamento: observacaoCancelamento ?? this.observacaoCancelamento,
    );
  }

  factory ExpeditionCheckModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCheckModel(
        codEmpresa: json['CodEmpresa'],
        codConferir: json['CodConferir'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        codOrigem: json['CodOrigem'],
        codPrioridade: json['CodPrioridade'],
        situacao: ExpeditionCartRouterSituation.fromCode(json['Situacao']) ?? ExpeditionCartRouterSituation.vazio,
        data: DateHelper.tryStringToDate(json['Data']),
        hora: json['Hora'],
        historico: json['Historico'],
        observacao: json['Observacao'],
        codMotivoCancelamento: json['CodMotivoCancelamento'],
        dataCancelamento: DateHelper.tryStringToDateOrNull(json['DataCancelamento']),
        horaCancelamento: json['HoraCancelamento'],
        codUsuarioCancelamento: json['CodUsuarioCancelamento'],
        nomeUsuarioCancelamento: json['NomeUsuarioCancelamento'],
        observacaoCancelamento: json['ObservacaoCancelamento'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCheckModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCheckModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      "CodEmpresa": codEmpresa,
      "CodConferir": codConferir,
      "Origem": origem.code,
      "CodOrigem": codOrigem,
      "CodPrioridade": codPrioridade,
      "Situacao": situacao.code,
      "Data": data.toIso8601String(),
      "Hora": hora,
      if (historico != null) "Historico": historico,
      if (observacao != null) "Observacao": observacao,
      "CodMotivoCancelamento": codMotivoCancelamento,
      "DataCancelamento": dataCancelamento?.toIso8601String(),
      "HoraCancelamento": horaCancelamento,
      "CodUsuarioCancelamento": codUsuarioCancelamento,
      "NomeUsuarioCancelamento": nomeUsuarioCancelamento,
      "ObservacaoCancelamento": observacaoCancelamento,
    };
  }

  bool get isCancelled => codMotivoCancelamento != null;

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => situacao.color;

  bool isSituacao(String situacaoToCheck) => situacao.code.toLowerCase() == situacaoToCheck.toLowerCase();

  String? get cancelInfo {
    if (!isCancelled) return null;

    final buffer = StringBuffer();
    if (nomeUsuarioCancelamento != null) {
      buffer.write('Cancelado por: $nomeUsuarioCancelamento');
    }
    if (dataCancelamento != null) {
      if (buffer.isNotEmpty) buffer.write(' - ');
      buffer.write('Data: ${DateHelper.dateToString(dataCancelamento!)}');
    }
    if (horaCancelamento != null) {
      buffer.write(' às $horaCancelamento');
    }
    if (observacaoCancelamento != null) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write('Motivo: $observacaoCancelamento');
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCheckModel && other.codEmpresa == codEmpresa && other.codConferir == codConferir;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codConferir.hashCode;

  @override
  String toString() {
    return '''ExpeditionCheckModel(
        codEmpresa: $codEmpresa, 
        codConferir: $codConferir, 
        origem: ${origem.description} (${origem.code}),
        codOrigem: $codOrigem, 
        codPrioridade: $codPrioridade, 
        situacao: ${situacao.description}, 
        data: $data, 
        hora: $hora, 
        historico: $historico, 
        observacao: $observacao, 
        codMotivoCancelamento: $codMotivoCancelamento, 
        dataCancelamento: $dataCancelamento, 
        horaCancelamento: $horaCancelamento, 
        codUsuarioCancelamento: $codUsuarioCancelamento, 
        nomeUsuarioCancelamento: $nomeUsuarioCancelamento, 
        observacaoCancelamento: $observacaoCancelamento
)''';
  }
}
