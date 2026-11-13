import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/errors/global_error_handlers.dart';

void main() {
  test('should notify the UI when an uncaught platform error is handled', () {
    final previousFlutter = FlutterError.onError;
    final previousPlatform = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = previousFlutter;
      PlatformDispatcher.instance.onError = previousPlatform;
    });
    var reported = 0;
    installGlobalErrorHandlers(onUnhandledError: () => reported++);
    final handled = PlatformDispatcher.instance.onError!(StateError('test error'), StackTrace.current);
    expect(handled, isTrue);
    expect(reported, 1);
  });
}
