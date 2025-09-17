import 'package:exp/domain/models/expedition_cart_consultation_model.dart';

/// Resultado abstrato para a operação de adicionar carrinho
abstract class AddCartResult {
  const AddCartResult();
}

/// Resultado de sucesso ao adicionar carrinho
class AddCartSuccess extends AddCartResult {
  final ExpeditionCartConsultationModel addedCart;
  final String message;

  const AddCartSuccess({required this.addedCart, this.message = 'Carrinho adicionado com sucesso'});

  @override
  String toString() => 'AddCartSuccess(addedCart: ${addedCart.codCarrinho}, message: $message)';
}

/// Resultado de falha ao adicionar carrinho
class AddCartFailure extends AddCartResult {
  final String message;
  final String? errorCode;
  final dynamic exception;

  const AddCartFailure({required this.message, this.errorCode, this.exception});

  @override
  String toString() => 'AddCartFailure(message: $message, errorCode: $errorCode)';

  /// Falha por carrinho não encontrado
  factory AddCartFailure.cartNotFound(String barcode) {
    return AddCartFailure(
      message: 'Carrinho não encontrado com o código de barras: $barcode',
      errorCode: 'CART_NOT_FOUND',
    );
  }

  /// Falha por situação inválida
  factory AddCartFailure.invalidSituation(String currentSituation) {
    return AddCartFailure(
      message: 'Carrinho deve estar na situação LIBERADO para ser adicionado. Situação atual: $currentSituation',
      errorCode: 'INVALID_SITUATION',
    );
  }

  /// Falha por usuário não autenticado
  factory AddCartFailure.userNotAuthenticated() {
    return const AddCartFailure(
      message: 'Usuário não autenticado ou dados do sistema não encontrados',
      errorCode: 'USER_NOT_AUTHENTICATED',
    );
  }

  /// Falha por erro de repositório
  factory AddCartFailure.repositoryError(dynamic exception) {
    return AddCartFailure(
      message: 'Erro ao acessar os dados: ${exception.toString()}',
      errorCode: 'REPOSITORY_ERROR',
      exception: exception,
    );
  }

  /// Falha por validação de parâmetros
  factory AddCartFailure.invalidParameters(String details) {
    return AddCartFailure(message: 'Parâmetros inválidos: $details', errorCode: 'INVALID_PARAMETERS');
  }

  /// Falha genérica
  factory AddCartFailure.generic(String message, [dynamic exception]) {
    return AddCartFailure(message: message, errorCode: 'GENERIC_ERROR', exception: exception);
  }
}
