enum ExpeditionItemSituation {
  separado('SP', 'Separado'),
  cancelado('CA', 'Cancelado'),
  pendente('PE', 'Pendente'),
  conferido('CO', 'Conferido'),
  embalado('EM', 'Embalado'),
  entregue('EN', 'Entregue'),
  expedido('EX', 'Expedido'),
  pausado('PA', 'Pausado'),
  reiniciado('RE', 'Reiniciado'),
  finalizado('FN', 'Finalizado'),
  armazenar('AR', 'Armazenar'),
  vazio('', 'Vazio');

  const ExpeditionItemSituation(this.code, this.description);

  final String code;
  final String description;

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
}

extension ExpeditionItemSituationExtension on String {
  ExpeditionItemSituation? get asSituation => ExpeditionItemSituation.fromCode(this);
  String get situationDescription => ExpeditionItemSituation.getDescription(this);
}

class ExpeditionItemSituationModel {
  ExpeditionItemSituationModel._();

  static String getDescription(String code) => ExpeditionItemSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionItemSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionItemSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionItemSituation.getAllDescriptions();

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
