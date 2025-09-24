import 'package:exp/core/results/index.dart';

/// Tipos de falha ao cancelar itens de separação
enum CancelItemSeparationFailureType {
  invalidParams('Parâmetros inválidos'),
  separationNotFound('Separação não encontrada'),
  itemsNotFound('Itens de separação não encontrados'),
  userNotFound('Usuário não encontrado'),
  updateSeparateItemFailed('Falha ao atualizar separate_item'),
  updateSeparationItemFailed('Falha ao atualizar separation_item'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const CancelItemSeparationFailureType(this.description);

  final String description;
}

/// Falha específica ao cancelar itens de separação
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

  /// Cria uma falha de parâmetros inválidos
  factory CancelItemSeparationFailure.invalidParams(String details) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.invalidParams,
      message: 'Parâmetros inválidos para cancelamento de itens',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_INVALID_PARAMS',
    );
  }

  /// Cria uma falha de separação não encontrada
  factory CancelItemSeparationFailure.separationNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.separationNotFound,
      message: 'Separação não encontrada',
      code: 'CANCEL_ITEM_SEPARATION_NOT_FOUND',
    );
  }

  /// Cria uma falha de itens não encontrados
  factory CancelItemSeparationFailure.itemsNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.itemsNotFound,
      message: 'Itens de separação não encontrados',
      code: 'CANCEL_ITEM_SEPARATION_ITEMS_NOT_FOUND',
    );
  }

  /// Cria uma falha de usuário não encontrado
  factory CancelItemSeparationFailure.userNotFound() {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'CANCEL_ITEM_SEPARATION_USER_NOT_FOUND',
    );
  }

  /// Cria uma falha de atualização do separate_item
  factory CancelItemSeparationFailure.updateSeparateItemFailed(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.updateSeparateItemFailed,
      message: 'Falha ao atualizar quantidades de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_SEPARATE_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de atualização do separation_item
  factory CancelItemSeparationFailure.updateSeparationItemFailed(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.updateSeparationItemFailed,
      message: 'Falha ao cancelar itens de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_SEPARATION_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de rede
  factory CancelItemSeparationFailure.networkError(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_NETWORK_ERROR',
      exception: originalException,
    );
  }

  /// Cria uma falha desconhecida
  factory CancelItemSeparationFailure.unknown(String details, [Exception? originalException]) {
    return CancelItemSeparationFailure(
      type: CancelItemSeparationFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == CancelItemSeparationFailureType.networkError;

  /// Verifica se é um erro de validação
  bool get isValidationError => type == CancelItemSeparationFailureType.invalidParams;

  /// Verifica se é um erro de negócio
  bool get isBusinessError => [
    CancelItemSeparationFailureType.separationNotFound,
    CancelItemSeparationFailureType.itemsNotFound,
    CancelItemSeparationFailureType.userNotFound,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case CancelItemSeparationFailureType.invalidParams:
        return 'Dados inválidos para cancelamento';
      case CancelItemSeparationFailureType.separationNotFound:
        return 'Separação não encontrada';
      case CancelItemSeparationFailureType.itemsNotFound:
        return 'Itens de separação não encontrados';
      case CancelItemSeparationFailureType.userNotFound:
        return 'Usuário não autenticado';
      case CancelItemSeparationFailureType.updateSeparateItemFailed:
        return 'Falha ao atualizar quantidades';
      case CancelItemSeparationFailureType.updateSeparationItemFailed:
        return 'Falha ao cancelar itens';
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
