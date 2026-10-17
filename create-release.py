#!/usr/bin/env python3
"""Build and optionally publish a GitHub release.

Typical internal APK build:
    python create-release.py

Full publish flow:
    python create-release.py --publish

Production-signed build:
    python create-release.py --require-release-signing --artifact both
"""

from __future__ import annotations

import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VERSION_PATTERN = re.compile(
    r"^\s*version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$",
    re.MULTILINE,
)


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def run(args: list[str], cwd: Path | None = None) -> int:
    command = list(args)
    found = shutil.which(command[0])
    if found is not None:
        command[0] = found

    use_shell = os.name == "nt" and command[0].lower().endswith((".bat", ".cmd"))
    completed = subprocess.run(command, cwd=cwd, check=False, shell=use_shell)
    return completed.returncode


def run_step(name: str, args: list[str], cwd: Path | None = None) -> None:
    print()
    print(f"==> {name}")
    try:
        exit_code = run(args, cwd=cwd)
    except FileNotFoundError:
        fail(f"{name} failed because '{args[0]}' was not found")
    if exit_code != 0:
        fail(f"{name} failed with exit code {exit_code}")


def capture(args: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        args,
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )


def ensure_command(name: str, install_hint: str) -> None:
    if shutil.which(name) is None:
        fail(f"{name} was not found. {install_hint}")


def read_pubspec_version() -> tuple[str, str]:
    pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    match = VERSION_PATTERN.search(pubspec)
    if match is None:
        fail("Could not find a semantic version with build number in pubspec.yaml")
    return match.group(1), match.group(2)


def ensure_clean_git(allow_dirty: bool) -> None:
    status = capture(["git", "status", "--porcelain"])
    if status.returncode != 0:
        fail("git status failed")
    if not allow_dirty and status.stdout.strip():
        fail(
            "Git worktree is dirty. Commit/stash changes or pass "
            "--allow-dirty for local build only."
        )


def copy_artifact(source: Path, destination: Path) -> None:
    if not source.is_file():
        fail(f"Expected artifact not found: {source}")

    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, destination)
    digest = hashlib.sha256(destination.read_bytes()).hexdigest()
    sidecar = f"{digest}  {destination.name}\n"
    Path(f"{destination}.sha256").write_text(sidecar, encoding="utf-8")
    print(f"Artifact: {destination}")
    print(f"SHA256:  {digest}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build and optionally publish a GitHub release.")
    parser.add_argument("--tag", default="", help="Release tag. Defaults to the pubspec version.")
    parser.add_argument("--owner", default="cesar-carlos")
    parser.add_argument("--repo", default="flutter-expedicao-app")
    parser.add_argument("--artifact", choices=("apk", "appbundle", "both"), default="apk")
    parser.add_argument("--publish", action="store_true")
    parser.add_argument("--draft", action="store_true")
    parser.add_argument("--prerelease", action="store_true")
    parser.add_argument("--skip-tests", action="store_true")
    parser.add_argument("--skip-build", action="store_true")
    parser.add_argument("--require-release-signing", action="store_true")
    parser.add_argument("--allow-dirty", action="store_true")
    parser.add_argument("--no-push", action="store_true")
    return parser.parse_args()


def main() -> None:
    os.chdir(ROOT)
    args = parse_args()

    version_name, build_number = read_pubspec_version()
    tag = args.tag.strip() or f"v{version_name}+{build_number}"
    expected_tag = f"v{version_name}+{build_number}"
    if tag != expected_tag:
        fail(f"Tag '{tag}' does not match pubspec version '{expected_tag}'")

    release_notes = ROOT / "docs" / "release" / f"RELEASE_NOTES_{tag}.md"
    if not release_notes.is_file():
        fail(f"Release notes not found: {release_notes}")

    release_dir = ROOT / "dist" / "release" / tag
    release_dir.mkdir(parents=True, exist_ok=True)

    print(f"Release: {tag}")
    print(f"Version: {version_name}+{build_number}")
    print(f"Notes:   {release_notes}")
    print(f"Output:  {release_dir}")

    ensure_command("flutter", "Install Flutter and add it to PATH.")
    ensure_command("git", "Install Git and add it to PATH.")

    if args.publish:
        ensure_command("gh", "Install GitHub CLI and run 'gh auth login'.")
        if args.artifact == "appbundle":
            fail(
                "GitHub auto-update requires an APK asset. "
                "Use --artifact apk or --artifact both when publishing."
            )
        ensure_clean_git(args.allow_dirty)

    if not args.skip_tests:
        run_step("flutter analyze", ["flutter", "analyze", "--fatal-infos", "--fatal-warnings"])
        run_step("flutter test", ["flutter", "test"])
        gradle = "gradlew.bat" if os.name == "nt" else "./gradlew"
        # AGP 9.1 lint workers fail with ClassNotFoundException for
        # org.jetbrains.kotlin.config.LanguageVersionSettings.
        run_step(
            "Android unit tests",
            [gradle, ":app:testDebugUnitTest"],
            cwd=ROOT / "android",
        )

    if not args.skip_build:
        previous_signing = os.environ.get("REQUIRE_RELEASE_SIGNING")
        if args.require_release_signing:
            os.environ["REQUIRE_RELEASE_SIGNING"] = "true"
        try:
            if args.artifact in {"apk", "both"}:
                run_step("flutter build apk --release", ["flutter", "build", "apk", "--release"])
            if args.artifact in {"appbundle", "both"}:
                run_step(
                    "flutter build appbundle --release",
                    ["flutter", "build", "appbundle", "--release"],
                )
        finally:
            if previous_signing is None:
                os.environ.pop("REQUIRE_RELEASE_SIGNING", None)
            else:
                os.environ["REQUIRE_RELEASE_SIGNING"] = previous_signing

    release_assets: list[Path] = []
    if args.artifact in {"apk", "both"}:
        apk_destination = release_dir / f"data7-expedicao-{tag}.apk"
        copy_artifact(ROOT / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk", apk_destination)
        release_assets.append(apk_destination)

    if args.artifact in {"appbundle", "both"}:
        aab_destination = release_dir / f"data7-expedicao-{tag}.aab"
        copy_artifact(
            ROOT / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab",
            aab_destination,
        )
        release_assets.append(aab_destination)

    if args.publish:
        branch = capture(["git", "branch", "--show-current"])
        current_branch = branch.stdout.strip()
        if branch.returncode != 0 or not current_branch:
            fail("Could not determine current git branch.")

        local_tag = capture(["git", "tag", "--list", tag])
        if local_tag.returncode != 0:
            fail("git tag --list failed")
        if not local_tag.stdout.strip():
            run_step("Create git tag", ["git", "tag", "-a", tag, "-m", f"Release {tag}"])

        if not args.no_push:
            run_step("Push branch", ["git", "push", "origin", current_branch])
            run_step("Push tag", ["git", "push", "origin", tag])

        repo = f"{args.owner}/{args.repo}"
        release_view = capture(["gh", "release", "view", tag, "--repo", repo])
        if release_view.returncode == 0:
            upload_args = ["gh", "release", "upload", tag, "--repo", repo, "--clobber"]
            upload_args.extend(str(asset) for asset in release_assets)
            run_step("Upload assets to existing GitHub release", upload_args)
        else:
            create_args = [
                "gh",
                "release",
                "create",
                tag,
                "--repo",
                repo,
                "--title",
                f"Release {tag}",
                "--notes-file",
                str(release_notes),
            ]
            if args.draft:
                create_args.append("--draft")
            if args.prerelease:
                create_args.append("--prerelease")
            create_args.extend(str(asset) for asset in release_assets)
            run_step("Create GitHub release", create_args)

    print()
    print(f"Release package ready: {release_dir}")
    print(f"Tag: {tag}")


if __name__ == "__main__":
    main()
