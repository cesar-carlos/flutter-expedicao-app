import 'package:exp/domain/models/query_builder.dart';

abstract class BasicRepository<T> {
  /// Seleciona entidades com filtros opcionais
  ///
  /// [queryBuilder] - Filtros para a consulta
  /// Retorna uma lista de T
  Future<List<T>> select(QueryBuilder queryBuilder);

  /// Insere uma nova entidade
  ///
  /// [entity] - Dados da entidade a ser inserida
  /// Retorna uma lista com a entidade inserida
  Future<List<T>> insert(T entity);

  /// Atualiza uma entidade existente
  ///
  /// [entity] - Dados da entidade a ser atualizada
  /// Retorna uma lista com a entidade atualizada
  Future<List<T>> update(T entity);

  /// Remove uma entidade
  ///
  /// [entity] - Dados da entidade a ser removida
  /// Retorna uma lista com o resultado da operação
  Future<List<T>> delete(T entity);
}
