import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _welcomeMessage = 'Bem-vindo!';
  String _subtitleMessage = 'Selecione uma das opções abaixo para começar:';
  bool _disposed = false;

  bool get isLoading => _isLoading;
  String get welcomeMessage => _welcomeMessage;
  String get subtitleMessage => _subtitleMessage;

  void updateWelcomeMessage(String message) {
    if (_disposed) return;
    _welcomeMessage = message;
    notifyListeners();
  }

  void updateSubtitleMessage(String message) {
    if (_disposed) return;
    _subtitleMessage = message;
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    if (_disposed) return;
    _isLoading = false;
    notifyListeners();
  }

  void navigateToFunctionality(String functionality) {
    if (_disposed) return;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
