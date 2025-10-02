import 'package:exp/domain/models/situation/situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionInternshipModel {
  final int codPercursoEstagio;
  final String descricao;
  final Situation ativo;
  final ExpeditionOrigem origem;
  final int sequencia;

  ExpeditionInternshipModel({
    required this.codPercursoEstagio,
    required this.descricao,
    required this.ativo,
    required this.origem,
    required this.sequencia,
  });

  ExpeditionInternshipModel copyWith({
    int? codPercursoEstagio,
    String? descricao,
    Situation? ativo,
    ExpeditionOrigem? origem,
    int? sequencia,
  }) {
    return ExpeditionInternshipModel(
      codPercursoEstagio: codPercursoEstagio ?? this.codPercursoEstagio,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      origem: origem ?? this.origem,
      sequencia: sequencia ?? this.sequencia,
    );
  }

  factory ExpeditionInternshipModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionInternshipModel(
        codPercursoEstagio: json['CodPercursoEstagio'],
        descricao: json['Descricao'],
        ativo: Situation.fromCodeWithFallback(json['Ativo']),
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        sequencia: json['Sequencia'],
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionInternshipModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionInternshipModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodPercursoEstagio': codPercursoEstagio,
      'Descricao': descricao,
      'Ativo': ativo.code,
      'Origem': origem.code,
      'Sequencia': sequencia,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionInternshipModel && other.codPercursoEstagio == codPercursoEstagio;
  }

  @override
  int get hashCode => codPercursoEstagio.hashCode;

  @override
  String toString() {
    return '''ExpeditionInternshipModel(
      codPercursoEstagio: $codPercursoEstagio, 
      descricao: $descricao, 
      ativo: ${ativo.description}, origem: 
      ${origem.description}, sequencia: 
      $sequencia
    )''';
  }
}
