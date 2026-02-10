import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/result_extensions.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/download_app_update/download_app_update_usecase.dart';

@GenerateMocks([IAppUpdateRepository])
import 'download_app_update_usecase_test.mocks.dart';

void main() {
  late DownloadAppUpdateUseCase useCase;
  late MockIAppUpdateRepository mockRepository;

  setUpAll(() {
    provideDummy<Result<String>>(success(''));
  });

  setUp(() {
    mockRepository = MockIAppUpdateRepository();
    useCase = DownloadAppUpdateUseCase(mockRepository);
  });

  group('DownloadAppUpdateUseCase', () {
    const tDownloadUrl = 'https://example.com/app.apk';
    const tFileName = 'app-release.apk';
    const tApkPath = '/path/to/app-release.apk';

    test('should return APK path when download succeeds', () async {
      // Arrange
      when(
        mockRepository.downloadApk(
          any,
          fileName: anyNamed('fileName'),
          onProgress: anyNamed('onProgress'),
          isCancelled: anyNamed('isCancelled'),
        ),
      ).thenAnswer((_) async => success(tApkPath));

      // Act
      final result = await useCase(const DownloadAppUpdateParams(downloadUrl: tDownloadUrl, fileName: tFileName));

      // Assert
      expect(result.isSuccess(), true);
      expect(result.get(), tApkPath);
      verify(
        mockRepository.downloadApk(tDownloadUrl, fileName: tFileName, onProgress: null, isCancelled: null),
      ).called(1);
    });

    test('should return downloadFailed when download fails', () async {
      // Arrange
      when(
        mockRepository.downloadApk(
          any,
          fileName: anyNamed('fileName'),
          onProgress: anyNamed('onProgress'),
          isCancelled: anyNamed('isCancelled'),
        ),
      ).thenAnswer((_) async => failure(AppUpdateFailure.downloadFailed('Network error')));

      // Act
      final result = await useCase(const DownloadAppUpdateParams(downloadUrl: tDownloadUrl, fileName: tFileName));

      // Assert
      expect(result.isError(), true);
      final err = result.getError();
      expect(err, isA<AppUpdateFailure>());
      expect((err as AppUpdateFailure).type, AppUpdateFailureType.downloadFailed);
    });

    test('should pass progress callback to repository', () async {
      // Arrange
      var lastReceived = 0;
      void onProgress(int received, int total) {
        lastReceived = received;
      }

      when(
        mockRepository.downloadApk(
          any,
          fileName: anyNamed('fileName'),
          onProgress: anyNamed('onProgress'),
          isCancelled: anyNamed('isCancelled'),
        ),
      ).thenAnswer((_) async => success(tApkPath));

      // Act
      await useCase(DownloadAppUpdateParams(downloadUrl: tDownloadUrl, fileName: tFileName, onProgress: onProgress));

      // Assert
      verify(
        mockRepository.downloadApk(tDownloadUrl, fileName: tFileName, onProgress: onProgress, isCancelled: null),
      ).called(1);
      expect(lastReceived, 0);
    });
  });
}
