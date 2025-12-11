import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_success.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_failure.dart';
import 'package:data7_expedicao/data/repositories/barcode_scanner_repository_mobile_impl.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_params.dart';
import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/core/results/index.dart';

class ScanBarcodeUseCase extends UseCase<ScanBarcodeSuccess, ScanBarcodeParams> {
  final BarcodeScannerRepository _scannerRepository;

  ScanBarcodeUseCase({required BarcodeScannerRepository scannerRepository}) : _scannerRepository = scannerRepository;

  Future<Result<ScanBarcodeSuccess>> callWithContext(BuildContext context, ScanBarcodeParams params) async {
    if (_scannerRepository is BarcodeScannerRepositoryMobileImpl) {
      (_scannerRepository).setContext(context);
    }

    return call(params);
  }

  @override
  Future<Result<ScanBarcodeSuccess>> call(ScanBarcodeParams params) async {
    try {
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(ScanBarcodeFailure.scannerError(errors));
      }

      final scanResult = await _scannerRepository.scanBarcode();

      return scanResult.fold(
        (barcode) => success(ScanBarcodeSuccess(barcode: barcode, message: 'Código escaneado com sucesso')),
        (error) {
          final errorMessage = error.toString();
          if (errorMessage.contains('cancelado')) {
            return failure(ScanBarcodeFailure.cancelled());
          } else if (errorMessage.contains('vazio')) {
            return failure(ScanBarcodeFailure.emptyBarcode());
          } else if (errorMessage.contains('permiss')) {
            return failure(ScanBarcodeFailure.permissionDenied());
          }
          return failure(ScanBarcodeFailure.scannerError(errorMessage));
        },
      );
    } catch (e) {
      return failure(ScanBarcodeFailure.scannerError(e.toString()));
    }
  }
}
