import 'package:exp/domain/models/separate_item_consultation_model.dart';

/// Estado de operação pendente
enum PendingOperationStatus { pending, syncing, synced, failed }

/// Operação pendente de adição de item
class PendingOperation {
  final String itemId;
  final int quantity;
  final DateTime timestamp;
  final PendingOperationStatus status;
  final String? errorMessage;

  const PendingOperation({
    required this.itemId,
    required this.quantity,
    required this.timestamp,
    required this.status,
    this.errorMessage,
  });

  PendingOperation copyWith({
    String? itemId,
    int? quantity,
    DateTime? timestamp,
    PendingOperationStatus? status,
    String? errorMessage,
  }) {
    return PendingOperation(
      itemId: itemId ?? this.itemId,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Modelo de estado para um item de picking
class PickingItemState {
  final String itemId;
  final int pickedQuantity;
  final bool isCompleted;
  final int totalQuantity;
  final List<PendingOperation> pendingOperations;

  const PickingItemState({
    required this.itemId,
    required this.pickedQuantity,
    required this.isCompleted,
    required this.totalQuantity,
    this.pendingOperations = const [],
  });

  /// Verifica se há operações pendentes de sincronização
  bool get hasPendingSync => pendingOperations.isNotEmpty;

  PickingItemState copyWith({
    String? itemId,
    int? pickedQuantity,
    bool? isCompleted,
    int? totalQuantity,
    List<PendingOperation>? pendingOperations,
  }) {
    return PickingItemState(
      itemId: itemId ?? this.itemId,
      pickedQuantity: pickedQuantity ?? this.pickedQuantity,
      isCompleted: isCompleted ?? this.isCompleted,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      pendingOperations: pendingOperations ?? this.pendingOperations,
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

  /// Adiciona uma nova operação pendente
  PickingItemState addPendingOperation(int quantity, DateTime timestamp) {
    final newOperation = PendingOperation(
      itemId: itemId,
      quantity: quantity,
      timestamp: timestamp,
      status: PendingOperationStatus.pending,
    );

    final updatedOperations = List<PendingOperation>.from(pendingOperations)..add(newOperation);
    return copyWith(pendingOperations: updatedOperations);
  }

  /// Atualiza o status de uma operação pendente específica
  PickingItemState updateOperationStatus(DateTime timestamp, PendingOperationStatus status, {String? errorMessage}) {
    final updatedOperations = pendingOperations.map((op) {
      if (op.timestamp == timestamp) {
        return op.copyWith(status: status, errorMessage: errorMessage);
      }
      return op;
    }).toList();

    return copyWith(pendingOperations: updatedOperations);
  }

  /// Remove operações que foram sincronizadas com sucesso
  PickingItemState clearSyncedOperations() {
    final filteredOperations = pendingOperations.where((op) => op.status != PendingOperationStatus.synced).toList();
    return copyWith(pendingOperations: filteredOperations);
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

  /// Adiciona uma operação pendente a um item
  PickingState addPendingOperation(String itemId, int quantity, DateTime timestamp) {
    final currentState = _itemStates[itemId];
    if (currentState == null) return this;

    final updatedStates = Map<String, PickingItemState>.from(_itemStates);
    updatedStates[itemId] = currentState.addPendingOperation(quantity, timestamp);

    return PickingState(updatedStates);
  }

  /// Atualiza o status de uma operação pendente
  PickingState updateOperationStatus(
    String itemId,
    DateTime timestamp,
    PendingOperationStatus status, {
    String? errorMessage,
  }) {
    final currentState = _itemStates[itemId];
    if (currentState == null) return this;

    final updatedStates = Map<String, PickingItemState>.from(_itemStates);
    updatedStates[itemId] = currentState.updateOperationStatus(timestamp, status, errorMessage: errorMessage);

    return PickingState(updatedStates);
  }

  /// Remove operações sincronizadas de um item
  PickingState clearSyncedOperations(String itemId) {
    final currentState = _itemStates[itemId];
    if (currentState == null) return this;

    final updatedStates = Map<String, PickingItemState>.from(_itemStates);
    updatedStates[itemId] = currentState.clearSyncedOperations();

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

  /// Retorna o total de operações pendentes em todos os itens
  int getTotalPendingOperations() {
    return _itemStates.values.fold(0, (sum, state) => sum + state.pendingOperations.length);
  }

  /// Retorna as operações pendentes de um item específico
  List<PendingOperation> getPendingOperationsForItem(String itemId) {
    final state = _itemStates[itemId];
    return state?.pendingOperations ?? [];
  }

  /// Verifica se há alguma operação pendente
  bool hasAnyPendingOperations() {
    return _itemStates.values.any((state) => state.hasPendingSync);
  }
}
