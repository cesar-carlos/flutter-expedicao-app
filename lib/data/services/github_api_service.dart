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
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  Future<List<GitHubReleaseDto>> getReleases(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases');
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => GitHubReleaseDto.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Repositório não encontrado: $owner/$repo');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Acesso negado. Verifique se o repositório é público ou se o token está configurado corretamente');
      }
      throw Exception('Erro ao buscar releases: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar releases: $e');
    }
  }

  Future<GitHubReleaseDto> getLatestRelease(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases/latest');
      return GitHubReleaseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Nenhum release encontrado para $owner/$repo');
      } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('Acesso negado. Verifique se o repositório é público ou se o token está configurado corretamente');
      }
      throw Exception('Erro ao buscar latest release: ${e.message}');
    } catch (e) {
      throw Exception('Erro ao buscar latest release: $e');
    }
  }
}
