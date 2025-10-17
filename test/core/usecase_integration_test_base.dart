import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/network/socket_config.dart';
import 'socket_integration_test_base.dart';

/// Classe base para testes de integração de usecases que usam Socket.IO
class UseCaseIntegrationTestBase {
  /// Configura o ambiente de teste com retry de conexão
  static Future<void> setupUseCaseTest({int maxAttempts = 10}) async {
    // Limpar qualquer conexão anterior
    if (SocketConfig.isInitialized) {
      SocketConfig.dispose();
    }

    // Inicializa o socket
    SocketConfig.initialize(SocketIntegrationTestBase.testConfig);

    // Aguardar conexão do socket com retry
    var attempts = 0;
    while (!SocketConfig.isConnected && attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
      debugPrint('⏳ Tentativa $attempts/$maxAttempts - Aguardando conexão...');
    }

    if (!SocketConfig.isConnected) {
      throw Exception(
        '❌ Socket não conectou após $maxAttempts tentativas.\n'
        '💡 Verifique se o servidor está rodando na porta ${SocketIntegrationTestBase.testConfig.apiPort}',
      );
    }

    debugPrint('✅ Socket conectado com sucesso!');
    debugPrint('🔑 SessionId: ${SocketConfig.sessionId}');
  }

  /// Verifica e reconecta o socket se necessário
  static Future<void> ensureSocketConnection() async {
    if (!SocketConfig.isConnected) {
      debugPrint('⚠️ Socket desconectado durante teste. Tentando reconectar...');
      await SocketConfig.connect();
      await Future.delayed(const Duration(seconds: 2));

      if (!SocketConfig.isConnected) {
        throw Exception('Socket não conseguiu reconectar. Teste cancelado.');
      }
    }
  }

  /// Valida o estado do socket para testes
  static void validateSocketState() {
    expect(SocketConfig.isConnected, isTrue, reason: 'Socket deve estar conectado');
    expect(SocketConfig.sessionId, isNotNull, reason: 'SessionId deve estar disponível');
  }

  /// Aguarda a conclusão de uma operação com feedback
  static Future<void> waitForOperation(String operation, {Duration? duration}) async {
    debugPrint('⏳ Aguardando conclusão: $operation');
    await Future.delayed(duration ?? const Duration(seconds: 1));
    debugPrint('✅ Operação concluída: $operation');
  }

  /// Registra o início de um teste
  static void logTestStart(String testName) {
    debugPrint('\n🔵 Iniciando teste: $testName');
  }

  /// Registra o sucesso de um teste
  static void logTestSuccess(String testName, {String? details}) {
    debugPrint('✅ Teste concluído com sucesso: $testName');
    if (details != null) {
      debugPrint('📊 Detalhes: $details');
    }
  }

  /// Registra uma falha esperada em um teste
  static void logExpectedFailure(String testName, String failureType, String message) {
    debugPrint('✅ Falha esperada em: $testName');
    debugPrint('📋 Tipo: $failureType');
    debugPrint('💬 Mensagem: $message');
  }

  /// Registra um erro inesperado
  static void logUnexpectedError(String operation, Object error) {
    debugPrint('❌ Erro inesperado em: $operation');
    debugPrint('💬 Detalhes: $error');
  }

  /// Limpa recursos do socket após os testes
  static Future<void> tearDownSocket() async {
    SocketConfig.dispose();
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
