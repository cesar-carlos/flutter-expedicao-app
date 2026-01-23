import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/user_preferences.dart';

class UserPreferencesService {
  static const String _boxName = 'user_preferences';
  static const String _preferencesKey = 'current_preferences';

  Box<UserPreferences>? _box;

  Future<void> initialize() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserPreferencesAdapter());
    }

    _box = await Hive.openBox<UserPreferences>(_boxName);
  }

  UserPreferences getCurrentPreferences() {
    if (_box == null) {
      throw Exception('UserPreferencesService not initialized');
    }

    return _box!.get(_preferencesKey) ?? UserPreferences.defaultPreferences;
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    if (_box == null) {
      throw Exception('UserPreferencesService not initialized');
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
      throw Exception('UserPreferencesService not initialized');
    }

    await _box!.clear();
  }

  Future<void> dispose() async {
    await _box?.close();
  }
}
