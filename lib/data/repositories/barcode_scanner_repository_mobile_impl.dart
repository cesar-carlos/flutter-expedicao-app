import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:result_dart/result_dart.dart';
import 'package:flutter/material.dart';

import 'dart:developer' as developer;
import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class BarcodeScannerRepositoryMobileImpl implements BarcodeScannerRepository {
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  Future<Result<String>> scanBarcode() async {
    try {
      if (_context == null) {
        return Failure(
          DataFailure(
            message:
                'Contexto não configurado. Chame setContext() antes de usar.',
            code: 'NO_CONTEXT',
          ),
        );
      }

      final result = await Navigator.of(_context!).push<String>(
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );

      if (result == null) {
        return Failure(
          DataFailure(
            message: 'Scan cancelado pelo usuário',
            code: 'SCAN_CANCELLED',
          ),
        );
      }

      if (result.trim().isEmpty) {
        return Failure(
          DataFailure(message: 'Código de barras vazio', code: 'EMPTY_BARCODE'),
        );
      }

      return Success(result);
    } catch (e) {
      return Failure(
        DataFailure(
          message: 'Erro ao escanear código de barras: ${e.toString()}',
          code: 'SCANNER_ERROR',
          exception: e,
        ),
      );
    }
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _disableSystemSounds();
    _initializeController();
  }

  void _disableSystemSounds() {}

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
        _errorMessage = 'Erro ao inicializar câmera: ${e.toString()}';
      });
    }
  }

  Future<void> _releaseControllerAsync(MobileScannerController ctrl) async {
    try {
      await ctrl.stop();
    } catch (_) {}
    await ctrl.dispose();
  }

  Future<void> _closeWithResult(String? result) async {
    if (_isDisposed || !mounted) return;
    if (mounted) {
      Navigator.of(context).pop(result);
    }
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
      unawaited(_handleAppBackground());
    }
  }

  Future<void> _handleAppBackground() async {
    if (mounted) {
      Navigator.of(context).pop(null);
    }
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (_isProcessing || _isDisposed) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode != null &&
        barcode.rawValue != null &&
        barcode.rawValue!.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      Future.delayed(const Duration(milliseconds: 300), () async {
        if (mounted && !_isDisposed) {
          await _closeWithResult(barcode.rawValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (!didPop) {
            await _closeWithResult(null);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Erro no Scanner')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppFonts.inter(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _closeWithResult(null),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _closeWithResult(null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Escanear Código'),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _controller!,
                builder: (context, state, child) {
                  return Icon(
                    state.torchState == TorchState.on
                        ? Icons.flash_on
                        : Icons.flash_off,
                  );
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
              controller: _controller!,
              onDetect: _onDetect,
              scanWindow: null,
              errorBuilder: (context, error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        'Erro: ${error.errorCode}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.errorDetails?.message ?? 'Erro desconhecido',
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
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
