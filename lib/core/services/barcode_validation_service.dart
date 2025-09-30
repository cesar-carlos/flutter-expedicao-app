import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/core/utils/picking_utils.dart';

/// Serviço para validação e processamento de códigos de barras
class BarcodeValidationService {
  /// Valida se o código escaneado corresponde ao próximo item esperado
  static BarcodeValidationResult validateScannedBarcode(
    String scannedBarcode,
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted,
  ) {
    if (scannedBarcode.trim().isEmpty) {
      return BarcodeValidationResult.empty();
    }

    // Encontrar o próximo item a ser separado
    final nextItem = PickingUtils.findNextItemToPick(items, isItemCompleted);

    if (nextItem == null) {
      return BarcodeValidationResult.allItemsCompleted();
    }

    // Validar se o código corresponde ao próximo item
    final isValid = PickingUtils.validateBarcode(scannedBarcode, nextItem);

    if (isValid) {
      return BarcodeValidationResult.valid(nextItem);
    } else {
      return BarcodeValidationResult.invalid(scannedBarcode, nextItem);
    }
  }
}

/// Resultado da validação de código de barras
class BarcodeValidationResult {
  final bool isValid;
  final bool isEmpty;
  final bool allItemsCompleted;
  final String? scannedBarcode;
  final SeparateItemConsultationModel? expectedItem;
  final String? errorMessage;

  const BarcodeValidationResult._({
    required this.isValid,
    required this.isEmpty,
    required this.allItemsCompleted,
    this.scannedBarcode,
    this.expectedItem,
    this.errorMessage,
  });

  factory BarcodeValidationResult.empty() {
    return const BarcodeValidationResult._(
      isValid: false,
      isEmpty: true,
      allItemsCompleted: false,
      errorMessage: 'Código de barras vazio',
    );
  }

  factory BarcodeValidationResult.allItemsCompleted() {
    return const BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: true,
      errorMessage: 'Todos os itens já foram separados',
    );
  }

  factory BarcodeValidationResult.valid(SeparateItemConsultationModel item) {
    return BarcodeValidationResult._(isValid: true, isEmpty: false, allItemsCompleted: false, expectedItem: item);
  }

  factory BarcodeValidationResult.invalid(String scannedBarcode, SeparateItemConsultationModel expectedItem) {
    return BarcodeValidationResult._(
      isValid: false,
      isEmpty: false,
      allItemsCompleted: false,
      scannedBarcode: scannedBarcode,
      expectedItem: expectedItem,
      errorMessage: 'Código de barras não corresponde ao próximo item esperado',
    );
  }
}
