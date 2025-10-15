import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exp/domain/models/scanner_data.dart';

class ScannerViewModel extends ChangeNotifier {
  String _scannedCode = "";
  List<ScannerData> _scanHistory = [];
  bool _isProcessing = false; // Flag para evitar processamento simultâneo
  Timer? _debounceTimer; // Timer próprio para debounce

  String get scannedCode => _scannedCode;
  List<ScannerData> get scanHistory => List.unmodifiable(_scanHistory);
  bool get hasCode => _scannedCode.isNotEmpty;

  void addCharacter(String character) {
    if (character.isNotEmpty) {
      print('ScannerViewModel: Adicionando caractere "$character", código atual: "$_scannedCode"');
      _scannedCode += character;

      // Cancelar timer anterior e agendar novo
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 150), () {
        _processDebouncedInput();
      });

      notifyListeners();
    }
  }

  /// Processa entrada após debounce - scanner parou de enviar
  void _processDebouncedInput() {
    if (_scannedCode.isEmpty || _isProcessing) return;

    print('ScannerViewModel: Processando entrada após debounce: "$_scannedCode"');

    // Limpar caracteres especiais (Enter, Tab, etc)
    final cleanCode = _scannedCode.replaceAll(RegExp(r'[^\d]'), '');

    // Processar qualquer código não vazio (sem validação de quantidade)
    if (cleanCode.isNotEmpty) {
      print('ScannerViewModel: Adicionando código à história: "$cleanCode" (${cleanCode.length} dígitos)');
      _addToHistory(cleanCode);
    }
  }

  void _addToHistory(String code) {
    if (code.isEmpty || _isProcessing) return;

    _isProcessing = true;

    // Verificar se o último código adicionado é o mesmo (evitar duplicatas)
    if (_scanHistory.isNotEmpty && _scanHistory.first.code == code) {
      print('ScannerViewModel: Código duplicado ignorado: "$code"');
      _isProcessing = false;
      return;
    }

    print('ScannerViewModel: Adicionando à história: "$code"');
    final scanData = ScannerData(code: code);
    _scanHistory.insert(0, scanData);

    if (_scanHistory.length > 50) {
      _scanHistory = _scanHistory.take(50).toList();
    }

    // Fornecer feedback tátil
    HapticFeedback.lightImpact();

    // Limpar código atual
    _scannedCode = "";

    // Notificar listeners
    print('ScannerViewModel: Notificando listeners - Total de leituras: ${_scanHistory.length}');
    notifyListeners();

    _isProcessing = false;
  }

  void processScannedCode() {
    if (_scannedCode.isNotEmpty) {
      // Cancelar debounce timer
      _debounceTimer?.cancel();

      // Processar imediatamente
      _processDebouncedInput();
    }
  }

  /// Força o processamento do código atual (útil para códigos que ficaram na "Última Leitura")
  void forceProcessCurrentCode() {
    if (_scannedCode.isNotEmpty) {
      print('ScannerViewModel: Forçando processamento do código: "$_scannedCode"');

      // Cancelar debounce timer
      _debounceTimer?.cancel();

      // Limpar caracteres especiais (Enter, Tab, etc)
      final cleanCode = _scannedCode.replaceAll(RegExp(r'[^\d]'), '');

      // Processar qualquer código não vazio
      if (cleanCode.isNotEmpty) {
        print('ScannerViewModel: Forçando adição à história: "$cleanCode"');
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
