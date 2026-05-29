import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';

class CartCancelFlowCoordinator {
  final int codCarrinho;
  final VoidCallback? onCancel;

  const CartCancelFlowCoordinator({required this.codCarrinho, this.onCancel});

  Future<void> cancelCart(ScaffoldMessengerState messenger, SeparationItemsViewModel vm) async {
    final errorColor = Theme.of(messenger.context).colorScheme.error;
    try {
      final success = await vm.cancelCart(codCarrinho);

      if (success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Carrinho #$codCarrinho cancelado com sucesso!'), backgroundColor: AppColors.success),
        );

        onCancel?.call();
      } else {
        final errorMessage = vm.lastCancelError ?? 'Erro ao cancelar carrinho';
        messenger.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: errorColor));
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao cancelar carrinho', tag: 'CartItemCard', error: e, stackTrace: stackTrace);
      messenger.showSnackBar(
        SnackBar(content: const Text('Erro inesperado. Tente novamente.'), backgroundColor: errorColor),
      );
    }
  }
}
