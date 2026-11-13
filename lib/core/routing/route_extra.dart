Map<String, dynamic>? routeExtraMap(Object? extra) {
  return switch (extra) {
    Map<String, dynamic> map => map,
    Map map => <String, dynamic>{
      for (final entry in map.entries)
        if (entry.key case final String key) key: entry.value,
    },
    _ => null,
  };
}

final class RouteExtraFailure {
  const RouteExtraFailure(this.message);

  final String message;
}
