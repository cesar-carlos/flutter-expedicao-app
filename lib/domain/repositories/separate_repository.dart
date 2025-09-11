import 'package:exp/domain/models/query_builder.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_model.dart';

abstract class SeparateRepository {
  /// Consulta separações com filtros opcionais
  ///
  /// [params] - Filtros para a consulta (opcional)
  /// Retorna uma lista de consultas de separação
  Future<List<SeparateConsultationModel>> selectConsultation(
    QueryBuilder queryBuilder,
  );

  /// Seleciona separações com filtros opcionais
  ///
  /// [params] - Filtros para a consulta (opcional)
  /// Retorna uma lista de separações
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder);

  /// Insere uma nova separação
  ///
  /// [entity] - Dados da separação a ser inserida
  /// Retorna uma lista com a separação inserida
  Future<List<SeparateModel>> insert(SeparateModel entity);

  /// Atualiza uma separação existente
  ///
  /// [entity] - Dados da separação a ser atualizada
  /// Retorna uma lista com a separação atualizada
  Future<List<SeparateModel>> update(SeparateModel entity);

  /// Remove uma separação
  ///
  /// [entity] - Dados da separação a ser removida
  /// Retorna uma lista com o resultado da operação
  Future<List<SeparateModel>> delete(SeparateModel entity);
}
