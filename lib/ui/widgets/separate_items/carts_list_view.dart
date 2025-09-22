import 'package:flutter/material.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/viewmodels/separate_items_viewmodel.dart';
import 'package:exp/ui/widgets/separate_items/cart_item_card.dart';
import 'package:exp/ui/widgets/separate_items/carts_empty_state.dart';

class CartsListView extends StatelessWidget {
  final SeparateItemsViewModel viewModel;

  const CartsListView({super.key, required this.viewModel});

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: viewModel.carts.length,
        itemBuilder: (context, index) {
          final cart = viewModel.carts[index];
          return CartItemCard(
            cart: cart,
            onTap: () => _onCartTap(context, cart),
            onCancel: () => _onCartCancel(context, cart),
            viewModel: viewModel,
          );
        },
      ),
    );
  }

  void _onCartTap(BuildContext context, ExpeditionCartRouteInternshipConsultationModel cart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Carrinho ${cart.nomeCarrinho} selecionado'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _onCartCancel(BuildContext context, ExpeditionCartRouteInternshipConsultationModel cart) {
    viewModel.refresh();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lista de carrinhos atualizada'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
