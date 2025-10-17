import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

abstract class BasicConsultationRepository<T> {
  /// Consulta T com filtros opcionais
  ///
  /// [params] - Filtros para a consulta (opcional)
  /// Retorna uma lista de consultas de T
  Future<List<T>> selectConsultation(QueryBuilder queryBuilder);
}
