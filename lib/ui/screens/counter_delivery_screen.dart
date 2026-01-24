import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CounterDeliveryScreen extends StatelessWidget {
  const CounterDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega Balcão'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_outlined, size: 80, color: AppColors.warning),
            SizedBox(height: 16),
            Text('Entrega Balcão', style: AppFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Funcionalidade em desenvolvimento', style: AppFonts.inter(fontSize: 16, color: AppColors.grey)),
            SizedBox(height: 16),
            Text(
              'Aqui será implementada a funcionalidade de gerenciamento de entregas no balcão.',
              textAlign: TextAlign.center,
              style: AppFonts.inter(fontSize: 14, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
