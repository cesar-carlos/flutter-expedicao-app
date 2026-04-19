import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCheckItemConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCheckItemConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCheckItemConsultationModel> {
  static const String _selectEvent = 'conferir.item.consulta';

  @override
  Future<List<ExpeditionCheckItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCheckItemConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCheckItemConsultationModel.fromJson,
    );
  }
}
