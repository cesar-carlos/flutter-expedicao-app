import 'package:flutter/material.dart';

class PickingScanState extends ChangeNotifier {
  bool _enabled = true;
  bool get enabled => _enabled;

  bool _keyboardEnabled = false;
  bool get keyboardEnabled => _keyboardEnabled;

  bool _isProcessingScan = false;
  bool get isProcessingScan => _isProcessingScan;

  bool _disposed = false;
  bool get disposed => _disposed;

  void setEnabled(bool value) {
    if (_disposed || _enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  void toggleKeyboard() {
    if (_disposed) return;

    _keyboardEnabled = !_keyboardEnabled;
    notifyListeners();
  }

  void setKeyboardEnabled(bool enabled) {
    if (_disposed || _keyboardEnabled == enabled) return;

    _keyboardEnabled = enabled;
    notifyListeners();
  }

  void startProcessing() {
    if (_disposed || _isProcessingScan) return;

    _isProcessingScan = true;
    notifyListeners();
  }

  /// Tenta marcar como "em processamento" de forma atomica.
  ///
  /// Retorna `true` se conseguiu adquirir o lock (estado mudou para true),
  /// ou `false` se ja estava em processamento.
  ///
  /// Use este metodo em call-sites concorrentes (ex.: broadcast Intents
  /// chegando em sequencia rapida) para evitar dupla execucao do mesmo scan.
  bool tryStartProcessing() {
    if (_disposed || _isProcessingScan) return false;

    _isProcessingScan = true;
    notifyListeners();
    return true;
  }

  void stopProcessing() {
    if (_disposed || !_isProcessingScan) return;

    _isProcessingScan = false;
    notifyListeners();
  }

  void forceUpdate() {
    if (_disposed) return;
    notifyListeners();
  }

  bool get canModifyState => !_disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
