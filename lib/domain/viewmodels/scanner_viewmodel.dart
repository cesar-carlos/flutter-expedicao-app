import 'package:flutter/material.dart';
import 'package:exp/domain/models/scanner_data.dart';

class ScannerViewModel extends ChangeNotifier {
  String _scannedCode = "";
  List<ScannerData> _scanHistory = [];
  String get scannedCode => _scannedCode;
  List<ScannerData> get scanHistory => List.unmodifiable(_scanHistory);
  bool get hasCode => _scannedCode.isNotEmpty;

  void addCharacter(String character) {
    if (character.isNotEmpty) {
      _scannedCode += character;
      notifyListeners();
    }
  }

  void processScannedCode() {
    if (_scannedCode.isNotEmpty) {
      final scanData = ScannerData(code: _scannedCode);
      _scanHistory.insert(0, scanData);

      if (_scanHistory.length > 50) {
        _scanHistory = _scanHistory.take(50).toList();
      }

      debugPrint("Código processado: $_scannedCode");
      notifyListeners();
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

    return _scanHistory
        .where((scan) => scan.code.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
