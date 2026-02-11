import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:data7_expedicao/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('manual update check shows not-configured SnackBar', (WidgetTester tester) async {
    app.main();

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));

    expect(find.textContaining('Olá'), findsOneWidget);

    final scaffoldFinder = find.ancestor(of: find.textContaining('Olá'), matching: find.byType(Scaffold));
    expect(scaffoldFinder, findsOneWidget);
    final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder);
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app_drawer_version')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('GITHUB_OWNER ou GITHUB_REPO não configurados'), findsOneWidget);
  });
}
