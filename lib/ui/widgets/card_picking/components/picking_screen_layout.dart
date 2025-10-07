import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/ui/widgets/card_picking/widgets/index.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/ui/widgets/card_picking/widgets/barcode_scanner_card_optimized.dart';
import 'package:exp/ui/widgets/card_picking/components/picking_scan_state.dart';
import 'package:exp/core/constants/ui_constants.dart';

/// Layout principal da tela de picking com otimizações de performance
///
/// Responsável por organizar os cards de picking em uma estrutura scrollável,
/// utilizando [RepaintBoundary] para otimizar a performance.
class PickingScreenLayout extends StatelessWidget {
  /// Carrinho em processo de separação
  final ExpeditionCartRouteInternshipConsultationModel cart;

  /// ViewModel com a lógica de negócio do picking
  final CardPickingViewModel viewModel;

  /// Controller para o campo de quantidade
  final TextEditingController quantityController;

  /// FocusNode para o campo de quantidade
  final FocusNode quantityFocusNode;

  /// Controller para o campo de scanner
  final TextEditingController scanController;

  /// FocusNode para o campo de scanner
  final FocusNode scanFocusNode;

  /// Callback para alternar entre modo scanner e teclado
  final VoidCallback onToggleKeyboard;

  /// Callback executado quando um código de barras é escaneado
  final void Function(String) onBarcodeScanned;

  const PickingScreenLayout({
    super.key,
    required this.cart,
    required this.viewModel,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.scanController,
    required this.scanFocusNode,
    required this.onToggleKeyboard,
    required this.onBarcodeScanned,
  });

  /// Espaçamento vertical entre os cards
  static const double _cardSpacing = UIConstants.smallPadding;

  /// Padding padrão da tela
  static const double _defaultPadding = UIConstants.smallPadding;

  /// Padding extra quando o teclado está aberto
  static const double _keyboardPadding = 60.0;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = bottomInset > 0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _defaultPadding,
        _defaultPadding,
        _defaultPadding,
        _defaultPadding + (hasKeyboard ? _keyboardPadding : 0),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNextItemCard(),
            const SizedBox(height: _cardSpacing),
            _buildQuantitySelector(),
            const SizedBox(height: _cardSpacing),
            _buildBarcodeScanner(),
          ],
        ),
      ),
    );
  }

  /// Constrói o card do próximo item com RepaintBoundary para otimização
  Widget _buildNextItemCard() {
    return RepaintBoundary(child: NextItemCard(viewModel: viewModel));
  }

  /// Constrói o card de seleção de quantidade
  Widget _buildQuantitySelector() {
    return Selector<PickingScanState, bool>(
      selector: (_, s) => s.enabled,
      builder: (context, isEnabled, __) {
        return QuantitySelectorCard(
          controller: quantityController,
          focusNode: quantityFocusNode,
          enabled: isEnabled,
          viewModel: viewModel,
        );
      },
    );
  }

  /// Constrói o card do scanner de código de barras com Provider otimizado
  ///
  /// Este componente usa Consumer granular para atualizar APENAS o scanner
  /// quando necessário, evitando rebuilds de toda a tela.
  Widget _buildBarcodeScanner() {
    return RepaintBoundary(
      child: BarcodeScannerCardOptimized(
        controller: scanController,
        focusNode: scanFocusNode,
        onToggleKeyboard: onToggleKeyboard,
        onSubmitted: onBarcodeScanned,
      ),
    );
  }
}
