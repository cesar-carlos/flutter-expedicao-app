import 'package:hive/hive.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';
import 'package:data7_expedicao/domain/models/scanner_input_mode.dart';

part 'api_config_entity.g.dart';

/// Entidade para persistência da configuração da API usando Hive
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

  /// Converte a entidade para o modelo de domínio
  ApiConfig toDomain() {
    return ApiConfig(
      apiUrl: apiUrl,
      apiPort: apiPort,
      useHttps: useHttps,
      lastUpdated: lastUpdated,
      scannerInputMode: ScannerInputMode.values[scannerModeIndex],
      broadcastAction: broadcastAction,
      broadcastExtraKey: broadcastExtraKey,
    );
  }

  /// Cria uma entidade a partir do modelo de domínio
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

  /// Configuração padrão
  static ApiConfigEntity get defaultConfig {
    final domain = ApiConfig.defaultConfig;
    return fromDomain(domain);
  }
}
