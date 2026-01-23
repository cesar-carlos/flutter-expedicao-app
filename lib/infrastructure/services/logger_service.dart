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

  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.fine(message, error, stackTrace);
  }

  @override
  void info(String message, {String? tag}) {
    _logger.info(message);
  }

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.warning(message, error, stackTrace);
  }

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.severe(message, error, stackTrace);
  }

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _logger.shout(message, error, stackTrace);
  }
}
