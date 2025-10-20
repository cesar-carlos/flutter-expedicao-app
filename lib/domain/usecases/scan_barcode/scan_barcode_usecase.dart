import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/usecases/base_usecase.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_success.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_failure.dart';
import 'package:data7_expedicao/data/repositories/barcode_scanner_repository_mobile_impl.dart';
import 'package:data7_expedicao/domain/usecases/scan_barcode/scan_barcode_params.dart';
import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/core/results/index.dart';

/// UseCase para escanear código de barras usando a câmera do dispositivo
///
/// Este caso de uso:
/// 1. Abre a câmera do dispositivo
/// 2. Permite ao usuário escanear um código de barras
/// 3. Retorna o código escaneado ou erro
class ScanBarcodeUseCase extends UseCase<ScanBarcodeSuccess, ScanBarcodeParams> {
  final BarcodeScannerRepository _scannerRepository;

  ScanBarcodeUseCase({required BarcodeScannerRepository scannerRepository}) : _scannerRepository = scannerRepository;

  /// Método alternativo que aceita o contexto diretamente
  Future<Result<ScanBarcodeSuccess>> callWithContext(BuildContext context, ScanBarcodeParams params) async {
    // Se o repository é do tipo Mobile, configura o contexto
    if (_scannerRepository is BarcodeScannerRepositoryMobileImpl) {
      (_scannerRepository).setContext(context);
    }

    return call(params);
  }

  @override
  Future<Result<ScanBarcodeSuccess>> call(ScanBarcodeParams params) async {
    try {
      // 1. Validar parâmetros (sempre válido neste caso)
      if (!params.isValid) {
        final errors = params.validationErrors.join(', ');
        return failure(ScanBarcodeFailure.scannerError(errors));
      }

      // 2. Executar o scan
      final scanResult = await _scannerRepository.scanBarcode();

      // 3. Processar resultado
      return scanResult.fold(
        (barcode) => success(ScanBarcodeSuccess(barcode: barcode, message: 'Código escaneado com sucesso')),
        (error) {
          // Mapear erros específicos
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
