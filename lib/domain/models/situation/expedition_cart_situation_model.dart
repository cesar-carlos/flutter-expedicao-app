import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';

enum ExpeditionCartSituation {
  liberado('LIBERADO', 'Liberado', AppColors.info),
  emSeparacao('EM SEPARACAO', 'Em Separação', AppColors.warning),
  separado('SEPARADO', 'Separado', AppColors.success),
  emConferencia('EM CONFERENCIA', 'Em Conferência', AppColors.purple),
  conferindo('CONFERIDO', 'Conferido', AppColors.lightGreen),
  emEntrega('EM ENTREGA', 'Em Entrega', AppColors.error),
  emPausa('EM PAUSA', 'Em Pausa', AppColors.yellow),
  vazio('', '', AppColors.grey);

  const ExpeditionCartSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;
  static ExpeditionCartSituation? fromCode(String code) {
    try {
      final normalized = (code.trim()).toUpperCase();
      return ExpeditionCartSituation.values.firstWhere((situation) => situation.code == normalized);
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
