"""整合測試 — 使用真實 API 驗證完整流程（標記為 slow，需網路連線）"""

from __future__ import annotations

import httpx
import pytest

from src.redirect_tracer import trace_redirects
from src.rule_generator import generate_rules
from src.winget_api import fetch_package


@pytest.mark.slow
class TestIntegrationGitGit:
    """整合測試：Git.Git 套件"""

    @pytest.mark.asyncio
    async def test_fetch_and_trace_git(self) -> None:
        async with httpx.AsyncClient(follow_redirects=False, timeout=30.0) as client:
            manifest = await fetch_package(client, "Git.Git")

            assert manifest.package_id == "Git.Git"
            assert len(manifest.installers) > 0

            # 追蹤第一個 installer 的重導向
            first_installer = manifest.installers[0]
            first_installer.redirect_chain = await trace_redirects(client, first_installer.url)

            assert len(first_installer.redirect_chain) >= 1
            # GitHub release 應該有重導向
            fqdns = {hop.fqdn for hop in first_installer.redirect_chain}
            assert "github.com" in fqdns

            # 產生規則
            path_rule, fqdn_rule = generate_rules(
                manifest, source_addresses=["10.0.0.0/8"]
            )
            assert len(fqdn_rule.target_fqdns) > 0


@pytest.mark.slow
class TestIntegrationGitHubCli:
    """整合測試：GitHub.cli 套件"""

    @pytest.mark.asyncio
    async def test_fetch_and_trace_gh_cli(self) -> None:
        async with httpx.AsyncClient(follow_redirects=False, timeout=30.0) as client:
            manifest = await fetch_package(client, "GitHub.cli")

            assert manifest.package_id == "GitHub.cli"
            assert len(manifest.installers) > 0

            first_installer = manifest.installers[0]
            first_installer.redirect_chain = await trace_redirects(client, first_installer.url)

            fqdns = {hop.fqdn for hop in first_installer.redirect_chain}
            assert "github.com" in fqdns


@pytest.mark.slow
class TestIntegrationGitHubDesktop:
    """整合測試：GitHub.GitHubDesktop 套件"""

    @pytest.mark.asyncio
    async def test_fetch_and_trace_github_desktop(self) -> None:
        async with httpx.AsyncClient(follow_redirects=False, timeout=30.0) as client:
            manifest = await fetch_package(client, "GitHub.GitHubDesktop")

            assert manifest.package_id == "GitHub.GitHubDesktop"
            assert len(manifest.installers) > 0

            first_installer = manifest.installers[0]
            first_installer.redirect_chain = await trace_redirects(client, first_installer.url)

            # GitHubDesktop 從 desktop.githubusercontent.com 下載
            fqdns = {hop.fqdn for hop in first_installer.redirect_chain}
            assert len(fqdns) >= 1
