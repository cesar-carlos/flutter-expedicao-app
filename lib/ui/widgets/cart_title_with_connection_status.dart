import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/common/title_with_connection_status.dart';

class CartTitleWithConnectionStatus extends StatelessWidget {
  final String cartName;

  const CartTitleWithConnectionStatus({super.key, required this.cartName});

  @override
  Widget build(BuildContext context) {
    return TitleWithConnectionStatus(
      dynamicTitleBuilder: (context) {
        return Consumer<CardPickingViewModel>(
          builder: (context, pickingViewModel, child) {
            final theme = Theme.of(context);
            final cart = pickingViewModel.cart;
            final displayName = cart?.nomeCarrinho ?? cartName;

            return Text(
              displayName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            );
          },
        );
      },
    );
  }
}
