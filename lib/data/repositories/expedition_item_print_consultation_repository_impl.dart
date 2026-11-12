import 'package:data7_expedicao/core/network/socket_request_helper.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';

class ExpeditionItemPrintConsultationRepositoryImpl
    implements BasicConsultationRepository<ExpeditionItemPrintConsultationModel> {
  static const String _selectEvent = 'separar.estoque.item.impresso.consulta';

  final dynamic _socket;
  final Duration? _responseTimeout;

  ExpeditionItemPrintConsultationRepositoryImpl({dynamic socket, Duration? responseTimeout})
    : _socket = socket,
      _responseTimeout = responseTimeout;

  @override
  Future<List<ExpeditionItemPrintConsultationModel>> selectConsultation(QueryBuilder queryBuilder) {
    return SocketRequestHelper.select<ExpeditionItemPrintConsultationModel>(
      baseEvent: _selectEvent,
      queryBuilder: queryBuilder.withAllRows(thenBy: ['Item']),
      fromJson: ExpeditionItemPrintConsultationModel.fromJson,
      timeout: _responseTimeout,
      socket: _socket,
    );
  }
}
