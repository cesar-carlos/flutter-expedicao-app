/// Classe base para representar falhas no aplicativo
///
/// Todas as falhas do app devem estender esta classe
/// para garantir consistência no tratamento de erros
abstract class AppFailure implements Exception {
  /// Mensagem de erro técnica (para logs)
  final String message;

  /// Código de erro (opcional)
  final String? code;

  /// Exceção original (opcional, para debugging)
  final dynamic exception;

  const AppFailure({required this.message, this.code, this.exception});

  /// Mensagem amigável para o usuário
  String get userMessage => message;

  @override
  String toString() => 'AppFailure(message: $message, code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppFailure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Falha de validação de dados
class ValidationFailure extends AppFailure {
  final List<String> validationErrors;

  const ValidationFailure({required super.message, super.code, this.validationErrors = const [], super.exception});

  @override
  String get userMessage => validationErrors.isNotEmpty ? validationErrors.join(', ') : message;

  factory ValidationFailure.fromErrors(List<String> errors) {
    return ValidationFailure(
      message: 'Dados inválidos: ${errors.join(', ')}',
      code: 'VALIDATION_ERROR',
      validationErrors: errors,
    );
  }
}

/// Falha de rede/conectividade
class NetworkFailure extends AppFailure {
  final int? statusCode;

  const NetworkFailure({required super.message, super.code, this.statusCode, super.exception});

  @override
  String get userMessage => 'Falha na conexão. Verifique sua internet e tente novamente.';

  factory NetworkFailure.connectionTimeout() {
    return const NetworkFailure(message: 'Timeout na conexão', code: 'CONNECTION_TIMEOUT');
  }

  factory NetworkFailure.noInternet() {
    return const NetworkFailure(message: 'Sem conexão com a internet', code: 'NO_INTERNET');
  }

  factory NetworkFailure.serverError(int statusCode, [String? message]) {
    return NetworkFailure(message: message ?? 'Erro do servidor', code: 'SERVER_ERROR', statusCode: statusCode);
  }
}

/// Falha de autenticação/autorização
class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  factory AuthFailure.unauthenticated() {
    return const AuthFailure(message: 'Usuário não autenticado', code: 'UNAUTHENTICATED');
  }

  factory AuthFailure.unauthorized() {
    return const AuthFailure(message: 'Acesso negado', code: 'UNAUTHORIZED');
  }

  factory AuthFailure.invalidCredentials() {
    return const AuthFailure(message: 'Credenciais inválidas', code: 'INVALID_CREDENTIALS');
  }
}

/// Falha de dados/repositório
class DataFailure extends AppFailure {
  const DataFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => 'Erro ao processar dados. Tente novamente.';

  factory DataFailure.notFound(String entity) {
    return DataFailure(message: '$entity não encontrado', code: 'NOT_FOUND');
  }

  factory DataFailure.parsing(String details) {
    return DataFailure(message: 'Erro ao processar dados: $details', code: 'PARSING_ERROR');
  }

  factory DataFailure.repository(dynamic exception) {
    return DataFailure(
      message: 'Erro no repositório: ${exception.toString()}',
      code: 'REPOSITORY_ERROR',
      exception: exception,
    );
  }
}

/// Falha de regra de negócio
class BusinessFailure extends AppFailure {
  const BusinessFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => message;

  factory BusinessFailure.invalidState(String details) {
    return BusinessFailure(message: 'Estado inválido: $details', code: 'INVALID_STATE');
  }

  factory BusinessFailure.operationNotAllowed(String reason) {
    return BusinessFailure(message: 'Operação não permitida: $reason', code: 'OPERATION_NOT_ALLOWED');
  }
}

/// Falha genérica/desconhecida
class UnknownFailure extends AppFailure {
  const UnknownFailure({required super.message, super.code, super.exception});

  @override
  String get userMessage => 'Erro inesperado. Tente novamente.';

  factory UnknownFailure.fromException(dynamic exception) {
    return UnknownFailure(
      message: 'Erro inesperado: ${exception.toString()}',
      code: 'UNKNOWN_ERROR',
      exception: exception,
    );
  }
}
