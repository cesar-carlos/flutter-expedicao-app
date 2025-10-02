import 'package:flutter/material.dart';

enum ExpeditionCartRouterSituation {
  cancelada('CANCELADA', 'Cancelada', Colors.red),
  conferido('CONFERIDO', 'Conferido', Colors.lightGreen),
  emAndamento('EM ANDAMENTO', 'Em Andamento', Colors.blue),
  emConferencia('EM CONFERENCIA', 'Em Conferência', Colors.purple),
  emEntrega('EM ENTREGA', 'Em Entrega', Colors.teal),
  emSeparacao('EM SEPARACAO', 'Em Separação', Colors.orange),
  finalizada('FINALIZADA', 'Finalizada', Colors.green),
  separado('SEPARADO', 'Separado', Colors.lightGreen),
  vazio('', '', Colors.grey);

  const ExpeditionCartRouterSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  static ExpeditionCartRouterSituation? fromCode(String code) {
    try {
      return ExpeditionCartRouterSituation.values.firstWhere((situation) => situation.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return ExpeditionCartRouterSituation.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return ExpeditionCartRouterSituation.values.map((e) => e.description).toList();
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

  static Map<String, String> getSituacaoMap() {
    return Map.fromEntries(
      ExpeditionCartRouterSituation.values.map((situation) => MapEntry(situation.code, situation.description)),
    );
  }
}

extension ExpeditionCartRouterSituationExtension on String {
  ExpeditionCartRouterSituation? get asCartRouterSituation => ExpeditionCartRouterSituation.fromCode(this);
  String get cartRouterSituationDescription => ExpeditionCartRouterSituation.getDescription(this);
  Color get cartRouterSituationColor => ExpeditionCartRouterSituation.getColor(this);
}

class ExpeditionCartRouterSituationModel {
  ExpeditionCartRouterSituationModel._();

  static String getDescription(String code) => ExpeditionCartRouterSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionCartRouterSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionCartRouterSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionCartRouterSituation.getAllDescriptions();

  static Color getColor(String code) => ExpeditionCartRouterSituation.getColor(code);

  static Map<String, String> get situacao => ExpeditionCartRouterSituation.getSituacaoMap();

  static List<ExpeditionCartRouterSituation> getAllSituations() => ExpeditionCartRouterSituation.values;
}
