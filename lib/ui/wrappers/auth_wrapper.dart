import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/ui/screens/splash_screen.dart';
import 'package:exp/ui/screens/login_screen.dart';
import 'package:exp/ui/screens/scanner_screen.dart';
import 'package:exp/ui/widgets/common/index.dart';
import 'user_selection_wrapper.dart';
import 'package:exp/di/locator.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        switch (authViewModel.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const SplashScreen();

          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();

          case AuthStatus.needsUserSelection:
            return ChangeNotifierProvider(
              create: (_) => locator<UserSelectionViewModel>(),
              child: const UserSelectionWrapper(),
            );

          case AuthStatus.authenticated:
            return const HomeScreen();
        }
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withUserInfo(
        title: 'Data7 Expedição',
        replaceWithUserName: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    const Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: const ScannerScreen(),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthViewModel>().logout();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
