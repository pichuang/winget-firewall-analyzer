"""測試 — 下載腳本產生器"""

from __future__ import annotations

from src.download_scripts import (
    _filename_from_url,
    generate_download_bash,
    generate_download_ps1,
)
from src.models import InstallerInfo, PackageManifest


def _make_manifests() -> list[PackageManifest]:
    return [
        PackageManifest(
            package_id="Microsoft.Git",
            version="2.48.0.vfs.0.0",
            publisher="Microsoft Corporation",
            installers=[
                InstallerInfo(
                    url="https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-64-bit.exe",
                    architecture="x64",
                    scope="user",
                ),
                InstallerInfo(
                    url="https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-arm64.exe",
                    architecture="arm64",
                    scope="machine",
                ),
            ],
        ),
        PackageManifest(
            package_id="GitHub.cli",
            version="2.92.0",
            publisher="GitHub",
            installers=[
                InstallerInfo(
                    url="https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.msi",
                    architecture="x64",
                    scope="machine",
                ),
            ],
        ),
    ]


class TestFilenameFromUrl:
    """測試 URL 檔名擷取"""

    def test_exe(self) -> None:
        assert _filename_from_url(
            "https://github.com/git/releases/download/v2.54.0/Git-2.54.0-64-bit.exe"
        ) == "Git-2.54.0-64-bit.exe"

    def test_msi(self) -> None:
        assert _filename_from_url(
            "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.msi"
        ) == "gh_2.92.0_windows_amd64.msi"

    def test_no_path(self) -> None:
        assert _filename_from_url("https://example.com/") == "installer"


class TestGenerateDownloadBash:
    """測試 Bash 下載腳本"""

    def test_has_shebang(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert output.startswith("#!/bin/bash")

    def test_contains_package_sections(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "Microsoft.Git v2.48.0.vfs.0.0" in output
        assert "GitHub.cli v2.92.0" in output

    def test_contains_curl_commands(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "curl -fSL" in output

    def test_contains_installer_urls(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "Git-2.48.0.vfs.0.0-64-bit.exe" in output
        assert "Git-2.48.0.vfs.0.0-arm64.exe" in output
        assert "gh_2.92.0_windows_amd64.msi" in output

    def test_creates_directories(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "mkdir -p" in output

    def test_skips_existing(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "已存在" in output

    def test_has_summary(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "下載結果摘要" in output

    def test_contains_architecture_info(self) -> None:
        output = generate_download_bash(_make_manifests())
        assert "x64" in output
        assert "arm64" in output


class TestGenerateDownloadPs1:
    """測試 PowerShell 下載腳本"""

    def test_contains_package_sections(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "Microsoft.Git v2.48.0.vfs.0.0" in output
        assert "GitHub.cli v2.92.0" in output

    def test_contains_invoke_webrequest(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "Invoke-WebRequest" in output

    def test_contains_installer_urls(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "Git-2.48.0.vfs.0.0-64-bit.exe" in output
        assert "gh_2.92.0_windows_amd64.msi" in output

    def test_creates_directories(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "New-Item -ItemType Directory" in output

    def test_skips_existing(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "Test-Path" in output
        assert "已存在" in output

    def test_has_summary(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "下載結果摘要" in output

    def test_uses_backslash_paths(self) -> None:
        output = generate_download_ps1(_make_manifests())
        assert "Microsoft\\Git" in output
