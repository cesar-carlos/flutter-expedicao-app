import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/ui/screens/splash_screen.dart';
import 'package:exp/ui/screens/login_screen.dart';
import 'package:exp/ui/screens/register_screen.dart';
import 'package:exp/ui/screens/scanner_screen.dart';
import 'package:exp/ui/screens/config_screen.dart';
import 'package:exp/ui/wrappers/user_selection_wrapper.dart';
import 'package:exp/ui/screens/home_screen.dart';
import 'package:exp/ui/screens/profile_screen.dart';
import 'package:exp/ui/screens/separate_consultation_screen.dart';
import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/domain/viewmodels/profile_viewmodel.dart';
import 'package:exp/domain/viewmodels/separate_consultation_viewmodel.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/di/locator.dart';

/// Configuração das rotas da aplicação usando GoRouter
class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String config = '/config';
  static const String home = '/home';
  static const String scanner = '/scanner';
  static const String userSelection = '/user-selection';
  static const String profile = '/profile';
  static const String shipmentSeparateConsultation =
      '/shipment-separate-consultation';

  /// Configuração do GoRouter
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,

      // Redirect baseado no estado de autenticação
      redirect: (BuildContext context, GoRouterState state) {
        final authStatus = authViewModel.status;
        final currentLocation = state.uri.path;

        // Se está no estado inicial ou loading, vai para splash
        if (authStatus == AuthStatus.initial ||
            authStatus == AuthStatus.loading) {
          if (currentLocation != splash) {
            return splash;
          }
          return null;
        }

        // Se não está autenticado, permite acesso ao login, registro e config
        if (authStatus == AuthStatus.unauthenticated ||
            authStatus == AuthStatus.error) {
          // Permite acesso ao login, registro e configuração
          if (currentLocation != login &&
              currentLocation != register &&
              currentLocation != config) {
            return login;
          }
          return null;
        }

        // Se precisa selecionar usuário, vai para tela de seleção
        if (authStatus == AuthStatus.needsUserSelection) {
          if (currentLocation != userSelection) {
            return userSelection;
          }
          return null;
        }

        // Se está autenticado, vai para home
        if (authStatus == AuthStatus.authenticated) {
          if (currentLocation == splash ||
              currentLocation == login ||
              currentLocation == register ||
              currentLocation == userSelection) {
            return home;
          }
          return null;
        }

        return null;
      },

      routes: [
        // Rota do Splash
        GoRoute(
          path: splash,
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Rota do Login
        GoRoute(
          path: login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        // Rota do Registro
        GoRoute(
          path: register,
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        // Rota de Configurações
        GoRoute(
          path: config,
          name: 'config',
          builder: (context, state) => const ConfigScreen(),
        ),

        // Rota de Seleção de Usuário
        GoRoute(
          path: userSelection,
          name: 'user-selection',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => locator<UserSelectionViewModel>(),
            child: const UserSelectionWrapper(),
          ),
        ),

        // Rota da Home (com subrotas)
        GoRoute(
          path: home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            // Scanner como subrota
            GoRoute(
              path: 'scanner',
              name: 'scanner',
              builder: (context, state) => const ScannerScreen(),
            ),
          ],
        ),

        // Rota do Perfil
        GoRoute(
          path: profile,
          name: 'profile',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => ProfileViewModel(
              locator<UserRepository>(),
              Provider.of<AuthViewModel>(context, listen: false),
            ),
            child: const ProfileScreen(),
          ),
        ),

        // Rota de Consultas de Separação
        GoRoute(
          path: shipmentSeparateConsultation,
          name: 'shipment-separate-consultation',
          builder: (context, state) => ChangeNotifierProvider(
            create: (_) => ShipmentSeparateConsultationViewModel(),
            child: const SeparateConsultationScreen(),
          ),
        ),
      ],

      // Página de erro
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Erro na navegação',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Rota não encontrada: ${state.uri.path}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(home),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
