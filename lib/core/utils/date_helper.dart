class DateHelper {
  static DateTime tryStringToDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      throw FormatException('Data não pode ser nula ou vazia');
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        if (dateString.contains('/')) {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }

        if (dateString.contains('-')) {
          final parts = dateString.split('-');
          if (parts.length == 3) {
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final day = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }

        throw FormatException('Formato de data inválido: $dateString');
      } catch (e) {
        throw FormatException('Erro ao converter data: $dateString - $e');
      }
    }
  }

  static DateTime? tryStringToDateOrNull(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return tryStringToDate(dateString);
    } catch (e) {
      return null;
    }
  }

  static String dateToString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static String dateToIsoString(DateTime date) {
    return date.toIso8601String();
  }

  static bool isValidDateString(String? dateString) {
    return tryStringToDateOrNull(dateString) != null;
  }
}
