import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';

class UserSessionService {
  static const String _appUserKey = 'current_app_user';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Salva os dados completos da sessão do usuário
  Future<void> saveUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva o AppUser (que já inclui UserSystemModel)
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));

      // Marca como logado
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      // Erro ao salvar sessão do usuário
      rethrow;
    }
  }

  /// Carrega o AppUser salvo (que inclui UserSystemModel)
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
      // Erro ao carregar sessão do usuário
      // Se há erro de deserialização (dados antigos), limpar sessão
      if (e.toString().contains('bool') && e.toString().contains('String')) {
        // Detectado formato antigo de dados, limpando sessão
        await clearUserSession();
      }
    }
    return null;
  }

  /// Atualiza os dados do usuário
  Future<void> updateUserSession(AppUser appUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appUserKey, jsonEncode(appUser.toJson()));
    } catch (e) {
      // Erro ao atualizar sessão do usuário
      rethrow;
    }
  }

  /// Verifica se há uma sessão ativa salva
  Future<bool> hasActiveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      // Erro ao verificar sessão ativa
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
      // Erro ao verificar se usuário está logado
      return false;
    }
  }

  /// Limpa todos os dados da sessão (logout)
  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([prefs.remove(_appUserKey), prefs.remove(_isLoggedInKey)]);
    } catch (e) {
      // Erro ao limpar sessão do usuário
      rethrow;
    }
  }
}
