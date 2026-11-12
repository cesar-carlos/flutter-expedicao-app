import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';

class ExpeditionCartRouteQuery {
  static QueryBuilder activeByOrigin({
    required int codEmpresa,
    required ExpeditionOrigem origem,
    required int codOrigem,
  }) {
    return QueryBuilder()
      ..equals('CodEmpresa', codEmpresa)
      ..equals('Origem', origem.code)
      ..equals('CodOrigem', codOrigem)
      ..notEquals('Situacao', ExpeditionCartRouterSituation.cancelada.code);
  }
}
