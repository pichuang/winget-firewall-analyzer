"""測試 — Azure Firewall 規則產生器"""

from __future__ import annotations

from src.models import (
    Confidence,
    FqdnCategory,
    InstallerInfo,
    PackageManifest,
    RedirectHop,
)
from src.rule_generator import (
    _classify_fqdn,
    collect_fqdn_entries,
    generate_base_infrastructure_rule,
    generate_rules,
)


class TestClassifyFqdn:
    """測試 FQDN 分類"""

    def test_github_com(self) -> None:
        assert _classify_fqdn("github.com") == FqdnCategory.DOWNLOAD

    def test_githubusercontent(self) -> None:
        assert _classify_fqdn("release-assets.githubusercontent.com") == FqdnCategory.CDN

    def test_desktop_githubusercontent(self) -> None:
        assert _classify_fqdn("desktop.githubusercontent.com") == FqdnCategory.CDN

    def test_winget_cdn(self) -> None:
        assert _classify_fqdn("cdn.winget.microsoft.com") == FqdnCategory.WINGET_SOURCE

    def test_winget_azureedge(self) -> None:
        assert _classify_fqdn("winget.azureedge.net") == FqdnCategory.WINGET_SOURCE

    def test_ms_delivery(self) -> None:
        assert _classify_fqdn("tlu.dl.delivery.mp.microsoft.com") == FqdnCategory.CDN

    def test_login(self) -> None:
        assert _classify_fqdn("login.microsoftonline.com") == FqdnCategory.AUTH

    def test_unknown(self) -> None:
        assert _classify_fqdn("random-domain.example.com") == FqdnCategory.UNKNOWN


def _make_test_manifest() -> PackageManifest:
    """建立測試用 manifest（模擬 Git.Git）"""
    return PackageManifest(
        package_id="Git.Git",
        version="2.54.0",
        publisher="Git",
        installers=[
            InstallerInfo(
                url="https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe",
                architecture="x64",
                scope="user",
                installer_type="inno",
                redirect_chain=[
                    RedirectHop(
                        url="https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe",
                        fqdn="github.com",
                        path="/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe",
                        status_code=302,
                        is_final=False,
                    ),
                    RedirectHop(
                        url="https://release-assets.githubusercontent.com/github-production-release-asset/23216272/some-uuid",
                        fqdn="release-assets.githubusercontent.com",
                        path="/github-production-release-asset/23216272/some-uuid",
                        status_code=200,
                        is_final=True,
                    ),
                ],
            ),
        ],
    )


class TestCollectFqdnEntries:
    """測試 FQDN 收集"""

    def test_collects_all_fqdns(self) -> None:
        manifest = _make_test_manifest()
        entries = collect_fqdn_entries(manifest)

        fqdns = {e.fqdn for e in entries}
        assert "github.com" in fqdns
        assert "release-assets.githubusercontent.com" in fqdns

    def test_final_hop_has_high_confidence(self) -> None:
        manifest = _make_test_manifest()
        entries = collect_fqdn_entries(manifest)

        final_entry = next(e for e in entries if e.fqdn == "release-assets.githubusercontent.com")
        assert final_entry.confidence == Confidence.HIGH

    def test_intermediate_hop_has_medium_confidence(self) -> None:
        manifest = _make_test_manifest()
        entries = collect_fqdn_entries(manifest)

        github_entry = next(e for e in entries if e.fqdn == "github.com")
        assert github_entry.confidence == Confidence.MEDIUM


class TestGenerateRules:
    """測試規則產生"""

    def test_generates_path_and_fqdn_rules(self) -> None:
        manifest = _make_test_manifest()
        path_rule, fqdn_rule = generate_rules(
            manifest,
            source_addresses=["10.0.0.0/8"],
        )

        assert path_rule.name == "winget-git-git-path"
        assert fqdn_rule.name == "winget-git-git-fqdn"

    def test_path_rule_has_target_urls(self) -> None:
        manifest = _make_test_manifest()
        path_rule, _ = generate_rules(manifest, source_addresses=["10.0.0.0/8"])

        assert len(path_rule.target_urls) > 0
        # 版本號應已被替換為萬用字元
        for url in path_rule.target_urls:
            assert "2.54.0" not in url

    def test_fqdn_rule_has_target_fqdns(self) -> None:
        manifest = _make_test_manifest()
        _, fqdn_rule = generate_rules(manifest, source_addresses=["10.0.0.0/8"])

        assert "github.com" in fqdn_rule.target_fqdns
        assert "release-assets.githubusercontent.com" in fqdn_rule.target_fqdns

    def test_source_addresses_applied(self) -> None:
        manifest = _make_test_manifest()
        path_rule, fqdn_rule = generate_rules(
            manifest,
            source_addresses=["192.168.1.0/24"],
        )

        assert path_rule.source_addresses == ["192.168.1.0/24"]
        assert fqdn_rule.source_addresses == ["192.168.1.0/24"]


class TestBaseInfrastructureRule:
    """測試基礎設施規則產生"""

    def test_generates_infra_rule(self) -> None:
        base_fqdns = [
            {"fqdn": "cdn.winget.microsoft.com", "description": "winget 來源"},
            {"fqdn": "winget.azureedge.net", "description": "CDN"},
        ]
        rule = generate_base_infrastructure_rule(base_fqdns, ["10.0.0.0/8"])

        assert rule.name == "winget-infrastructure-fqdn"
        assert "cdn.winget.microsoft.com" in rule.target_fqdns
        assert "winget.azureedge.net" in rule.target_fqdns
        assert rule.source_addresses == ["10.0.0.0/8"]
