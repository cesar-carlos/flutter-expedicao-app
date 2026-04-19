import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_group_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCartRouteInternshipGroupConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCartRouteInternshipConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCartRouteInternshipGroupConsultationModel> {
  static const String _selectEvent = 'carrinho.percurso.agrupamento.consulta';

  @override
  Future<List<ExpeditionCartRouteInternshipGroupConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartRouteInternshipGroupConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartRouteInternshipGroupConsultationModel.fromJson,
    );
  }
}
