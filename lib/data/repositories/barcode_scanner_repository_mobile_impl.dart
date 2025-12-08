import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:result_dart/result_dart.dart';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/repositories/barcode_scanner_repository.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';

/// Implementação do repository de scanner usando mobile_scanner
class BarcodeScannerRepositoryMobileImpl implements BarcodeScannerRepository {
  BuildContext? _context;

  /// Define o contexto para navegação
  void setContext(BuildContext context) {
    _context = context;
  }

  @override
  Future<Result<String>> scanBarcode() async {
    try {
      if (_context == null) {
        return Failure(
          DataFailure(message: 'Contexto não configurado. Chame setContext() antes de usar.', code: 'NO_CONTEXT'),
        );
      }

      final result = await Navigator.of(
        _context!,
      ).push<String>(MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));

      // Se o usuário cancelou, retorna erro
      if (result == null) {
        return Failure(DataFailure(message: 'Scan cancelado pelo usuário', code: 'SCAN_CANCELLED'));
      }

      // Se o código está vazio, retorna erro
      if (result.trim().isEmpty) {
        return Failure(DataFailure(message: 'Código de barras vazio', code: 'EMPTY_BARCODE'));
      }

      // Retorna o código escaneado
      return Success(result);
    } catch (e) {
      return Failure(
        DataFailure(message: 'Erro ao escanear código de barras: ${e.toString()}', code: 'SCANNER_ERROR', exception: e),
      );
    }
  }
}

/// Tela de scanner de código de barras
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _disableSystemSounds();
    _initializeController();
  }

  /// Desabilita sons do sistema durante o scan
  void _disableSystemSounds() {
    // Não há API direta para desabilitar o beep do mobile_scanner
    // O beep é controlado pelo sistema operacional Android/iOS
  }

  void _initializeController() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates, // Evita múltiplos beeps
        facing: CameraFacing.back,
        torchEnabled: false,
        useNewCameraSelector: true,
        returnImage: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao inicializar câmera: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode != null && barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
      setState(() {
        _isProcessing = true;
      });

      // Pequeno delay para garantir que o scan foi bem sucedido
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.of(context).pop(barcode.rawValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erro no Scanner')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Voltar')),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller!,
              builder: (context, state, child) {
                return Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: () {
              try {
                _controller?.toggleTorch();
              } catch (e) {
                // Ignora erros ao alternar flash
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
            scanWindow: null, // Escanear toda a área
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erro: ${error.errorCode}', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(error.errorDetails?.message ?? 'Erro desconhecido', textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
