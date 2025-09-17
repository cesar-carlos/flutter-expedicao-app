/// Utilitários para manipulação de strings
class StringUtils {
  // Construtor privado para evitar instanciação
  StringUtils._();

  /// Capitaliza a primeira letra de cada palavra em uma string
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.capitalizeWords('joão da silva'); // retorna 'João Da Silva'
  /// StringUtils.capitalizeWords('MARIA SANTOS'); // retorna 'Maria Santos'
  /// ```
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  /// Remove espaços extras e normaliza uma string
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.normalize('  João   da   Silva  '); // retorna 'João da Silva'
  /// ```
  static String normalize(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Verifica se uma string está vazia ou contém apenas espaços
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.isBlank('   '); // retorna true
  /// StringUtils.isBlank('teste'); // retorna false
  /// ```
  static bool isBlank(String? text) {
    return text == null || text.trim().isEmpty;
  }

  /// Trunca uma string para um tamanho máximo, adicionando '...' se necessário
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.truncate('Este é um texto longo', 10); // retorna 'Este é um...'
  /// ```
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }

  /// Remove acentos de uma string
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.removeAccents('João Ação Coração'); // retorna 'Joao Acao Coracao'
  /// ```
  static String removeAccents(String text) {
    const withAccents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = text;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    return result;
  }
}
