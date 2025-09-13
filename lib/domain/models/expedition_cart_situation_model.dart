enum ExpeditionCartSituation {
  emSeparacao('EM SEPARACAO', 'Em Separação'),
  liberado('LIBERADO', 'Liberado'),
  separando('SEPARANDO', 'Separando'),
  emConferencia('EM CONFERENCIA', 'Em Conferência'),
  separado('SEPARADO', 'Separado'),
  conferindo('CONFERINDO', 'Conferindo'),
  conferido('CONFERIDO', 'Conferido'),
  agrupado('AGRUPADO', 'Agrupado'),
  cancelado('CANCELADO', 'Cancelado'),
  vazio('', '');

  const ExpeditionCartSituation(this.code, this.description);

  final String code;
  final String description;

  static ExpeditionCartSituation? fromCode(String code) {
    try {
      return ExpeditionCartSituation.values.firstWhere(
        (situation) => situation.code == code.toUpperCase(),
      );
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
      ExpeditionCartSituation.values.map(
        (situation) => MapEntry(situation.code, situation.description),
      ),
    );
  }
}

extension ExpeditionCartSituationExtension on String {
  ExpeditionCartSituation? get asCartSituation =>
      ExpeditionCartSituation.fromCode(this);
  String get cartSituationDescription =>
      ExpeditionCartSituation.getDescription(this);
}

class ExpeditionCartSituationModel {
  ExpeditionCartSituationModel._();

  static String getDescription(String code) =>
      ExpeditionCartSituation.getDescription(code);

  static bool isValidSituation(String code) =>
      ExpeditionCartSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionCartSituation.getAllCodes();

  static List<String> getAllDescriptions() =>
      ExpeditionCartSituation.getAllDescriptions();

  static Map<String, String> get situacao =>
      ExpeditionCartSituation.getSituacaoMap();
}
