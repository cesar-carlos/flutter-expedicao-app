import 'package:flutter/material.dart';

import 'package:data7_expedicao/presentation/viewmodels/separation_items_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/cart_item_card.dart';
import 'package:data7_expedicao/ui/widgets/separate_items/carts_empty_state.dart';

class CartsListView extends StatelessWidget {
  final SeparationItemsViewModel viewModel;
  final ScrollController? scrollController;

  const CartsListView({super.key, required this.viewModel, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (!viewModel.cartsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!viewModel.hasCartsData) {
      return const CartsEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await viewModel.refresh();
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
        itemCount: viewModel.carts.length,
        itemBuilder: (context, index) {
          final cart = viewModel.carts[index];
          return CartItemCard(cartRouteInternshipConsultation: cart, viewModel: viewModel);
        },
      ),
    );
  }
}
