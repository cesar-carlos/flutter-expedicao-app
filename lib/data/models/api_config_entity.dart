import 'package:hive/hive.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

part 'api_config_entity.g.dart';

@HiveType(typeId: 0)
class ApiConfigEntity extends HiveObject {
  @HiveField(0)
  String apiUrl;

  @HiveField(1)
  int apiPort;

  @HiveField(2)
  bool useHttps;

  @HiveField(3)
  DateTime? lastUpdated;

  @HiveField(4)
  int scannerModeIndex;

  @HiveField(5)
  String? broadcastAction;

  @HiveField(6)
  String? broadcastExtraKey;

  ApiConfigEntity({
    required this.apiUrl,
    required this.apiPort,
    this.useHttps = false,
    this.lastUpdated,
    this.scannerModeIndex = 0,
    this.broadcastAction,
    this.broadcastExtraKey,
  });

  ApiConfig toDomain() {
    final scannerInputMode = scannerModeIndex >= 0 && scannerModeIndex < ScannerInputMode.values.length
        ? ScannerInputMode.values[scannerModeIndex]
        : ApiConfig.defaultConfig.scannerInputMode;

    return ApiConfig(
      apiUrl: apiUrl,
      apiPort: apiPort,
      useHttps: useHttps,
      lastUpdated: lastUpdated,
      scannerInputMode: scannerInputMode,
      broadcastAction: broadcastAction,
      broadcastExtraKey: broadcastExtraKey,
    );
  }

  static ApiConfigEntity fromDomain(ApiConfig config) {
    return ApiConfigEntity(
      apiUrl: config.apiUrl,
      apiPort: config.apiPort,
      useHttps: config.useHttps,
      lastUpdated: config.lastUpdated,
      scannerModeIndex: config.scannerInputMode.index,
      broadcastAction: config.broadcastAction,
      broadcastExtraKey: config.broadcastExtraKey,
    );
  }

  static ApiConfigEntity get defaultConfig {
    final domain = ApiConfig.defaultConfig;
    return fromDomain(domain);
  }
}
