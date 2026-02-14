import 'package:data7_expedicao/domain/models/user/app_user.dart';

abstract class IUserSessionService {
  Future<void> saveUserSession(AppUser appUser);
  Future<AppUser?> loadUserSession();
  Future<void> updateUserSession(AppUser appUser);
  Future<bool> hasActiveSession();
  Future<bool> isUserLoggedIn();
  Future<void> clearUserSession();
}
