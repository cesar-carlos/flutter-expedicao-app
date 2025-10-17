import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:data7_expedicao/data/datasources/config_service.dart';
import 'package:data7_expedicao/domain/viewmodels/config_viewmodel.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

/// Classe base para testes de integração que usam API
abstract class ApiIntegrationTestBase {
  /// Configuração padrão para testes
  static ApiConfig get testConfig =>
      ApiConfig(apiUrl: 'localhost', apiPort: 3001, useHttps: false, lastUpdated: DateTime.now());

  /// Inicializa o ambiente de teste com API
  static Future<void> setupApi() async {
    // Registra o serviço de configuração
    if (!GetIt.I.isRegistered<ConfigService>()) {
      final configService = ConfigService();
      GetIt.I.registerSingleton<ConfigService>(configService);
      GetIt.I.registerSingleton<ConfigViewModel>(ConfigViewModel(configService));
    }

    // Configura a API
    final configService = GetIt.I<ConfigService>();
    await configService.initialize();
    await configService.saveApiConfig(testConfig);

    // Aguarda um pouco para garantir que tudo está configurado
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Limpa recursos da API após os testes
  static Future<void> tearDownApi() async {
    // Limpa a configuração e reseta o GetIt
    final configService = GetIt.I<ConfigService>();
    await configService.clearConfig();
    await configService.dispose();
    await GetIt.I.reset();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Aguarda a conclusão de uma operação
  static Future<void> waitForOperation() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}
