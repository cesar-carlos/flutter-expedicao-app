import 'package:data7_expedicao/core/results/index.dart';

/// Tipos de falha ao cancelar um carrinho
enum CancelCartFailureType {
  invalidParams('Parâmetros inválidos'),
  cartNotFound('Carrinho não encontrado'),
  cartNotInSeparatingStatus('Carrinho não está em status de separação'),
  userNotFound('Usuário não encontrado'),
  cancellationFailed('Falha ao criar cancelamento'),
  updateFailed('Falha ao atualizar carrinho'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const CancelCartFailureType(this.description);
  final String description;
}

/// Falha específica ao cancelar um carrinho
class CancelCartFailure extends AppFailure {
  final CancelCartFailureType type;
  final String? details;

  const CancelCartFailure({required this.type, required super.message, this.details, super.code, super.exception});

  /// Cria uma falha de parâmetros inválidos
  factory CancelCartFailure.invalidParams(String details) {
    return CancelCartFailure(
      type: CancelCartFailureType.invalidParams,
      message: 'Parâmetros inválidos para cancelamento',
      details: details,
      code: 'CANCEL_CART_INVALID_PARAMS',
    );
  }

  /// Cria uma falha de carrinho não encontrado
  factory CancelCartFailure.cartNotFound() {
    return CancelCartFailure(
      type: CancelCartFailureType.cartNotFound,
      message: 'Carrinho não encontrado',
      code: 'CANCEL_CART_NOT_FOUND',
    );
  }

  /// Cria uma falha de status inválido
  factory CancelCartFailure.cartNotInSeparatingStatus(String currentStatus) {
    return CancelCartFailure(
      type: CancelCartFailureType.cartNotInSeparatingStatus,
      message: 'Carrinho não está em status de separação',
      details: 'Status atual: $currentStatus',
      code: 'CANCEL_CART_INVALID_STATUS',
    );
  }

  /// Cria uma falha de usuário não encontrado
  factory CancelCartFailure.userNotFound() {
    return CancelCartFailure(
      type: CancelCartFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'CANCEL_CART_USER_NOT_FOUND',
    );
  }

  /// Cria uma falha de cancelamento
  factory CancelCartFailure.cancellationFailed(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.cancellationFailed,
      message: 'Falha ao criar cancelamento',
      details: details,
      code: 'CANCEL_CART_CANCELLATION_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de atualização
  factory CancelCartFailure.updateFailed(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.updateFailed,
      message: 'Falha ao atualizar carrinho',
      details: details,
      code: 'CANCEL_CART_UPDATE_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de rede
  factory CancelCartFailure.networkError(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'CANCEL_CART_NETWORK_ERROR',
      exception: originalException,
    );
  }

  /// Cria uma falha desconhecida
  factory CancelCartFailure.unknown(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'CANCEL_CART_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == CancelCartFailureType.networkError;

  /// Verifica se é um erro de validação
  bool get isValidationError => type == CancelCartFailureType.invalidParams;

  /// Verifica se é um erro de negócio
  bool get isBusinessError => [
    CancelCartFailureType.cartNotFound,
    CancelCartFailureType.cartNotInSeparatingStatus,
    CancelCartFailureType.userNotFound,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case CancelCartFailureType.invalidParams:
        return 'Dados inválidos para cancelamento';
      case CancelCartFailureType.cartNotFound:
        return 'Carrinho não encontrado';
      case CancelCartFailureType.cartNotInSeparatingStatus:
        return 'Carrinho não pode ser cancelado no status atual';
      case CancelCartFailureType.userNotFound:
        return 'Usuário não autenticado';
      case CancelCartFailureType.cancellationFailed:
        return 'Falha ao cancelar carrinho';
      case CancelCartFailureType.updateFailed:
        return 'Falha ao atualizar carrinho';
      case CancelCartFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case CancelCartFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('CancelCartFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
