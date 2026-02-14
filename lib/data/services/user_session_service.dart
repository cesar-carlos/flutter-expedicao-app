import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';

class UserSessionService implements IUserSessionService {
  static const String _appUserKey = 'current_app_user';
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<void> saveUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));

      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppUser?> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_appUserKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final appUser = AppUser.fromJson(userMap);
        return appUser;
      }
    } catch (e) {
      if (e.toString().contains('bool') && e.toString().contains('String')) {
        await clearUserSession();
      }
    }
    return null;
  }

  @override
  Future<void> updateUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final hasSession = await hasActiveSession();
      if (!hasSession) return false;

      final appUser = await loadUserSession();
      return appUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([prefs.remove(_appUserKey), prefs.remove(_isLoggedInKey)]);
    } catch (e) {
      rethrow;
    }
  }
}
