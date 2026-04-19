import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCartRouteInternshipConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCartRouteInternshipConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCartRouteInternshipConsultationModel> {
  static const String _selectEvent = 'carrinho.percurso.estagio.consulta';

  @override
  Future<List<ExpeditionCartRouteInternshipConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartRouteInternshipConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartRouteInternshipConsultationModel.fromJson,
    );
  }
}
