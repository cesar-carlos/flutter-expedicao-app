import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';

/// Repositorio de SeparateModel usando socket.io.
///
/// Refatoracao: a versao anterior tinha 4 metodos quase identicos
/// (~210 linhas total) com padrao manual de socket-completer. Agora
/// delega tudo para [SocketRequestHelper] que mitiga 4 bugs latentes
/// (timeout ausente, null assertion errada, stale reference, casts
/// inseguros) — ver doc do helper para detalhes.
///
/// Codigo reduziu de ~210 para ~30 linhas, com comportamento MAIS
/// robusto (timeout de 30s + parsing defensivo + log de items
/// invalidos).
class SeparateRepositoryImpl implements BasicRepository<SeparateModel> {
  static const String _selectEvent = 'separar.select';
  static const String _insertEvent = 'separar.insert';
  static const String _updateEvent = 'separar.update';
  static const String _deleteEvent = 'separar.delete';

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateModel.fromJson,
    );
  }

  @override
  Future<List<SeparateModel>> insert(SeparateModel entity) {
    return SocketRequestHelper.mutation<SeparateModel>(
      baseEvent: _insertEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateModel.fromJson,
    );
  }

  @override
  Future<List<SeparateModel>> update(SeparateModel entity) {
    return SocketRequestHelper.mutation<SeparateModel>(
      baseEvent: _updateEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateModel.fromJson,
    );
  }

  @override
  Future<List<SeparateModel>> delete(SeparateModel entity) {
    return SocketRequestHelper.mutation<SeparateModel>(
      baseEvent: _deleteEvent,
      entityJson: entity.toJson(),
      fromJson: SeparateModel.fromJson,
    );
  }
}
