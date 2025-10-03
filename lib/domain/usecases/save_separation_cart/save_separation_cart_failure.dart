import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/core/results/app_failure.dart';

class SaveSeparationCartFailure extends AppFailure {
  final ExpeditionCartRouteInternshipModel? cart;
  final String? details;
  final DateTime timestamp;

  SaveSeparationCartFailure({this.cart, required super.message, this.details, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now(),
      super(code: 'SAVE_SEPARATION_CART_ERROR');

  SaveSeparationCartFailure copyWith({
    ExpeditionCartRouteInternshipModel? cart,
    String? message,
    String? details,
    DateTime? timestamp,
  }) {
    return SaveSeparationCartFailure(
      cart: cart ?? this.cart,
      message: message ?? this.message,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory SaveSeparationCartFailure.cartRouteNotFound() {
    return SaveSeparationCartFailure(message: 'Carrinho percurso não encontrado');
  }

  factory SaveSeparationCartFailure.cartRouteInternshiptNotFound() {
    return SaveSeparationCartFailure(message: 'Carrinho percurso não encontrado');
  }

  factory SaveSeparationCartFailure.cartNotFound() {
    return SaveSeparationCartFailure(message: 'Carrinho não encontrado');
  }

  factory SaveSeparationCartFailure.invalidStatus(ExpeditionCartRouteInternshipModel cart) {
    return SaveSeparationCartFailure(
      cart: cart,
      message: 'Carrinho deve estar em situação SEPARANDO para ser finalizado',
      details: 'Situação atual: ${cart.situacao.description}',
    );
  }

  factory SaveSeparationCartFailure.noItems() {
    return SaveSeparationCartFailure(message: 'Nenhum item encontrado para este carrinho');
  }

  factory SaveSeparationCartFailure.noSeparatedItems() {
    return SaveSeparationCartFailure(message: 'Nenhum item foi separado neste carrinho');
  }

  factory SaveSeparationCartFailure.separationNotFound() {
    return SaveSeparationCartFailure(message: 'Separação não encontrada');
  }

  factory SaveSeparationCartFailure.invalidSeparationStatus(String currentStatus) {
    return SaveSeparationCartFailure(
      message: 'Separação deve estar em situação SEPARANDO para finalizar o carrinho',
      details: 'Situação atual: $currentStatus',
    );
  }

  factory SaveSeparationCartFailure.userNotAuthenticated() {
    return SaveSeparationCartFailure(message: 'Usuário não autenticado');
  }

  factory SaveSeparationCartFailure.unexpected(Object error) {
    return SaveSeparationCartFailure(message: 'Erro inesperado ao salvar carrinho', details: error.toString());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveSeparationCartFailure &&
        other.cart == cart &&
        other.message == message &&
        other.details == details &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return cart.hashCode ^ message.hashCode ^ details.hashCode ^ timestamp.hashCode;
  }

  @override
  String toString() {
    return '''
      SaveSeparationCartFailure(
        cart: $cart,
        message: $message,
        details: $details,
        timestamp: $timestamp
      )''';
  }
}
