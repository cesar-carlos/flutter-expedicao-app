import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CartNoItemsForSectorDialog extends StatelessWidget {
  final int userSectorCode;
  final VoidCallback onClose;

  const CartNoItemsForSectorDialog({super.key, required this.userSectorCode, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 8),
          const Expanded(child: Text('Sem Itens para Separar', overflow: TextOverflow.ellipsis)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(UIConstants.smallPadding),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Todos os itens do seu setor já foram separados!',
                  style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.blue700),
                ),
                const SizedBox(height: 8),
                Text('Seu setor: Setor $userSectorCode', style: AppFonts.inter(color: AppColors.blue600)),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.defaultPadding),
          const Text('Não há mais produtos do seu setor neste carrinho para separar.'),
          const SizedBox(height: 8),
          Text(
            'Os itens restantes pertencem a outros setores e serão separados por outros usuários.',
            style: AppFonts.inter(fontSize: UIConstants.smallFontSize),
          ),
        ],
      ),
      actions: [TextButton(onPressed: onClose, child: const Text('Fechar'))],
    );
  }
}
