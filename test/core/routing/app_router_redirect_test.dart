import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';

void main() {
  group('AppRouter.resolveRedirect', () {
    test('deve redirecionar para login ao acessar rota autenticada sem login', () {
      final redirect = AppRouter.resolveRedirect(
        authStatus: AuthStatus.unauthenticated,
        currentLocation: AppRouter.home,
      );

      expect(redirect, AppRouter.login);
    });

    test('deve permitir tela de configuração do servidor sem login', () {
      final redirect = AppRouter.resolveRedirect(
        authStatus: AuthStatus.unauthenticated,
        currentLocation: AppRouter.config,
      );

      expect(redirect, isNull);
    });

    test('deve redirecionar splash para home quando autenticado', () {
      final redirect = AppRouter.resolveRedirect(
        authStatus: AuthStatus.authenticated,
        currentLocation: AppRouter.splash,
      );

      expect(redirect, AppRouter.home);
    });

    test('deve manter em user-selection quando status exige seleção', () {
      final redirect = AppRouter.resolveRedirect(
        authStatus: AuthStatus.needsUserSelection,
        currentLocation: AppRouter.userSelection,
      );

      expect(redirect, isNull);
    });
  });
}
