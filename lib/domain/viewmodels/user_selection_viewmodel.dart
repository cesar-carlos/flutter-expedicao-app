import 'dart:async';
import 'package:flutter/material.dart';

import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/pagination.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/domain/repositories/user_repository.dart';
import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/ui/widgets/common/index.dart';

enum UserSelectionState { initial, loading, loaded, selecting, selected }

class UserSelectionViewModel extends ChangeNotifier {
  final UserSystemRepository _userSystemRepository;
  final UserRepository _userRepository;
  BuildContext? _context;

  UserSelectionViewModel(this._userSystemRepository, this._userRepository);

  void setContext(BuildContext context) {
    _context = context;
  }

  UserSelectionState _state = UserSelectionState.initial;
  List<UserSystemData> _users = [];
  UserSystemData? _selectedUser;
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
  List<UserSystemData> get users => _users;
  UserSystemData? get selectedUser => _selectedUser;
  AppUser? get currentAppUser => _currentAppUser;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  bool get isSearchMode => _isSearchMode;
  bool get isWaitingForSearch => _isWaitingForSearch;
  int get currentPage => _currentPage;

  List<UserSystemData> get filteredUsers {
    // Agora mostra todos os usuários (disponíveis e vinculados)
    if (_searchQuery.isEmpty) {
      return _users;
    }
    return _users
        .where(
          (user) => user.nomeUsuario.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  // Getter para verificar se usuário está disponível para seleção
  bool isUserAvailable(UserSystemData user) {
    return user.codLoginApp == null;
  }

  void initialize(AppUser appUser) {
    _currentAppUser = appUser;
    notifyListeners();
  }

  Future<void> searchUsers(String nome) async {
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
        apenasAtivos: true,
        pagination: pagination,
      );

      if (response.success && response.users.isNotEmpty) {
        _users = response.users;
        _hasMoreData = false;
        _setState(UserSelectionState.loaded);
      } else {
        _users = [];
        _setState(UserSelectionState.loaded);
        if (_context != null) {
          _context!.showServerError(
            response.message ?? 'Nenhum usuário encontrado',
            onRetry: () => searchUsers(nome),
          );
        }
      }
    } catch (e) {
      _users = [];
      _setState(UserSelectionState.loaded);
      if (_context != null) {
        _context!.showServerError(
          'Erro ao buscar usuários',
          details: e.toString(),
          onRetry: () => searchUsers(nome),
        );
      }
    }
  }

  Future<void> loadAllUsers() async {
    _setState(UserSelectionState.loading);
    _errorMessage = null;
    _isSearchMode = false;
    _resetPagination();

    try {
      final pagination = Pagination.create(
        limit: _pageLimit,
        offset: 0,
        page: 1,
      );
      final response = await _userSystemRepository.getUsers(
        apenasAtivos: true,
        pagination: pagination,
      );

      if (response.success) {
        _users = response.users;
        _currentPage = 1;
        _hasMoreData = response.users.length == _pageLimit;
        _setState(UserSelectionState.loaded);
      } else {
        _users = [];
        _setState(UserSelectionState.loaded);
        if (_context != null) {
          _context!.showServerError(
            response.message ?? 'Nenhum usuário encontrado',
            onRetry: loadAllUsers,
          );
        }
      }
    } catch (e) {
      _users = [];
      _setState(UserSelectionState.loaded);
      if (_context != null) {
        _context!.showServerError(
          'Erro ao carregar usuários',
          details: e.toString(),
          onRetry: loadAllUsers,
        );
      }
    }
  }

  Future<void> loadMoreUsers() async {
    if (_isLoadingMore || !_hasMoreData || _isSearchMode) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final pagination = Pagination.create(
        limit: _pageLimit,
        offset: _currentPage * _pageLimit,
        page: _currentPage + 1,
      );
      final response = await _userSystemRepository.getUsers(
        apenasAtivos: true,
        pagination: pagination,
      );

      if (response.success) {
        final Set<int> existingUserCodes = _users
            .map((u) => u.codUsuario)
            .toSet();
        final List<UserSystemData> newUsers = response.users
            .where((user) => !existingUserCodes.contains(user.codUsuario))
            .toList();

        _users.addAll(newUsers);
        _currentPage++;
        _hasMoreData = response.users.length == _pageLimit;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      _hasMoreData = false;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _searchTimer?.cancel();

    if (query.trim().isNotEmpty) {
      _isWaitingForSearch = true;
    } else {
      _isWaitingForSearch = false;
    }

    notifyListeners();
    _searchTimer = Timer(_searchDebounceTime, () {
      _performDebouncedSearch(query);
    });
  }

  void _performDebouncedSearch(String query) {
    _isWaitingForSearch = false;

    if (query.trim().isEmpty) {
      _clearUsers();
    } else {
      searchUsers(query);
    }
  }

  void selectUser(UserSystemData user) {
    if (!isUserAvailable(user)) {
      // Usuário já vinculado - mostra aviso
      if (_context != null) {
        _context!.showValidationError(
          'Usuário não disponível',
          details:
              'Este usuário já está vinculado a outro dispositivo (ID: ${user.codLoginApp})',
        );
      }
      return;
    }

    _selectedUser = user;
    _setState(UserSelectionState.loaded);
  }

  Future<bool> confirmUserSelection() async {
    if (_selectedUser == null || _currentAppUser == null) {
      if (_context != null) {
        _context!.showValidationError(
          'Usuário ou AppUser não encontrado',
          details: 'Selecione um usuário antes de confirmar a seleção',
        );
      }
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
      );

      final result = await _userRepository.putAppUser(updatedAppUser);

      _currentAppUser = AppUser(
        codLoginApp: result.codLoginApp,
        nome: result.nome,
        ativo: result.ativo,
        codUsuario: result.codUsuario,
        fotoUsuario: _currentAppUser!.fotoUsuario,
      );

      return true;
    } catch (e) {
      _setState(UserSelectionState.loaded);
      if (_context != null) {
        _context!.showServerError(
          'Erro ao vincular usuário',
          details: e.toString(),
          onRetry: confirmUserSelection,
        );
      }
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
    notifyListeners();
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
    notifyListeners();
  }

  void _resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
    _isLoadingMore = false;
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
