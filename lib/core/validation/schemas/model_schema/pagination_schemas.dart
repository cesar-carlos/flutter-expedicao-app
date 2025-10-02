import 'package:zard/zard.dart';

import 'package:exp/core/validation/schemas/common_schemas.dart';

/// Schemas para validação de models de paginação
class PaginationSchemas {
  PaginationSchemas._();

  // === PAGINATION ===

  /// Schema para Pagination
  static final paginationSchema = z.map({
    'CurrentPage': CommonSchemas.pageSchema,
    'PageSize': CommonSchemas.pageSizeSchema,
    'TotalItems': z.int().min(0, message: 'Total de itens deve ser maior ou igual a zero'),
    'TotalPages': z.int().min(0, message: 'Total de páginas deve ser maior ou igual a zero'),
    'HasNextPage': CommonSchemas.booleanSchema,
    'HasPreviousPage': CommonSchemas.booleanSchema,
    'StartIndex': z.int().min(0, message: 'Índice inicial deve ser maior ou igual a zero'),
    'EndIndex': z.int().min(0, message: 'Índice final deve ser maior ou igual a zero'),
  });

  // === QUERY PARAM ===

  /// Schema para QueryParam
  static final queryParamSchema = z.map({
    'Field': CommonSchemas.nonEmptyStringSchema,
    'Operator': CommonSchemas.enumSchema([
      '=',
      '!=',
      '>',
      '<',
      '>=',
      '<=',
      'LIKE',
      'IN',
      'NOT IN',
      'IS NULL',
      'IS NOT NULL',
    ], 'Operador'),
    'Value': z.string().optional(), // Valor como string, pode ser convertido depois
    'LogicalOperator': CommonSchemas.optionalEnumSchema(['AND', 'OR'], 'Operador lógico'),
  });

  // === QUERY ORDER BY ===

  /// Schema para QueryOrderBy
  static final queryOrderBySchema = z.map({
    'Field': CommonSchemas.nonEmptyStringSchema,
    'Direction': CommonSchemas.enumSchema(['ASC', 'DESC', 'asc', 'desc'], 'Direção da ordenação'),
  });

  // === QUERY BUILDER ===

  /// Schema para QueryBuilder
  static final queryBuilderSchema = z.map({
    'Parameters': z.list(queryParamSchema).optional(),
    'OrderBy': z.list(queryOrderBySchema).optional(),
    'Page': CommonSchemas.optionalIntegerSchema,
    'PageSize': z.int().min(1).max(1000).optional(),
    'Distinct': CommonSchemas.optionalBooleanSchema,
    'GroupBy': z.list(CommonSchemas.nonEmptyStringSchema).optional(),
    'Having': z.list(queryParamSchema).optional(),
  });

  // === SCHEMAS DE FILTRO ===

  /// Schema para filtros de paginação
  static final paginationFiltersSchema = z.map({
    'Page': CommonSchemas.pageSchema.optional(),
    'PageSize': CommonSchemas.pageSizeSchema.optional(),
    'SortBy': CommonSchemas.optionalStringSchema,
    'SortDirection': CommonSchemas.optionalEnumSchema(['ASC', 'DESC', 'asc', 'desc'], 'Direção da ordenação'),
    'Search': CommonSchemas.optionalStringSchema,
  });

  /// Schema para parâmetros de consulta
  static final queryParametersSchema = z.map({
    'Filters': z.map({}).optional(), // Mapa dinâmico de filtros
    'Pagination': paginationFiltersSchema.optional(),
    'Include': z.list(CommonSchemas.nonEmptyStringSchema).optional(),
    'Exclude': z.list(CommonSchemas.nonEmptyStringSchema).optional(),
  });

  // === MÉTODOS DE VALIDAÇÃO ===

  /// Valida dados de paginação
  static Map<String, dynamic> validatePagination(Map<String, dynamic> data) {
    try {
      return paginationSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da paginação: $e';
    }
  }

  /// Valida parâmetro de consulta
  static Map<String, dynamic> validateQueryParam(Map<String, dynamic> data) {
    try {
      return queryParamSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do parâmetro de consulta: $e';
    }
  }

  /// Valida ordenação
  static Map<String, dynamic> validateQueryOrderBy(Map<String, dynamic> data) {
    try {
      return queryOrderBySchema.parse(data);
    } catch (e) {
      throw 'Erro na validação da ordenação: $e';
    }
  }

  /// Valida construtor de consulta
  static Map<String, dynamic> validateQueryBuilder(Map<String, dynamic> data) {
    try {
      return queryBuilderSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação do construtor de consulta: $e';
    }
  }

  /// Valida filtros de paginação
  static Map<String, dynamic> validatePaginationFilters(Map<String, dynamic> data) {
    try {
      return paginationFiltersSchema.parse(data);
    } catch (e) {
      throw 'Erro na validação dos filtros de paginação: $e';
    }
  }

  // === VALIDAÇÃO SEGURA ===

  /// Validação segura para paginação
  static ({bool success, Map<String, dynamic>? data, String? error}) safeValidatePagination(Map<String, dynamic> data) {
    try {
      final result = paginationSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  /// Validação segura para construtor de consulta
  static ({bool success, Map<String, dynamic>? data, String? error}) safeValidateQueryBuilder(
    Map<String, dynamic> data,
  ) {
    try {
      final result = queryBuilderSchema.parse(data);
      return (success: true, data: result, error: null);
    } catch (e) {
      return (success: false, data: null, error: e.toString());
    }
  }

  // === VALIDAÇÕES DE REGRAS DE NEGÓCIO ===

  /// Valida consistência da paginação
  static bool validatePaginationConsistency(int currentPage, int totalPages, int totalItems, int pageSize) {
    // Página atual não pode ser maior que total de páginas
    if (currentPage > totalPages && totalPages > 0) return false;

    // Total de páginas deve ser consistente com total de itens e tamanho da página
    final expectedTotalPages = totalItems == 0 ? 0 : ((totalItems - 1) / pageSize).floor() + 1;
    if (totalPages != expectedTotalPages) return false;

    return true;
  }

  /// Valida índices de paginação
  static bool validatePaginationIndices(int startIndex, int endIndex, int currentPage, int pageSize, int totalItems) {
    // Índice inicial deve ser menor que final
    if (startIndex > endIndex && totalItems > 0) return false;

    // Índices devem estar dentro do range válido
    final expectedStartIndex = (currentPage - 1) * pageSize;
    final expectedEndIndex = (expectedStartIndex + pageSize - 1).clamp(0, totalItems - 1);

    return startIndex == expectedStartIndex && (totalItems == 0 || endIndex == expectedEndIndex);
  }

  /// Valida operador de consulta
  static bool isValidQueryOperator(String operator, dynamic value) {
    switch (operator.toUpperCase()) {
      case 'IS NULL':
      case 'IS NOT NULL':
        return value == null;
      case 'IN':
      case 'NOT IN':
        return value is List;
      default:
        return value != null;
    }
  }

  /// Valida direção de ordenação
  static String normalizeOrderDirection(String direction) {
    return direction.toUpperCase();
  }

  /// Valida se o campo pode ser usado para ordenação
  static bool isValidOrderByField(String field, List<String> allowedFields) {
    return allowedFields.contains(field);
  }
}
