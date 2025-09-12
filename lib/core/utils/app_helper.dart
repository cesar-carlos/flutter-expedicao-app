import 'package:date_format/date_format.dart';

/// Utilitário geral da aplicação
class AppHelper {
  /// Converte string para double de forma segura
  static double stringToDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        // Remove formatação se houver (vírgulas, pontos, espaços)
        final cleanValue = value
            .replaceAll(',', '.')
            .replaceAll(' ', '')
            .replaceAll(RegExp(r'[^\d.-]'), '');

        return double.parse(cleanValue);
      } catch (e) {
        return 0.0;
      }
    }

    return 0.0;
  }

  /// Converte string para int de forma segura
  static int stringToInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        // Remove formatação se houver
        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
        return int.parse(cleanValue);
      } catch (e) {
        return 0;
      }
    }

    return 0;
  }

  /// Converte string para bool de forma segura
  static bool stringToBool(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == 'true' ||
          lowerValue == '1' ||
          lowerValue == 's' ||
          lowerValue == 'sim' ||
          lowerValue == 'y' ||
          lowerValue == 'yes';
    }
    if (value is int) return value != 0;
    if (value is double) return value != 0.0;

    return false;
  }

  /// Verifica se uma string é nula ou vazia
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Verifica se uma string não é nula nem vazia
  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  /// Retorna string vazia se nula
  static String nullToEmpty(String? value) {
    return value ?? '';
  }

  /// Retorna string padrão se nula ou vazia
  static String nullToDefault(String? value, String defaultValue) {
    return isNullOrEmpty(value) ? defaultValue : value!;
  }

  /// Formata número com casas decimais
  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  /// Formata número com separador de milhares
  static String formatNumberWithSeparator(double value, {int decimals = 2}) {
    final parts = value.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Adiciona separador de milhares
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );

    return decimalPart.isNotEmpty
        ? '$formattedInteger,$decimalPart'
        : formattedInteger;
  }

  /// Converte string para DateTime de forma segura
  static DateTime? stringToDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        // Tenta formatos brasileiros
        try {
          if (value.contains('/')) {
            final parts = value.split('/');
            if (parts.length == 3) {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              return DateTime(year, month, day);
            }
          }
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }

  /// Converte string para DateTime ou retorna DateTime.now() se falhar
  static DateTime stringToDateTimeOrDefault(dynamic value) {
    return stringToDateTime(value) ?? DateTime.now();
  }

  static DateTime tryStringToDate(String? value) {
    try {
      if (value == null) return DateTime(1900);
      if (value == '') return DateTime(1900);

      return DateTime.parse(value);
    } catch (err) {
      return DateTime(1900);
    }
  }

  static qtdDisplayToDouble(String value) {
    return double.parse(value.replaceAll('.', '').replaceAll(',', '.'));
  }

  static isBarCode(String value) {
    if (value.trim().length > 6) return true;
    if (!AppHelper.isNumeric(value.trim())) return true;

    return false;
  }

  static String formatarData(DateTime? value) {
    if (value == null) return '';
    return formatDate(value, [dd, '/', mm, '/', yyyy]);
  }

  static bool isNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }
}
