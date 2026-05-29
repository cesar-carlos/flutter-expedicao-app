import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/core/utils/avatar_utils.dart';
import 'package:data7_expedicao/core/utils/string_utils.dart';
import 'package:data7_expedicao/presentation/viewmodels/app_update_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/socket_viewmodel.dart';
import 'package:data7_expedicao/presentation/viewmodels/theme_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/app_drawer/drawer_menu_tile.dart';
import 'package:data7_expedicao/ui/widgets/app_update_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Item 8: removido o context.watch no topo do build. Antes, qualquer
    // notifyListeners de AuthViewModel/ThemeViewModel reconstruía o Drawer
    // inteiro (incluindo a lista de menus estável). Agora apenas o header
    // (nome/foto) e o botão de tema observam seus ViewModels via Selector.
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
                    child: Selector<ThemeViewModel, (IconData, String)>(
                      selector: (_, vm) => (vm.themeIcon, vm.themeTooltip),
                      builder: (context, themeData, child) {
                        return IconButton(
                          // Bug latente anterior: `toggleTheme()` retorna Future
                          // e na rodada de auditoria do tema (commit d80709c)
                          // foi alterado para `rethrow` em caso de falha de
                          // persistencia. Sem catch aqui, isso virava
                          // "Unhandled Exception" no IconButton onPressed.
                          // Agora capturamos via `unawaited` + catchError com
                          // log — o usuario nao precisa ser notificado de
                          // erro de persistencia de preferencia (UI ja foi
                          // revertida pelo ViewModel).
                          onPressed: () {
                            unawaited(
                              context.read<ThemeViewModel>().toggleTheme().catchError((Object e, StackTrace s) {
                                AppLogger.warning(
                                  'Falha ao alternar tema (estado revertido)',
                                  tag: 'AppDrawer',
                                  error: e,
                                  stackTrace: s,
                                );
                              }),
                            );
                          },
                          icon: Icon(themeData.$1, color: theme.colorScheme.onPrimary),
                          tooltip: themeData.$2,
                        );
                      },
                    ),
                  ),

                  Selector<AuthViewModel, (String, String?)>(
                    selector: (_, vm) => (vm.username, vm.currentUser?.fotoUsuario),
                    builder: (context, userData, child) {
                      final username = userData.$1;
                      final photoBase64 = userData.$2;
                      return Column(
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
                              name: username.isNotEmpty ? username : 'Usuário',
                              photoBase64: photoBase64,
                              backgroundColor: AppColors.transparent,
                              textColor: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: UIConstants.hugeFontSize,
                              radius: 30,
                            ),
                          ),
                          const SizedBox(height: 9),

                          Text(
                            username.isNotEmpty ? StringUtils.capitalizeWords(username) : 'Usuário',
                            style: AppFonts.inter(
                              color: theme.colorScheme.onPrimary,
                              fontSize: UIConstants.mediumFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
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
                  title: context.l10n.scannerConfigMenu,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.scannerConfig);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.print_outlined,
                  title: context.l10n.printerConfigTitle,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRouter.printerConfig);
                  },
                ),

                DrawerMenuTile(
                  icon: Icons.settings_outlined,
                  title: context.l10n.serverConfigTitle,
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
                        // Bug JJJJJJJJJ: connect() retorna Future. Antes era
                        // fire-and-forget sem catch — qualquer erro virava
                        // uncaught exception silenciosa em release. Agora
                        // logamos o erro pelo proprio SocketViewModel/Service
                        // (ja tem AppLogger) e ignoramos o future via unawaited.
                        if (socketViewModel.isConnected) {
                          socketViewModel.disconnect();
                        } else {
                          socketViewModel.connect().catchError((Object _) {
                            // Erro ja logado em SocketViewModel.connect.
                          });
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

        return Consumer<AppUpdateViewModel>(
          builder: (context, appUpdateViewModel, child) {
            return GestureDetector(
              key: const Key('app_drawer_version'),
              onTap: appUpdateViewModel.isChecking ? null : () => _handleVersionTap(context, appUpdateViewModel),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.12), width: 1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!appUpdateViewModel.isChecking)
                      Icon(
                        Icons.system_update_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    if (!appUpdateViewModel.isChecking) const SizedBox(width: 8),
                    Text(
                      'Versão $version+$buildNumber',
                      style: AppFonts.inter(
                        fontSize: UIConstants.smallFontSize,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (appUpdateViewModel.isChecking) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleVersionTap(BuildContext context, AppUpdateViewModel appUpdateViewModel) async {
    if (appUpdateViewModel.isChecking) return;

    appUpdateViewModel.clearError();

    final scaffoldState = Scaffold.of(context);
    final scaffoldContext = scaffoldState.context;

    final owner = dotenv.env['GITHUB_OWNER']?.trim();
    final repo = dotenv.env['GITHUB_REPO']?.trim();

    if (owner == null || owner.isEmpty || repo == null || repo.isEmpty) {
      if (scaffoldContext.mounted) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: const Text('GITHUB_OWNER ou GITHUB_REPO não configurados'),
            backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Bug latente anterior: `checkForUpdate(...)` retorna Future
    // mas era chamado sem await/unawaited/catch. Erros nao
    // tratados viravam "Unhandled Future error" silencioso. O
    // ViewModel ja loga internamente, entao usamos unawaited
    // + catchError defensivo para satisfazer o lint
    // `discarded_futures`.
    unawaited(
      appUpdateViewModel.checkForUpdate(owner: owner, repo: repo, forceCheck: true).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao verificar atualizacao (sera tratado pelo viewmodel)',
          tag: 'AppDrawer',
          error: e,
          stackTrace: s,
        );
      }),
    );

    await Future.delayed(const Duration(milliseconds: 500));

    if (!scaffoldContext.mounted) return;

    // Bug IIIIIIIII: busy loop sem timeout. Antes:
    //   while (appUpdateViewModel.isChecking && scaffoldContext.mounted) {
    //     await Future.delayed(const Duration(milliseconds: 200));
    //   }
    // Se isChecking ficar true para sempre (bug em checkForUpdate, race,
    // erro nao tratado no ViewModel), o loop nunca terminava ate o widget
    // ser desmontado — desperdicio de bateria + bloqueava feedback ao usuario.
    //
    // Adicionado timeout de 30s. Se exceder, assumimos que algo travou e
    // saimos com snackbar de erro em vez de loop infinito.
    final pollDeadline = DateTime.now().add(const Duration(seconds: 30));
    while (appUpdateViewModel.isChecking && scaffoldContext.mounted) {
      if (DateTime.now().isAfter(pollDeadline)) {
        if (scaffoldContext.mounted) {
          ScaffoldMessenger.of(scaffoldContext).showSnackBar(
            const SnackBar(
              content: Text('Verificação de atualização demorou muito. Tente novamente mais tarde.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (!scaffoldContext.mounted) return;

    if (appUpdateViewModel.hasUpdate && appUpdateViewModel.updateAvailable != null) {
      await showDialog<void>(
        context: scaffoldContext,
        barrierDismissible: false,
        builder: (_) => AppUpdateDialog(release: appUpdateViewModel.updateAvailable!),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de atualização (drawer)',
          tag: 'AppDrawer',
          error: e,
          stackTrace: s,
        );
      });
    } else if (appUpdateViewModel.error != null) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(appUpdateViewModel.error!.message),
          backgroundColor: Theme.of(scaffoldContext).colorScheme.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Você está usando a versão mais recente'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Confirmar Saída'),
          content: const Text('Deseja realmente sair do aplicativo?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(dialogContext).pop();
                // Bug latente anterior: `logout()` retorna Future. Sem
                // await/catch, qualquer erro durante o logout (ex.: falha
                // de I/O ao limpar sessao) virava "Unhandled Future error".
                // Logamos via AppLogger e seguimos — o usuario ja foi
                // navegado para fora do drawer e o estado de auth ficou
                // limpo na memoria.
                unawaited(
                  dialogContext.read<AuthViewModel>().logout().catchError((Object e, StackTrace s) {
                    AppLogger.warning(
                      'Falha ao executar logout',
                      tag: 'AppDrawer',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
              },
              child: Text('Sair', style: AppFonts.inter(color: Theme.of(dialogContext).colorScheme.error)),
            ),
          ],
        ),
      ).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir dialog de logout (drawer)',
          tag: 'AppDrawer',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }
}
