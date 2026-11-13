import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparationUserSectorConsultationModel.
class SeparationUserSectorConsultationRepositoryImpl
    implements BasicConsultationRepository<SeparationUserSectorConsultationModel> {
  static const String _selectEvent = 'separar.usuario.setor.consulta';

  @override
  Future<List<SeparationUserSectorConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparationUserSectorConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparationUserSectorConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
      includeOrderBy: true,
    );
  }
}
