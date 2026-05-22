import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/core/constants/scan_failure_codes.dart';
import 'package:data7_expedicao/core/localization/localization_extensions.dart';
import 'package:data7_expedicao/core/results/app_failure.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/user/system_qrcode_data.dart';
import 'package:data7_expedicao/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/services/camera_barcode_scan_service.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

class QRCodeLoginScreen extends StatefulWidget {
  final CameraBarcodeScanService scanService;
  final RegisterViaQRCodeUseCase registerViaQRCodeUseCase;

  const QRCodeLoginScreen({super.key, required this.scanService, required this.registerViaQRCodeUseCase});

  @override
  State<QRCodeLoginScreen> createState() => _QRCodeLoginScreenState();
}

class _QRCodeLoginScreenState extends State<QRCodeLoginScreen> {
  bool _isProcessing = false;
  String? _errorMessage;

  CameraBarcodeScanService get _scanService => widget.scanService;

  RegisterViaQRCodeUseCase get _registerViaQRCodeUseCase => widget.registerViaQRCodeUseCase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar.withoutSocket(
        title: context.l10n.loginSystem,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.qr_code_scanner, size: 120, color: colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              'Cadastro via QR Code',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Escaneie o QR Code fornecido pelo sistema para criar seu cadastro automaticamente.',
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR Code'),
              onPressed: _isProcessing ? null : _startScanFlow,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
            const SizedBox(height: 16),
            if (_isProcessing) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              ErrorMessage(message: _errorMessage!),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                onPressed: _isProcessing ? null : _startScanFlow,
              ),
              TextButton(
                onPressed: _isProcessing ? null : () => context.go('/login'),
                child: const Text('Voltar ao login'),
              ),
            ],
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('Como funciona?', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Solicite ao administrador o QR Code de cadastro\n'
                    '2. Clique em "Escanear QR Code"\n'
                    '3. Aponte a camera para o QR Code\n'
                    '4. Seu cadastro sera criado automaticamente',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScanFlow() {
    unawaited(
      _scanQRCode().catchError((Object error, StackTrace stackTrace) {
        AppLogger.warning(
          'Falha nao tratada no fluxo de scan QR',
          tag: 'QRCodeLoginScreen',
          error: error,
          stackTrace: stackTrace,
        );
        _setErrorState('Erro inesperado ao escanear. Tente novamente.');
      }),
    );
  }

  Future<void> _scanQRCode() async {
    AppLogger.operation('Iniciando leitura de QR Code', tag: 'QRCodeLoginScreen');
    _setProcessingState(true);

    try {
      final scanResult = await _scanService.scan(context);

      await scanResult.fold(
        (barcode) async {
          AppLogger.info('QR Code escaneado com sucesso', tag: 'QRCodeLoginScreen');
          await _processQRCodeData(barcode);
        },
        (failure) {
          AppLogger.warning('Falha ao escanear QR Code', tag: 'QRCodeLoginScreen', error: failure);
          _setErrorState(_scanFailureMessage(failure));
        },
      );
    } catch (e, s) {
      AppLogger.error('Erro inesperado durante scan de QR Code', tag: 'QRCodeLoginScreen', error: e, stackTrace: s);
      _setErrorState('Erro inesperado: ${e.toString()}');
    }
  }

  Future<void> _processQRCodeData(String qrCodeContent) async {
    if (!mounted) {
      return;
    }

    try {
      final parseResult = SystemQRCodeData.fromQRCodeString(qrCodeContent);
      await parseResult.fold((qrCodeData) async {
        AppLogger.info('QR Code interpretado para codUsuario=${qrCodeData.codUsuario}', tag: 'QRCodeLoginScreen');
        await _handleQRCodeParseSuccess(qrCodeData);
      }, (failure) async => _handleQRCodeParseFailure(failure as AppFailure));
    } catch (e, stackTrace) {
      _handleCriticalError(e, stackTrace);
    }
  }

  Future<void> _handleQRCodeParseSuccess(SystemQRCodeData qrCodeData) async {
    if (!mounted) {
      return;
    }

    try {
      final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);
      final result = await _registerViaQRCodeUseCase(params);

      if (!mounted) {
        return;
      }

      await result.fold(
        (success) async => _handleRegistrationSuccess(success),
        (failure) async => _handleRegistrationFailure(failure as AppFailure),
      );
    } catch (e, s) {
      AppLogger.error(
        'Erro ao registrar usuario a partir do QR Code',
        tag: 'QRCodeLoginScreen',
        error: e,
        stackTrace: s,
      );
      _setErrorState('Erro ao registrar usuario: ${e.toString()}');
    }
  }

  void _handleQRCodeParseFailure(AppFailure failure) {
    AppLogger.warning('Falha ao interpretar QR Code', tag: 'QRCodeLoginScreen', error: failure);
    _setErrorState(failure.userMessage);
  }

  String _scanFailureMessage(Object failure) {
    if (failure is! AppFailure) {
      return 'Erro ao escanear. Tente novamente.';
    }

    return switch (failure.code) {
      ScanFailureCodes.cancelled => context.l10n.scanCancelledMessage,
      ScanFailureCodes.emptyBarcode => context.l10n.emptyBarcodeMessage,
      ScanFailureCodes.permissionDenied => context.l10n.cameraPermissionDeniedMessage,
      ScanFailureCodes.scannerError => context.l10n.scannerOpenErrorMessage,
      _ => failure.userMessage,
    };
  }

  Future<void> _handleRegistrationSuccess(RegisterViaQRCodeSuccess success) async {
    if (!mounted) {
      return;
    }

    AppLogger.info('Cadastro via QR concluido; atualizando estado de autenticacao', tag: 'QRCodeLoginScreen');

    try {
      await _updateAuthStatus();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Cadastro via QR concluido mas atualizacao de auth falhou',
        tag: 'QRCodeLoginScreen',
        error: e,
        stackTrace: stackTrace,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    _showSuccessMessage(success.message);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _setProcessingState(false);
    }
  }

  void _handleRegistrationFailure(AppFailure failure) {
    AppLogger.warning('Falha ao concluir cadastro via QR', tag: 'QRCodeLoginScreen', error: failure);
    _setErrorState(failure.userMessage);
  }

  void _handleCriticalError(Object error, StackTrace stackTrace) {
    _setErrorState('Erro critico ao processar QR Code: ${error.toString()}');
    AppLogger.error(
      'Erro critico ao processar QR Code',
      tag: 'QRCodeLoginScreen',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _setProcessingState(bool isProcessing) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = isProcessing;
      if (isProcessing) {
        _errorMessage = null;
      }
    });
  }

  void _setErrorState(String errorMessage) {
    if (!mounted) {
      return;
    }

    setState(() {
      _errorMessage = errorMessage;
      _isProcessing = false;
    });
  }

  void _showSuccessMessage(String message) {
    if (!mounted) {
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
      );
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Erro ao exibir mensagem de sucesso do QR',
        tag: 'QRCodeLoginScreen',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _updateAuthStatus() async {
    if (!mounted) {
      return;
    }

    try {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.checkAuthStatus();
    } catch (e) {
      _setErrorState('Erro ao atualizar autenticacao: ${e.toString()}');
      rethrow;
    }
  }
}
