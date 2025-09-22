import 'package:exp/domain/usecases/cancel_cart/cancel_cart_success.dart';
import 'package:exp/domain/usecases/cancel_cart/cancel_cart_failure.dart';

/// Resultado do cancelamento de carrinho
abstract class CancelCartResult {
  const CancelCartResult();

  /// Verifica se é sucesso
  bool get isSuccess => this is CancelCartSuccess;

  /// Verifica se é falha
  bool get isFailure => this is CancelCartFailure;

  /// Retorna o sucesso se for do tipo correto
  CancelCartSuccess? get success => isSuccess ? this as CancelCartSuccess : null;

  /// Retorna a falha se for do tipo correto
  CancelCartFailure? get failure => isFailure ? this as CancelCartFailure : null;

  /// Retorna uma mensagem descritiva
  String get message {
    if (isSuccess) {
      return success!.message;
    } else {
      return failure!.message;
    }
  }
}
