# Android Release Signing Guide

## Current Behavior

`android/app/build.gradle.kts` supports production signing through
`android/key.properties`.

If `android/key.properties` is not present, release builds fall back to the
debug signing key so internal APK builds remain possible. This fallback is only
acceptable for local tests and direct internal validation.

For production or store builds, force the build to fail unless release signing
is configured:

```powershell
$env:REQUIRE_RELEASE_SIGNING = "true"
flutter build apk --release
```

The release helper script exposes the same check:

```powershell
.\create-release.ps1 -RequireReleaseSigning
```

## Generated Files

APK:

```text
build/app/outputs/flutter-apk/app-release.apk
```

AAB:

```text
build/app/outputs/bundle/release/app-release.aab
```

Versioned release copies created by the script:

```text
dist/release/vX.Y.Z+B/data7-expedicao-vX.Y.Z+B.apk
dist/release/vX.Y.Z+B/data7-expedicao-vX.Y.Z+B.aab
```

Each versioned artifact also gets a `.sha256` file.

## Configure Production Signing

Create the upload keystore outside the repository or in a path ignored by Git:

```powershell
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:

```properties
storePassword=<keystore-password>
keyPassword=<key-password>
keyAlias=upload
storeFile=../upload-keystore.jks
```

Rules:

- Do not commit `key.properties`.
- Do not commit `.jks`, `.keystore`, or password files.
- Keep a backup of the keystore. Losing it can block future updates.
- Use `-RequireReleaseSigning` in production release builds.

## Build Commands

Internal APK with fallback signing:

```powershell
flutter build apk --release
```

Production-signed APK:

```powershell
.\create-release.ps1 -RequireReleaseSigning
```

Production-signed APK and AAB:

```powershell
.\create-release.ps1 -RequireReleaseSigning -Artifact both
```

## Verify Signing

APK:

```powershell
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

AAB:

```powershell
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## Versioning

Update `pubspec.yaml` before each release:

```yaml
version: 2.1.3+4
```

The semantic version becomes Android `versionName`; the build number becomes
Android `versionCode`. The build number must always increase for Android
updates.
