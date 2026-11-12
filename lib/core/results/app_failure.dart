import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/errors/socket_error_parser.dart';
import 'package:data7_expedicao/core/errors/user_facing_message.dart';

abstract class AppFailure implements Exception {
  final String message;

  final String? code;

  final dynamic exception;

  const AppFailure({required this.message, this.code, this.exception});

  String get userMessage => UserFacingMessage.fromText(message);

  /// Mensagem para a tela a partir de qualquer erro capturado.
  static String forUser(Object? error, {String fallback = UserFacingMessage.fallback}) {
    if (error is AppFailure) {
      return error.userMessage;
    }
    if (error is AppError) {
      return UserFacingMessage.fromText(error.message, fallback: fallback);
    }
    return UserFacingMessage.fromText(error?.toString(), fallback: fallback);
  }

  /// Converte erro de repositório, envelope Socket.IO ou falha já tipada.
  factory AppFailure.fromCaught(Object error) {
    if (error is AppFailure) {
      return error;
    }
    if (error is DataError) {
      return AppFailure.fromDataError(error);
    }
    if (error is NetworkError) {
      return NetworkFailure(message: error.message, code: error.code, exception: error);
    }
    if (error is AppError) {
      return UnknownFailure(message: error.message, code: error.code, exception: error);
    }
    return UnknownFailure.fromException(error);
  }

  factory AppFailure.fromDataError(DataError error) {
    final fromMessage = SocketErrorInfo(
      message: error.message,
      identifier: SocketErrorInfo.identifierOf(error.message) ?? error.code?.toUpperCase(),
      contractCode: error.code?.toUpperCase(),
    );

    if (fromMessage.isUnauthorized) {
      return AuthFailure(message: error.message, code: fromMessage.identifier, exception: error);
    }
    if (fromMessage.isInvalidPayload) {
      return ValidationFailure(
        message: error.message,
        code: fromMessage.identifier ?? 'INVALID_PAYLOAD',
        validationErrors: <String>[error.message],
        exception: error,
      );
    }
    if (fromMessage.isNotFound) {
      return DataFailure(message: error.message, code: fromMessage.identifier ?? 'NOT_FOUND', exception: error);
    }
    if (fromMessage.isBusinessRule) {
      return BusinessFailure(
        message: error.message,
        code: fromMessage.identifier ?? 'BUSINESS_RULE_VIOLATION',
        exception: error,
      );
    }
    if (fromMessage.identifier == 'INTERNAL_ERROR') {
      return DataFailure(message: error.message, code: 'INTERNAL_ERROR', exception: error);
    }
    if (fromMessage.identifier != null &&
        fromMessage.identifier!.startsWith('SQL-') &&
        fromMessage.identifier != 'SQL-CONN') {
      return DataFailure(message: error.message, code: fromMessage.identifier, exception: error);
    }
    if (fromMessage.isConnection) {
      return NetworkFailure(
        message: error.message,
        code: fromMessage.identifier ?? 'NETWORK_ERROR',
        exception: error,
      );
    }

    return DataFailure(message: error.message, code: error.code ?? 'REPOSITORY_ERROR', exception: error);
  }

  @override
  String toString() {
    if (code == null) {
      return '$runtimeType($message)';
    }
    return '$runtimeType($message, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    // Bug VVVVVVVVVV: antes era `other is AppFailure` (classe abstrata),
    // que sempre era true para QUALQUER subclasse. Significa que
    // `NetworkFailure(message: 'X', code: 'Y')` era considerado IGUAL
    // a `DataFailure(message: 'X', code: 'Y')` — quebrando comparacoes
    // em testes (ex.: expect(failure, isA<NetworkFailure>()) passa,
    // mas equals para um DataFailure tambem passava). Agora exige
    // mesmo tipo concreto.
    return other.runtimeType == runtimeType &&
        other is AppFailure &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);
}

class ValidationFailure extends AppFailure {
  final List<String> validationErrors;

  const ValidationFailure({required super.message, super.code, this.validationErrors = const [], super.exception});

  @override
  String get userMessage {
    if (validationErrors.isNotEmpty) {
      return UserFacingMessage.fromText(validationErrors.join(', '));
    }
    return UserFacingMessage.fromText(message);
  }

  factory ValidationFailure.fromErrors(List<String> errors) {
    return ValidationFailure(
      message: 'Dados inválidos: ${errors.join(', ')}',
      code: 'VALIDATION_ERROR',
      validationErrors: errors,
    );
  }
}

class NetworkFailure extends AppFailure {
  final int? statusCode;

  const NetworkFailure({required super.message, super.code, this.statusCode, super.exception});

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

class AuthFailure extends AppFailure {
  const AuthFailure({required super.message, super.code, super.exception});

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

class DataFailure extends AppFailure {
  const DataFailure({required super.message, super.code, super.exception});

  factory DataFailure.notFound(String entity) {
    return DataFailure(message: '$entity não encontrado', code: 'NOT_FOUND');
  }

  factory DataFailure.parsing(String details) {
    return DataFailure(message: 'Erro ao processar dados: $details', code: 'PARSING_ERROR');
  }

  factory DataFailure.repository(dynamic exception) {
    return DataFailure(
      message: UserFacingMessage.fromText(exception?.toString(), fallback: 'Erro no repositório'),
      code: 'REPOSITORY_ERROR',
      exception: exception,
    );
  }
}

class BusinessFailure extends AppFailure {
  const BusinessFailure({required super.message, super.code, super.exception});

  factory BusinessFailure.invalidState(String details) {
    return BusinessFailure(message: 'Estado inválido: $details', code: 'INVALID_STATE');
  }

  factory BusinessFailure.operationNotAllowed(String reason) {
    return BusinessFailure(message: 'Operação não permitida: $reason', code: 'OPERATION_NOT_ALLOWED');
  }
}

class UnknownFailure extends AppFailure {
  const UnknownFailure({required super.message, super.code, super.exception});

  factory UnknownFailure.fromException(dynamic exception) {
    return UnknownFailure(
      message: exception?.toString() ?? UserFacingMessage.fallback,
      code: 'UNKNOWN_ERROR',
      exception: exception,
    );
  }
}
