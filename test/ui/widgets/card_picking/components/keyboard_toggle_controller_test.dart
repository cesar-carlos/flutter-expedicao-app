import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_scan_state.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/widgets/barcode_scanner_card_optimized.dart';

void main() {
  for (final keyboardMode in [false, true]) {
    testWidgets('should restore focus after confirming a scan when keyboard mode is $keyboardMode', (tester) async {
      final harness = _ScannerHarness(keyboardMode: keyboardMode);
      await tester.pumpWidget(harness.app);
      harness.focus.requestFocus();
      await tester.pump();
      expect(harness.focus.hasFocus, isTrue);

      // A leitura desabilita o campo enquanto aguarda a operacao assincrona.
      harness.state.tryStartProcessing();
      await tester.pump();
      expect(harness.focus.hasFocus, isFalse);
      harness.state.stopProcessing();
      harness.keyboard.restoreInputFocus(keyboardEnabled: harness.state.keyboardEnabled);
      await tester.pump();
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
      expect(harness.focus.hasFocus, isTrue);
      expect(harness.state.keyboardEnabled, keyboardMode);
      expect(tester.testTextInput.isVisible, keyboardMode);
      await tester.pumpWidget(const SizedBox.shrink());
      harness.dispose();
    });
  }

  testWidgets('should preserve modal focus and keyboard when a scan completes behind a dialog', (tester) async {
    final harness = _ScannerHarness(keyboardMode: true);
    final modalFocus = FocusNode();
    await tester.pumpWidget(harness.app);
    harness.focus.requestFocus();
    await tester.pump();
    harness.state.tryStartProcessing();
    await tester.pump();
    showDialog<void>(
      context: harness.context,
      builder: (_) => AlertDialog(content: TextField(focusNode: modalFocus, autofocus: true)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(modalFocus.hasFocus, isTrue);
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.textInput, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.textInput, null));

    harness.state.stopProcessing();
    harness.keyboard.restoreInputFocus(keyboardEnabled: harness.state.keyboardEnabled);
    await tester.pump();
    await tester.pump();

    expect(modalFocus.hasFocus, isTrue);
    expect(harness.focus.hasFocus, isFalse);
    expect(calls.where((call) => call.method == 'TextInput.hide'), isEmpty);
    expect(calls.where((call) => call.method == 'TextInput.show'), isEmpty);
    Navigator.of(harness.context).pop();
    await tester.pumpAndSettle();
    harness.keyboard.forceFocusAndCloseKeyboard();
    await tester.pump();
    await tester.pump();
    expect(harness.focus.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    modalFocus.dispose();
    harness.dispose();
  });

  testWidgets('should ignore pending focus restoration after leaving the screen', (tester) async {
    final harness = _ScannerHarness();
    await tester.pumpWidget(harness.app);
    harness.keyboard.forceFocusAndCloseKeyboard();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    harness.dispose();
  });
}

class _ScannerHarness {
  final state = PickingScanState();
  final focus = FocusNode();
  final text = TextEditingController();
  late BuildContext context;
  late KeyboardToggleController keyboard;

  _ScannerHarness({bool keyboardMode = false}) {
    state.setKeyboardEnabled(keyboardMode);
  }

  Widget get app => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: ChangeNotifierProvider.value(
        value: state,
        child: Builder(
          builder: (context) {
            this.context = context;
            keyboard = KeyboardToggleController(scanFocusNode: focus, context: context);
            return BarcodeScannerCardOptimized(
              controller: text,
              focusNode: focus,
              onToggleKeyboard: () {},
              onSubmitted: (_) {},
            );
          },
        ),
      ),
    ),
  );

  void dispose() {
    focus.dispose();
    text.dispose();
    state.dispose();
  }
}
