import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

enum ExpeditionItemSituation {
  separado('SP', 'Separado', AppColors.lightGreen),
  cancelado('CA', 'Cancelado', AppColors.error),
  pendente('PE', 'Pendente', AppColors.grey),
  conferido('CO', 'Conferido', AppColors.lightGreen),
  embalado('EM', 'Embalado', AppColors.teal),
  entregue('EN', 'Entregue', AppColors.success),
  expedido('EX', 'Expedido', AppColors.success),
  pausado('PA', 'Pausado', AppColors.yellow),
  reiniciado('RE', 'Reiniciado', AppColors.info),
  finalizado('FN', 'Finalizado', AppColors.success),
  armazenar('AR', 'Armazenar', AppColors.brown),
  vazio('', 'Vazio', AppColors.grey);

  const ExpeditionItemSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  static ExpeditionItemSituation? fromCode(String code) {
    try {
      return ExpeditionItemSituation.values.firstWhere((situation) => situation.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return ExpeditionItemSituation.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return ExpeditionItemSituation.values.map((e) => e.description).toList();
  }

  static bool isValidSituation(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static Color getColor(String code) {
    return fromCode(code)?.color ?? AppColors.grey;
  }
}

extension ExpeditionItemSituationExtension on String {
  ExpeditionItemSituation? get asSituation => ExpeditionItemSituation.fromCode(this);
  String get situationDescription => ExpeditionItemSituation.getDescription(this);
  Color get situationColor => ExpeditionItemSituation.getColor(this);
}

class ExpeditionItemSituationModel {
  ExpeditionItemSituationModel._();

  static String getDescription(String code) => ExpeditionItemSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionItemSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionItemSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionItemSituation.getAllDescriptions();

  static Color getColor(String code) => ExpeditionItemSituation.getColor(code);

  static List<ExpeditionItemSituation> getAllSituations() => ExpeditionItemSituation.values;
}

@Deprecated('Use ShippingSituationModel instead of ExpedicaoSituacaoModel')
class ExpedicaoSituacaoModel {
  ExpedicaoSituacaoModel._();

  static String getDescricao(String codigo) => ExpeditionItemSituationModel.getDescription(codigo);
  static bool isSituacaoValida(String codigo) => ExpeditionItemSituationModel.isValidSituation(codigo);
  static List<String> getTodasSituacoes() => ExpeditionItemSituationModel.getAllCodes();
  static List<String> getTodasDescricoes() => ExpeditionItemSituationModel.getAllDescriptions();
}
