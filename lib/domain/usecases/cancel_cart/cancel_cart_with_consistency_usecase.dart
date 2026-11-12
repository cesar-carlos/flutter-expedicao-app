import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart_item_separation/cancel_cart_item_separation_usecase.dart';

class CancelCartWithConsistencyUseCase {
  final CancelCartUseCase _cancelCartUseCase;
  final CancelCardItemSeparationUseCase _cancelCardItemSeparationUseCase;

  CancelCartWithConsistencyUseCase({
    required CancelCartUseCase cancelCartUseCase,
    required CancelCardItemSeparationUseCase cancelCardItemSeparationUseCase,
  }) : _cancelCartUseCase = cancelCartUseCase,
       _cancelCardItemSeparationUseCase = cancelCardItemSeparationUseCase;

  Future<Result<CancelCartSuccess>> call({
    required CancelCartParams cancelCartParams,
    required CancelCardItemSeparationParams cancelItemParams,
  }) async {
    if (!cancelCartParams.isValid || !cancelItemParams.isValid) {
      return failure(CancelCartFailure.invalidParams('Parâmetros inválidos para cancelamento consistente'));
    }

    final ready = await _cancelCartUseCase.ensureCanCancel(cancelCartParams);
    if (ready.isError()) {
      return _asCancelCartFailure(ready.exceptionOrNull(), 'Falha ao validar cancelamento do carrinho');
    }

    CancelCardItemSeparationSuccess? cancelledItemsSnapshot;
    final cancelItemsResult = await _cancelCardItemSeparationUseCase.call(cancelItemParams);
    if (cancelItemsResult.isError()) {
      final itemsFailure = cancelItemsResult.exceptionOrNull();
      if (!_isItemsNotFound(itemsFailure)) {
        final details = itemsFailure is AppFailure ? itemsFailure.userMessage : 'Falha ao cancelar itens';
        return failure(CancelCartFailure.updateFailed(details));
      }
    } else {
      cancelledItemsSnapshot = cancelItemsResult.getOrNull();
    }

    final cancelCartResult = await _cancelCartUseCase.call(cancelCartParams);
    if (cancelCartResult.isSuccess()) {
      return cancelCartResult;
    }

    if (cancelledItemsSnapshot != null) {
      final rollbackSuccess = await _cancelCardItemSeparationUseCase.rollbackCancellation(cancelledItemsSnapshot);
      if (!rollbackSuccess) {
        return failure(
          CancelCartFailure.updateFailed(
            'Falha ao cancelar carrinho e também ao reverter itens. Estado pode estar inconsistente.',
          ),
        );
      }
    }

    return _asCancelCartFailure(cancelCartResult.exceptionOrNull(), 'Falha ao cancelar carrinho');
  }

  bool _isItemsNotFound(Object? error) {
    return error is CancelCardItemSeparationFailure && error.type == CancelCardItemSeparationFailureType.itemsNotFound;
  }

  Result<CancelCartSuccess> _asCancelCartFailure(Object? error, String fallback) {
    if (error is CancelCartFailure) {
      return failure(error);
    }
    if (error is AppFailure) {
      return failure(CancelCartFailure.updateFailed(error.userMessage));
    }
    return failure(CancelCartFailure.unknown(fallback));
  }
}
