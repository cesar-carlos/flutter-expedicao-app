import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_params.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_usecase.dart';

void main() {
  group('ScanBarcodeUseCase', () {
    test('call retorna falha orientando uso de callWithContext', () async {
      final uc = ScanBarcodeUseCase(scannerRepository: _FakeScanner(const Success('ignored')));

      final result = await uc.call(const ScanBarcodeParams());

      expect(result.isError(), isTrue);
      expect(result.exceptionOrNull()?.toString(), contains('callWithContext'));
    });

    testWidgets('callWithContext retorna sucesso quando scanner retorna codigo', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final uc = ScanBarcodeUseCase(scannerRepository: _FakeScanner(const Success('789')));

      final result = await uc.callWithContext(ctx, const ScanBarcodeParams());

      expect(result.isSuccess(), isTrue);
      result.fold((success) => expect(success.barcode, '789'), (_) => fail('expected success'));
    });

    testWidgets('callWithContext mapeia cancelamento', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final uc = ScanBarcodeUseCase(scannerRepository: _FakeScanner(Failure(Exception('cancelado pelo usuario'))));

      final result = await uc.callWithContext(ctx, const ScanBarcodeParams());

      expect(result.isError(), isTrue);
    });
  });
}

class _FakeScanner implements BarcodeScannerRepository {
  _FakeScanner(this.outcome);

  final Result<String> outcome;

  @override
  Future<Result<String>> scanBarcode({required BuildContext context}) async => outcome;
}
