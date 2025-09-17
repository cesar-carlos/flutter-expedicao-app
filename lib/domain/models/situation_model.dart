enum Situation {
  ativo('S', 'Sim'),
  inativo('N', 'Não');

  const Situation(this.code, this.description);

  final String code;
  final String description;

  static Situation? fromCode(String code) {
    try {
      return Situation.values.firstWhere(
        (situation) => situation.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return Situation.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return Situation.values.map((e) => e.description).toList();
  }

  static bool isValidSituation(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static Situation fromCodeWithFallback(
    String code, {
    Situation fallback = Situation.inativo,
  }) {
    return fromCode(code) ?? fallback;
  }
}

extension SituationExtension on String {
  Situation? get asSituation => Situation.fromCode(this);
  String get situationDescription => Situation.getDescription(this);
  bool get isValidSituation => Situation.isValidSituation(this);
}

class SituationModel {
  SituationModel._();

  static String getDescription(String code) => Situation.getDescription(code);
  static bool isValidSituation(String code) => Situation.isValidSituation(code);
  static List<String> getAllCodes() => Situation.getAllCodes();
  static List<String> getAllDescriptions() => Situation.getAllDescriptions();
  static List<Situation> getAllSituations() => Situation.values;

  static Situation fromCodeWithFallback(
    String code, {
    Situation fallback = Situation.inativo,
  }) {
    return Situation.fromCodeWithFallback(code, fallback: fallback);
  }

  static Map<String, String> get situationMap {
    return Map.fromEntries(
      Situation.values.map(
        (situation) => MapEntry(situation.code, situation.description),
      ),
    );
  }
}
