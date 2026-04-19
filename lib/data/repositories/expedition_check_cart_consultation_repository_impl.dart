import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_check_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCheckCartConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCheckCartConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCheckCartConsultationModel> {
  static const String _selectEvent = 'carrinho.conferir.consulta';

  @override
  Future<List<ExpeditionCheckCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCheckCartConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCheckCartConsultationModel.fromJson,
      includeOrderBy: true,
    );
  }
}
