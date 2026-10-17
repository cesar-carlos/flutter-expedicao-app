import 'package:zard/zard.dart';

/// Schemas comuns reutilizáveis para validação de dados
class CommonSchemas {
  CommonSchemas._();

  // === SCHEMAS BÁSICOS ===

  /// Schema para IDs numéricos
  static final integerSchema = z.int().min(1, message: 'integerSchema deve ser maior que zero');

  /// Schema para IDs opcionais (aceita null e ausência)
  static final optionalIntegerSchema = z.int().nullable();

  /// Schema para códigos numéricos
  static final codeSchema = z
      .string()
      .min(1, message: 'Código é obrigatório')
      .refine((value) => int.tryParse(value.trim()) != null, message: 'Código deve ser numérico')
      .transform((value) => value.trim());

  static final optionalCodeSchema = z
      .string()
      .refine((value) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) return true;
        return int.tryParse(trimmed) != null;
      }, message: 'Código deve ser numérico')
      .transform((value) {
        final trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      })
      .optional();

  /// Schema para descrições/nomes
  static final descriptionSchema = z
      .string()
      .min(1, message: 'Descrição é obrigatória')
      .refine((value) => value.trim().length <= 255, message: 'Descrição deve ter no máximo 255 caracteres')
      .transform((value) => value.trim());

  static final optionalDescriptionSchema = z
      .string()
      .refine((value) => value.trim().length <= 255, message: 'Descrição deve ter no máximo 255 caracteres')
      .transform((value) => value.trim())
      .optional();

  /// Schema para quantidades
  static final quantitySchema = z.double().min(0, message: 'Quantidade deve ser maior ou igual a zero');

  /// Schema para quantidades opcionais
  static final optionalQuantitySchema = z.double()
      .min(0, message: 'Quantidade deve ser maior ou igual a zero')
      .optional();

  /// Schema para valores monetários
  static final monetarySchema = z.double().min(0, message: 'Valor deve ser maior ou igual a zero');

  /// Schema para valores monetários opcionais
  static final optionalMonetarySchema = z.double().min(0, message: 'Valor deve ser maior ou igual a zero').optional();

  /// Schema para datas ISO 8601
  static final dateTimeSchema = z
      .string()
      .min(1, message: 'Data é obrigatória')
      .refine((value) => DateTime.tryParse(value) != null, message: 'Data deve estar em formato válido (ISO 8601)');

  static final optionalDateTimeSchema = z.string().refine((value) {
    if (value.isEmpty) return true;
    return DateTime.tryParse(value) != null;
  }, message: 'Data deve estar em formato válido (ISO 8601)').optional();

  /// Schema para booleanos
  static final booleanSchema = z.bool();

  /// Schema para booleanos opcionais
  static final optionalBooleanSchema = z.bool().optional();

  /// Schema para strings não vazias
  static final nonEmptyStringSchema = z
      .string()
      .min(1, message: 'Campo não pode estar vazio')
      .transform((value) => value.trim());

  static final optionalStringSchema = z.string().transform((value) => value.trim()).optional();

  // === SCHEMAS DE VALIDAÇÃO DE FORMATO ===

  /// Schema para CPF/CNPJ
  static final documentSchema = z
      .string()
      .min(1, message: 'Documento é obrigatório')
      .refine((value) {
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        return digits.length == 11 || digits.length == 14;
      }, message: 'Documento deve ter 11 (CPF) ou 14 (CNPJ) dígitos')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''));

  /// Schema para telefone
  static final phoneSchema = z
      .string()
      .min(1, message: 'Telefone é obrigatório')
      .refine((value) {
        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
        return digits.length >= 10 && digits.length <= 11;
      }, message: 'Telefone deve ter 10 ou 11 dígitos')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''));

  /// Schema para CEP
  static final cepSchema = z
      .string()
      .min(1, message: 'CEP é obrigatório')
      .refine((value) => value.replaceAll(RegExp(r'[^\d]'), '').length == 8, message: 'CEP deve ter 8 dígitos')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''));

  // === SCHEMAS DE LISTA/ARRAY ===

  /// Schema para lista de IDs
  static final idListSchema = z.list(integerSchema);

  /// Schema para lista opcional de IDs
  static final optionalIdListSchema = z.list(integerSchema).optional();

  /// Schema para lista de strings
  static final stringListSchema = z.list(nonEmptyStringSchema);

  /// Schema para lista opcional de strings
  static final optionalStringListSchema = z.list(nonEmptyStringSchema).optional();

  // === SCHEMAS DE PAGINAÇÃO ===

  /// Schema para página (page)
  static final pageSchema = z.int().min(1, message: 'Página deve ser maior que zero');

  /// Schema para tamanho da página (pageSize)
  static final pageSizeSchema = z.int()
      .min(1, message: 'Tamanho da página deve ser maior que zero')
      .max(1000, message: 'Tamanho da página deve ser no máximo 1000');

  /// Schema para ordenação
  static final orderDirectionSchema = z.string().refine(
    (value) => ['ASC', 'DESC', 'asc', 'desc'].contains(value),
    message: 'Direção deve ser ASC ou DESC',
  );

  // === MÉTODOS UTILITÁRIOS ===

  /// Cria schema para enum baseado em lista de valores válidos
  static Schema<String> enumSchema(List<String> validValues, String fieldName) {
    return z.string().refine(
      (value) => validValues.contains(value),
      message: '$fieldName deve ser um dos valores: ${validValues.join(', ')}',
    );
  }

  /// Cria schema para enum opcional
  ///
  /// Bug latente anterior: `validValues.contains(value)` rejeitava
  /// strings vazias sempre, gerando erro em campos opcionais
  /// "limpos" pelo usuario. Agora empty e aceito como "nao
  /// filtrado" (consistente com optionalDateTimeSchema).
  static Schema<String?> optionalEnumSchema(List<String> validValues, String fieldName) {
    return z
        .string()
        .refine(
          (value) => value.isEmpty || validValues.contains(value),
          message: '$fieldName deve ser um dos valores: ${validValues.join(', ')}',
        )
        .optional();
  }

  /// Cria schema para string com tamanho específico
  static Schema<String> fixedLengthStringSchema(int length, String fieldName) {
    return z
        .string()
        .min(1, message: '$fieldName é obrigatório')
        .refine((value) => value.trim().length == length, message: '$fieldName deve ter exatamente $length caracteres')
        .transform((value) => value.trim());
  }

  /// Cria schema para string com tamanho máximo
  static Schema<String> maxLengthStringSchema(int maxLength, String fieldName) {
    return z
        .string()
        .min(1, message: '$fieldName é obrigatório')
        .refine(
          (value) => value.trim().length <= maxLength,
          message: '$fieldName deve ter no máximo $maxLength caracteres',
        )
        .transform((value) => value.trim());
  }

  /// Cria schema para range numérico
  static Schema<int> rangeSchema(int min, int max, String fieldName) {
    return z.int()
        .min(min, message: '$fieldName deve ser no mínimo $min')
        .max(max, message: '$fieldName deve ser no máximo $max');
  }

  // === SCHEMAS ESPECÍFICOS DO PROJETO ===

  /// Schema para ItemId (5 caracteres numéricos, incluindo '00000' para API)
  static final itemIdSchema = z
      .string()
      .length(5, message: 'ItemId deve ter exatamente 5 caracteres')
      .regex(RegExp(r'^\d{5}$'), message: 'ItemId deve conter apenas números')
      .transform((value) => value.padLeft(5, '0'));

  /// Schema para ItemId opcional
  static final optionalItemIdSchema = itemIdSchema.optional();

  /// Schema para SessionId do Socket.IO
  static final sessionIdSchema = z
      .string()
      .min(1, message: 'SessionId não pode estar vazio')
      .regex(RegExp(r'^[a-zA-Z0-9_-]+$'), message: 'SessionId deve conter apenas caracteres alfanuméricos, _ e -');

  /// Schema para SessionId opcional
  static final optionalSessionIdSchema = sessionIdSchema.optional();
}
