import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';

class CartCancelFlowCoordinator {
  final int codEmpresa;
  final int codCarrinhoPercurso;
  final String item;
  final int codCarrinho;

  const CartCancelFlowCoordinator({
    required this.codEmpresa,
    required this.codCarrinhoPercurso,
    required this.item,
    required this.codCarrinho,
  });

  Future<void> cancelCart(ScaffoldMessengerState messenger, SeparationItemsViewModel vm) async {
    final errorColor = Theme.of(messenger.context).colorScheme.error;
    try {
      final success = await vm.cancelCart(codEmpresa: codEmpresa, codCarrinhoPercurso: codCarrinhoPercurso, item: item);

      if (success) {
        messenger.showSnackBar(
          SnackBar(content: Text('Carrinho #$codCarrinho cancelado com sucesso!'), backgroundColor: AppColors.success),
        );
        return;
      }

      final errorMessage = vm.lastCancelError;
      if (errorMessage == null) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: errorColor));
    } catch (e, stackTrace) {
      AppLogger.error('Erro inesperado ao cancelar carrinho', tag: 'CartItemCard', error: e, stackTrace: stackTrace);
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppFailure.forUser(e, fallback: 'Não foi possível cancelar o carrinho. Tente novamente.')),
          backgroundColor: errorColor,
        ),
      );
    }
  }
}
