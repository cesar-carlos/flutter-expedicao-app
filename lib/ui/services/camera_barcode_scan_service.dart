import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/constants/scan_failure_codes.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/routing/app_router.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

class CameraBarcodeScanService {
  const CameraBarcodeScanService();

  Future<Result<String>> scan(BuildContext context) async {
    final router = GoRouter.of(context);
    final cameraPermissionDeniedMessage = context.l10n.cameraPermissionDeniedMessage;
    final scannerOpenErrorMessage = context.l10n.scannerOpenErrorMessage;
    final scanCancelledMessage = context.l10n.scanCancelledMessage;
    final emptyBarcodeMessage = context.l10n.emptyBarcodeMessage;

    try {
      final result = await router.push<Result<String>>(AppRouter.cameraBarcodeScanner);
      return _normalizeRouteResult(
        result,
        scanCancelledMessage: scanCancelledMessage,
        emptyBarcodeMessage: emptyBarcodeMessage,
      );
    } on MobileScannerException catch (e) {
      final code = e.errorCode == MobileScannerErrorCode.permissionDenied
          ? ScanFailureCodes.permissionDenied
          : ScanFailureCodes.scannerError;
      final message = code == ScanFailureCodes.permissionDenied
          ? cameraPermissionDeniedMessage
          : scannerOpenErrorMessage;
      return Failure(DataFailure(message: message, code: code, exception: e));
    } catch (e) {
      return Failure(DataFailure(message: scannerOpenErrorMessage, code: ScanFailureCodes.scannerError, exception: e));
    }
  }

  Result<String> _normalizeRouteResult(
    Result<String>? result, {
    required String scanCancelledMessage,
    required String emptyBarcodeMessage,
  }) {
    if (result == null) {
      return Failure(DataFailure(message: scanCancelledMessage, code: ScanFailureCodes.cancelled));
    }

    return result.fold((barcode) {
      if (barcode.trim().isEmpty) {
        return Failure(DataFailure(message: emptyBarcodeMessage, code: ScanFailureCodes.emptyBarcode));
      }
      return Success(barcode);
    }, (failure) => Failure(failure));
  }
}
