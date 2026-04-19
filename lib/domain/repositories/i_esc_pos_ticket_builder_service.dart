import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';

abstract class IEscPosTicketBuilderService {
  Future<List<int>> buildPrinterTestTicketBytes({
    required String printerName,
    required String printerIp,
    required int printerPort,
    bool autoCut = true,
    int? leftMarginMm,
  });

  Future<List<int>> buildExpeditionTicketBytes({
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    bool autoCut = true,
    int? codUsuario,
    int? leftMarginMm,
  });
}
