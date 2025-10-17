import 'package:data7_expedicao/core/results/index.dart';

/// Falha específica para operações de adicionar carrinho
class AddCartFailure extends BusinessFailure {
  const AddCartFailure({required super.message, super.code, super.exception});

  /// Carrinho não encontrado
  factory AddCartFailure.cartNotFound(String cartCode) {
    return AddCartFailure(message: 'Carrinho não encontrado com código: $cartCode', code: 'CART_NOT_FOUND');
  }

  /// Situação do carrinho inválida
  factory AddCartFailure.invalidSituation(String currentSituation) {
    return AddCartFailure(
      message: 'Carrinho deve estar na situação LIBERADO para ser adicionado. Situação atual: $currentSituation',
      code: 'INVALID_CART_SITUATION',
    );
  }

  /// Usuário não autenticado
  factory AddCartFailure.userNotAuthenticated() {
    return const AddCartFailure(
      message: 'Usuário não autenticado ou sem permissões necessárias',
      code: 'USER_NOT_AUTHENTICATED',
    );
  }

  /// Erro no repositório
  factory AddCartFailure.repositoryError(dynamic exception) {
    return AddCartFailure(
      message: 'Erro ao acessar os dados: ${exception.toString()}',
      code: 'REPOSITORY_ERROR',
      exception: exception,
    );
  }

  /// Parâmetros inválidos
  factory AddCartFailure.invalidParameters(String details) {
    return AddCartFailure(message: 'Parâmetros inválidos: $details', code: 'INVALID_PARAMETERS');
  }

  /// Percurso não encontrado
  factory AddCartFailure.routeNotFound(String origem) {
    return AddCartFailure(message: 'Percurso não encontrado para origem: $origem', code: 'ROUTE_NOT_FOUND');
  }

  /// Falha genérica
  factory AddCartFailure.generic(String message, [dynamic exception]) {
    return AddCartFailure(message: message, code: 'GENERIC_ERROR', exception: exception);
  }
}
