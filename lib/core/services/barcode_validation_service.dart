import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';

/// Serviço para validação e processamento de códigos de barras
class BarcodeValidationService {
  /// Valida se o código escaneado corresponde ao próximo item esperado
  static BarcodeValidationResult validateScannedBarcode(
    String scannedBarcode,
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted, {
    int? userSectorCode,
  }) {
    if (scannedBarcode.trim().isEmpty) {
      return BarcodeValidationResult.empty();
    }

    // Encontrar o próximo item a ser separado
    final nextItem = PickingUtils.findNextItemToPick(items, isItemCompleted, userSectorCode: userSectorCode);

    if (nextItem == null) {
      // Verificar se é porque não há mais itens do setor do usuário
      if (userSectorCode != null) {
        final hasItemsForSector = items.any(
          (item) =>
              !isItemCompleted(item.item) && (item.codSetorEstoque == null || item.codSetorEstoque == userSectorCode),
        );

        if (!hasItemsForSector) {
          return BarcodeValidationResult.noItemsForSector(userSectorCode);
        }
      }

      return BarcodeValidationResult.allItemsCompleted();
    }

    // Validar se o código corresponde ao próximo item
    final isValid = PickingUtils.validateBarcode(scannedBarcode, nextItem);

    if (isValid) {
      return BarcodeValidationResult.valid(nextItem);
    } else {
      // Verificar se o produto escaneado pertence a outro setor
      final scannedItem = _findItemByBarcode(items, scannedBarcode);

      if (scannedItem != null && userSectorCode != null) {
        // Se usuário tem setor definido e o produto tem setor diferente (e não é null)
        final productSector = scannedItem.codSetorEstoque;
        if (productSector != null && productSector != userSectorCode) {
          return BarcodeValidationResult.wrongSector(scannedBarcode, scannedItem, userSectorCode);
        }
      }

      return BarcodeValidationResult.invalid(scannedBarcode, nextItem);
    }
  }

  /// Encontra um item pelo código de barras
  static SeparateItemConsultationModel? _findItemByBarcode(List<SeparateItemConsultationModel> items, String barcode) {
    final trimmedBarcode = barcode.trim().toLowerCase();

    for (final item in items) {
      final barcode1 = item.codigoBarras?.trim().toLowerCase();
      final barcode2 = item.codigoBarras2?.trim().toLowerCase();

      if ((barcode1 != null && barcode1 == trimmedBarcode) || (barcode2 != null && barcode2 == trimmedBarcode)) {
        return item;
      }
    }

    return null;
  }
}

/// Resultado da validação de código de barras
class BarcodeValidationResult {
  final bool isValid;
  final bool isEmpty;
  final bool allItemsCompleted;
  final bool isWrongSector;
  final bool noItemsForSector;
  final String? scannedBarcode;
  final SeparateItemConsultationModel? expectedItem;
  final SeparateItemConsultationModel? scannedItem;
  final int? userSectorCode;
  final String? errorMessage;

  const BarcodeValidationResult._({
    required this.isValid,
    required this.isEmpty,
    required this.allItemsCompleted,
    required this.isWrongSector,
    required this.noItemsForSector,
    this.scannedBarcode,
    this.expectedItem,
    this.scannedItem,
    this.userSectorCode,
    this.errorMessage,
  });

  factory BarcodeValidationResult.empty() {
    return const BarcodeValidationResult._(
      isValid: false,
      isEmpty: true,
      allItemsCompleted: false,
      isWrongSector: false,
      noItemsForSector: false,
      errorMessage: 'Código de barras vazio',
    );
  }

  factory BarcodeValidationResult.allItemsCompleted() {
    return const BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: true,
      isWrongSector: false,
      noItemsForSector: false,
      errorMessage: 'Todos os itens já foram separados',
    );
  }

  factory BarcodeValidationResult.noItemsForSector(int userSectorCode) {
    return BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: false,
      isWrongSector: false,
      noItemsForSector: true,
      userSectorCode: userSectorCode,
      errorMessage: 'Não há mais itens do seu setor para separar',
    );
  }

  factory BarcodeValidationResult.valid(SeparateItemConsultationModel item) {
    return BarcodeValidationResult._(
      isValid: true,
      isEmpty: false,
      allItemsCompleted: false,
      isWrongSector: false,
      noItemsForSector: false,
      expectedItem: item,
    );
  }

  factory BarcodeValidationResult.invalid(String scannedBarcode, SeparateItemConsultationModel expectedItem) {
    return BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: false,
      isWrongSector: false,
      noItemsForSector: false,
      scannedBarcode: scannedBarcode,
      expectedItem: expectedItem,
      errorMessage: 'Código de barras não corresponde ao próximo item esperado',
    );
  }

  factory BarcodeValidationResult.wrongSector(
    String scannedBarcode,
    SeparateItemConsultationModel scannedItem,
    int userSectorCode,
  ) {
    return BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: false,
      isWrongSector: true,
      noItemsForSector: false,
      scannedBarcode: scannedBarcode,
      scannedItem: scannedItem,
      userSectorCode: userSectorCode,
      errorMessage: 'Produto pertence a outro setor de estoque',
    );
  }
}
