enum TipoFatorConversao {
  multiplicacao('M', 'Multiplicação'),
  divisao('D', 'Divisão');

  const TipoFatorConversao(this.code, this.description);

  final String code;
  final String description;

  static TipoFatorConversao? fromCode(String code) {
    try {
      return TipoFatorConversao.values.firstWhere((tipo) => tipo.code.toUpperCase() == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return TipoFatorConversao.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return TipoFatorConversao.values.map((e) => e.description).toList();
  }

  static bool isValidTipoFatorConversao(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static TipoFatorConversao fromCodeWithFallback(
    String code, {
    TipoFatorConversao fallback = TipoFatorConversao.multiplicacao,
  }) {
    return fromCode(code) ?? fallback;
  }
}

extension TipoFatorConversaoExtension on String {
  TipoFatorConversao? get asTipoFatorConversao => TipoFatorConversao.fromCode(this);
  String get tipoFatorConversaoDescription => TipoFatorConversao.getDescription(this);
  bool get isValidTipoFatorConversao => TipoFatorConversao.isValidTipoFatorConversao(this);
}

class TipoFatorConversaoModel {
  TipoFatorConversaoModel._();

  static String getDescription(String code) => TipoFatorConversao.getDescription(code);
  static bool isValidTipoFatorConversao(String code) => TipoFatorConversao.isValidTipoFatorConversao(code);
  static List<String> getAllCodes() => TipoFatorConversao.getAllCodes();
  static List<String> getAllDescriptions() => TipoFatorConversao.getAllDescriptions();
  static List<TipoFatorConversao> getAllTipos() => TipoFatorConversao.values;

  static TipoFatorConversao fromCodeWithFallback(
    String code, {
    TipoFatorConversao fallback = TipoFatorConversao.multiplicacao,
  }) {
    return TipoFatorConversao.fromCodeWithFallback(code, fallback: fallback);
  }

  static Map<String, String> get tipoFatorConversaoMap {
    return Map.fromEntries(TipoFatorConversao.values.map((tipo) => MapEntry(tipo.code, tipo.description)));
  }
}
