import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';

/// Representa o sucesso ao salvar um carrinho na separação
class SaveSeparationCartSuccess {
  final DateTime dataFinalizacao;
  final String horaFinalizacao;
  final int codUsuarioFinalizacao;
  final String nomeUsuarioFinalizacao;
  final ExpeditionCartRouteInternshipModel cart;

  const SaveSeparationCartSuccess({
    required this.cart,
    required this.dataFinalizacao,
    required this.horaFinalizacao,
    required this.codUsuarioFinalizacao,
    required this.nomeUsuarioFinalizacao,
  });

  /// Mensagem de sucesso
  String get message => 'Carrinho finalizado com sucesso!';

  /// Detalhes adicionais do sucesso
  String? get details =>
      'Finalizado por $nomeUsuarioFinalizacao em ${_formatDate(dataFinalizacao)} às $horaFinalizacao';

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

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
