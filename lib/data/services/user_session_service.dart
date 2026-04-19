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
      // Bug PP: paraleliza para reduzir janela de inconsistencia (se o
      // app crashar entre os dois sets, ficavamos com appUserKey
      // gravado mas isLoggedInKey nao — proxima isUserLoggedIn falhava).
      // SharedPreferences nao oferece transacao atomica, mas Future.wait
      // dispara as duas escritas em paralelo, minimizando o gap.
      await Future.wait([
        prefs.setString(_appUserKey, jsonEncode(appUser.toJson())),
        prefs.setBool(_isLoggedInKey, true),
      ]);
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
    } on TypeError catch (_) {
      // Bug NN: substitui string-match `e.toString().contains('bool')...`
      // por captura tipada. TypeError eh lancado quando shape do JSON
      // mudou entre versoes do app (ex.: campo era bool, virou String).
      // Sessao corrompida = limpar e voltar para login.
      await clearUserSession();
    } on FormatException catch (_) {
      // JSON invalido (ex.: gravacao parcial, corrupcao) → mesma acao.
      await clearUserSession();
    } catch (_) {
      // Outros erros: mantem o comportamento legado (silencia e retorna null).
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
