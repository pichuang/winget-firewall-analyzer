"""測試 — winget API manifest 查詢（使用 mock）"""

from __future__ import annotations

import json
from unittest.mock import AsyncMock

import httpx
import pytest

from src.winget_api import (
    _build_manifest_path,
    _parse_version_key,
    fetch_installer_manifest,
    list_versions,
)


class TestBuildManifestPath:
    """測試 manifest 路徑建構"""

    def test_two_part_id(self) -> None:
        assert _build_manifest_path("Git.Git") == "manifests/g/Git/Git"

    def test_github_cli(self) -> None:
        assert _build_manifest_path("GitHub.cli") == "manifests/g/GitHub/cli"

    def test_github_desktop(self) -> None:
        assert _build_manifest_path("GitHub.GitHubDesktop") == "manifests/g/GitHub/GitHubDesktop"

    def test_microsoft_vscode(self) -> None:
        assert _build_manifest_path("Microsoft.VisualStudioCode") == "manifests/m/Microsoft/VisualStudioCode"

    def test_three_part_id(self) -> None:
        assert _build_manifest_path("Microsoft.Azure.StorageExplorer") == "manifests/m/Microsoft/Azure/StorageExplorer"


class TestParseVersionKey:
    """測試版本號排序"""

    def test_numeric_versions_sort_correctly(self) -> None:
        versions = ["2.25.1", "2.54.0", "2.24.1.2", "2.26.2"]
        sorted_versions = sorted(versions, key=_parse_version_key)
        assert sorted_versions[-1] == "2.54.0"
        assert sorted_versions[0] == "2.24.1.2"

    def test_non_numeric_sorts_after_numeric(self) -> None:
        versions = ["2.54.0", "PreRelease", "Beta"]
        sorted_versions = sorted(versions, key=_parse_version_key)
        # 數字版本排在前面
        assert sorted_versions[0] == "2.54.0"


class TestListVersions:
    """測試版本列表查詢"""

    @pytest.mark.asyncio
    async def test_list_versions_filters_directories(self) -> None:
        mock_response = httpx.Response(
            200,
            json=[
                {"name": "2.54.0", "type": "dir"},
                {"name": "2.53.0", "type": "dir"},
                {"name": "PreRelease", "type": "dir"},
                {"name": ".gitkeep", "type": "file"},
            ],
            request=httpx.Request("GET", "https://example.com"),
        )

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(return_value=mock_response)

        versions = await list_versions(client, "Git.Git")
        assert versions == ["2.53.0", "2.54.0"]
        assert "PreRelease" not in versions


class TestFetchInstallerManifest:
    """測試 installer manifest 解析"""

    SAMPLE_INSTALLER_YAML = """\
PackageIdentifier: Git.Git
PackageVersion: 2.54.0
InstallerType: inno
Installers:
- Architecture: x64
  Scope: user
  InstallerUrl: https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe
  InstallerSha256: ABC123
- Architecture: x64
  Scope: machine
  InstallerUrl: https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe
  InstallerSha256: ABC123
- Architecture: arm64
  Scope: user
  InstallerUrl: https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-arm64.exe
  InstallerSha256: DEF456
"""

    @pytest.mark.asyncio
    async def test_parse_manifest_deduplicates_urls(self) -> None:
        mock_response = httpx.Response(
            200,
            text=self.SAMPLE_INSTALLER_YAML,
            request=httpx.Request("GET", "https://example.com"),
        )

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(return_value=mock_response)

        manifest = await fetch_installer_manifest(client, "Git.Git", "2.54.0")

        assert manifest.package_id == "Git.Git"
        assert manifest.version == "2.54.0"
        # 同一 URL 應去重（x64 user 和 machine 的 URL 相同）
        assert len(manifest.installers) == 2
        urls = {inst.url for inst in manifest.installers}
        assert "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe" in urls
        assert "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-arm64.exe" in urls

    @pytest.mark.asyncio
    async def test_parse_manifest_extracts_architecture(self) -> None:
        mock_response = httpx.Response(
            200,
            text=self.SAMPLE_INSTALLER_YAML,
            request=httpx.Request("GET", "https://example.com"),
        )

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(return_value=mock_response)

        manifest = await fetch_installer_manifest(client, "Git.Git", "2.54.0")

        architectures = {inst.architecture for inst in manifest.installers}
        assert "x64" in architectures
        assert "arm64" in architectures
