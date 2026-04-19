import 'package:data7_expedicao/core/utils/json_parse_helpers.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

class CartsFiltersModel {
  final String? codCarrinho;
  final String? nomeCarrinho;
  final String? codigoBarrasCarrinho;
  final List<String>? situacoes;
  final String? nomeUsuarioInicio;
  final DateTime? dataInicioInicial;
  final DateTime? dataInicioFinal;
  final Situation carrinhoAgrupador;

  const CartsFiltersModel({
    this.codCarrinho,
    this.nomeCarrinho,
    this.codigoBarrasCarrinho,
    this.situacoes,
    this.nomeUsuarioInicio,
    this.dataInicioInicial,
    this.dataInicioFinal,
    this.carrinhoAgrupador = Situation.inativo,
  });

  factory CartsFiltersModel.fromJson(Map<String, dynamic> json) {
    // Bug critico anterior: 2x `DateTime.parse(...)` sem try/catch
    // (dataInicioInicial e dataInicioFinal). Agora usa parseDateTime
    // nullable que retorna null em caso de falha.
    final situacoesRaw = json['situacoes'];
    final agrupRaw = json['carrinhoAgrupador'];
    return CartsFiltersModel(
      codCarrinho: JsonParse.parseStringOrNull(json['codCarrinho']),
      nomeCarrinho: JsonParse.parseStringOrNull(json['nomeCarrinho']),
      codigoBarrasCarrinho: JsonParse.parseStringOrNull(json['codigoBarrasCarrinho']),
      situacoes: situacoesRaw is List ? situacoesRaw.map((e) => e.toString()).toList(growable: false) : null,
      nomeUsuarioInicio: JsonParse.parseStringOrNull(json['nomeUsuarioInicio']),
      dataInicioInicial: JsonParse.parseDateTime(json['dataInicioInicial']),
      dataInicioFinal: JsonParse.parseDateTime(json['dataInicioFinal']),
      carrinhoAgrupador: agrupRaw != null ? Situation.fromCodeWithFallback(agrupRaw.toString()) : Situation.inativo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCarrinho': codCarrinho,
      'nomeCarrinho': nomeCarrinho,
      'codigoBarrasCarrinho': codigoBarrasCarrinho,
      'situacoes': situacoes,
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
      (situacoes == null || situacoes!.isEmpty) &&
      nomeUsuarioInicio == null &&
      dataInicioInicial == null &&
      dataInicioFinal == null &&
      carrinhoAgrupador == Situation.inativo;

  bool get isNotEmpty => !isEmpty;

  CartsFiltersModel copyWith({
    String? codCarrinho,
    String? nomeCarrinho,
    String? codigoBarrasCarrinho,
    List<String>? situacoes,
    String? nomeUsuarioInicio,
    DateTime? dataInicioInicial,
    DateTime? dataInicioFinal,
    Situation? carrinhoAgrupador,
  }) {
    return CartsFiltersModel(
      codCarrinho: codCarrinho ?? this.codCarrinho,
      nomeCarrinho: nomeCarrinho ?? this.nomeCarrinho,
      codigoBarrasCarrinho: codigoBarrasCarrinho ?? this.codigoBarrasCarrinho,
      situacoes: situacoes ?? this.situacoes,
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
        'situacoes: $situacoes, '
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
        _listEquals(other.situacoes, situacoes) &&
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
      situacoes,
      nomeUsuarioInicio,
      dataInicioInicial,
      dataInicioFinal,
      carrinhoAgrupador,
    );
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
