import 'dart:io';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/domain/usecases/user/register_user_usecase.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';

class RegisterViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  File? _profileImage;
  RegisterUserUseCase? _registerUserUseCase;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  File? get profileImage => _profileImage;

  void initialize(RegisterUserUseCase registerUserUseCase) {
    _registerUserUseCase = registerUserUseCase;
  }

  void setProfileImage(File? image) {
    _profileImage = image;
    notifyListeners();
  }

  void removeProfileImage() {
    _profileImage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String password,
    required String confirmPassword,
    File? profileImage,
  }) async {
    if (!validateForm(name: name, password: password, confirmPassword: confirmPassword)) {
      return false;
    }

    if (_registerUserUseCase == null) {
      setError('UseCase não disponível');
      return false;
    }

    _isLoading = true;
    clearError();
    notifyListeners();

    try {
      final params = RegisterUserParams(nome: name.trim(), senha: password, profileImage: profileImage);

      await _registerUserUseCase!.call(params);

      return true;
    } on UserApiException catch (e) {
      setError(e.message);
      return false;
    } catch (e) {
      setError('Erro ao criar conta: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool validateForm({required String name, required String password, required String confirmPassword}) {
    clearError();

    if (name.trim().isEmpty) {
      setError('Por favor, digite seu nome');
      return false;
    }

    if (name.trim().length > 30) {
      setError('Nome deve ter no máximo 30 caracteres');
      return false;
    }

    if (password.isEmpty) {
      setError('Por favor, digite sua senha');
      return false;
    }

    if (password.length < 4) {
      setError('A senha deve ter pelo menos 4 caracteres');
      return false;
    }

    if (password.length > 60) {
      setError('Senha deve ter no máximo 60 caracteres');
      return false;
    }

    if (confirmPassword.isEmpty) {
      setError('Por favor, confirme sua senha');
      return false;
    }

    if (password != confirmPassword) {
      setError('As senhas não coincidem');
      return false;
    }

    return true;
  }

  void reset() {
    _isLoading = false;
    _errorMessage = '';
    _profileImage = null;
    notifyListeners();
  }
}
