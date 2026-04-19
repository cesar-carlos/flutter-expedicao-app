import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';

/// Status possível do resultado de uma tentativa de scan no picking.
enum ScanProcessStatus {
  ignored,
  cartNotInSeparation,
  noItemsForSector,
  allItemsCompleted,
  wrongSector,
  wrongProduct,
  wrongShelf,
  shelfScanned,
  quantityExceeded,
  success,
}

/// Resultado tipado do `processScan` do picking.
///
/// Carrega o status + dados auxiliares (item esperado, item bipado,
/// quantidade convertida, setor, prateleiras) que a UI usa para exibir
/// feedback adequado ao operador.
class ScanProcessResult {
  final ScanProcessStatus status;
  final SeparateItemConsultationModel? expectedItem;
  final SeparateItemConsultationModel? scannedItem;
  final int? convertedQuantity;
  final int? userSectorCode;
  final int? requestedQuantity;
  final int? availableQuantity;
  final String? scannedShelf;
  final String? expectedShelf;

  const ScanProcessResult({
    required this.status,
    this.expectedItem,
    this.scannedItem,
    this.convertedQuantity,
    this.userSectorCode,
    this.requestedQuantity,
    this.availableQuantity,
    this.scannedShelf,
    this.expectedShelf,
  });

  const ScanProcessResult.success(SeparateItemConsultationModel item, int convertedQuantity)
    : this(status: ScanProcessStatus.success, expectedItem: item, convertedQuantity: convertedQuantity);

  const ScanProcessResult.noItemsForSector(int? userSectorCode)
    : this(status: ScanProcessStatus.noItemsForSector, userSectorCode: userSectorCode);

  const ScanProcessResult.wrongSector(SeparateItemConsultationModel scannedItem, int? userSectorCode)
    : this(status: ScanProcessStatus.wrongSector, scannedItem: scannedItem, userSectorCode: userSectorCode);

  const ScanProcessResult.wrongProduct(SeparateItemConsultationModel expectedItem)
    : this(status: ScanProcessStatus.wrongProduct, expectedItem: expectedItem);

  const ScanProcessResult.shelfScanned(SeparateItemConsultationModel item, String shelf)
    : this(status: ScanProcessStatus.shelfScanned, expectedItem: item, scannedShelf: shelf);

  const ScanProcessResult.wrongShelf(
    SeparateItemConsultationModel expectedItem,
    String scannedShelf,
    String expectedShelf,
  ) : this(
        status: ScanProcessStatus.wrongShelf,
        expectedItem: expectedItem,
        scannedShelf: scannedShelf,
        expectedShelf: expectedShelf,
      );

  const ScanProcessResult.quantityExceeded(
    SeparateItemConsultationModel item,
    int requestedQuantity,
    int availableQuantity,
  ) : this(
        status: ScanProcessStatus.quantityExceeded,
        expectedItem: item,
        requestedQuantity: requestedQuantity,
        availableQuantity: availableQuantity,
      );
}
