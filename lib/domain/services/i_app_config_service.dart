import 'package:data7_expedicao/domain/models/api_config.dart';

/// Contrato de dominio para acesso a configuracao da API.
///
/// Expoe apenas as operacoes consumidas pela camada de apresentacao,
/// mantendo a presentation desacoplada da implementacao em `data/`.
abstract interface class IAppConfigService {
  ApiConfig getApiConfig();

  Future<void> saveApiConfig(ApiConfig config);

  Future<void> clearConfig();

  bool hasApiConfig();
}
