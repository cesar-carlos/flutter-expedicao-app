import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';

import '../mocks/user_system_model_mock.dart';

class FakeUserSessionService implements IUserSessionService {
  FakeUserSessionService({AppUser? session, this.loggedOut = false}) : _session = session;

  final AppUser? _session;
  final bool loggedOut;

  @override
  Future<void> clearUserSession() async {}

  @override
  Future<bool> hasActiveSession() async => !loggedOut;

  @override
  Future<bool> isUserLoggedIn() async => !loggedOut;

  @override
  Future<AppUser?> loadUserSession() async => loggedOut ? null : (_session ?? defaultLoggedInAppUser());

  @override
  Future<void> saveUserSession(AppUser appUser) async {}

  @override
  Future<void> updateUserSession(AppUser appUser) async {}

  static AppUser defaultLoggedInAppUser() {
    final user = createDefaultTestUserSystem();
    return AppUser(
      codLoginApp: 1,
      ativo: Situation.ativo,
      nome: user.nomeUsuario,
      codUsuario: user.codUsuario,
      userSystemModel: user,
    );
  }
}
