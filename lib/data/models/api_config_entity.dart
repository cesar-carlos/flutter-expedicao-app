import 'package:hive/hive.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

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

  ApiConfigEntity({required this.apiUrl, required this.apiPort, this.useHttps = false, this.lastUpdated});

  /// Converte a entidade para o modelo de domínio
  ApiConfig toDomain() {
    return ApiConfig(apiUrl: apiUrl, apiPort: apiPort, useHttps: useHttps, lastUpdated: lastUpdated);
  }

  /// Cria uma entidade a partir do modelo de domínio
  static ApiConfigEntity fromDomain(ApiConfig config) {
    return ApiConfigEntity(
      apiUrl: config.apiUrl,
      apiPort: config.apiPort,
      useHttps: config.useHttps,
      lastUpdated: config.lastUpdated,
    );
  }

  /// Configuração padrão
  static ApiConfigEntity get defaultConfig {
    final domain = ApiConfig.defaultConfig;
    return fromDomain(domain);
  }
}
