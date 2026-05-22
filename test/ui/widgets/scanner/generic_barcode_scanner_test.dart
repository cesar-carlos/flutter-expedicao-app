import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/barcode_scanner_service.dart';
import 'package:data7_expedicao/ui/widgets/scanner/generic_barcode_scanner.dart';

void main() {
  testWidgets('allowKeyboardInput true permite submissao manual', (tester) async {
    final scanned = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenericBarcodeScanner(
            scannerService: BarcodeScannerService(),
            allowKeyboardInput: true,
            enableTactileFeedback: false,
            onBarcodeScanned: scanned.add,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '789123');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(scanned, equals(['789123']));
  });
}
