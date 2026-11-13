import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/errors/socket_error_parser.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/network/socket_ready_gate.dart';
import 'package:data7_expedicao/data/dtos/send_mutation_socket_dto.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/paged_query.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

/// Helper para encapsular o padrao socket-completer-on usado em ~30
/// repositorios.
class SocketRequestHelper {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const _uuid = Uuid();
  static const String lostConnectionMessage = 'Conexão com o servidor foi perdida. Tente novamente.';
  static const String disconnectedMessage = 'Socket nao esta conectado';

  /// `fromJson` cede um frame a cada N itens para o spinner continuar.
  @visibleForTesting
  static const int parseYieldEvery = 20;

  @visibleForTesting
  static SocketReadyGate readyGate = SocketReadyGate.forConfig();

  static Duration get defaultTimeout => _defaultTimeout;

  /// Executa um SELECT socket-based padrao.
  ///
  /// Sem `allRows()`, uma ida só — lookup ou página explícita. Com
  /// `allRows()`, busca a lista em páginas de [Pagination.fetchPageSize]
  /// para o servidor não cortar em 1500 nem travar a fila num JSON só.
  static Future<List<T>> select<T>({
    required String baseEvent,
    required QueryBuilder queryBuilder,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
    bool includeOrderBy = false,
    dynamic socket,
  }) async {
    if (!queryBuilder.shouldFetchAllPages) {
      return _selectPage(
        baseEvent: baseEvent,
        queryBuilder: queryBuilder,
        fromJson: fromJson,
        timeout: timeout,
        includeOrderBy: includeOrderBy,
        pagination: queryBuilder.buildPagination(),
        socket: socket,
      );
    }

    try {
      return await PagedQuery.collect(
        pageSize: queryBuilder.fetchAllPages ? queryBuilder.fetchPageSize : Pagination.fetchPageSize,
        fetchPage: (page, pageSize) {
          return _selectPage(
            baseEvent: baseEvent,
            queryBuilder: queryBuilder,
            fromJson: fromJson,
            timeout: timeout,
            includeOrderBy: includeOrderBy || queryBuilder.fetchAllPages || queryBuilder.orderByClauses.isNotEmpty,
            pagination: Pagination.page(page: page, pageSize: pageSize).toQueryString(),
            socket: socket,
          );
        },
      );
    } on StateError catch (e) {
      throw DataError(message: e.message);
    }
  }

  static Future<List<T>> _selectPage<T>({
    required String baseEvent,
    required QueryBuilder queryBuilder,
    required T Function(Map<String, dynamic>) fromJson,
    required bool includeOrderBy,
    required String pagination,
    Duration? timeout,
    dynamic socket,
  }) {
    final whereQuery = queryBuilder.buildWhereParams();
    final orderByQuery = includeOrderBy ? queryBuilder.buildOrderByQuery() : '';

    return _execute<T>(
      baseEvent: baseEvent,
      buildPayload: (sessionId, responseId) {
        final dto = SendQuerySocketDto(
          session: sessionId,
          responseIn: responseId,
          where: whereQuery,
          pagination: pagination.isEmpty ? null : pagination,
          orderBy: orderByQuery.isEmpty ? null : orderByQuery,
        );
        return jsonEncode(dto.toJson());
      },
      extractList: extractDataList,
      fromJson: fromJson,
      timeout: timeout,
      socket: socket,
    );
  }

  /// Executa uma MUTATION socket-based padrao (insert / update / delete).
  static Future<List<T>> mutation<T>({
    required String baseEvent,
    required Map<String, dynamic> entityJson,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
    dynamic socket,
  }) async {
    return _execute<T>(
      baseEvent: baseEvent,
      buildPayload: (sessionId, responseId) {
        final dto = SendMutationSocketDto(session: sessionId, responseIn: responseId, mutation: entityJson);
        return jsonEncode(dto.toJson());
      },
      extractList: extractMutationList,
      fromJson: fromJson,
      timeout: timeout,
      socket: socket,
    );
  }

  static Future<List<T>> _execute<T>({
    required String baseEvent,
    required String Function(String sessionId, String responseId) buildPayload,
    required List<dynamic> Function(Map<String, dynamic> response) extractList,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
    dynamic socket,
  }) async {
    ensureTrafficAllowed();
    final resolved = await _resolveSocket(socket);
    final activeSocket = resolved.socket;
    final sessionId = resolved.sessionId;
    final watchDisconnect = resolved.watchDisconnect;

    final responseId = _uuid.v4();
    final event = '$sessionId $baseEvent';
    final completer = Completer<List<T>>();

    void completeOnce(void Function() action) {
      if (completer.isCompleted) {
        return;
      }
      try {
        action();
      } catch (e, s) {
        if (!completer.isCompleted) {
          completer.completeError(DataError(message: e.toString(), stackTrace: s));
        }
      }
    }

    void onDisconnected() {
      completeOnce(() {
        completer.completeError(DataError(message: lostConnectionMessage));
      });
    }

    activeSocket.on(responseId, (dynamic receiver) {
      if (completer.isCompleted) {
        return;
      }
      unawaited(
        _completeParsedResponse(completer: completer, receiver: receiver, extractList: extractList, fromJson: fromJson),
      );
    });

    if (watchDisconnect) {
      SocketConfig.addDisconnectListener(onDisconnected);
    }

    try {
      activeSocket.emit(event, buildPayload(sessionId, responseId));
    } catch (e, s) {
      activeSocket.off(responseId);
      if (watchDisconnect) {
        SocketConfig.removeDisconnectListener(onDisconnected);
      }
      throw DataError(message: 'Falha ao emitir evento $event: $e', stackTrace: s);
    }

    final effectiveTimeout = timeout ?? _defaultTimeout;
    try {
      return await completer.future.timeout(
        effectiveTimeout,
        onTimeout: () {
          throw DataError(message: 'Tempo limite excedido ($effectiveTimeout) ao aguardar resposta de $baseEvent');
        },
      );
    } finally {
      activeSocket.off(responseId);
      if (watchDisconnect) {
        SocketConfig.removeDisconnectListener(onDisconnected);
      }
    }
  }

  @visibleForTesting
  static void ensureTrafficAllowed() {
    if (SocketConfig.isTrafficBlocked) {
      throw DataError(message: SocketConfig.sessionEndedMessage);
    }
  }

  static Future<({dynamic socket, String sessionId, bool watchDisconnect})> _resolveSocket(dynamic socket) async {
    ensureTrafficAllowed();
    if (socket != null) {
      final sessionId = socket.id?.toString();
      if (sessionId == null || sessionId.isEmpty) {
        throw DataError(message: 'Sessão com o servidor não identificada. Reconecte e tente novamente.');
      }
      return (socket: socket, sessionId: sessionId, watchDisconnect: false);
    }

    try {
      await readyGate.ensureReady();
    } catch (e, s) {
      if (SocketConfig.isTrafficBlocked) {
        throw DataError(message: SocketConfig.sessionEndedMessage, stackTrace: s);
      }
      throw DataError(message: disconnectedMessage, stackTrace: s);
    }

    final sessionId = SocketConfig.sessionId;
    if (!SocketConfig.isConnected || sessionId == null || sessionId.isEmpty) {
      throw DataError(message: disconnectedMessage);
    }
    return (socket: SocketConfig.instance, sessionId: sessionId, watchDisconnect: true);
  }

  static DataError? dataErrorFromResponse(Map<String, dynamic> response) {
    final info = SocketErrorInfo.fromResponse(response);
    if (info == null) {
      return null;
    }
    return DataError(
      message: info.message,
      code: info.identifier ?? info.contractCode,
      requestId: info.requestId,
      details: info.details,
    );
  }

  static Future<void> _completeParsedResponse<T>({
    required Completer<List<T>> completer,
    required dynamic receiver,
    required List<dynamic> Function(Map<String, dynamic> response) extractList,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await decodeResponseAsync(receiver);
      if (completer.isCompleted) {
        return;
      }
      final socketError = dataErrorFromResponse(response);
      if (socketError != null) {
        completer.completeError(socketError);
        return;
      }
      final rawList = extractList(response);
      final result = await parseItemsAsync<T>(rawList, fromJson);
      if (!completer.isCompleted) {
        completer.complete(result);
      }
    } catch (e, s) {
      if (!completer.isCompleted) {
        completer.completeError(DataError(message: e.toString(), stackTrace: s));
      }
    }
  }

  /// Cede um frame e decodifica no isolate de UI.
  ///
  @visibleForTesting
  static Future<Map<String, dynamic>> decodeResponseAsync(dynamic receiver) async {
    await Future<void>.delayed(Duration.zero);
    return decodeResponse(receiver);
  }

  @visibleForTesting
  static Map<String, dynamic> decodeResponse(dynamic receiver) {
    if (receiver is String) {
      final decoded = jsonDecode(receiver);
      if (decoded is! Map) {
        throw FormatException('Resposta socket nao e Map: ${decoded.runtimeType}');
      }
      return Map<String, dynamic>.from(decoded);
    }
    if (receiver is Map) {
      return Map<String, dynamic>.from(receiver);
    }
    throw FormatException('Resposta socket inesperada: ${receiver.runtimeType}');
  }

  @visibleForTesting
  static List<dynamic> extractDataList(Map<String, dynamic> response) {
    final data = response['Data'];
    if (data == null) {
      return const [];
    }
    if (data is! List) {
      throw FormatException('Campo "Data" da resposta nao e List: ${data.runtimeType}');
    }
    return data;
  }

  @visibleForTesting
  static List<dynamic> extractMutationList(Map<String, dynamic> response) {
    final mutation = response['Mutation'];
    if (mutation == null) {
      return const [];
    }
    if (mutation is! List) {
      throw FormatException('Campo "Mutation" da resposta nao e List: ${mutation.runtimeType}');
    }
    return mutation;
  }

  /// Parse de um item da lista. Item inválido falha a consulta inteira
  /// para o operador não trabalhar com lista incompleta.
  static List<T> parseItems<T>(List<dynamic> rawList, T Function(Map<String, dynamic>) fromJson) {
    final result = <T>[];
    for (var i = 0; i < rawList.length; i++) {
      result.add(_parseItem(rawList, i, fromJson));
    }
    return result;
  }

  /// Igual a [parseItems], cedendo a UI entre blocos.
  @visibleForTesting
  static Future<List<T>> parseItemsAsync<T>(List<dynamic> rawList, T Function(Map<String, dynamic>) fromJson) async {
    await Future<void>.delayed(Duration.zero);
    if (rawList.length <= parseYieldEvery) {
      return parseItems(rawList, fromJson);
    }

    final result = <T>[];
    for (var i = 0; i < rawList.length; i++) {
      result.add(_parseItem(rawList, i, fromJson));
      if ((i + 1) % parseYieldEvery == 0 && i + 1 < rawList.length) {
        await Future<void>.delayed(Duration.zero);
      }
    }
    return result;
  }

  static T _parseItem<T>(List<dynamic> rawList, int index, T Function(Map<String, dynamic>) fromJson) {
    final entry = rawList[index];
    if (entry is! Map) {
      throw DataError(message: 'Resposta do servidor inválida: item ${index + 1} não pôde ser lido.');
    }
    try {
      return fromJson(Map<String, dynamic>.from(entry));
    } catch (e, s) {
      throw DataError(message: 'Resposta do servidor inválida: item ${index + 1} não pôde ser lido.', stackTrace: s);
    }
  }
}
