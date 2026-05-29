import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';

/// Gerencia o cache do "próximo item" a separar no fluxo de picking.
///
/// Extraído de [CardPickingViewModel] (refator F8) para isolar o estado do
/// cache e a regra de "qual é o próximo item pendente na ordem atual".
///
/// Classe pura/testável: não depende de `ChangeNotifier`, locator nem
/// `BuildContext`. Recebe a lista de itens e os predicados de estado via
/// parâmetros, preservando exatamente o comportamento anterior do
/// ViewModel.
class NextItemCacheManager {
  SeparateItemConsultationModel? _cache;

  /// Item atualmente em cache. Pode estar desatualizado se a lista mudou
  /// sem uma chamada a [update].
  SeparateItemConsultationModel? get current => _cache;

  /// Limpa o cache (espelha o antigo `_clearNextItemCache`).
  void clear() {
    _cache = null;
  }

  /// Recalcula o cache a partir da lista atual de itens
  /// (espelha o antigo `_updateNextItemCache`).
  void update(
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted,
  ) {
    _cache = _findNext(items, isItemCompleted);
  }

  /// Retorna o item em cache ou, se nulo, calcula sob demanda sem
  /// persistir no cache. Espelha o padrão antigo
  /// `_nextItemCache ?? _findNextItemFromCurrentOrder()`.
  SeparateItemConsultationModel? currentOrCompute(
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted,
  ) {
    return _cache ?? _findNext(items, isItemCompleted);
  }

  /// Quantidade máxima que ainda pode ser separada para o próximo item em
  /// cache. Preserva exatamente a regra antiga de `maxQuantityForNextItem`:
  /// retorna 999 sem item em cache e no mínimo 1 quando o restante é <= 0.
  int maxQuantity(int Function(String itemId) getPickedQuantity) {
    final nextItem = _cache;
    if (nextItem == null) return 999;
    final totalQuantity = nextItem.quantidade.toInt();
    final pickedQuantity = getPickedQuantity(nextItem.item);
    final remainingQuantity = totalQuantity - pickedQuantity;
    return remainingQuantity > 0 ? remainingQuantity : 1;
  }

  SeparateItemConsultationModel? _findNext(
    List<SeparateItemConsultationModel> items,
    bool Function(String itemId) isItemCompleted,
  ) {
    for (final item in items) {
      if (!isItemCompleted(item.item)) {
        return item;
      }
    }

    return null;
  }
}
