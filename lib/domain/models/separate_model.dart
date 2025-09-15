import 'package:flutter/material.dart';
import 'package:exp/core/utils/date_helper.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';

class SeparateModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codTipoOperacaoExpedicao;
  final String tipoEntidade;
  final int codEntidade;
  final String nomeEntidade;
  final ExpeditionSituation situacao;
  final DateTime data;
  final String hora;
  final int codPrioridade;
  final String? historico;
  final String? observacao;
  final int? codMotivoCancelamento;
  final DateTime? dataCancelamento;
  final String? horaCancelamento;
  final int? codUsuarioCancelamento;
  final String? nomeUsuarioCancelamento;
  final String? observacaoCancelamento;

  const SeparateModel({
    required this.codEmpresa,
    required this.codSepararEstoque,
    required this.origem,
    required this.codOrigem,
    required this.codTipoOperacaoExpedicao,
    required this.tipoEntidade,
    required this.codEntidade,
    required this.nomeEntidade,
    required this.situacao,
    required this.data,
    required this.hora,
    required this.codPrioridade,
    this.historico,
    this.observacao,
    this.codMotivoCancelamento,
    this.dataCancelamento,
    this.horaCancelamento,
    this.codUsuarioCancelamento,
    this.nomeUsuarioCancelamento,
    this.observacaoCancelamento,
  });

  SeparateModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    ExpeditionOrigem? origem,
    int? codOrigem,
    int? codTipoOperacaoExpedicao,
    String? tipoEntidade,
    int? codEntidade,
    String? nomeEntidade,
    ExpeditionSituation? situacao,
    DateTime? data,
    String? hora,
    int? codPrioridade,
    String? historico,
    String? observacao,
    int? codMotivoCancelamento,
    DateTime? dataCancelamento,
    String? horaCancelamento,
    int? codUsuarioCancelamento,
    String? nomeUsuarioCancelamento,
    String? observacaoCancelamento,
  }) {
    return SeparateModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codSepararEstoque: codSepararEstoque ?? this.codSepararEstoque,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      codTipoOperacaoExpedicao:
          codTipoOperacaoExpedicao ?? this.codTipoOperacaoExpedicao,
      tipoEntidade: tipoEntidade ?? this.tipoEntidade,
      codEntidade: codEntidade ?? this.codEntidade,
      nomeEntidade: nomeEntidade ?? this.nomeEntidade,
      situacao: situacao ?? this.situacao,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      codPrioridade: codPrioridade ?? this.codPrioridade,
      historico: historico ?? this.historico,
      observacao: observacao ?? this.observacao,
      codMotivoCancelamento:
          codMotivoCancelamento ?? this.codMotivoCancelamento,
      dataCancelamento: dataCancelamento ?? this.dataCancelamento,
      horaCancelamento: horaCancelamento ?? this.horaCancelamento,
      codUsuarioCancelamento:
          codUsuarioCancelamento ?? this.codUsuarioCancelamento,
      nomeUsuarioCancelamento:
          nomeUsuarioCancelamento ?? this.nomeUsuarioCancelamento,
      observacaoCancelamento:
          observacaoCancelamento ?? this.observacaoCancelamento,
    );
  }

  factory SeparateModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateModel(
        codEmpresa: json['CodEmpresa'] as int,
        codSepararEstoque: json['CodSepararEstoque'] as int,
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String),
        codOrigem: json['CodOrigem'] as int,
        codTipoOperacaoExpedicao: json['CodTipoOperacaoExpedicao'] as int,
        tipoEntidade: json['TipoEntidade'] as String,
        codEntidade: json['CodEntidade'] as int,
        nomeEntidade: json['NomeEntidade'] as String,
        situacao:
            ExpeditionSituation.fromCode(json['Situacao'] as String) ??
            ExpeditionSituation.aguardando,
        data: DateHelper.tryStringToDate(json['Data']),
        hora: json['Hora'] as String? ?? '00:00:00',
        codPrioridade: json['CodPrioridade'] as int,
        historico: json['Historico'] as String?,
        observacao: json['Observacao'] as String?,
        codMotivoCancelamento: json['CodMotivoCancelamento'] as int?,
        dataCancelamento: DateHelper.tryStringToDateOrNull(
          json['DataCancelamento'],
        ),
        horaCancelamento: json['HoraCancelamento'] as String?,
        codUsuarioCancelamento: json['CodUsuarioCancelamento'] as int?,
        nomeUsuarioCancelamento: json['NomeUsuarioCancelamento'] as String?,
        observacaoCancelamento: json['ObservacaoCancelamento'] as String?,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'CodTipoOperacaoExpedicao': codTipoOperacaoExpedicao,
      'TipoEntidade': tipoEntidade,
      'CodEntidade': codEntidade,
      'NomeEntidade': nomeEntidade,
      'Situacao': situacao.code,
      'Data': data.toIso8601String(),
      'Hora': hora,
      'CodPrioridade': codPrioridade,
      'Historico': historico,
      'Observacao': observacao,
      'CodMotivoCancelamento': codMotivoCancelamento,
      'DataCancelamento': dataCancelamento?.toIso8601String(),
      'HoraCancelamento': horaCancelamento,
      'CodUsuarioCancelamento': codUsuarioCancelamento,
      'NomeUsuarioCancelamento': nomeUsuarioCancelamento,
      'ObservacaoCancelamento': observacaoCancelamento,
    };
  }

  bool get isCancelled => codMotivoCancelamento != null;

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna a cor da situação
  Color get situacaoColor => situacao.color;

  bool isSituacao(String situacaoToCheck) =>
      situacao.code.toLowerCase() == situacaoToCheck.toLowerCase();

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
    return other is SeparateModel &&
        other.codEmpresa == codEmpresa &&
        other.codSepararEstoque == codSepararEstoque;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codSepararEstoque.hashCode;

  @override
  String toString() {
    return '''ShipmentSeparateModel(
        codEmpresa: $codEmpresa, 
        codSepararEstoque: $codSepararEstoque, 
        origem: ${origem.description} (${origem.code}),
        codOrigem: $codOrigem,
        codTipoOperacaoExpedicao: $codTipoOperacaoExpedicao, 
        tipoEntidade: $tipoEntidade, 
        codEntidade: $codEntidade, 
        nomeEntidade: $nomeEntidade, 
        situacao: ${situacao.description}, 
        data: $data, 
        hora: $hora, 
        codPrioridade: $codPrioridade, 
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
