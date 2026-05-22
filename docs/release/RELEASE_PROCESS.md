# Release Process

## Goals

The Android release flow must be repeatable, traceable, and compatible with the
GitHub auto-update system.

The app auto-update expects:

- `pubspec.yaml` with a higher `version: X.Y.Z+B`.
- Git tag in the format `vX.Y.Z+B`.
- GitHub Release published from that tag.
- An attached `.apk` asset.

## Standard Flow

1. Update `pubspec.yaml`.
2. Add release notes at `docs/release/RELEASE_NOTES_vX.Y.Z+B.md`.
3. Commit the version bump and release notes.
4. Run the release script:

   ```powershell
   .\create-release.ps1 -Publish
   ```

5. Validate the GitHub Release and attached APK.
6. Install a previous build on an Android device and validate auto-update.

## Production-Signed Flow

Use this when `android/key.properties` is configured:

```powershell
.\create-release.ps1 -Publish -RequireReleaseSigning -Artifact both
```

This builds:

- APK for direct install and GitHub auto-update.
- AAB for Play Store or store-like distribution.

## Script Behavior

`create-release.ps1` performs these checks and actions:

- Reads `version` from `pubspec.yaml`.
- Derives the expected tag `vX.Y.Z+B`.
- Validates that matching release notes exist.
- Runs `flutter analyze --fatal-infos --fatal-warnings`.
- Runs `flutter test`.
- Runs Android unit tests and lint.
- Builds APK and optionally AAB.
- Copies artifacts to `dist/release/vX.Y.Z+B/` with versioned filenames.
- Writes SHA-256 sidecar files.
- Creates/pushes the tag when publishing.
- Creates or updates the GitHub Release assets through `gh`.

## Release Checklist

Use this checklist before publishing:

- `pubspec.yaml` has a new semantic version and higher build number.
- Release notes describe user-facing changes, scanner/camera changes, and
  validation scope.
- `flutter analyze --fatal-infos --fatal-warnings` passes.
- `flutter test` passes.
- `.\gradlew.bat :app:testDebugUnitTest :app:lintDebug` passes in `android/`.
- `flutter build apk --release` passes.
- For production: `.\create-release.ps1 -RequireReleaseSigning` passes.
- APK asset is attached to the GitHub Release.
- GitHub asset SHA-256 matches the local SHA-256.
- Auto-update is tested from an older build on a real Android device.
- QR login is tested with success, cancel, permission denied, and invalid QR.
- Scanner broadcast is tested with the target collector configuration.
- Shelf scan is tested with addresses containing hyphen and dot.
- Picking scan and finalization are regression-tested.

## Rollback

If a release is published with the wrong APK:

1. Upload the corrected APK with the same filename using `gh release upload
   vX.Y.Z+B <apk> --clobber`.
2. Keep the tag unchanged if the app version did not change.
3. Create a new build number only when the installed app must detect a newer
   update than the already-published build.
