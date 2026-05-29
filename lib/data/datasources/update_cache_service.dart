import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/domain/services/i_update_cache_service.dart';

/// Serviço para gerenciar cache de verificações de atualização do app.
///
/// Evita verificações frequentes à API do GitHub, economizando recursos
/// e melhorando a experiência do usuário.
class UpdateCacheService implements IUpdateCacheService {
  /// Chave usada para armazenar o timestamp da última verificação.
  static const String _lastCheckKey = 'last_update_check_timestamp';

  /// Duração padrão de validade do cache (1 hora).
  static const Duration _defaultCacheValidDuration = Duration(hours: 1);

  final SharedPreferences _prefs;
  final Duration cacheValidDuration;

  /// Cria uma nova instância de [UpdateCacheService].
  ///
  /// [_prefs] é a instância de SharedPreferences usada para armazenar o cache.
  /// [cacheValidDuration] é a duração de validade do cache (padrão: 1 hora).
  UpdateCacheService({required SharedPreferences prefs, this.cacheValidDuration = _defaultCacheValidDuration})
    : _prefs = prefs;

  /// Verifica se deve verificar por atualizações.
  ///
  /// Retorna `true` se o cache expirou ou se nunca houve uma verificação anterior.
  /// Retorna `false` se ainda houver cache válido.
  @override
  bool shouldCheckForUpdates() {
    final lastCheckTimestamp = _prefs.getInt(_lastCheckKey);

    if (lastCheckTimestamp == null) {
      return true; // Nunca verificou antes
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastCheckTimestamp;

    return elapsed >= cacheValidDuration.inMilliseconds;
  }

  /// Marca a verificação de atualização como realizada.
  ///
  /// Armazena o timestamp atual no cache.
  /// Deve ser chamado após uma verificação bem-sucedida.
  @override
  Future<void> markAsChecked() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs.setInt(_lastCheckKey, now);
  }

  /// Limpa o cache de verificação de atualização.
  ///
  /// Força uma nova verificação na próxima chamada de [shouldCheckForUpdates].
  Future<void> clearCache() async {
    await _prefs.remove(_lastCheckKey);
  }

  /// Obtém o timestamp da última verificação em milissegundos desde a época Unix.
  ///
  /// Retorna `null` se nunca houve uma verificação anterior.
  int? getLastCheckTimestamp() {
    return _prefs.getInt(_lastCheckKey);
  }

  /// Obtém a data/hora da última verificação.
  ///
  /// Retorna `null` se nunca houve uma verificação anterior.
  DateTime? getLastCheckDate() {
    final timestamp = getLastCheckTimestamp();
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Verifica se o cache está expirado.
  ///
  /// Retorna `true` se o cache expirou ou se nunca houve verificação.
  bool isCacheExpired() {
    return shouldCheckForUpdates();
  }

  /// Obtém o tempo restante até o cache expirar.
  ///
  /// Retorna [Duration.zero] se o cache já estiver expirado.
  Duration getRemainingTime() {
    final lastCheck = getLastCheckTimestamp();
    if (lastCheck == null) return Duration.zero;

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - lastCheck;
    final remaining = cacheValidDuration.inMilliseconds - elapsed;

    return remaining > 0 ? Duration(milliseconds: remaining) : Duration.zero;
  }
}
