import 'package:data7_expedicao/core/network/socket_config.dart';

/// Utilitários para validação de Socket e SessionId
class SocketValidationHelper {
  /// Valida se o sessionId possui formato plausível do Socket.IO.
  ///
  /// **Bug Y/Z corrigido**: o regex anterior `[a-zA-Z0-9_-]{15,30}` era
  /// restritivo demais e bloqueava IDs legítimos em alguns cenários:
  /// - Socket.IO 4.x emite IDs com 20 chars puramente alfanuméricos (OK)
  /// - Alguns proxies/clusters adicionam prefixo do namespace (`/admin#xyz`)
  /// - Versões customizadas podem usar formatos diferentes
  ///
  /// A nova regex aceita qualquer ID com 8-64 caracteres usando os chars
  /// padrão de identificadores web (alfanuméricos + `_-./#:`). Para uso
  /// de "validação real" (saber se o socket está OK), prefira
  /// [validateSocketState] que checa conectividade — não apenas formato.
  static bool isValidSocketSessionId(String sessionId) {
    if (sessionId.isEmpty) return false;

    final socketIdRegex = RegExp(r'^[a-zA-Z0-9_\-./#:]{8,64}$');
    return socketIdRegex.hasMatch(sessionId);
  }

  /// Valida se o socket está em estado válido para operações
  ///
  /// Verifica:
  /// 1. Se o socket foi inicializado
  /// 2. Se está conectado
  /// 3. Se tem um sessionId válido
  static SocketValidationResult validateSocketState() {
    // Verifica se o socket foi inicializado
    if (!SocketConfig.isInitialized) {
      return SocketValidationResult.error('Socket não foi inicializado. Chame SocketConfig.initialize() primeiro.');
    }

    // Verifica se o socket está conectado
    if (!SocketConfig.isConnected) {
      return SocketValidationResult.error('Socket não está conectado. Verifique a conexão com o servidor.');
    }

    // Verifica se o sessionId está disponível e é válido
    final currentSessionId = SocketConfig.sessionId;
    if (currentSessionId == null || currentSessionId.isEmpty) {
      return SocketValidationResult.error('SessionId do socket não disponível. Aguarde a conexão ser estabelecida.');
    }

    if (!isValidSocketSessionId(currentSessionId)) {
      return SocketValidationResult.error(
        'SessionId atual ($currentSessionId) não possui formato válido do Socket.IO.',
      );
    }

    return SocketValidationResult.success(currentSessionId);
  }

  /// Valida se um sessionId informado coincide com o sessionId atual do socket
  ///
  /// Útil para validar se uma operação ainda é válida para a conexão atual
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
        'SessionId informado ($providedSessionId) não coincide com o sessionId atual do socket ($currentSessionId). '
        'A conexão pode ter sido reiniciada.',
      );
    }

    return SocketValidationResult.success(currentSessionId);
  }

  /// Valida completamente um sessionId (formato + estado do socket + consistência)
  ///
  /// Executa todas as validações em sequência:
  /// 1. Valida o formato do sessionId
  /// 2. Valida o estado atual do socket
  /// 3. Valida a consistência entre o sessionId fornecido e o atual
  static SocketValidationResult validateSessionIdCompletely(String sessionId) {
    // 1. Valida formato
    if (!isValidSocketSessionId(sessionId)) {
      return SocketValidationResult.error(
        'SessionId ($sessionId) não possui formato válido do Socket.IO. '
        'O formato deve ser alfanumérico com 15-30 caracteres.',
      );
    }

    // 2. Valida estado do socket e consistência
    return validateSessionIdConsistency(sessionId);
  }
}

/// Resultado da validação do socket
class SocketValidationResult {
  /// Indica se a validação foi bem-sucedida
  final bool isValid;

  /// Mensagem de erro em caso de falha
  final String? errorMessage;

  /// SessionId validado em caso de sucesso
  final String? sessionId;

  const SocketValidationResult._({required this.isValid, this.errorMessage, this.sessionId});

  /// Cria um resultado de sucesso com o sessionId validado
  factory SocketValidationResult.success(String sessionId) {
    return SocketValidationResult._(isValid: true, sessionId: sessionId);
  }

  /// Cria um resultado de erro com a mensagem explicativa
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
