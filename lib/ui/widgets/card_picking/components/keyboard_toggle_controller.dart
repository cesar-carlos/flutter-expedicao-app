import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:exp/core/constants/ui_constants.dart';

/// Controlador responsável por gerenciar o toggle entre modo scanner e teclado
///
/// Gerencia a alternância entre modo scanner (hardware) e modo teclado (manual),
/// controlando o foco e a visibilidade do teclado virtual.
class KeyboardToggleController {
  final FocusNode scanFocusNode;
  final BuildContext context;

  /// Delay para aguardar mudança de foco
  static const Duration _focusDelay = UIConstants.shortDelay;

  /// Delay para aguardar abertura do teclado
  static const Duration _keyboardDelay = UIConstants.shortLoadingDelay;

  /// Delay para garantir carregamento completo da tela
  static const Duration _initialFocusDelay = UIConstants.slideInDuration;

  KeyboardToggleController({required this.scanFocusNode, required this.context});

  /// Habilita modo teclado com abertura automática
  void enableKeyboardMode() {
    scanFocusNode.unfocus();

    Future.delayed(_focusDelay, () {
      if (context.mounted) {
        scanFocusNode.requestFocus();
        _forceKeyboardShow();
      }
    });
  }

  /// Habilita modo scanner com fechamento do teclado
  void enableScannerMode() {
    _hideKeyboard();

    Future.delayed(_focusDelay, () {
      if (context.mounted) {
        scanFocusNode.requestFocus();
      }
    });
  }

  /// Força a abertura do teclado
  void _forceKeyboardShow() {
    Future.delayed(_keyboardDelay, () {
      if (context.mounted) {
        try {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } catch (e) {
          // Fallback: tentar novamente
          Future.delayed(_focusDelay, () {
            if (context.mounted) {
              scanFocusNode.requestFocus();
            }
          });
        }
      }
    });
  }

  /// Esconde o teclado
  void _hideKeyboard() {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (e) {
      // Fallback: usar unfocus para fechar teclado
      FocusScope.of(context).unfocus();
    }
  }

  /// Solicita foco inicial no campo de scanner
  ///
  /// Usa dois pedidos de foco sequenciais para garantir que o campo
  /// esteja focado mesmo em telas que ainda estão carregando.
  void requestInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      scanFocusNode.requestFocus();

      // Garantir foco após delay para telas que ainda estão carregando
      Future.delayed(_initialFocusDelay, () {
        if (context.mounted) {
          scanFocusNode.requestFocus();
        }
      });
    });
  }

  /// Retorna foco para o campo de scanner
  void returnFocusToScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        scanFocusNode.requestFocus();
      }
    });
  }
}
