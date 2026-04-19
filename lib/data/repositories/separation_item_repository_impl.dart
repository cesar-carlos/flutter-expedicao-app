import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de SeparationItemModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva os timeouts originais (`shortNetworkTimeout` no select,
/// `networkTimeout` nas mutations) para manter comportamento existente.
class SeparationItemRepositoryImpl implements BasicRepository<SeparationItemModel> {
  static const String _selectEvent = 'separacao.item.select';
  static const String _insertEvent = 'separacao.item.insert';
  static const String _updateEvent = 'separacao.item.update';
  static const String _deleteEvent = 'separacao.item.delete';

  @override
  Future<List<SeparationItemModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparationItemModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationItemModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }

  @override
  Future<List<SeparationItemModel>> insert(SeparationItemModel entity) {
    return SocketRequestHelper.mutation<SeparationItemModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationItemModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<SeparationItemModel>> update(SeparationItemModel entity) {
    return SocketRequestHelper.mutation<SeparationItemModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationItemModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }

  @override
  Future<List<SeparationItemModel>> delete(SeparationItemModel entity) {
    return SocketRequestHelper.mutation<SeparationItemModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationItemModel.fromJson,
      timeout: UIConstants.networkTimeout,
    );
  }
}
