import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparateItemConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva o timeout original (`shortNetworkTimeout`).
class SeparateItemConsultationRepositoryImpl implements BasicConsultationRepository<SeparateItemConsultationModel> {
  static const String _selectEvent = 'separar.item.consulta';

  @override
  Future<List<SeparateItemConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateItemConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateItemConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }
}
