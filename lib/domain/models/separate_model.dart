import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/date_helper.dart';
import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class SeparateModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final int codTipoOperacaoExpedicao;
  final EntityType tipoEntidade;
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
    EntityType? tipoEntidade,
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
      codTipoOperacaoExpedicao: codTipoOperacaoExpedicao ?? this.codTipoOperacaoExpedicao,
      tipoEntidade: tipoEntidade ?? this.tipoEntidade,
      codEntidade: codEntidade ?? this.codEntidade,
      nomeEntidade: nomeEntidade ?? this.nomeEntidade,
      situacao: situacao ?? this.situacao,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      codPrioridade: codPrioridade ?? this.codPrioridade,
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

  factory SeparateModel.fromJson(Map<String, dynamic> json) {
    // Refatorado para usar JsonParse helpers (parsing defensivo
    // centralizado). Antes: casts diretos `as int`/`as String` que
    // crashavam com TypeError quando servidor retornava tipos
    // diferentes (string em vez de int, null em vez de string), e
    // try/catch+rethrow inutil ao redor.
    return SeparateModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codSepararEstoque: JsonParse.parseIntOr(json['CodSepararEstoque'], 0),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      codTipoOperacaoExpedicao: JsonParse.parseIntOr(json['CodTipoOperacaoExpedicao'], 0),
      tipoEntidade: EntityType.fromCode(JsonParse.parseStringOr(json['TipoEntidade'], '')) ?? EntityType.cliente,
      codEntidade: JsonParse.parseIntOr(json['CodEntidade'], 0),
      nomeEntidade: JsonParse.parseStringOr(json['NomeEntidade'], ''),
      situacao:
          ExpeditionSituation.fromCode(JsonParse.parseStringOr(json['Situacao'], '')) ?? ExpeditionSituation.aguardando,
      data: DateHelper.tryStringToDate(json['Data']),
      hora: JsonParse.parseStringOr(json['Hora'], '00:00:00'),
      codPrioridade: JsonParse.parseIntOr(json['CodPrioridade'], 0),
      historico: JsonParse.parseStringOrNull(json['Historico']),
      observacao: JsonParse.parseStringOrNull(json['Observacao']),
      codMotivoCancelamento: JsonParse.parseInt(json['CodMotivoCancelamento']),
      dataCancelamento: DateHelper.tryStringToDateOrNull(json['DataCancelamento']),
      horaCancelamento: JsonParse.parseStringOrNull(json['HoraCancelamento']),
      codUsuarioCancelamento: JsonParse.parseInt(json['CodUsuarioCancelamento']),
      nomeUsuarioCancelamento: JsonParse.parseStringOrNull(json['NomeUsuarioCancelamento']),
      observacaoCancelamento: JsonParse.parseStringOrNull(json['ObservacaoCancelamento']),
    );
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<SeparateModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => SeparateModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'CodTipoOperacaoExpedicao': codTipoOperacaoExpedicao,
      'TipoEntidade': tipoEntidade.code,
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
    return other is SeparateModel && other.codEmpresa == codEmpresa && other.codSepararEstoque == codSepararEstoque;
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
