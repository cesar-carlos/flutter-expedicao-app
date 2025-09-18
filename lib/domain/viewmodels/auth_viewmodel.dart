import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/usecases/login_user_usecase.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/services/user_session_service.dart';
import 'package:exp/di/locator.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, needsUserSelection }

class AuthViewModel extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _username = '';
  bool _isLoginLoading = false;
  AppUser? _currentUser;
  LoginUserUseCase? _loginUserUseCase;
  final _userSessionService = locator<UserSessionService>();
  final _userSystemRepository = locator<UserSystemRepository>();

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

    try {
      // Verificar se há uma sessão salva
      final savedUser = await _userSessionService.loadUserSession();

      if (savedUser != null) {
        _currentUser = savedUser;
        _username = savedUser.nome;
        _status = AuthStatus.authenticated;
        debugPrint('Usuário carregado da sessão: ${savedUser.nome}');

        // Carregar UserSystemModel se necessário
        await _ensureUserSystemModel();
      } else {
        _status = AuthStatus.unauthenticated;
        debugPrint('Nenhuma sessão salva encontrada');
      }
    } catch (e) {
      debugPrint('Erro ao verificar sessão salva: $e');
      _status = AuthStatus.unauthenticated;
    }

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

      // Salvar sessão do usuário
      await _userSessionService.saveUserSession(loginResponse.user);

      if (loginResponse.user.codUsuario == null) {
        _status = AuthStatus.needsUserSelection;
      } else {
        _status = AuthStatus.authenticated;

        // Carregar UserSystemModel se necessário
        await _ensureUserSystemModel();
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

    try {
      // Limpar sessão persistida
      await _userSessionService.clearUserSession();
      debugPrint('Sessão limpa com sucesso');
    } catch (e) {
      debugPrint('Erro ao limpar sessão: $e');
    }

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

  Future<void> updateUserAfterSelection(AppUser updatedUser) async {
    _currentUser = updatedUser;
    _status = AuthStatus.authenticated;

    // Salvar sessão atualizada
    await _userSessionService.saveUserSession(updatedUser).catchError((e) {
      debugPrint('Erro ao salvar sessão atualizada: $e');
    });

    // Carregar UserSystemModel se necessário
    await _ensureUserSystemModel();

    notifyListeners();
  }

  void cancelUserSelection() {
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  /// Carrega ou atualiza o userSystemModel do usuário atual
  Future<void> _ensureUserSystemModel() async {
    if (_currentUser?.userSystemModel != null) {
      // UserSystemModel já existe, não precisa carregar
      return;
    }

    if (_currentUser?.codUsuario == null) {
      // Não tem codUsuario, não pode carregar UserSystemModel
      return;
    }

    try {
      debugPrint('Carregando UserSystemModel para usuário: ${_currentUser!.codUsuario}');

      final userSystemModel = await _userSystemRepository.getUserById(_currentUser!.codUsuario!);

      if (userSystemModel != null) {
        // Atualizar o usuário com o UserSystemModel
        _currentUser = _currentUser!.copyWith(userSystemModel: userSystemModel);

        // Salvar a sessão atualizada
        await _userSessionService.saveUserSession(_currentUser!);

        debugPrint('UserSystemModel carregado com sucesso para: ${userSystemModel.nomeUsuario}');
      } else {
        debugPrint('UserSystemModel não encontrado para usuário: ${_currentUser!.codUsuario}');
      }
    } catch (e) {
      debugPrint('Erro ao carregar UserSystemModel: $e');
      // Não falha o login, apenas registra o erro
    }
  }
}
