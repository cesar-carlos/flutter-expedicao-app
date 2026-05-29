import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/models/user_preferences.dart';

/// Contrato para acesso as preferencias do usuario.
///
/// Vive em `core` (e nao em `domain`) porque expoe `ThemeMode`, um tipo
/// do Flutter. Isso desacopla a camada de apresentacao da implementacao
/// concreta em `data/` sem poluir o dominio puro com dependencia de
/// framework. Expoe apenas as operacoes consumidas pela apresentacao.
abstract interface class IUserPreferencesRepository {
  Future<void> initialize();

  UserPreferences getCurrentPreferences();

  Future<void> updateThemeMode(ThemeMode themeMode);
}
