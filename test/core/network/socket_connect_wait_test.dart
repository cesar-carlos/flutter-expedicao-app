import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_connect_wait.dart';

void main() {
  group('waitForSocketConnect', () {
    test('should return when the wait completer completes before timeout', () async {
      final wait = Completer<void>();
      var timedOut = false;

      final future = waitForSocketConnect(
        wait: wait,
        timeout: const Duration(seconds: 1),
        onTimeout: () {
          timedOut = true;
        },
      );
      wait.complete();
      await future;

      expect(timedOut, isFalse);
    });

    test('should throw TimeoutException and call onTimeout when wait expires', () async {
      final wait = Completer<void>();
      var timedOut = false;

      await expectLater(
        waitForSocketConnect(
          wait: wait,
          timeout: const Duration(milliseconds: 20),
          onTimeout: () {
            timedOut = true;
          },
        ),
        throwsA(isA<TimeoutException>()),
      );

      expect(timedOut, isTrue);
      expect(wait.isCompleted, isTrue);
    });

    test('should not leak an unhandled zone error when timeout fires', () async {
      final zoneErrors = <Object>[];

      await runZonedGuarded(
        () async {
          final wait = Completer<void>();
          await expectLater(
            waitForSocketConnect(wait: wait, timeout: const Duration(milliseconds: 20), onTimeout: () {}),
            throwsA(isA<TimeoutException>()),
          );
        },
        (error, _) {
          zoneErrors.add(error);
        },
      );

      expect(zoneErrors, isEmpty);
    });

    test('should propagate an error already completed on the wait', () async {
      final wait = Completer<void>();
      wait.completeError(StateError('Conexão encerrada.'));

      await expectLater(
        waitForSocketConnect(wait: wait, timeout: const Duration(seconds: 1), onTimeout: () {}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
