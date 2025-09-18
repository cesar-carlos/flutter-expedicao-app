import 'package:exp/core/network/base_api_service.dart';
import 'package:exp/domain/models/pagination/pagination.dart';
import 'package:exp/data/dtos/user_system_list_response_dto.dart';
import 'package:exp/domain/models/user_system_models.dart';
import 'package:exp/domain/models/user/user_models.dart';

class UserSystemApiService extends BaseApiService {
  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, bool? apenasAtivos, Pagination? pagination}) async {
    final queryParams = <String, dynamic>{};
    if (codEmpresa != null) queryParams['CodEmpresa'] = codEmpresa;
    if (apenasAtivos != null) {
      queryParams['Ativo'] = apenasAtivos ? 'S' : 'N';
    }

    if (pagination != null) {
      queryParams['Limit'] = pagination.limit;
      queryParams['Offset'] = pagination.offset;
      queryParams['Page'] = pagination.page;
    }

    final response = await get('/usuarios', queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  Future<UserSystemModel?> getUserById(int codUsuario) async {
    try {
      final response = await get('/usuarios', queryParameters: {'CodUsuario': codUsuario});

      if (response.data != null && response.data is Map<String, dynamic>) {
        return UserSystemModel.fromMap(response.data);
      }
      return null;
    } on UserApiException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    } catch (e) {
      throw UserApiException('Erro ao processar dados do usuário: $e');
    }
  }

  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    bool apenasAtivos = true,
    Pagination? pagination,
  }) async {
    final queryParams = <String, dynamic>{'Nome': nome, 'ApenasAtivos': apenasAtivos ? 'S' : 'N'};

    if (codEmpresa != null) queryParams['CodEmpresa'] = codEmpresa;

    if (pagination != null) {
      queryParams['Limit'] = pagination.limit;
      queryParams['Offset'] = pagination.offset;
      queryParams['Page'] = pagination.page;
    } else {
      queryParams['Limit'] = 50;
    }

    final response = await get('/usuarios', queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  UserSystemListResponseDto _processUserListResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final usersData = responseData['data'] as List;
          final users = usersData.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>)).toList();

          return UserSystemListResponseDto(
            users: users,
            total: responseData['total'] as int? ?? users.length,
            page: responseData['page'] as int?,
            limit: responseData['limit'] as int?,
            totalPages: responseData['totalPages'] as int?,
            success: true,
            message: responseData['message'] as String?,
          );
        } else {
          final user = UserSystemModel.fromMap(responseData);

          return UserSystemListResponseDto.success(users: [user], message: 'Usuário encontrado');
        }
      } else if (responseData is List) {
        final users = responseData.map((item) => UserSystemModel.fromMap(item as Map<String, dynamic>)).toList();

        return UserSystemListResponseDto.success(users: users, message: 'Lista de usuários obtida com sucesso');
      } else {
        throw UserApiException('Formato de resposta inválida');
      }
    } catch (e) {
      throw UserApiException('Erro ao processar lista de usuários: $e');
    }
  }

  UserSystemListResponseDto processUserListResponseForTesting(dynamic responseData) {
    return _processUserListResponse(responseData);
  }
}
