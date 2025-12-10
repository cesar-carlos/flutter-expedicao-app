import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:data7_expedicao/core/utils/string_utils.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/app_drawer/drawer_menu_tile.dart';
import 'package:data7_expedicao/core/utils/avatar_utils.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/constants/app_strings.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.watch<AuthViewModel>();
    final themeViewModel = context.watch<ThemeViewModel>();

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.8)],
              ),
            ),
            child: DrawerHeader(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () => themeViewModel.toggleTheme(),
                      icon: Icon(themeViewModel.themeIcon, color: theme.colorScheme.onPrimary),
                      tooltip: themeViewModel.themeTooltip,
                    ),
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                          border: Border.all(color: theme.colorScheme.onPrimary, width: 2),
                        ),
                        child: AvatarUtils.buildAvatar(
                          name: authViewModel.username.isNotEmpty ? authViewModel.username : 'Usuário',
                          photoBase64: authViewModel.currentUser?.fotoUsuario,
                          backgroundColor: Colors.transparent,
                          textColor: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          radius: 30,
                        ),
                      ),
                      const SizedBox(height: 9),

                      Text(
                        authViewModel.username.isNotEmpty
                            ? StringUtils.capitalizeWords(authViewModel.username)
                            : 'Usuário',
                        style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerMenuTile(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.home);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.person_outline,
                  title: 'Meu Perfil',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.profile);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.qr_code_scanner,
                  title: 'Scanner',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('${AppRouter.home}/scanner');
                  },
                ),

                const Divider(),

                DrawerMenuTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'Separação',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.separation);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.checklist_outlined,
                  title: 'Conferência',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.conference);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.storefront_outlined,
                  title: 'Entrega Balcão',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.counterDelivery);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.inventory_outlined,
                  title: 'Embalagem',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.packaging);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.warehouse_outlined,
                  title: 'Armazenagem',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.storage);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Coleta',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.collection);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.qr_code_2_outlined,
                  title: AppStrings.scannerConfigMenu,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.scannerConfig);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Configurações',
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.config);
                  },
                  showNotification: true,
                ),

                Consumer<SocketViewModel>(
                  builder: (context, socketViewModel, child) {
                    return DrawerMenuTile(
                      iconColor: Color(socketViewModel.connectionStateColor),
                      textColor: Color(socketViewModel.connectionStateColor),
                      icon: socketViewModel.isConnected ? Icons.wifi : Icons.wifi_off,
                      title: socketViewModel.isConnected ? 'Conectado' : 'Desconectado',
                      onTap: () {
                        if (socketViewModel.isConnected) {
                          socketViewModel.disconnect();
                        } else {
                          socketViewModel.connect();
                        }
                      },
                    );
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.logout,
                  title: 'Sair',
                  onTap: () => _showLogoutDialog(context),
                  iconColor: theme.colorScheme.error,
                  textColor: theme.colorScheme.error,
                ),
              ],
            ),
          ),
          _buildVersionInfo(context, theme),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(BuildContext context, ThemeData theme) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final packageInfo = snapshot.data!;
        final version = packageInfo.version;
        final buildNumber = packageInfo.buildNumber;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.12), width: 1)),
          ),
          child: Text(
            'Versão $version+$buildNumber',
            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              context.read<AuthViewModel>().logout();
            },
            child: Text('Sair', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
