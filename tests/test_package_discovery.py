"""測試 — 套件探索模組（使用 mock）"""

from __future__ import annotations

from unittest.mock import AsyncMock

import httpx
import pytest

from src.package_discovery import (
    _is_package_dir,
    _path_to_package_id,
    discover_all_packages,
    discover_packages_under_prefix,
)


class TestPathToPackageId:
    """測試路徑轉換"""

    def test_two_level(self) -> None:
        assert _path_to_package_id("manifests/g/Git/Git") == "Git.Git"

    def test_three_level(self) -> None:
        assert _path_to_package_id("manifests/g/GitHub/GitHubDesktop") == "GitHub.GitHubDesktop"

    def test_deep_level(self) -> None:
        result = _path_to_package_id("manifests/m/Microsoft/VisualStudio/2022/Community")
        assert result == "Microsoft.VisualStudio.2022.Community"


class TestIsPackageDir:
    """測試 leaf 套件目錄判斷"""

    @pytest.mark.asyncio
    async def test_version_dirs_means_leaf(self) -> None:
        children = [
            {"name": "2.54.0", "type": "dir"},
            {"name": "2.53.0", "type": "dir"},
        ]
        client = AsyncMock(spec=httpx.AsyncClient)
        assert await _is_package_dir(client, "any/path", children) is True

    @pytest.mark.asyncio
    async def test_named_dirs_means_not_leaf(self) -> None:
        children = [
            {"name": "SubPackageA", "type": "dir"},
            {"name": "SubPackageB", "type": "dir"},
        ]
        client = AsyncMock(spec=httpx.AsyncClient)
        assert await _is_package_dir(client, "any/path", children) is False

    @pytest.mark.asyncio
    async def test_mixed_with_version_is_leaf(self) -> None:
        children = [
            {"name": "2.54.0", "type": "dir"},
            {"name": "PreRelease", "type": "dir"},
        ]
        client = AsyncMock(spec=httpx.AsyncClient)
        assert await _is_package_dir(client, "any/path", children) is True

    @pytest.mark.asyncio
    async def test_empty_dir_not_leaf(self) -> None:
        client = AsyncMock(spec=httpx.AsyncClient)
        assert await _is_package_dir(client, "any/path", []) is False


class TestDiscoverPackagesUnderPrefix:
    """測試遞迴套件探索"""

    @pytest.mark.asyncio
    async def test_discovers_leaf_packages(self) -> None:
        """模擬 GitHub 下有 cli 和 GitHubDesktop 兩個 leaf 套件"""
        # manifests/g/GitHub/ → [cli, GitHubDesktop]
        github_root = [
            {"name": "cli", "type": "dir"},
            {"name": "GitHubDesktop", "type": "dir"},
        ]
        # manifests/g/GitHub/cli/ → [2.91.0, 2.92.0]（leaf）
        cli_dir = [
            {"name": "2.91.0", "type": "dir"},
            {"name": "2.92.0", "type": "dir"},
        ]
        # manifests/g/GitHub/GitHubDesktop/ → [3.5.7, 3.5.8]（leaf）
        desktop_dir = [
            {"name": "3.5.7", "type": "dir"},
            {"name": "3.5.8", "type": "dir"},
        ]

        def mock_get(url: str, **kwargs) -> httpx.Response:
            if url.endswith("manifests/g/GitHub"):
                return httpx.Response(200, json=github_root, request=httpx.Request("GET", url))
            elif url.endswith("manifests/g/GitHub/cli"):
                return httpx.Response(200, json=cli_dir, request=httpx.Request("GET", url))
            elif url.endswith("manifests/g/GitHub/GitHubDesktop"):
                return httpx.Response(200, json=desktop_dir, request=httpx.Request("GET", url))
            return httpx.Response(404, request=httpx.Request("GET", url))

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(side_effect=mock_get)

        packages = await discover_packages_under_prefix(client, "GitHub")

        assert sorted(packages) == ["GitHub.GitHubDesktop", "GitHub.cli"]

    @pytest.mark.asyncio
    async def test_discovers_nested_packages(self) -> None:
        """模擬多層嵌套（如 Microsoft.VisualStudio.2022.Community）"""
        # manifests/m/Microsoft/ → [VisualStudio]
        ms_root = [{"name": "VisualStudio", "type": "dir"}]
        # manifests/m/Microsoft/VisualStudio/ → [2022]（非 leaf，"2022" 不是 x.y 版本）
        vs_dir = [{"name": "2022", "type": "dir"}]
        # manifests/m/Microsoft/VisualStudio/2022/ → [Community, Enterprise]
        vs_2022 = [
            {"name": "Community", "type": "dir"},
            {"name": "Enterprise", "type": "dir"},
        ]
        # leaf 套件含版本目錄（x.y.z 格式）
        community_dir = [{"name": "17.0.0", "type": "dir"}]
        enterprise_dir = [{"name": "17.0.0", "type": "dir"}]

        def mock_get(url: str, **kwargs) -> httpx.Response:
            path_map = {
                "manifests/m/Microsoft": ms_root,
                "manifests/m/Microsoft/VisualStudio": vs_dir,
                "manifests/m/Microsoft/VisualStudio/2022": vs_2022,
                "manifests/m/Microsoft/VisualStudio/2022/Community": community_dir,
                "manifests/m/Microsoft/VisualStudio/2022/Enterprise": enterprise_dir,
            }
            for key, val in path_map.items():
                if url.endswith(key):
                    return httpx.Response(200, json=val, request=httpx.Request("GET", url))
            return httpx.Response(404, request=httpx.Request("GET", url))

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(side_effect=mock_get)

        packages = await discover_packages_under_prefix(client, "Microsoft")

        assert sorted(packages) == [
            "Microsoft.VisualStudio.2022.Community",
            "Microsoft.VisualStudio.2022.Enterprise",
        ]


class TestDiscoverAllPackages:
    """測試 allowlist 模式探索"""

    @pytest.mark.asyncio
    async def test_wildcard_and_exact(self) -> None:
        """模擬 GitHub.* 萬用字元 + 精確 ID"""
        github_root = [{"name": "cli", "type": "dir"}]
        cli_dir = [{"name": "2.92.0", "type": "dir"}]

        def mock_get(url: str, **kwargs) -> httpx.Response:
            if url.endswith("manifests/g/GitHub"):
                return httpx.Response(200, json=github_root, request=httpx.Request("GET", url))
            elif url.endswith("manifests/g/GitHub/cli"):
                return httpx.Response(200, json=cli_dir, request=httpx.Request("GET", url))
            return httpx.Response(404, request=httpx.Request("GET", url))

        client = AsyncMock(spec=httpx.AsyncClient)
        client.get = AsyncMock(side_effect=mock_get)

        packages = await discover_all_packages(client, ["GitHub.*", "Git.Git"])

        assert "GitHub.cli" in packages
        assert "Git.Git" in packages
