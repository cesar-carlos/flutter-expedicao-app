import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/ui/widgets/common/custom_app_bar.dart';

void main() {
  Widget wrap(Widget appBar) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A7A8A),
          foregroundColor: Colors.white,
        ),
      ),
      home: Scaffold(appBar: appBar as PreferredSizeWidget),
    );
  }

  group('CustomAppBar', () {
    testWidgets('renderiza titulo String', (tester) async {
      await tester.pumpWidget(
        wrap(const CustomAppBar(title: 'Minha Tela', showSocketStatus: false)),
      );
      expect(find.text('Minha Tela'), findsOneWidget);
    });

    testWidgets('renderiza titulo Widget personalizado', (tester) async {
      await tester.pumpWidget(
        wrap(const CustomAppBar(title: Text('CustomWidget'), showSocketStatus: false)),
      );
      expect(find.text('CustomWidget'), findsOneWidget);
    });

    // Bug visual anterior: o titulo usava `foregroundColor` cru
    // (null em chamadas comuns), enquanto o `AppBar` aplicava
    // `effectiveForegroundColor` com fallback. Resultado: titulo
    // poderia ter cor diferente da cor do AppBar.
    testWidgets('cor do titulo segue effectiveForegroundColor do AppBar', (tester) async {
      await tester.pumpWidget(
        wrap(const CustomAppBar(title: 'X', showSocketStatus: false)),
      );

      final textWidget = tester.widget<Text>(find.text('X'));
      // Como nao passamos foregroundColor explicito, o titulo deve
      // usar a cor `theme.appBarTheme.foregroundColor` (Colors.white
      // no tema do test), nao null/preto.
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('cor do titulo respeita foregroundColor explicito', (tester) async {
      await tester.pumpWidget(
        wrap(const CustomAppBar(title: 'X', foregroundColor: Colors.red, showSocketStatus: false)),
      );

      final textWidget = tester.widget<Text>(find.text('X'));
      expect(textWidget.style?.color, equals(Colors.red));
    });

    // Bug latente anterior: title era `dynamic`. Outros tipos
    // (int, Map) crashariam no cast em `_buildNormalTitle`. Agora
    // type-safe via `Object` mas com fallback defensivo (toString).
    testWidgets('aceita Object inesperado sem crash (toString fallback)', (tester) async {
      await tester.pumpWidget(
        wrap(const CustomAppBar(title: 42, showSocketStatus: false)),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('42'), findsOneWidget);
    });
  });
}
