import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/user/app_user.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/data/services/user_session_service.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/core/utils/avatar_utils.dart';

enum ProfileState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;
  final UserSessionService _userSessionService;

  ProfileViewModel(this._userRepository, this._authViewModel) : _userSessionService = locator<UserSessionService>();

  ProfileState _state = ProfileState.idle;
  String? _errorMessage;
  String? _successMessage;
  File? _selectedPhoto;
  bool _photoWasRemoved = false;
  String? _currentPassword;
  String? _newPassword;
  String? _confirmPassword;
  bool _disposed = false;

  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  File? get selectedPhoto => _selectedPhoto;
  bool get photoWasRemoved => _photoWasRemoved;
  AppUser? get currentUser => _authViewModel.currentUser;
  String? get currentPassword => _currentPassword;
  String? get newPassword => _newPassword;
  String? get confirmPassword => _confirmPassword;

  void setSelectedPhoto(File? photo) {
    _selectedPhoto = photo;

    if (photo == null && currentUser?.hasPhoto == true) {
      _photoWasRemoved = true;
    } else {
      _photoWasRemoved = false;
    }
    _safeNotifyListeners();
  }

  void setCurrentPassword(String? password) {
    _currentPassword = password;

    if (_state == ProfileState.error &&
        (_errorMessage?.contains('Senha atual incorreta') == true ||
            _errorMessage?.contains('Por favor, informe a senha atual') == true)) {
      clearError();
    }
    _safeNotifyListeners();
  }

  void setNewPassword(String? password) {
    _newPassword = password;

    if (_state == ProfileState.error &&
        (_errorMessage?.contains('A nova senha deve ter pelo menos 4 caracteres') == true ||
            _errorMessage?.contains('Nova senha é obrigatória') == true)) {
      clearError();
    }
    _safeNotifyListeners();
  }

  void setConfirmPassword(String? password) {
    _confirmPassword = password;

    if (_state == ProfileState.error &&
        (_errorMessage?.contains('A confirmação da senha não confere') == true ||
            _errorMessage?.contains('Confirmação da nova senha é obrigatória') == true)) {
      clearError();
    }
    _safeNotifyListeners();
  }

  void _setState(ProfileState newState) {
    _state = newState;
    _safeNotifyListeners();
  }

  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(ProfileState.error);
  }

  void clearError() {
    _errorMessage = null;
    if (_state == ProfileState.error) {
      _setState(ProfileState.idle);
    }
  }

  bool _hasPhotoBeenRemoved() {
    return _photoWasRemoved;
  }

  bool _validatePasswordsLocally() {
    if (_newPassword == null || _newPassword!.isEmpty) {
      return true;
    }

    if (_currentPassword == null || _currentPassword!.isEmpty) {
      _setError('Por favor, informe a senha atual');
      return false;
    }

    if (_newPassword!.length < 4) {
      _setError('A nova senha deve ter pelo menos 4 caracteres');
      return false;
    }

    if (_confirmPassword != _newPassword) {
      _setError('A confirmação da senha não confere');
      return false;
    }

    return true;
  }

  Future<bool> _validateCurrentPasswordWithServer() async {
    if (currentUser == null || _currentPassword == null || _currentPassword!.isEmpty) {
      return false;
    }

    try {
      return await _userRepository.validateCurrentPassword(nome: currentUser!.nome, currentPassword: _currentPassword!);
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveProfile() async {
    if (currentUser == null) {
      _setError('Usuário não encontrado');
      return false;
    }

    if (!_validatePasswordsLocally()) {
      return false;
    }

    _setState(ProfileState.loading);

    final hasPasswordChange = _newPassword != null && _newPassword!.isNotEmpty;

    if (hasPasswordChange) {
      final isCurrentPasswordValid = await _validateCurrentPasswordWithServer();
      if (!isCurrentPasswordValid) {
        _setError('Senha atual incorreta');
        return false;
      }
    }

    try {
      String? photoBase64;

      if (_selectedPhoto != null) {
        photoBase64 = await AvatarUtils.convertImageToBase64(_selectedPhoto!);
        if (photoBase64 == null) {
          _setError('Erro ao processar a imagem');
          return false;
        }
      } else {
        if (_hasPhotoBeenRemoved()) {
          photoBase64 = null;
        } else {
          photoBase64 = currentUser!.fotoUsuario;
        }
      }

      final updatedUser = currentUser!.copyWith(
        fotoUsuario: photoBase64,
        senha: hasPasswordChange ? _newPassword : null,
      );

      final result = await _userRepository.putAppUser(updatedUser);

      final finalUser = currentUser!.copyWith(
        codLoginApp: result.codLoginApp,
        nome: result.nome,
        ativo: result.ativo,
        codUsuario: result.codUsuario,
        fotoUsuario: photoBase64,
        senha: null,
      );

      await _authViewModel.updateUserAfterSelection(finalUser);
      await _userSessionService.saveUserSession(finalUser);

      if (hasPasswordChange) {
        _successMessage = 'Perfil e senha atualizados com sucesso!';
      } else {
        _successMessage = 'Perfil atualizado com sucesso!';
      }

      _setState(ProfileState.success);
      _clearForm();
      return true;
    } catch (e) {
      _setError('Erro ao salvar perfil: ${e.toString()}');
      return false;
    }
  }

  void _clearForm() {
    _selectedPhoto = null;
    _photoWasRemoved = false;
    _currentPassword = null;
    _newPassword = null;
    _confirmPassword = null;
    _successMessage = null;
    _safeNotifyListeners();
  }

  void resetState() {
    _setState(ProfileState.idle);
    _errorMessage = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
