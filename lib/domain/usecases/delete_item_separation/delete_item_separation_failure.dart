/// Falhas possíveis na exclusão de item de separação
class DeleteItemSeparationFailure {
  final String message;
  final String code;
  final Exception? exception;

  const DeleteItemSeparationFailure._({required this.message, required this.code, this.exception});

  /// Parâmetros inválidos
  factory DeleteItemSeparationFailure.invalidParams(String message) {
    return DeleteItemSeparationFailure._(message: message, code: 'INVALID_PARAMS');
  }

  /// Usuário não encontrado ou não autenticado
  factory DeleteItemSeparationFailure.userNotFound() {
    return DeleteItemSeparationFailure._(message: 'Usuário não encontrado ou não autenticado', code: 'USER_NOT_FOUND');
  }

  /// Item de separação não encontrado
  factory DeleteItemSeparationFailure.separationItemNotFound() {
    return DeleteItemSeparationFailure._(
      message: 'Item de separação não encontrado',
      code: 'SEPARATION_ITEM_NOT_FOUND',
    );
  }

  /// Item base não encontrado
  factory DeleteItemSeparationFailure.separateItemNotFound(int codProduto) {
    return DeleteItemSeparationFailure._(
      message: 'Item base não encontrado para o produto $codProduto',
      code: 'SEPARATE_ITEM_NOT_FOUND',
    );
  }

  /// Separação não encontrada
  factory DeleteItemSeparationFailure.separateNotFound() {
    return DeleteItemSeparationFailure._(message: 'Separação não encontrada', code: 'SEPARATE_NOT_FOUND');
  }

  /// Separação não está em situação de separando
  factory DeleteItemSeparationFailure.separateNotInSeparatingState() {
    return DeleteItemSeparationFailure._(
      message: 'Separação não está em situação de separando',
      code: 'SEPARATE_NOT_IN_SEPARATING_STATE',
    );
  }

  /// Falha ao excluir item de separação
  factory DeleteItemSeparationFailure.deleteSeparationItemFailed(String message) {
    return DeleteItemSeparationFailure._(message: message, code: 'DELETE_SEPARATION_ITEM_FAILED');
  }

  /// Falha ao atualizar item base
  factory DeleteItemSeparationFailure.updateSeparateItemFailed(String message) {
    return DeleteItemSeparationFailure._(message: message, code: 'UPDATE_SEPARATE_ITEM_FAILED');
  }

  /// Erro de rede
  factory DeleteItemSeparationFailure.networkError(String message, Exception exception) {
    return DeleteItemSeparationFailure._(message: message, code: 'NETWORK_ERROR', exception: exception);
  }

  /// Erro desconhecido
  factory DeleteItemSeparationFailure.unknown(String message, Exception exception) {
    return DeleteItemSeparationFailure._(message: message, code: 'UNKNOWN_ERROR', exception: exception);
  }

  @override
  String toString() {
    return 'DeleteItemSeparationFailure(code: $code, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteItemSeparationFailure && other.message == message && other.code == code;
  }

  @override
  int get hashCode {
    return message.hashCode ^ code.hashCode;
  }
}
