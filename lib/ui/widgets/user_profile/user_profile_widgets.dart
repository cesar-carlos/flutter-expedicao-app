import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/core/utils/avatar_utils.dart';
import 'package:data7_expedicao/ui/widgets/common/socket_widgets.dart';

/// Widget que exibe a foto do usuário logado
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

        return GestureDetector(
          onTap: onTap,
          child: AvatarUtils.buildAvatar(
            name: currentUser.nome,
            photoBase64: currentUser.fotoUsuario,
            radius: radius,
            backgroundColor: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        );
      },
    );
  }
}

/// AppBar customizado com informações do usuário
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
        // Indicador de WebSocket
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
                          Text(currentUser.nome, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            'ID: ${currentUser.codLoginApp}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade300),
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

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho com foto e informações
            Row(
              children: [
                UserProfileAvatar(radius: 30),
                const SizedBox(width: 16),
                if (currentUser != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          'ID: ${currentUser.codLoginApp}',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                        if (currentUser.codUsuario != null)
                          Text(
                            'Código: ${currentUser.codUsuario}',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        Row(
                          children: [
                            Icon(
                              currentUser.isActive ? Icons.check_circle : Icons.cancel,
                              color: currentUser.isActive ? Colors.green : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentUser.isActive ? 'Ativo' : 'Inativo',
                              style: TextStyle(fontSize: 12, color: currentUser.isActive ? Colors.green : Colors.red),
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
            // Opções do menu
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () {
                Navigator.of(context).pop();
                authViewModel.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
