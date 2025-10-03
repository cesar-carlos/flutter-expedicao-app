import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/data/dtos/send_query_socket_dto.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/domain/models/expedition_check_item_consultation_model.dart';
import 'package:exp/core/network/socket_config.dart';

class ExpeditionCheckItemConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCheckItemConsultationModel> {
  final uuid = const Uuid();
  var socket = SocketConfig.instance;
  final selectEvent = 'conferir.item.consulta';

  @override
  Future<List<ExpeditionCheckItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<ExpeditionCheckItemConsultationModel>>();
    final responseId = uuid.v4();

    final send = SendQuerySocketDto(
      session: socket.id!,
      responseIn: responseId,
      where: queryBuilder.buildSqlWhere(),
      pagination: queryBuilder.buildPagination(),
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

          final list = data.map<ExpeditionCheckItemConsultationModel>((json) {
            return ExpeditionCheckItemConsultationModel.fromJson(json);
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
