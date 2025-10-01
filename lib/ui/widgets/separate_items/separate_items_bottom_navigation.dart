import 'package:flutter/material.dart';

import 'package:exp/core/theme/app_colors.dart';

class SeparateItemsBottomNavigation extends StatelessWidget {
  final TabController tabController;

  const SeparateItemsBottomNavigation({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(color: AppColors.withOpacity(colorScheme.shadow, 0.1), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: colorScheme.primaryContainer),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: colorScheme.onPrimaryContainer,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 10),
            unselectedLabelStyle: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 10),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: [
              _buildTab(icon: Icons.shopping_cart, label: 'Carrinhos', colorScheme: colorScheme),
              _buildTab(icon: Icons.inventory_2, label: 'Produtos', colorScheme: colorScheme),
              _buildTab(icon: Icons.info_outline, label: 'Informações', colorScheme: colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({required IconData icon, required String label, required ColorScheme colorScheme}) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
