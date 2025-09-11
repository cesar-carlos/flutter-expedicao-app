import 'package:exp/domain/models/query_params.dart';
import 'package:exp/domain/models/shipping_situation_model.dart';

/// Exemplos práticos de uso do QueryBuilder
void main() {
  print('=== Exemplos de Uso do QueryBuilder ===\n');

  // Exemplo 1: Consulta simples por código
  print('1. Consulta simples por código:');
  final query1 = QueryBuilder()
      .code('EXP001')
      .paginate(limit: 10, offset: 0)
      .build();
  print('Query: $query1\n');

  // Exemplo 2: Consulta por situação
  print('2. Consulta por situação:');
  final query2 = QueryBuilder()
      .status(ExpeditionSituation.aguardando.code)
      .paginate(limit: 20)
      .build();
  print('Query: $query2\n');

  // Exemplo 3: Consulta com múltiplos filtros
  print('3. Consulta com múltiplos filtros:');
  final query3 = QueryBuilder()
      .equals('usuario', 'joao.silva')
      .status(ExpeditionSituation.emAndamento.code)
      .greaterThan('data_criacao', DateTime(2024, 1, 1))
      .lessThan('data_criacao', DateTime(2024, 12, 31))
      .paginate(limit: 50, offset: 0)
      .build();
  print('Query: $query3\n');

  // Exemplo 4: Consulta com busca de texto
  print('4. Consulta com busca de texto:');
  final query4 = QueryBuilder()
      .search('observacoes', 'urgente')
      .status(ExpeditionSituation.finalizada.code)
      .paginate(limit: 15)
      .build();
  print('Query: $query4\n');

  // Exemplo 5: Consulta com lista de valores
  print('5. Consulta com lista de valores:');
  final query5 = QueryBuilder()
      .inList('situacao', [
        ExpeditionSituation.aguardando.code,
        ExpeditionSituation.emAndamento.code,
        ExpeditionSituation.emSeparacao.code,
      ])
      .equals('ativo', true)
      .paginate(limit: 100)
      .build();
  print('Query: $query5\n');

  // Exemplo 6: Consulta com range de datas
  print('6. Consulta com range de datas:');
  final query6 = QueryBuilder()
      .dateRange('data_criacao', DateTime(2024, 1, 1), DateTime(2024, 1, 31))
      .notEquals('situacao', ExpeditionSituation.cancelada.code)
      .paginate(limit: 30)
      .build();
  print('Query: $query6\n');

  // Exemplo 7: Consulta complexa (todos os recursos)
  print('7. Consulta complexa (todos os recursos):');
  final query7 = QueryBuilder()
      .equals('usuario', 'admin')
      .notEquals('deleted', true)
      .like('codigo', 'EXP%')
      .greaterThan('prioridade', 5)
      .lessThan('prioridade', 10)
      .inList('categoria', ['urgente', 'normal'])
      .dateRange('data_criacao', DateTime(2024, 1, 1), DateTime(2024, 12, 31))
      .search('observacoes', 'importante')
      .status(ExpeditionSituation.aguardando.code)
      .code('EXP001')
      .paginate(limit: 100, offset: 50)
      .build();
  print('Query: $query7\n');

  // Exemplo 8: Construção dinâmica de query
  print('8. Construção dinâmica de query:');
  final queryBuilder = QueryBuilder();

  // Adiciona filtros condicionalmente
  final usuario = 'maria.santos';
  if (usuario.isNotEmpty) {
    queryBuilder.equals('usuario', usuario);
  }

  final situacao = ExpeditionSituation.emAndamento.code;
  if (situacao.isNotEmpty) {
    queryBuilder.status(situacao);
  }

  final dataInicio = DateTime(2024, 6, 1);
  final dataFim = DateTime(2024, 6, 30);
  queryBuilder.dateRange('data_criacao', dataInicio, dataFim);

  queryBuilder.paginate(limit: 25);

  final query8 = queryBuilder.build();
  print('Query dinâmica: $query8\n');

  // Exemplo 9: Reutilização de QueryBuilder
  print('9. Reutilização de QueryBuilder:');
  final baseQuery = QueryBuilder()
      .equals('ativo', true)
      .status(ExpeditionSituation.aguardando.code);

  // Query para admin
  final adminQuery = QueryBuilder()
      .addParam('usuario', 'admin')
      .addParam('admin', true)
      .build();
  print('Query admin: $adminQuery');

  // Query para usuário comum
  final userQuery = baseQuery.equals('usuario', 'usuario.comum').build();
  print('Query usuário: $userQuery\n');

  // Exemplo 10: Validação de parâmetros
  print('10. Validação de parâmetros:');
  try {
    final query10 = QueryBuilder()
        .equals('codigo', '') // Código vazio
        .equals('situacao', 'INVALID_STATUS') // Status inválido
        .build();
    print('Query com parâmetros inválidos: $query10');
  } catch (e) {
    print('Erro na validação: $e');
  }

  print('\n=== Fim dos Exemplos ===');
}

/// Exemplo de uso em um ViewModel
class ExampleViewModel {
  final QueryBuilder _baseQuery = QueryBuilder()
      .equals('ativo', true)
      .paginate(limit: 20);

  /// Busca expedições por situação
  String buildStatusQuery(String situacao) {
    return _baseQuery.status(situacao).build();
  }

  /// Busca expedições por usuário
  String buildUserQuery(String usuario) {
    return _baseQuery.equals('usuario', usuario).build();
  }

  /// Busca expedições por período
  String buildDateRangeQuery(DateTime inicio, DateTime fim) {
    return _baseQuery.dateRange('data_criacao', inicio, fim).build();
  }

  /// Busca expedições com filtros múltiplos
  String buildComplexQuery({
    String? usuario,
    String? situacao,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? buscaTexto,
  }) {
    final query = QueryBuilder().equals('ativo', true).paginate(limit: 50);

    if (usuario != null && usuario.isNotEmpty) {
      query.equals('usuario', usuario);
    }

    if (situacao != null && situacao.isNotEmpty) {
      query.status(situacao);
    }

    if (dataInicio != null && dataFim != null) {
      query.dateRange('data_criacao', dataInicio, dataFim);
    }

    if (buscaTexto != null && buscaTexto.isNotEmpty) {
      query.search('observacoes', buscaTexto);
    }

    return query.build();
  }
}
