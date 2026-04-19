import 'package:data7_expedicao/core/utils/date_helper.dart';

/// Helpers compartilhados para parsing defensivo de JSON em models.
///
/// Centraliza padroes que apareciam duplicados em ~40 fromJson:
/// * `_parseInt(value)` aceita int, num, String parsavel; retorna null
///   se nada disso (ou se value e null).
/// * `_parseString(value, fallback)` retorna `value.toString()` ou fallback
///   se null.
/// * `_parseDateTime(value, fallback)` para DateTime com fallback seguro.
/// * `_parseDouble(value)` mesmo padrao defensivo para double.
///
/// Esses helpers eliminam crashes com TypeError quando o servidor retorna
/// tipos inesperados (string em vez de int, null em vez de string, etc) —
/// problema comum em APIs antigas com serializacao inconsistente.
class JsonParse {
  JsonParse._();

  /// Parse defensivo de int. Aceita int direto, num (converte com toInt),
  /// ou String parsavel via int.tryParse. Retorna null se nada disso.
  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Parse defensivo de int com fallback (uso em campos non-nullable).
  static int parseIntOr(dynamic value, int fallback) {
    return parseInt(value) ?? fallback;
  }

  /// Parse defensivo de double. Aceita double direto, num (toDouble), ou
  /// String parsavel.
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Parse defensivo de double com fallback.
  static double parseDoubleOr(dynamic value, double fallback) {
    return parseDouble(value) ?? fallback;
  }

  /// Parse defensivo de String. Retorna `value.toString()` ou fallback.
  /// Util para campos non-nullable que servidor pode retornar null.
  static String parseStringOr(dynamic value, String fallback) {
    if (value == null) return fallback;
    return value.toString();
  }

  /// Parse defensivo de String? (mantem null se ausente).
  static String? parseStringOrNull(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  /// Parse defensivo de bool. Aceita bool direto, ou string 'true'/'false'/'S'/'N'.
  static bool? parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().toLowerCase().trim();
    if (s == 'true' || s == '1' || s == 's' || s == 'sim' || s == 'y' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'n' || s == 'nao' || s == 'no') return false;
    return null;
  }

  /// Parse defensivo de bool com fallback.
  static bool parseBoolOr(dynamic value, bool fallback) {
    return parseBool(value) ?? fallback;
  }

  /// Parse defensivo de DateTime via [DateHelper.tryStringToDateOrNull].
  /// Aceita ISO 8601 ou formatos brasileiros (dd/MM/yyyy).
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateHelper.tryStringToDateOrNull(value.toString());
  }

  /// Parse defensivo de DateTime com fallback.
  /// Util para campos non-nullable que servidor pode retornar null/invalido.
  static DateTime parseDateTimeOr(dynamic value, DateTime fallback) {
    return parseDateTime(value) ?? fallback;
  }
}
