import 'package:flutter/material.dart';

import 'package:data7_expedicao/ui/widgets/home/home_menu_card.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.1,
      padding: const EdgeInsets.all(16),
      children: const [
        HomeMenuCard(
          title: 'Separação',
          description: 'Gerenciar separação de produtos e pedidos',
          icon: Icons.inventory_2_outlined,
          route: '/home/separation',
          iconColor: AppColors.info,
          cardColor: AppColors.info,
        ),
        HomeMenuCard(
          title: 'Conferência',
          description: 'Conferir produtos e validar separação',
          icon: Icons.checklist_outlined,
          route: '/home/conference',
          iconColor: AppColors.success,
          cardColor: AppColors.success,
        ),
        HomeMenuCard(
          title: 'Entrega Balcão',
          description: 'Gerenciar entregas no balcão',
          icon: Icons.storefront_outlined,
          route: '/home/counter-delivery',
          iconColor: AppColors.warning,
          cardColor: AppColors.warning,
        ),
        HomeMenuCard(
          title: 'Embalagem',
          description: 'Processar embalagem de produtos',
          icon: Icons.inventory_outlined,
          route: '/home/packaging',
          iconColor: AppColors.purple,
          cardColor: AppColors.purple,
        ),
        HomeMenuCard(
          title: 'Armazenagem',
          description: 'Gerenciar armazenamento de produtos',
          icon: Icons.warehouse_outlined,
          route: '/home/storage',
          iconColor: AppColors.teal,
          cardColor: AppColors.teal,
        ),
        HomeMenuCard(
          title: 'Coleta',
          description: 'Processar coleta de produtos',
          icon: Icons.local_shipping_outlined,
          route: '/home/collection',
          iconColor: AppColors.indigo,
          cardColor: AppColors.indigo,
        ),
      ],
    );
  }
}
