import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/domain/models/scanner_data.dart';

/// ViewModel da tela livre de scan ([ScannerScreen]).
///
/// Tem propósito **diferente** do [BarcodeScannerService]:
/// - Aqui aceitamos **qualquer string** (alfanumérica, com símbolos),
///   pois a tela é usada para testar/debugar coletores antes da operação real.
/// - O [BarcodeScannerService] valida formato (regex 7–16 dígitos) e é usado
///   no fluxo de separação real, onde só dígitos fazem sentido.
///
/// Por isso esta ViewModel mantém debounce e validação próprios.
class ScannerViewModel extends ChangeNotifier {
  static const int _maxHistorySize = 50;
  static const Duration _debounceDuration = Duration(milliseconds: 150);

  String _scannedCode = "";
  final List<ScannerData> _scanHistory = [];
  bool _isProcessing = false;
  Timer? _debounceTimer;

  String get scannedCode => _scannedCode;
  List<ScannerData> get scanHistory => List.unmodifiable(_scanHistory);
  bool get hasCode => _scannedCode.isNotEmpty;

  void addCharacter(String character) {
    if (character.isNotEmpty) {
      _scannedCode += character;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, () {
        _processDebouncedInput();
      });

      notifyListeners();
    }
  }

  void _processDebouncedInput() {
    if (_scannedCode.isEmpty || _isProcessing) return;

    final cleanCode = _scannedCode.trim();

    if (cleanCode.isNotEmpty) {
      _addToHistory(cleanCode);
    }
  }

  void _addToHistory(String code) {
    if (code.isEmpty || _isProcessing) return;

    _isProcessing = true;

    if (_scanHistory.isNotEmpty && _scanHistory.first.code == code) {
      _isProcessing = false;
      return;
    }

    final scanData = ScannerData(code: code);
    _scanHistory.insert(0, scanData);

    // P4: removeLast() em vez de recriar a lista a cada bipagem.
    // Como inserimos no indice 0, o item mais antigo esta no fim.
    while (_scanHistory.length > _maxHistorySize) {
      _scanHistory.removeLast();
    }

    HapticFeedback.lightImpact();

    _scannedCode = "";

    notifyListeners();

    _isProcessing = false;
  }

  void processScannedCode() {
    if (_scannedCode.isNotEmpty) {
      _debounceTimer?.cancel();

      _processDebouncedInput();
    }
  }

  void forceProcessCurrentCode() {
    if (_scannedCode.isNotEmpty) {
      _debounceTimer?.cancel();

      final cleanCode = _scannedCode.trim();

      if (cleanCode.isNotEmpty) {
        _addToHistory(cleanCode);
      }
    }
  }

  /// Adiciona um código completo (modo broadcast)
  void addFullCode(String code) {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) return;
    _addToHistory(cleanCode);
  }

  void clearCurrentCode() {
    _scannedCode = "";
    notifyListeners();
  }

  void clearHistory() {
    _scanHistory.clear();
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _scanHistory.length) {
      _scanHistory.removeAt(index);
      notifyListeners();
    }
  }

  List<ScannerData> searchInHistory(String query) {
    if (query.isEmpty) return scanHistory;

    return _scanHistory.where((scan) => scan.code.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
