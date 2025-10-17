import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';

/// Widget que exibe um aviso quando o carrinho não está em situação de separação
class CartStatusWarning extends StatelessWidget {
  const CartStatusWarning({super.key});

  // === CONSTANTES ===
  static const _containerMargin = EdgeInsets.all(16);
  static const _containerPadding = EdgeInsets.all(16);
  static const _iconSpacing = EdgeInsets.only(right: 12);
  static const _textSpacing = EdgeInsets.only(top: 4);

  static const double _borderRadius = 8.0;
  static const double _iconSize = 24.0;
  static const double _titleFontSize = 16.0;
  static const double _descriptionFontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<CardPickingViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isCartInSeparationStatus) {
          return const SizedBox.shrink();
        }

        return _buildWarningContainer(context);
      },
    );
  }

  /// Constrói o container de aviso
  Widget _buildWarningContainer(BuildContext context) {
    return Container(
      margin: _containerMargin,
      padding: _containerPadding,
      decoration: _buildWarningDecoration(),
      child: _buildWarningContent(),
    );
  }

  /// Constrói a decoração do container de aviso
  BoxDecoration _buildWarningDecoration() {
    return BoxDecoration(
      color: Colors.red.shade50,
      border: Border.all(color: Colors.red.shade300),
      borderRadius: BorderRadius.circular(_borderRadius),
    );
  }

  /// Constrói o conteúdo do aviso
  Widget _buildWarningContent() {
    return Row(
      children: [
        _buildWarningIcon(),
        Expanded(child: _buildWarningText()),
      ],
    );
  }

  /// Constrói o ícone de aviso
  Widget _buildWarningIcon() {
    return Padding(
      padding: _iconSpacing,
      child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: _iconSize),
    );
  }

  /// Constrói o texto do aviso
  Widget _buildWarningText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWarningTitle(),
        Padding(padding: _textSpacing, child: _buildWarningDescription()),
      ],
    );
  }

  /// Constrói o título do aviso
  Widget _buildWarningTitle() {
    return Text(
      'Carrinho não está em separação',
      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade800, fontSize: _titleFontSize),
    );
  }

  /// Constrói a descrição do aviso
  Widget _buildWarningDescription() {
    return Text(
      'Este carrinho não está mais em situação de separação. '
      'Não é possível adicionar ou remover itens.',
      style: TextStyle(color: Colors.red.shade700, fontSize: _descriptionFontSize),
    );
  }
}
