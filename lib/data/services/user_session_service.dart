import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exp/domain/models/user/app_user.dart';

class UserSessionService {
  static const String _appUserKey = 'current_app_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Salva os dados completos da sessão do usuário
  Future<void> saveUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva o AppUser (que já inclui UserSystemData)
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));

      // Marca como logado
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      print('Erro ao salvar sessão do usuário: $e');
      rethrow;
    }
  }

  /// Carrega o AppUser salvo (que inclui UserSystemData)
  Future<AppUser?> loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_appUserKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return AppUser.fromJson(userMap);
      }
    } catch (e) {
      print('Erro ao carregar sessão do usuário: $e');
    }
    return null;
  }

  /// Atualiza os dados do usuário
  Future<void> updateUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));
    } catch (e) {
      print('Erro ao atualizar sessão do usuário: $e');
      rethrow;
    }
  }

  /// Verifica se há uma sessão ativa salva
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Erro ao verificar sessão ativa: $e');
      return false;
    }
  }

  /// Verifica se o usuário está logado e tem dados válidos
  Future<bool> isUserLoggedIn() async {
    try {
      final hasSession = await hasActiveSession();
      if (!hasSession) return false;

      final appUser = await loadUserSession();
      return appUser != null;
    } catch (e) {
      print('Erro ao verificar se usuário está logado: $e');
      return false;
    }
  }

  /// Limpa todos os dados da sessão (logout)
  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_appUserKey),
        prefs.remove(_isLoggedInKey),
      ]);
    } catch (e) {
      print('Erro ao limpar sessão do usuário: $e');
      rethrow;
    }
  }
}
