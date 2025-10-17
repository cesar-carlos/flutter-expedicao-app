import 'package:flutter/material.dart';

import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final UserPreferencesService _preferencesService;
  ThemeMode _themeMode = ThemeMode.light;

  ThemeViewModel(this._preferencesService);

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return false;
    }
  }

  /// Inicializa o tema carregando das preferências salvas
  Future<void> initialize() async {
    await _preferencesService.initialize();
    final preferences = _preferencesService.getCurrentPreferences();
    _themeMode = preferences.themeMode;
    notifyListeners();
  }

  /// Alterna entre os modos de tema e salva a preferência
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
        break;
    }

    // Salva a preferência no Hive
    await _preferencesService.updateThemeMode(_themeMode);
    notifyListeners();
  }

  /// Define um modo de tema específico e salva
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _preferencesService.updateThemeMode(_themeMode);
      notifyListeners();
    }
  }

  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String get themeTooltip {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Modo Claro';
      case ThemeMode.dark:
        return 'Modo Escuro';
      case ThemeMode.system:
        return 'Tema do Sistema';
    }
  }
}
