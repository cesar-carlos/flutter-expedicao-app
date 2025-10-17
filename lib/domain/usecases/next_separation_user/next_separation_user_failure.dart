import 'package:data7_expedicao/core/results/index.dart';

/// Tipos de falha ao buscar a próxima separação para o usuário
enum NextSeparationUserFailureType {
  userWithoutSector('Usuário sem setor estoque'),
  invalidParams('Parâmetros inválidos'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const NextSeparationUserFailureType(this.description);
  final String description;
}

/// Falha ao buscar a próxima separação para o usuário
class NextSeparationUserFailure extends AppFailure {
  final NextSeparationUserFailureType type;
  final String? details;

  const NextSeparationUserFailure({
    required this.type,
    required super.message,
    this.details,
    super.code,
    super.exception,
  });

  /// Falha quando o usuário não possui setor estoque configurado
  factory NextSeparationUserFailure.userWithoutSector() {
    return const NextSeparationUserFailure(
      type: NextSeparationUserFailureType.userWithoutSector,
      message: 'Usuário não possui setor estoque',
      code: 'USER_WITHOUT_SECTOR',
    );
  }

  /// Falha por parâmetros inválidos
  factory NextSeparationUserFailure.invalidParams(String details) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.invalidParams,
      message: 'Parâmetros inválidos',
      details: details,
      code: 'INVALID_PARAMS',
    );
  }

  /// Falha por erro de rede/comunicação
  factory NextSeparationUserFailure.networkError(String details, Exception? exception) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'NETWORK_ERROR',
      exception: exception,
    );
  }

  /// Falha desconhecida
  factory NextSeparationUserFailure.unknown(String details, Exception? exception) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'UNKNOWN_ERROR',
      exception: exception,
    );
  }

  /// Verifica se é um erro de validação
  bool get isValidationError =>
      type == NextSeparationUserFailureType.invalidParams || type == NextSeparationUserFailureType.userWithoutSector;

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == NextSeparationUserFailureType.networkError;

  @override
  String get userMessage {
    switch (type) {
      case NextSeparationUserFailureType.userWithoutSector:
        return 'Usuário não possui setor estoque configurado';
      case NextSeparationUserFailureType.invalidParams:
        return 'Dados inválidos para buscar separação';
      case NextSeparationUserFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case NextSeparationUserFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('NextSeparationUserFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
