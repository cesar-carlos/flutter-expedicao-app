import 'package:exp/core/results/index.dart';

/// Tipos de falha ao adicionar itens na separação
enum AddItemSeparationFailureType {
  invalidParams('Parâmetros inválidos'),
  userNotFound('Usuário não encontrado'),
  separateItemNotFound('Item de separação não encontrado'),
  insufficientQuantity('Quantidade insuficiente disponível'),
  insertSeparationItemFailed('Falha ao inserir item de separação'),
  updateSeparateItemFailed('Falha ao atualizar separate_item'),
  networkError('Erro de rede'),
  unknownError('Erro desconhecido');

  const AddItemSeparationFailureType(this.description);
  final String description;
}

/// Falha específica ao adicionar itens na separação
class AddItemSeparationFailure extends AppFailure {
  final AddItemSeparationFailureType type;
  final String? details;

  const AddItemSeparationFailure({
    required this.type,
    required super.message,
    this.details,
    super.code,
    super.exception,
  });

  /// Cria uma falha de parâmetros inválidos
  factory AddItemSeparationFailure.invalidParams(String details) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.invalidParams,
      message: 'Parâmetros inválidos para adição de itens',
      details: details,
      code: 'ADD_ITEM_SEPARATION_INVALID_PARAMS',
    );
  }

  /// Cria uma falha de usuário não encontrado
  factory AddItemSeparationFailure.userNotFound() {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.userNotFound,
      message: 'Usuário não encontrado',
      code: 'ADD_ITEM_SEPARATION_USER_NOT_FOUND',
    );
  }

  /// Cria uma falha de item de separação não encontrado
  factory AddItemSeparationFailure.separateItemNotFound(int codProduto) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.separateItemNotFound,
      message: 'Item de separação não encontrado',
      details: 'Produto código: $codProduto',
      code: 'ADD_ITEM_SEPARATION_ITEM_NOT_FOUND',
    );
  }

  /// Cria uma falha de quantidade insuficiente
  factory AddItemSeparationFailure.insufficientQuantity({
    required double requested,
    required double available,
    required int codProduto,
  }) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.insufficientQuantity,
      message: 'Quantidade insuficiente disponível',
      details:
          'Produto $codProduto: solicitado ${requested.toStringAsFixed(4)}, disponível ${available.toStringAsFixed(4)}',
      code: 'ADD_ITEM_SEPARATION_INSUFFICIENT_QUANTITY',
    );
  }

  /// Cria uma falha de inserção do separation_item
  factory AddItemSeparationFailure.insertSeparationItemFailed(String details, [Exception? originalException]) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.insertSeparationItemFailed,
      message: 'Falha ao inserir item de separação',
      details: details,
      code: 'ADD_ITEM_SEPARATION_INSERT_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de atualização do separate_item
  factory AddItemSeparationFailure.updateSeparateItemFailed(String details, [Exception? originalException]) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.updateSeparateItemFailed,
      message: 'Falha ao atualizar quantidades de separação',
      details: details,
      code: 'ADD_ITEM_SEPARATION_UPDATE_FAILED',
      exception: originalException,
    );
  }

  /// Cria uma falha de rede
  factory AddItemSeparationFailure.networkError(String details, [Exception? originalException]) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.networkError,
      message: 'Erro de rede',
      details: details,
      code: 'ADD_ITEM_SEPARATION_NETWORK_ERROR',
      exception: originalException,
    );
  }

  /// Cria uma falha desconhecida
  factory AddItemSeparationFailure.unknown(String details, [Exception? originalException]) {
    return AddItemSeparationFailure(
      type: AddItemSeparationFailureType.unknownError,
      message: 'Erro desconhecido',
      details: details,
      code: 'ADD_ITEM_SEPARATION_UNKNOWN_ERROR',
      exception: originalException,
    );
  }

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == AddItemSeparationFailureType.networkError;

  /// Verifica se é um erro de validação
  bool get isValidationError => type == AddItemSeparationFailureType.invalidParams;

  /// Verifica se é um erro de negócio
  bool get isBusinessError => [
    AddItemSeparationFailureType.separateItemNotFound,
    AddItemSeparationFailureType.insufficientQuantity,
    AddItemSeparationFailureType.userNotFound,
  ].contains(type);

  /// Verifica se é um erro de operação
  bool get isOperationError => [
    AddItemSeparationFailureType.insertSeparationItemFailed,
    AddItemSeparationFailureType.updateSeparateItemFailed,
  ].contains(type);

  @override
  String get userMessage {
    switch (type) {
      case AddItemSeparationFailureType.invalidParams:
        return 'Dados inválidos para adicionar item';
      case AddItemSeparationFailureType.userNotFound:
        return 'Usuário não autenticado';
      case AddItemSeparationFailureType.separateItemNotFound:
        return 'Item não encontrado para separação';
      case AddItemSeparationFailureType.insufficientQuantity:
        return 'Quantidade solicitada maior que disponível';
      case AddItemSeparationFailureType.insertSeparationItemFailed:
        return 'Falha ao registrar item na separação';
      case AddItemSeparationFailureType.updateSeparateItemFailed:
        return 'Falha ao atualizar quantidades';
      case AddItemSeparationFailureType.networkError:
        return 'Erro de conexão. Verifique sua internet';
      case AddItemSeparationFailureType.unknownError:
        return 'Erro inesperado. Tente novamente';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('AddItemSeparationFailure(type: ${type.description}, message: $message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}
