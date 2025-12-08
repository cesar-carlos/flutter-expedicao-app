import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_params.dart';

class AppUpdateViewModel extends ChangeNotifier {
  final CheckAppUpdateUseCase checkAppUpdateUseCase;
  final DownloadAppUpdateUseCase downloadAppUpdateUseCase;
  final InstallAppUpdateUseCase installAppUpdateUseCase;

  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  GitHubRelease? _updateAvailable;
  AppUpdateFailure? _error;
  double _downloadProgress = 0.0;

  bool get isChecking => _isChecking;
  bool get isDownloading => _isDownloading;
  bool get isInstalling => _isInstalling;
  bool get hasUpdate => _updateAvailable != null;
  GitHubRelease? get updateAvailable => _updateAvailable;
  AppUpdateFailure? get error => _error;
  double get downloadProgress => _downloadProgress;
  bool get isProcessing => _isChecking || _isDownloading || _isInstalling;

  AppUpdateViewModel({
    required this.checkAppUpdateUseCase,
    required this.downloadAppUpdateUseCase,
    required this.installAppUpdateUseCase,
  });

  Future<void> checkForUpdate() async {
    final owner = dotenv.env['GITHUB_OWNER'];
    final repo = dotenv.env['GITHUB_REPO'];

    if (owner == null || repo == null) {
      _error = AppUpdateFailure.versionCheckFailed('GITHUB_OWNER ou GITHUB_REPO não configurados no .env');
      notifyListeners();
      return;
    }

    _isChecking = true;
    _error = null;
    _updateAvailable = null;
    notifyListeners();

    final result = await checkAppUpdateUseCase(CheckAppUpdateParams(owner: owner, repo: repo));

    _isChecking = false;

    result.fold(
      (success) {
        _updateAvailable = success;
        notifyListeners();
      },
      (failure) {
        if (failure is AppUpdateFailure && failure.type == AppUpdateFailureType.noUpdateAvailable) {
          _updateAvailable = null;
        } else {
          _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.versionCheckFailed(failure.toString());
        }
        notifyListeners();
      },
    );
  }

  Future<void> downloadAndInstall() async {
    if (_updateAvailable == null) return;

    final apkAsset = _updateAvailable!.getApkAsset();
    if (apkAsset == null) {
      _error = AppUpdateFailure.noApkFound();
      notifyListeners();
      return;
    }

    _isDownloading = true;
    _error = null;
    _downloadProgress = 0.0;
    notifyListeners();

    final downloadResult = await downloadAppUpdateUseCase(
      DownloadAppUpdateParams(downloadUrl: apkAsset.downloadUrl, fileName: apkAsset.name),
    );

    _isDownloading = false;

    downloadResult.fold(
      (apkPath) {
        _downloadProgress = 1.0;
        notifyListeners();
        _installApk(apkPath);
      },
      (failure) {
        _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.downloadFailed(failure.toString());
        notifyListeners();
      },
    );
  }

  Future<void> _installApk(String apkPath) async {
    _isInstalling = true;
    _error = null;
    notifyListeners();

    final installResult = await installAppUpdateUseCase(InstallAppUpdateParams(apkPath: apkPath));

    _isInstalling = false;

    installResult.fold(
      (_) {
        notifyListeners();
      },
      (failure) {
        _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.installFailed(failure.toString());
        notifyListeners();
      },
    );
  }

  void cancelDownload() {
    _isDownloading = false;
    _downloadProgress = 0.0;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
