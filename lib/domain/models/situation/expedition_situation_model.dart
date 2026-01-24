import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';

enum ExpeditionSituation {
  aguardando('AGUARDANDO', 'Aguardando', AppColors.grey),
  emPausa('EM PAUSA', 'Em Pausa', AppColors.yellow),
  cancelada('CANCELADA', 'Cancelada', AppColors.error),
  separando('SEPARANDO', 'Separando', AppColors.warning),
  separado('SEPARADO', 'Separado', AppColors.lightGreen),
  conferindo('CONFERINDO', 'Conferindo', AppColors.purple),
  conferido('CONFERIDO', 'Conferido', AppColors.lightGreen),
  entregue('ENTREGUE', 'Entregue', AppColors.success),
  embalando('EMBALANDO', 'Embalando', AppColors.teal),
  embalado('EMBALADO', 'Embalado', AppColors.teal),
  agrupado('AGRUPADO', 'Agrupado', AppColors.error),
  finalizada('FINALIZADA', 'Finalizada', AppColors.success),
  naoLocalizada('NÃO LOCALIZADO', 'Não Localizada', AppColors.error);

  const ExpeditionSituation(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  static ExpeditionSituation? fromCode(String code) {
    try {
      return ExpeditionSituation.values.firstWhere((situation) => situation.code == code.toUpperCase());
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
    return fromCode(code)?.color ?? AppColors.grey;
  }
}

extension ExpeditionSituationExtension on String {
  ExpeditionSituation? get asSituation => ExpeditionSituation.fromCode(this);
  String get situationDescription => ExpeditionSituation.getDescription(this);
  Color get situationColor => ExpeditionSituation.getColor(this);
}

class ExpeditionSituationModel {
  ExpeditionSituationModel._();

  static String getDescription(String code) => ExpeditionSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionSituation.getAllDescriptions();

  static Color getColor(String code) => ExpeditionSituation.getColor(code);

  static List<ExpeditionSituation> getAllSituations() => ExpeditionSituation.values;
}

@Deprecated('Use ShippingSituationModel instead of ExpedicaoSituacaoModel')
class ExpedicaoSituacaoModel {
  ExpedicaoSituacaoModel._();

  static String getDescricao(String codigo) => ExpeditionSituationModel.getDescription(codigo);
  static bool isSituacaoValida(String codigo) => ExpeditionSituationModel.isValidSituation(codigo);
  static List<String> getTodasSituacoes() => ExpeditionSituationModel.getAllCodes();
  static List<String> getTodasDescricoes() => ExpeditionSituationModel.getAllDescriptions();
}
