import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/utils/i_logger.dart';

class LoggerService implements ILogger {
  final Logger _logger;

  LoggerService({String? name}) : _logger = Logger(name ?? 'Data7Expedicao');

  static void initialize({Level level = Level.ALL}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        final levelEmoji = _getLevelEmoji(record.level);
        final tag = record.loggerName != 'Data7Expedicao' ? '[${record.loggerName}]' : '';

        debugPrint('$levelEmoji$tag ${record.message}');

        if (record.error != null) {
          debugPrint('💥 Erro: ${record.error}');
        }

        if (record.stackTrace != null) {
          debugPrint('📍 Stack: ${record.stackTrace}');
        }
      }
    });
  }

  static String _getLevelEmoji(Level level) {
    if (level.value >= Level.SEVERE.value) return '🔴';
    if (level.value >= Level.WARNING.value) return '⚠️';
    if (level.value >= Level.INFO.value) return 'ℹ️';
    return '🔵';
  }

  /// Bug latente anterior: o parametro `tag` era IGNORADO em `info`
  /// e `debug` (chamadas `_logger.info(message)` sem prefixo). Outros
  /// metodos passavam apenas `(message, error, stackTrace)` ao Logger
  /// — o tag tambem nao chegava no output (o package `logging` so
  /// usa o nome do `Logger` em si). Isso significava que callers
  /// passando tag esperando rastrear origem nao recebiam essa info
  /// em logs. Agora o tag e prefixado em todas as 5 funcoes.
  String _format(String message, String? tag) {
    if (tag == null || tag.isEmpty) return message;
    return '[$tag] $message';
  }

  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.fine(_format(message, tag), error, stackTrace);
  }

  @override
  void info(String message, {String? tag}) {
    _logger.info(_format(message, tag));
  }

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.warning(_format(message, tag), error, stackTrace);
  }

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.severe(_format(message, tag), error, stackTrace);
  }

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.shout(_format(message, tag), error, stackTrace);
  }
}
