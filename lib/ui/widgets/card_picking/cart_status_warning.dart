import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CartStatusWarning extends StatelessWidget {
  const CartStatusWarning({super.key});

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

  Widget _buildWarningContainer(BuildContext context) {
    return Container(
      margin: _containerMargin,
      padding: _containerPadding,
      decoration: _buildWarningDecoration(),
      child: _buildWarningContent(),
    );
  }

  BoxDecoration _buildWarningDecoration() {
    return BoxDecoration(
      color: AppColors.red50,
      border: Border.all(color: AppColors.red300),
      borderRadius: BorderRadius.circular(_borderRadius),
    );
  }

  Widget _buildWarningContent() {
    return Row(
      children: [
        _buildWarningIcon(),
        Expanded(child: _buildWarningText()),
      ],
    );
  }

  Widget _buildWarningIcon() {
    return Padding(
      padding: _iconSpacing,
      child: Icon(Icons.warning_amber_rounded, color: AppColors.red600, size: _iconSize),
    );
  }

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

  Widget _buildWarningTitle() {
    return Text(
      'Carrinho não está em separação',
      style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.red800, fontSize: _titleFontSize),
    );
  }

  Widget _buildWarningDescription() {
    return Text(
      'Este carrinho não está mais em situação de separação. '
      'Não é possível adicionar ou remover itens.',
      style: AppFonts.inter(color: AppColors.red700, fontSize: _descriptionFontSize),
    );
  }
}
