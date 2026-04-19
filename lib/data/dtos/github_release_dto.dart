import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/models/release_asset.dart';

class ReleaseAssetDto {
  final String name;
  final String browserDownloadUrl;
  final int size;
  final String contentType;

  ReleaseAssetDto({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
    required this.contentType,
  });

  factory ReleaseAssetDto.fromJson(Map<String, dynamic> json) {
    // Bug FFFFFFFFFFF: casts diretos em 'name' e 'browser_download_url'
    // crashavam com TypeError se a API GitHub retornasse formato
    // diferente (ou erro com body inesperado). Agora usamos
    // toString()/'' como fallback defensivo. Se algum asset estiver
    // realmente quebrado, ele aparece com URL vazia (e GetApkAsset
    // ja filtra entries invalidas).
    return ReleaseAssetDto(
      name: json['name']?.toString() ?? '',
      browserDownloadUrl: json['browser_download_url']?.toString() ?? '',
      size: json['size'] is int ? json['size'] as int : 0,
      contentType: json['content_type']?.toString() ?? 'application/vnd.android.package-archive',
    );
  }

  ReleaseAsset toDomain() {
    return ReleaseAsset(name: name, downloadUrl: browserDownloadUrl, size: size, contentType: contentType);
  }
}

class GitHubReleaseDto {
  final String tagName;
  final String name;
  final String? body;
  final String publishedAt;
  final List<dynamic> assets;

  GitHubReleaseDto({
    required this.tagName,
    required this.name,
    this.body,
    required this.publishedAt,
    required this.assets,
  });

  factory GitHubReleaseDto.fromJson(Map<String, dynamic> json) {
    // Bug GGGGGGGGGGG: parsing defensivo (mesma motivacao do
    // ReleaseAssetDto.fromJson acima). API GitHub raramente muda mas
    // erros pontuais (rate-limit, manutencao) podem retornar shape
    // inesperado.
    final tagName = json['tag_name']?.toString() ?? '';
    return GitHubReleaseDto(
      tagName: tagName,
      name: json['name']?.toString() ?? tagName,
      body: json['body']?.toString(),
      publishedAt: json['published_at']?.toString() ?? '',
      assets: json['assets'] is List ? json['assets'] as List<dynamic> : const <dynamic>[],
    );
  }

  GitHubRelease toDomain() {
    // Bug HHHHHHHHHHH: `DateTime.parse(publishedAt)` sem try/catch
    // crashava se a string viesse mal formatada (ex.: '' no caso
    // do parsing defensivo acima). Fallback para epoch 0 (data
    // claramente invalida que outras camadas podem detectar).
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(publishedAt);
    } catch (_) {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(0);
    }

    // Bug IIIIIIIIIII: parse item-por-item dos assets em vez de
    // crashar lista inteira se algum asset for invalido (ex.: null
    // entry no array da API).
    final parsedAssets = <ReleaseAsset>[];
    for (final asset in assets) {
      if (asset is! Map) continue;
      try {
        parsedAssets.add(ReleaseAssetDto.fromJson(Map<String, dynamic>.from(asset)).toDomain());
      } catch (_) {
        // ignore item invalido — outros assets continuam
      }
    }

    return GitHubRelease(
      tagName: tagName,
      name: name,
      body: body,
      publishedAt: parsedDate,
      assets: parsedAssets,
    );
  }
}
