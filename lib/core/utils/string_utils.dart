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

  /// Converte uma string com valores separados por vírgula em uma lista de inteiros
  ///
  /// Pode receber null ou uma string com valores separados por vírgula.
  /// Remove espaços em branco e valores inválidos.
  ///
  /// Exemplo:
  /// ```dart
  /// StringUtils.parseCommaSeparatedInts('1,2,4'); // retorna [1, 2, 4]
  /// StringUtils.parseCommaSeparatedInts('1, 2, 4'); // retorna [1, 2, 4]
  /// StringUtils.parseCommaSeparatedInts(null); // retorna []
  /// StringUtils.parseCommaSeparatedInts(''); // retorna []
  /// StringUtils.parseCommaSeparatedInts('1,abc,3'); // retorna [1, 3]
  /// ```
  static List<int> parseCommaSeparatedInts(dynamic value) {
    if (value == null) return [];

    if (value is String) {
      if (value.isEmpty) return [];

      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .where((e) => e != 0)
          .toList();
    }

    return [];
  }
}
