import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de ExpeditionCartConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Preserva o timeout original (`shortNetworkTimeout`).
class ExpeditionCartConsultationRepositoryImpl implements BasicConsultationRepository<ExpeditionCartConsultationModel> {
  static const String _selectEvent = 'carrinho.consulta';

  @override
  Future<List<ExpeditionCartConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionCartConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: ExpeditionCartConsultationModel.fromJson,
      timeout: UIConstants.shortNetworkTimeout,
    );
  }
}
