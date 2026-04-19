import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';

class KeyboardToggleController {
  final FocusNode scanFocusNode;
  final BuildContext context;

  static const Duration _focusDelay = UIConstants.shortDelay;
  static const Duration _keyboardDelay = UIConstants.shortLoadingDelay;
  static const Duration _initialFocusDelay = UIConstants.slideInDuration;

  KeyboardToggleController({required this.scanFocusNode, required this.context});

  void enableKeyboardMode() {
    scanFocusNode.unfocus();

    unawaited(
      Future<void>.delayed(_focusDelay, () {
        if (context.mounted) {
          scanFocusNode.requestFocus();
          _forceKeyboardShow();
        }
      }).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha no delayed de foco (teclado)',
          tag: 'KeyboardToggleController',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void enableScannerMode() {
    _hideKeyboard();
    scanFocusNode.requestFocus();
  }

  void _forceKeyboardShow() {
    unawaited(
      Future<void>.delayed(_keyboardDelay, () {
        if (context.mounted) {
          try {
            SystemChannels.textInput.invokeMethod('TextInput.show');
          } catch (e) {
            unawaited(
              Future<void>.delayed(_focusDelay, () {
                if (context.mounted) {
                  scanFocusNode.requestFocus();
                }
              }).catchError((Object err, StackTrace st) {
                AppLogger.warning(
                  'Falha no delayed de fallback de foco (teclado)',
                  tag: 'KeyboardToggleController',
                  error: err,
                  stackTrace: st,
                );
              }),
            );
          }
        }
      }).catchError((Object e, StackTrace s) {
        AppLogger.warning(
          'Falha ao exibir teclado (delayed)',
          tag: 'KeyboardToggleController',
          error: e,
          stackTrace: s,
        );
      }),
    );
  }

  void _hideKeyboard() {
    try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    } catch (e) {
      FocusScope.of(context).unfocus();
    }
  }

  void requestInitialFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;

      scanFocusNode.requestFocus();

      unawaited(
        Future<void>.delayed(_initialFocusDelay, () {
          if (context.mounted) {
            scanFocusNode.requestFocus();
          }
        }).catchError((Object e, StackTrace s) {
          AppLogger.warning(
            'Falha no delayed de foco inicial',
            tag: 'KeyboardToggleController',
            error: e,
            stackTrace: s,
          );
        }),
      );
    });
  }

  void returnFocusToScanner() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        scanFocusNode.requestFocus();
      }
    });
  }

  void forceFocusAndCloseKeyboard() {
    _hideKeyboard();
    scanFocusNode.requestFocus();
  }
}
