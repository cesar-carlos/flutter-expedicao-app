import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

class ExpeditionItemPrintConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionItemPrintConsultationModel> {
  final Uuid _uuid;
  final dynamic _socket;
  final Duration _responseTimeout;
  final selectEvent = 'separar.estoque.item.impresso.consulta';

  ExpeditionItemPrintConsultationRepositoryImpl({
    Uuid? uuid,
    dynamic socket,
    Duration responseTimeout = const Duration(seconds: 12),
  }) : _uuid = uuid ?? const Uuid(),
       _socket = socket ?? SocketConfig.instance,
       _responseTimeout = responseTimeout;

  @override
  Future<List<ExpeditionItemPrintConsultationModel>> selectConsultation(QueryBuilder queryBuilder) async {
    final sessionId = _socket.id?.toString();
    if (sessionId == null || sessionId.isEmpty) {
      throw DataError(message: 'Sessao de socket indisponivel para consulta de impressao.');
    }

    final event = '$sessionId $selectEvent';
    final completer = Completer<List<ExpeditionItemPrintConsultationModel>>();
    final responseId = _uuid.v4();

    final send = SendQuerySocketDto(
      session: sessionId,
      responseIn: responseId,
      where: queryBuilder.buildSqlWhere(),
      pagination: queryBuilder.buildPagination(),
      orderBy: queryBuilder.buildOrderByQuery(),
    );

    try {
      // Nota: nao consultamos SocketConfig.isConnected aqui (era um leak da
      // singleton global que quebrava testes com socket injetado e tambem
      // era redundante: a indisponibilidade real ja eh coberta pela checagem
      // de sessionId acima e pelo `responseTimeout` abaixo).
      _socket.on(responseId, (receiver) {
        try {
          if (completer.isCompleted) {
            return;
          }

          final response = receiver is String ? jsonDecode(receiver) : receiver;
          final error = response?['Error'];
          final data = response?['Data'];

          if (error != null) {
            completer.completeError(DataError(message: error.toString()));
            return;
          }

          // Bug DDDDDD: parsing defensivo item-por-item (mesma protecao
          // do SocketRequestHelper, mas mantendo a estrutura especial
          // deste repo com socket injetado para testes).
          if (data == null) {
            completer.complete(const []);
            return;
          }
          if (data is! List) {
            completer.completeError(
              DataError(message: 'Campo "Data" da resposta nao e List: ${data.runtimeType}'),
            );
            return;
          }
          final list = SocketRequestHelper.parseItems<ExpeditionItemPrintConsultationModel>(
            data,
            ExpeditionItemPrintConsultationModel.fromJson,
          );

          completer.complete(list);
        } catch (e) {
          if (!completer.isCompleted) {
            completer.completeError(DataError(message: e.toString()));
          }
        } finally {
          _socket.off(responseId);
        }
      });

      _socket.emit(event, jsonEncode(send.toJson()));

      return completer.future.timeout(
        _responseTimeout,
        onTimeout: () {
          _socket.off(responseId);
          throw DataError(
            message: 'Timeout aguardando retorno da consulta de impressao em ${_responseTimeout.inSeconds}s.',
          );
        },
      );
    } on DataError {
      _socket.off(responseId);
      rethrow;
    } catch (e) {
      _socket.off(responseId);
      throw DataError(message: e.toString());
    }
  }
}
