enum ExpeditionCartSituation {
  liberado('LIBERADO', 'Liberado'),
  emSeparacao('EM SEPARACAO', 'Em Separação'),
  separado('SEPARADO', 'Separado'),
  emConferencia('EM CONFERENCIA', 'Em Conferência'),
  conferindo('CONFERIDO', 'Conferido'),
  emEntrega('EM ENTREGA', 'Em Entrega'),
  emPausa('EM PAUSA', 'Em Pausa'),
  vazio('', '');

  const ExpeditionCartSituation(this.code, this.description);

  final String code;
  final String description;
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
