import 'package:flutter/material.dart';

import 'package:data7_expedicao/ui/widgets/home/home_menu_card.dart';

/// Grid de menu principal para a tela inicial
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
          iconColor: Colors.blue,
          cardColor: Colors.blue,
        ),
        HomeMenuCard(
          title: 'Conferência',
          description: 'Conferir produtos e validar separação',
          icon: Icons.checklist_outlined,
          route: '/home/conference',
          iconColor: Colors.green,
          cardColor: Colors.green,
        ),
        HomeMenuCard(
          title: 'Entrega Balcão',
          description: 'Gerenciar entregas no balcão',
          icon: Icons.storefront_outlined,
          route: '/home/counter-delivery',
          iconColor: Colors.orange,
          cardColor: Colors.orange,
        ),
        HomeMenuCard(
          title: 'Embalagem',
          description: 'Processar embalagem de produtos',
          icon: Icons.inventory_outlined,
          route: '/home/packaging',
          iconColor: Colors.purple,
          cardColor: Colors.purple,
        ),
        HomeMenuCard(
          title: 'Armazenagem',
          description: 'Gerenciar armazenamento de produtos',
          icon: Icons.warehouse_outlined,
          route: '/home/storage',
          iconColor: Colors.teal,
          cardColor: Colors.teal,
        ),
        HomeMenuCard(
          title: 'Coleta',
          description: 'Processar coleta de produtos',
          icon: Icons.local_shipping_outlined,
          route: '/home/collection',
          iconColor: Colors.indigo,
          cardColor: Colors.indigo,
        ),
      ],
    );
  }
}
