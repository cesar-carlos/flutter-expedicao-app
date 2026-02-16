import 'package:data7_expedicao/core/results/index.dart';

enum NextSeparationUserFailureType {
  userWithoutSector('Usuário sem setor estoque'),
  invalidParams('Parâmetros inválidos'),
  socketDisconnected('Socket desconectado'),
  networkError('Erro de rede'),
  serverError('Erro no servidor'),
  unknownError('Erro desconhecido');

  const NextSeparationUserFailureType(this.description);
  final String description;
}

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

  factory NextSeparationUserFailure.userWithoutSector() {
    return const NextSeparationUserFailure(
      type: NextSeparationUserFailureType.userWithoutSector,
      message: 'Usuário não possui setor estoque',
      code: 'USER_WITHOUT_SECTOR',
    );
  }

  factory NextSeparationUserFailure.invalidParams(String details) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.invalidParams,
      message: 'Parâmetros inválidos',
      details: details,
      code: 'INVALID_PARAMS',
    );
  }

  factory NextSeparationUserFailure.socketDisconnected() {
    return const NextSeparationUserFailure(
      type: NextSeparationUserFailureType.socketDisconnected,
      message: 'Socket não está conectado',
      code: 'SOCKET_DISCONNECTED',
    );
  }

  factory NextSeparationUserFailure.networkError(String details, Exception? exception) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'NETWORK_ERROR',
      exception: exception,
    );
  }

  factory NextSeparationUserFailure.unknown(String details, Exception? exception) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'UNKNOWN_ERROR',
      exception: exception,
    );
  }

  factory NextSeparationUserFailure.serverError(String details) {
    return NextSeparationUserFailure(
      type: NextSeparationUserFailureType.serverError,
      message: 'Erro no servidor',
      details: details,
      code: 'SERVER_ERROR',
    );
  }

  bool get isValidationError =>
      type == NextSeparationUserFailureType.invalidParams || type == NextSeparationUserFailureType.userWithoutSector;

  bool get isNetworkError => type == NextSeparationUserFailureType.networkError;

  bool get isSocketDisconnected => type == NextSeparationUserFailureType.socketDisconnected;

  @override
  String get userMessage {
    switch (type) {
      case NextSeparationUserFailureType.userWithoutSector:
        return 'Usuário não possui setor estoque configurado';
      case NextSeparationUserFailureType.invalidParams:
        return 'Dados inválidos para buscar separação';
      case NextSeparationUserFailureType.socketDisconnected:
        return 'Conexão em tempo real indisponível no momento. Verifique o indicador de conexão e tente novamente.';
      case NextSeparationUserFailureType.networkError:
        if (details != null && details!.trim().isNotEmpty) {
          return details!.trim();
        }
        return 'Não foi possível conectar ao servidor. Verifique sua conexão com a rede.';
      case NextSeparationUserFailureType.serverError:
        return 'Erro no servidor ao processar a consulta. Tente novamente.';
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
