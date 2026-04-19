import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_internship_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de ExpeditionInternshipModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionInternshipRepositoryImpl implements BasicRepository<ExpeditionInternshipModel> {
  static const String _selectEvent = 'expedicao.percurso.estagio.select';
  static const String _insertEvent = 'expedicao.percurso.estagio.insert';
  static const String _updateEvent = 'expedicao.percurso.estagio.update';
  static const String _deleteEvent = 'expedicao.percurso.estagio.delete';

  @override
  Future<List<ExpeditionInternshipModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionInternshipModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionInternshipModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionInternshipModel>> insert(ExpeditionInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionInternshipModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionInternshipModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionInternshipModel>> update(ExpeditionInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionInternshipModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionInternshipModel.fromJson,
    );
  }

  @override
  Future<List<ExpeditionInternshipModel>> delete(ExpeditionInternshipModel entity) {
    return SocketRequestHelper.mutation<ExpeditionInternshipModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: ExpeditionInternshipModel.fromJson,
    );
  }
}
