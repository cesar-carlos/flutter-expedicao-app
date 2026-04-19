import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/data/datasources/user_preferences_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final UserPreferencesService _preferencesService;
  ThemeMode _themeMode = ThemeMode.light;

  /// Permite injetar o PlatformDispatcher (para testes). Em runtime
  /// usa `PlatformDispatcher.instance`.
  final PlatformDispatcher? _platformDispatcher;

  ThemeViewModel(this._preferencesService, {PlatformDispatcher? platformDispatcher})
      : _platformDispatcher = platformDispatcher;

  ThemeMode get themeMode => _themeMode;

  /// Retorna se a UI deve ser renderizada em modo escuro.
  ///
  /// Bug funcional anterior: `ThemeMode.system` retornava sempre `false`
  /// (mentindo quando o sistema estava em dark mode). Agora consulta o
  /// brightness atual do sistema via `PlatformDispatcher`.
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        final dispatcher = _platformDispatcher ?? PlatformDispatcher.instance;
        return dispatcher.platformBrightness == Brightness.dark;
    }
  }

  Future<void> initialize() async {
    await _preferencesService.initialize();
    final preferences = _preferencesService.getCurrentPreferences();
    _themeMode = preferences.themeMode;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final next = switch (_themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    await setThemeMode(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    final previous = _themeMode;
    _themeMode = mode;
    notifyListeners();

    // Bug latente anterior: se `updateThemeMode` lancar excecao
    // (Hive corrompido, disco cheio, etc), o tema da UI continuava
    // mudado mas a preferencia nunca era persistida — proxima
    // sessao revertia silenciosamente. Agora logamos e revertemos
    // o estado em memoria para manter consistencia.
    try {
      await _preferencesService.updateThemeMode(mode);
    } catch (e, s) {
      AppLogger.warning(
        'Falha ao persistir ThemeMode (revertendo para $previous)',
        tag: 'ThemeViewModel',
        error: e,
        stackTrace: s,
      );
      _themeMode = previous;
      notifyListeners();
      rethrow;
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
