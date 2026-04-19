import 'dart:async';

import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/user_preferences.dart';

class UserPreferencesService {
  static const String _boxName = 'user_preferences';
  static const String _preferencesKey = 'current_preferences';

  Box<UserPreferences>? _box;

  /// Bug EEEEE: guard anti-race contra inicializacoes concorrentes.
  /// Sem isso, 2 chamadas paralelas de initialize() podiam tentar
  /// abrir o mesmo Box duas vezes → exception ou state corrompido.
  Completer<void>? _initCompleter;

  Future<void> initialize() async {
    if (_box != null) return;
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    final completer = Completer<void>();
    _initCompleter = completer;

    try {
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserPreferencesAdapter());
      }

      _box = await Hive.openBox<UserPreferences>(_boxName);
      completer.complete();
    } catch (e, s) {
      completer.completeError(e, s);
      _initCompleter = null;
      rethrow;
    }
  }

  UserPreferences getCurrentPreferences() {
    if (_box == null) {
      // Bug DDDDD: trocado de Exception generico para StateError
      // (consistente com ConfigService e mais semanticamente correto
      // para "violacao de pre-condicao da API").
      throw StateError('UserPreferencesService nao foi inicializado. Chame initialize() primeiro.');
    }

    return _box!.get(_preferencesKey) ?? UserPreferences.defaultPreferences;
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    if (_box == null) {
      throw StateError('UserPreferencesService nao foi inicializado. Chame initialize() primeiro.');
    }

    preferences.lastUpdated = DateTime.now();
    await _box!.put(_preferencesKey, preferences);
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final currentPrefs = getCurrentPreferences();
    currentPrefs.themeMode = themeMode;
    await savePreferences(currentPrefs);
  }

  Future<void> clearPreferences() async {
    if (_box == null) {
      throw StateError('UserPreferencesService nao foi inicializado. Chame initialize() primeiro.');
    }

    await _box!.clear();
  }

  Future<void> dispose() async {
    // Bug FFFFF: antes era apenas `await _box?.close()` sem catch.
    // Se o close falhar (Hive corrompido em runtime), a exception
    // propagava sem log e impedia futura inicializacao porque _box
    // continuava != null. Agora logamos e zeramos o estado para
    // permitir reinicializacao.
    try {
      await _box?.close();
    } catch (e, s) {
      AppLogger.warning(
        'Erro ao fechar box de preferencias do usuario',
        tag: 'UserPreferencesService',
        error: e,
        stackTrace: s,
      );
    } finally {
      _box = null;
      _initCompleter = null;
    }
  }
}
