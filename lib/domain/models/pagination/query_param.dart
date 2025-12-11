class QueryParam<P> {
  final String key;
  final P value;
  final String operator;
  final bool isFieldComparison;

  const QueryParam({required this.key, required this.value, this.operator = '=', this.isFieldComparison = false});

  static QueryParam<P> create<P>(String key, P value) {
    return QueryParam<P>(key: key, value: value, operator: '=');
  }

  static QueryParam<P> createWithOperator<P>(String key, P value, String operator) {
    return QueryParam<P>(key: key, value: value, operator: operator);
  }

  static QueryParam<String> createFieldComparison(String key, String fieldName, String operator) {
    return QueryParam<String>(key: key, value: fieldName, operator: operator, isFieldComparison: true);
  }

  String toQueryString() {
    return '$key$operator${_formatValue(value)}';
  }

  String toSqlString() {
    if (operator == 'RAW' && key == 'where') {
      return value.toString();
    }
    return '$key $operator ${_formatSqlValue(value)}';
  }

  String _formatValue(P value) {
    if (isFieldComparison) {
      return value.toString();
    }

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

  String _formatSqlValue(P value) {
    if (isFieldComparison) {
      return value.toString();
    }

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
