import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:data7_expedicao/domain/models/scanner_data.dart';

class ScannerViewModel extends ChangeNotifier {
  String _scannedCode = "";
  List<ScannerData> _scanHistory = [];
  bool _isProcessing = false;
  Timer? _debounceTimer;

  String get scannedCode => _scannedCode;
  List<ScannerData> get scanHistory => List.unmodifiable(_scanHistory);
  bool get hasCode => _scannedCode.isNotEmpty;

  void addCharacter(String character) {
    if (character.isNotEmpty) {
      _scannedCode += character;

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 150), () {
        _processDebouncedInput();
      });

      notifyListeners();
    }
  }

  void _processDebouncedInput() {
    if (_scannedCode.isEmpty || _isProcessing) return;

    final cleanCode = _scannedCode.replaceAll(RegExp(r'[^\d]'), '');

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

    if (_scanHistory.length > 50) {
      _scanHistory = _scanHistory.take(50).toList();
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

      final cleanCode = _scannedCode.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCode.isNotEmpty) {
        _addToHistory(cleanCode);
      }
    }
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
