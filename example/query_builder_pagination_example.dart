import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/models/query_builder_extension.dart';

/// Exemplo de uso do QueryBuilder com paginação
void main() {
  // Exemplo 1: QueryBuilder básico com paginação padrão
  final basicQuery = QueryBuilderExtension.withDefaultPagination();
  print('Query básica: ${basicQuery.build()}');
  // Output: limit=20&offset=0

  // Exemplo 2: QueryBuilder com parâmetros e paginação personalizada
  final customQuery = QueryBuilder()
      .equals('situacao', 'ATIVO')
      .like('codigo', 'SEP%')
      .paginate(limit: 50, offset: 100);
  print('Query personalizada: ${customQuery.build()}');
  // Output: situacao='ATIVO'&codigoLIKE'SEP%'&limit=50&offset=100

  // Exemplo 3: QueryBuilder usando extensões
  final extendedQuery =
      QueryBuilderExtension.withDefaultPagination(limit: 10, offset: 0)
          .status('PENDENTE')
          .search('codigo', 'SEP')
          .dateRange(
            'data_criacao',
            DateTime(2024, 1, 1),
            DateTime(2024, 12, 31),
          );
  print('Query com extensões: ${extendedQuery.build()}');
  // Output: limit=10&offset=0&situacao='PENDENTE'&codigoLIKE'%SEP%'&data_criacao>'2024-01-01T00:00:00.000'&data_criacao<'2024-12-31T00:00:00.000'

  // Exemplo 4: QueryBuilder sem paginação
  final noPaginationQuery = QueryBuilder()
      .equals('usuario', 'admin')
      .notEquals('status', 'CANCELADO');
  print('Query sem paginação: ${noPaginationQuery.build()}');
  // Output: usuario='admin'&status!='CANCELADO'

  // Exemplo 5: QueryBuilder com lista de valores
  final listQuery = QueryBuilder()
      .inList('situacao', ['ATIVO', 'PENDENTE', 'PROCESSANDO'])
      .paginate(limit: 25, offset: 0);
  print('Query com lista: ${listQuery.build()}');
  // Output: situacaoIN'ATIVO','PENDENTE','PROCESSANDO'&limit=25&offset=0

  // Exemplo 6: Construção de query em etapas
  final stepQuery = QueryBuilder();

  // Adiciona filtros condicionalmente
  stepQuery.equals('ativo', true);

  // Adiciona paginação
  stepQuery.paginate(limit: 30, offset: 60);

  // Adiciona mais filtros
  stepQuery.greaterThan('data_criacao', DateTime(2024, 6, 1));

  print('Query em etapas: ${stepQuery.build()}');
  // Output: ativo=true&limit=30&offset=60&data_criacao>'2024-06-01T00:00:00.000'

  // Exemplo 7: Acesso aos parâmetros e paginação
  print('Parâmetros: ${stepQuery.params.length}');
  print('Paginação: ${stepQuery.pagination}');
  print('Query string: ${stepQuery.buildQuery()}');
  print('Paginação string: ${stepQuery.buildPagination()}');
}
