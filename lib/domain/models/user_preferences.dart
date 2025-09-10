import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'user_preferences.g.dart';

@HiveType(typeId: 1)
class UserPreferences extends HiveObject {
  @HiveField(0)
  int themeModeIndex;

  @HiveField(1)
  DateTime? lastUpdated;

  UserPreferences({required this.themeModeIndex, this.lastUpdated});

  ThemeMode get themeMode => ThemeMode.values[themeModeIndex];

  set themeMode(ThemeMode mode) {
    themeModeIndex = mode.index;
    lastUpdated = DateTime.now();
  }

  static UserPreferences get defaultPreferences => UserPreferences(
    themeModeIndex: ThemeMode.light.index,
    lastUpdated: DateTime.now(),
  );

  UserPreferences copyWith({int? themeModeIndex, DateTime? lastUpdated}) {
    return UserPreferences(
      themeModeIndex: themeModeIndex ?? this.themeModeIndex,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserPreferences(themeMode: ${themeMode.name}, lastUpdated: $lastUpdated)';
  }
}
