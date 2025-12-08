import 'package:data7_expedicao/core/results/app_failure.dart';

enum AppUpdateFailureType {
  noUpdateAvailable('Nenhuma atualização disponível'),
  downloadFailed('Falha ao baixar atualização'),
  installFailed('Falha ao instalar atualização'),
  versionCheckFailed('Falha ao verificar versão'),
  invalidRelease('Release inválido'),
  noApkFound('APK não encontrado no release'),
  networkError('Erro de rede');

  const AppUpdateFailureType(this.description);
  final String description;
}

class AppUpdateFailure extends AppFailure {
  final AppUpdateFailureType type;

  const AppUpdateFailure({required this.type, required super.message, super.code, super.exception});

  factory AppUpdateFailure.noUpdateAvailable() {
    return const AppUpdateFailure(
      type: AppUpdateFailureType.noUpdateAvailable,
      message: 'Nenhuma atualização disponível',
      code: 'NO_UPDATE_AVAILABLE',
    );
  }

  factory AppUpdateFailure.downloadFailed(String details) {
    return AppUpdateFailure(
      type: AppUpdateFailureType.downloadFailed,
      message: 'Falha ao baixar atualização: $details',
      code: 'DOWNLOAD_FAILED',
    );
  }

  factory AppUpdateFailure.installFailed(String details) {
    return AppUpdateFailure(
      type: AppUpdateFailureType.installFailed,
      message: 'Falha ao instalar atualização: $details',
      code: 'INSTALL_FAILED',
    );
  }

  factory AppUpdateFailure.versionCheckFailed(String details) {
    return AppUpdateFailure(
      type: AppUpdateFailureType.versionCheckFailed,
      message: 'Falha ao verificar versão: $details',
      code: 'VERSION_CHECK_FAILED',
    );
  }

  factory AppUpdateFailure.invalidRelease(String details) {
    return AppUpdateFailure(
      type: AppUpdateFailureType.invalidRelease,
      message: 'Release inválido: $details',
      code: 'INVALID_RELEASE',
    );
  }

  factory AppUpdateFailure.noApkFound() {
    return const AppUpdateFailure(
      type: AppUpdateFailureType.noApkFound,
      message: 'APK não encontrado no release',
      code: 'NO_APK_FOUND',
    );
  }

  factory AppUpdateFailure.networkError(String details) {
    return AppUpdateFailure(
      type: AppUpdateFailureType.networkError,
      message: 'Erro de rede: $details',
      code: 'NETWORK_ERROR',
    );
  }
}
