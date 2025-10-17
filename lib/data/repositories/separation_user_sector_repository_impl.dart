import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/data/dtos/send_mutation_socket_dto.dart';
import 'package:data7_expedicao/domain/repositories/basic_repository.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_model.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

class SeparationUserSectorRepositoryImpl implements BasicRepository<SeparationUserSectorModel> {
  final selectEvent = 'separar.usuario.setor.select';
  final insertEvent = 'separar.usuario.setor.insert';
  final updateEvent = 'separar.usuario.setor.update';
  final deleteEvent = 'separar.usuario.setor.delete';
  var socket = SocketConfig.instance;
  final uuid = const Uuid();

  @override
  Future<List<SeparationUserSectorModel>> select(QueryBuilder queryBuilder) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<SeparationUserSectorModel>>();
    final responseId = uuid.v4();

    final whereQuery = queryBuilder.buildSqlWhere();
    final paginationQuery = queryBuilder.buildPagination();

    final send = SendQuerySocketDto(
      session: socket.id!,
      responseIn: responseId,
      where: whereQuery.isEmpty ? null : whereQuery,
      pagination: paginationQuery.isEmpty ? null : paginationQuery,
    );

    try {
      socket.emit(event, jsonEncode(send.toJson()));

      socket.on(responseId, (receiver) {
        try {
          final response = jsonDecode(receiver);
          final error = response?['Error'];
          final data = response?['Data'] ?? [];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            return;
          }

          final list = data.map<SeparationUserSectorModel>((json) {
            return SeparationUserSectorModel.fromJson(json);
          }).toList();

          completer.complete(list);
        } catch (e) {
          completer.completeError(DataError(message: e.toString()));
        } finally {
          socket.off(responseId);
        }
      });

      return completer.future;
    } catch (e) {
      socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }

  @override
  Future<List<SeparationUserSectorModel>> insert(SeparationUserSectorModel entity) async {
    final event = '${socket.id} $insertEvent';
    final completer = Completer<List<SeparationUserSectorModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(session: socket.id!, responseIn: responseId, mutation: entity.toJson());

    try {
      socket.emit(event, jsonEncode(send.toJson()));

      socket.on(responseId, (receiver) {
        try {
          final response = jsonDecode(receiver);
          final mutation = response?['Mutation'] ?? [];
          final error = response?['Error'];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            return;
          }

          final list = mutation.map<SeparationUserSectorModel>((json) {
            return SeparationUserSectorModel.fromJson(json);
          }).toList();

          completer.complete(list);
        } catch (e) {
          completer.completeError(DataError(message: e.toString()));
        } finally {
          socket.off(responseId);
        }
      });

      return completer.future;
    } catch (e) {
      socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }

  @override
  Future<List<SeparationUserSectorModel>> update(SeparationUserSectorModel entity) async {
    final event = '${socket.id} $updateEvent';
    final completer = Completer<List<SeparationUserSectorModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(session: socket.id!, responseIn: responseId, mutation: entity.toJson());

    try {
      socket.emit(event, jsonEncode(send.toJson()));

      socket.on(responseId, (receiver) {
        try {
          final response = jsonDecode(receiver);
          final mutation = response?['Mutation'] ?? [];
          final error = response?['Error'];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            return;
          }

          final list = mutation.map<SeparationUserSectorModel>((json) {
            return SeparationUserSectorModel.fromJson(json);
          }).toList();

          completer.complete(list);
        } catch (e) {
          completer.completeError(DataError(message: e.toString()));
        } finally {
          socket.off(responseId);
        }
      });

      return completer.future;
    } catch (e) {
      socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }

  @override
  Future<List<SeparationUserSectorModel>> delete(SeparationUserSectorModel entity) async {
    final event = '${socket.id} $deleteEvent';
    final completer = Completer<List<SeparationUserSectorModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(session: socket.id!, responseIn: responseId, mutation: entity.toJson());

    try {
      socket.emit(event, jsonEncode(send.toJson()));

      socket.on(responseId, (receiver) {
        try {
          final response = jsonDecode(receiver);
          final mutation = response?['Mutation'] ?? [];
          final error = response?['Error'];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            return;
          }

          final list = mutation.map<SeparationUserSectorModel>((json) {
            return SeparationUserSectorModel.fromJson(json);
          }).toList();

          completer.complete(list);
        } catch (e) {
          completer.completeError(DataError(message: e.toString()));
        } finally {
          socket.off(responseId);
        }
      });

      return completer.future;
    } catch (e) {
      socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }
}
