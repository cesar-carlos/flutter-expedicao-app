import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/di/locator.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/services/i_user_session_service.dart';
import 'package:data7_expedicao/domain/usecases/user/login_user_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error, needsUserSelection }

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required LoginUserUseCase loginUserUseCase,
    IUserSessionService? userSessionService,
    UserSystemRepository? userSystemRepository,
  }) : _loginUserUseCase = loginUserUseCase,
       _userSessionService = userSessionService ?? locator<IUserSessionService>(),
       _userSystemRepository = userSystemRepository ?? locator<UserSystemRepository>();

  AuthStatus _status = AuthStatus.initial;
  String _errorMessage = '';
  String _username = '';
  bool _isLoginLoading = false;
  AppUser? _currentUser;
  final LoginUserUseCase _loginUserUseCase;
  final IUserSessionService _userSessionService;
  final UserSystemRepository _userSystemRepository;

  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  String get username => _username;
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isLoginLoading => _isLoginLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get needsUserSelection => _status == AuthStatus.needsUserSelection;

  Future<void> checkAuthStatus() async {
    if (const bool.fromEnvironment('INTEGRATION_TEST', defaultValue: false)) {
      _status = AuthStatus.loading;
      notifyListeners();
      _status = AuthStatus.authenticated;
      _username = 'E2E User';
      _currentUser = AppUser(codLoginApp: 1, ativo: Situation.ativo, nome: 'E2E User', codUsuario: 1);
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final savedUser = await _userSessionService.loadUserSession();

      if (savedUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      _currentUser = savedUser;
      _username = savedUser.nome;

      if (_requiresUserSelection(savedUser)) {
        _status = AuthStatus.needsUserSelection;
      } else if (_hasCompleteSession(savedUser)) {
        _status = AuthStatus.authenticated;
        await _loadAndAttachUserSystemModel();
      } else {
        final loaded = await _loadAndAttachUserSystemModel();
        if (loaded) {
          _status = AuthStatus.authenticated;
        } else {
          await _clearPersistedIncompleteSession();
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e, s) {
      AppLogger.error('Falha ao verificar status de autenticacao', tag: 'AuthViewModel', error: e, stackTrace: s);
      _clearInMemorySession();
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    // Lock anti-race contra cliques rapidos no botao de login.
    if (_isLoginLoading) {
      return;
    }

    if (username.isEmpty || password.isEmpty) {
      _setError('Por favor, preencha todos os campos');
      notifyListeners();
      return;
    }

    if (password.length < 4) {
      _setError('Senha deve ter pelo menos 4 caracteres');
      notifyListeners();
      return;
    }

    _isLoginLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final params = LoginUserParams(nome: username, senha: password);
      final loginResponse = await _loginUserUseCase.call(params);

      _username = loginResponse.user.nome;
      _currentUser = loginResponse.user;

      if (_requiresUserSelection(loginResponse.user)) {
        await _userSessionService.saveUserSession(loginResponse.user);
        _status = AuthStatus.needsUserSelection;
      } else {
        final loaded = await _loadAndAttachUserSystemModel();
        if (loaded) {
          _status = AuthStatus.authenticated;
        } else {
          _clearInMemorySession();
          _setError('Nao foi possivel carregar os dados do usuario no sistema. Tente novamente.');
        }
      }

      if (_status != AuthStatus.error) {
        _errorMessage = '';
      }
    } on UserApiException catch (e) {
      if (e.statusCode == 401) {
        _setError('Credenciais invalidas');
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
      await _userSessionService.clearUserSession();
    } catch (e, s) {
      AppLogger.error('Falha ao limpar sessao no logout', tag: 'AuthViewModel', error: e, stackTrace: s);
    }

    await Future.delayed(const Duration(milliseconds: 500));

    _username = '';
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = '';
    notifyListeners();
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

    try {
      await _userSessionService.saveUserSession(updatedUser);
    } catch (e, s) {
      AppLogger.error('Falha ao salvar sessao apos selecao de usuario', tag: 'AuthViewModel', error: e, stackTrace: s);
    }

    await _loadAndAttachUserSystemModel();

    notifyListeners();
  }

  void cancelUserSelection() {
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> _loadAndAttachUserSystemModel() async {
    if (_currentUser?.codUsuario == null) {
      return false;
    }

    try {
      final userSystemModel = await _userSystemRepository.getUserById(_currentUser!.codUsuario!);

      if (userSystemModel == null) {
        AppLogger.warning(
          'UserSystemModel nao encontrado para codUsuario=${_currentUser!.codUsuario}',
          tag: 'AuthViewModel',
        );
        return false;
      }

      _currentUser = _currentUser!.copyWith(userSystemModel: userSystemModel);
      await _userSessionService.saveUserSession(_currentUser!);
      return true;
    } catch (e, s) {
      AppLogger.error('Erro ao carregar UserSystemModel', tag: 'AuthViewModel', error: e, stackTrace: s);
      return false;
    }
  }

  bool _requiresUserSelection(AppUser user) => user.codUsuario == null;

  bool _hasCompleteSession(AppUser user) => user.codUsuario != null && user.userSystemModel != null;

  void _setError(String message) {
    _errorMessage = message;
    _status = AuthStatus.error;
  }

  void _clearInMemorySession() {
    _username = '';
    _currentUser = null;
  }

  Future<void> _clearPersistedIncompleteSession() async {
    _clearInMemorySession();
    try {
      await _userSessionService.clearUserSession();
    } catch (e, s) {
      AppLogger.error(
        'Falha ao limpar sessao incompleta durante checkAuthStatus',
        tag: 'AuthViewModel',
        error: e,
        stackTrace: s,
      );
    }
  }
}
