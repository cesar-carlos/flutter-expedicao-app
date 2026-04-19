import 'dart:async';
import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/domain/repositories/user_system_repository.dart';
import 'package:data7_expedicao/domain/repositories/user_repository.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/ui/widgets/common/index.dart';

enum UserSelectionState { initial, loading, loaded, selecting, selected }

class UserSelectionViewModel extends ChangeNotifier {
  final UserSystemRepository _userSystemRepository;
  final UserRepository _userRepository;
  BuildContext? _context;
  bool _disposed = false;

  UserSelectionViewModel(this._userSystemRepository, this._userRepository);

  void setContext(BuildContext context) {
    _context = context;
  }

  /// Bug DDDD: BuildContext armazenado em ViewModel e anti-pattern. Como
  /// refatorar tudo seria GRANDE (quebra a API publica), no minimo
  /// validamos `mounted` antes de cada uso para evitar:
  /// - Erros "Looking up a deactivated widget's ancestor is unsafe"
  /// - Crashes ao mostrar SnackBar/dialog em widget ja removido
  /// - Memory leaks por reter referencia a tree morta.
  BuildContext? get _safeContext {
    final ctx = _context;
    if (ctx == null) return null;
    if (!ctx.mounted) {
      _context = null;
      return null;
    }
    return ctx;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  UserSelectionState _state = UserSelectionState.initial;
  List<UserSystemModel> _users = [];
  UserSystemModel? _selectedUser;
  AppUser? _currentAppUser;
  String? _errorMessage;
  String _searchQuery = '';

  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 0;
  final int _pageLimit = 20;
  bool _isSearchMode = false;

  Timer? _searchTimer;
  bool _isWaitingForSearch = false;
  static const Duration _searchDebounceTime = Duration(milliseconds: 500);

  UserSelectionState get state => _state;
  List<UserSystemModel> get users => _users;
  UserSystemModel? get selectedUser => _selectedUser;
  AppUser? get currentAppUser => _currentAppUser;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get isSearchMode => _isSearchMode;
  bool get isWaitingForSearch => _isWaitingForSearch;
  int get currentPage => _currentPage;

  List<UserSystemModel> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users.where((user) => user.nomeUsuario.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  bool isUserAvailable(UserSystemModel user) {
    return user.codLoginApp == null;
  }

  void initialize(AppUser appUser) {
    _currentAppUser = appUser;
    _safeNotify();
  }

  Future<void> searchUsers(String nome) async {
    if (_disposed) return;
    if (nome.trim().isEmpty) {
      _clearUsers();
      return;
    }

    _setState(UserSelectionState.loading);
    _errorMessage = null;
    _isSearchMode = true;
    _resetPagination();

    try {
      final pagination = Pagination.create(limit: 50, offset: 0, page: 1);
      final response = await _userSystemRepository.searchUsersByName(
        nome,
        apenasAtivos: Situation.ativo,
        pagination: pagination,
      );
      if (_disposed) return;

      if (response.success && response.users.isNotEmpty) {
        _users = response.users;
        _hasMoreData = false;
        _setState(UserSelectionState.loaded);
      } else {
        _users = [];
        _setState(UserSelectionState.loaded);
        _safeContext?.showServerError(
          response.message ?? 'Nenhum usuário encontrado',
          onRetry: () => searchUsers(nome),
        );
      }
    } catch (e, s) {
      if (_disposed) return;
      AppLogger.warning('Erro ao buscar usuarios', tag: 'UserSelectionVM', error: e, stackTrace: s);
      _users = [];
      _setState(UserSelectionState.loaded);
      _safeContext?.showServerError('Erro ao buscar usuários', details: e.toString(), onRetry: () => searchUsers(nome));
    }
  }

  Future<void> loadAllUsers() async {
    if (_disposed) return;
    _setState(UserSelectionState.loading);
    _errorMessage = null;
    _isSearchMode = false;
    _resetPagination();

    try {
      final pagination = Pagination.create(limit: _pageLimit, offset: 0, page: 1);
      final response = await _userSystemRepository.getUsers(apenasAtivos: Situation.ativo, pagination: pagination);
      if (_disposed) return;

      if (response.success) {
        _users = response.users;
        _currentPage = 1;
        _hasMoreData = response.users.length == _pageLimit;
        _setState(UserSelectionState.loaded);
      } else {
        _users = [];
        _setState(UserSelectionState.loaded);
        _safeContext?.showServerError(response.message ?? 'Nenhum usuário encontrado', onRetry: loadAllUsers);
      }
    } catch (e, s) {
      if (_disposed) return;
      AppLogger.warning('Erro ao carregar usuarios', tag: 'UserSelectionVM', error: e, stackTrace: s);
      _users = [];
      _setState(UserSelectionState.loaded);
      _safeContext?.showServerError('Erro ao carregar usuários', details: e.toString(), onRetry: loadAllUsers);
    }
  }

  Future<void> loadMoreUsers() async {
    if (_disposed || _isLoadingMore || !_hasMoreData || _isSearchMode) {
      return;
    }

    _isLoadingMore = true;
    _safeNotify();

    try {
      final pagination = Pagination.create(
        limit: _pageLimit,
        offset: _currentPage * _pageLimit,
        page: _currentPage + 1,
      );
      final response = await _userSystemRepository.getUsers(apenasAtivos: Situation.ativo, pagination: pagination);
      if (_disposed) return;

      if (response.success) {
        final Set<int> existingUserCodes = _users.map((u) => u.codUsuario).toSet();
        final List<UserSystemModel> newUsers = response.users
            .where((user) => !existingUserCodes.contains(user.codUsuario))
            .toList();

        _users.addAll(newUsers);
        _currentPage++;
        _hasMoreData = response.users.length == _pageLimit;
      } else {
        _hasMoreData = false;
      }
    } catch (e, s) {
      if (_disposed) return;
      // Bug GGGG: antes era catch silencioso. Falha em paginacao
      // virava `hasMoreData = false` sem nenhum log — usuario perdia
      // acesso ao resto da lista sem entender o motivo.
      AppLogger.warning('Erro em loadMoreUsers (pagina ${_currentPage + 1})', tag: 'UserSelectionVM', error: e, stackTrace: s);
      _hasMoreData = false;
    }

    if (_disposed) return;
    _isLoadingMore = false;
    _safeNotify();
  }

  void updateSearchQuery(String query) {
    if (_disposed) return;
    _searchQuery = query;
    _searchTimer?.cancel();

    if (query.trim().isNotEmpty) {
      _isWaitingForSearch = true;
    } else {
      _isWaitingForSearch = false;
    }

    _safeNotify();
    _searchTimer = Timer(_searchDebounceTime, () {
      // Timer pode disparar 500ms apos dispose.
      if (_disposed) return;
      _performDebouncedSearch(query);
    });
  }

  void _performDebouncedSearch(String query) {
    if (_disposed) return;
    _isWaitingForSearch = false;

    if (query.trim().isEmpty) {
      _clearUsers();
    } else {
      // searchUsers e fire-and-forget aqui (mesmo padrao da UI),
      // porem a propria searchUsers ja loga erros via AppLogger.
      unawaited(searchUsers(query));
    }
  }

  void selectUser(UserSystemModel user) {
    if (!isUserAvailable(user)) {
      _safeContext?.showValidationError(
        'Usuário não disponível',
        details: 'Este usuário já está vinculado a outro dispositivo (ID: ${user.codLoginApp})',
      );
      return;
    }

    _selectedUser = user;
    _setState(UserSelectionState.loaded);
  }

  Future<bool> confirmUserSelection() async {
    if (_disposed) return false;
    if (_selectedUser == null || _currentAppUser == null) {
      _safeContext?.showValidationError(
        'Usuário ou AppUser não encontrado',
        details: 'Selecione um usuário antes de confirmar a seleção',
      );
      return false;
    }

    if (_state == UserSelectionState.selecting) {
      return false;
    }

    _setState(UserSelectionState.selecting);
    _errorMessage = null;

    try {
      final updatedAppUser = AppUser(
        codLoginApp: _currentAppUser!.codLoginApp,
        nome: _currentAppUser!.nome,
        ativo: _currentAppUser!.ativo,
        codUsuario: _selectedUser!.codUsuario,
        fotoUsuario: _currentAppUser!.fotoUsuario,
        userSystemModel: _selectedUser!,
      );

      final result = await _userRepository.putAppUser(updatedAppUser);
      if (_disposed) return false;

      _currentAppUser = AppUser(
        codLoginApp: result.codLoginApp,
        nome: result.nome,
        ativo: result.ativo,
        codUsuario: result.codUsuario,
        fotoUsuario: _currentAppUser!.fotoUsuario,
        userSystemModel: _selectedUser!,
      );

      return true;
    } catch (e, s) {
      if (_disposed) return false;
      AppLogger.warning('Erro ao vincular usuario', tag: 'UserSelectionVM', error: e, stackTrace: s);
      _setState(UserSelectionState.loaded);
      _safeContext?.showServerError('Erro ao vincular usuário', details: e.toString(), onRetry: confirmUserSelection);
      return false;
    }
  }

  void _clearUsers() {
    _users = [];
    _setState(UserSelectionState.initial);
  }

  void clearSelection() {
    _searchTimer?.cancel();
    _isWaitingForSearch = false;
    _selectedUser = null;
    _searchQuery = '';
    _clearUsers();
  }

  void _setState(UserSelectionState newState) {
    _state = newState;
    _safeNotify();
  }

  void reset() {
    _searchTimer?.cancel();
    _isWaitingForSearch = false;
    _state = UserSelectionState.initial;
    _users = [];
    _selectedUser = null;
    _errorMessage = null;
    _searchQuery = '';
    _resetPagination();
    _safeNotify();
  }

  void _resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    _context = null;
    super.dispose();
  }
}
