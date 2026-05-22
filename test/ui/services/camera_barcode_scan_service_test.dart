import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/constants/scan_failure_codes.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/ui/services/camera_barcode_scan_service.dart';

void main() {
  group('CameraBarcodeScanService', () {
    testWidgets('returns success from camera route', (tester) async {
      final service = CameraBarcodeScanService();
      late BuildContext scanContext;

      await tester.pumpWidget(
        _buildHarness((context) => scanContext = context, (context) {
          context.pop<Result<String>>(Success('ABC123'));
        }),
      );

      final future = service.scan(scanContext);
      await tester.pumpAndSettle();
      final result = await future;

      expect(result.getOrNull(), equals('ABC123'));
    });

    testWidgets('maps null route result to SCAN_CANCELLED', (tester) async {
      final service = CameraBarcodeScanService();
      late BuildContext scanContext;

      await tester.pumpWidget(
        _buildHarness((context) => scanContext = context, (context) {
          context.pop();
        }),
      );

      final future = service.scan(scanContext);
      await tester.pumpAndSettle();
      final result = await future;

      expect(
        result.exceptionOrNull(),
        isA<DataFailure>().having((failure) => failure.code, 'code', ScanFailureCodes.cancelled),
      );
    });

    testWidgets('maps empty barcode success to EMPTY_BARCODE', (tester) async {
      final service = CameraBarcodeScanService();
      late BuildContext scanContext;

      await tester.pumpWidget(
        _buildHarness((context) => scanContext = context, (context) {
          context.pop<Result<String>>(Success('   '));
        }),
      );

      final future = service.scan(scanContext);
      await tester.pumpAndSettle();
      final result = await future;

      expect(
        result.exceptionOrNull(),
        isA<DataFailure>().having((failure) => failure.code, 'code', ScanFailureCodes.emptyBarcode),
      );
    });

    testWidgets('preserves typed scanner failure from route', (tester) async {
      final service = CameraBarcodeScanService();
      late BuildContext scanContext;

      await tester.pumpWidget(
        _buildHarness((context) => scanContext = context, (context) {
          context.pop<Result<String>>(
            Failure(DataFailure(message: 'Permissao negada', code: ScanFailureCodes.permissionDenied)),
          );
        }),
      );

      final future = service.scan(scanContext);
      await tester.pumpAndSettle();
      final result = await future;

      expect(
        result.exceptionOrNull(),
        isA<DataFailure>().having((failure) => failure.code, 'code', ScanFailureCodes.permissionDenied),
      );
    });
  });
}

Widget _buildHarness(
  void Function(BuildContext context) onHomeContext,
  void Function(BuildContext context) routeAction,
) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return Scaffold(
            body: Builder(
              builder: (context) {
                onHomeContext(context);
                return ElevatedButton(onPressed: () {}, child: const Text('ready'));
              },
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouter.cameraBarcodeScanner,
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) => routeAction(context));
          return const Scaffold(body: Text('camera'));
        },
      ),
    ],
  );

  return MaterialApp.router(
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}
