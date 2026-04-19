import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionCartModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva os timeouts originais.
class ExpeditionCartRepositoryImpl implements BasicRepository<ExpeditionCartModel> {
  static const String _selectEvent = 'carrinho.select';
  static const String _insertEvent = 'carrinho.insert';
  static const String _updateEvent = 'carrinho.update';
  static const String _deleteEvent = 'carrinho.delete';

  @override
  Future<List<ExpeditionCartModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartModel>> insert(ExpeditionCartModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartModel>> update(ExpeditionCartModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<ExpeditionCartModel>> delete(ExpeditionCartModel entity) {
    return SocketRequestHelper.mutation<ExpeditionCartModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionCartModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }
}
