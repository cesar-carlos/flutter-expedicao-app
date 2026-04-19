import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/data/dtos/github_release_dto.dart';
import 'package:data7_expedicao/data/services/github_api_service.dart';

class GitHubReleaseJsonAdapter {
  final GitHubApiService _githubApiService;
  final Dio _dio;

  GitHubReleaseJsonAdapter({GitHubApiService? githubApiService, Dio? dio})
    : _githubApiService = githubApiService ?? GitHubApiService(),
      _dio = dio ?? Dio();

  Future<String> createVersionJsonFile(String owner, String repo) async {
    final releases = await _githubApiService.getReleases(owner, repo);
    final jsonData = await _convertReleasesToJson(releases);

    final directory = await getTemporaryDirectory();
    final filePath = path.join(directory.path, 'versions.json');
    final file = File(filePath);
    await file.writeAsString(jsonData);

    return filePath;
  }

  Future<String> _convertReleasesToJson(List<GitHubReleaseDto> releases) async {
    final List<Map<String, dynamic>> versionList = [];

    for (final releaseDto in releases) {
      final release = releaseDto.toDomain();
      final apkAsset = release.getApkAsset();

      if (apkAsset == null) continue;

      final version = release.getVersion();
      if (version == null) continue;

      // Bug latente anterior: `try { sha = ... } catch { sha = ''; }`
      // engolia silenciosamente falhas no calculo do checksum e
      // gravava string vazia no JSON. Apps que validassem o checksum
      // contra '' poderiam aceitar APK adulterado por engano (vetor
      // de seguranca). Agora logamos a falha para que o problema seja
      // visivel em monitoring. O '' continua sendo gravado para
      // compatibilidade — clientes do JSON devem tratar '' como
      // "checksum nao disponivel" e exibir warning ao usuario.
      final sha512 = await _calculateSha512(apkAsset.downloadUrl);

      versionList.add({
        'version': version.version,
        'url': apkAsset.downloadUrl,
        'releaseNotes': release.body ?? release.name,
        'releaseDate': release.publishedAt.toUtc().toIso8601String(),
        'sha512': sha512,
      });
    }

    return jsonEncode(versionList);
  }

  Future<String> _calculateSha512(String url) async {
    try {
      final response = await _dio.get<List<int>>(url, options: Options(responseType: ResponseType.bytes));

      if (response.data == null) {
        AppLogger.warning(
          'GitHub APK download retornou body vazio em $url',
          tag: 'GitHubReleaseJsonAdapter',
        );
        return '';
      }

      final bytes = response.data!;
      final digest = sha512.convert(bytes);
      return digest.toString();
    } catch (e, s) {
      AppLogger.warning(
        'Falha ao calcular SHA-512 do APK em $url',
        tag: 'GitHubReleaseJsonAdapter',
        error: e,
        stackTrace: s,
      );
      return '';
    }
  }

  Future<Map<String, dynamic>?> getLatestVersionJson(String owner, String repo) async {
    try {
      final latestReleaseDto = await _githubApiService.getLatestRelease(owner, repo);
      final release = latestReleaseDto.toDomain();
      final apkAsset = release.getApkAsset();

      if (apkAsset == null) return null;

      final version = release.getVersion();
      if (version == null) return null;

      // Bug latente anterior: try/catch local para sha somente.
      // Removido — `_calculateSha512` ja loga internamente.
      final sha512 = await _calculateSha512(apkAsset.downloadUrl);

      return {
        'version': version.version,
        'url': apkAsset.downloadUrl,
        'releaseNotes': release.body ?? release.name,
        'releaseDate': release.publishedAt.toUtc().toIso8601String(),
        'sha512': sha512,
      };
    } catch (e, s) {
      // Bug latente anterior: catch silencioso retornava null sem
      // log. Em producao, ausencia de update disponivel poderia
      // ser:  (a) realmente nenhuma release nova, ou (b) erro de
      // rede/parsing. Sem log, era impossivel distinguir.
      AppLogger.warning(
        'Falha ao buscar latest release de $owner/$repo',
        tag: 'GitHubReleaseJsonAdapter',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }
}
