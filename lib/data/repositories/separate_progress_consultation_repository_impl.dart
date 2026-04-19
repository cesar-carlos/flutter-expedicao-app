import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_progress_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparateProgressConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Usa `includeOrderBy: true` para preservar comportamento original.
class SeparateProgressConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparateProgressConsultationModel> {
  static const String _selectEvent = 'separar.progresso.consulta';

  @override
  Future<List<SeparateProgressConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateProgressConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateProgressConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
      includeOrderBy: true,
    );
  }
}
