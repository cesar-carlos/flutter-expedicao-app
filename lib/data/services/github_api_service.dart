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
    } catch (e) {
      throw Exception('Erro ao buscar releases: $e');
    }
  }

  Future<GitHubReleaseDto> getLatestRelease(String owner, String repo) async {
    try {
      final response = await _dio.get('/repos/$owner/$repo/releases/latest');
      return GitHubReleaseDto.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Erro ao buscar latest release: $e');
    }
  }
}
