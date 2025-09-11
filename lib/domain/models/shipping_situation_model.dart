import 'package:flutter/material.dart';

enum ExpeditionSituation {
  aguardando('AGUARDANDO', 'Aguardando', Colors.grey),
  emPausa('EM PAUSA', 'Em Pausa', Colors.yellow),
  emAndamento('EM ANDAMENTO', 'Em Andamento', Colors.blue),
  emSeparacao('EM SEPARACAO', 'Em Separação', Colors.orange),
  emConferencia('EM CONFERENCIA', 'Em Conferência', Colors.purple),
  cancelada('CANCELADA', 'Cancelada', Colors.red),
  devolvida('DEVOLVIDA', 'Devolvida', Colors.deepOrange),
  separando('SEPARANDO', 'Separando', Colors.orange),
  separado('SEPARADO', 'Separado', Colors.lightGreen),
  conferindo('CONFERINDO', 'Conferindo', Colors.purple),
  conferido('CONFERIDO', 'Conferido', Colors.lightGreen),
  entregue('ENTREGUE', 'Entregue', Colors.green),
  embalando('EMBALANDO', 'Embalando', Colors.teal),
  finalizada('FINALIZADA', 'Finalizada', Colors.green),
  naoLocalizada('NÃO LOCALIZADO', 'Não Localizada', Colors.red);

  const ExpeditionSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  static ExpeditionSituation? fromCode(String code) {
    try {
      return ExpeditionSituation.values.firstWhere(
        (situation) => situation.code == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return ExpeditionSituation.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return ExpeditionSituation.values.map((e) => e.description).toList();
  }

  static bool isValidSituation(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static Color getColor(String code) {
    return fromCode(code)?.color ?? Colors.grey;
  }
}

extension ExpeditionSituationExtension on String {
  ExpeditionSituation? get asSituation => ExpeditionSituation.fromCode(this);
  String get situationDescription => ExpeditionSituation.getDescription(this);
  Color get situationColor => ExpeditionSituation.getColor(this);
}

class ShippingSituationModel {
  ShippingSituationModel._();

  static String getDescription(String code) =>
      ExpeditionSituation.getDescription(code);

  static bool isValidSituation(String code) =>
      ExpeditionSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionSituation.getAllCodes();

  static List<String> getAllDescriptions() =>
      ExpeditionSituation.getAllDescriptions();

  static Color getColor(String code) => ExpeditionSituation.getColor(code);

  static List<ExpeditionSituation> getAllSituations() =>
      ExpeditionSituation.values;
}

@Deprecated('Use ShippingSituationModel instead of ExpedicaoSituacaoModel')
class ExpedicaoSituacaoModel {
  ExpedicaoSituacaoModel._();

  static String getDescricao(String codigo) =>
      ShippingSituationModel.getDescription(codigo);
  static bool isSituacaoValida(String codigo) =>
      ShippingSituationModel.isValidSituation(codigo);
  static List<String> getTodasSituacoes() =>
      ShippingSituationModel.getAllCodes();
  static List<String> getTodasDescricoes() =>
      ShippingSituationModel.getAllDescriptions();
}
