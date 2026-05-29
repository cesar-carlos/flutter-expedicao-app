import 'dart:async';

import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/picking_state.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/services/picking_state_manager.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/add_item_separation/add_item_separation_usecase.dart';
import 'package:data7_expedicao/presentation/viewmodels/controllers/picking_pending_operations_tracker.dart';

/// Coordena a orquestração assíncrona de adição de itens no picking.
///
/// Extraído de [CardPickingViewModel] (refator F10) para isolar o ciclo de
/// vida de uma operação de sincronização: rastreamento como pendente,
/// chamada do use case, atualização de status no [PickingStateManager],
/// rollback otimista em falha e limpeza tardia das operações sincronizadas.
///
/// O ViewModel mantém os entry points públicos (`addScannedItem` /
/// `updatePickedQuantityWithSync`), faz o update otimista local e a
/// validação, e delega aqui a parte assíncrona. O comportamento observável
/// (ordem das notificações, guards de `disposed`, locks e rollback) é
/// idêntico ao anterior — esta classe apenas recebe os colaboradores via
/// callbacks/dependências injetadas.
class PickingAddItemCoordinator {
  final AddItemSeparationUseCase _addItemSeparationUseCase;
  final PickingStateManager _stateManager;
  final PickingPendingOperationsTracker _pendingOperations;
  final bool Function() _isDisposed;
  final void Function() _notifyListeners;
  final void Function() _scheduleQueuedResync;
  final void Function(String itemId, String errorMessage) _notifyOperationError;

  PickingAddItemCoordinator({
    required AddItemSeparationUseCase addItemSeparationUseCase,
    required PickingStateManager stateManager,
    required PickingPendingOperationsTracker pendingOperations,
    required bool Function() isDisposed,
    required void Function() notifyListeners,
    required void Function() scheduleQueuedResync,
    required void Function(String itemId, String errorMessage) notifyOperationError,
  }) : _addItemSeparationUseCase = addItemSeparationUseCase,
       _stateManager = stateManager,
       _pendingOperations = pendingOperations,
       _isDisposed = isDisposed,
       _notifyListeners = notifyListeners,
       _scheduleQueuedResync = scheduleQueuedResync,
       _notifyOperationError = notifyOperationError;

  /// Inicia a operação assíncrona, registra-a no tracker de pendências e
  /// aguarda sua conclusão. Os callers continuam fire-and-forget.
  Future<void> executeAsyncAddItem(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    final operation = _performAddItemOperation(params, userSystem, itemId, quantity, timestamp);
    _pendingOperations.track(itemId, operation);
    await operation;
  }

  Future<void> _performAddItemOperation(
    AddItemSeparationParams params,
    UserSystemModel userSystem,
    String itemId,
    int quantity,
    DateTime timestamp,
  ) async {
    try {
      _updateOperationStatus(itemId, timestamp, PendingOperationStatus.syncing);

      final result = await _addItemSeparationUseCase.call(params, userSystem: userSystem);

      await result.fold(
        (success) async {
          _updateOperationStatus(itemId, timestamp, PendingOperationStatus.synced);

          unawaited(
            Future<void>.delayed(const Duration(seconds: 2), () {
              if (!_isDisposed()) {
                _stateManager.clearSyncedOperations(itemId);
                _notifyListeners();
                _scheduleQueuedResync();
              }
            }).catchError((Object e, StackTrace s) {
              AppLogger.warning(
                'Falha no delayed de limpeza de operação sincronizada',
                tag: 'CardPickingViewModel',
                error: e,
                stackTrace: s,
              );
            }),
          );
        },
        (failure) async {
          _handleAddItemFailure(itemId, quantity, timestamp, failure);
        },
      );
    } catch (e) {
      _handleAddItemFailure(itemId, quantity, timestamp, e);
    }
  }

  void _handleAddItemFailure(String itemId, int quantity, DateTime timestamp, dynamic error) {
    if (_isDisposed()) return;
    final errorMessage = error is AppFailure ? error.userMessage : error.toString();
    _stateManager.revertQuantityAndMarkOperationFailed(itemId, quantity, timestamp, errorMessage);
    _notifyListeners();
    _notifyOperationError(itemId, errorMessage);
  }

  void _updateOperationStatus(
    String itemId,
    DateTime timestamp,
    PendingOperationStatus status, {
    String? errorMessage,
  }) {
    if (_isDisposed()) return;
    _stateManager.updateOperationStatus(itemId, timestamp, status, errorMessage: errorMessage);
    _notifyListeners();
  }
}
