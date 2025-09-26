import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/models/user/app_user.dart';
import 'user_system_model_mock.dart';

/// Mock do UserSessionService para testes
class MockUserSessionService extends UserSessionService {
  @override
  Future<AppUser?> loadUserSession() async {
    final testUserSystem = createDefaultTestUserSystem();
    return AppUser(
      codLoginApp: 12345,
      ativo: testUserSystem.ativo,
      nome: testUserSystem.nomeUsuario,
      codUsuario: testUserSystem.codUsuario,
      userSystemModel: testUserSystem,
    );
  }

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    // Mock implementation
  }

  @override
  Future<void> clearUserSession() async {
    // Mock implementation
  }

  @override
  Future<bool> hasActiveSession() async {
    return true;
  }

  @override
  Future<bool> isUserLoggedIn() async {
    return true;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    // Mock implementation
  }
}
