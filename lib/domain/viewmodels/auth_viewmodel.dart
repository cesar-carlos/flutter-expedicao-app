import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:exp/domain/usecases/login_user_usecase.dart';
import 'package:exp/domain/models/user/user_models.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  needsUserSelection,
}

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _username = '';
  bool _isLoginLoading = false;
  AppUser? _currentUser;
  LoginUserUseCase? _loginUserUseCase;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get username => _username;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoginLoading => _isLoginLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get needsUserSelection => _status == AuthStatus.needsUserSelection;

  void initialize(LoginUserUseCase loginUserUseCase) {
    _loginUserUseCase = loginUserUseCase;
  }

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _setError('Por favor, preencha todos os campos');
      return;
    }

    if (password.length < 4) {
      _setError('Senha deve ter pelo menos 4 caracteres');
      return;
    }

    if (_loginUserUseCase == null) {
      _setError('Erro interno: LoginUserUseCase não inicializado');
      return;
    }

    _isLoginLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final params = LoginUserParams(nome: username, senha: password);
      final loginResponse = await _loginUserUseCase!.call(params);

      _username = loginResponse.user.nome;
      _currentUser = loginResponse.user;

      if (loginResponse.user.codUsuario == null) {
        _status = AuthStatus.needsUserSelection;
      } else {
        _status = AuthStatus.authenticated;
      }

      _errorMessage = '';
    } on UserApiException catch (e) {
      if (e.statusCode == 401) {
        _setError('Credenciais inválidas');
      } else if (e.isValidationError) {
        _setError(e.message);
      } else {
        _setError('Erro no servidor: ${e.message}');
      }
    } catch (e) {
      _setError('Erro inesperado: $e');
    }

    _isLoginLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _username = '';
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
  }

  void clearError() {
    _errorMessage = '';
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void updateUserAfterSelection(AppUser updatedUser) {
    _currentUser = updatedUser;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  void cancelUserSelection() {
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }
}
