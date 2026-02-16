import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

class SeparationUserSectorConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  final uuid = const Uuid();
  var socket = SocketConfig.instance;
  final selectEvent = 'separar.usuario.setor.consulta';

  static const Duration _waitBeforeSocketCheck = Duration(milliseconds: 1500);

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    final completer = Completer<List<SeparationUserSectorConsultationModel>>();
    final responseId = uuid.v4();

    try {
      if (!SocketConfig.isConnected) {
        await Future.delayed(_waitBeforeSocketCheck);
        if (!SocketConfig.isConnected) {
          throw DataError(message: 'Socket não está conectado');
        }
      }

      socket = SocketConfig.instance;
      final event = '${socket.id} $selectEvent';
      final send = SendQuerySocketDto(
        session: socket.id!,
        responseIn: responseId,
        where: queryBuilder.buildSqlWhere(),
        pagination: queryBuilder.buildPagination(),
        orderBy: queryBuilder.buildOrderByQuery(),
      );

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

          final list = data.map<SeparationUserSectorConsultationModel>((json) {
            return SeparationUserSectorConsultationModel.fromJson(json);
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
      if (e is DataError) rethrow;
      throw DataError(message: e.toString());
    }
  }
}
