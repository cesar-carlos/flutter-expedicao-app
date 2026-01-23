import 'package:date_format/date_format.dart';

class AppHelper {
  static double stringToDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        final cleanValue = value.replaceAll(',', '.').replaceAll(' ', '').replaceAll(RegExp(r'[^\d.-]'), '');

        return double.parse(cleanValue);
      } catch (e) {
        return 0.0;
      }
    }

    return 0.0;
  }

  static int stringToInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
        return int.parse(cleanValue);
      } catch (e) {
        return 0;
      }
    }

    return 0;
  }

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

  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static bool isNotNullOrEmpty(String? value) {
    return !isNullOrEmpty(value);
  }

  static String nullToEmpty(String? value) {
    return value ?? '';
  }

  static String nullToDefault(String? value, String defaultValue) {
    return isNullOrEmpty(value) ? defaultValue : value!;
  }

  static String formatNumber(double value, {int decimals = 2}) {
    return value.toStringAsFixed(decimals);
  }

  static String formatNumberWithSeparator(double value, {int decimals = 2}) {
    final parts = value.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]}.',
    );

    return decimalPart.isNotEmpty ? '$formattedInteger,$decimalPart' : formattedInteger;
  }

  static DateTime? stringToDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
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

  static double qtdDisplayToDouble(String value) {
    return double.parse(value.replaceAll('.', '').replaceAll(',', '.'));
  }

  static bool isBarCode(String value) {
    if (value.trim().length > 6) return true;
    if (!AppHelper.isNumeric(value.trim())) return true;
    return false;
  }

  static String formatarData(DateTime? value) {
    if (value == null) return '';
    return formatDate(value, [dd, '/', mm, '/', yyyy]);
  }

  static String formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }

  static String formatTimeShort(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static bool isNumeric(String value) {
    final numericRegex = RegExp(r'^[0-9]+$');
    return numericRegex.hasMatch(value);
  }

  static DateTime? tryStringToDateOrNull(String? value) {
    try {
      if (value == null) return null;
      if (value == '') return null;

      return DateTime.parse(value);
    } catch (err) {
      return null;
    }
  }
}
