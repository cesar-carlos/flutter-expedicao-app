import 'dart:convert';

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

final class AppRouteExtraCodec extends Codec<Object?, Object?> {
  const AppRouteExtraCodec();

  @override
  Converter<Object?, Object?> get decoder => const _IdentityConverter();

  @override
  Converter<Object?, Object?> get encoder => const _IdentityConverter();
}

final class _IdentityConverter extends Converter<Object?, Object?> {
  const _IdentityConverter();

  @override
  Object? convert(Object? input) => input;
}
