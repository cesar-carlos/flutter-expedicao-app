import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';

class ExpeditionCartRouteInternshipGroupModel {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;
  final ExpeditionOrigem origem;
  final String itemCarrinhoPercurso;
  final ExpeditionCartSituation situacao;
  final int codCarrinhoAgrupador;
  final DateTime dataLancamento;
  final String horaLancamento;
  final int codUsuarioLancamento;
  final String nomeUsuarioLancamento;

  ExpeditionCartRouteInternshipGroupModel({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.item,
    required this.origem,
    required this.itemCarrinhoPercurso,
    required this.situacao,
    required this.codCarrinhoAgrupador,
    required this.dataLancamento,
    required this.horaLancamento,
    required this.codUsuarioLancamento,
    required this.nomeUsuarioLancamento,
  });

  ExpeditionCartRouteInternshipGroupModel copyWith({
    int? codEmpresa,
    int? codCarrinhoPercurso,
    String? item,
    ExpeditionOrigem? origem,
    String? itemCarrinhoPercurso,
    ExpeditionCartSituation? situacao,
    int? codCarrinhoAgrupador,
    DateTime? dataLancamento,
    String? horaLancamento,
    int? codUsuarioLancamento,
    String? nomeUsuarioLancamento,
  }) {
    return ExpeditionCartRouteInternshipGroupModel(
      codEmpresa: codEmpresa ?? this.codEmpresa,
      codCarrinhoPercurso: codCarrinhoPercurso ?? this.codCarrinhoPercurso,
      item: item ?? this.item,
      origem: origem ?? this.origem,
      itemCarrinhoPercurso: itemCarrinhoPercurso ?? this.itemCarrinhoPercurso,
      situacao: situacao ?? this.situacao,
      codCarrinhoAgrupador: codCarrinhoAgrupador ?? this.codCarrinhoAgrupador,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      horaLancamento: horaLancamento ?? this.horaLancamento,
      codUsuarioLancamento: codUsuarioLancamento ?? this.codUsuarioLancamento,
      nomeUsuarioLancamento: nomeUsuarioLancamento ?? this.nomeUsuarioLancamento,
    );
  }

  factory ExpeditionCartRouteInternshipGroupModel.fromJson(Map<String, dynamic> json) {
    try {
      return ExpeditionCartRouteInternshipGroupModel(
        codEmpresa: json['CodEmpresa'],
        codCarrinhoPercurso: json['CodCarrinhoPercurso'],
        item: json['Item'],
        origem: ExpeditionOrigem.fromCodeWithFallback(json['Origem']),
        itemCarrinhoPercurso: json['ItemCarrinhoPercurso'],
        situacao: ExpeditionCartSituation.fromCode(json['Situacao']) ?? ExpeditionCartSituation.vazio,
        codCarrinhoAgrupador: json['CodCarrinhoAgrupador'],
        dataLancamento: DateTime.parse(json['DataLancamento']),
        horaLancamento: json['HoraLancamento'],
        codUsuarioLancamento: json['CodUsuarioLancamento'],
        nomeUsuarioLancamento: json['NomeUsuarioLancamento'],
      );
    } catch (_) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'CodEmpresa': codEmpresa,
      'CodCarrinhoPercurso': codCarrinhoPercurso,
      'Item': item,
      'Origem': origem.code,
      'ItemCarrinhoPercurso': itemCarrinhoPercurso,
      'Situacao': situacao.code,
      'CodCarrinhoAgrupador': codCarrinhoAgrupador,
      'DataLancamento': dataLancamento.toIso8601String(),
      'HoraLancamento': horaLancamento,
      'CodUsuarioLancamento': codUsuarioLancamento,
      'NomeUsuarioLancamento': nomeUsuarioLancamento,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpeditionCartRouteInternshipGroupModel &&
        other.codEmpresa == codEmpresa &&
        other.codCarrinhoPercurso == codCarrinhoPercurso &&
        other.item == item;
  }

  @override
  int get hashCode => codEmpresa.hashCode ^ codCarrinhoPercurso.hashCode ^ item.hashCode;

  @override
  String toString() {
    return '''
      ExpeditionCartRouteInternshipGroupModel(
        codEmpresa: $codEmpresa, 
        codCarrinhoPercurso: $codCarrinhoPercurso, 
        item: $item, 
        origem: ${origem.description} (${origem.code}),
        itemCarrinhoPercurso: $itemCarrinhoPercurso, 
        situacao: ${situacao.description} (${situacao.code}), 
        codCarrinhoAgrupador: $codCarrinhoAgrupador, 
        dataLancamento: $dataLancamento, 
        horaLancamento: $horaLancamento, 
        codUsuarioLancamento: $codUsuarioLancamento, 
        nomeUsuarioLancamento: $nomeUsuarioLancamento)
    )''';
  }
}
