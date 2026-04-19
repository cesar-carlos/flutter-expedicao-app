import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/ui/widgets/common/loading_button.dart';

void main() {
  group('LoadingButton', () {
    Widget wrap(Widget child) {
      return MaterialApp(home: Scaffold(body: Center(child: child)));
    }

    testWidgets('renderiza o texto quando isLoading=false', (tester) async {
      await tester.pumpWidget(wrap(LoadingButton(text: 'Enviar', onPressed: () {})));
      expect(find.text('Enviar'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('mostra spinner quando isLoading=true', (tester) async {
      await tester.pumpWidget(wrap(const LoadingButton(text: 'Enviar', isLoading: true)));
      expect(find.text('Enviar'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('desabilita o botao quando isLoading=true', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(LoadingButton(text: 'X', isLoading: true, onPressed: () => pressed = true)));
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(pressed, isFalse);
    });

    // Bug latente anterior: `strokeWidth!` e `loadingColor!` (null
    // assertions) crashavam com TypeError se o caller passasse null
    // explicitamente. Defaults so se aplicam para argumentos
    // omitidos, nao para nulls passados deliberadamente.
    testWidgets('NAO crasha quando loadingColor=null explicito + isLoading=true', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingButton(text: 'X', isLoading: true, loadingColor: null)),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('NAO crasha quando strokeWidth=null explicito + isLoading=true', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingButton(text: 'X', isLoading: true, strokeWidth: null)),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('NAO crasha quando loadingSize=null explicito + isLoading=true', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingButton(text: 'X', isLoading: true, loadingSize: null)),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
