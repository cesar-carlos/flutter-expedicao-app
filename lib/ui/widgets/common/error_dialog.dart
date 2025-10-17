import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final bool showRetryButton;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.details,
    this.onRetry,
    this.onClose,
    this.showRetryButton = false,
  });

  /// Método estático para exibir o diálogo de erro do servidor
  static Future<void> showServerError(
    BuildContext context, {
    required String message,
    String? details,
    VoidCallback? onRetry,
    VoidCallback? onClose,
    bool showRetryButton = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: 'Erro do Servidor',
          message: message,
          details: details,
          onRetry: onRetry,
          onClose: onClose,
          showRetryButton: showRetryButton,
        );
      },
    );
  }

  /// Método estático para exibir erro de conexão
  static Future<void> showConnectionError(BuildContext context, {VoidCallback? onRetry, VoidCallback? onClose}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: 'Erro de Conexão',
          message:
              'Não foi possível conectar ao servidor. '
              'Verifique sua conexão com a internet e tente novamente.',
          onRetry: onRetry,
          onClose: onClose,
          showRetryButton: true,
        );
      },
    );
  }

  /// Método estático para exibir erro genérico
  static Future<void> showGenericError(
    BuildContext context, {
    required String message,
    String? details,
    VoidCallback? onClose,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ErrorDialog(title: 'Erro', message: message, details: details, onClose: onClose, showRetryButton: false);
      },
    );
  }

  /// Método estático para exibir erro de validação
  static Future<void> showValidationError(BuildContext context, {required String message, String? details}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ErrorDialog(title: 'Dados Inválidos', message: message, details: details, showRetryButton: false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Detalhes técnicos:',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      details!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (showRetryButton && onRetry != null)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          icon: const Icon(Icons.close),
          label: const Text('Fechar'),
          style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
        ),
      ],
    );
  }
}

/// Classe para padronizar tipos de erro comuns
class AppErrorType {
  static const String serverError = 'server_error';
  static const String connectionError = 'connection_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String notFoundError = 'not_found_error';
  static const String timeoutError = 'timeout_error';
  static const String unknownError = 'unknown_error';
}

/// Extensão para facilitar o uso do ErrorDialog
extension ErrorDialogExtension on BuildContext {
  /// Exibe erro do servidor
  Future<void> showServerError(String message, {String? details, VoidCallback? onRetry, VoidCallback? onClose}) {
    return ErrorDialog.showServerError(this, message: message, details: details, onRetry: onRetry, onClose: onClose);
  }

  /// Exibe erro de conexão
  Future<void> showConnectionError({VoidCallback? onRetry, VoidCallback? onClose}) {
    return ErrorDialog.showConnectionError(this, onRetry: onRetry, onClose: onClose);
  }

  /// Exibe erro genérico
  Future<void> showGenericError(String message, {String? details, VoidCallback? onClose}) {
    return ErrorDialog.showGenericError(this, message: message, details: details, onClose: onClose);
  }

  /// Exibe erro de validação
  Future<void> showValidationError(String message, {String? details}) {
    return ErrorDialog.showValidationError(this, message: message, details: details);
  }
}
