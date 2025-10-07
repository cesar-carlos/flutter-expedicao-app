import 'package:flutter/material.dart';

/// Estado local da tela de picking para gerenciamento via Provider
///
/// Responsabilidades:
/// - Gerenciar estado do modo teclado/scanner
/// - Controlar estado de processamento de scan
/// - Evitar problemas de setState após dispose
/// - Melhorar reatividade da UI
class PickingScanState extends ChangeNotifier {
  // === ESTADO DA UI ===

  /// Indica se o modo teclado manual está ativo (vs modo scanner)
  bool _keyboardEnabled = false;
  bool get keyboardEnabled => _keyboardEnabled;

  /// Bloqueia o campo durante processamento para evitar scans duplicados
  bool _isProcessingScan = false;
  bool get isProcessingScan => _isProcessingScan;

  /// Indica se o widget foi descartado
  bool _disposed = false;
  bool get disposed => _disposed;

  // === MÉTODOS DE CONTROLE DE ESTADO ===

  /// Alterna entre modo scanner e teclado
  void toggleKeyboard() {
    if (_disposed) return;

    _keyboardEnabled = !_keyboardEnabled;
    notifyListeners();
  }

  /// Define o estado do modo teclado
  void setKeyboardEnabled(bool enabled) {
    if (_disposed || _keyboardEnabled == enabled) return;

    _keyboardEnabled = enabled;
    notifyListeners();
  }

  /// Inicia o processamento de scan
  void startProcessing() {
    if (_disposed || _isProcessingScan) return;

    _isProcessingScan = true;
    notifyListeners();
  }

  /// Finaliza o processamento de scan
  void stopProcessing() {
    if (_disposed || !_isProcessingScan) return;

    _isProcessingScan = false;
    notifyListeners();
  }

  /// Força uma atualização do estado (útil para inicialização)
  void forceUpdate() {
    if (_disposed) return;
    notifyListeners();
  }

  /// Verifica se o estado pode ser modificado
  bool get canModifyState => !_disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
