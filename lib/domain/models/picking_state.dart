import 'package:exp/domain/models/separate_item_consultation_model.dart';

/// Modelo de estado para um item de picking
class PickingItemState {
  final String itemId;
  final int pickedQuantity;
  final bool isCompleted;
  final int totalQuantity;

  const PickingItemState({
    required this.itemId,
    required this.pickedQuantity,
    required this.isCompleted,
    required this.totalQuantity,
  });

  PickingItemState copyWith({String? itemId, int? pickedQuantity, bool? isCompleted, int? totalQuantity}) {
    return PickingItemState(
      itemId: itemId ?? this.itemId,
      pickedQuantity: pickedQuantity ?? this.pickedQuantity,
      isCompleted: isCompleted ?? this.isCompleted,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  /// Atualiza a quantidade separada e recalcula se está completo
  PickingItemState updateQuantity(int newQuantity) {
    return copyWith(pickedQuantity: newQuantity, isCompleted: newQuantity >= totalQuantity);
  }

  /// Marca o item como completo com a quantidade total
  PickingItemState markAsCompleted() {
    return copyWith(pickedQuantity: totalQuantity, isCompleted: true);
  }
}

/// Estado consolidado do picking
class PickingState {
  final Map<String, PickingItemState> _itemStates;

  const PickingState(this._itemStates);

  /// Cria estado inicial baseado nos itens
  factory PickingState.initial(List<SeparateItemConsultationModel> items) {
    final Map<String, PickingItemState> states = {};

    for (final item in items) {
      states[item.item] = PickingItemState(
        itemId: item.item,
        pickedQuantity: item.quantidadeSeparacao.toInt(),
        isCompleted: item.isCompletamenteSeparado,
        totalQuantity: item.quantidade.toInt(),
      );
    }

    return PickingState(states);
  }

  /// Obtém o estado de um item específico
  PickingItemState? getItemState(String itemId) => _itemStates[itemId];

  /// Atualiza a quantidade de um item
  PickingState updateItemQuantity(String itemId, int quantity) {
    final currentState = _itemStates[itemId];
    if (currentState == null) return this;

    final updatedStates = Map<String, PickingItemState>.from(_itemStates);
    updatedStates[itemId] = currentState.updateQuantity(quantity);

    return PickingState(updatedStates);
  }

  /// Marca um item como completo
  PickingState completeItem(String itemId) {
    final currentState = _itemStates[itemId];
    if (currentState == null) return this;

    final updatedStates = Map<String, PickingItemState>.from(_itemStates);
    updatedStates[itemId] = currentState.markAsCompleted();

    return PickingState(updatedStates);
  }

  /// Obtém a quantidade separada de um item
  int getPickedQuantity(String itemId) {
    return _itemStates[itemId]?.pickedQuantity ?? 0;
  }

  /// Verifica se um item foi completado
  bool isItemCompleted(String itemId) {
    return _itemStates[itemId]?.isCompleted ?? false;
  }

  /// Conta itens completados
  int get completedItems => _itemStates.values.where((state) => state.isCompleted).length;

  /// Conta total de itens
  int get totalItems => _itemStates.length;

  /// Calcula progresso
  double get progress => totalItems > 0 ? completedItems / totalItems : 0.0;

  /// Verifica se o picking está completo
  bool get isComplete => completedItems == totalItems && totalItems > 0;

  /// Obtém todos os estados dos itens
  Map<String, PickingItemState> get itemStates => Map.unmodifiable(_itemStates);
}
