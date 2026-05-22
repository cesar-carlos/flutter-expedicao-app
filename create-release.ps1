# Builds and optionally publishes a GitHub release.
#
# Typical internal APK build:
#   .\create-release.ps1
#
# Full publish flow:
#   .\create-release.ps1 -Publish
#
# Production-signed build:
#   .\create-release.ps1 -RequireReleaseSigning -Artifact both

[CmdletBinding()]
param(
    [string]$Tag = "",
    [string]$Owner = "cesar-carlos",
    [string]$Repo = "flutter-expedicao-app",
    [ValidateSet("apk", "appbundle", "both")]
    [string]$Artifact = "apk",
    [switch]$Publish,
    [switch]$Draft,
    [switch]$Prerelease,
    [switch]$SkipTests,
    [switch]$SkipBuild,
    [switch]$RequireReleaseSigning,
    [switch]$AllowDirty,
    [switch]$NoPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

function Run-Step([string]$Name, [scriptblock]$Command) {
    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
    & $Command

    if ($LASTEXITCODE -ne 0) {
        Fail "$Name failed with exit code $LASTEXITCODE"
    }
}

function Get-PubspecVersion {
    $pubspecLine = Select-String -Path "pubspec.yaml" -Pattern "^\s*version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$" | Select-Object -First 1
    if ($null -eq $pubspecLine) {
        Fail "Could not find a semantic version with build number in pubspec.yaml"
    }

    return @{
        Version = $pubspecLine.Matches[0].Groups[1].Value
        Build = $pubspecLine.Matches[0].Groups[2].Value
    }
}

function Ensure-Command([string]$CommandName, [string]$InstallHint) {
    if ($null -eq (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Fail "$CommandName was not found. $InstallHint"
    }
}

function Ensure-CleanGit {
    $status = git status --porcelain
    if (-not $AllowDirty -and -not [string]::IsNullOrWhiteSpace($status)) {
        Fail "Git worktree is dirty. Commit/stash changes or pass -AllowDirty for local build only."
    }
}

function Copy-Artifact([string]$Source, [string]$Destination) {
    if (-not (Test-Path $Source)) {
        Fail "Expected artifact not found: $Source"
    }

    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    $hash = Get-FileHash -LiteralPath $Destination -Algorithm SHA256
    $hashLine = "$($hash.Hash.ToLowerInvariant())  $(Split-Path -Leaf $Destination)"
    Set-Content -LiteralPath "$Destination.sha256" -Value $hashLine -Encoding utf8
    Write-Host "Artifact: $Destination" -ForegroundColor Green
    Write-Host "SHA256:  $($hash.Hash.ToLowerInvariant())" -ForegroundColor Green
}

$pubspecVersion = Get-PubspecVersion
$versionName = $pubspecVersion.Version
$buildNumber = $pubspecVersion.Build

if ([string]::IsNullOrWhiteSpace($Tag)) {
    $Tag = "v$versionName+$buildNumber"
}

$expectedTag = "v$versionName+$buildNumber"
if ($Tag -ne $expectedTag) {
    Fail "Tag '$Tag' does not match pubspec version '$expectedTag'"
}

$releaseNotesPath = "docs\release\RELEASE_NOTES_$Tag.md"
if (-not (Test-Path $releaseNotesPath)) {
    Fail "Release notes not found: $releaseNotesPath"
}

$releaseDir = Join-Path "dist\release" $Tag
New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null

Write-Host "Release: $Tag" -ForegroundColor Cyan
Write-Host "Version: $versionName+$buildNumber" -ForegroundColor Cyan
Write-Host "Notes:   $releaseNotesPath" -ForegroundColor Cyan
Write-Host "Output:  $releaseDir" -ForegroundColor Cyan

Ensure-Command "flutter" "Install Flutter and add it to PATH."
Ensure-Command "git" "Install Git and add it to PATH."

if ($Publish) {
    Ensure-Command "gh" "Install GitHub CLI and run 'gh auth login'."
    if ($Artifact -eq "appbundle") {
        Fail "GitHub auto-update requires an APK asset. Use -Artifact apk or -Artifact both when publishing."
    }
    Ensure-CleanGit
}

if (-not $SkipTests) {
    Run-Step "flutter analyze" { flutter analyze --fatal-infos --fatal-warnings }
    Run-Step "flutter test" { flutter test }
    Run-Step "Android unit tests and lint" {
        Push-Location android
        try {
            .\gradlew.bat :app:testDebugUnitTest :app:lintDebug
        } finally {
            Pop-Location
        }
    }
}

if (-not $SkipBuild) {
    $previousRequireReleaseSigning = $env:REQUIRE_RELEASE_SIGNING
    if ($RequireReleaseSigning) {
        $env:REQUIRE_RELEASE_SIGNING = "true"
    }

    try {
        if ($Artifact -eq "apk" -or $Artifact -eq "both") {
            Run-Step "flutter build apk --release" { flutter build apk --release }
        }

        if ($Artifact -eq "appbundle" -or $Artifact -eq "both") {
            Run-Step "flutter build appbundle --release" { flutter build appbundle --release }
        }
    } finally {
        $env:REQUIRE_RELEASE_SIGNING = $previousRequireReleaseSigning
    }
}

$releaseAssets = New-Object System.Collections.Generic.List[string]

if ($Artifact -eq "apk" -or $Artifact -eq "both") {
    $apkDestination = Join-Path $releaseDir "data7-expedicao-$Tag.apk"
    Copy-Artifact "build\app\outputs\flutter-apk\app-release.apk" $apkDestination
    $releaseAssets.Add($apkDestination)
}

if ($Artifact -eq "appbundle" -or $Artifact -eq "both") {
    $aabDestination = Join-Path $releaseDir "data7-expedicao-$Tag.aab"
    Copy-Artifact "build\app\outputs\bundle\release\app-release.aab" $aabDestination
    $releaseAssets.Add($aabDestination)
}

if ($Publish) {
    $currentBranch = git branch --show-current
    if ([string]::IsNullOrWhiteSpace($currentBranch)) {
        Fail "Could not determine current git branch."
    }

    $localTagExists = git tag --list $Tag
    if ([string]::IsNullOrWhiteSpace($localTagExists)) {
        Run-Step "Create git tag $Tag" { git tag -a $Tag -m "Release $Tag" }
    }

    if (-not $NoPush) {
        Run-Step "Push branch $currentBranch" { git push origin $currentBranch }
        Run-Step "Push tag $Tag" { git push origin $Tag }
    }

    $releaseExists = $true
    gh release view $Tag --repo "$Owner/$Repo" *> $null
    if ($LASTEXITCODE -ne 0) {
        $releaseExists = $false
    }

    if ($releaseExists) {
        $uploadArgs = @("release", "upload", $Tag, "--repo", "$Owner/$Repo", "--clobber")
        foreach ($asset in $releaseAssets) {
            $uploadArgs += $asset
        }
        Run-Step "Upload assets to existing GitHub release" { gh @uploadArgs }
    } else {
        $createArgs = @(
            "release", "create", $Tag,
            "--repo", "$Owner/$Repo",
            "--title", "Release $Tag",
            "--notes-file", $releaseNotesPath
        )

        if ($Draft) {
            $createArgs += "--draft"
        }

        if ($Prerelease) {
            $createArgs += "--prerelease"
        }

        foreach ($asset in $releaseAssets) {
            $createArgs += $asset
        }

        Run-Step "Create GitHub release" { gh @createArgs }
    }
}

Write-Host ""
Write-Host "Release package ready: $releaseDir" -ForegroundColor Green
Write-Host "Tag: $Tag" -ForegroundColor Green
