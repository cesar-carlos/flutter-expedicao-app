import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/ui/widgets/common/navigation_error_screen.dart';

void main() {
  testWidgets('should show an actionable error and invoke recovery', (tester) async {
    var recovered = false;
    await tester.pumpWidget(
      MaterialApp(
        home: NavigationErrorScreen(
          message: 'Reabra a separação para continuar.',
          onReturnHome: () => recovered = true,
        ),
      ),
    );
    expect(find.text('Reabra a separação para continuar.'), findsOneWidget);
    await tester.tap(find.text('Voltar ao início'));
    expect(recovered, isTrue);
  });
}
