import 'package:exp/domain/models/query_params.dart';
import 'package:exp/domain/models/shipping_situation_model.dart';

/// Exemplo de uso do sistema de parâmetros tipados
class QueryParamsExample {
  /// Exemplo básico de uso
  static void basicExample() {
    // Criando parâmetros simples
    final param1 = QueryParam.create('codigo', '12345');
    final param2 = QueryParam.create('situacao', 'AGUARDANDO');

    print('Parâmetro 1: ${param1.toQueryString()}'); // codigo='12345'
    print('Parâmetro 2: ${param2.toQueryString()}'); // situacao='AGUARDANDO'
  }

  /// Exemplo com QueryBuilder
  static void queryBuilderExample() {
    final query = QueryBuilder()
        .equals('codigo', '12345')
        .status(ExpeditionSituation.aguardando.code)
        .like('descricao', 'produto')
        .greaterThan('data', DateTime(2024, 1, 1))
        .paginate(limit: 20, offset: 0)
        .build();

    print('Query: $query');
    // Resultado: codigo='12345'&situacao='AGUARDANDO'&descricao LIKE '%produto%'&data>'2024-01-01T00:00:00.000'&limit=20&offset=0
  }

  /// Exemplo com filtros de situação
  static void situationFilterExample() {
    final query = QueryBuilder()
        .status(ExpeditionSituation.emAndamento.code)
        .search('usuario', 'joao')
        .dateRange('dataInicial', DateTime(2024, 1, 1), DateTime(2024, 12, 31))
        .paginate(limit: 50)
        .build();

    print('Query com situação: $query');
  }

  /// Exemplo com operadores customizados
  static void customOperatorsExample() {
    final query = QueryBuilder()
        .addParam('codigo', '12345', operator: '=')
        .addParam('valor', 100.50, operator: '>')
        .addParam('status', ['ATIVO', 'PENDENTE'], operator: 'IN')
        .build();

    print('Query com operadores: $query');
  }

  /// Exemplo de uso no repositório
  static Future<void> repositoryExample() async {
    // Simulando uso no repositório
    final queryBuilder = QueryBuilder()
        .status(ExpeditionSituation.finalizada.code)
        .search('usuario', 'admin')
        .paginate(limit: 10, offset: 0);

    // Uso seria assim:
    // final results = await repository.selectConsultationWithParams(queryBuilder);

    print('Query para repositório: ${queryBuilder.build()}');
  }

  /// Exemplo com validação de parâmetros
  static void validationExample() {
    final query = QueryBuilder();

    // Adicionando parâmetros condicionalmente
    final codigo = '12345';
    if (codigo.isNotEmpty) {
      query.code(codigo);
    }

    final situacao = ExpeditionSituation.aguardando.code;
    if (situacao.isNotEmpty) {
      query.status(situacao);
    }

    // Sempre adicionar paginação
    query.paginate(limit: 20);

    print('Query com validação: ${query.build()}');
  }

  /// Exemplo de reutilização de queries
  static void reusableQueryExample() {
    // Query base que pode ser reutilizada
    final baseQuery = QueryBuilder()
        .status(ExpeditionSituation.emAndamento.code)
        .paginate(limit: 10);

    // Adicionando filtros específicos
    final query1 = QueryBuilder()
        .addParam('codigo', '12345')
        .addParam('usuario', 'joao')
        .build();

    final query2 = QueryBuilder()
        .addParam('data', DateTime.now())
        .addParam('valor', 100.0, operator: '>')
        .build();

    print('Query base: ${baseQuery.build()}');
    print('Query 1: $query1');
    print('Query 2: $query2');
  }
}

/// Exemplo de uso em ViewModels
class SeparateConsultationViewModelExample {
  /// Buscar por situação específica
  static QueryBuilder buildSituationQuery(String situation) {
    return QueryBuilder().status(situation).paginate(limit: 20, offset: 0);
  }

  /// Buscar por código
  static QueryBuilder buildCodeQuery(String code) {
    return QueryBuilder().code(code).paginate(limit: 10);
  }

  /// Buscar por usuário
  static QueryBuilder buildUserQuery(String user) {
    return QueryBuilder().search('usuario', user).paginate(limit: 50);
  }

  /// Buscar por período
  static QueryBuilder buildDateRangeQuery(DateTime start, DateTime end) {
    return QueryBuilder()
        .dateRange('dataInicial', start, end)
        .paginate(limit: 100);
  }

  /// Buscar com múltiplos filtros
  static QueryBuilder buildComplexQuery({
    String? code,
    String? situation,
    String? user,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final query = QueryBuilder();

    if (code != null && code.isNotEmpty) {
      query.code(code);
    }

    if (situation != null && situation.isNotEmpty) {
      query.status(situation);
    }

    if (user != null && user.isNotEmpty) {
      query.search('usuario', user);
    }

    if (startDate != null && endDate != null) {
      query.dateRange('dataInicial', startDate, endDate);
    }

    return query.paginate(limit: 20);
  }
}
