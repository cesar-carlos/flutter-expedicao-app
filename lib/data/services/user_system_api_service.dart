import 'package:exp/core/network/base_api_service.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/data/dtos/user_system_dto.dart';
import 'package:exp/domain/models/user/user_models.dart';

class UserSystemApiService extends BaseApiService {
  Future<UserSystemListResponse> getUsers({
    int? codEmpresa,
    bool? apenasAtivos,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (codEmpresa != null) queryParams['CodEmpresa'] = codEmpresa;
    if (apenasAtivos != null) {
      queryParams['Ativo'] = apenasAtivos ? 'S' : 'N';
    }
    if (limit != null) queryParams['Limit'] = limit;
    if (offset != null) queryParams['Offset'] = offset;

    final response = await get('/usuarios', queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  Future<UserSystemData?> getUserById(int codUsuario) async {
    try {
      final response = await get(
        '/usuarios',
        queryParameters: {'CodUsuario': codUsuario},
      );

      if (response.data != null) {
        final userSystemDto = UserSystemDto.fromApiResponse(response.data);
        return UserSystemData.fromMap(userSystemDto.toDomain());
      }
      return null;
    } on UserApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<UserSystemListResponse> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'Nome': nome,
      'Limit': limit,
      'ApenasAtivos': apenasAtivos ? 'S' : 'N',
    };

    final response = await get('/usuarios', queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  UserSystemListResponse _processUserListResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final usersData = responseData['data'] as List;
          final users = usersData
              .map(
                (item) =>
                    UserSystemDto.fromApiResponse(item as Map<String, dynamic>),
              )
              .map((dto) => UserSystemData.fromMap(dto.toDomain()))
              .toList();

          return UserSystemListResponse(
            users: users,
            total: responseData['total'] as int? ?? users.length,
            page: responseData['page'] as int?,
            limit: responseData['limit'] as int?,
            totalPages: responseData['totalPages'] as int?,
            success: true,
            message: responseData['message'] as String?,
          );
        } else {
          final userDto = UserSystemDto.fromApiResponse(responseData);
          final user = UserSystemData.fromMap(userDto.toDomain());

          return UserSystemListResponse.success(
            users: [user],
            message: 'Usuário encontrado',
          );
        }
      } else if (responseData is List) {
        final users = responseData
            .map(
              (item) =>
                  UserSystemDto.fromApiResponse(item as Map<String, dynamic>),
            )
            .map((dto) => UserSystemData.fromMap(dto.toDomain()))
            .toList();

        return UserSystemListResponse.success(
          users: users,
          message: 'Lista de usuários obtida com sucesso',
        );
      } else {
        throw UserApiException('Formato de resposta inválida');
      }
    } catch (e) {
      throw UserApiException('Erro ao processar lista de usuários: $e');
    }
  }

  /// Método exposto apenas para testes
  /// Permite testar o processamento de resposta sem fazer chamadas HTTP
  UserSystemListResponse processUserListResponseForTesting(
    dynamic responseData,
  ) {
    return _processUserListResponse(responseData);
  }
}
