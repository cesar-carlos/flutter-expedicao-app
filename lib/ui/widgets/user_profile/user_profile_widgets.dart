import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/presentation/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/core/utils/avatar_utils.dart';
import 'package:data7_expedicao/ui/widgets/common/socket_widgets.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class UserProfileAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const UserProfileAvatar({super.key, this.radius = 20, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final currentUser = authViewModel.currentUser;

        if (currentUser == null) {
          return GestureDetector(
            onTap: onTap,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, color: Colors.grey.shade600, size: radius),
            ),
          );
        }

        final colorScheme = Theme.of(context).colorScheme;

        return GestureDetector(
          onTap: onTap,
          child: AvatarUtils.buildAvatar(
            name: currentUser.nome,
            photoBase64: currentUser.fotoUsuario,
            radius: radius,
            backgroundColor: colorScheme.primaryContainer,
            textColor: colorScheme.onPrimaryContainer,
          ),
        );
      },
    );
  }
}

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showUserInfo;

  const UserAppBar({super.key, required this.title, this.actions, this.showUserInfo = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        Center(child: SocketStatusIndicator(showLabel: false, size: 8, padding: EdgeInsets.only(right: 8))),
        if (showUserInfo) ...[
          Consumer<AuthViewModel>(
            builder: (context, authViewModel, child) {
              final currentUser = authViewModel.currentUser;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentUser != null) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(currentUser.nome, style: AppFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            'ID: ${currentUser.codLoginApp}',
                            style: AppFonts.inter(fontSize: 12, color: Colors.grey.shade300),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    UserProfileAvatar(radius: 18, onTap: () => _showUserMenu(context)),
                  ],
                ),
              );
            },
          ),
        ],
        if (actions != null) ...actions!,
      ],
    );
  }

  void _showUserMenu(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (modalContext) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  UserProfileAvatar(radius: 30),
                  const SizedBox(width: 16),
                  if (currentUser != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(currentUser.nome, style: AppFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            'ID: ${currentUser.codLoginApp}',
                            style: AppFonts.inter(
                              fontSize: 14,
                              color: Theme.of(modalContext).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (currentUser.codUsuario != null)
                            Text(
                              'Código: ${currentUser.codUsuario}',
                              style: AppFonts.inter(
                                fontSize: 14,
                                color: Theme.of(modalContext).colorScheme.onSurfaceVariant,
                              ),
                            ),
                        Row(
                          children: [
                            Icon(
                              currentUser.isActive ? Icons.check_circle : Icons.cancel,
                              color: currentUser.isActive ? AppColors.success : AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentUser.isActive ? 'Ativo' : 'Inativo',
                              style: AppFonts.inter(
                                fontSize: 12,
                                color: currentUser.isActive ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(modalContext).pop();
                unawaited(
                  authViewModel.logout().catchError((Object e, StackTrace s) {
                    AppLogger.warning(
                      'Falha ao executar logout (menu utilizador)',
                      tag: 'UserAppBar',
                      error: e,
                      stackTrace: s,
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir menu de utilizador',
        tag: 'UserAppBar',
        error: e,
        stackTrace: s,
      );
    }),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
