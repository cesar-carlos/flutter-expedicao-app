class WebSocketMetrics {
  WebSocketMetrics();

  int totalConnections = 0;
  int failedConnections = 0;
  Duration? lastConnectionTime;

  int totalOperations = 0;
  int successfulOperations = 0;
  int failedOperations = 0;

  static const int _maxLatencySamples = 100;
  final List<int> _operationLatenciesMs = [];

  DateTime? lastSuccessfulOperation;
  DateTime? lastFailedOperation;

  List<int> get operationLatenciesMs => List.unmodifiable(_operationLatenciesMs);

  int? get averageLatencyMs {
    if (_operationLatenciesMs.isEmpty) return null;
    final sum = _operationLatenciesMs.reduce((a, b) => a + b);
    return sum ~/ _operationLatenciesMs.length;
  }

  int? get maxLatencyMs =>
      _operationLatenciesMs.isEmpty ? null : _operationLatenciesMs.reduce((a, b) => a > b ? a : b);

  int? get minLatencyMs =>
      _operationLatenciesMs.isEmpty ? null : _operationLatenciesMs.reduce((a, b) => a < b ? a : b);

  Duration? get averageLatency =>
      averageLatencyMs != null ? Duration(milliseconds: averageLatencyMs!) : null;

  Duration? get maxLatency => maxLatencyMs != null ? Duration(milliseconds: maxLatencyMs!) : null;

  Duration? get minLatency => minLatencyMs != null ? Duration(milliseconds: minLatencyMs!) : null;

  double get successRate {
    if (totalOperations == 0) return 1.0;
    return successfulOperations / totalOperations;
  }

  void recordConnectionAttempt(bool success, Duration duration) {
    totalConnections++;
    if (!success) {
      failedConnections++;
    }
    lastConnectionTime = duration;
  }

  final Map<String, DateTime> _operationStarts = {};

  void recordOperationStart(String operationId) {
    _operationStarts[operationId] = DateTime.now();
  }

  void recordOperationEnd(String operationId, bool success, Duration duration) {
    _operationStarts.remove(operationId);
    totalOperations++;
    if (success) {
      successfulOperations++;
      lastSuccessfulOperation = DateTime.now();
    } else {
      failedOperations++;
      lastFailedOperation = DateTime.now();
    }
    final ms = duration.inMilliseconds;
    _operationLatenciesMs.add(ms);
    if (_operationLatenciesMs.length > _maxLatencySamples) {
      _operationLatenciesMs.removeAt(0);
    }
  }

  void recordOperationEndFromStart(String operationId, bool success) {
    final start = _operationStarts[operationId];
    _operationStarts.remove(operationId);
    if (start == null) return;
    recordOperationEnd(operationId, success, DateTime.now().difference(start));
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConnections': totalConnections,
      'failedConnections': failedConnections,
      'lastConnectionTimeMs': lastConnectionTime?.inMilliseconds,
      'totalOperations': totalOperations,
      'successfulOperations': successfulOperations,
      'failedOperations': failedOperations,
      'successRate': successRate,
      'averageLatencyMs': averageLatencyMs,
      'maxLatencyMs': maxLatencyMs,
      'minLatencyMs': minLatencyMs,
      'lastSuccessfulOperation': lastSuccessfulOperation?.toIso8601String(),
      'lastFailedOperation': lastFailedOperation?.toIso8601String(),
      'operationLatenciesMs': _operationLatenciesMs,
    };
  }

  factory WebSocketMetrics.fromJson(Map<String, dynamic> json) {
    final m = WebSocketMetrics();
    m.totalConnections = (json['totalConnections'] as int?) ?? 0;
    m.failedConnections = (json['failedConnections'] as int?) ?? 0;
    final lastConnMs = json['lastConnectionTimeMs'] as int?;
    m.lastConnectionTime = lastConnMs != null ? Duration(milliseconds: lastConnMs) : null;
    m.totalOperations = (json['totalOperations'] as int?) ?? 0;
    m.successfulOperations = (json['successfulOperations'] as int?) ?? 0;
    m.failedOperations = (json['failedOperations'] as int?) ?? 0;
    final lastOk = json['lastSuccessfulOperation'] as String?;
    m.lastSuccessfulOperation = lastOk != null ? DateTime.tryParse(lastOk) : null;
    final lastFail = json['lastFailedOperation'] as String?;
    m.lastFailedOperation = lastFail != null ? DateTime.tryParse(lastFail) : null;
    final list = json['operationLatenciesMs'];
    if (list is List) {
      for (final e in list) {
        if (e is int) m._operationLatenciesMs.add(e);
      }
      while (m._operationLatenciesMs.length > _maxLatencySamples) {
        m._operationLatenciesMs.removeAt(0);
      }
    }
    return m;
  }

  void reset() {
    totalConnections = 0;
    failedConnections = 0;
    lastConnectionTime = null;
    totalOperations = 0;
    successfulOperations = 0;
    failedOperations = 0;
    _operationLatenciesMs.clear();
    lastSuccessfulOperation = null;
    lastFailedOperation = null;
    _operationStarts.clear();
  }

  void mergeFrom(WebSocketMetrics other) {
    totalConnections = other.totalConnections;
    failedConnections = other.failedConnections;
    lastConnectionTime = other.lastConnectionTime;
    totalOperations = other.totalOperations;
    successfulOperations = other.successfulOperations;
    failedOperations = other.failedOperations;
    lastSuccessfulOperation = other.lastSuccessfulOperation;
    lastFailedOperation = other.lastFailedOperation;
    _operationLatenciesMs.clear();
    _operationLatenciesMs.addAll(other._operationLatenciesMs);
  }
}
