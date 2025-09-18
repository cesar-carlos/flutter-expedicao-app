import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/user/app_user.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/core/utils/avatar_utils.dart';
import 'package:exp/di/locator.dart';

enum ProfileState { idle, loading, success, error }

/// ViewModel para gerenciar o estado da tela de perfil do usuário
class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthViewModel _authViewModel;
  final UserSessionService _userSessionService;

  ProfileViewModel(this._userRepository, this._authViewModel) : _userSessionService = locator<UserSessionService>();

  ProfileState _state = ProfileState.idle;
  String? _errorMessage;
  String? _successMessage;
  File? _selectedPhoto;
  bool _photoWasRemoved = false; // Rastreia se a foto foi removida explicitamente
  String? _currentPassword;
  String? _newPassword;
  String? _confirmPassword;
  bool _disposed = false;

  // Getters
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  File? get selectedPhoto => _selectedPhoto;
  bool get photoWasRemoved => _photoWasRemoved;
  AppUser? get currentUser => _authViewModel.currentUser;
  String? get currentPassword => _currentPassword;
  String? get newPassword => _newPassword;
  String? get confirmPassword => _confirmPassword;

  // Setters
  void setSelectedPhoto(File? photo) {
    _selectedPhoto = photo;
    // Se photo é null e o usuário tinha foto, marca como removida
    if (photo == null && currentUser?.hasPhoto == true) {
      _photoWasRemoved = true;
    } else {
      _photoWasRemoved = false;
    }
    _safeNotifyListeners();
  }

  void setCurrentPassword(String? password) {
    _currentPassword = password;
    // Limpar erro relacionado à senha quando usuário começar a digitar novamente
    if (_state == ProfileState.error &&
        (_errorMessage?.contains('Senha atual incorreta') == true ||
            _errorMessage?.contains('Por favor, informe a senha atual') == true)) {
      clearError();
    }
    _safeNotifyListeners();
  }

  void setNewPassword(String? password) {
    _newPassword = password;
    // Limpar erros relacionados à nova senha
    if (_state == ProfileState.error &&
        (_errorMessage?.contains('A nova senha deve ter pelo menos 4 caracteres') == true ||
            _errorMessage?.contains('Nova senha é obrigatória') == true)) {
      clearError();
    }
    _safeNotifyListeners();
  }

  void setConfirmPassword(String? password) {
    _confirmPassword = password;
    // Limpar erros relacionados à confirmação de senha
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

  /// Chama notifyListeners apenas se o viewModel não foi disposed
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

  /// Verifica se a foto foi removida explicitamente
  bool _hasPhotoBeenRemoved() {
    return _photoWasRemoved;
  }

  /// Valida se as senhas estão corretas (validação local)
  bool _validatePasswordsLocally() {
    // Se não há senha nova, não precisa validar
    if (_newPassword == null || _newPassword!.isEmpty) {
      return true;
    }

    // Se há senha nova, precisa da atual
    if (_currentPassword == null || _currentPassword!.isEmpty) {
      _setError('Por favor, informe a senha atual');
      return false;
    }

    // Validar tamanho da nova senha
    if (_newPassword!.length < 4) {
      _setError('A nova senha deve ter pelo menos 4 caracteres');
      return false;
    }

    // Validar confirmação da senha
    if (_confirmPassword != _newPassword) {
      _setError('A confirmação da senha não confere');
      return false;
    }

    return true;
  }

  /// Valida a senha atual com o servidor
  Future<bool> _validateCurrentPasswordWithServer() async {
    if (currentUser == null || _currentPassword == null || _currentPassword!.isEmpty) {
      return false;
    }

    try {
      return await _userRepository.validateCurrentPassword(nome: currentUser!.nome, currentPassword: _currentPassword!);
    } catch (e) {
      debugPrint('Erro ao validar senha atual: $e');
      return false;
    }
  }

  /// Salva as alterações do perfil
  Future<bool> saveProfile() async {
    if (currentUser == null) {
      _setError('Usuário não encontrado');
      return false;
    }

    // Validação local das senhas
    if (!_validatePasswordsLocally()) {
      return false;
    }

    _setState(ProfileState.loading);

    // Se há mudança de senha, validar a senha atual com o servidor
    final hasPasswordChange = _newPassword != null && _newPassword!.isNotEmpty;

    if (hasPasswordChange) {
      final isCurrentPasswordValid = await _validateCurrentPasswordWithServer();
      if (!isCurrentPasswordValid) {
        _setError('Senha atual incorreta');
        return false;
      }
    }

    try {
      // Preparar os dados do usuário atualizado
      String? photoBase64;

      // Se há uma nova foto selecionada, converte para base64
      if (_selectedPhoto != null) {
        photoBase64 = await AvatarUtils.convertImageToBase64(_selectedPhoto!);
        if (photoBase64 == null) {
          _setError('Erro ao processar a imagem');
          return false;
        }
      } else {
        // Se selectedPhoto foi definido como null explicitamente, remove a foto
        // Caso contrário, mantém a foto atual
        if (_hasPhotoBeenRemoved()) {
          photoBase64 = null; // Remove a foto
        } else {
          photoBase64 = currentUser!.fotoUsuario; // Mantém foto atual
        }
      }

      // Criar o usuário atualizado mantendo os dados do sistema
      final updatedUser = currentUser!.copyWith(
        fotoUsuario: photoBase64,
        senha: hasPasswordChange ? _newPassword : null,
      );

      // Chamar o repositório para atualizar
      final result = await _userRepository.putAppUser(updatedUser);

      // Criar usuário final sem senha para segurança
      final finalUser = currentUser!.copyWith(
        codLoginApp: result.codLoginApp,
        nome: result.nome,
        ativo: result.ativo,
        codUsuario: result.codUsuario,
        fotoUsuario: photoBase64,
        senha: null, // Remove senha por segurança
      );

      // Atualizar no AuthViewModel e persistir na sessão
      await _authViewModel.updateUserAfterSelection(finalUser);
      await _userSessionService.saveUserSession(finalUser);

      // Definir mensagem de sucesso baseada nas alterações feitas
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

  /// Limpa o formulário após sucesso
  void _clearForm() {
    _selectedPhoto = null;
    _photoWasRemoved = false;
    _currentPassword = null;
    _newPassword = null;
    _confirmPassword = null;
    _successMessage = null;
    _safeNotifyListeners();
  }

  /// Reset do estado para idle
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
