import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCartRouteInternshipGroupModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCartRouteInternshipGorupImpl implements BasicRepository<ExpeditionCartRouteInternshipGroupModel> {
  static const String _selectEvent = 'carrinho.percurso.agrupamento.select';
  static const String _insertEvent = 'carrinho.percurso.agrupamento.insert';
  static const String _updateEvent = 'carrinho.percurso.agrupamento.update';
  static const String _deleteEvent = 'carrinho.percurso.agrupamento.delete';

  @override
  Future<List<ExpeditionCartRouteInternshipGroupModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartRouteInternshipGroupModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartRouteInternshipGroupModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipGroupModel>> insert(ExpeditionCartRouteInternshipGroupModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipGroupModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipGroupModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipGroupModel>> update(ExpeditionCartRouteInternshipGroupModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipGroupModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipGroupModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipGroupModel>> delete(ExpeditionCartRouteInternshipGroupModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipGroupModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipGroupModel.fromJson,
    );
  }
}
