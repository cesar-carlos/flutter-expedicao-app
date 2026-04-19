import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/separate_item_unidade_medida_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de SeparateItemUnidadeMedidaConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
/// Apenas SELECT — implementa BasicConsultationRepository.
class SeparateItemUnidadeMedidaRepositoryImpl
    implements BasicConsultationRepository<SeparateItemUnidadeMedidaConsultationModel> {
  static const String _selectEvent = 'separar.item.unidade.medida.consulta';

  @override
  Future<List<SeparateItemUnidadeMedidaConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<SeparateItemUnidadeMedidaConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: SeparateItemUnidadeMedidaConsultationModel.fromJson,
    );
  }
}
