import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/core/results/index.dart';

class ExpeditionCartModel {
  final int codEmpresa;
  final int codCarrinho;
  final String descricao;
  final Situation ativo;
  final String codigoBarras;
  final ExpeditionCartSituation situacao;

  ExpeditionCartModel({
    required this.codEmpresa,
    required this.codCarrinho,
    required this.descricao,
    required this.ativo,
    required this.codigoBarras,
    required this.situacao,
  });

  ExpeditionCartModel copyWith({
    int? codEmpresa,
    int? codCarrinho,
    String? descricao,
    Situation? ativo,
    String? codigoBarras,
    ExpeditionCartSituation? situacao,
  }) {
    return ExpeditionCartModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinho: codCarrinho ?? this.codCarrinho,
      descricao: descricao ?? this.descricao,
      ativo: ativo ?? this.ativo,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      situacao: situacao ?? this.situacao,
    );
  }

  factory ExpeditionCartModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCartModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinho: json['CodCarrinho'],
        descricao: json['Descricao'],
        ativo: Situation.fromCodeWithFallback(json['Ativo'] as String? ?? ''),
        codigoBarras: json['CodigoBarras'],
        situacao: ExpeditionCartSituation.fromCode(json['Situacao'] as String? ?? '') ?? ExpeditionCartSituation.vazio,
      );
    } catch (_) {
      rethrow;
    }
  }

  /// Factory method para criação segura com validação de schema
  /// Retorna um Result que pode ser sucesso ou falha
  static Result<ExpeditionCartModel> fromJsonSafe(Map<String, dynamic> json) {
    return safeCallSync(() => ExpeditionCartModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinho': codCarrinho,
      'Descricao': descricao,
      'Ativo': ativo.code,
      'CodigoBarras': codigoBarras,
      'Situacao': situacao.code,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartModel && other.codEmpresa == codEmpresa && other.codCarrinho == codCarrinho;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinho.hashCode;

  /// Retorna o código da situação
  String get situacaoCode => situacao.code;

  /// Retorna a descrição da situação
  String get situacaoDescription => situacao.description;

  /// Retorna o código do status ativo
  String get ativoCode => ativo.code;

  /// Retorna a descrição do status ativo
  String get ativoDescription => ativo.description;

  @override
  String toString() {
    return '''
      ExpedicaoCarrinhoModel(
        codEmpresa: $codEmpresa, 
        codCarrinho: $codCarrinho, 
        descricao: $descricao, 
        ativo: ${ativo.description}, 
        codigoBarras: $codigoBarras, 
        situacao: ${situacao.description}
    )''';
  }
}
