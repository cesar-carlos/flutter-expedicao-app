import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/core/metrics/websocket_metrics.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class MetricsStorage {
  static const String _websocketMetricsKey = 'websocket_metrics';

  Future<void> saveMetrics(WebSocketMetrics metrics) async {
    final prefs = await SharedPreferences.getInstance();
    final json = metrics.toJson();
    await prefs.setString(_websocketMetricsKey, jsonEncode(json));
  }

  Future<WebSocketMetrics?> loadMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_websocketMetricsKey);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        // Bug TTTTTTTTTT: tipo invalido em vez de Map era cast silencioso
        // que retornava null. Agora logamos E limpamos a chave corrompida
        // (mesmo padrao do FiltersStorageService) para evitar falha
        // recorrente em todas as proximas cargas.
        await _recoverFromCorruption(
          prefs,
          'Esperado Map<String, dynamic>, recebido ${decoded.runtimeType}',
        );
        return null;
      }
      return WebSocketMetrics.fromJson(decoded);
    } catch (e, s) {
      // Bug UUUUUUUUUU: antes catch era silencioso (`catch (_) { return null; }`).
      // Agora logamos a corrupcao E removemos a chave para prevenir
      // erro recorrente ad infinitum em todas as cargas subsequentes.
      AppLogger.warning('Metrics corrompidos — limpando chave', tag: 'MetricsStorage', error: e, stackTrace: s);
      await _recoverFromCorruption(prefs, e.toString());
      return null;
    }
  }

  Future<void> _recoverFromCorruption(SharedPreferences prefs, String reason) async {
    try {
      await prefs.remove(_websocketMetricsKey);
    } catch (e, s) {
      AppLogger.error(
        'Falha tambem ao remover chave corrompida de metrics ($reason)',
        tag: 'MetricsStorage',
        error: e,
        stackTrace: s,
      );
    }
  }

  Future<void> clearMetrics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_websocketMetricsKey);
  }

  Future<Map<String, dynamic>> exportMetrics() async {
    final m = await loadMetrics();
    if (m == null) return <String, dynamic>{};
    return m.toJson();
  }
}
