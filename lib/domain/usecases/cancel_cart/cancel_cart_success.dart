import 'package:data7_expedicao/domain/models/expedition_cancellation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_model.dart';

class CancelCartSuccess {
  final ExpeditionCancellationModel cancellation;
  final ExpeditionCartRouteInternshipModel updatedCartRoute;

  const CancelCartSuccess({required this.cancellation, required this.updatedCartRoute});

  factory CancelCartSuccess.create({
    required ExpeditionCancellationModel cancellation,
    required ExpeditionCartRouteInternshipModel updatedCartInternshipRoute,
  }) {
    return CancelCartSuccess(cancellation: cancellation, updatedCartRoute: updatedCartInternshipRoute);
  }

  String get message => 'Carrinho cancelado com sucesso';

  int get codCancelamento => cancellation.codCancelamento;

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
