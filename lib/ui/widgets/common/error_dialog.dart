import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/theme/app_text_styles.dart';
import 'package:data7_expedicao/core/theme/theme_extensions.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.error),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppFonts.inter(fontSize: 16, color: theme.isDark ? AppColors.light : AppColors.black87),
            ),
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.isDark ? colorScheme.surfaceContainerHighest : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.isDark ? colorScheme.outline.withValues(alpha: 0.3) : AppColors.grey300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.grey600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Detalhes técnicos:',
                          style: AppFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.grey700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(details!, style: AppTextStyles.code(context, color: AppColors.grey600)),
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
            style: TextButton.styleFrom(foregroundColor: theme.adaptivePrimary(colorScheme)),
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          icon: const Icon(Icons.close),
          label: const Text('Fechar'),
          style: TextButton.styleFrom(foregroundColor: AppColors.grey600),
        ),
      ],
    );
  }
}

class AppErrorType {
  static const String serverError = 'server_error';
  static const String connectionError = 'connection_error';
  static const String validationError = 'validation_error';
  static const String authenticationError = 'authentication_error';
  static const String notFoundError = 'not_found_error';
  static const String timeoutError = 'timeout_error';
  static const String unknownError = 'unknown_error';
}

extension ErrorDialogExtension on BuildContext {
  Future<void> showServerError(String message, {String? details, VoidCallback? onRetry, VoidCallback? onClose}) {
    return ErrorDialog.showServerError(this, message: message, details: details, onRetry: onRetry, onClose: onClose);
  }

  Future<void> showConnectionError({VoidCallback? onRetry, VoidCallback? onClose}) {
    return ErrorDialog.showConnectionError(this, onRetry: onRetry, onClose: onClose);
  }

  Future<void> showGenericError(String message, {String? details, VoidCallback? onClose}) {
    return ErrorDialog.showGenericError(this, message: message, details: details, onClose: onClose);
  }

  Future<void> showValidationError(String message, {String? details}) {
    return ErrorDialog.showValidationError(this, message: message, details: details);
  }
}
