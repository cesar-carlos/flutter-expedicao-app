/// Modelo de domínio para configuração da API
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

class ApiConfig {
  final String apiUrl;
  final int apiPort;
  final bool useHttps;
  final DateTime? lastUpdated;
  final ScannerInputMode scannerInputMode;
  final String? broadcastAction;
  final String? broadcastExtraKey;

  const ApiConfig({
    required this.apiUrl,
    required this.apiPort,
    this.useHttps = false,
    this.lastUpdated,
    this.scannerInputMode = ScannerInputMode.focus,
    this.broadcastAction,
    this.broadcastExtraKey,
  });

  String get fullUrl {
    final protocol = useHttps ? 'https' : 'http';
    return '$protocol://$apiUrl:$apiPort';
  }

  static ApiConfig get defaultConfig => ApiConfig(
        apiUrl: 'localhost',
        apiPort: 3001,
        useHttps: false,
        scannerInputMode: ScannerInputMode.broadcast,
        broadcastAction: 'com.scanner.BARCODE',
        broadcastExtraKey: 'data',
        lastUpdated: DateTime.now(),
      );

  ApiConfig copyWith({
    String? apiUrl,
    int? apiPort,
    bool? useHttps,
    DateTime? lastUpdated,
    ScannerInputMode? scannerInputMode,
    String? broadcastAction,
    String? broadcastExtraKey,
  }) {
    return ApiConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiPort: apiPort ?? this.apiPort,
      useHttps: useHttps ?? this.useHttps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      scannerInputMode: scannerInputMode ?? this.scannerInputMode,
      broadcastAction: broadcastAction ?? this.broadcastAction,
      broadcastExtraKey: broadcastExtraKey ?? this.broadcastExtraKey,
    );
  }

  @override
  String toString() {
    return 'ApiConfig(url: $apiUrl, port: $apiPort, https: $useHttps, fullUrl: $fullUrl, scannerMode: $scannerInputMode, action: $broadcastAction, extra: $broadcastExtraKey)';
  }
}
