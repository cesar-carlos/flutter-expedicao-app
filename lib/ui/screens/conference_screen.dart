import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class ConferenceScreen extends StatelessWidget {
  const ConferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conferência'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(AppRouter.home)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 80, color: AppColors.success),
            SizedBox(height: 16),
            Text('Conferência', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Funcionalidade em desenvolvimento', style: TextStyle(fontSize: 16, color: AppColors.grey)),
            SizedBox(height: 16),
            Text(
              'Aqui será implementada a funcionalidade de conferência de produtos e validação de separação.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
