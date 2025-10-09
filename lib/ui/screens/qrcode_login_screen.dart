import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:exp/di/locator.dart';
import 'package:exp/domain/usecases/scan_barcode/scan_barcode_usecase.dart';
import 'package:exp/domain/usecases/scan_barcode/scan_barcode_params.dart';
import 'package:exp/domain/usecases/user/register_via_qrcode_usecase.dart';
import 'package:exp/domain/models/user/system_qrcode_data.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/core/results/app_failure.dart';

/// Tela para login/cadastro via QR Code do Sistema
class QRCodeLoginScreen extends StatefulWidget {
  const QRCodeLoginScreen({super.key});

  @override
  State<QRCodeLoginScreen> createState() => _QRCodeLoginScreenState();
}

class _QRCodeLoginScreenState extends State<QRCodeLoginScreen> {
  // Estados da UI
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login System'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/login')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ícone
            Icon(Icons.qr_code_scanner, size: 120, color: colorScheme.primary),

            const SizedBox(height: 32),

            // Título
            Text(
              'Cadastro via QR Code',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Descrição
            Text(
              'Escaneie o QR Code fornecido pelo sistema para criar seu cadastro automaticamente.',
              style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Botão de Escanear
            FilledButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear QR Code'),
              onPressed: _isProcessing ? null : _scanQRCode,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),

            const SizedBox(height: 16),

            // Loading indicator
            if (_isProcessing) const Center(child: CircularProgressIndicator()),

            // Mensagem de erro
            if (_errorMessage != null) ...[const SizedBox(height: 16), ErrorMessage(message: _errorMessage!)],

            const SizedBox(height: 48),

            // Informações adicionais
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
                    '3. Aponte a câmera para o QR Code\n'
                    '4. Seu cadastro será criado automaticamente',
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

  /// Inicia o processo de escaneamento do QR Code.
  Future<void> _scanQRCode() async {
    _setProcessingState(true);

    try {
      final scanUseCase = locator<ScanBarcodeUseCase>();
      const params = ScanBarcodeParams();
      final scanResult = await scanUseCase.callWithContext(context, params);

      await scanResult.fold((success) async => await _processQRCodeData(success.barcode), (failure) {
        _setErrorState('Erro ao escanear: ${failure.toString()}');
      });
    } catch (e) {
      _setErrorState('Erro inesperado: ${e.toString()}');
    }
  }

  /// Processa os dados do QR Code escaneado.
  Future<void> _processQRCodeData(String qrCodeContent) async {
    if (!mounted) return;

    try {
      final parseResult = SystemQRCodeData.fromQRCodeString(qrCodeContent);

      parseResult.fold(
        (qrCodeData) => _handleQRCodeParseSuccess(qrCodeData),
        (failure) => _handleQRCodeParseFailure(failure as AppFailure),
      );
    } catch (e, stackTrace) {
      _handleCriticalError(e, stackTrace);
    }
  }

  /// Processa sucesso no parse do QR Code.
  Future<void> _handleQRCodeParseSuccess(SystemQRCodeData qrCodeData) async {
    if (!mounted) return;

    try {
      final registerUseCase = locator<RegisterViaQRCodeUseCase>();
      final params = RegisterViaQRCodeParams(qrCodeData: qrCodeData);
      final result = await registerUseCase(params);

      if (!mounted) return;

      result.fold(
        (success) => _handleRegistrationSuccess(success),
        (failure) => _handleRegistrationFailure(failure as AppFailure),
      );
    } catch (e) {
      _setErrorState('Erro ao registrar usuário: ${e.toString()}');
    }
  }

  /// Processa falha no parse do QR Code.
  void _handleQRCodeParseFailure(AppFailure failure) {
    _setErrorState(failure.toString());
  }

  /// Processa sucesso no registro.
  Future<void> _handleRegistrationSuccess(RegisterViaQRCodeSuccess success) async {
    if (!mounted) return;

    try {
      await _updateAuthStatus();
    } catch (e) {
      return; // _updateAuthStatus já chama _setErrorState
    }

    if (!mounted) return;

    _showSuccessMessage(success.message);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      _setProcessingState(false);
    }
  }

  /// Processa falha no registro.
  void _handleRegistrationFailure(AppFailure failure) {
    final errorMessage = failure is RegisterViaQRCodeFailure ? failure.userMessage : failure.userMessage;

    _setErrorState(errorMessage);
  }

  /// Processa erro crítico.
  void _handleCriticalError(dynamic error, StackTrace stackTrace) {
    _setErrorState('Erro crítico ao processar QR Code: ${error.toString()}');

    // Log do erro para debug
    debugPrint('Erro ao processar QR Code: $error');
    debugPrint('StackTrace: $stackTrace');
  }

  /// Atualiza o estado de processamento.
  void _setProcessingState(bool isProcessing) {
    if (mounted) {
      setState(() {
        _isProcessing = isProcessing;
        if (isProcessing) _errorMessage = null;
      });
    }
  }

  /// Define uma mensagem de erro e para o processamento.
  void _setErrorState(String errorMessage) {
    if (mounted) {
      setState(() {
        _errorMessage = errorMessage;
        _isProcessing = false;
      });
    }
  }

  /// Mostra mensagem de sucesso.
  void _showSuccessMessage(String message) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
      );
    } catch (e) {
      // Ignora erro ao mostrar snackbar
    }
  }

  /// Atualiza o status de autenticação.
  Future<void> _updateAuthStatus() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.checkAuthStatus();
    } catch (e) {
      _setErrorState('Erro ao atualizar autenticação: ${e.toString()}');
      rethrow;
    }
  }
}
