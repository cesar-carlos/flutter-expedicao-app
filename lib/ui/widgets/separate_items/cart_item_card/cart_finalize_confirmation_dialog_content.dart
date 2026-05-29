import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CartFinalizeConfirmationDialogContent extends StatelessWidget {
  final int codCarrinho;
  final bool hasPending;
  final int pendingCount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const CartFinalizeConfirmationDialogContent({
    super.key,
    required this.codCarrinho,
    required this.hasPending,
    required this.pendingCount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Salvar Carrinho'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deseja realmente salvar o carrinho #$codCarrinho?'),
          if (hasPending) ...[
            const SizedBox(height: UIConstants.defaultPadding),
            Container(
              padding: const EdgeInsets.all(UIConstants.smallPadding),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.sync, color: AppColors.warning, size: UIConstants.defaultIconSize),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Há $pendingCount operação(ões) sincronizando. Aguarde concluir antes de salvar.',
                      style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.orange800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: hasPending ? null : onConfirm,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: Text('Salvar', style: AppFonts.inter(color: AppColors.white)),
        ),
      ],
    );
  }
}
