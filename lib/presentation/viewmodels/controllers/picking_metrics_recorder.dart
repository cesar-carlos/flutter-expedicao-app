import 'package:data7_expedicao/core/metrics/metrics_collector.dart';

/// Recorder fino de métricas de scan no fluxo de picking.
///
/// Extraído de [CardPickingViewModel] (refator F5) para isolar a integração
/// com [MetricsCollector] — que é opcional (pode não estar registrado no
/// locator durante testes).
///
/// O recorder é seguro de chamar mesmo sem `MetricsCollector`: nesse caso
/// vira no-op silencioso (telemetria nunca deve quebrar o fluxo principal).
class PickingMetricsRecorder {
  final MetricsCollector? _collector;

  const PickingMetricsRecorder({MetricsCollector? collector}) : _collector = collector;

  /// Registra um evento de scan, calculando a duração entre `startTime`
  /// e o instante atual. Sem `MetricsCollector` configurado, é no-op.
  void recordScan({
    required String barcode,
    required DateTime startTime,
    required bool success,
    String? errorMessage,
  }) {
    final collector = _collector;
    if (collector == null) return;

    final duration = DateTime.now().difference(startTime);
    collector.recordScan(
      barcode: barcode,
      duration: duration,
      success: success,
      errorMessage: errorMessage,
    );
  }
}
