import 'dart:io';
import 'package:dio/dio.dart';

import 'package:exp/domain/models/user/user_models.dart';
import 'package:exp/core/network/dio_config.dart';
import 'package:exp/data/dtos/create_user_dto.dart';
import 'package:exp/data/dtos/create_user_response_dto.dart';
import 'package:exp/data/dtos/login_dto.dart';
import 'package:exp/data/dtos/login_response_dto.dart';
import 'package:exp/data/dtos/api_error_dto.dart';
import 'package:exp/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  Dio get _dio => DioConfig.instance;
  String get _baseUrl => DioConfig.baseUrl;

  @override
  Future<CreateUserResponse> createUser({
    required String nome,
    required String senha,
    File? profileImage,
    int? codUsuario,
  }) async {
    final createUserDto = CreateUserDto.fromDomainParams(
      nome: nome,
      senha: senha,
      profileImage: profileImage,
      codUsuario: codUsuario,
    );

    if (!createUserDto.isValid) {
      throw UserApiException('Dados de usuário inválidos', statusCode: 400, isValidationError: true);
    }

    return await _createUserWithDto(createUserDto);
  }

  @override
  Future<LoginResponse> login(String nome, String senha) async {
    try {
      final loginDto = LoginDto(nome: nome, senha: senha);

      final url = '$_baseUrl/expedicao/login-app';
      final response = await _dio.post(url, data: loginDto.toApiRequest());

      if (response.statusCode == 200) {
        final loginResponseDto = LoginResponseDto.fromJson(response.data);
        return loginResponseDto.toDomain();
      } else {
        throw UserApiException('Erro inesperado no login', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UserApiException('Credenciais inválidas', statusCode: 401);
      }

      final errorDto = ApiErrorDto.connectionError(_getErrorMessage(e));
      throw UserApiException(errorDto.message, statusCode: e.response?.statusCode, originalException: e);
    } catch (e) {
      throw UserApiException('Erro interno: $e', statusCode: 500, originalException: e);
    }
  }

  Future<CreateUserResponse> _createUserWithDto(CreateUserDto dto) async {
    try {
      final url = '$_baseUrl/expedicao/create-login-app';

      final requestData = await dto.toApiRequest();
      final response = await _dio.post(url, data: requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseDto = CreateUserResponseDto.fromApiResponse(response.data);
          final userResponse = CreateUserResponse.fromJson(responseDto.toDomain());

          return userResponse;
        } catch (e) {
          throw UserApiException('Erro ao processar resposta da API: $e', statusCode: response.statusCode);
        }
      } else {
        throw UserApiException('Erro inesperado: Status ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        try {
          final errorDto = ApiErrorDto.fromApiResponse(e.response!.data, e.response!.statusCode);
          throw errorDto.toException();
        } catch (_) {
          final errorDto = ApiErrorDto.validationError('Erro de validação', e.response?.data);
          throw errorDto.toException();
        }
      }

      final errorDto = ApiErrorDto.connectionError(_getErrorMessage(e));
      throw UserApiException(errorDto.message, statusCode: e.response?.statusCode, originalException: e);
    } catch (e) {
      final errorDto = ApiErrorDto.connectionError('Erro inesperado: $e');
      throw UserApiException(errorDto.message, originalException: e);
    }
  }

  @override
  Future<AppUserConsultation> getAppUser(int codLoginApp) async {
    try {
      final url = '$_baseUrl/expedicao/consult-login-app';
      final response = await _dio.get(url, queryParameters: {'CodLoginApp': codLoginApp});

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data') &&
            responseData.containsKey('message')) {
          final userData = responseData['data'];
          if (userData != null) {
            return AppUserConsultation.fromJson(userData);
          } else {
            throw UserApiException('Dados do usuário não encontrados na resposta', statusCode: 200);
          }
        } else {
          throw UserApiException('Formato de resposta inválido', statusCode: 200);
        }
      } else {
        throw UserApiException('Erro inesperado: Status ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final errorMessage = e.response?.data is Map<String, dynamic>
            ? (e.response!.data['message'] ?? 'Usuário não encontrado')
            : 'Usuário não encontrado';

        throw UserApiException(errorMessage, statusCode: 404);
      }

      final errorDto = ApiErrorDto.connectionError(_getErrorMessage(e));
      throw UserApiException(errorDto.message, statusCode: e.response?.statusCode, originalException: e);
    } catch (e) {
      if (e is UserApiException) {
        rethrow;
      }

      throw UserApiException('Erro interno ao consultar usuário: $e', statusCode: 500, originalException: e);
    }
  }

  @override
  Future<AppUserConsultation> putAppUser(AppUser appUser) async {
    try {
      final url = '$_baseUrl/expedicao/login-app';
      final response = await _dio.put(
        url,
        queryParameters: {'CodLoginApp': appUser.codLoginApp},
        data: appUser.toJson(),
      );
      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('user') &&
            responseData.containsKey('message')) {
          final userData = responseData['user'];
          if (userData != null) {
            return AppUserConsultation.fromJson(userData);
          } else {
            throw UserApiException('Dados do usuário não encontrados na resposta', statusCode: 200);
          }
        } else {
          throw UserApiException('Formato de resposta inválido', statusCode: 200);
        }
      } else {
        throw UserApiException('Erro inesperado: Status ${response.statusCode}', statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        String errorMessage = 'Erro ao atualizar usuário';

        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Dados inválidos enviados para o servidor';
        } else if (errorData is String) {
          errorMessage = errorData;
        }

        throw UserApiException(errorMessage, statusCode: 400);
      }

      final errorDto = ApiErrorDto.connectionError(_getErrorMessage(e));
      throw UserApiException(errorDto.message, statusCode: e.response?.statusCode, originalException: e);
    } catch (e) {
      if (e is UserApiException) {
        rethrow;
      }

      throw UserApiException('Erro interno ao atualizar usuário: $e', statusCode: 500, originalException: e);
    }
  }

  @override
  Future<bool> validateCurrentPassword({required String nome, required String currentPassword}) async {
    try {
      // Usar o endpoint de login para validar a senha atual
      await login(nome, currentPassword);
      return true; // Se não deu erro, a senha está correta
    } on UserApiException catch (e) {
      if (e.statusCode == 401) {
        return false; // Senha incorreta
      }
      // Re-lança outros erros (conexão, servidor, etc.)
      rethrow;
    } catch (e) {
      // Re-lança erros inesperados
      rethrow;
    }
  }

  @override
  Future<bool> changePassword({
    required String nome,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Primeiro, validar a senha atual
      final isCurrentPasswordValid = await validateCurrentPassword(nome: nome, currentPassword: currentPassword);

      if (!isCurrentPasswordValid) {
        throw UserApiException('Senha atual incorreta', statusCode: 401, isValidationError: true);
      }

      // Usar o endpoint PUT /expedicao/login-app para alterar a senha
      // Precisamos obter o CodLoginApp do usuário atual primeiro
      final loginResponse = await login(nome, currentPassword);
      final user = loginResponse.user;

      final url = '$_baseUrl/expedicao/login-app';
      final response = await _dio.put(
        url,
        queryParameters: {'CodLoginApp': user.codLoginApp},
        data: {
          'CodLoginApp': user.codLoginApp,
          'Ativo': user.ativo.code,
          'Nome': user.nome,
          'CodUsuario': user.codUsuario,
          'Senha': newPassword, // Nova senha no body
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw UserApiException('Erro ao alterar senha: Status ${response.statusCode}', statusCode: response.statusCode);
      }
    } on UserApiException {
      rethrow;
    } catch (e) {
      throw UserApiException('Erro ao alterar senha: $e', statusCode: 500, originalException: e);
    }
  }

  String _getErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão excedido';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio excedido';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de resposta excedido';
      case DioExceptionType.connectionError:
        return 'Erro de conexão - Verifique URL e porta';
      case DioExceptionType.cancel:
        return 'Operação cancelada';
      default:
        return 'Erro de comunicação: ${e.message}';
    }
  }
}
