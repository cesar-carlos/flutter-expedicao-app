import 'package:exp/domain/models/expedition_origem_model.dart';

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
    try {
      return ExpeditionCancellationModel(
        codEmpresa: json['CodEmpresa'],
        codCancelamento: json['CodCancelamento'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem'] as String? ?? ''),
        codOrigem: json['CodOrigem'],
        itemOrigem: json['ItemOrigem'],
        codMotivoCancelamento: json['CodMotivoCancelamento'],
        dataCancelamento: DateTime.parse(json['DataCancelamento']),
        horaCancelamento: json['HoraCancelamento'],
        codUsuarioCancelamento: json['CodUsuarioCancelamento'],
        nomeUsuarioCancelamento: json['NomeUsuarioCancelamento'],
        observacaoCancelamento: json['ObservacaoCancelamento'],
      );
    } catch (_) {
      rethrow;
    }
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

  /// Retorna o código da origem
  String get origemCode => origem.code;

  /// Retorna a descrição da origem
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
