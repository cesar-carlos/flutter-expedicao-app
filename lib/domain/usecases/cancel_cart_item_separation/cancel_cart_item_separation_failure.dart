import 'package:exp/core/results/index.dart';

/// Tipos de falha ao cancelar itens de separação
enum CancelCardItemSeparationFailureType {
  invalidParams('Parâmetros inválidos'),
  separationNotFound('Separação não encontrada'),
  itemsNotFound('Itens de separação não encontrados'),
  userNotFound('Usuário não encontrado'),
  updateSeparateItemFailed('Falha ao atualizar separate_item'),
  updateSeparationItemFailed('Falha ao atualizar separation_item'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const CancelCardItemSeparationFailureType(this.description);

  final String description;
}

/// Falha específica ao cancelar itens de separação
class CancelCardItemSeparationFailure extends AppFailure {
  final CancelCardItemSeparationFailureType type;
  final String? details;

  const CancelCardItemSeparationFailure({
    required this.type,
    required super.message,
    this.details,
    super.code,
    super.exception,
  });

  /// Cria uma falha de parâmetros inválidos
  factory CancelCardItemSeparationFailure.invalidParams(String details) {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.invalidParams,
      message: 'Parâmetros inválidos para cancelamento de itens',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_INVALID_PARAMS',
    );
  }

  /// Cria uma falha de separação não encontrada
  factory CancelCardItemSeparationFailure.separationNotFound() {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.separationNotFound,
      message: 'Separação não encontrada',
      code: 'CANCEL_ITEM_SEPARATION_NOT_FOUND',
    );
  }

  /// Cria uma falha de itens não encontrados
  factory CancelCardItemSeparationFailure.itemsNotFound() {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.itemsNotFound,
      message: 'Itens de separação não encontrados',
      code: 'CANCEL_ITEM_SEPARATION_ITEMS_NOT_FOUND',
    );
  }

  /// Cria uma falha de usuário não encontrado
  factory CancelCardItemSeparationFailure.userNotFound() {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'CANCEL_ITEM_SEPARATION_USER_NOT_FOUND',
    );
  }

  /// Cria uma falha de atualização do separate_item
  factory CancelCardItemSeparationFailure.updateSeparateItemFailed(String details, [Exception? originalException]) {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.updateSeparateItemFailed,
      message: 'Falha ao atualizar quantidades de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_SEPARATE_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de atualização do separation_item
  factory CancelCardItemSeparationFailure.updateSeparationItemFailed(String details, [Exception? originalException]) {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.updateSeparationItemFailed,
      message: 'Falha ao cancelar itens de separação',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UPDATE_SEPARATION_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de rede
  factory CancelCardItemSeparationFailure.networkError(String details, [Exception? originalException]) {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_NETWORK_ERROR',
      exception: originalException,
    );
  }

  /// Cria uma falha desconhecida
  factory CancelCardItemSeparationFailure.unknown(String details, [Exception? originalException]) {
    return CancelCardItemSeparationFailure(
      type: CancelCardItemSeparationFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'CANCEL_ITEM_SEPARATION_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == CancelCardItemSeparationFailureType.networkError;

  /// Verifica se é um erro de validação
  bool get isValidationError => type == CancelCardItemSeparationFailureType.invalidParams;

  /// Verifica se é um erro de negócio
  bool get isBusinessError => [
    CancelCardItemSeparationFailureType.separationNotFound,
    CancelCardItemSeparationFailureType.itemsNotFound,
    CancelCardItemSeparationFailureType.userNotFound,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case CancelCardItemSeparationFailureType.invalidParams:
        return 'Dados inválidos para cancelamento';
      case CancelCardItemSeparationFailureType.separationNotFound:
        return 'Separação não encontrada';
      case CancelCardItemSeparationFailureType.itemsNotFound:
        return 'Itens de separação não encontrados';
      case CancelCardItemSeparationFailureType.userNotFound:
        return 'Usuário não autenticado';
      case CancelCardItemSeparationFailureType.updateSeparateItemFailed:
        return 'Falha ao atualizar quantidades';
      case CancelCardItemSeparationFailureType.updateSeparationItemFailed:
        return 'Falha ao cancelar itens';
      case CancelCardItemSeparationFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case CancelCardItemSeparationFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('CancelCardItemSeparationFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
