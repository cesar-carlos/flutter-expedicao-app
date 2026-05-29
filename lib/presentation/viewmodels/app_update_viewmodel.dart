import 'package:flutter/foundation.dart';

import 'package:data7_expedicao/domain/services/i_update_cache_service.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_usecase.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_usecase.dart';

class AppUpdateViewModel extends ChangeNotifier {
  final CheckAppUpdateUseCase checkAppUpdateUseCase;
  final DownloadAppUpdateUseCase downloadAppUpdateUseCase;
  final InstallAppUpdateUseCase installAppUpdateUseCase;
  final IUpdateCacheService updateCacheService;

  bool _cancelDownloadFlag = false;
  bool _disposed = false;

  bool _isChecking = false;
  bool _isDownloading = false;
  bool _isInstalling = false;
  GitHubRelease? _updateAvailable;
  AppUpdateFailure? _error;
  double _downloadProgress = 0.0;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

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
    required this.updateCacheService,
  });

  Future<void> checkForUpdate({String? owner, String? repo, bool forceCheck = false}) async {
    if (_disposed) return;
    // Bug IIII (parcial): impede chamadas concorrentes em checkForUpdate.
    if (_isChecking) return;

    if (owner == null || owner.isEmpty || repo == null || repo.isEmpty) {
      if (forceCheck) {
        _error = AppUpdateFailure.versionCheckFailed('GITHUB_OWNER ou GITHUB_REPO não configurados');
        _safeNotify();
      }
      return;
    }

    if (!forceCheck && !updateCacheService.shouldCheckForUpdates()) {
      return;
    }

    _isChecking = true;
    _error = null;
    _updateAvailable = null;
    _safeNotify();

    try {
      final result = await checkAppUpdateUseCase(CheckAppUpdateParams(owner: owner, repo: repo));
      if (_disposed) return;

      _isChecking = false;

      result.fold(
        (success) {
          _updateAvailable = success;
          updateCacheService.markAsChecked();
          _safeNotify();
        },
        (failure) {
          if (failure is AppUpdateFailure && failure.type == AppUpdateFailureType.noUpdateAvailable) {
            _updateAvailable = null;
            updateCacheService.markAsChecked();
          } else if (failure is AppUpdateFailure &&
              (failure.type == AppUpdateFailureType.networkError ||
                  failure.message.contains('timeout') ||
                  failure.message.contains('conexão'))) {
            if (!forceCheck) {
              _error = null;
            } else {
              _error = failure;
            }
          } else {
            _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.versionCheckFailed(failure.toString());
          }
          _safeNotify();
        },
      );
    } catch (e) {
      if (_disposed) return;
      _isChecking = false;
      if (forceCheck) {
        _error = AppUpdateFailure.versionCheckFailed('Erro ao verificar atualização: ${e.toString()}');
      }
      _safeNotify();
    }
  }

  Future<void> downloadAndInstall() async {
    if (_disposed) return;
    // Bug IIII: impede 2 cliques rapidos no botao "Atualizar agora"
    // disparando 2 downloads paralelos do mesmo APK (cada um cria
    // arquivo temporario, ocupa banda, e o ultimo a terminar tenta
    // instalar — possivel corrupcao se ambos escrevem no mesmo path).
    if (_isDownloading || _isInstalling) return;
    if (_updateAvailable == null) return;

    final apkAsset = _updateAvailable!.getApkAsset();
    if (apkAsset == null) {
      _error = AppUpdateFailure.noApkFound();
      _safeNotify();
      return;
    }

    _isDownloading = true;
    _error = null;
    _downloadProgress = 0.0;
    _cancelDownloadFlag = false;
    _safeNotify();

    final downloadResult = await downloadAppUpdateUseCase(
      DownloadAppUpdateParams(
        downloadUrl: apkAsset.downloadUrl,
        fileName: apkAsset.name,
        onProgress: (received, total) {
          _downloadProgress = total > 0 ? received / total : 0;
          _safeNotify();
        },
        isCancelled: () => _cancelDownloadFlag || _disposed,
      ),
    );
    if (_disposed) return;

    _isDownloading = false;

    downloadResult.fold(
      (apkPath) {
        _downloadProgress = 1.0;
        _safeNotify();
        _installApk(apkPath);
      },
      (failure) {
        _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.downloadFailed(failure.toString());
        _safeNotify();
      },
    );
  }

  Future<void> _installApk(String apkPath) async {
    if (_disposed) return;
    _isInstalling = true;
    _error = null;
    _safeNotify();

    final installResult = await installAppUpdateUseCase(InstallAppUpdateParams(apkPath: apkPath));
    if (_disposed) return;

    _isInstalling = false;

    installResult.fold(
      (_) {
        _safeNotify();
      },
      (failure) {
        _error = failure is AppUpdateFailure ? failure : AppUpdateFailure.installFailed(failure.toString());
        _safeNotify();
      },
    );
  }

  void cancelDownload() {
    _cancelDownloadFlag = true;
    if (_isDownloading) {
      _isDownloading = false;
      _downloadProgress = 0.0;
      _safeNotify();
    }
  }

  void clearError() {
    _error = null;
    _safeNotify();
  }

  @override
  void dispose() {
    // Bug HHHH: download de APK pode levar minutos; sem _disposed flag,
    // qualquer notifyListeners apos a tela ser fechada crasha em
    // FlutterError "A AppUpdateViewModel was used after being disposed".
    // Setamos _cancelDownloadFlag para tentar abortar o download em
    // andamento (o usecase chama isCancelled periodicamente).
    _disposed = true;
    _cancelDownloadFlag = true;
    super.dispose();
  }
}
