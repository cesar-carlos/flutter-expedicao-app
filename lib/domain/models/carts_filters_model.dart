import 'package:exp/domain/models/situation_model.dart';

class CartsFiltersModel {
  final String? codCarrinho;
  final String? nomeCarrinho;
  final String? codigoBarrasCarrinho;
  final String? situacao;
  final String? nomeUsuarioInicio;
  final DateTime? dataInicioInicial;
  final DateTime? dataInicioFinal;
  final Situation carrinhoAgrupador;

  const CartsFiltersModel({
    this.codCarrinho,
    this.nomeCarrinho,
    this.codigoBarrasCarrinho,
    this.situacao,
    this.nomeUsuarioInicio,
    this.dataInicioInicial,
    this.dataInicioFinal,
    this.carrinhoAgrupador = Situation.inativo,
  });

  factory CartsFiltersModel.fromJson(Map<String, dynamic> json) {
    return CartsFiltersModel(
      codCarrinho: json['codCarrinho'],
      nomeCarrinho: json['nomeCarrinho'],
      codigoBarrasCarrinho: json['codigoBarrasCarrinho'],
      situacao: json['situacao'],
      nomeUsuarioInicio: json['nomeUsuarioInicio'],
      dataInicioInicial: json['dataInicioInicial'] != null ? DateTime.parse(json['dataInicioInicial']) : null,
      dataInicioFinal: json['dataInicioFinal'] != null ? DateTime.parse(json['dataInicioFinal']) : null,
      carrinhoAgrupador: json['carrinhoAgrupador'] != null
          ? Situation.fromCodeWithFallback(json['carrinhoAgrupador'])
          : Situation.inativo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCarrinho': codCarrinho,
      'nomeCarrinho': nomeCarrinho,
      'codigoBarrasCarrinho': codigoBarrasCarrinho,
      'situacao': situacao,
      'nomeUsuarioInicio': nomeUsuarioInicio,
      'dataInicioInicial': dataInicioInicial?.toIso8601String(),
      'dataInicioFinal': dataInicioFinal?.toIso8601String(),
      'carrinhoAgrupador': carrinhoAgrupador.code,
    };
  }

  bool get isEmpty =>
      codCarrinho == null &&
      nomeCarrinho == null &&
      codigoBarrasCarrinho == null &&
      situacao == null &&
      nomeUsuarioInicio == null &&
      dataInicioInicial == null &&
      dataInicioFinal == null &&
      carrinhoAgrupador == Situation.inativo;

  bool get isNotEmpty => !isEmpty;

  CartsFiltersModel copyWith({
    String? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    String? situacao,
    String? nomeUsuarioInicio,
    DateTime? dataInicioInicial,
    DateTime? dataInicioFinal,
    Situation? carrinhoAgrupador,
  }) {
    return CartsFiltersModel(
      codCarrinho: codCarrinho ?? this.codCarrinho,
      nomeCarrinho: nomeCarrinho ?? this.nomeCarrinho,
      codigoBarrasCarrinho: codigoBarrasCarrinho ?? this.codigoBarrasCarrinho,
      situacao: situacao ?? this.situacao,
      nomeUsuarioInicio: nomeUsuarioInicio ?? this.nomeUsuarioInicio,
      dataInicioInicial: dataInicioInicial ?? this.dataInicioInicial,
      dataInicioFinal: dataInicioFinal ?? this.dataInicioFinal,
      carrinhoAgrupador: carrinhoAgrupador ?? this.carrinhoAgrupador,
    );
  }

  CartsFiltersModel clear() {
    return const CartsFiltersModel();
  }

  @override
  String toString() {
    return 'CartsFiltersModel('
        'codCarrinho: $codCarrinho, '
        'nomeCarrinho: $nomeCarrinho, '
        'codigoBarrasCarrinho: $codigoBarrasCarrinho, '
        'situacao: $situacao, '
        'nomeUsuarioInicio: $nomeUsuarioInicio, '
        'dataInicioInicial: $dataInicioInicial, '
        'dataInicioFinal: $dataInicioFinal, '
        'carrinhoAgrupador: ${carrinhoAgrupador.code} (${carrinhoAgrupador.description})'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartsFiltersModel &&
        other.codCarrinho == codCarrinho &&
        other.nomeCarrinho == nomeCarrinho &&
        other.codigoBarrasCarrinho == codigoBarrasCarrinho &&
        other.situacao == situacao &&
        other.nomeUsuarioInicio == nomeUsuarioInicio &&
        other.dataInicioInicial == dataInicioInicial &&
        other.dataInicioFinal == dataInicioFinal &&
        other.carrinhoAgrupador == carrinhoAgrupador;
  }

  @override
  int get hashCode {
    return Object.hash(
      codCarrinho,
      nomeCarrinho,
      codigoBarrasCarrinho,
      situacao,
      nomeUsuarioInicio,
      dataInicioInicial,
      dataInicioFinal,
      carrinhoAgrupador,
    );
  }
}
