enum OrderDirection {
  asc('ASC'),
  desc('DESC');

  const OrderDirection(this.value);
  final String value;
}

class OrderBy {
  final String field;
  final OrderDirection direction;

  const OrderBy({required this.field, this.direction = OrderDirection.asc});

  factory OrderBy.asc(String field) {
    return OrderBy(field: field, direction: OrderDirection.asc);
  }

  factory OrderBy.desc(String field) {
    return OrderBy(field: field, direction: OrderDirection.desc);
  }

  String toSqlString() {
    return '$field ${direction.value}';
  }

  @override
  String toString() {
    return 'OrderBy(field: $field, direction: ${direction.value})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderBy && other.field == field && other.direction == direction;
  }

  @override
  int get hashCode => Object.hash(field, direction);
}

class OrderByCollection {
  final List<OrderBy> _orders = [];

  OrderByCollection asc(String field) {
    _orders.add(OrderBy.asc(field));
    return this;
  }

  OrderByCollection desc(String field) {
    _orders.add(OrderBy.desc(field));
    return this;
  }

  OrderByCollection add(OrderBy order) {
    _orders.add(order);
    return this;
  }

  List<OrderBy> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  bool get isNotEmpty => _orders.isNotEmpty;

  String toSqlString() {
    if (_orders.isEmpty) return '';
    return 'ORDER BY ${_orders.map((o) => o.toSqlString()).join(', ')}';
  }

  String toQueryString() {
    if (_orders.isEmpty) return '';

    final fields = _orders.map((o) => o.field).join(',');
    final directions = _orders.map((o) => o.direction.value).join(',');

    return 'order_by=$fields&order_direction=$directions';
  }

  void clear() {
    _orders.clear();
  }

  @override
  String toString() {
    return 'OrderByCollection(orders: ${_orders.length})';
  }
}
