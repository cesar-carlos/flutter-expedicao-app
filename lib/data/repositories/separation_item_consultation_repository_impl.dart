import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_item_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparationItemConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class SeparationItemConsultationRepositoryImpl implements BasicConsultationRepository<SeparationItemConsultationModel> {
  static const String _selectEvent = 'separacao.item.consulta';

  @override
  Future<List<SeparationItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparationItemConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationItemConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }
}
