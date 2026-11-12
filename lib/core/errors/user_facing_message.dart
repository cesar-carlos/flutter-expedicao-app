/// Texto que a tela pode mostrar: causa clara, sem stack e sem jargão interno.
class UserFacingMessage {
  static const String fallback = 'Não foi possível concluir a operação. Tente novamente.';

  static final RegExp _wrapperPrefix = RegExp(
    r'^(Exception|Error|StateError|FormatException|DataError|NetworkError|AppError|Erro inesperado):\s*',
    caseSensitive: false,
  );

  static String fromText(String? raw, {String fallback = UserFacingMessage.fallback}) {
    if (raw == null) {
      return fallback;
    }

    var text = raw.trim();
    if (text.isEmpty) {
      return fallback;
    }

    for (var i = 0; i < 4; i++) {
      final stripped = text.replaceFirst(_wrapperPrefix, '').trim();
      if (stripped == text) {
        break;
      }
      text = stripped;
    }

    final firstLine = text.split(RegExp(r'\r?\n')).first.trim();
    if (firstLine.isEmpty || firstLine.startsWith('Instance of ')) {
      return fallback;
    }
    if (_looksLikeStackFrame(firstLine)) {
      return fallback;
    }

    return _rewriteKnown(firstLine);
  }

  /// Prefere o detalhe específico quando ele existe; senão o fallback.
  static String prefer(String? specific, String fallback) {
    final trimmed = specific?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return fallback;
    }
    return fromText(trimmed, fallback: fallback);
  }

  static bool _looksLikeStackFrame(String line) {
    if (line.startsWith('#')) {
      return true;
    }
    return line.contains('package:') && line.contains('.dart');
  }

  static String _rewriteKnown(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('sql-conn') || lower.contains('falha de conexao com o banco')) {
      return 'O banco de dados do servidor está indisponível. Tente novamente em instantes.';
    }

    if (text.startsWith('[')) {
      return text;
    }

    if (lower.contains('socket') && lower.contains('session')) {
      return 'Sessão com o servidor não identificada. Reconecte e tente novamente.';
    }
    if (lower.contains('socket') && lower.contains('conect')) {
      return 'Conexão em tempo real indisponível. Verifique o indicador de conexão e tente novamente.';
    }
    if (lower.contains('perdida') && lower.contains('conex')) {
      return 'Conexão com o servidor foi perdida. Tente novamente.';
    }
    if (lower.contains('tempo limite') || lower.contains('timeout')) {
      return 'O servidor não respondeu a tempo. Tente novamente.';
    }
    return text;
  }
}
