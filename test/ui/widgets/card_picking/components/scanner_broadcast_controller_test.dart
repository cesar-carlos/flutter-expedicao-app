import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_broadcast_service.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scanner_broadcast_controller.dart';

void main() {
  late _FakeBroadcastService fakeService;

  setUp(() {
    fakeService = _FakeBroadcastService();
    if (locator.isRegistered<BarcodeBroadcastService>()) {
      locator.unregister<BarcodeBroadcastService>();
    }
    locator.registerSingleton<BarcodeBroadcastService>(fakeService);
  });

  tearDown(() {
    if (locator.isRegistered<BarcodeBroadcastService>()) {
      locator.unregister<BarcodeBroadcastService>();
    }
  });

  group('ScannerBroadcastController (wrapper sobre ScannerModeCoordinator)', () {
    test('start com action ou extraKey vazio nao registra subscription', () async {
      final controller = ScannerBroadcastController();

      await controller.start(action: '', extraKey: 'data', onBarcodeReceived: (_) {});
      expect(controller.isActive, isFalse);
      expect(fakeService.listenCalls, equals(0));

      await controller.start(action: 'a', extraKey: '', onBarcodeReceived: (_) {});
      expect(controller.isActive, isFalse);
      expect(fakeService.listenCalls, equals(0));

      controller.dispose();
    });

    test('start com configuracao valida ativa subscription', () async {
      final controller = ScannerBroadcastController();
      final received = <String>[];

      await controller.start(action: 'com.scan.BARCODE', extraKey: 'data', onBarcodeReceived: received.add);
      expect(controller.isActive, isTrue);
      expect(fakeService.listenCalls, equals(1));

      fakeService.emit('7891234567890');
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(['7891234567890']));

      controller.dispose();
    });

    test('REGRESSAO: start apos stop deve reativar a subscription', () async {
      final controller = ScannerBroadcastController();
      final received = <String>[];

      await controller.start(action: 'a', extraKey: 'd', onBarcodeReceived: received.add);
      expect(controller.isActive, isTrue);

      await controller.stop();
      expect(controller.isActive, isFalse);

      // Apos stop, deve voltar a ouvir com nova chamada de start.
      await controller.start(action: 'a', extraKey: 'd', onBarcodeReceived: received.add);
      expect(controller.isActive, isTrue);

      fakeService.emit('999');
      await Future<void>.delayed(Duration.zero);
      expect(received, equals(['999']));

      controller.dispose();
    });

    test('stop em controller que nunca foi iniciado eh no-op', () async {
      final controller = ScannerBroadcastController();
      await controller.stop(); // nao deve lancar
      expect(controller.isActive, isFalse);
      controller.dispose();
    });

    test('dispose limpa callback e impede entregas posteriores', () async {
      final controller = ScannerBroadcastController();
      final received = <String>[];

      await controller.start(action: 'a', extraKey: 'd', onBarcodeReceived: received.add);
      controller.dispose();

      fakeService.emit('123');
      await Future<void>.delayed(Duration.zero);
      expect(received, isEmpty);
    });
  });
}

class _FakeBroadcastService implements BarcodeBroadcastService {
  int listenCalls = 0;
  StreamController<String>? _controller;

  @override
  Stream<String> listen({required String action, required String extraKey}) {
    listenCalls++;
    _controller?.close();
    _controller = StreamController<String>.broadcast();
    return _controller!.stream;
  }

  void emit(String code) {
    _controller?.add(code);
  }
}
