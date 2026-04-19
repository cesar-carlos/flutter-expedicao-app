import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_item_summary_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparationItemSummaryConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class SeparationItemSummaryConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparationItemSummaryConsultationModel> {
  static const String _selectEvent = 'separacao.item.resumo.consulta';

  @override
  Future<List<SeparationItemSummaryConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparationItemSummaryConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationItemSummaryConsultationModel.fromJson,
    );
  }
}
