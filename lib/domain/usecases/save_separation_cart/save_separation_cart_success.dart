import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';

/// Representa o sucesso ao salvar um carrinho na separação
class SaveSeparationCartSuccess {
  final ExpeditionCartRouteInternshipModel cart;
  final DateTime dataFinalizacao;
  final String horaFinalizacao;
  final int codUsuarioFinalizacao;
  final String nomeUsuarioFinalizacao;

  const SaveSeparationCartSuccess({
    required this.cart,
    required this.dataFinalizacao,
    required this.horaFinalizacao,
    required this.codUsuarioFinalizacao,
    required this.nomeUsuarioFinalizacao,
  });

  SaveSeparationCartSuccess copyWith({
    ExpeditionCartRouteInternshipModel? cart,
    DateTime? dataFinalizacao,
    String? horaFinalizacao,
    int? codUsuarioFinalizacao,
    String? nomeUsuarioFinalizacao,
  }) {
    return SaveSeparationCartSuccess(
      cart: cart ?? this.cart,
      dataFinalizacao: dataFinalizacao ?? this.dataFinalizacao,
      horaFinalizacao: horaFinalizacao ?? this.horaFinalizacao,
      codUsuarioFinalizacao: codUsuarioFinalizacao ?? this.codUsuarioFinalizacao,
      nomeUsuarioFinalizacao: nomeUsuarioFinalizacao ?? this.nomeUsuarioFinalizacao,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveSeparationCartSuccess &&
        other.cart == cart &&
        other.dataFinalizacao == dataFinalizacao &&
        other.horaFinalizacao == horaFinalizacao &&
        other.codUsuarioFinalizacao == codUsuarioFinalizacao &&
        other.nomeUsuarioFinalizacao == nomeUsuarioFinalizacao;
  }

  @override
  int get hashCode {
    return cart.hashCode ^
        dataFinalizacao.hashCode ^
        horaFinalizacao.hashCode ^
        codUsuarioFinalizacao.hashCode ^
        nomeUsuarioFinalizacao.hashCode;
  }

  @override
  String toString() {
    return '''
      SaveSeparationCartSuccess(
        cart: $cart,
        dataFinalizacao: $dataFinalizacao,
        horaFinalizacao: $horaFinalizacao,
        codUsuarioFinalizacao: $codUsuarioFinalizacao,
        nomeUsuarioFinalizacao: $nomeUsuarioFinalizacao
      )''';
  }
}
