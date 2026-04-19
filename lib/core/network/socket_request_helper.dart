import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:uuid/uuid.dart';

import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/data/dtos/send_mutation_socket_dto.dart';
import 'package:data7_expedicao/data/dtos/send_query_socket_dto.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';

/// Helper para encapsular o padrao socket-completer-on usado em ~30
/// repositorios.
///
/// Mitiga 4 bugs latentes presentes em todos os repos socket-based:
///
/// - **AAAAAA — TIMEOUT AUSENTE**: a versao manual nao tinha timeout.
///   Se o servidor nunca respondesse, o future ficava pendente PARA
///   SEMPRE (UI em loading eterno). Aqui usamos `Future.timeout` com
///   default de 30s — caller pode ajustar via parametro.
///
/// - **BBBBBB — `socket.id!` antes do check `isConnected`**: a versao
///   manual fazia null assertion ANTES de validar conexao, causando
///   `NullCheckOperator` em vez do erro tratado. Aqui validamos `id`
///   primeiro e lancamos `DataError` claro se faltar.
///
/// - **CCCCCC — stale reference**: a versao manual capturava
///   `var socket = SocketConfig.instance` no campo da classe, que
///   ficava obsoleto apos `updateConfig` recriar o socket. Aqui
///   sempre usamos `SocketConfig.instance` (getter) — pega a
///   instancia atual a cada chamada.
///
/// - **DDDDDD — cast inseguro em mutation/data**: a versao manual fazia
///   `mutation.map<T>(...)` direto. Se o servidor retornasse Map em vez
///   de List (formato inesperado), crashava com TypeError em vez de
///   DataError tratado. Aqui validamos com `is List` antes do cast.
///
/// Uso tipico (em qualquer repositorio):
/// ```dart
/// @override
/// Future<List<MyModel>> select(QueryBuilder qb) {
///   return SocketRequestHelper.select<MyModel>(
///     baseEvent: 'minha_entidade.select',
///     queryBuilder: qb,
///     fromJson: MyModel.fromJson,
///   );
/// }
/// ```
class SocketRequestHelper {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const _uuid = Uuid();

  /// Timeout configuravel via locator/test override (futuro).
  /// Mantido como const para o caso atual; se precisarmos injetar via
  /// DI no futuro, basta tornar instance method.
  static Duration get defaultTimeout => _defaultTimeout;

  /// Executa um SELECT socket-based padrao.
  ///
  /// - [baseEvent]: nome do evento sem o prefixo de session (ex.: 'separar.select').
  ///   O helper prefixa com `${socket.id} ` automaticamente.
  /// - [queryBuilder]: QueryBuilder ja configurado pelo caller.
  /// - [fromJson]: factory que converte 1 entry do array `Data` em `T`.
  /// - [timeout]: timeout customizado (default 30s).
  static Future<List<T>> select<T>({
    required String baseEvent,
    required QueryBuilder queryBuilder,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
    bool includeOrderBy = false,
  }) async {
    final whereQuery = queryBuilder.buildSqlWhere();
    final paginationQuery = queryBuilder.buildPagination();
    // Bug observado: alguns repos (SeparationUserSectorConsultation,
    // SeparateProgressConsultation) tambem enviam `orderBy`. Tornamos
    // opcional via flag para preservar comportamento existente sem
    // adicionar overhead nos repos que nao precisam.
    final orderByQuery = includeOrderBy ? queryBuilder.buildOrderByQuery() : '';

    return _execute<T>(
      baseEvent: baseEvent,
      buildPayload: (sessionId, responseId) {
        final dto = SendQuerySocketDto(
          session: sessionId,
          responseIn: responseId,
          where: whereQuery.isEmpty ? null : whereQuery,
          pagination: paginationQuery.isEmpty ? null : paginationQuery,
          orderBy: orderByQuery.isEmpty ? null : orderByQuery,
        );
        return jsonEncode(dto.toJson());
      },
      extractList: extractDataList,
      fromJson: fromJson,
      timeout: timeout,
    );
  }

  /// Executa uma MUTATION socket-based padrao (insert / update / delete).
  ///
  /// - [baseEvent]: nome do evento (ex.: 'separar.insert').
  /// - [entityJson]: JSON da entidade a enviar como mutation.
  /// - [fromJson]: factory para converter cada item do array `Mutation` em `T`.
  static Future<List<T>> mutation<T>({
    required String baseEvent,
    required Map<String, dynamic> entityJson,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
  }) async {
    return _execute<T>(
      baseEvent: baseEvent,
      buildPayload: (sessionId, responseId) {
        final dto = SendMutationSocketDto(
          session: sessionId,
          responseIn: responseId,
          mutation: entityJson,
        );
        return jsonEncode(dto.toJson());
      },
      extractList: extractMutationList,
      fromJson: fromJson,
      timeout: timeout,
    );
  }

  /// Implementacao comum para select/mutation. Mantida privada porque
  /// o nome do array de resposta varia (`Data` vs `Mutation`) e e
  /// abstraida via [extractList].
  static Future<List<T>> _execute<T>({
    required String baseEvent,
    required String Function(String sessionId, String responseId) buildPayload,
    required List Function(Map<String, dynamic> response) extractList,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? timeout,
  }) async {
    // Bug BBBBBB: validar conexao + sessao ANTES de qualquer null
    // assertion. socket.id! seguido de socket.connected era ordem
    // errada — desconectado dava NPE feio.
    if (!SocketConfig.isConnected) {
      throw DataError(message: 'Socket nao esta conectado');
    }
    final sessionId = SocketConfig.sessionId;
    if (sessionId == null || sessionId.isEmpty) {
      throw DataError(message: 'Socket sem session id (nao identificado pelo servidor)');
    }

    // Bug CCCCCC: usar SocketConfig.instance (getter) em vez de
    // capturar referencia. Se updateConfig recriou o socket, pegamos
    // o novo automaticamente.
    final socket = SocketConfig.instance;
    final responseId = _uuid.v4();
    final event = '$sessionId $baseEvent';
    final completer = Completer<List<T>>();

    void completeOnce(FutureOr<void> Function() action) {
      if (completer.isCompleted) return;
      try {
        action();
      } catch (e, s) {
        if (!completer.isCompleted) {
          completer.completeError(DataError(message: e.toString(), stackTrace: s));
        }
      }
    }

    // Registra o listener ANTES do emit para nao perder respostas
    // muito rapidas (race entre emit ack e on).
    socket.on(responseId, (dynamic receiver) {
      completeOnce(() {
        final response = decodeResponse(receiver);
        final error = response['Error'];
        if (error != null) {
          if (!completer.isCompleted) {
            completer.completeError(DataError(message: error.toString()));
          }
          return;
        }
        // Bug DDDDDD: extractList + parseItems validam tipo e ignoram
        // items invalidos com log (em vez de crashar lista inteira).
        final rawList = extractList(response);
        final result = parseItems<T>(rawList, fromJson);
        if (!completer.isCompleted) completer.complete(result);
      });
    });

    try {
      socket.emit(event, buildPayload(sessionId, responseId));
    } catch (e, s) {
      // Garante limpeza do listener mesmo se o emit falhar.
      socket.off(responseId);
      throw DataError(message: 'Falha ao emitir evento $event: $e', stackTrace: s);
    }

    // Bug AAAAAA: timeout. Antes, future ficava pendente para sempre
    // se o servidor nao respondesse.
    final effectiveTimeout = timeout ?? _defaultTimeout;
    try {
      return await completer.future.timeout(
        effectiveTimeout,
        onTimeout: () {
          throw DataError(
            message: 'Tempo limite excedido ($effectiveTimeout) ao aguardar resposta de $baseEvent',
          );
        },
      );
    } finally {
      // Sempre desregistra o listener — evita memory leak / callbacks
      // duplicados em chamadas subsequentes.
      socket.off(responseId);
    }
  }

  /// Decodifica a resposta vinda do socket. Aceita tanto String JSON
  /// quanto Map ja decodificado (alguns transports do socket.io entregam
  /// um, outros outro). Lanca FormatException em formato invalido.
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

  /// Extrai a lista de uma resposta de SELECT (chave "Data").
  @visibleForTesting
  static List extractDataList(Map<String, dynamic> response) {
    final data = response['Data'];
    if (data == null) return const [];
    if (data is! List) {
      throw FormatException('Campo "Data" da resposta nao e List: ${data.runtimeType}');
    }
    return data;
  }

  /// Extrai a lista de uma resposta de MUTATION (chave "Mutation").
  @visibleForTesting
  static List extractMutationList(Map<String, dynamic> response) {
    final mutation = response['Mutation'];
    if (mutation == null) return const [];
    if (mutation is! List) {
      throw FormatException('Campo "Mutation" da resposta nao e List: ${mutation.runtimeType}');
    }
    return mutation;
  }

  /// Parse defensivo de um item da lista — pula items invalidos com log.
  /// Exposto para testes; chamado internamente por [_execute].
  @visibleForTesting
  static List<T> parseItems<T>(
    List rawList,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final result = <T>[];
    for (var i = 0; i < rawList.length; i++) {
      final entry = rawList[i];
      if (entry is! Map) {
        AppLogger.warning(
          'SocketRequestHelper: item $i da resposta nao e Map (${entry.runtimeType}) — ignorado',
          tag: 'SocketRequestHelper',
        );
        continue;
      }
      try {
        result.add(fromJson(Map<String, dynamic>.from(entry)));
      } catch (e, s) {
        AppLogger.warning(
          'SocketRequestHelper: falha ao parsear item $i — ignorado',
          tag: 'SocketRequestHelper',
          error: e,
          stackTrace: s,
        );
      }
    }
    return result;
  }
}

