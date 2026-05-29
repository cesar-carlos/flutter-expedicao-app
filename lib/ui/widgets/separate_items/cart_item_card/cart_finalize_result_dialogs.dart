import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_failure.dart';
import 'package:data7_expedicao/domain/usecases/save_separation_cart/save_separation_cart_success.dart';

class CartFinalizeSuccessDialog extends StatelessWidget {
  final int codCarrinho;
  final SaveSeparationCartSuccess success;
  final VoidCallback onOk;

  const CartFinalizeSuccessDialog({super.key, required this.codCarrinho, required this.success, required this.onOk});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 8),
          const Text('Sucesso'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Carrinho #$codCarrinho finalizado com sucesso!'),
          if (success.details != null) ...[
            const SizedBox(height: 8),
            Text(
              success.details!,
              style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.grey),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
          child: Text('OK', style: AppFonts.inter(color: AppColors.white)),
        ),
      ],
    );
  }
}

class CartFinalizeErrorDialog extends StatelessWidget {
  final AppFailure failure;
  final VoidCallback onOk;

  const CartFinalizeErrorDialog({super.key, required this.failure, required this.onOk});

  @override
  Widget build(BuildContext context) {
    final failure = this.failure;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error, color: AppColors.error),
          const SizedBox(width: 8),
          const Text('Erro'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(failure.userMessage),
          if (failure is SaveSeparationCartFailure && failure.details != null) ...[
            const SizedBox(height: 8),
            Text(
              failure.details!,
              style: AppFonts.inter(fontSize: UIConstants.smallFontSize, color: AppColors.grey),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: onOk,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          child: Text('OK', style: AppFonts.inter(color: AppColors.white)),
        ),
      ],
    );
  }
}
