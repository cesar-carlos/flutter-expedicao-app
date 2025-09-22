import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/pagination/pagination.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/dtos/user_system_list_response_dto.dart';
import 'package:exp/data/services/user_system_api_service.dart';
import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/domain/models/situation_model.dart';

/// Implementação do repositório de usuários do sistema
///
/// Gerencia operações relacionadas a usuários do sistema, incluindo busca,
/// listagem e pesquisa. Atua como uma camada de abstração entre os casos de uso
/// e o serviço de API, adicionando lógica de cache e tratamento de erro específico.
class UserSystemRepositoryImpl implements UserSystemRepository {
  final UserSystemApiService _apiService;

  // Cache simples para usuários consultados recentemente
  final Map<int, UserSystemModel> _userCache = {};
  final Map<int, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);

  /// Cria uma instância do repositório
  ///
  /// [apiService] - Serviço de API para comunicação HTTP (opcional para testes)
  UserSystemRepositoryImpl({UserSystemApiService? apiService}) : _apiService = apiService ?? UserSystemApiService();
  @override
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario) async {
    final user = await getUserById(codUsuario);
    if (user == null) {
      throw UserApiException('Usuário não encontrado', statusCode: 404);
    }
    return user.toMap();
  }

  @override
  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination}) async {
    try {
      return await _apiService.getUsers(codEmpresa: codEmpresa, apenasAtivos: apenasAtivos, pagination: pagination);
    } on UserApiException {
      // Preservar exceção específica da API
      rethrow;
    } catch (e) {
      throw UserApiException('Erro interno no repositório: $e');
    }
  }

  @override
  Future<UserSystemModel?> getUserById(int codUsuario) async {
    // Verificar cache primeiro
    if (_isUserCachedAndValid(codUsuario)) {
      return _userCache[codUsuario];
    }

    try {
      final user = await _apiService.getUserById(codUsuario);

      // Adicionar ao cache se encontrado
      if (user != null) {
        _addUserToCache(codUsuario, user);
      }

      return user;
    } on UserApiException {
      // Preservar exceção específica da API
      rethrow;
    } catch (e) {
      throw UserApiException('Erro interno no repositório: $e');
    }
  }

  @override
  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  }) async {
    try {
      return await _apiService.searchUsersByName(
        nome,
        codEmpresa: codEmpresa,
        apenasAtivos: apenasAtivos,
        pagination: pagination,
      );
    } on UserApiException {
      // Preservar exceção específica da API
      rethrow;
    } catch (e) {
      throw UserApiException('Erro interno no repositório: $e');
    }
  }

  /// Verifica se o usuário está no cache e ainda é válido
  bool _isUserCachedAndValid(int codUsuario) {
    if (!_userCache.containsKey(codUsuario)) {
      return false;
    }

    final cacheTime = _cacheTimestamps[codUsuario];
    if (cacheTime == null) {
      return false;
    }

    final now = DateTime.now();
    return now.difference(cacheTime) < _cacheExpiration;
  }

  /// Adiciona um usuário ao cache
  void _addUserToCache(int codUsuario, UserSystemModel user) {
    _userCache[codUsuario] = user;
    _cacheTimestamps[codUsuario] = DateTime.now();

    // Limpar cache muito antigo para evitar vazamento de memória
    _cleanOldCacheEntries();
  }

  /// Remove entradas antigas do cache
  void _cleanOldCacheEntries() {
    final now = DateTime.now();
    final keysToRemove = <int>[];

    for (final entry in _cacheTimestamps.entries) {
      if (now.difference(entry.value) > _cacheExpiration) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _userCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  /// Limpa todo o cache
  void clearCache() {
    _userCache.clear();
    _cacheTimestamps.clear();
  }
}
