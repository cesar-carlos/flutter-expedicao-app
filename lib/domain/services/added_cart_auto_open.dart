import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';

/// Após adicionar um carrinho, só abre picking no estágio ativo.
///
/// `SEPARADO` e `CONFERIDO` são estágio encerrado. Incluí-los na busca
/// faz o coletor abrir um documento antigo do mesmo `CodCarrinho` no
/// lugar do `SEPARANDO` corrente.
bool isCartAvailableForAutoOpen(ExpeditionSituation situacao) {
  return situacao == ExpeditionSituation.aguardando || situacao == ExpeditionSituation.separando;
}

ExpeditionCartRouteInternshipConsultationModel? findAddedCartForAutoOpen({
  required List<ExpeditionCartRouteInternshipConsultationModel> carts,
  required int codCarrinho,
  int? codCarrinhoPercurso,
}) {
  final matchingCarts = carts.where((cart) {
    final matchesCart = cart.codCarrinho == codCarrinho;
    final matchesRoute = codCarrinhoPercurso == null || cart.codCarrinhoPercurso == codCarrinhoPercurso;
    return matchesCart && matchesRoute && isCartAvailableForAutoOpen(cart.situacao);
  }).toList();

  if (matchingCarts.isEmpty) {
    return null;
  }

  matchingCarts.sort(_compareAutoOpenCandidates);
  return matchingCarts.first;
}

int _compareAutoOpenCandidates(
  ExpeditionCartRouteInternshipConsultationModel a,
  ExpeditionCartRouteInternshipConsultationModel b,
) {
  final bySituation = _autoOpenRank(b.situacao).compareTo(_autoOpenRank(a.situacao));
  if (bySituation != 0) {
    return bySituation;
  }
  return b.dataInicio.compareTo(a.dataInicio);
}

int _autoOpenRank(ExpeditionSituation situacao) {
  return switch (situacao) {
    ExpeditionSituation.separando => 2,
    ExpeditionSituation.aguardando => 1,
    _ => 0,
  };
}
