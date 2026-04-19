import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCancellationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCancellationRepositoryImpl implements BasicRepository<ExpeditionCancellationModel> {
  static const String _selectEvent = 'expedicao.cancelamento.select';
  static const String _insertEvent = 'expedicao.cancelamento.insert';
  static const String _updateEvent = 'expedicao.cancelamento.update';
  static const String _deleteEvent = 'expedicao.cancelamento.delete';

  @override
  Future<List<ExpeditionCancellationModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCancellationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCancellationModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCancellationModel>> insert(ExpeditionCancellationModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCancellationModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCancellationModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCancellationModel>> update(ExpeditionCancellationModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCancellationModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCancellationModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCancellationModel>> delete(ExpeditionCancellationModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCancellationModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCancellationModel.fromJson,
    );
  }
}
