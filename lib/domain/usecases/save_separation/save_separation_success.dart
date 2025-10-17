import 'package:data7_expedicao/domain/models/expedition_cart_route_model.dart';

/// Resultado de sucesso ao salvar separação
class SaveSeparationSuccess {
  final ExpeditionCartRouteModel updatedCartRoute;
  final String message;

  const SaveSeparationSuccess({required this.updatedCartRoute, required this.message});

  /// Factory method para criar sucesso
  static SaveSeparationSuccess create({required ExpeditionCartRouteModel updatedCartRoute, String? message}) {
    return SaveSeparationSuccess(updatedCartRoute: updatedCartRoute, message: message ?? 'Separação salva com sucesso');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveSeparationSuccess && other.updatedCartRoute == updatedCartRoute && other.message == message;
  }

  @override
  int get hashCode => Object.hash(updatedCartRoute, message);

  @override
  String toString() => 'SaveSeparationSuccess(message: $message, updatedCartRoute: $updatedCartRoute)';
}
