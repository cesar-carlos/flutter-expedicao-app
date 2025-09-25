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

  static ExpeditionOrigem? fromCode(String code) {
    try {
      return ExpeditionOrigem.values.firstWhere((origem) => origem.code.toUpperCase() == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return ExpeditionOrigem.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return ExpeditionOrigem.values.map((e) => e.description).toList();
  }

  static bool isValidOrigem(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }

  static ExpeditionOrigem fromCodeWithFallback(String code, {ExpeditionOrigem fallback = ExpeditionOrigem.vazio}) {
    return fromCode(code) ?? fallback;
  }

  static Map<String, String> get origemMap {
    return Map.fromEntries(ExpeditionOrigem.values.map((origem) => MapEntry(origem.code, origem.description)));
  }
}

extension ExpeditionOrigemExtension on String {
  ExpeditionOrigem? get asExpeditionOrigem => ExpeditionOrigem.fromCode(this);

  String get expeditionOrigemDescription => ExpeditionOrigem.getDescription(this);

  bool get isValidExpeditionOrigem => ExpeditionOrigem.isValidOrigem(this);
}

class ExpeditionOrigemModel {
  ExpeditionOrigemModel._();

  static String getDescription(String code) => ExpeditionOrigem.getDescription(code);

  static bool isValidOrigem(String code) => ExpeditionOrigem.isValidOrigem(code);

  static List<String> getAllCodes() => ExpeditionOrigem.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionOrigem.getAllDescriptions();

  static List<ExpeditionOrigem> getAllOrigens() => ExpeditionOrigem.values;

  static ExpeditionOrigem fromCodeWithFallback(String code, {ExpeditionOrigem fallback = ExpeditionOrigem.vazio}) {
    return ExpeditionOrigem.fromCodeWithFallback(code, fallback: fallback);
  }

  static Map<String, String> get origemMap => ExpeditionOrigem.origemMap;
}
