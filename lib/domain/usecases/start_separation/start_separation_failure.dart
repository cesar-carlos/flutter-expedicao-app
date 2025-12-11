import 'package:data7_expedicao/core/results/index.dart';

enum StartSeparationFailureType {
  invalidParams('Parâmetros inválidos'),
  separationNotFound('Separação não encontrada'),
  separationNotInAwaitingStatus('Separação não está aguardando'),
  separationAlreadyStarted('Já existe separação em andamento'),
  userNotFound('Usuário não encontrado'),
  insertCartRouteFailed('Falha ao criar percurso do carrinho'),
  updateSeparateFailed('Falha ao atualizar separação'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const StartSeparationFailureType(this.description);
  final String description;
}

class StartSeparationFailure extends AppFailure {
  final StartSeparationFailureType type;
  final String? details;

  const StartSeparationFailure({required this.type, required super.message, this.details, super.code, super.exception});

  factory StartSeparationFailure.invalidParams(String details) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.invalidParams,
      message: 'Parâmetros inválidos para iniciar separação',
      details: details,
      code: 'START_SEPARATION_INVALID_PARAMS',
    );
  }

  factory StartSeparationFailure.separationNotFound(int codEmpresa, String origem, int codOrigem) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.separationNotFound,
      message: 'Separação não encontrada',
      details: 'Empresa: $codEmpresa, Origem: $origem, CodOrigem: $codOrigem',
      code: 'START_SEPARATION_NOT_FOUND',
    );
  }

  factory StartSeparationFailure.separationNotInAwaitingStatus(String currentStatus) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.separationNotInAwaitingStatus,
      message: 'Separação não está com situação AGUARDANDO',
      details: 'Situação atual: $currentStatus',
      code: 'START_SEPARATION_INVALID_STATUS',
    );
  }

  factory StartSeparationFailure.separationAlreadyStarted(int codCarrinhoPercurso) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.separationAlreadyStarted,
      message: 'Já existe separação em andamento para esta origem',
      details: 'Código do carrinho percurso: $codCarrinhoPercurso',
      code: 'START_SEPARATION_ALREADY_STARTED',
    );
  }

  factory StartSeparationFailure.userNotFound() {
    return StartSeparationFailure(
      type: StartSeparationFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'START_SEPARATION_USER_NOT_FOUND',
    );
  }

  factory StartSeparationFailure.insertCartRouteFailed(String details, [Exception? originalException]) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.insertCartRouteFailed,
      message: 'Falha ao criar percurso do carrinho',
      details: details,
      code: 'START_SEPARATION_INSERT_CART_ROUTE_FAILED',
      exception: originalException,
    );
  }

  factory StartSeparationFailure.updateSeparateFailed(String details, [Exception? originalException]) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.updateSeparateFailed,
      message: 'Falha ao atualizar situação da separação',
      details: details,
      code: 'START_SEPARATION_UPDATE_SEPARATE_FAILED',
      exception: originalException,
    );
  }

  factory StartSeparationFailure.networkError(String details, [Exception? originalException]) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'START_SEPARATION_NETWORK_ERROR',
      exception: originalException,
    );
  }

  factory StartSeparationFailure.unknown(String details, [Exception? originalException]) {
    return StartSeparationFailure(
      type: StartSeparationFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'START_SEPARATION_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  bool get isNetworkError => type == StartSeparationFailureType.networkError;

  bool get isValidationError => type == StartSeparationFailureType.invalidParams;

  bool get isBusinessError => [
    StartSeparationFailureType.separationNotFound,
    StartSeparationFailureType.separationNotInAwaitingStatus,
    StartSeparationFailureType.separationAlreadyStarted,
    StartSeparationFailureType.userNotFound,
  ].contains(type);

  bool get isOperationError => [
    StartSeparationFailureType.insertCartRouteFailed,
    StartSeparationFailureType.updateSeparateFailed,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case StartSeparationFailureType.invalidParams:
        return 'Dados inválidos para iniciar separação';
      case StartSeparationFailureType.separationNotFound:
        return 'Separação não encontrada';
      case StartSeparationFailureType.separationNotInAwaitingStatus:
        return 'Separação não pode ser iniciada. Status inválido';
      case StartSeparationFailureType.separationAlreadyStarted:
        return 'Já existe uma separação em andamento';
      case StartSeparationFailureType.userNotFound:
        return 'Usuário não autenticado';
      case StartSeparationFailureType.insertCartRouteFailed:
        return 'Falha ao criar percurso do carrinho';
      case StartSeparationFailureType.updateSeparateFailed:
        return 'Falha ao atualizar separação';
      case StartSeparationFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case StartSeparationFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('StartSeparationFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
