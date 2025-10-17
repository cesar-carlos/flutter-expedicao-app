import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/user_preferences.dart';

class UserPreferencesService {
  static const String _boxName = 'user_preferences';
  static const String _preferencesKey = 'current_preferences';

  Box<UserPreferences>? _box;

  /// Inicializa o serviço de preferências
  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }

    _box = await Hive.openBox<UserPreferences>(_boxName);
  }

  /// Obtém as preferências atuais ou as padrão se não existirem
  UserPreferences getCurrentPreferences() {
    if (_box == null) {
      throw Exception('UserPreferencesService not initialized');
    }

    return _box!.get(_preferencesKey) ?? UserPreferences.defaultPreferences;
  }

  /// Salva as preferências do usuário
  Future<void> savePreferences(UserPreferences preferences) async {
    if (_box == null) {
      throw Exception('UserPreferencesService not initialized');
    }

    preferences.lastUpdated = DateTime.now();
    await _box!.put(_preferencesKey, preferences);
  }

  /// Atualiza apenas o tema
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final currentPrefs = getCurrentPreferences();
    currentPrefs.themeMode = themeMode;
    await savePreferences(currentPrefs);
  }

  /// Limpa todas as preferências
  Future<void> clearPreferences() async {
    if (_box == null) {
      throw Exception('UserPreferencesService not initialized');
    }

    await _box!.clear();
  }

  /// Fecha o box do Hive
  Future<void> dispose() async {
    await _box?.close();
  }
}
