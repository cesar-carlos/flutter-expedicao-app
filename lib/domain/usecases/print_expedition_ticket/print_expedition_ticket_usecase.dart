import 'package:data7_expedicao/core/errors/app_error.dart';
import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';
import 'package:data7_expedicao/domain/repositories/basic_consultation_repository.dart';
import 'package:data7_expedicao/domain/repositories/thermal_printer_repository.dart';
import 'package:data7_expedicao/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart';

class PrintExpeditionTicketUseCase {
  final BasicConsultationRepository<ExpeditionItemPrintConsultationModel> _expeditionItemPrintRepository;
  final ThermalPrinterRepository _thermalPrinterRepository;

  const PrintExpeditionTicketUseCase({
    required BasicConsultationRepository<ExpeditionItemPrintConsultationModel> expeditionItemPrintRepository,
    required ThermalPrinterRepository thermalPrinterRepository,
  }) : _expeditionItemPrintRepository = expeditionItemPrintRepository,
       _thermalPrinterRepository = thermalPrinterRepository;

  Future<Result<ThermalPrintResult>> call(PrintExpeditionTicketParams params) async {
    if (!params.isValid) {
      return failure(ValidationFailure.fromErrors(params.validationErrors));
    }

    try {
      final queryBuilder = QueryBuilder()
        ..equals('CodEmpresa', params.codEmpresa.toString())
        ..equals('CodSepararEstoque', params.codSepararEstoque.toString())
        ..orderByAsc('Item');

      final items = await _expeditionItemPrintRepository.selectConsultation(queryBuilder);
      if (items.isEmpty) {
        return failure(DataFailure.notFound('Itens para impressao da separacao ${params.codSepararEstoque}'));
      }

      return _thermalPrinterRepository.printExpeditionTicket(
        printer: params.printer,
        items: items,
        separatorName: params.separatorName,
        autoCut: params.autoCut,
      );
    } on DataError catch (e) {
      return failure(NetworkFailure(message: e.message));
    } catch (e) {
      return failure(UnknownFailure.fromException(e));
    }
  }
}
