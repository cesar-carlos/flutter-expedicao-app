import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/core/validation/common/socket_validation_helper.dart';

void main() {
  group('SocketValidationHelper.validateSocketState', () {
    tearDown(SocketConfig.reset);

    test('retorna erro quando SocketConfig nao foi inicializado', () {
      SocketConfig.reset();

      final result = SocketValidationHelper.validateSocketState();

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('inicializado'));
    });
  });
}
