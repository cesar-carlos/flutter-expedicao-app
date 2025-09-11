/// Helper para conversões de data
class DateHelper {
  /// Converte string para DateTime, lança exceção se falhar
  static DateTime tryStringToDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      throw FormatException('Data não pode ser nula ou vazia');
    }

    try {
      // Tenta formatos ISO 8601 primeiro
      return DateTime.parse(dateString);
    } catch (e) {
      // Tenta outros formatos comuns
      try {
        // Formato brasileiro dd/MM/yyyy
        if (dateString.contains('/')) {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            return DateTime(year, month, day);
          }
        }

        // Formato yyyy-MM-dd
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

  /// Converte string para DateTime, retorna null se falhar
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

  /// Converte DateTime para string no formato brasileiro
  static String dateToString(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Converte DateTime para string ISO 8601
  static String dateToIsoString(DateTime date) {
    return date.toIso8601String();
  }

  /// Verifica se uma string é uma data válida
  static bool isValidDateString(String? dateString) {
    return tryStringToDateOrNull(dateString) != null;
  }
}
