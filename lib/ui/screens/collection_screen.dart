import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coleta'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping_outlined, size: 80, color: AppColors.indigo),
            SizedBox(height: 16),
            Text('Coleta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Funcionalidade em desenvolvimento', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            SizedBox(height: 16),
            Text(
              'Aqui será implementada a funcionalidade de processamento de coleta de produtos.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
