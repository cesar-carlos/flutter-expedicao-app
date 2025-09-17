enum ExpeditionOrigem {
  orcamentoBalcao('OB', 'Orcamento Balcão'),
  separacaoEstoque('SE', 'Separação Estoque'),
  compraMercadoria('CP', 'Compra de Mercadoria'),
  devolucaoVenda('DV', 'Devolução de Venda'),
  devolucaoCompra('DC', 'Devolução de Compra'),
  conferenciaMercadoria('CO', 'Conferencia de Mercadoria'),
  entregaBalcao('EB', 'Entrega Balcão'),
  entregaBalcaoEN('EN', 'Entrega Balcão'),
  embalagem('EM', 'Embalagem de Mercadoria'),
  vazio('', '');

  const ExpeditionOrigem(this.code, this.description);

  final String code;
  final String description;

  /// Converte uma string para o enum correspondente
  static ExpeditionOrigem? fromCode(String code) {
    try {
      return ExpeditionOrigem.values.firstWhere((origem) => origem.code.toUpperCase() == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  /// Retorna todos os códigos disponíveis
  static List<String> getAllCodes() {
    return ExpeditionOrigem.values.map((e) => e.code).toList();
  }

  /// Retorna todas as descrições disponíveis
  static List<String> getAllDescriptions() {
    return ExpeditionOrigem.values.map((e) => e.description).toList();
  }

  /// Verifica se um código é válido
  static bool isValidOrigem(String code) {
    return fromCode(code) != null;
  }

  /// Retorna a descrição para um código específico
  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  /// Retorna o enum para um código específico com fallback
  static ExpeditionOrigem fromCodeWithFallback(String code, {ExpeditionOrigem fallback = ExpeditionOrigem.vazio}) {
    return fromCode(code) ?? fallback;
  }

  /// Mapa de códigos para descrições
  static Map<String, String> get origemMap {
    return Map.fromEntries(ExpeditionOrigem.values.map((origem) => MapEntry(origem.code, origem.description)));
  }
}

/// Extension para facilitar o uso com strings
extension ExpeditionOrigemExtension on String {
  /// Converte string para ExpeditionOrigem
  ExpeditionOrigem? get asExpeditionOrigem => ExpeditionOrigem.fromCode(this);

  /// Retorna a descrição da origem
  String get expeditionOrigemDescription => ExpeditionOrigem.getDescription(this);

  /// Verifica se é uma origem válida
  bool get isValidExpeditionOrigem => ExpeditionOrigem.isValidOrigem(this);
}

/// Classe utilitária para trabalhar com origens de expedição
class ExpeditionOrigemModel {
  ExpeditionOrigemModel._();

  /// Retorna a descrição para um código
  static String getDescription(String code) => ExpeditionOrigem.getDescription(code);

  /// Verifica se um código é válido
  static bool isValidOrigem(String code) => ExpeditionOrigem.isValidOrigem(code);

  /// Retorna todos os códigos
  static List<String> getAllCodes() => ExpeditionOrigem.getAllCodes();

  /// Retorna todas as descrições
  static List<String> getAllDescriptions() => ExpeditionOrigem.getAllDescriptions();

  /// Retorna todas as origens
  static List<ExpeditionOrigem> getAllOrigens() => ExpeditionOrigem.values;

  /// Converte código para enum com fallback
  static ExpeditionOrigem fromCodeWithFallback(String code, {ExpeditionOrigem fallback = ExpeditionOrigem.vazio}) {
    return ExpeditionOrigem.fromCodeWithFallback(code, fallback: fallback);
  }

  /// Mapa de códigos para descrições
  static Map<String, String> get origemMap => ExpeditionOrigem.origemMap;
}
