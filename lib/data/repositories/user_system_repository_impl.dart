import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/data/services/user_system_api_service.dart';

class UserSystemRepositoryImpl implements UserSystemRepository {
  final UserSystemApiService _apiService;

  UserSystemRepositoryImpl() : _apiService = UserSystemApiService();
  @override
  Future<Map<String, dynamic>> getUserSystemInfo(int codUsuario) async {
    final user = await _apiService.getUserById(codUsuario);
    if (user != null) {
      return user.toMap();
    } else {
      throw Exception('Usuário não encontrado');
    }
  }

  @override
  Future<UserSystemListResponse> getUsers({
    int? codEmpresa,
    bool? apenasAtivos,
    int? limit,
    int? offset,
  }) async {
    return await _apiService.getUsers(
      apenasAtivos: apenasAtivos,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<UserSystemData?> getUserById(int codUsuario) async {
    return await _apiService.getUserById(codUsuario);
  }

  @override
  Future<UserSystemListResponse> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    int limit = 50,
  }) async {
    return await _apiService.searchUsersByName(
      nome,
      codEmpresa: codEmpresa,
      apenasAtivos: apenasAtivos,
      limit: limit,
    );
  }
}
