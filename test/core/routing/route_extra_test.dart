import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/routing/route_extra.dart';

void main() {
  group('routeExtraMap', () {
    test('should return the same map when extra is Map<String, dynamic>', () {
      final extra = <String, dynamic>{'cart': 1};

      expect(routeExtraMap(extra), same(extra));
    });

    test('should accept Map<String, Object?> used by GoRouter extras', () {
      final extra = <String, Object?>{'cart': 'carrinho', 'userModel': null};

      expect(routeExtraMap(extra), {'cart': 'carrinho', 'userModel': null});
    });

    test('should return null when extra is not a map', () {
      expect(routeExtraMap('payload'), isNull);
      expect(routeExtraMap(null), isNull);
    });
  });

  group('AppRouteExtraCodec', () {
    test('should keep in-memory extras unchanged', () {
      const codec = AppRouteExtraCodec();
      final extra = <String, Object?>{'cart': Object()};

      expect(codec.encode(extra), same(extra));
      expect(codec.decode(extra), same(extra));
    });
  });
}
