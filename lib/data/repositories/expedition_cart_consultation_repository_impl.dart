import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

class ExpeditionCartConsultationRepositoryImpl implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  final uuid = const Uuid();
  var socket = SocketConfig.instance;
  final selectEvent = 'carrinho.consulta';

  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<ExpeditionCartConsultationModel>>();
    final responseId = uuid.v4();

    final send = SendQuerySocketDto(
      session: socket.id!,
      responseIn: responseId,
      where: queryBuilder.buildSqlWhere(),
      pagination: queryBuilder.buildPagination(),
    );

    try {
      if (!SocketConfig.isConnected) {
        throw DataError(message: 'Socket não está conectado');
      }

      socket.emit(event, jsonEncode(send.toJson()));

      socket.on(responseId, (receiver) {
        if (completer.isCompleted) return;

        try {
          final response = jsonDecode(receiver);
          final error = response?['Error'];
          final data = response?['Data'] ?? [];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            socket.off(responseId);
            return;
          }

          final list = data.map<ExpeditionCartConsultationModel>((json) {
            return ExpeditionCartConsultationModel.fromJson(json);
          }).toList();

          completer.complete(list);
          socket.off(responseId);
        } catch (e) {
          completer.completeError(DataError(message: e.toString()));
          socket.off(responseId);
        }
      });

      return completer.future.timeout(
        UIConstants.shortNetworkTimeout,
        onTimeout: () {
          if (completer.isCompleted) return completer.future;

          socket.off(responseId);
          completer.completeError(DataError(message: 'Tempo limite de consulta excedido'));
          return completer.future;
        },
      );
    } catch (e) {
      socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }
}
