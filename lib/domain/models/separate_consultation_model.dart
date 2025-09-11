/// Modelo para consulta de separação de expedição
class SeparateConsultationModel {
  final int? id;
  final String? codigo;
  final String? descricao;
  final String? status;
  final DateTime? dataInicialSeparacao;
  final DateTime? dataFinalSeparacao;
  final String? usuario;
  final String? observacoes;

  const SeparateConsultationModel({
    this.id,
    this.codigo,
    this.descricao,
    this.status,
    this.dataInicialSeparacao,
    this.dataFinalSeparacao,
    this.usuario,
    this.observacoes,
  });

  factory SeparateConsultationModel.fromJson(Map<String, dynamic> json) {
    return SeparateConsultationModel(
      id: json['Id'],
      codigo: json['Codigo'],
      descricao: json['Descricao'],
      status: json['Status'],
      dataInicialSeparacao: json['DataInicialSeparacao'] != null
          ? DateTime.tryParse(json['DataInicialSeparacao'])
          : null,
      dataFinalSeparacao: json['DataFinalSeparacao'] != null
          ? DateTime.tryParse(json['DataFinalSeparacao'])
          : null,
      usuario: json['Usuario'],
      observacoes: json['Observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Codigo': codigo,
      'Descricao': descricao,
      'Status': status,
      'DataInicialSeparacao': dataInicialSeparacao?.toIso8601String(),
      'DataFinalSeparacao': dataFinalSeparacao?.toIso8601String(),
      'Usuario': usuario,
      'Observacoes': observacoes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SeparateConsultationModel &&
        other.id == id &&
        other.codigo == codigo;
  }

  @override
  int get hashCode => id.hashCode ^ codigo.hashCode;

  @override
  String toString() {
    return 'ShipmentSeparateConsultationModel(id: $id, codigo: $codigo, status: $status)';
  }
}
