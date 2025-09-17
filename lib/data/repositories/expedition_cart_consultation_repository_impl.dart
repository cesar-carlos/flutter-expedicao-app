import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';

import 'package:exp/core/errors/app_error.dart';
import 'package:exp/domain/models/pagination/query_builder.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/repositories/expedition_cart_consultation_repository.dart';
import 'package:exp/data/dtos/send_query_socket_dto.dart';
import 'package:exp/core/network/socket_config.dart';

class ExpeditionCartConsultationRepositoryImpl implements ExpeditionCartConsultationRepository {
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

          final list = data.map<ExpeditionCartConsultationModel>((json) {
            return ExpeditionCartConsultationModel.fromJson(json);
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

  /// Busca um carrinho específico pelo código de barras
  @override
  Future<ExpeditionCartConsultationModel?> getCartByBarcode({
    required int codEmpresa,
    required String codigoBarras,
  }) async {
    try {
      final queryBuilder = QueryBuilder()
        ..addParam('CodEmpresa', codEmpresa)
        ..addParam('CodigoBarras', codigoBarras);

      final results = await selectConsultation(queryBuilder);

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw DataError(message: 'Erro ao buscar carrinho: ${e.toString()}');
    }
  }

  /// Busca um carrinho específico pelo código do carrinho
  @override
  Future<ExpeditionCartConsultationModel?> getCartByCode({required int codEmpresa, required int codCarrinho}) async {
    try {
      final queryBuilder = QueryBuilder()
        ..addParam('CodEmpresa', codEmpresa)
        ..addParam('CodCarrinho', codCarrinho);

      final results = await selectConsultation(queryBuilder);

      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      throw DataError(message: 'Erro ao buscar carrinho por código: ${e.toString()}');
    }
  }
}
