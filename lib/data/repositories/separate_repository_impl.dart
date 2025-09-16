import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/data/dtos/send_query_socket_dto.dart';
import 'package:exp/data/dtos/send_mutation_socket_dto.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/core/network/socket_config.dart';

class SeparateRepositoryImpl implements BasicRepository<SeparateModel> {
  final selectEvent = 'separar.select';
  final insertEvent = 'separar.insert';
  final updateEvent = 'separar.update';
  final deleteEvent = 'separar.delete';
  var socket = SocketConfig.instance;
  final uuid = const Uuid();

  @override
  Future<List<SeparateModel>> select(QueryBuilder queryBuilder) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<SeparateModel>>();
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

          final list = data.map<SeparateModel>((json) {
            return SeparateModel.fromJson(json);
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
  Future<List<SeparateModel>> insert(SeparateModel entity) async {
    final event = '${socket.id} $insertEvent';
    final completer = Completer<List<SeparateModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(
      session: socket.id!,
      responseIn: responseId,
      mutation: entity.toJson(),
    );

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

          final list = mutation.map<SeparateModel>((json) {
            return SeparateModel.fromJson(json);
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
  Future<List<SeparateModel>> update(SeparateModel entity) async {
    final event = '${socket.id} $updateEvent';
    final completer = Completer<List<SeparateModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(
      session: socket.id!,
      responseIn: responseId,
      mutation: entity.toJson(),
    );

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

          final list = mutation.map<SeparateModel>((json) {
            return SeparateModel.fromJson(json);
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
  Future<List<SeparateModel>> delete(SeparateModel entity) async {
    final event = '${socket.id} $deleteEvent';
    final completer = Completer<List<SeparateModel>>();
    final responseId = uuid.v4();

    final send = SendMutationSocketDto(
      session: socket.id!,
      responseIn: responseId,
      mutation: entity.toJson(),
    );

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

          final list = mutation.map<SeparateModel>((json) {
            return SeparateModel.fromJson(json);
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
