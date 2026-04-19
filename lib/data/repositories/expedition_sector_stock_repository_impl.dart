import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_sector_stock_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionSectorStockModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionSectorStockRepositoryImpl implements BasicRepository<ExpeditionSectorStockModel> {
  static const String _selectEvent = 'setor.estoque.select';
  static const String _insertEvent = 'setor.estoque.insert';
  static const String _updateEvent = 'setor.estoque.update';
  static const String _deleteEvent = 'setor.estoque.delete';

  @override
  Future<List<ExpeditionSectorStockModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionSectorStockModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionSectorStockModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionSectorStockModel>> insert(ExpeditionSectorStockModel entity) {
    return SocketRequestHelper.mutation<ExpeditionSectorStockModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionSectorStockModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionSectorStockModel>> update(ExpeditionSectorStockModel entity) {
    return SocketRequestHelper.mutation<ExpeditionSectorStockModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionSectorStockModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionSectorStockModel>> delete(ExpeditionSectorStockModel entity) {
    return SocketRequestHelper.mutation<ExpeditionSectorStockModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionSectorStockModel.fromJson,
    );
  }
}
