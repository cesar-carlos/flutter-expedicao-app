import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_check_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCheckConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class ExpeditionCheckConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionCheckConsultationModel> {
  static const String _selectEvent = 'conferir.consulta';

  @override
  Future<List<ExpeditionCheckConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCheckConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCheckConsultationModel.fromJson,
      includeOrderBy: true,
    );
  }
}
