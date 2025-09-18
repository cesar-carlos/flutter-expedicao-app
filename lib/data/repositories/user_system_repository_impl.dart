import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/pagination/pagination.dart';
import 'package:exp/domain/repositories/user_system_repository.dart';
import 'package:exp/data/dtos/user_system_list_response_dto.dart';
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
  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, bool? apenasAtivos, Pagination? pagination}) async {
    return await _apiService.getUsers(codEmpresa: codEmpresa, apenasAtivos: apenasAtivos, pagination: pagination);
  }

  @override
  Future<UserSystemModel?> getUserById(int codUsuario) async {
    try {
      final user = await _apiService.getUserById(codUsuario);
      return user;
    } catch (e) {
      throw Exception('Erro ao buscar usuário: $e');
    }
  }

  @override
  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    Pagination? pagination,
  }) async {
    return await _apiService.searchUsersByName(
      nome,
      codEmpresa: codEmpresa,
      apenasAtivos: apenasAtivos,
      pagination: pagination,
    );
  }
}
