import 'package:dio/dio.dart';

import 'package:data7_expedicao/data/dtos/github_release_dto.dart';

class GitHubApiService {
  final Dio _dio;

  GitHubApiService({String? token})
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.github.com',
          headers: token != null
              ? {'Authorization': 'token $token', 'Accept': 'application/vnd.github.v3+json'}
              : {'Accept': 'application/vnd.github.v3+json'},
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 7),
          sendTimeout: const Duration(seconds: 5),
        ),
      );

  Future<List<GitHubReleaseDto>> getReleases(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases');
      // Bug IIIII: antes era `response.data as List<dynamic>` direto.
      // Se a API GitHub mudar o formato (improvavel mas possivel) ou
      // retornar erro com body diferente, o cast crashava com TypeError
      // gritante. Agora validamos explicitamente.
      final data = response.data;
      if (data is! List) {
        throw Exception('Resposta inesperada do GitHub (esperado List, recebido ${data.runtimeType})');
      }
      return data
          .whereType<Map>()
          .map((json) => GitHubReleaseDto.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Repositório não encontrado: $owner/$repo');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception(
          'Acesso negado. Verifique se o repositório é público ou se o token está configurado corretamente',
        );
      }
      throw Exception('Erro ao buscar releases: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar releases: $e');
    }
  }

  /// Fecha o cliente Dio subjacente, liberando conexoes pendentes.
  /// Deve ser chamado quando o servico nao for mais utilizado.
  void close() {
    _dio.close();
  }

  Future<GitHubReleaseDto> getLatestRelease(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases/latest');
      final data = response.data;
      if (data is! Map) {
        throw Exception('Resposta inesperada do GitHub (esperado Map, recebido ${data.runtimeType})');
      }
      return GitHubReleaseDto.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Nenhum release encontrado para $owner/$repo');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception(
          'Acesso negado. Verifique se o repositório é público ou se o token está configurado corretamente',
        );
      }
      throw Exception('Erro ao buscar latest release: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar latest release: $e');
    }
  }
}
