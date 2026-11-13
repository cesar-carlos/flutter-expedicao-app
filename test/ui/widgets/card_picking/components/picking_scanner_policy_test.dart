import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scanner_policy.dart';

void main() {
  group('shouldActivatePickingScanner', () {
    test('should keep scanner off when cart is not in separation', () {
      expect(shouldActivatePickingScanner(isCartInSeparation: false, hasNextItem: true), isFalse);
    });

    test('should keep scanner off when there is no next item', () {
      expect(shouldActivatePickingScanner(isCartInSeparation: true, hasNextItem: false), isFalse);
    });

    test('should keep scanner off when cart is finished and empty', () {
      expect(shouldActivatePickingScanner(isCartInSeparation: false, hasNextItem: false), isFalse);
    });

    test('should activate scanner only while separating a pending item', () {
      expect(shouldActivatePickingScanner(isCartInSeparation: true, hasNextItem: true), isTrue);
    });
  });
}
