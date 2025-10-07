import 'package:flutter/foundation.dart';

/// Sistema de logging centralizado para a aplicação
/// 
/// Substitui o uso de print() por um sistema mais robusto e configurável
class AppLogger {
  static const String _tagPrefix = '[EXP]';
  
  /// Log de debug - apenas em modo debug
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr $message');
    }
  }
  
  /// Log de informação - sempre exibido
  static void info(String message, {String? tag}) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_tagPrefix$tagStr ℹ️ $message');
  }
  
  /// Log de aviso - sempre exibido
  static void warning(String message, {String? tag}) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_tagPrefix$tagStr ⚠️ $message');
  }
  
  /// Log de erro - sempre exibido
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_tagPrefix$tagStr ❌ $message');
    
    if (error != null) {
      debugPrint('$_tagPrefix$tagStr 💥 Erro: $error');
    }
    
    if (stackTrace != null && kDebugMode) {
      debugPrint('$_tagPrefix$tagStr 📍 Stack: $stackTrace');
    }
  }
  
  /// Log de sucesso - sempre exibido
  static void success(String message, {String? tag}) {
    final tagStr = tag != null ? '[$tag]' : '';
    debugPrint('$_tagPrefix$tagStr ✅ $message');
  }
  
  /// Log de progresso - apenas em modo debug
  static void progress(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr 📊 $message');
    }
  }
  
  /// Log de operação - apenas em modo debug
  static void operation(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr 🔄 $message');
    }
  }
  
  /// Log de inicialização - apenas em modo debug
  static void init(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr 🚀 $message');
    }
  }
  
  /// Log de conexão - apenas em modo debug
  static void connection(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr 🔗 $message');
    }
  }
  
  /// Log de dados - apenas em modo debug
  static void data(String message, {String? tag}) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag]' : '';
      debugPrint('$_tagPrefix$tagStr 📦 $message');
    }
  }
}
