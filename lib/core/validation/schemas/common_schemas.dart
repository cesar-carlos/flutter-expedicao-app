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
      .transform((value) => value.trim())
      .refine((value) => int.tryParse(value) != null, message: 'Código deve ser numérico');

  /// Schema para códigos opcionais
  static final optionalCodeSchema = z
      .string()
      .optional()
      .transform((value) {
        if (value.trim().isEmpty) return null;
        return value.trim();
      })
      .refine((value) {
        if (value == null) return true;
        return int.tryParse(value) != null;
      }, message: 'Código deve ser numérico');

  /// Schema para descrições/nomes
  static final descriptionSchema = z
      .string()
      .min(1, message: 'Descrição é obrigatória')
      .transform((value) => value.trim())
      .refine((value) => value.length <= 255, message: 'Descrição deve ter no máximo 255 caracteres');

  /// Schema para descrições opcionais
  static final optionalDescriptionSchema = z
      .string()
      .optional()
      .transform((value) => value.trim())
      .refine((value) => value.length <= 255, message: 'Descrição deve ter no máximo 255 caracteres');

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

  /// Schema para datas opcionais
  static final optionalDateTimeSchema = z.string().optional().refine((value) {
    if (value.isEmpty) return true;
    return DateTime.tryParse(value) != null;
  }, message: 'Data deve estar em formato válido (ISO 8601)');

  /// Schema para booleanos
  static final booleanSchema = z.bool();

  /// Schema para booleanos opcionais
  static final optionalBooleanSchema = z.bool().optional();

  /// Schema para strings não vazias
  static final nonEmptyStringSchema = z
      .string()
      .min(1, message: 'Campo não pode estar vazio')
      .transform((value) => value.trim());

  /// Schema para strings opcionais
  static final optionalStringSchema = z.string().optional().transform((value) => value.trim());

  // === SCHEMAS DE VALIDAÇÃO DE FORMATO ===

  /// Schema para CPF/CNPJ
  static final documentSchema = z
      .string()
      .min(1, message: 'Documento é obrigatório')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''))
      .refine(
        (value) => value.length == 11 || value.length == 14,
        message: 'Documento deve ter 11 (CPF) ou 14 (CNPJ) dígitos',
      );

  /// Schema para telefone
  static final phoneSchema = z
      .string()
      .min(1, message: 'Telefone é obrigatório')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''))
      .refine((value) => value.length >= 10 && value.length <= 11, message: 'Telefone deve ter 10 ou 11 dígitos');

  /// Schema para CEP
  static final cepSchema = z
      .string()
      .min(1, message: 'CEP é obrigatório')
      .transform((value) => value.replaceAll(RegExp(r'[^\d]'), ''))
      .refine((value) => value.length == 8, message: 'CEP deve ter 8 dígitos');

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
  static Schema<String?> optionalEnumSchema(List<String> validValues, String fieldName) {
    return z.string().optional().refine(
      (value) => validValues.contains(value),
      message: '$fieldName deve ser um dos valores: ${validValues.join(', ')}',
    );
  }

  /// Cria schema para string com tamanho específico
  static Schema<String> fixedLengthStringSchema(int length, String fieldName) {
    return z
        .string()
        .min(1, message: '$fieldName é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length == length, message: '$fieldName deve ter exatamente $length caracteres');
  }

  /// Cria schema para string com tamanho máximo
  static Schema<String> maxLengthStringSchema(int maxLength, String fieldName) {
    return z
        .string()
        .min(1, message: '$fieldName é obrigatório')
        .transform((value) => value.trim())
        .refine((value) => value.length <= maxLength, message: '$fieldName deve ter no máximo $maxLength caracteres');
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
