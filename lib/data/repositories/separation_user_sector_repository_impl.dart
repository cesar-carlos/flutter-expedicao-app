import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de SeparationUserSectorModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class SeparationUserSectorRepositoryImpl implements BasicRepository<SeparationUserSectorModel> {
  static const String _selectEvent = 'separar.usuario.setor.select';
  static const String _insertEvent = 'separar.usuario.setor.insert';
  static const String _updateEvent = 'separar.usuario.setor.update';
  static const String _deleteEvent = 'separar.usuario.setor.delete';

  @override
  Future<List<SeparationUserSectorModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparationUserSectorModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationUserSectorModel.fromJson,
    );
  }

  @override
  Future<List<SeparationUserSectorModel>> insert(SeparationUserSectorModel entity) {
    return SocketRequestHelper.mutation<SeparationUserSectorModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationUserSectorModel.fromJson,
    );
  }

  @override
  Future<List<SeparationUserSectorModel>> update(SeparationUserSectorModel entity) {
    return SocketRequestHelper.mutation<SeparationUserSectorModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationUserSectorModel.fromJson,
    );
  }

  @override
  Future<List<SeparationUserSectorModel>> delete(SeparationUserSectorModel entity) {
    return SocketRequestHelper.mutation<SeparationUserSectorModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: SeparationUserSectorModel.fromJson,
    );
  }
}
