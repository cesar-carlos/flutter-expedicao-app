import 'package:exp/domain/models/expedition_cart_consultation_model.dart';

/// Representa o sucesso na operação de adicionar carrinho
class AddCartSuccess {
  /// Carrinho que foi adicionado
  final ExpeditionCartConsultationModel addedCart;

  /// Mensagem de sucesso
  final String message;

  /// Código do percurso do carrinho gerado
  final int? codCarrinhoPercurso;

  const AddCartSuccess({required this.addedCart, required this.message, this.codCarrinhoPercurso});

  @override
  String toString() => 'AddCartSuccess(message: $message, codCarrinho: ${addedCart.codCarrinho})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddCartSuccess && other.addedCart.codCarrinho == addedCart.codCarrinho && other.message == message;
  }

  @override
  int get hashCode => addedCart.codCarrinho.hashCode ^ message.hashCode;
}
