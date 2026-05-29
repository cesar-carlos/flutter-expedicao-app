import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_text_styles.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';

class CartItemCardCodeSituation extends StatelessWidget {
  final ExpeditionCartRouteInternshipConsultationModel cart;
  final Color situationColor;

  const CartItemCardCodeSituation({super.key, required this.cart, required this.situationColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final barcodeLabelColor = theme.adaptivePrimary(colorScheme);
    final barcodeValueColor = theme.adaptiveSecondary(colorScheme);

    final originLabelColor = theme.isDark
        ? (situationColor == AppColors.warning ? AppColors.orange700 : AppColors.light)
        : situationColor;
    final originValueColor = theme.isDark
        ? (situationColor == AppColors.warning ? AppColors.orange700 : AppColors.secondary)
        : situationColor;

    return Container(
      padding: const EdgeInsets.all(UIConstants.smallPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: situationColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          if (cart.codigoBarrasCarrinho.isNotEmpty) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.qr_code_2, size: UIConstants.defaultIconSize, color: barcodeLabelColor),
                      const SizedBox(width: 6),
                      Text(
                        'Código de Barras',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: barcodeLabelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                    ),
                    child: Text(
                      cart.codigoBarrasCarrinho,
                      style: AppTextStyles.code(
                        context,
                        color: barcodeValueColor,
                      ).copyWith(fontWeight: FontWeight.w600, fontSize: theme.textTheme.bodySmall?.fontSize),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.source, size: UIConstants.defaultIconSize, color: originLabelColor),
                    const SizedBox(width: 6),
                    Text(
                      'Origem',
                      style: theme.textTheme.labelSmall?.copyWith(color: originLabelColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: situationColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UIConstants.smallBorderRadius),
                  ),
                  child: Text(
                    '${cart.origem.description} #${cart.codOrigem}',
                    style: theme.textTheme.bodySmall?.copyWith(color: originValueColor, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
