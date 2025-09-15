import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _welcomeMessage = 'Bem-vindo!';
  String _subtitleMessage = 'Selecione uma das opções abaixo para começar:';

  bool get isLoading => _isLoading;
  String get welcomeMessage => _welcomeMessage;
  String get subtitleMessage => _subtitleMessage;

  void updateWelcomeMessage(String message) {
    _welcomeMessage = message;
    notifyListeners();
  }

  void updateSubtitleMessage(String message) {
    _subtitleMessage = message;
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _isLoading = false;
    notifyListeners();
  }

  void navigateToFunctionality(String functionality) {
    debugPrint('Navegando para: $functionality');
  }
}
