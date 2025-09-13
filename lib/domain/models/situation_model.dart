/// Enum para representar situações ativas/inativas
enum Situation {
  ativo('S', 'Sim'),
  inativo('N', 'Não');

  const Situation(this.code, this.description);

  final String code;
  final String description;

  /// Converte uma string para o enum correspondente
  static Situation? fromCode(String code) {
    try {
      return Situation.values.firstWhere(
        (situation) => situation.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Retorna todos os códigos disponíveis
  static List<String> getAllCodes() {
    return Situation.values.map((e) => e.code).toList();
  }

  /// Retorna todas as descrições disponíveis
  static List<String> getAllDescriptions() {
    return Situation.values.map((e) => e.description).toList();
  }

  /// Verifica se um código é válido
  static bool isValidSituation(String code) {
    return fromCode(code) != null;
  }

  /// Retorna a descrição para um código específico
  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  /// Retorna o enum para um código específico com fallback
  static Situation fromCodeWithFallback(
    String code, {
    Situation fallback = Situation.inativo,
  }) {
    return fromCode(code) ?? fallback;
  }
}

/// Extension para facilitar o uso com strings
extension SituationExtension on String {
  /// Converte string para Situation
  Situation? get asSituation => Situation.fromCode(this);

  /// Retorna a descrição da situação
  String get situationDescription => Situation.getDescription(this);

  /// Verifica se é uma situação válida
  bool get isValidSituation => Situation.isValidSituation(this);
}

/// Classe utilitária para trabalhar com situações
class SituationModel {
  SituationModel._();

  /// Retorna a descrição para um código
  static String getDescription(String code) => Situation.getDescription(code);

  /// Verifica se um código é válido
  static bool isValidSituation(String code) => Situation.isValidSituation(code);

  /// Retorna todos os códigos
  static List<String> getAllCodes() => Situation.getAllCodes();

  /// Retorna todas as descrições
  static List<String> getAllDescriptions() => Situation.getAllDescriptions();

  /// Retorna todas as situações
  static List<Situation> getAllSituations() => Situation.values;

  /// Converte código para enum com fallback
  static Situation fromCodeWithFallback(
    String code, {
    Situation fallback = Situation.inativo,
  }) {
    return Situation.fromCodeWithFallback(code, fallback: fallback);
  }

  /// Mapa de códigos para descrições
  static Map<String, String> get situationMap {
    return Map.fromEntries(
      Situation.values.map(
        (situation) => MapEntry(situation.code, situation.description),
      ),
    );
  }
}
