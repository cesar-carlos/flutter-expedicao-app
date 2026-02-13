import 'package:data7_expedicao/core/utils/i_logger.dart';
import 'package:data7_expedicao/core/utils/no_op_logger.dart';
import 'package:data7_expedicao/di/locator.dart';

class AppLogger {
  static ILogger? _logger;

  static ILogger get _instance {
    _logger ??= locator.isRegistered<ILogger>() ? locator<ILogger>() : const NoOpLogger();
    return _logger!;
  }

  static void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance.debug(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {String? tag}) {
    _instance.info(message, tag: tag);
  }

  static void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance.warning(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance.error(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void severe(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _instance.severe(message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void success(String message, {String? tag}) {
    _instance.info('✅ $message', tag: tag);
  }

  static void progress(String message, {String? tag}) {
    _instance.debug('📊 $message', tag: tag);
  }

  static void operation(String message, {String? tag}) {
    _instance.debug('🔄 $message', tag: tag);
  }

  static void init(String message, {String? tag}) {
    _instance.debug('🚀 $message', tag: tag);
  }

  static void connection(String message, {String? tag}) {
    _instance.debug('🔗 $message', tag: tag);
  }

  static void data(String message, {String? tag}) {
    _instance.debug('📦 $message', tag: tag);
  }
}
