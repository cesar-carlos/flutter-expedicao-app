import 'package:data7_expedicao/core/network/base_api_service.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/pagination/pagination.dart';
import 'package:data7_expedicao/data/dtos/user_system_list_response_dto.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/user/user_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

/// Serviço para operações de API relacionadas a usuários do sistema
///
/// Fornece métodos para buscar, listar e pesquisar usuários do sistema
/// através de chamadas HTTP para a API.
class UserSystemApiService extends BaseApiService {
  static const String _baseEndpoint = '/usuarios';
  static const int _defaultSearchLimit = 50;

  /// Busca uma lista de usuários com filtros opcionais e paginação
  ///
  /// [codEmpresa] - Código da empresa para filtrar usuários
  /// [apenasAtivos] - Situação dos usuários (ativo/inativo). Se null, retorna todos
  /// [pagination] - Parâmetros de paginação
  ///
  /// Retorna [UserSystemListResponseDto] com a lista de usuários
  ///
  /// Throws [UserApiException] em caso de erro na API
  Future<UserSystemListResponseDto> getUsers({int? codEmpresa, Situation? apenasAtivos, Pagination? pagination}) async {
    final queryParams = _buildQueryParams(codEmpresa: codEmpresa, apenasAtivos: apenasAtivos, pagination: pagination);

    final response = await get(_baseEndpoint, queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  /// Busca um usuário específico pelo código
  ///
  /// [codUsuario] - Código único do usuário
  ///
  /// Retorna [UserSystemModel] se encontrado, null caso contrário
  ///
  /// Throws [UserApiException] em caso de erro na API (exceto 404)
  Future<UserSystemModel?> getUserById(int codUsuario) async {
    _validateCodUsuario(codUsuario);

    try {
      final response = await get(_baseEndpoint, queryParameters: {'CodUsuario': codUsuario});

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          return UserSystemModel.fromJson(data['data'] as Map<String, dynamic>);
        }
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

  /// Pesquisa usuários pelo nome com filtros opcionais
  ///
  /// [nome] - Nome ou parte do nome para buscar
  /// [codEmpresa] - Código da empresa para filtrar
  /// [apenasAtivos] - Situação dos usuários (padrão: Situation.ativo)
  /// [pagination] - Parâmetros de paginação
  ///
  /// Retorna [UserSystemListResponseDto] com os usuários encontrados
  ///
  /// Throws [UserApiException] em caso de erro na API
  Future<UserSystemListResponseDto> searchUsersByName(
    String nome, {
    int? codEmpresa,
    Situation apenasAtivos = Situation.ativo,
    Pagination? pagination,
  }) async {
    _validateSearchName(nome);

    final queryParams = _buildQueryParams(
      codEmpresa: codEmpresa,
      apenasAtivos: apenasAtivos,
      pagination: pagination,
      searchName: nome,
    );

    final response = await get(_baseEndpoint, queryParameters: queryParams);
    return _processUserListResponse(response.data);
  }

  /// Constrói parâmetros de query para as chamadas da API
  Map<String, dynamic> _buildQueryParams({
    int? codEmpresa,
    Situation? apenasAtivos,
    Pagination? pagination,
    String? searchName,
  }) {
    final queryParams = <String, dynamic>{};

    if (codEmpresa != null) {
      queryParams['CodEmpresa'] = codEmpresa;
    }

    if (apenasAtivos != null) {
      queryParams['Ativo'] = apenasAtivos.code;
    }

    if (searchName != null) {
      queryParams['Nome'] = searchName;
      queryParams['ApenasAtivos'] = apenasAtivos?.code ?? Situation.ativo.code;
    }

    if (pagination != null) {
      queryParams['Limit'] = pagination.limit;
      queryParams['Offset'] = pagination.offset;
      queryParams['Page'] = pagination.page;
    } else if (searchName != null) {
      // Aplicar limite padrão apenas para busca por nome
      queryParams['Limit'] = _defaultSearchLimit;
    }

    return queryParams;
  }

  /// Processa a resposta da API e converte para DTO
  UserSystemListResponseDto _processUserListResponse(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        return _processMapResponse(responseData);
      } else if (responseData is List) {
        return _processListResponse(responseData);
      } else {
        throw UserApiException('Formato de resposta inválida da API');
      }
    } catch (e) {
      if (e is UserApiException) rethrow;
      throw UserApiException('Erro ao processar lista de usuários: $e');
    }
  }

  /// Processa resposta em formato Map
  UserSystemListResponseDto _processMapResponse(Map<String, dynamic> responseData) {
    if (responseData.containsKey('data')) {
      final data = responseData['data'];
      if (data is List) {
        final users = _parseUsersList(data);

        return UserSystemListResponseDto(
          users: users,
          total: responseData['total'] as int? ?? users.length,
          page: responseData['page'] as int?,
          limit: responseData['limit'] as int?,
          totalPages: responseData['totalPages'] as int?,
          success: true,
          message: responseData['message'] as String?,
        );
      }

      // Envelope com 'data' presente mas que NAO e lista indica resposta
      // de erro ou formato inesperado. Falhar explicitamente em vez de
      // interpretar o envelope inteiro como um "usuario fantasma".
      throw UserApiException(
        'Formato de resposta inválido: campo "data" não é uma lista (${data.runtimeType})',
      );
    }

    // Sem envelope 'data': resposta de usuario unico (caso documentado).
    final user = UserSystemModel.fromJson(responseData);
    return UserSystemListResponseDto.success(users: [user], message: 'Usuário encontrado');
  }

  /// Processa resposta em formato List
  UserSystemListResponseDto _processListResponse(List responseData) {
    final users = _parseUsersList(responseData);
    return UserSystemListResponseDto.success(users: users, message: 'Lista de usuários obtida com sucesso');
  }

  /// Bug KKKKK/LLLLL: parse defensivo da lista de usuarios.
  /// Antes era `responseData.map((item) => UserSystemModel.fromJson(item as Map<String, dynamic>)).toList()`
  /// que crashava com TypeError se QUALQUER item fosse null ou de tipo
  /// errado, perdendo a lista inteira. Agora cada item e parseado
  /// individualmente; itens invalidos sao logados e ignorados, e a
  /// resposta continua util mesmo se 1-2 itens estiverem corrompidos.
  List<UserSystemModel> _parseUsersList(List rawList) {
    final result = <UserSystemModel>[];
    for (var i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is! Map) {
        AppLogger.warning(
          'UserSystem: item $i da lista nao e Map (${item.runtimeType}) — ignorado',
          tag: 'UserSystemApi',
        );
        continue;
      }
      try {
        result.add(UserSystemModel.fromJson(Map<String, dynamic>.from(item)));
      } catch (e, s) {
        AppLogger.warning(
          'UserSystem: falha ao parsear item $i — ignorado',
          tag: 'UserSystemApi',
          error: e,
          stackTrace: s,
        );
      }
    }
    return result;
  }

  /// Valida código do usuário
  void _validateCodUsuario(int codUsuario) {
    if (codUsuario <= 0) {
      throw ArgumentError('Código do usuário deve ser maior que zero');
    }
  }

  /// Valida nome de busca
  void _validateSearchName(String nome) {
    if (nome.trim().isEmpty) {
      throw ArgumentError('Nome de busca não pode estar vazio');
    }
    if (nome.trim().length < 2) {
      throw ArgumentError('Nome de busca deve ter pelo menos 2 caracteres');
    }
  }
}
