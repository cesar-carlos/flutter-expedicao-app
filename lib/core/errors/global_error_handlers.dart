import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';

/// Instala handlers globais para erros de framework e da plataforma.
void installGlobalErrorHandlers({required void Function() onUnhandledError}) {
  FlutterError.onError = (details) {
    AppLogger.error(
      details.exceptionAsString(),
      tag: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    );
    FlutterError.presentError(details);
    onUnhandledError();
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Erro não tratado', tag: 'PlatformDispatcher', error: error, stackTrace: stack);
    onUnhandledError();
    return true;
  };
}
