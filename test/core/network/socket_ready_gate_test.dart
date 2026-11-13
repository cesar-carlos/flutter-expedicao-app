import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_ready_gate.dart';

void main() {
  group('SocketReadyGate', () {
    test('should return immediately when socket is already connected with session', () async {
      var connectCalls = 0;
      final gate = SocketReadyGate(
        isConnected: () => true,
        sessionId: () => 'session-1',
        connect: ({required Duration timeout}) async {
          connectCalls++;
        },
      );

      await gate.ensureReady();

      expect(connectCalls, 0);
    });

    test('should wait for connect when socket is disconnected', () async {
      var connected = false;
      String? sessionId;
      var connectCalls = 0;
      final gate = SocketReadyGate(
        isConnected: () => connected,
        sessionId: () => sessionId,
        connect: ({required Duration timeout}) async {
          connectCalls++;
          connected = true;
          sessionId = 'session-2';
        },
      );

      await gate.ensureReady();

      expect(connectCalls, 1);
      expect(gate.isReady, isTrue);
    });

    test('should wait for connect when connected but session id is missing', () async {
      var connected = true;
      String? sessionId;
      var connectCalls = 0;
      final gate = SocketReadyGate(
        isConnected: () => connected,
        sessionId: () => sessionId,
        connect: ({required Duration timeout}) async {
          connectCalls++;
          sessionId = 'session-3';
        },
      );

      await gate.ensureReady();

      expect(connectCalls, 1);
      expect(gate.isReady, isTrue);
    });

    test('should throw TimeoutException when connect finishes without a ready socket', () async {
      final gate = SocketReadyGate(
        isConnected: () => false,
        sessionId: () => null,
        connect: ({required Duration timeout}) async {},
      );

      await expectLater(gate.ensureReady(timeout: const Duration(seconds: 1)), throwsA(isA<TimeoutException>()));
    });

    test('should propagate connect timeout', () async {
      final gate = SocketReadyGate(
        isConnected: () => false,
        sessionId: () => null,
        connect: ({required Duration timeout}) async {
          throw TimeoutException('Conexão não estabelecida em ${timeout.inSeconds}s');
        },
      );

      await expectLater(gate.ensureReady(), throwsA(isA<TimeoutException>()));
    });
  });
}
