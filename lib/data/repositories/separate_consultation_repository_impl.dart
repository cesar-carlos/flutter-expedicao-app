import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';
import 'package:exp/data/dtos/send_query_socket_dto.dart';
import 'package:exp/core/network/socket_config.dart';

class SeparateConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparateConsultationModel> {
  final uuid = const Uuid();
  var socket = SocketConfig.instance;
  final selectEvent = 'separar.consulta';

  @override
  Future<List<SeparateConsultationModel>> selectConsultation(
    QueryBuilder queryBuilder,
  ) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<SeparateConsultationModel>>();
    final responseId = uuid.v4();

    final send = SendQuerySocketDto(
      session: socket.id!,
      responseIn: responseId,
      where: queryBuilder.buildQuery(),
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

          final list = data.map<SeparateConsultationModel>((json) {
            return SeparateConsultationModel.fromJson(json);
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
