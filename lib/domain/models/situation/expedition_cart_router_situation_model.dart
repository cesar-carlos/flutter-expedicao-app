enum ExpeditionCartRouterSituation {
  cancelada('CANCELADA', 'Cancelada'),
  conferido('CONFERIDO', 'Conferido'),
  emConferencia('EM CONFERENCIA', 'Em Conferência'),
  emEntrega('EM ENTREGA', 'Em Entrega'),
  entregue('ENTREGUE', 'Entregue'),
  emSeparacao('EM SEPARACAO', 'Em Separação'),
  finalizada('FINALIZADA', 'Finalizada'),
  separado('SEPARADO', 'Separado'),
  embalado('EMBALADO', 'Embalado'),
  vazio('', '');

  const ExpeditionCartRouterSituation(this.code, this.description);

  final String code;
  final String description;

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

  static Map<String, String> getSituacaoMap() {
    return Map.fromEntries(
      ExpeditionCartRouterSituation.values.map((situation) => MapEntry(situation.code, situation.description)),
    );
  }
}

extension ExpeditionCartRouterSituationExtension on String {
  ExpeditionCartRouterSituation? get asCartRouterSituation => ExpeditionCartRouterSituation.fromCode(this);
  String get cartRouterSituationDescription => ExpeditionCartRouterSituation.getDescription(this);
}

class ExpeditionCartRouterSituationModel {
  ExpeditionCartRouterSituationModel._();

  static String getDescription(String code) => ExpeditionCartRouterSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionCartRouterSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionCartRouterSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionCartRouterSituation.getAllDescriptions();

  static Map<String, String> get situacao => ExpeditionCartRouterSituation.getSituacaoMap();

  static List<ExpeditionCartRouterSituation> getAllSituations() => ExpeditionCartRouterSituation.values;
}
