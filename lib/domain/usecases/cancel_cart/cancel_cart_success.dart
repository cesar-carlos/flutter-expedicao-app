import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';

/// Resultado de sucesso ao cancelar um carrinho
class CancelCartSuccess {
  final ExpeditionCancellationModel cancellation;
  final ExpeditionCartRouteInternshipModel updatedCartRoute;

  const CancelCartSuccess({required this.cancellation, required this.updatedCartRoute});

  /// Cria um resultado de sucesso
  factory CancelCartSuccess.create({
    required ExpeditionCancellationModel cancellation,
    required ExpeditionCartRouteInternshipModel updatedCartInternshipRoute,
  }) {
    return CancelCartSuccess(cancellation: cancellation, updatedCartRoute: updatedCartInternshipRoute);
  }

  /// Retorna uma mensagem de sucesso
  String get message => 'Carrinho cancelado com sucesso';

  /// Retorna o código do cancelamento
  int get codCancelamento => cancellation.codCancelamento;

  /// Retorna o item cancelado
  String get item => updatedCartRoute.item;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CancelCartSuccess &&
        other.cancellation == cancellation &&
        other.updatedCartRoute == updatedCartRoute;
  }

  @override
  int get hashCode => cancellation.hashCode ^ updatedCartRoute.hashCode;

  @override
  String toString() {
    return 'CancelCartSuccess(codCancelamento: $codCancelamento, item: $item)';
  }
}
