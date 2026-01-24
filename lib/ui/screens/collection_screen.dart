import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';
import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: 'Coleta',
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 80, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text('Coleta', style: AppFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Funcionalidade em desenvolvimento',
              style: AppFonts.inter(
                fontSize: 16,
                color: theme.isDark ? AppColors.light : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aqui será implementada a funcionalidade de processamento de coleta de produtos.',
              textAlign: TextAlign.center,
              style: AppFonts.inter(
                fontSize: 14,
                color: theme.isDark ? AppColors.light : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
