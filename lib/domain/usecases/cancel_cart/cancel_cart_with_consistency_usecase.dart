import 'package:data7_expedicao/core/results/index.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_params.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_success.dart';
import 'package:data7_expedicao/domain/usecases/cancel_cart/cancel_cart_usecase.dart';
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

    CancelCardItemSeparationSuccess? cancelledItemsSnapshot;
    final canCancelItems = await _cancelCardItemSeparationUseCase.canCancelItems(cancelItemParams);

    if (canCancelItems) {
      final cancelItemsResult = await _cancelCardItemSeparationUseCase.call(cancelItemParams);
      if (cancelItemsResult.isError()) {
        final failureException = cancelItemsResult.exceptionOrNull();
        final details = failureException is AppFailure ? failureException.userMessage : 'Falha ao cancelar itens';
        return failure(CancelCartFailure.updateFailed(details));
      }
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

    final cancelFailure = cancelCartResult.exceptionOrNull();
    if (cancelFailure is CancelCartFailure) {
      return failure(cancelFailure);
    }

    if (cancelFailure is AppFailure) {
      return failure(CancelCartFailure.updateFailed(cancelFailure.userMessage));
    }

    return failure(CancelCartFailure.unknown('Falha ao cancelar carrinho'));
  }
}
