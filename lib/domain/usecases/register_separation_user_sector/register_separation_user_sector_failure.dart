import 'package:data7_expedicao/core/results/index.dart';

/// Tipos de falha no registro de atribuição usuário/setor
enum RegisterSeparationUserSectorFailureType {
  invalidParams('Parâmetros inválidos'),
  insertError('Erro ao inserir'),
  networkError('Erro de rede'),
  unknown('Erro desconhecido');

  const RegisterSeparationUserSectorFailureType(this.description);
  final String description;
}

/// Resposta de falha para registro de atribuição usuário/setor
class RegisterSeparationUserSectorFailure extends AppFailure {
  final RegisterSeparationUserSectorFailureType type;
  final String? details;

  const RegisterSeparationUserSectorFailure({
    required this.type,
    required super.message,
    this.details,
    super.code,
    super.exception,
  });

  /// Factory: Parâmetros inválidos
  factory RegisterSeparationUserSectorFailure.invalidParams(String details) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.invalidParams,
      message: 'Parâmetros inválidos: $details',
      details: details,
      code: 'INVALID_PARAMS',
    );
  }

  /// Factory: Erro ao inserir registro
  factory RegisterSeparationUserSectorFailure.insertError(String details, Exception exception) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.insertError,
      message: 'Erro ao inserir registro: $details',
      details: details,
      code: 'INSERT_ERROR',
      exception: exception,
    );
  }

  /// Factory: Erro de rede
  factory RegisterSeparationUserSectorFailure.networkError(String details, Exception exception) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.networkError,
      message: 'Erro de rede: $details',
      details: details,
      code: 'NETWORK_ERROR',
      exception: exception,
    );
  }

  /// Factory: Erro desconhecido
  factory RegisterSeparationUserSectorFailure.unknown(String details, Exception exception) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.unknown,
      message: 'Erro desconhecido: $details',
      details: details,
      code: 'UNKNOWN_ERROR',
      exception: exception,
    );
  }

  @override
  String get userMessage {
    switch (type) {
      case RegisterSeparationUserSectorFailureType.invalidParams:
        return 'Dados inválidos para registro de atribuição';
      case RegisterSeparationUserSectorFailureType.insertError:
        return 'Não foi possível registrar a atribuição do usuário';
      case RegisterSeparationUserSectorFailureType.networkError:
        return 'Erro de conexão ao registrar atribuição';
      case RegisterSeparationUserSectorFailureType.unknown:
        return 'Erro inesperado ao registrar atribuição';
    }
  }

  @override
  String toString() {
    return 'RegisterSeparationUserSectorFailure('
        'type: $type, '
        'message: $message, '
        'details: $details, '
        'code: $code, '
        'exception: $exception'
        ')';
  }
}
