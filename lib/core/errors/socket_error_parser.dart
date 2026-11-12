/// Extrai o envelope de erro Socket.IO (`Error` + `Code`) no formato
/// `[identificador] mensagem`.
class SocketErrorInfo {
  const SocketErrorInfo({required this.message, this.identifier, this.contractCode});

  /// Primeira linha de `Error`, já no formato `[id] texto` quando o servidor
  /// classifica a falha.
  final String message;

  /// Prefixo entre colchetes: `50014`, `SQL-CONN`, `INVALID_PAYLOAD`, …
  final String? identifier;

  /// Campo `Code` do envelope: `BUSINESS_RULE_VIOLATION`, `NOT_FOUND`, …
  final String? contractCode;

  static final RegExp _identifierPattern = RegExp(
    r'^\[(500\d{2}|SQL-[A-Z0-9]+|INVALID_[A-Z0-9_]+|INTERNAL_ERROR|UNAUTHORIZED|NOT_FOUND|BUSINESS_RULE_VIOLATION)\]\s*',
    caseSensitive: false,
  );

  static SocketErrorInfo? fromResponse(Map<String, dynamic> response) {
    final lines = linesOf(response['Error']);
    if (lines.isEmpty) {
      return null;
    }

    final first = lines.first;
    final contractCode = _readContractCode(response['Code']);
    return SocketErrorInfo(message: first, identifier: identifierOf(first), contractCode: contractCode);
  }

  static List<String> linesOf(Object? error) {
    if (error == null) {
      return const [];
    }
    if (error is String) {
      final trimmed = error.trim();
      return trimmed.isEmpty ? const [] : <String>[trimmed];
    }
    if (error is List) {
      return error
          .map((item) => item?.toString().trim() ?? '')
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
    }
    final fallback = error.toString().trim();
    return fallback.isEmpty ? const [] : <String>[fallback];
  }

  static String? identifierOf(String message) {
    final match = _identifierPattern.firstMatch(message.trim());
    return match?.group(1)?.toUpperCase();
  }

  static String? _readContractCode(Object? code) {
    if (code is String && code.trim().isNotEmpty) {
      return code.trim().toUpperCase();
    }
    return null;
  }

  bool get isBusinessRule {
    if (contractCode == 'BUSINESS_RULE_VIOLATION') {
      return true;
    }
    final id = identifier;
    if (id == null) {
      return false;
    }
    if (id == 'BUSINESS_RULE_VIOLATION') {
      return true;
    }
    final number = int.tryParse(id);
    return number != null && number >= 50011 && number <= 50099;
  }

  bool get isInvalidPayload => identifier == 'INVALID_PAYLOAD' || contractCode == 'INVALID_PAYLOAD';

  bool get isUnauthorized => identifier == 'UNAUTHORIZED' || contractCode == 'UNAUTHORIZED';

  bool get isNotFound => identifier == 'NOT_FOUND' || contractCode == 'NOT_FOUND';

  bool get isSqlUnavailable => identifier == 'SQL-CONN';

  bool get isInternalError => identifier == 'INTERNAL_ERROR' || contractCode == 'INTERNAL_ERROR';

  bool get isConnection {
    if (identifier == 'SQL-CONN') {
      return true;
    }
    final lower = message.toLowerCase();
    return lower.contains('socket') ||
        lower.contains('tempo limite') ||
        lower.contains('timeout') ||
        lower.contains('conex') ||
        lower.contains('rede');
  }
}
