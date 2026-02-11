import 'dart:typed_data';

import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';

abstract class IEscPosTicketBuilderService {
  Future<List<int>> buildPrinterTestTicketBytes({
    required String printerName,
    required String printerIp,
    required int printerPort,
    Uint8List? logoBytes,
    int logoMaxWidthPx = 576,
    bool autoCut = true,
  });

  Future<List<int>> buildExpeditionTicketBytes({
    required List<ExpeditionItemPrintConsultationModel> items,
    String? separatorName,
    Uint8List? logoBytes,
    int logoMaxWidthPx = 576,
    bool autoCut = true,
    int? codSetorEstoque,
    int? codUsuario,
  });
}
