import 'package:flutter/material.dart';

import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:exp/ui/widgets/card_picking/widgets/index.dart';

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

  /// Indica se o modo teclado está ativo (vs modo scanner)
  final bool keyboardEnabled;

  /// Callback para alternar entre modo scanner e teclado
  final VoidCallback onToggleKeyboard;

  /// Callback executado quando um código de barras é escaneado
  final void Function(String) onBarcodeScanned;

  /// Indica se os campos estão habilitados (carrinho em separação)
  final bool isEnabled;

  const PickingScreenLayout({
    super.key,
    required this.cart,
    required this.viewModel,
    required this.quantityController,
    required this.quantityFocusNode,
    required this.scanController,
    required this.scanFocusNode,
    required this.keyboardEnabled,
    required this.onToggleKeyboard,
    required this.onBarcodeScanned,
    required this.isEnabled,
  });

  /// Espaçamento vertical entre os cards
  static const double _cardSpacing = 6.0;

  /// Padding padrão da tela
  static const double _defaultPadding = 8.0;

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
    return QuantitySelectorCard(controller: quantityController, focusNode: quantityFocusNode, enabled: isEnabled);
  }

  /// Constrói o card do scanner de código de barras
  Widget _buildBarcodeScanner() {
    return BarcodeScannerCard(
      controller: scanController,
      focusNode: scanFocusNode,
      keyboardEnabled: keyboardEnabled,
      onToggleKeyboard: onToggleKeyboard,
      onSubmitted: onBarcodeScanned,
      enabled: isEnabled,
    );
  }
}
