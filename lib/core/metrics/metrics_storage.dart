import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:data7_expedicao/core/metrics/websocket_metrics.dart';

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
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WebSocketMetrics.fromJson(map);
    } catch (_) {
      return null;
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
