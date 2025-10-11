/// Generic parameter for queries
class QueryParam<P> {
  final String key;
  final P value;
  final String operator;
  final bool isFieldComparison;

  const QueryParam({required this.key, required this.value, this.operator = '=', this.isFieldComparison = false});

  /// Creates a parameter with default equals operator
  static QueryParam<P> create<P>(String key, P value) {
    return QueryParam<P>(key: key, value: value, operator: '=');
  }

  /// Creates a parameter with custom operator
  static QueryParam<P> createWithOperator<P>(String key, P value, String operator) {
    return QueryParam<P>(key: key, value: value, operator: operator);
  }

  /// Creates a field comparison (value is treated as a field name, not a literal)
  /// Example: createFieldComparison('QuantidadeItens', 'QuantidadeItensSeparacao', '=')
  /// Generates: QuantidadeItens = QuantidadeItensSeparacao (without quotes)
  static QueryParam<String> createFieldComparison(String key, String fieldName, String operator) {
    return QueryParam<String>(key: key, value: fieldName, operator: operator, isFieldComparison: true);
  }

  /// Converts parameter to query string format
  String toQueryString() {
    return '$key$operator${_formatValue(value)}';
  }

  /// Converts parameter to SQL format
  String toSqlString() {
    // Se for operador RAW e a chave for 'where', retorna apenas o valor sem formatação
    if (operator == 'RAW' && key == 'where') {
      return value.toString();
    }
    return '$key $operator ${_formatSqlValue(value)}';
  }

  /// Formats the value for query string
  String _formatValue(P value) {
    // Se for comparação de campo, retorna o valor sem aspas
    if (isFieldComparison) {
      return value.toString();
    }
    // Se o valor já está formatado (contém parênteses para IN), retorna direto
    if (value is String && value.startsWith('(') && value.endsWith(')')) {
      return value;
    }
    if (value is String) {
      return "'$value'";
    } else if (value is DateTime) {
      return "'${value.toIso8601String()}'";
    } else {
      return value.toString();
    }
  }

  /// Formats the value for SQL
  String _formatSqlValue(P value) {
    // Se for comparação de campo, retorna o valor sem aspas
    if (isFieldComparison) {
      return value.toString();
    }
    // Se o valor já está formatado (contém parênteses para IN), retorna direto
    if (value is String && value.startsWith('(') && value.endsWith(')')) {
      return value;
    }
    if (value is String) {
      return "'$value'";
    } else if (value is DateTime) {
      return "'${value.toIso8601String()}'";
    } else if (value is bool) {
      return value ? '1' : '0';
    } else {
      return value.toString();
    }
  }

  @override
  String toString() {
    return 'QueryParam(key: $key, value: $value, operator: $operator)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QueryParam<P> &&
        other.key == key &&
        other.value == value &&
        other.operator == operator &&
        other.isFieldComparison == isFieldComparison;
  }

  @override
  int get hashCode => Object.hash(key, value, operator, isFieldComparison);
}
