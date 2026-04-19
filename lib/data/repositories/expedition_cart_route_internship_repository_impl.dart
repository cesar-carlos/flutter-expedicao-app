import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCartRouteInternshipModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva os timeouts originais.
class ExpeditionCartRouteInternshipRepositoryImpl implements BasicRepository<ExpeditionCartRouteInternshipModel> {
  static const String _selectEvent = 'carrinho.percurso.estagio.select';
  static const String _insertEvent = 'carrinho.percurso.estagio.insert';
  static const String _updateEvent = 'carrinho.percurso.estagio.update';
  static const String _deleteEvent = 'carrinho.percurso.estagio.delete';

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartRouteInternshipModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartRouteInternshipModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> insert(ExpeditionCartRouteInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> update(ExpeditionCartRouteInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartRouteInternshipModel>> delete(ExpeditionCartRouteInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartRouteInternshipModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartRouteInternshipModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }
}
