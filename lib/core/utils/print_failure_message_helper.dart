import 'package:data7_expedicao/core/results/index.dart';

enum PrintFailureContext {
  separation,
  cartSaved,
}

class PrintFailureMessageHelper {
  const PrintFailureMessageHelper();

  String build(
    Object? failure, {
    required PrintFailureContext context,
  }) {
    final isCartSaved = context == PrintFailureContext.cartSaved;

    if (failure is DataFailure && failure.code == 'NOT_FOUND') {
      return isCartSaved
          ? 'Carrinho salvo, mas não existem itens para imprimir.'
          : 'Não existem itens para imprimir nesta separação.';
    }

    if (failure is AppFailure) {
      return isCartSaved
          ? 'Carrinho salvo, mas a impressao falhou: ${failure.message}'
          : 'Falha ao imprimir separação: ${failure.message}';
    }

    if (failure != null) {
      return isCartSaved
          ? 'Carrinho salvo, mas a impressao falhou: $failure'
          : 'Falha ao imprimir separação: $failure';
    }

    return isCartSaved
        ? 'Carrinho salvo, mas a impressao falhou.'
        : 'Falha ao imprimir separação.';
  }
}
