import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'package:data7_expedicao/domain/models/api_config.dart';

/// Classe base para testes de integração que usam Socket.IO
abstract class SocketIntegrationTestBase {
  /// Configuração padrão para testes
  static ApiConfig get testConfig =>
      ApiConfig(apiUrl: 'localhost', apiPort: 3001, useHttps: false, lastUpdated: DateTime.now());

  /// Inicializa o ambiente de teste com Socket.IO
  static Future<void> setupSocket() async {
    // Inicializa o socket
    SocketConfig.initialize(testConfig);

    // Aguarda a conexão ser estabelecida
    await Future.delayed(const Duration(seconds: 2));

    // Verifica se o socket está conectado
    if (!SocketConfig.isConnected) {
      throw Exception('Falha ao conectar ao servidor de teste');
    }
  }

  /// Limpa recursos do socket após os testes
  static Future<void> tearDownSocket() async {
    SocketConfig.dispose();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Aguarda a conclusão de uma operação
  static Future<void> waitForOperation() async {
    await Future.delayed(const Duration(seconds: 3));
  }
}
