import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_consultation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/add_cart_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/add_cart/barcode_scanner_widget.dart';
import 'package:data7_expedicao/ui/widgets/add_cart/cart_actions_widget.dart';
import 'package:data7_expedicao/ui/widgets/add_cart/cart_details_widget.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';

class AddCartScreen extends StatefulWidget {
  final int codEmpresa;
  final int codSepararEstoque;

  const AddCartScreen({super.key, required this.codEmpresa, required this.codSepararEstoque});

  @override
  State<AddCartScreen> createState() => _AddCartScreenState();
}

class _AddCartScreenState extends State<AddCartScreen> {
  final _scrollController = ScrollController();
  int _lastSuccessCounter = 0;
  int? _lastScrolledCartCode;
  late final AddCartViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<AddCartViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    final currentCartCode = !_viewModel.isScanning ? _viewModel.scannedCart?.codCarrinho : null;

    if (currentCartCode == null) {
      _lastScrolledCartCode = null;
    } else if (currentCartCode != _lastScrolledCartCode) {
      _lastScrolledCartCode = currentCartCode;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToActions();
        }
      });
    }

    if (_viewModel.successCounter > _lastSuccessCounter && mounted) {
      _lastSuccessCounter = _viewModel.successCounter;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop(_viewModel.lastAddSuccess);
        }
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
    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: 'Incluir Carrinho',
        leading: IconButton(
          onPressed: () {
            _viewModel.cancelAutoAdd();
            context.pop();
          },
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
              Selector<AddCartViewModel, bool>(
                selector: (_, viewModel) => viewModel.isScanning,
                builder: (context, isScanning, _) {
                  return BarcodeScanner(onBarcodeScanned: _viewModel.scanBarcode, isLoading: isScanning);
                },
              ),
              const SizedBox(height: 24),
              Selector<AddCartViewModel, ExpeditionCartConsultationModel?>(
                selector: (_, viewModel) => viewModel.scannedCart,
                builder: (context, cart, _) {
                  if (cart == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CartDetailsWidget(cart: cart),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
              Selector<
                AddCartViewModel,
                ({
                  ExpeditionCartConsultationModel? cart,
                  bool isAdding,
                  bool isScanning,
                  bool isCountdownActive,
                  int countdownSeconds,
                })
              >(
                selector: (_, viewModel) => (
                  cart: viewModel.scannedCart,
                  isAdding: viewModel.isAdding,
                  isScanning: viewModel.isScanning,
                  isCountdownActive: viewModel.isCountdownActive,
                  countdownSeconds: viewModel.countdownSeconds,
                ),
                builder: (context, state, _) {
                  if (state.cart == null) {
                    return const SizedBox.shrink();
                  }

                  return CartActionsWidget(
                    viewModel: _viewModel,
                    onCancel: () {
                      _viewModel.cancelAutoAdd();
                      context.pop();
                    },
                    onAdd: () {
                      unawaited(
                        _onAddCart(_viewModel).catchError((Object e, StackTrace s) {
                          AppLogger.warning(
                            'Falha ao adicionar carrinho à separação',
                            tag: 'AddCartScreen',
                            error: e,
                            stackTrace: s,
                          );
                        }),
                      );
                    },
                    onNewQuery: () => _onNewQuery(_viewModel),
                  );
                },
              ),
              Selector<AddCartViewModel, String?>(
                selector: (_, viewModel) => viewModel.errorMessage,
                builder: (context, errorMessage, _) {
                  if (errorMessage == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
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
                            errorMessage,
                            style: AppFonts.inter(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onNewQuery(AddCartViewModel viewModel) {
    viewModel.clearScannedData();
  }

  Future<void> _onAddCart(AddCartViewModel viewModel) async {
    if (viewModel.isAdding) return;

    viewModel.cancelAutoAdd();
    await viewModel.addCartToSeparation();
  }
}
