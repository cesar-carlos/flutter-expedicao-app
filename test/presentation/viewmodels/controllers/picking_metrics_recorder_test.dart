import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/metrics/metrics_collector.dart';
import 'package:data7_expedicao/core/metrics/metrics_storage.dart';
import 'package:data7_expedicao/core/metrics/websocket_metrics.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_metrics_recorder.dart';

void main() {
  group('PickingMetricsRecorder', () {
    test('recordScan eh no-op quando MetricsCollector nao foi fornecido', () {
      const recorder = PickingMetricsRecorder();
      // Nao deve lancar; eh telemetria que nunca quebra o fluxo.
      recorder.recordScan(
        barcode: '7891234567890',
        startTime: DateTime.now().subtract(const Duration(milliseconds: 50)),
        success: true,
      );
    });

    test('recordScan delega ao MetricsCollector com duracao calculada', () {
      final collector = MetricsCollector(_NoopMetricsStorage());
      final recorder = PickingMetricsRecorder(collector: collector);

      final startTime = DateTime.now().subtract(const Duration(milliseconds: 100));
      recorder.recordScan(
        barcode: '7891234567890',
        startTime: startTime,
        success: false,
        errorMessage: 'erro de teste',
      );

      final scans = collector.scanMetrics.recentScans;
      expect(scans, hasLength(1));
      expect(scans.first.barcode, equals('7891234567890'));
      expect(scans.first.success, isFalse);
      expect(scans.first.errorMessage, equals('erro de teste'));
      // Duracao deve ser >= 80ms (tolerancia para CI lento).
      expect(scans.first.duration.inMilliseconds, greaterThanOrEqualTo(80));
    });

    test('multiplas chamadas acumulam scans no collector', () {
      final collector = MetricsCollector(_NoopMetricsStorage());
      final recorder = PickingMetricsRecorder(collector: collector);

      final t = DateTime.now();
      recorder.recordScan(barcode: 'A', startTime: t, success: true);
      recorder.recordScan(barcode: 'B', startTime: t, success: false, errorMessage: 'x');
      recorder.recordScan(barcode: 'C', startTime: t, success: true);

      expect(collector.scanMetrics.recentScans, hasLength(3));
      expect(collector.scanMetrics.recentScans.map((s) => s.barcode), equals(['A', 'B', 'C']));
    });
  });
}

/// MetricsStorage que sobrescreve apenas os metodos sincronos chamados
/// internamente pelo MetricsCollector durante os testes (nao chama
/// SharedPreferences).
class _NoopMetricsStorage extends MetricsStorage {
  @override
  Future<WebSocketMetrics?> loadMetrics() async => null;

  @override
  Future<void> saveMetrics(WebSocketMetrics metrics) async {}
}
