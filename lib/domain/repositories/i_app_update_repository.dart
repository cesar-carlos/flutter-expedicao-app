import 'package:result_dart/result_dart.dart';
import 'package:data7_expedicao/domain/models/app_version.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';

abstract class IAppUpdateRepository {
  Future<Result<AppVersion>> getCurrentVersion();
  Future<Result<List<GitHubRelease>>> getReleases(String owner, String repo);
  Future<Result<GitHubRelease>> getLatestRelease(String owner, String repo);
  Future<Result<String>> downloadApk(
    String downloadUrl, {
    required String fileName,
    void Function(int received, int total)? onProgress,
    bool Function()? isCancelled,
  });
  Future<Result<void>> installApk(String apkPath);
}
