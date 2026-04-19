import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/stock_product_consultation_model.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

/// Repositorio de consulta de StockProductConsultationModel.
///
/// Refatorado para usar [SocketRequestHelper] (ver doc do helper).
class StockProductConsultationRepositoryImpl implements BasicConsultationRepository<StockProductConsultationModel> {
  static const String _selectEvent = 'estoque.produto.consulta';

  @override
  Future<List<StockProductConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<StockProductConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder,
      fromJson: StockProductConsultationModel.fromJson,
    );
  }
}
