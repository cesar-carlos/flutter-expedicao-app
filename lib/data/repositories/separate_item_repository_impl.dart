import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de SeparateItemModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper para
/// detalhes dos 4 bugs latentes mitigados).
class SeparateItemRepositoryImpl implements BasicRepository<SeparateItemModel> {
  static const String _selectEvent = 'separar.item.select';
  static const String _insertEvent = 'separar.item.insert';
  static const String _updateEvent = 'separar.item.update';
  static const String _deleteEvent = 'separar.item.delete';

  @override
  Future<List<SeparateItemModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateItemModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateItemModel.fromJson,
    );
  }

  @override
  Future<List<SeparateItemModel>> insert(SeparateItemModel entity) {
    return SocketRequestHelper.mutation<SeparateItemModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateItemModel.fromJson,
    );
  }

  @override
  Future<List<SeparateItemModel>> update(SeparateItemModel entity) {
    return SocketRequestHelper.mutation<SeparateItemModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateItemModel.fromJson,
    );
  }

  @override
  Future<List<SeparateItemModel>> delete(SeparateItemModel entity) {
    return SocketRequestHelper.mutation<SeparateItemModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateItemModel.fromJson,
    );
  }
}
