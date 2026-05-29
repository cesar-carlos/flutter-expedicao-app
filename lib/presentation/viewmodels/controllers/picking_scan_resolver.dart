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
        // Out-of-sequence: o operador com permissão de separar fora de ordem
        // pode ter bipado o PRODUTO de outro item pendente (não a prateleira
        // do próximo item da sequência). Nesse caso, não bloqueamos com
        // "prateleira incorreta": tentamos resolver como produto e, se o
        // código casar com um item real, seguimos esse fluxo. Um código que
        // não casa com produto algum (provável endereço errado) mantém o
        // wrongShelf original.
        if (allowOutOfSequence && shelfResult.status == ScanProcessStatus.wrongShelf) {
          final productResult = _resolveProductScan(
            trimmedBarcode: trimmedBarcode,
            inputQuantity: inputQuantity,
            items: items,
            expectedNextItem: expectedNextItem,
            userSectorCode: userSectorCode,
            isItemCompleted: isItemCompleted,
            getPickedQuantity: getPickedQuantity,
            allowOutOfSequence: allowOutOfSequence,
          );
          if (productResult.status != ScanProcessStatus.wrongProduct &&
              productResult.status != ScanProcessStatus.ignored) {
            _recordForResult(record, productResult);
            return productResult;
          }
        }

        final success = shelfResult.status == ScanProcessStatus.shelfScanned;
        record(success, success ? null : 'Prateleira incorreta');
        return shelfResult;
      }
    }

    final productResult = _resolveProductScan(
      trimmedBarcode: trimmedBarcode,
      inputQuantity: inputQuantity,
      items: items,
      expectedNextItem: expectedNextItem,
      userSectorCode: userSectorCode,
      isItemCompleted: isItemCompleted,
      getPickedQuantity: getPickedQuantity,
      allowOutOfSequence: allowOutOfSequence,
    );
    _recordForResult(record, productResult);
    return productResult;
  }

  /// Resolve um scan de produto (sem registrar métrica) aplicando a validação
  /// de código de barras e a checagem de quantidade restante.
  ScanProcessResult _resolveProductScan({
    required String trimmedBarcode,
    required int inputQuantity,
    required List<SeparateItemConsultationModel> items,
    required SeparateItemConsultationModel? expectedNextItem,
    required int? userSectorCode,
    required bool Function(String itemId) isItemCompleted,
    required int Function(String itemId) getPickedQuantity,
    required bool allowOutOfSequence,
  }) {
    final validation = BarcodeValidationService.validateScannedBarcode(
      trimmedBarcode,
      items,
      isItemCompleted,
      expectedItem: expectedNextItem,
      userSectorCode: userSectorCode,
      allowOutOfSequence: allowOutOfSequence,
    );

    if (validation.isEmpty) {
      return const ScanProcessResult(status: ScanProcessStatus.ignored);
    }

    if (validation.noItemsForSector) {
      return ScanProcessResult.noItemsForSector(validation.userSectorCode);
    }

    if (validation.allItemsCompleted) {
      return const ScanProcessResult(status: ScanProcessStatus.allItemsCompleted);
    }

    if (validation.isWrongSector && validation.scannedItem != null) {
      return ScanProcessResult.wrongSector(validation.scannedItem!, validation.userSectorCode);
    }

    if (validation.isValid && validation.expectedItem != null) {
      final item = validation.expectedItem!;
      final effectiveQuantity = _convertQuantityWithBarcode(item, trimmedBarcode, inputQuantity);

      final totalQuantity = item.quantidade.toInt();
      final pickedQuantity = getPickedQuantity(item.item);
      final remainingQuantity = totalQuantity - pickedQuantity;

      if (effectiveQuantity > remainingQuantity) {
        return ScanProcessResult.quantityExceeded(item, effectiveQuantity, remainingQuantity);
      }

      return ScanProcessResult.success(item, effectiveQuantity);
    }

    if (validation.expectedItem != null) {
      return ScanProcessResult.wrongProduct(validation.expectedItem!);
    }

    return const ScanProcessResult(status: ScanProcessStatus.ignored);
  }

  /// Registra a métrica de scan a partir do resultado resolvido, preservando as
  /// mensagens de erro usadas anteriormente em cada caminho.
  void _recordForResult(
    void Function(bool success, String? errorMessage) record,
    ScanProcessResult result,
  ) {
    switch (result.status) {
      case ScanProcessStatus.success:
      case ScanProcessStatus.shelfScanned:
        record(true, null);
      case ScanProcessStatus.noItemsForSector:
        record(false, 'Sem itens para o setor');
      case ScanProcessStatus.allItemsCompleted:
        record(false, 'Todos os itens completados');
      case ScanProcessStatus.wrongSector:
        record(false, 'Setor incorreto');
      case ScanProcessStatus.quantityExceeded:
        record(false, 'Quantidade excedida');
      case ScanProcessStatus.wrongProduct:
        record(false, 'Produto incorreto');
      case ScanProcessStatus.wrongShelf:
        record(false, 'Prateleira incorreta');
      case ScanProcessStatus.cartNotInSeparation:
        record(false, 'Carrinho não em separação');
      case ScanProcessStatus.ignored:
        record(false, 'Ignorado');
    }
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
