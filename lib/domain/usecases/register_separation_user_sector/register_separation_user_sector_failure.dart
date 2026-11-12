import 'package:data7_expedicao/core/results/index.dart';

enum RegisterSeparationUserSectorFailureType {
  invalidParams('Parâmetros inválidos'),
  insertError('Erro ao inserir'),
  networkError('Erro de rede'),
  unknown('Erro desconhecido');

  const RegisterSeparationUserSectorFailureType(this.description);
  final String description;
}

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

  factory RegisterSeparationUserSectorFailure.invalidParams(String details) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.invalidParams,
      message: 'Parâmetros inválidos: $details',
      details: details,
      code: 'INVALID_PARAMS',
    );
  }

  factory RegisterSeparationUserSectorFailure.insertError(String details, Exception exception) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.insertError,
      message: 'Erro ao inserir registro: $details',
      details: details,
      code: 'INSERT_ERROR',
      exception: exception,
    );
  }

  factory RegisterSeparationUserSectorFailure.networkError(String details, Exception exception) {
    return RegisterSeparationUserSectorFailure(
      type: RegisterSeparationUserSectorFailureType.networkError,
      message: 'Erro de rede: $details',
      details: details,
      code: 'NETWORK_ERROR',
      exception: exception,
    );
  }

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
        return UserFacingMessage.prefer(details, 'Não foi possível registrar a atribuição do usuário');
      case RegisterSeparationUserSectorFailureType.networkError:
        return UserFacingMessage.prefer(details, 'Não foi possível conectar ao servidor para registrar a atribuição.');
      case RegisterSeparationUserSectorFailureType.unknown:
        return UserFacingMessage.prefer(details, 'Não foi possível registrar a atribuição do usuário');
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
