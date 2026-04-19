import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ExpeditionCancellationModel {
  final int codEmpresa;
  final int codCancelamento;
  final ExpeditionOrigem origem;
  final int codOrigem;
  final String itemOrigem;
  int? codMotivoCancelamento;
  final DateTime dataCancelamento;
  final String horaCancelamento;
  final int codUsuarioCancelamento;
  final String nomeUsuarioCancelamento;
  final String? observacaoCancelamento;

  ExpeditionCancellationModel({
    required this.codEmpresa,
    required this.codCancelamento,
    required this.origem,
    required this.codOrigem,
    required this.itemOrigem,
    this.codMotivoCancelamento,
    required this.dataCancelamento,
    required this.horaCancelamento,
    required this.codUsuarioCancelamento,
    required this.nomeUsuarioCancelamento,
    this.observacaoCancelamento,
  });

  ExpeditionCancellationModel copyWith({
    int? codEmpresa,
    int? codCancelamento,
    ExpeditionOrigem? origem,
    int? codOrigem,
    String? itemOrigem,
    int? codMotivoCancelamento,
    DateTime? dataCancelamento,
    String? horaCancelamento,
    int? codUsuarioCancelamento,
    String? nomeUsuarioCancelamento,
    String? observacaoCancelamento,
  }) {
    return ExpeditionCancellationModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCancelamento: codCancelamento ?? this.codCancelamento,
      origem: origem ?? this.origem,
      codOrigem: codOrigem ?? this.codOrigem,
      itemOrigem: itemOrigem ?? this.itemOrigem,
      codMotivoCancelamento: codMotivoCancelamento ?? this.codMotivoCancelamento,
      dataCancelamento: dataCancelamento ?? this.dataCancelamento,
      horaCancelamento: horaCancelamento ?? this.horaCancelamento,
      codUsuarioCancelamento: codUsuarioCancelamento ?? this.codUsuarioCancelamento,
      nomeUsuarioCancelamento: nomeUsuarioCancelamento ?? this.nomeUsuarioCancelamento,
      observacaoCancelamento: observacaoCancelamento ?? this.observacaoCancelamento,
    );
  }

  factory ExpeditionCancellationModel.fromJson(Map<String, dynamic> json) {
    // Bug critico anterior: `DateTime.parse(json['DataCancelamento'])`
    // sem try/catch crashava com FormatException se viesse mal
    // formatado. Agora `parseDateTimeOr` com fallback epoch 0.
    return ExpeditionCancellationModel(
      codEmpresa: JsonParse.parseIntOr(json['CodEmpresa'], 0),
      codCancelamento: JsonParse.parseIntOr(json['CodCancelamento'], 0),
      origem: ExpeditionOrigem.fromCodeWithFallback(JsonParse.parseStringOr(json['Origem'], '')),
      codOrigem: JsonParse.parseIntOr(json['CodOrigem'], 0),
      itemOrigem: JsonParse.parseStringOr(json['ItemOrigem'], ''),
      codMotivoCancelamento: JsonParse.parseInt(json['CodMotivoCancelamento']),
      dataCancelamento: JsonParse.parseDateTimeOr(json['DataCancelamento'], DateTime.fromMillisecondsSinceEpoch(0)),
      horaCancelamento: JsonParse.parseStringOr(json['HoraCancelamento'], '00:00:00'),
      codUsuarioCancelamento: JsonParse.parseIntOr(json['CodUsuarioCancelamento'], 0),
      nomeUsuarioCancelamento: JsonParse.parseStringOr(json['NomeUsuarioCancelamento'], ''),
      observacaoCancelamento: JsonParse.parseStringOrNull(json['ObservacaoCancelamento']),
    );
  }

  static Result<ExpeditionCancellationModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCancellationModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCancelamento': codCancelamento,
      'Origem': origem.code,
      'CodOrigem': codOrigem,
      'ItemOrigem': itemOrigem,
      'CodMotivoCancelamento': codMotivoCancelamento,
      'DataCancelamento': dataCancelamento.toIso8601String(),
      'HoraCancelamento': horaCancelamento,
      'CodUsuarioCancelamento': codUsuarioCancelamento,
      'NomeUsuarioCancelamento': nomeUsuarioCancelamento,
      'ObservacaoCancelamento': observacaoCancelamento,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCancellationModel &&
        other.codEmpresa == codEmpresa &&
        other.codCancelamento == codCancelamento;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCancelamento.hashCode;

  String get origemCode => origem.code;

  String get origemDescription => origem.description;

  @override
  String toString() {
    return '''
      ExpeditionCancellationModel(
        codEmpresa: $codEmpresa, 
        codCancelamento: $codCancelamento, 
        origem: ${origem.description}, 
        codOrigem: $codOrigem, 
        itemOrigem: $itemOrigem, 
        codMotivoCancelamento: $codMotivoCancelamento, 
        dataCancelamento: $dataCancelamento, 
        horaCancelamento: $horaCancelamento, 
        codUsuarioCancelamento: $codUsuarioCancelamento, 
        nomeUsuarioCancelamento: $nomeUsuarioCancelamento, 
        observacaoCancelamento: $observacaoCancelamento
    )''';
  }
}
