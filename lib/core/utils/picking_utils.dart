import 'package:exp/domain/models/separate_item_consultation_model.dart';

/// Utilitários para operações de picking
class PickingUtils {
  /// Ordena itens por endereço de descrição
  static List<SeparateItemConsultationModel> sortItemsByAddress(List<SeparateItemConsultationModel> items) {
    return List.from(items)..sort((a, b) => (a.enderecoDescricao ?? '').compareTo(b.enderecoDescricao ?? ''));
  }

  /// Encontra o próximo item a ser separado
  static SeparateItemConsultationModel? findNextItemToPick(
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted,
  ) {
    final sortedItems = sortItemsByAddress(items);
    return sortedItems.where((item) => !isItemCompleted(item.item)).firstOrNull;
  }

  /// Valida se o código de barras corresponde ao item esperado
  static bool validateBarcode(String scannedBarcode, SeparateItemConsultationModel expectedItem) {
    final trimmedBarcode = scannedBarcode.trim().toLowerCase();
    final expectedBarcode1 = expectedItem.codigoBarras?.trim().toLowerCase();
    final expectedBarcode2 = expectedItem.codigoBarras2?.trim().toLowerCase();

    return (expectedBarcode1 != null && expectedBarcode1 == trimmedBarcode) ||
        (expectedBarcode2 != null && expectedBarcode2 == trimmedBarcode);
  }

  /// Calcula o progresso de separação
  static double calculateProgress(int completedItems, int totalItems) {
    return totalItems > 0 ? completedItems / totalItems : 0.0;
  }

  /// Verifica se todos os itens foram completados
  static bool isPickingComplete(int completedItems, int totalItems) {
    return completedItems == totalItems && totalItems > 0;
  }
}
