import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/domain/repositories/basic_repository.dart';

/// Interface para operações de carrinho de percurso de estágio
abstract class ExpeditionCartRouteInternshipRepository extends BasicRepository<ExpeditionCartRouteInternshipModel> {
  /// Busca carrinho por código de empresa, carrinho percurso e item
  Future<ExpeditionCartRouteInternshipModel?> getCartRouteByKeys({
    required int codEmpresa,
    required int codCarrinhoPercurso,
    required String item,
  });

  /// Atualiza a situação do carrinho
  Future<ExpeditionCartRouteInternshipModel> updateCartSituation({
    required int codEmpresa,
    required int codCarrinhoPercurso,
    required String item,
    required String newSituation,
    required int codUsuario,
    required String nomeUsuario,
  });
}
