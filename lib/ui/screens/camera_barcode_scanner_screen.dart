import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/constants/scan_failure_codes.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CameraBarcodeScannerScreen extends StatefulWidget {
  const CameraBarcodeScannerScreen({super.key});

  @override
  State<CameraBarcodeScannerScreen> createState() => _CameraBarcodeScannerScreenState();
}

class _CameraBarcodeScannerScreenState extends State<CameraBarcodeScannerScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeController();
  }

  void _initializeController() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _releaseControllerAsync(MobileScannerController ctrl) async {
    try {
      await ctrl.stop();
    } catch (_) {}
    await ctrl.dispose();
  }

  Future<void> _closeWithResult(Result<String> result) async {
    if (_isDisposed || !mounted) return;
    Navigator.of(context).pop(result);
  }

  Future<void> _closeCancelled() async {
    await _closeWithResult(
      Failure(DataFailure(message: context.l10n.scanCancelledMessage, code: ScanFailureCodes.cancelled)),
    );
  }

  Future<void> _closeScannerError(MobileScannerException error) async {
    await _closeWithResult(_failureForMobileScannerError(error));
  }

  Result<String> _failureForMobileScannerError(MobileScannerException error) {
    final code = error.errorCode == MobileScannerErrorCode.permissionDenied
        ? ScanFailureCodes.permissionDenied
        : ScanFailureCodes.scannerError;
    final message = code == ScanFailureCodes.permissionDenied
        ? context.l10n.cameraPermissionDeniedMessage
        : context.l10n.scannerOpenErrorMessage;
    return Failure(DataFailure(message: message, code: code, exception: error));
  }

  Result<String> _scannerErrorFromMessage(String message, Object exception) {
    return Failure(DataFailure(message: message, code: ScanFailureCodes.scannerError, exception: exception));
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    final ctrl = _controller;
    _controller = null;
    if (ctrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_releaseControllerAsync(ctrl));
      });
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_closeCancelled());
    }
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (_isProcessing || _isDisposed) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode?.rawValue == null || barcode!.rawValue!.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 300))
          .then((_) async {
            if (mounted && !_isDisposed) {
              await _closeWithResult(Success(barcode.rawValue!));
            }
          })
          .catchError((Object e, StackTrace s) {
            developer.log(
              'Falha apos deteccao de codigo no scanner',
              error: e,
              stackTrace: s,
              name: 'CameraBarcodeScannerScreen',
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await _closeWithResult(_scannerErrorFromMessage(_errorMessage!, _errorMessage!));
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(context.l10n.scannerErrorTitle)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.cameraInitializationError(_errorMessage!),
                    textAlign: TextAlign.center,
                    style: AppFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _closeWithResult(
                      _scannerErrorFromMessage(context.l10n.cameraInitializationError(_errorMessage!), _errorMessage!),
                    ),
                    child: Text(context.l10n.back),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _closeCancelled();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.barcodeScannerTitle),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, state, child) {
                  return Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off);
                },
              ),
              onPressed: () {
                if (_isDisposed || _controller == null) return;
                try {
                  _controller!.toggleTorch();
                } catch (e) {
                  developer.log('Failed to toggle torch', error: e);
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(_closeScannerError(error));
                });
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(context.l10n.scannerErrorCode(error.errorCode.toString()), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(
                        error.errorDetails?.message ?? context.l10n.unknownScannerError,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
            if (_isProcessing)
              Container(
                color: AppColors.black54,
                child: const Center(child: CircularProgressIndicator(color: AppColors.white)),
              ),
          ],
        ),
      ),
    );
  }
}
