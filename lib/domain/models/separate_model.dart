import 'package:exp/core/utils/date_helper.dart';

/// Modelo para separação de expedição
class SeparateModel {
  final int codEmpresa;
  final int codSepararEstoque;
  final int codTipoOperacaoExpedicao;
  final String tipoEntidade;
  final int codEntidade;
  final String nomeEntidade;
  final String situacao;
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

  /// Cria uma cópia do modelo com valores alterados
  SeparateModel copyWith({
    int? codEmpresa,
    int? codSepararEstoque,
    int? codTipoOperacaoExpedicao,
    String? tipoEntidade,
    int? codEntidade,
    String? nomeEntidade,
    String? situacao,
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

  /// Cria um modelo a partir de JSON
  factory SeparateModel.fromJson(Map<String, dynamic> json) {
    try {
      return SeparateModel(
        codEmpresa: json['CodEmpresa'] as int,
        codSepararEstoque: json['CodSepararEstoque'] as int,
        codTipoOperacaoExpedicao: json['CodTipoOperacaoExpedicao'] as int,
        tipoEntidade: json['TipoEntidade'] as String,
        codEntidade: json['CodEntidade'] as int,
        nomeEntidade: json['NomeEntidade'] as String,
        situacao: json['Situacao'] as String,
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

  /// Converte o modelo para JSON
  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodSepararEstoque': codSepararEstoque,
      'CodTipoOperacaoExpedicao': codTipoOperacaoExpedicao,
      'TipoEntidade': tipoEntidade,
      'CodEntidade': codEntidade,
      'NomeEntidade': nomeEntidade,
      'Situacao': situacao,
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

  /// Verifica se o item foi cancelado
  bool get isCancelled => codMotivoCancelamento != null;

  /// Verifica se está em uma situação específica
  bool isSituacao(String situacaoToCheck) =>
      situacao.toLowerCase() == situacaoToCheck.toLowerCase();

  /// Obtém informações de cancelamento (se houver)
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
  codTipoOperacaoExpedicao: $codTipoOperacaoExpedicao, 
  tipoEntidade: $tipoEntidade, 
  codEntidade: $codEntidade, 
  nomeEntidade: $nomeEntidade, 
  situacao: $situacao, 
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
