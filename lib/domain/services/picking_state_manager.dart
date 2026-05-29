import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';

class PickingStateManager extends ChangeNotifier {
  PickingState _state = const PickingState({});

  PickingState get pickingState => _state;

  int get totalItems => _state.totalItems;

  int get completedItems => _state.completedItems;

  double get progress => _state.progress;

  bool get isComplete => _state.isComplete;

  int getPickedQuantity(String itemId) => _state.getPickedQuantity(itemId);

  bool isItemCompleted(String itemId) => _state.isItemCompleted(itemId);

  void initial(List<SeparateItemConsultationModel> items) {
    _state = PickingState.initial(items);
    notifyListeners();
  }

  void updateItemQuantity(String itemId, int quantity) {
    _state = _state.updateItemQuantity(itemId, quantity);
    notifyListeners();
  }

  void updateItemQuantityAndAddPending(String itemId, int quantityToAdd, DateTime timestamp) {
    final current = _state.getPickedQuantity(itemId);
    _state = _state
        .updateItemQuantity(itemId, current + quantityToAdd)
        .addPendingOperation(itemId, quantityToAdd, timestamp);
    notifyListeners();
  }

  void addPendingOperation(String itemId, int quantity, DateTime timestamp) {
    _state = _state.addPendingOperation(itemId, quantity, timestamp);
    notifyListeners();
  }

  void updateOperationStatus(String itemId, DateTime timestamp, PendingOperationStatus status, {String? errorMessage}) {
    _state = _state.updateOperationStatus(itemId, timestamp, status, errorMessage: errorMessage);
    notifyListeners();
  }

  void clearSyncedOperations(String itemId) {
    _state = _state.clearSyncedOperations(itemId);
    notifyListeners();
  }

  void completeItem(String itemId) {
    _state = _state.completeItem(itemId);
    notifyListeners();
  }

  void revertQuantityAndMarkOperationFailed(
    String itemId,
    int quantityToRevert,
    DateTime timestamp,
    String? errorMessage,
  ) {
    final current = _state.getPickedQuantity(itemId);
    final reverted = current - quantityToRevert;
    _state = _state
        .updateItemQuantity(itemId, reverted < 0 ? 0 : reverted)
        .updateOperationStatus(itemId, timestamp, PendingOperationStatus.failed, errorMessage: errorMessage);
    notifyListeners();
  }
}
