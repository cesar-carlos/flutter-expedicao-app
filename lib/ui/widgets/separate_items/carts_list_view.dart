import 'dart:async';

import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/viewmodels/separation_items_viewmodel.dart';
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
          return CartItemCard(
            cartRouteInternshipConsultation: cart,
            onCancel: () => _onCartCancel(context, cart),
            viewModel: viewModel,
          );
        },
      ),
    );
  }

  void _onCartCancel(BuildContext context, ExpeditionCartRouteInternshipConsultationModel cart) {
    // Bug latente anterior: `viewModel.refresh()` retorna Future
    // descartado. Sem catch, qualquer erro durante refresh virava
    // "Unhandled Future error". Agora envolvemos em
    // `unawaited(... .catchError(AppLogger.warning))` consistente
    // com outros callsites.
    unawaited(
      viewModel.refresh().catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao atualizar lista de carrinhos apos cancelar',
          tag: 'CartsListView',
          error: e,
          stackTrace: s,
        );
      }),
    );

    // Bug EEEEEEEEE: callback pode rodar APOS o widget ser desmontado
    // (cancel async lento). ScaffoldMessenger.of(context) em context
    // invalido lanca, e como callback nao tem try/catch, propagaria.
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Lista de carrinhos atualizada'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
