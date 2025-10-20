import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';

/// Utilitários para operações de picking
class PickingUtils {
  /// Ordena itens por setor de estoque e depois por endereço usando ordenação natural
  ///
  /// REGRA DE NEGÓCIO:
  /// 1. Produtos SEM setor (codSetorEstoque == null) aparecem PRIMEIRO para todos os usuários
  /// 2. Depois, produtos DO setor do usuário logado (se o usuário tiver setor)
  /// 3. Dentro de cada grupo (sem setor / com setor), ordenar por endereço (ordenação natural)
  static List<SeparateItemConsultationModel> sortItemsByAddress(
    List<SeparateItemConsultationModel> items, {
    int? userSectorCode,
  }) {
    return List.from(items)..sort((a, b) {
      final sectorA = a.codSetorEstoque;
      final sectorB = b.codSetorEstoque;

      // Priorizar produtos sem setor definido (aparecem primeiro)
      if (sectorA == null && sectorB != null) return -1;
      if (sectorA != null && sectorB == null) return 1;

      // Se usuário tem setor definido, agrupar produtos do mesmo setor
      if (userSectorCode != null && sectorA != null && sectorB != null) {
        final isASameUserSector = sectorA == userSectorCode;
        final isBSameUserSector = sectorB == userSectorCode;

        // Priorizar produtos do setor do usuário
        if (isASameUserSector && !isBSameUserSector) return -1;
        if (!isASameUserSector && isBSameUserSector) return 1;
      }

      // Dentro do mesmo grupo (sem setor / mesmo setor), ordenar por endereço
      final endA = a.enderecoDescricao?.toLowerCase() ?? '';
      final endB = b.enderecoDescricao?.toLowerCase() ?? '';

      // Extrair números do início do endereço (01, 02, etc)
      final regExp = RegExp(r'^(\d+)');
      final matchA = regExp.firstMatch(endA);
      final matchB = regExp.firstMatch(endB);

      // Se ambos começam com números, comparar numericamente
      if (matchA != null && matchB != null) {
        final numA = int.parse(matchA.group(1)!);
        final numB = int.parse(matchB.group(1)!);
        if (numA != numB) return numA.compareTo(numB);
      }

      // Se um começa com número e outro não, priorizar o que começa com número
      if (matchA != null && matchB == null) return -1;
      if (matchA == null && matchB != null) return 1;

      // Caso contrário, ordenar alfabeticamente
      return endA.compareTo(endB);
    });
  }

  /// Encontra o próximo item a ser separado
  ///
  /// Considera a ordenação por setor de estoque e endereço
  static SeparateItemConsultationModel? findNextItemToPick(
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted, {
    int? userSectorCode,
  }) {
    final sortedItems = sortItemsByAddress(items, userSectorCode: userSectorCode);
    return sortedItems.where((item) => !isItemCompleted(item.item)).firstOrNull;
  }

  /// Valida se o código de barras corresponde ao item esperado
  /// Verifica tanto os códigos principais quanto os códigos das unidades de medida
  static bool validateBarcode(String scannedBarcode, SeparateItemConsultationModel expectedItem) {
    final trimmedBarcode = scannedBarcode.trim();
    final expectedBarcode1 = expectedItem.codigoBarras?.trim();
    final expectedBarcode2 = expectedItem.codigoBarras2?.trim();

    // Verificar códigos principais
    if ((expectedBarcode1 != null && expectedBarcode1 == trimmedBarcode) ||
        (expectedBarcode2 != null && expectedBarcode2 == trimmedBarcode)) {
      return true;
    }

    // Verificar se o código está na lista de unidades de medida
    final unidadeEncontrada = expectedItem.buscarUnidadeMedidaPorCodigoBarras(trimmedBarcode);
    return unidadeEncontrada != null;
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
