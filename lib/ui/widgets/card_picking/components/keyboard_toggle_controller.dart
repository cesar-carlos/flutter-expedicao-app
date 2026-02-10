import 'dart:async' show Future;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/core/constants/ui_constants.dart';

class KeyboardToggleController {
  final FocusNode scanFocusNode;
  final BuildContext context;

  static const Duration _focusDelay = UIConstants.shortDelay;
  static const Duration _keyboardDelay = UIConstants.shortLoadingDelay;
  static const Duration _initialFocusDelay = UIConstants.slideInDuration;

  KeyboardToggleController({required this.scanFocusNode, required this.context});

  void enableKeyboardMode() {
    scanFocusNode.unfocus();

    Future.delayed(_focusDelay, () {
      if (context.mounted) {
        scanFocusNode.requestFocus();
        _forceKeyboardShow();
      }
    });
  }

  void enableScannerMode() {
    _hideKeyboard();
    scanFocusNode.requestFocus();
  }

  void _forceKeyboardShow() {
    Future.delayed(_keyboardDelay, () {
      if (context.mounted) {
        try {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        } catch (e) {
          Future.delayed(_focusDelay, () {
            if (context.mounted) {
              scanFocusNode.requestFocus();
            }
          });
        }
      }
    });
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

      Future.delayed(_initialFocusDelay, () {
        if (context.mounted) {
          scanFocusNode.requestFocus();
        }
      });
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
