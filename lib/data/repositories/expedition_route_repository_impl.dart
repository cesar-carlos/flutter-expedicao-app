import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/data/dtos/send_mutation_socket_dto.dart';
import 'package:exp/domain/repositories/basic_repository.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/expedition_cart_route_model.dart';
import 'package:exp/data/dtos/send_query_socket_dto.dart';
import 'package:exp/core/network/socket_config.dart';

class ExpeditionRouteRepositoryImpl
    implements BasicRepository<ExpeditionCartRouteModel> {
  final selectEvent = 'carrinho.percurso.select';
  final insertEvent = 'carrinho.percurso.insert';
  final updateEvent = 'carrinho.percurso.update';
  final deleteEvent = 'carrinho.percurso.delete';
  var socket = SocketConfig.instance;
  final uuid = const Uuid();

  @override
  Future<List<ExpeditionCartRouteModel>> select(
    QueryBuilder queryBuilder,
  ) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<ExpeditionCartRouteModel>>();
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

          final list = data.map<ExpeditionCartRouteModel>((json) {
            return ExpeditionCartRouteModel.fromJson(json);
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
  Future<List<ExpeditionCartRouteModel>> insert(
    ExpeditionCartRouteModel entity,
  ) async {
    final event = '${socket.id} $insertEvent';
    final completer = Completer<List<ExpeditionCartRouteModel>>();
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

          final list = mutation.map<ExpeditionCartRouteModel>((json) {
            return ExpeditionCartRouteModel.fromJson(json);
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
  Future<List<ExpeditionCartRouteModel>> update(
    ExpeditionCartRouteModel entity,
  ) async {
    final event = '${socket.id} $updateEvent';
    final completer = Completer<List<ExpeditionCartRouteModel>>();
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

          final list = mutation.map<ExpeditionCartRouteModel>((json) {
            return ExpeditionCartRouteModel.fromJson(json);
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
  Future<List<ExpeditionCartRouteModel>> delete(
    ExpeditionCartRouteModel entity,
  ) async {
    final event = '${socket.id} $deleteEvent';
    final completer = Completer<List<ExpeditionCartRouteModel>>();
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

          final list = mutation.map<ExpeditionCartRouteModel>((json) {
            return ExpeditionCartRouteModel.fromJson(json);
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
