import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/repositories/basic_consultation_repository.dart';

/// Interface para repositório de consulta de carrinhos de expedição
abstract class ExpeditionCartConsultationRepository
    extends BasicConsultationRepository<ExpeditionCartConsultationModel> {
  /// Busca um carrinho específico pelo código de barras
  Future<ExpeditionCartConsultationModel?> getCartByBarcode({required int codEmpresa, required String codigoBarras});

  /// Busca um carrinho específico pelo código do carrinho
  Future<ExpeditionCartConsultationModel?> getCartByCode({required int codEmpresa, required int codCarrinho});
}
