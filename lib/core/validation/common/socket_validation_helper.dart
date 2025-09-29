import 'package:exp/core/network/socket_config.dart';

/// Utilitários para validação de Socket e SessionId
class SocketValidationHelper {
  /// Valida se o sessionId possui formato válido do Socket.IO
  ///
  /// Socket.IO gera IDs alfanuméricos de aproximadamente 15-30 caracteres
  /// Formato típico: combinação de letras, números, hífens e underscores
  static bool isValidSocketSessionId(String sessionId) {
    if (sessionId.isEmpty) return false;

    // Regex para validar formato de sessionId do Socket.IO
    final socketIdRegex = RegExp(r'^[a-zA-Z0-9_-]{15,30}$');
    return socketIdRegex.hasMatch(sessionId);
  }

  /// Valida se o socket está em estado válido para operações
  static SocketValidationResult validateSocketState() {
    // Verifica se o socket foi inicializado
    if (!SocketConfig.isInitialized) {
      return SocketValidationResult.error('Socket não foi inicializado');
    }

    // Verifica se o socket está conectado
    if (!SocketConfig.isConnected) {
      return SocketValidationResult.error('Socket não está conectado');
    }

    // Verifica se o sessionId está disponível
    final currentSessionId = SocketConfig.sessionId;
    if (currentSessionId == null || currentSessionId.isEmpty) {
      return SocketValidationResult.error('SessionId do socket não disponível');
    }

    return SocketValidationResult.success(currentSessionId);
  }

  /// Valida se um sessionId informado coincide com o sessionId atual do socket
  static SocketValidationResult validateSessionIdConsistency(String providedSessionId) {
    // Primeiro valida o estado do socket
    final socketStateResult = validateSocketState();
    if (!socketStateResult.isValid) {
      return socketStateResult;
    }

    final currentSessionId = socketStateResult.sessionId!;

    // Verifica se o sessionId fornecido coincide com o atual
    if (currentSessionId != providedSessionId) {
      return SocketValidationResult.error(
        'SessionId informado ($providedSessionId) não coincide com o sessionId atual do socket ($currentSessionId)',
      );
    }

    return SocketValidationResult.success(currentSessionId);
  }

  /// Valida completamente um sessionId (formato + estado do socket + consistência)
  static SocketValidationResult validateSessionIdCompletely(String sessionId) {
    // 1. Valida formato
    if (!isValidSocketSessionId(sessionId)) {
      return SocketValidationResult.error('SessionId não possui formato válido do Socket.IO');
    }

    // 2. Valida estado do socket e consistência
    return validateSessionIdConsistency(sessionId);
  }
}

/// Resultado da validação do socket
class SocketValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? sessionId;

  const SocketValidationResult._({required this.isValid, this.errorMessage, this.sessionId});

  /// Cria um resultado de sucesso
  factory SocketValidationResult.success(String sessionId) {
    return SocketValidationResult._(isValid: true, sessionId: sessionId);
  }

  /// Cria um resultado de erro
  factory SocketValidationResult.error(String errorMessage) {
    return SocketValidationResult._(isValid: false, errorMessage: errorMessage);
  }

  @override
  String toString() {
    if (isValid) {
      return 'SocketValidationResult.success(sessionId: $sessionId)';
    } else {
      return 'SocketValidationResult.error(message: $errorMessage)';
    }
  }
}
