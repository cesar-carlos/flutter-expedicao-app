import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/metrics/metrics_storage.dart';
import 'package:data7_expedicao/core/metrics/websocket_metrics.dart';

class MetricsCollector extends ChangeNotifier {
  final MetricsStorage _storage;
  final WebSocketMetrics _metrics = WebSocketMetrics();

  Timer? _saveTimer;
  static const Duration _saveInterval = Duration(seconds: 30);

  WebSocketMetrics get metrics => _metrics;

  MetricsCollector(this._storage);

  Future<void> init() async {
    final loaded = await _storage.loadMetrics();
    if (loaded != null) {
      _metrics.mergeFrom(loaded);
    }
    _startPeriodicSave();
  }

  void _startPeriodicSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer.periodic(_saveInterval, (_) => save());
  }

  void recordConnectionAttempt(bool success, Duration duration) {
    _metrics.recordConnectionAttempt(success, duration);
    notifyListeners();
  }

  void recordOperationStart(String operationId) {
    _metrics.recordOperationStart(operationId);
  }

  void recordOperationEnd(String operationId, bool success, Duration duration) {
    _metrics.recordOperationEnd(operationId, success, duration);
    notifyListeners();
  }

  void recordOperationEndFromStart(String operationId, bool success) {
    _metrics.recordOperationEndFromStart(operationId, success);
    notifyListeners();
  }

  Future<void> save() async {
    try {
      await _storage.saveMetrics(_metrics);
    } catch (_) {}
  }

  Future<void> clear() async {
    _metrics.reset();
    await _storage.clearMetrics();
    notifyListeners();
  }

  Future<Map<String, dynamic>> export() => _storage.exportMetrics();

  void disposeCollector() {
    _saveTimer?.cancel();
    _saveTimer = null;
  }
}
