import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparateConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class SeparateConsultationRepositoryImpl implements BasicConsultationRepository<SeparateConsultationModel> {
  static const String _selectEvent = 'separar.consulta';

  @override
  Future<List<SeparateConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateConsultationModel.fromJson,
      includeOrderBy: true,
    );
  }
}
