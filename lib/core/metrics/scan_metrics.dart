import 'package:flutter/foundation.dart';

/// Métricas relacionadas a escaneamentos de código de barras
class ScanMetrics {
  /// Total de escaneamentos realizados
  int _totalScans = 0;

  /// Escaneamentos bem-sucedidos
  int _successfulScans = 0;

  /// Escaneamentos com erro
  int _failedScans = 0;

  /// Soma de todos os tempos de escaneamento (em milissegundos)
  int _totalScanTimeMs = 0;

  /// Tempo médio de escaneamento (em milissegundos)
  double get averageScanTimeMs =>
      _totalScans > 0 ? _totalScanTimeMs / _totalScans : 0.0;

  /// Taxa de sucesso (0.0 a 1.0)
  double get successRate =>
      _totalScans > 0 ? _successfulScans / _totalScans : 0.0;

  /// Histórico de escaneamentos recentes (últimos 100)
  final List<ScanRecord> _recentScans = [];

  /// Lista não modificável de escaneamentos recentes
  List<ScanRecord> get recentScans => List.unmodifiable(_recentScans);

  /// Registra um escaneamento
  void recordScan({
    required String barcode,
    required Duration duration,
    required bool success,
    String? errorMessage,
  }) {
    _totalScans++;
    _totalScanTimeMs += duration.inMilliseconds;

    if (success) {
      _successfulScans++;
    } else {
      _failedScans++;
    }

    // Adicionar ao histórico
    _recentScans.add(
      ScanRecord(
        barcode: barcode,
        duration: duration,
        success: success,
        errorMessage: errorMessage,
        timestamp: DateTime.now(),
      ),
    );

    // Manter apenas os últimos 100
    if (_recentScans.length > 100) {
      _recentScans.removeAt(0);
    }

    if (kDebugMode) {
      print(
        '[ScanMetrics] Scan: $barcode | Success: $success | Duration: ${duration.inMilliseconds}ms',
      );
    }
  }

  /// Reseta todas as métricas
  void reset() {
    _totalScans = 0;
    _successfulScans = 0;
    _failedScans = 0;
    _totalScanTimeMs = 0;
    _recentScans.clear();
  }

  /// Converte para JSON para persistência
  Map<String, dynamic> toJson() => {
    'totalScans': _totalScans,
    'successfulScans': _successfulScans,
    'failedScans': _failedScans,
    'totalScanTimeMs': _totalScanTimeMs,
    'averageScanTimeMs': averageScanTimeMs,
    'successRate': successRate,
    'recentScans': _recentScans.map((r) => r.toJson()).toList(),
  };

  /// Restaura de JSON
  void mergeFromJson(Map<String, dynamic> json) {
    _totalScans = json['totalScans'] as int? ?? 0;
    _successfulScans = json['successfulScans'] as int? ?? 0;
    _failedScans = json['failedScans'] as int? ?? 0;
    _totalScanTimeMs = json['totalScanTimeMs'] as int? ?? 0;

    final scansJson = json['recentScans'] as List?;
    if (scansJson != null) {
      _recentScans.clear();
      for (final scanJson in scansJson) {
        if (scanJson is Map<String, dynamic>) {
          _recentScans.add(ScanRecord.fromJson(scanJson));
        }
      }
    }
  }
}

/// Registro de um escaneamento individual
class ScanRecord {
  final String barcode;
  final Duration duration;
  final bool success;
  final String? errorMessage;
  final DateTime timestamp;

  ScanRecord({
    required this.barcode,
    required this.duration,
    required this.success,
    this.errorMessage,
    required this.timestamp,
  });

  /// Converte para JSON
  Map<String, dynamic> toJson() => {
    'barcode': barcode,
    'durationMs': duration.inMilliseconds,
    'success': success,
    'errorMessage': errorMessage,
    'timestamp': timestamp.toIso8601String(),
  };

  /// Restaura de JSON
  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
    barcode: json['barcode'] as String,
    duration: Duration(milliseconds: json['durationMs'] as int? ?? 0),
    success: json['success'] as bool? ?? false,
    errorMessage: json['errorMessage'] as String?,
    timestamp: DateTime.parse(
      json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    ),
  );
}
