import 'dart:developer' as developer;

import 'package:data7_expedicao/core/utils/i_logger.dart';

final class DeveloperLogger implements ILogger {
  const DeveloperLogger();

  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(message, 500, tag, error, stackTrace);

  @override
  void info(String message, {String? tag}) => _log(message, 800, tag, null, null);

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(message, 900, tag, error, stackTrace);

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(message, 1000, tag, error, stackTrace);

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) =>
      _log(message, 1200, tag, error, stackTrace);

  void _log(String message, int level, String? tag, Object? error, StackTrace? stackTrace) {
    developer.log(message, name: tag ?? 'Data7Expedicao', level: level, error: error, stackTrace: stackTrace);
  }
}
