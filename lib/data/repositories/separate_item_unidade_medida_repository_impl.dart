import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';

class SeparateItemUnidadeMedidaRepositoryImpl
    implements BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> {
  final uuid = const Uuid();
  var socket = SocketConfig.instance;
  final selectEvent = 'separar.item.unidade.medida.consulta';

  @override
  Future<List<SeparateItemUnidadeMedidaConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    final event = '${socket.id} $selectEvent';
    final completer = Completer<List<SeparateItemUnidadeMedidaConsultationModel>>();
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

          final list = data.map<SeparateItemUnidadeMedidaConsultationModel>((json) {
            return SeparateItemUnidadeMedidaConsultationModel.fromJson(json);
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
