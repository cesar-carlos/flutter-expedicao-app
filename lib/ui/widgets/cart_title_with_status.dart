import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

/// Widget que exibe o título do carrinho com sua situação em tempo real
class CartTitleWithStatus extends StatelessWidget {
  final String cartName;

  const CartTitleWithStatus({super.key, required this.cartName});

  @override
  Widget build(BuildContext context) {
    return Consumer<CardPickingViewModel>(
      builder: (context, viewModel, child) {
        final cart = viewModel.cart;
        final displayName = cart?.nomeCarrinho ?? cartName;

        return Text(
          displayName,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        );
      },
    );
  }
}
