import 'package:data7_expedicao/core/services/barcode_validation_service.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/picking_scan_result.dart';

/// Resolver puro/testável que encapsula a regra de negócio do `processScan`
/// do `CardPickingViewModel` (refator F7).
///
/// **Não** depende de `BuildContext`, locator, `ChangeNotifier`, nem de
/// `_state` interno mutável. Recebe TUDO via parâmetros do método [resolve],
/// devolvendo um [ScanProcessResult].
///
/// Caminhos cobertos (ordem importa — primeiro match ganha):
/// 1. Barcode vazio → `ignored`
/// 2. Carrinho não em separação → `cartNotInSeparation`
/// 3. Próximo item exige scan de prateleira → resolve via [validateShelf]
/// 4. `BarcodeValidationService` → `noItemsForSector`, `allItemsCompleted`,
///    `wrongSector`, `wrongProduct`, ou `success`
/// 5. Validação `success` mas quantidade excederia o restante → `quantityExceeded`
/// 6. Fallback → `ignored`
class PickingScanResolver {
  const PickingScanResolver();

  ScanProcessResult resolve({
    required String barcode,
    required int inputQuantity,
    required bool isCartInSeparation,
    required List<SeparateItemConsultationModel> items,
    SeparateItemConsultationModel? nextItem,
    required int? userSectorCode,
    required bool requiresShelfScanning,
    required String? lastScannedAddress,
    required void Function(String address) onShelfAddressMatched,
    required bool Function(String itemId) isItemCompleted,
    required int Function(String itemId) getPickedQuantity,
    bool Function(SeparateItemConsultationModel item)? shouldScanShelfFor,
    void Function(String barcode, DateTime startTime, bool success, String? errorMessage)? onScanRecorded,
    bool allowOutOfSequence = false,
  }) {
    final scanStartTime = DateTime.now();
    final trimmedBarcode = barcode.trim();

    void record(bool success, String? errorMessage) {
      onScanRecorded?.call(trimmedBarcode, scanStartTime, success, errorMessage);
    }

    if (trimmedBarcode.isEmpty) {
      record(false, 'Código vazio');
      return const ScanProcessResult(status: ScanProcessStatus.ignored);
    }

    if (!isCartInSeparation) {
      record(false, 'Carrinho não em separação');
      return const ScanProcessResult(status: ScanProcessStatus.cartNotInSeparation);
    }

    final expectedNextItem =
        nextItem ?? PickingUtils.findNextItemToPick(items, isItemCompleted, userSectorCode: userSectorCode);

    final shouldCheckShelf =
        expectedNextItem != null && requiresShelfScanning && (shouldScanShelfFor?.call(expectedNextItem) ?? true);

    if (shouldCheckShelf) {
      final shelfResult = _validateShelfScanning(
        scannedBarcode: trimmedBarcode,
        expectedItem: expectedNextItem,
        lastScannedAddress: lastScannedAddress,
        onShelfAddressMatched: onShelfAddressMatched,
      );
      if (shelfResult != null) {
        final success = shelfResult.status == ScanProcessStatus.shelfScanned;
        record(success, success ? null : 'Prateleira incorreta');
        return shelfResult;
      }
    }

    final validation = BarcodeValidationService.validateScannedBarcode(
      trimmedBarcode,
      items,
      isItemCompleted,
      expectedItem: expectedNextItem,
      userSectorCode: userSectorCode,
      allowOutOfSequence: allowOutOfSequence,
    );

    if (validation.isEmpty) {
      record(false, 'Validação vazia');
      return const ScanProcessResult(status: ScanProcessStatus.ignored);
    }

    if (validation.noItemsForSector) {
      record(false, 'Sem itens para o setor');
      return ScanProcessResult.noItemsForSector(validation.userSectorCode);
    }

    if (validation.allItemsCompleted) {
      record(false, 'Todos os itens completados');
      return const ScanProcessResult(status: ScanProcessStatus.allItemsCompleted);
    }

    if (validation.isWrongSector && validation.scannedItem != null) {
      record(false, 'Setor incorreto');
      return ScanProcessResult.wrongSector(validation.scannedItem!, validation.userSectorCode);
    }

    if (validation.isValid && validation.expectedItem != null) {
      final item = validation.expectedItem!;
      final effectiveQuantity = _convertQuantityWithBarcode(item, trimmedBarcode, inputQuantity);

      final totalQuantity = item.quantidade.toInt();
      final pickedQuantity = getPickedQuantity(item.item);
      final remainingQuantity = totalQuantity - pickedQuantity;

      if (effectiveQuantity > remainingQuantity) {
        record(false, 'Quantidade excedida');
        return ScanProcessResult.quantityExceeded(item, effectiveQuantity, remainingQuantity);
      }

      record(true, null);
      return ScanProcessResult.success(item, effectiveQuantity);
    }

    if (validation.expectedItem != null) {
      record(false, 'Produto incorreto');
      return ScanProcessResult.wrongProduct(validation.expectedItem!);
    }

    record(false, 'Ignorado');
    return const ScanProcessResult(status: ScanProcessStatus.ignored);
  }

  ScanProcessResult? _validateShelfScanning({
    required String scannedBarcode,
    required SeparateItemConsultationModel expectedItem,
    required String? lastScannedAddress,
    required void Function(String address) onShelfAddressMatched,
  }) {
    final trimmedCode = scannedBarcode.trim();
    final expectedShelf = expectedItem.endereco?.trim();

    if (lastScannedAddress == null || lastScannedAddress != expectedShelf) {
      if (expectedShelf != null && expectedShelf == trimmedCode) {
        onShelfAddressMatched(trimmedCode);
        return ScanProcessResult.shelfScanned(expectedItem, trimmedCode);
      } else if (expectedShelf != null) {
        return ScanProcessResult.wrongShelf(expectedItem, trimmedCode, expectedShelf);
      }
    }

    return null;
  }

  int _convertQuantityWithBarcode(SeparateItemConsultationModel item, String barcode, int inputQuantity) {
    try {
      if (item.unidadeMedidas.length <= 1) {
        return inputQuantity;
      }

      final convertedQuantity = item.converterQuantidadePorCodigoBarras(barcode, inputQuantity.toDouble());

      if (convertedQuantity != null && convertedQuantity > 0) {
        return convertedQuantity.toInt();
      }

      return inputQuantity;
    } catch (_) {
      return inputQuantity;
    }
  }
}
