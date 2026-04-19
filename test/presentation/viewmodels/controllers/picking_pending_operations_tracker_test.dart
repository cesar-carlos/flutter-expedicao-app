import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_pending_operations_tracker.dart';

void main() {
  group('PickingPendingOperationsTracker', () {
    late PickingPendingOperationsTracker tracker;

    setUp(() {
      tracker = PickingPendingOperationsTracker();
    });

    test('comeca vazio', () {
      expect(tracker.isEmpty, isTrue);
      expect(tracker.isNotEmpty, isFalse);
      expect(tracker.count, equals(0));
    });

    test('track marca operacao como pendente', () {
      final completer = Completer<void>();
      tracker.track('item-1', completer.future);

      expect(tracker.isNotEmpty, isTrue);
      expect(tracker.count, equals(1));

      completer.complete();
    });

    test('operacao eh removida automaticamente ao completar', () async {
      final completer = Completer<void>();
      tracker.track('item-1', completer.future);

      expect(tracker.count, equals(1));
      completer.complete();
      await completer.future;
      // Espera microtask do whenComplete rodar
      await Future<void>.delayed(Duration.zero);

      expect(tracker.isEmpty, isTrue);
    });

    test('operacao eh removida ao falhar', () async {
      final completer = Completer<void>();
      // ignore: unawaited_futures
      tracker.track('item-1', completer.future);
      expect(tracker.count, equals(1));

      completer.completeError(Exception('boom'));
      // Aguarda o future falhar e o whenComplete propagar
      try {
        await completer.future;
      } catch (_) {}
      await Future<void>.delayed(Duration.zero);

      expect(tracker.isEmpty, isTrue);
    });

    test('multiplas operacoes do mesmo itemId sao agrupadas', () async {
      final c1 = Completer<void>();
      final c2 = Completer<void>();
      tracker.track('item-1', c1.future);
      tracker.track('item-1', c2.future);

      expect(tracker.count, equals(2));

      c1.complete();
      await c1.future;
      await Future<void>.delayed(Duration.zero);

      // Ainda ha 1 pendente do mesmo itemId
      expect(tracker.count, equals(1));

      c2.complete();
      await c2.future;
      await Future<void>.delayed(Duration.zero);

      expect(tracker.isEmpty, isTrue);
    });

    test('waitForAll aguarda todas as operacoes em andamento', () async {
      final c1 = Completer<void>();
      final c2 = Completer<void>();
      tracker.track('item-1', c1.future);
      tracker.track('item-2', c2.future);

      var allDone = false;
      // ignore: unawaited_futures
      tracker.waitForAll().then((_) => allDone = true);

      await Future<void>.delayed(Duration.zero);
      expect(allDone, isFalse);

      c1.complete();
      c2.complete();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(allDone, isTrue);
    });

    test('waitForAll com tracker vazio retorna imediatamente', () async {
      var done = false;
      // ignore: unawaited_futures
      tracker.waitForAll().then((_) => done = true);
      await Future<void>.delayed(Duration.zero);
      expect(done, isTrue);
    });

    test('waitForAll nao falha se uma operacao falhar (eagerError=false)', () async {
      final c1 = Completer<void>();
      final c2 = Completer<void>();
      tracker.track('item-1', c1.future);
      tracker.track('item-2', c2.future);

      final waitFuture = tracker.waitForAll();
      // Suprime non-handled error em c1.future:
      c1.future.catchError((_) {});

      c1.completeError(Exception('boom'));
      c2.complete();

      await waitFuture; // nao deve lancar
    });

    test('clear esvazia o tracker sem cancelar operacoes', () async {
      final c1 = Completer<void>();
      tracker.track('item-1', c1.future);

      tracker.clear();
      expect(tracker.isEmpty, isTrue);

      // O future original ainda completa normalmente (nao foi cancelado).
      c1.complete();
      await c1.future;
    });
  });
}
