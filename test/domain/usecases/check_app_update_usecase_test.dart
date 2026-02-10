import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:result_dart/result_dart.dart';

import 'package:data7_expedicao/core/results/app_result.dart';
import 'package:data7_expedicao/core/results/result_extensions.dart';
import 'package:data7_expedicao/domain/models/app_version.dart';
import 'package:data7_expedicao/domain/models/app_update_failure.dart';
import 'package:data7_expedicao/domain/models/github_release.dart';
import 'package:data7_expedicao/domain/models/release_asset.dart';
import 'package:data7_expedicao/domain/repositories/i_app_update_repository.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_params.dart';
import 'package:data7_expedicao/domain/usecases/check_app_update/check_app_update_usecase.dart';

@GenerateMocks([IAppUpdateRepository])
import 'check_app_update_usecase_test.mocks.dart';

void main() {
  late CheckAppUpdateUseCase useCase;
  late MockIAppUpdateRepository mockRepository;

  setUpAll(() {
    provideDummy<Result<AppVersion>>(
      success(AppVersion(version: '0.0.0', buildNumber: 0)),
    );
    provideDummy<Result<GitHubRelease>>(
      failure(AppUpdateFailure.versionCheckFailed('dummy')),
    );
  });

  setUp(() {
    mockRepository = MockIAppUpdateRepository();
    useCase = CheckAppUpdateUseCase(mockRepository);
  });

  group('CheckAppUpdateUseCase', () {
    final tCurrentVersion = AppVersion(version: '1.0.0', buildNumber: 1);
    final tNewerRelease = GitHubRelease(
      tagName: 'v1.0.1',
      name: 'Version 1.0.1',
      body: 'Bug fixes',
      publishedAt: DateTime(2024, 1, 1),
      assets: [
        ReleaseAsset(
          name: 'app-release.apk',
          downloadUrl: 'https://example.com/app.apk',
          size: 1000000,
          contentType: 'application/vnd.android.package-archive',
        ),
      ],
    );
    final tSameVersionRelease = GitHubRelease(
      tagName: 'v1.0.0',
      name: 'Version 1.0.0',
      body: 'Same version',
      publishedAt: DateTime(2024, 1, 1),
      assets: [
        ReleaseAsset(
          name: 'app-release.apk',
          downloadUrl: 'https://example.com/app.apk',
          size: 1000000,
          contentType: 'application/vnd.android.package-archive',
        ),
      ],
    );

    test('should return release when newer version is available', () async {
      // Arrange
      when(
        mockRepository.getCurrentVersion(),
      ).thenAnswer((_) async => success(tCurrentVersion));
      when(
        mockRepository.getLatestRelease('owner', 'repo'),
      ).thenAnswer((_) async => success(tNewerRelease));

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isSuccess(), true);
      final release = result.get();
      expect(release.tagName, 'v1.0.1');
      verify(mockRepository.getCurrentVersion()).called(1);
      verify(mockRepository.getLatestRelease('owner', 'repo')).called(1);
    });

    test('should return noUpdateAvailable when versions are equal', () async {
      // Arrange
      when(
        mockRepository.getCurrentVersion(),
      ).thenAnswer((_) async => success(tCurrentVersion));
      when(
        mockRepository.getLatestRelease('owner', 'repo'),
      ).thenAnswer((_) async => success(tSameVersionRelease));

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isError(), true);
      final err = result.getError();
      expect(err, isA<AppUpdateFailure>());
      expect(
        (err as AppUpdateFailure).type,
        AppUpdateFailureType.noUpdateAvailable,
      );
    });

    test(
      'should return noUpdateAvailable when release version is older',
      () async {
        // Arrange
        final olderRelease = GitHubRelease(
          tagName: 'v0.9.9',
          name: 'Version 0.9.9',
          body: 'Older version',
          publishedAt: DateTime(2024, 1, 1),
          assets: [],
        );
        when(
          mockRepository.getCurrentVersion(),
        ).thenAnswer((_) async => success(tCurrentVersion));
        when(
          mockRepository.getLatestRelease('owner', 'repo'),
        ).thenAnswer((_) async => success(olderRelease));

        // Act
        final result = await useCase(
          const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
        );

        // Assert
        expect(result.isError(), true);
        final err = result.getError();
        expect(err, isA<AppUpdateFailure>());
        expect(
          (err as AppUpdateFailure).type,
          AppUpdateFailureType.noUpdateAvailable,
        );
      },
    );

    test('should return noApkFound when release has no APK asset', () async {
      // Arrange
      final releaseWithoutApk = GitHubRelease(
        tagName: 'v1.0.1',
        name: 'Version 1.0.1',
        body: 'No APK',
        publishedAt: DateTime(2024, 1, 1),
        assets: [],
      );
      when(
        mockRepository.getCurrentVersion(),
      ).thenAnswer((_) async => success(tCurrentVersion));
      when(
        mockRepository.getLatestRelease('owner', 'repo'),
      ).thenAnswer((_) async => success(releaseWithoutApk));

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isError(), true);
      final err = result.getError();
      expect(err, isA<AppUpdateFailure>());
      expect((err as AppUpdateFailure).type, AppUpdateFailureType.noApkFound);
    });

    test('should return invalidRelease when tag name is invalid', () async {
      // Arrange
      final invalidRelease = GitHubRelease(
        tagName: 'invalid',
        name: 'Invalid Release',
        body: 'Invalid tag',
        publishedAt: DateTime(2024, 1, 1),
        assets: [],
      );
      when(
        mockRepository.getCurrentVersion(),
      ).thenAnswer((_) async => success(tCurrentVersion));
      when(
        mockRepository.getLatestRelease('owner', 'repo'),
      ).thenAnswer((_) async => success(invalidRelease));

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isError(), true);
      final err = result.getError();
      expect(err, isA<AppUpdateFailure>());
      expect(
        (err as AppUpdateFailure).type,
        AppUpdateFailureType.invalidRelease,
      );
    });

    test('should return failure when getCurrentVersion fails', () async {
      // Arrange
      when(mockRepository.getCurrentVersion()).thenAnswer(
        (_) async =>
            failure(AppUpdateFailure.versionCheckFailed('Network error')),
      );

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isError(), true);
      verify(mockRepository.getCurrentVersion()).called(1);
      verifyNever(mockRepository.getLatestRelease(any, any));
    });

    test('should return failure when getLatestRelease fails', () async {
      // Arrange
      when(
        mockRepository.getCurrentVersion(),
      ).thenAnswer((_) async => success(tCurrentVersion));
      when(mockRepository.getLatestRelease('owner', 'repo')).thenAnswer(
        (_) async => failure(AppUpdateFailure.versionCheckFailed('Not found')),
      );

      // Act
      final result = await useCase(
        const CheckAppUpdateParams(owner: 'owner', repo: 'repo'),
      );

      // Assert
      expect(result.isError(), true);
      verify(mockRepository.getCurrentVersion()).called(1);
      verify(mockRepository.getLatestRelease('owner', 'repo')).called(1);
    });
  });
}
