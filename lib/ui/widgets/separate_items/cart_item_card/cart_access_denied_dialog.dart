import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CartAccessDeniedDialog extends StatelessWidget {
  final String actionLabel;
  final String cartOwnerName;
  final VoidCallback onClose;

  const CartAccessDeniedDialog({
    super.key,
    required this.actionLabel,
    required this.cartOwnerName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.block, color: AppColors.error),
          const SizedBox(width: 8),
          const Expanded(child: Text('Acesso Negado', overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '❌ Você não pode $actionLabel neste carrinho',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.red700),
                ),
                const SizedBox(height: 8),
                Text('Carrinho incluído por: $cartOwnerName', style: AppFonts.inter(color: AppColors.red600)),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.defaultPadding),
          const Text('Este carrinho foi incluído por outro usuário.'),
          const SizedBox(height: 8),
          Text(
            'Apenas o usuário que incluiu o carrinho pode realizar esta ação.',
            style: AppFonts.inter(fontSize: UIConstants.smallFontSize),
          ),
        ],
      ),
      actions: [TextButton(onPressed: onClose, child: const Text('Fechar'))],
    );
  }
}
