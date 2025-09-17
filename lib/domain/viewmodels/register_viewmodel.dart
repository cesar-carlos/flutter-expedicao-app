import 'dart:io';
import 'package:flutter/material.dart';

import 'package:exp/core/constants/app_strings.dart';
import 'package:exp/domain/usecases/register_user_usecase.dart';
import 'package:exp/domain/models/user/user_models.dart';

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
      setError('${AppStrings.registerError}: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool validateForm({required String name, required String password, required String confirmPassword}) {
    clearError();

    if (name.trim().isEmpty) {
      setError(AppStrings.nameRequired);
      return false;
    }

    if (name.trim().length > 30) {
      setError(AppStrings.nameMaxLength);
      return false;
    }

    if (password.isEmpty) {
      setError(AppStrings.passwordRequired);
      return false;
    }

    if (password.length < 4) {
      setError(AppStrings.passwordMinLength);
      return false;
    }

    if (password.length > 60) {
      setError(AppStrings.passwordMaxLength);
      return false;
    }

    if (confirmPassword.isEmpty) {
      setError(AppStrings.confirmPasswordRequired);
      return false;
    }

    if (password != confirmPassword) {
      setError(AppStrings.passwordsDoNotMatch);
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
