import 'package:exp/domain/models/query_builder.dart';

abstract class BasicConsultationRepository<T> {
  /// Consulta T com filtros opcionais
  ///
  /// [params] - Filtros para a consulta (opcional)
  /// Retorna uma lista de consultas de T
  Future<List<T>> selectConsultation(QueryBuilder queryBuilder);
}
