import 'package:data7_expedicao/core/utils/i_logger.dart';

class NoOpLogger implements ILogger {
  const NoOpLogger();

  @override
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message, {String? tag}) {}

  @override
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}

  @override
  void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {}
}
