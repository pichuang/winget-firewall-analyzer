"""測試 — 輸出格式化器"""

from __future__ import annotations

import csv
import io
import json

from src.models import Confidence, FirewallRule, InstallerInfo, PackageManifest, RedirectHop
from src.formatters import format_azure_cli, format_csv, format_json, format_markdown
from src.formatters_powershell import format_azure_powershell


def _make_test_rules() -> list[FirewallRule]:
    """建立測試用規則"""
    return [
        FirewallRule(
            name="mirror-to-ms-git-https",
            target_urls=[
                "github.com/microsoft/git/releases/download/*/Git-*-64-bit.exe",
                "release-assets.githubusercontent.com/github-production-release-asset-*/*",
            ],
            source_addresses=["10.0.0.0/8"],
            description="winget 套件 Microsoft.Git 下載所需路徑",
            package_id="Microsoft.Git",
        ),
        FirewallRule(
            name="mirror-to-ms-git-https",
            target_fqdns=["github.com", "release-assets.githubusercontent.com"],
            source_addresses=["10.0.0.0/8"],
            description="winget 套件 Microsoft.Git 下載所需網域",
            package_id="Microsoft.Git",
        ),
    ]


class TestFormatJson:
    """測試 JSON 輸出"""

    def test_valid_json_output(self) -> None:
        rules = _make_test_rules()
        output = format_json(rules)
        data = json.loads(output)
        assert "properties" in data
        assert "ruleCollections" in data["properties"]

    def test_contains_rules(self) -> None:
        rules = _make_test_rules()
        output = format_json(rules)
        data = json.loads(output)
        arm_rules = data["properties"]["ruleCollections"][0]["rules"]
        assert len(arm_rules) == 2

    def test_path_rule_has_target_urls(self) -> None:
        rules = _make_test_rules()
        output = format_json(rules)
        data = json.loads(output)
        arm_rules = data["properties"]["ruleCollections"][0]["rules"]
        path_rule = arm_rules[0]
        assert "targetUrls" in path_rule
        assert len(path_rule["targetUrls"]) == 2

    def test_fqdn_rule_has_target_fqdns(self) -> None:
        rules = _make_test_rules()
        output = format_json(rules)
        data = json.loads(output)
        arm_rules = data["properties"]["ruleCollections"][0]["rules"]
        fqdn_rule = arm_rules[1]
        assert "targetFqdns" in fqdn_rule

    def test_custom_collection_name(self) -> None:
        rules = _make_test_rules()
        output = format_json(rules, rule_collection_name="custom-rc")
        data = json.loads(output)
        rc = data["properties"]["ruleCollections"][0]
        assert rc["name"] == "custom-rc"


class TestFormatCsv:
    """測試 CSV 輸出"""

    def test_valid_csv(self) -> None:
        rules = _make_test_rules()
        output = format_csv(rules)
        reader = csv.reader(io.StringIO(output))
        rows = list(reader)
        # 標頭 + 資料列（2 個 path URLs + 2 個 FQDNs = 4 資料列）
        assert len(rows) == 5  # 1 header + 4 data

    def test_header_row(self) -> None:
        rules = _make_test_rules()
        output = format_csv(rules)
        reader = csv.reader(io.StringIO(output))
        header = next(reader)
        assert "規則名稱" in header
        assert "套件識別碼" in header

    def test_contains_package_id(self) -> None:
        rules = _make_test_rules()
        output = format_csv(rules)
        assert "Microsoft.Git" in output


class TestFormatAzureCli:
    """測試 Azure CLI 輸出"""

    def test_contains_az_commands(self) -> None:
        rules = _make_test_rules()
        output = format_azure_cli(rules)
        assert "az network firewall policy" in output

    def test_contains_rule_names(self) -> None:
        rules = _make_test_rules()
        output = format_azure_cli(rules)
        assert "mirror-to-ms-git-https" in output
        assert "mirror-to-ms-git-https" in output

    def test_contains_target_urls_flag(self) -> None:
        rules = _make_test_rules()
        output = format_azure_cli(rules)
        assert "--target-urls" in output

    def test_contains_target_fqdns_flag(self) -> None:
        rules = _make_test_rules()
        output = format_azure_cli(rules)
        assert "--target-fqdns" in output

    def test_is_valid_bash(self) -> None:
        rules = _make_test_rules()
        output = format_azure_cli(rules)
        assert output.startswith("#!/bin/bash")


def _make_test_manifests() -> list[PackageManifest]:
    """建立測試用 manifest"""
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
                    installer_type="inno",
                    redirect_chain=[
                        RedirectHop(
                            url="https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-64-bit.exe",
                            fqdn="github.com",
                            path="/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-64-bit.exe",
                            status_code=302,
                            is_final=False,
                        ),
                        RedirectHop(
                            url="https://release-assets.githubusercontent.com/asset-123",
                            fqdn="release-assets.githubusercontent.com",
                            path="/asset-123",
                            status_code=200,
                            is_final=True,
                        ),
                    ],
                ),
            ],
        ),
    ]


class TestFormatMarkdown:
    """測試 Markdown 輸出"""

    def test_contains_deploy_info(self) -> None:
        """部署資訊區塊應包含 Rule Collection Group 等參數"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        fw_config = {
            "rule_collection_group_name": "test-rcg",
            "rule_collection_name": "test-rc",
            "priority": 600,
            "source_addresses": ["192.168.0.0/16"],
        }
        output = format_markdown(manifests, rules, firewall_config=fw_config)

        assert "Azure Firewall Policy 部署資訊" in output
        assert "`test-rcg`" in output
        assert "`test-rc`" in output
        assert "`600`" in output
        assert "`192.168.0.0/16`" in output

    def test_contains_fqdn_summary_table(self) -> None:
        """FQDN 彙總表應列出所有涉及的 FQDN"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        assert "FQDN 彙總表" in output
        assert "`github.com`" in output
        assert "`release-assets.githubusercontent.com`" in output

    def test_fqdn_summary_includes_base_fqdns(self) -> None:
        """FQDN 彙總表應包含基礎設施 FQDN"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        base = [{"fqdn": "cdn.winget.microsoft.com", "description": "winget 來源"}]
        output = format_markdown(manifests, rules, base_fqdns=base)

        assert "`cdn.winget.microsoft.com`" in output

    def test_fqdn_summary_shows_packages(self) -> None:
        """FQDN 彙總表應標示涉及的套件"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        # github.com 應標示 Microsoft.Git
        lines = output.split("\n")
        github_lines = [l for l in lines if "github.com" in l and "Microsoft.Git" in l]
        assert len(github_lines) > 0

    def test_contains_maintenance_tracker(self) -> None:
        """維護追蹤區塊應列出每個套件的分析狀態"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        assert "規則維護追蹤" in output
        assert "`Microsoft.Git`" in output
        assert "2.48.0.vfs.0.0" in output
        assert "已分析" in output

    def test_contains_maintenance_suggestions(self) -> None:
        """維護追蹤區塊應包含維護建議"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        assert "維護建議" in output
        assert "diff" in output

    def test_contains_package_details(self) -> None:
        """應保留原有的逐套件詳細規則"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        assert "📦 Microsoft.Git" in output
        assert "下載路徑分析" in output
        assert "Path 層級規則" in output
        assert "FQDN 層級規則" in output

    def test_deploy_info_defaults(self) -> None:
        """不傳 firewall_config 時應使用預設值"""
        manifests = _make_test_manifests()
        rules = _make_test_rules()
        output = format_markdown(manifests, rules)

        assert "`rcg-1100-mirror-winget`" in output
        assert "`action-allow-mirror`" in output
        assert "`1100`" in output


class TestFormatAzurePowershell:
    """測試 PowerShell 5.1 部署腳本輸出"""

    def test_contains_requires_version(self) -> None:
        """應包含 #Requires -Version 5.1"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "#Requires -Version 5.1" in output

    def test_contains_strict_mode(self) -> None:
        """應包含 Set-StrictMode"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "Set-StrictMode -Version Latest" in output

    def test_contains_az_commands(self) -> None:
        """應包含 az CLI 指令"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert '"network", "firewall", "policy"' in output

    def test_contains_rule_names(self) -> None:
        """應包含規則名稱"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "mirror-to-ms-git-https" in output

    def test_contains_invoke_azcli_helper(self) -> None:
        """應包含 Invoke-AzCli 輔助函式"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "function Invoke-AzCli" in output
        assert "$LASTEXITCODE" in output

    def test_contains_case_sensitive_comparison(self) -> None:
        """規則比對應使用 case-sensitive 比較"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "-cne" in output

    def test_no_jq_dependency(self) -> None:
        """不應依賴 jq"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "jq" not in output.lower()

    def test_contains_draft_deploy_instructions(self) -> None:
        """應包含 Draft deploy 指引"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules)
        assert "draft deploy" in output

    def test_tls_filter(self) -> None:
        """TLS 模式應僅包含 target_urls 規則"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules, rule_filter="tls")
        assert "TLS Inspection" in output
        assert "--target-urls" in output

    def test_fqdn_filter(self) -> None:
        """FQDN 模式應僅包含 target_fqdns 規則"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules, rule_filter="fqdn")
        assert "FQDN" in output
        assert "--target-fqdns" in output

    def test_source_ip_groups(self) -> None:
        """使用 source_ip_groups 時應產出 --source-ip-groups"""
        rules = [
            FirewallRule(
                name="test-rule",
                target_fqdns=["example.com"],
                source_ip_groups=["ipgroup-corp"],
                package_id="Test.Package",
            ),
        ]
        output = format_azure_powershell(rules)
        assert "--source-ip-groups" in output
        assert "ipgroup-corp" in output

    def test_subscription_check(self) -> None:
        """應包含訂閱 ID 檢查"""
        rules = _make_test_rules()
        output = format_azure_powershell(rules, subscription_id="test-sub-123")
        assert "test-sub-123" in output
        assert "$ExpectedSubscriptionId" in output
