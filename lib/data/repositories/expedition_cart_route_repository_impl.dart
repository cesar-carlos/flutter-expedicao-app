import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCartRouteModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCartRouteRepositoryImpl implements BasicRepository<ExpeditionCartRouteModel> {
  static const String _selectEvent = 'carrinho.percurso.select';
  static const String _insertEvent = 'carrinho.percurso.insert';
  static const String _updateEvent = 'carrinho.percurso.update';
  static const String _deleteEvent = 'carrinho.percurso.delete';

  @override
  Future<List<ExpeditionCartRouteModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartRouteModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartRouteModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteModel>> insert(ExpeditionCartRouteModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteModel>> update(ExpeditionCartRouteModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteModel>> delete(ExpeditionCartRouteModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteModel.fromJson,
    );
  }
}
