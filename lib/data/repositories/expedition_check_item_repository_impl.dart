import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCheckItemModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCheckItemRepositoryImpl implements BasicRepository<ExpeditionCheckItemModel> {
  static const String _selectEvent = 'conferir.item.select';
  static const String _insertEvent = 'conferir.item.insert';
  static const String _updateEvent = 'conferir.item.update';
  static const String _deleteEvent = 'conferir.item.delete';

  @override
  Future<List<ExpeditionCheckItemModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCheckItemModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCheckItemModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckItemModel>> insert(ExpeditionCheckItemModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckItemModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckItemModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckItemModel>> update(ExpeditionCheckItemModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckItemModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckItemModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCheckItemModel>> delete(ExpeditionCheckItemModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCheckItemModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCheckItemModel.fromJson,
    );
  }
}
