import 'package:exp/domain/usecases/cancel_cart/cancel_cart_result.dart';

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

/// Resultado de falha ao cancelar um carrinho
class CancelCartFailure extends CancelCartResult {
  final CancelCartFailureType type;
  @override
  final String message;
  final String? details;
  final Exception? originalException;

  const CancelCartFailure({required this.type, required this.message, this.details, this.originalException});

  /// Cria uma falha de parâmetros inválidos
  factory CancelCartFailure.invalidParams(String details) {
    return CancelCartFailure(
      type: CancelCartFailureType.invalidParams,
      message: 'Parâmetros inválidos para cancelamento',
      details: details,
    );
  }

  /// Cria uma falha de carrinho não encontrado
  factory CancelCartFailure.cartNotFound() {
    return CancelCartFailure(type: CancelCartFailureType.cartNotFound, message: 'Carrinho não encontrado');
  }

  /// Cria uma falha de status inválido
  factory CancelCartFailure.cartNotInSeparatingStatus(String currentStatus) {
    return CancelCartFailure(
      type: CancelCartFailureType.cartNotInSeparatingStatus,
      message: 'Carrinho não está em status de separação',
      details: 'Status atual: $currentStatus',
    );
  }

  /// Cria uma falha de usuário não encontrado
  factory CancelCartFailure.userNotFound() {
    return CancelCartFailure(type: CancelCartFailureType.userNotFound, message: 'Usuário não encontrado');
  }

  /// Cria uma falha de cancelamento
  factory CancelCartFailure.cancellationFailed(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.cancellationFailed,
      message: 'Falha ao criar cancelamento',
      details: details,
      originalException: originalException,
    );
  }

  /// Cria uma falha de atualização
  factory CancelCartFailure.updateFailed(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.updateFailed,
      message: 'Falha ao atualizar carrinho',
      details: details,
      originalException: originalException,
    );
  }

  /// Cria uma falha de rede
  factory CancelCartFailure.networkError(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      originalException: originalException,
    );
  }

  /// Cria uma falha desconhecida
  factory CancelCartFailure.unknown(String details, [Exception? originalException]) {
    return CancelCartFailure(
      type: CancelCartFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      originalException: originalException,
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelCartFailure && other.type == type && other.message == message && other.details == details;
  }

  @override
  int get hashCode => type.hashCode ^ message.hashCode ^ details.hashCode;

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
