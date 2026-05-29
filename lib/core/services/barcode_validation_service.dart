import 'dart:collection';

import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/core/utils/picking_utils.dart';

class BarcodeValidationService {
  /// Capacidade máxima do cache de busca por código de barras.
  /// Usado para evitar crescimento ilimitado em sessões longas (B10).
  static const int _maxCacheSize = 256;

  /// Cache LRU de busca por código de barras.
  /// Vinculado à `identityHashCode` da última lista de items vista,
  /// para invalidação automática ao trocar de separação (B1).
  static final LinkedHashMap<String, SeparateItemConsultationModel?> _barcodeSearchCache =
      LinkedHashMap<String, SeparateItemConsultationModel?>();

  /// Identidade da última lista de items para qual o cache foi populado.
  /// Trocou a lista? Invalidamos automaticamente.
  static int? _cachedItemsIdentity;

  static void clearCaches() {
    _barcodeSearchCache.clear();
    _cachedItemsIdentity = null;
  }

  static BarcodeValidationResult validateScannedBarcode(
    String scannedBarcode,
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted, {
    SeparateItemConsultationModel? expectedItem,
    int? userSectorCode,
    bool allowOutOfSequence = false,
  }) {
    if (scannedBarcode.trim().isEmpty) {
      return BarcodeValidationResult.empty();
    }

    final nextItem =
        expectedItem ?? PickingUtils.findNextItemToPick(items, isItemCompleted, userSectorCode: userSectorCode);

    if (nextItem == null) {
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

    final isValid = PickingUtils.validateBarcode(scannedBarcode, nextItem);

    if (isValid) {
      return BarcodeValidationResult.valid(nextItem);
    } else {
      final scannedItem = _findItemByBarcode(items, scannedBarcode);

      if (scannedItem != null && userSectorCode != null) {
        final productSector = scannedItem.codSetorEstoque;
        if (productSector != null && productSector != userSectorCode) {
          return BarcodeValidationResult.wrongSector(scannedBarcode, scannedItem, userSectorCode);
        }
      }

      // Regra "separar fora de sequência": quando o usuário tem a permissão,
      // aceitamos qualquer item pendente cujo código de barras casa (já
      // descartado o caso de setor incorreto acima), e não apenas o próximo
      // item da ordem sugerida.
      if (allowOutOfSequence && scannedItem != null && !isItemCompleted(scannedItem.item)) {
        return BarcodeValidationResult.valid(scannedItem);
      }

      return BarcodeValidationResult.invalid(scannedBarcode, nextItem);
    }
  }

  static SeparateItemConsultationModel? _findItemByBarcode(List<SeparateItemConsultationModel> items, String barcode) {
    final trimmedBarcode = barcode.trim();
    final itemsIdentity = identityHashCode(items);

    // Invalidação automática (B1): se a lista mudou desde o último cache,
    // descarta tudo antes de consultar.
    if (_cachedItemsIdentity != itemsIdentity) {
      _barcodeSearchCache.clear();
      _cachedItemsIdentity = itemsIdentity;
    }

    if (_barcodeSearchCache.containsKey(trimmedBarcode)) {
      // Move para o final (estilo LRU): chave acessada vira a mais recente.
      final cached = _barcodeSearchCache.remove(trimmedBarcode);
      _barcodeSearchCache[trimmedBarcode] = cached;
      return cached;
    }

    SeparateItemConsultationModel? foundItem;

    for (final item in items) {
      final barcode1 = item.codigoBarras?.trim();
      final barcode2 = item.codigoBarras2?.trim();

      if ((barcode1 != null && barcode1 == trimmedBarcode) || (barcode2 != null && barcode2 == trimmedBarcode)) {
        foundItem = item;
        break;
      }

      final unidadeEncontrada = item.buscarUnidadeMedidaPorCodigoBarras(trimmedBarcode);
      if (unidadeEncontrada != null) {
        foundItem = item;
        break;
      }
    }

    _barcodeSearchCache[trimmedBarcode] = foundItem;

    // Eviction LRU (B10): remove a entrada mais antiga se estourar o teto.
    if (_barcodeSearchCache.length > _maxCacheSize) {
      _barcodeSearchCache.remove(_barcodeSearchCache.keys.first);
    }

    return foundItem;
  }
}

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
