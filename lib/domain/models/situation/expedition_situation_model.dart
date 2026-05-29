enum ExpeditionSituation {
  aguardando('AGUARDANDO', 'Aguardando'),
  emPausa('EM PAUSA', 'Em Pausa'),
  cancelada('CANCELADA', 'Cancelada'),
  separando('SEPARANDO', 'Separando'),
  separado('SEPARADO', 'Separado'),
  conferindo('CONFERINDO', 'Conferindo'),
  conferido('CONFERIDO', 'Conferido'),
  entregue('ENTREGUE', 'Entregue'),
  embalando('EMBALANDO', 'Embalando'),
  embalado('EMBALADO', 'Embalado'),
  agrupado('AGRUPADO', 'Agrupado'),
  finalizada('FINALIZADA', 'Finalizada'),
  naoLocalizada('NÃO LOCALIZADO', 'Não Localizada');

  const ExpeditionSituation(this.code, this.description);

  final String code;
  final String description;

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
}

extension ExpeditionSituationExtension on String {
  ExpeditionSituation? get asSituation => ExpeditionSituation.fromCode(this);
  String get situationDescription => ExpeditionSituation.getDescription(this);
}

class ExpeditionSituationModel {
  ExpeditionSituationModel._();

  static String getDescription(String code) => ExpeditionSituation.getDescription(code);

  static bool isValidSituation(String code) => ExpeditionSituation.isValidSituation(code);

  static List<String> getAllCodes() => ExpeditionSituation.getAllCodes();

  static List<String> getAllDescriptions() => ExpeditionSituation.getAllDescriptions();

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
