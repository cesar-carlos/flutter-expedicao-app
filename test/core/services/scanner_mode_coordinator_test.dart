import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/core/services/scanner_mode_coordinator.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

void main() {
  late _FakeBroadcastService fakeService;
  late List<String> received;
  late ScannerModeCoordinator coordinator;

  setUp(() {
    fakeService = _FakeBroadcastService();
    received = [];
    coordinator = ScannerModeCoordinator(
      broadcastService: fakeService,
      onBarcode: received.add,
      listenerRestartDelay: const Duration(milliseconds: 1),
    );
  });

  tearDown(() async {
    await coordinator.dispose();
  });

  group('ScannerModePreferences', () {
    test('isBroadcastConfigured exige modo broadcast + action + extraKey', () {
      expect(
        const ScannerModePreferences(mode: ScannerInputMode.focus, action: 'a', extraKey: 'd').isBroadcastConfigured,
        isFalse,
      );
      expect(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: '', extraKey: 'd').isBroadcastConfigured,
        isFalse,
      );
      expect(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: '').isBroadcastConfigured,
        isFalse,
      );
      expect(
        const ScannerModePreferences(
          mode: ScannerInputMode.broadcast,
          action: 'a',
          extraKey: 'd',
        ).isBroadcastConfigured,
        isTrue,
      );
    });
  });

  group('start()', () {
    test('em focus mode nao registra subscription', () async {
      await coordinator.start(const ScannerModePreferences(mode: ScannerInputMode.focus, action: 'a', extraKey: 'd'));
      expect(coordinator.isBroadcastActive, isFalse);
      expect(fakeService.listenCalls, equals(0));
    });

    test('em broadcast mode bem configurado registra subscription', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      expect(coordinator.isBroadcastActive, isTrue);
      expect(fakeService.listenCalls, equals(1));
      expect(fakeService.lastAction, equals('a'));
      expect(fakeService.lastExtraKey, equals('d'));
    });

    test('em broadcast mal configurado (action vazio) NAO registra', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: '', extraKey: 'd'),
      );
      expect(coordinator.isBroadcastActive, isFalse);
      expect(fakeService.listenCalls, equals(0));
    });
  });

  group('barcode forwarding', () {
    test('encaminha codigo nao-vazio recebido do stream', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      fakeService.emit('  7891234567890  ');
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(['7891234567890']));
    });

    test('ignora codigo vazio (so espacos)', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      fakeService.emit('   ');
      await Future<void>.delayed(Duration.zero);
      expect(received, isEmpty);
    });
  });

  group('manual override', () {
    test('override true para a subscription mesmo com prefs corretas', () async {
      final prefs = const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd');
      await coordinator.start(prefs);
      expect(coordinator.isBroadcastActive, isTrue);

      await coordinator.setManualOverride(true);
      expect(coordinator.isBroadcastActive, isFalse);

      // Codigo emitido enquanto override ativo nao chega ao callback
      // (porque a subscription ja foi cancelada).
      fakeService.emit('123');
      await Future<void>.delayed(Duration.zero);
      expect(received, isEmpty);
    });

    test('override false reinicia a subscription', () async {
      final prefs = const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd');
      await coordinator.start(prefs);
      await coordinator.setManualOverride(true);

      await coordinator.setManualOverride(false);
      expect(coordinator.isBroadcastActive, isTrue);

      fakeService.emit('999');
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(['999']));
    });

    test('override idempotente (chamar com mesmo valor nao reinicia)', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      await coordinator.setManualOverride(false);
      expect(fakeService.listenCalls, equals(1)); // apenas o start original
    });
  });

  group('updatePreferences()', () {
    test('trocar action recria subscription', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'old', extraKey: 'd'),
      );
      expect(fakeService.listenCalls, equals(1));

      await coordinator.updatePreferences(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'new', extraKey: 'd'),
      );
      expect(fakeService.listenCalls, equals(2));
      expect(fakeService.lastAction, equals('new'));
    });

    test('reiniciar broadcast cancela subscription anterior antes de ouvir novamente', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      final firstController = fakeService.currentController;

      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );

      expect(fakeService.listenCalls, equals(2));
      expect(fakeService.cancelCalls, equals(1));

      firstController?.add('old');
      fakeService.emit('new');
      await Future<void>.delayed(Duration.zero);

      expect(received, equals(['new']));
    });

    test('trocar de broadcast para focus para subscription', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      expect(coordinator.isBroadcastActive, isTrue);

      await coordinator.updatePreferences(
        const ScannerModePreferences(mode: ScannerInputMode.focus, action: 'a', extraKey: 'd'),
      );
      expect(coordinator.isBroadcastActive, isFalse);
    });
  });

  group('dispose()', () {
    test('cancela subscription e ignora chamadas posteriores', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      await coordinator.dispose();
      expect(coordinator.isBroadcastActive, isFalse);

      // Codigos posteriores nao devem mais ser entregues.
      fakeService.emit('123');
      await Future<void>.delayed(Duration.zero);
      expect(received, isEmpty);
    });

    test('idempotente', () async {
      await coordinator.dispose();
      await coordinator.dispose(); // nao deve lancar
    });
  });

  group('stream recovery', () {
    test('reinicia o listener quando o stream broadcast eh encerrado', () async {
      await coordinator.start(
        const ScannerModePreferences(mode: ScannerInputMode.broadcast, action: 'a', extraKey: 'd'),
      );
      expect(fakeService.listenCalls, equals(1));

      await fakeService.closeCurrentStream();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(coordinator.isBroadcastActive, isTrue);
      expect(fakeService.listenCalls, equals(2));

      fakeService.emit('321');
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(['321']));
    });
  });
}

class _FakeBroadcastService implements BarcodeBroadcastService {
  int listenCalls = 0;
  int cancelCalls = 0;
  String? lastAction;
  String? lastExtraKey;
  StreamController<String>? _controller;
  StreamController<String>? get currentController => _controller;

  @override
  Stream<String> listen({required String action, required String extraKey}) {
    listenCalls++;
    lastAction = action;
    lastExtraKey = extraKey;
    _controller = StreamController<String>.broadcast(onCancel: () => cancelCalls++);
    return _controller!.stream;
  }

  void emit(String code) {
    _controller?.add(code);
  }

  Future<void> closeCurrentStream() async {
    await _controller?.close();
  }
}
