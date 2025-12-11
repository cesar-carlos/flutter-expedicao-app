import 'package:data7_expedicao/core/results/index.dart';

enum CancelItemSeparationFailureType {
  invalidParams('Parâmetros inválidos'),
  userNotFound('Usuário não encontrado'),
  separationItemNotFound('Item de separação não encontrado'),
  separateItemNotFound('Item base não encontrado'),
  separateNotFound('Separação não encontrada'),
  itemAlreadyCancelled('Item já foi cancelado'),
  separateNotInSeparatingState('Separação não está em situação de separando'),
  updateSeparateItemFailed('Falha ao atualizar separate_item'),
  updateSeparationItemFailed('Falha ao atualizar separation_item'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const CancelItemSeparationFailureType(this.description);
  final String description;
}

class CancelItemSeparationFailure extends AppFailure {
  final CancelItemSeparationFailureType type;
  final String? details;

  const CancelItemSeparationFailure({
    required this.type,
    required super.message,
    this.details,
    super.code,
    super.exception,
  });

  factory CancelItemSeparationFailure.invalidParams(String details) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.invalidParams,
      message: 'Parâmetros inválidos para cancelamento de item',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_INVALID_PARAMS',
    );
  }

  factory CancelItemSeparationFailure.userNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'CANCEL_ITEM_SEPARATION_USER_NOT_FOUND',
    );
  }

  factory CancelItemSeparationFailure.separationItemNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.separationItemNotFound,
      message: 'Item de separação não encontrado',
      code: 'CANCEL_ITEM_SEPARATION_ITEM_NOT_FOUND',
    );
  }

  factory CancelItemSeparationFailure.separateItemNotFound(int codProduto) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.separateItemNotFound,
      message: 'Item base não encontrado',
      details: 'Produto código: $codProduto',
      code: 'CANCEL_ITEM_SEPARATION_BASE_ITEM_NOT_FOUND',
    );
  }

  factory CancelItemSeparationFailure.itemAlreadyCancelled() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.itemAlreadyCancelled,
      message: 'Item já foi cancelado',
      code: 'CANCEL_ITEM_SEPARATION_ALREADY_CANCELLED',
    );
  }

  factory CancelItemSeparationFailure.separateNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.separateNotFound,
      message: 'Separação não encontrada',
      code: 'CANCEL_ITEM_SEPARATION_SEPARATE_NOT_FOUND',
    );
  }

  factory CancelItemSeparationFailure.separateNotInSeparatingState() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.separateNotInSeparatingState,
      message: 'Separação não está em situação de separando',
      code: 'CANCEL_ITEM_SEPARATION_NOT_IN_SEPARATING_STATE',
    );
  }

  factory CancelItemSeparationFailure.updateSeparateItemFailed(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.updateSeparateItemFailed,
      message: 'Falha ao atualizar quantidades de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_SEPARATE_FAILED',
      exception: originalException,
    );
  }

  factory CancelItemSeparationFailure.updateSeparationItemFailed(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.updateSeparationItemFailed,
      message: 'Falha ao cancelar item de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_ITEM_FAILED',
      exception: originalException,
    );
  }

  factory CancelItemSeparationFailure.networkError(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_NETWORK_ERROR',
      exception: originalException,
    );
  }

  factory CancelItemSeparationFailure.unknown(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  bool get isNetworkError => type == CancelItemSeparationFailureType.networkError;

  bool get isValidationError => type == CancelItemSeparationFailureType.invalidParams;

  bool get isBusinessError => [
    CancelItemSeparationFailureType.separationItemNotFound,
    CancelItemSeparationFailureType.separateItemNotFound,
    CancelItemSeparationFailureType.separateNotFound,
    CancelItemSeparationFailureType.itemAlreadyCancelled,
    CancelItemSeparationFailureType.separateNotInSeparatingState,
    CancelItemSeparationFailureType.userNotFound,
  ].contains(type);

  bool get isOperationError => [
    CancelItemSeparationFailureType.updateSeparateItemFailed,
    CancelItemSeparationFailureType.updateSeparationItemFailed,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case CancelItemSeparationFailureType.invalidParams:
        return 'Dados inválidos para cancelar item';
      case CancelItemSeparationFailureType.userNotFound:
        return 'Usuário não autenticado';
      case CancelItemSeparationFailureType.separationItemNotFound:
        return 'Item de separação não encontrado';
      case CancelItemSeparationFailureType.separateItemNotFound:
        return 'Item base não encontrado';
      case CancelItemSeparationFailureType.separateNotFound:
        return 'Separação não encontrada';
      case CancelItemSeparationFailureType.itemAlreadyCancelled:
        return 'Item já foi cancelado';
      case CancelItemSeparationFailureType.separateNotInSeparatingState:
        return 'Separação não está em processo de separação';
      case CancelItemSeparationFailureType.updateSeparateItemFailed:
        return 'Falha ao atualizar quantidades';
      case CancelItemSeparationFailureType.updateSeparationItemFailed:
        return 'Falha ao cancelar item';
      case CancelItemSeparationFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case CancelItemSeparationFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('CancelItemSeparationFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
