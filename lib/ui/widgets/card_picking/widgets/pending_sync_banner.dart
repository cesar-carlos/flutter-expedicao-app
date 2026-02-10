import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

/// Banner que mostra operações de sincronização pendentes
///
/// Aparece quando há itens aguardando sincronização com o servidor,
/// prevenindo que o usuário finalize o carrinho com dados não salvos.
class PendingSyncBanner extends StatelessWidget {
  const PendingSyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<CardPickingViewModel, int>(
      selector: (_, vm) {
        // Contar operações pendentes em todos os itens
        int pendingCount = 0;
        for (final item in vm.items) {
          final itemState = vm.pickingState.getItemState(item.item);
          if (itemState?.hasPendingSync == true) {
            pendingCount += itemState!.pendingOperations.length;
          }
        }
        return pendingCount;
      },
      builder: (context, pendingCount, _) {
        if (pendingCount == 0) {
          return const SizedBox.shrink();
        }

        return RepaintBoundary(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              border: Border(bottom: BorderSide(color: AppColors.warning.withValues(alpha: 0.5), width: 2)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sincronizando $pendingCount operação${pendingCount == 1 ? '' : 'es'}...',
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Aguarde antes de finalizar a separação',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColors.warning.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.cloud_upload, color: AppColors.warning, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
