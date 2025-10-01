import 'package:flutter/material.dart';

enum ExpeditionCartSituation {
  liberado('LIBERADO', 'Liberado', Colors.blue),
  emSeparacao('EM SEPARACAO', 'Em Separação', Colors.orange),
  separado('SEPARADO', 'Separado', Colors.green),
  emConferencia('EM CONFERENCIA', 'Em Conferência', Colors.purple),
  conferindo('CONFERIDO', 'Conferido', Colors.lightGreen),
  emEntrega('EM ENTREGA', 'Em Entrega', Colors.red),
  emPausa('EM PAUSA', 'Em Pausa', Colors.yellow),
  vazio('', '', Colors.grey);

  const ExpeditionCartSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;
  static ExpeditionCartSituation? fromCode(String code) {
    try {
      return ExpeditionCartSituation.values.firstWhere((situation) => situation.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return ExpeditionCartSituation.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return ExpeditionCartSituation.values.map((e) => e.description).toList();
  }

  static bool isValidSituation(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static Map<String, String> getSituacaoMap() {
    return Map.fromEntries(
      ExpeditionCartSituation.values.map((situation) => MapEntry(situation.code, situation.description)),
    );
  }
}

extension ExpeditionCartSituationExtension on String {
  ExpeditionCartSituation? get asCartSituation => ExpeditionCartSituation.fromCode(this);
  String get cartSituationDescription => ExpeditionCartSituation.getDescription(this);
}

class ExpeditionCartSituationModel {
  ExpeditionCartSituationModel._();

  static String getDescription(String code) => ExpeditionCartSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionCartSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionCartSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionCartSituation.getAllDescriptions();

  static Map<String, String> get situacao => ExpeditionCartSituation.getSituacaoMap();
}
