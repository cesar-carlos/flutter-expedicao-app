import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_check.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCheckModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCheckRepositoryImpl implements BasicRepository<ExpeditionCheckModel> {
  static const String _selectEvent = 'conferir.select';
  static const String _insertEvent = 'conferir.insert';
  static const String _updateEvent = 'conferir.update';
  static const String _deleteEvent = 'conferir.delete';

  @override
  Future<List<ExpeditionCheckModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCheckModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCheckModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckModel>> insert(ExpeditionCheckModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckModel>> update(ExpeditionCheckModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckModel>> delete(ExpeditionCheckModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckModel.fromJson,
    );
  }
}
