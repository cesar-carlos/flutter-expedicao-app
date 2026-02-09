import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/printer_config.dart';
import 'package:data7_expedicao/domain/models/thermal_print_result.dart';

abstract class ThermalPrinterRepository {
  Future<Result<ThermalPrintResult>> printTestTicket({required PrinterConfig printer, bool autoCut = true});

  Future<Result<ThermalPrintResult>> printExpeditionTicket({
    required PrinterConfig printer,
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    bool autoCut = true,
  });
}
