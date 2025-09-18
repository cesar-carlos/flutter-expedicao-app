import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/add_cart_viewmodel.dart';
import 'package:exp/ui/widgets/common/custom_app_bar.dart';
import 'package:exp/ui/widgets/add_cart/barcode_scanner_widget.dart';
import 'package:exp/ui/widgets/add_cart/cart_details_widget.dart';
import 'package:exp/ui/widgets/add_cart/cart_actions_widget.dart';

class AddCartScreen extends StatefulWidget {
  final int codEmpresa;
  final int codSepararEstoque;

  const AddCartScreen({super.key, required this.codEmpresa, required this.codSepararEstoque});

  @override
  State<AddCartScreen> createState() => _AddCartScreenState();
}

class _AddCartScreenState extends State<AddCartScreen> {
  final _scrollController = ScrollController();
  late AddCartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddCartViewModel(codEmpresa: widget.codEmpresa, codSepararEstoque: widget.codSepararEstoque);

    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (_viewModel.hasCartData && !_viewModel.isScanning) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToActions();
      });
    }
  }

  void _scrollToActions() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AddCartViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: CustomAppBar.withoutSocket(
              title: 'Incluir Carrinho',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Voltar',
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BarcodeScanner(onBarcodeScanned: viewModel.scanBarcode, isLoading: viewModel.isScanning),

                    const SizedBox(height: 24),

                    if (viewModel.hasCartData) ...[
                      CartDetailsWidget(cart: viewModel.scannedCart!),

                      const SizedBox(height: 24),

                      CartActionsWidget(
                        viewModel: viewModel,
                        onCancel: () => Navigator.of(context).pop(),
                        onAdd: () => _onAddCart(viewModel),
                      ),
                    ],

                    if (viewModel.hasError)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              viewModel.errorMessage ?? 'Erro desconhecido',
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onAddCart(AddCartViewModel viewModel) async {
    final success = await viewModel.addCartToSeparation();

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Carrinho adicionado com sucesso!'), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(viewModel.errorMessage ?? 'Erro ao adicionar carrinho'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
