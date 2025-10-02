import 'package:exp/domain/models/situation/situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionSectorStockModel {
  final int codSetorEstoque;
  final String descricao;
  final Situation ativo;

  ExpeditionSectorStockModel({required this.codSetorEstoque, required this.descricao, required this.ativo});

  ExpeditionSectorStockModel copyWith({int? codSetorEstoque, String? descricao, Situation? ativo}) {
    return ExpeditionSectorStockModel(
      codSetorEstoque: codSetorEstoque ?? this.codSetorEstoque,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
    );
  }

  factory ExpeditionSectorStockModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionSectorStockModel(
        codSetorEstoque: json['CodSetorEstoque'],
        descricao: json['Descricao'],
        ativo: Situation.fromCodeWithFallback(json['Ativo'] as String? ?? ''),
      );
    } catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'CodSetorEstoque': codSetorEstoque, 'Descricao': descricao, 'Ativo': ativo.code};
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionSectorStockModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionSectorStockModel.fromJson(json));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionSectorStockModel && other.codSetorEstoque == codSetorEstoque;
  }

  @override
  int get hashCode => codSetorEstoque.hashCode;

  String get ativoCode => ativo.code;

  String get ativoDescription => ativo.description;

  @override
  String toString() {
    return '''
      ExpeditionSectorStockModel(
        codSetorEstoque: $codSetorEstoque, 
        descricao: $descricao, 
        ativo: ${ativo.description}, 
    )''';
  }
}
