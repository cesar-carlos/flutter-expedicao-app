import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/result_extensions.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/install_app_update/install_app_update_usecase.dart';

@GenerateMocks([IAppUpdateRepository])
import 'install_app_update_usecase_test.mocks.dart';

void main() {
  late InstallAppUpdateUseCase useCase;
  late MockIAppUpdateRepository mockRepository;

  setUpAll(() {
    provideDummy<Result<void>>(successVoid());
  });

  setUp(() {
    mockRepository = MockIAppUpdateRepository();
    useCase = InstallAppUpdateUseCase(mockRepository);
  });

  group('InstallAppUpdateUseCase', () {
    const tApkPath = '/path/to/app-release.apk';

    test('should return success when installation succeeds', () async {
      // Arrange
      when(mockRepository.installApk(any)).thenAnswer((_) async => successVoid());

      // Act
      final result = await useCase(const InstallAppUpdateParams(apkPath: tApkPath));

      // Assert
      expect(result.isSuccess(), true);
      verify(mockRepository.installApk(tApkPath)).called(1);
    });

    test('should return installFailed when installation fails', () async {
      // Arrange
      when(mockRepository.installApk(any)).thenAnswer(
        (_) async => failure(AppUpdateFailure.installFailed('Install error')),
      );

      // Act
      final result = await useCase(const InstallAppUpdateParams(apkPath: tApkPath));

      // Assert
      expect(result.isError(), true);
      final err = result.getError();
      expect(err, isA<AppUpdateFailure>());
      expect((err as AppUpdateFailure).type, AppUpdateFailureType.installFailed);
    });
  });
}
