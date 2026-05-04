"""packages_list_generator 單元測試"""

from __future__ import annotations

import textwrap

import pytest

from src.packages_list_generator import (
    Category,
    SecurityInfo,
    categorize_all,
    categorize_package,
    generate_packages_list_md,
    load_categories,
    load_security_yaml,
    validate_overlay,
    _risk_badge,
)


# ── 分類測試 ──


class TestCategorizePackage:
    """測試套件分類邏輯。"""

    @pytest.fixture
    def categories(self) -> list[Category]:
        return [
            Category(name="Azure", description="Azure 工具", prefixes=[
                "Microsoft.Azure.",
                "Microsoft.AzureCLI",
                "Microsoft.Bicep",
            ]),
            Category(name="Sysinternals", description="Sysinternals 工具", prefixes=[
                "Microsoft.Sysinternals.",
            ]),
            Category(name=".NET", description=".NET 環境", prefixes=[
                "Microsoft.DotNet.",
            ]),
            Category(name="開發工具", description="開發工具", prefixes=[
                "Microsoft.VisualStudioCode",
                "Microsoft.VisualStudio.",
                "GitHub.",
            ]),
            Category(name="執行環境", description="執行環境", prefixes=[
                "Microsoft.DotNet.Native.",
            ]),
        ]

    def test_prefix_with_dot(self, categories: list[Category]) -> None:
        """以 '.' 結尾的前綴應匹配子命名空間。"""
        assert categorize_package("Microsoft.Azure.AZCopy.10", categories) == "Azure"

    def test_exact_match(self, categories: list[Category]) -> None:
        """精確匹配的前綴。"""
        assert categorize_package("Microsoft.AzureCLI", categories) == "Azure"

    def test_exact_prefix_with_subpackage(self, categories: list[Category]) -> None:
        """精確 ID + 子套件應匹配。"""
        assert categorize_package("Microsoft.Bicep", categories) == "Azure"

    def test_sysinternals(self, categories: list[Category]) -> None:
        assert categorize_package("Microsoft.Sysinternals.ProcessExplorer", categories) == "Sysinternals"

    def test_dotnet(self, categories: list[Category]) -> None:
        assert categorize_package("Microsoft.DotNet.SDK.8", categories) == ".NET"

    def test_longest_prefix_wins(self, categories: list[Category]) -> None:
        """最長前綴優先：DotNet.Native 應匹配「執行環境」而非「.NET」。"""
        assert categorize_package("Microsoft.DotNet.Native.Runtime", categories) == "執行環境"

    def test_github_prefix(self, categories: list[Category]) -> None:
        assert categorize_package("GitHub.cli", categories) == "開發工具"

    def test_unmatched_returns_none(self, categories: list[Category]) -> None:
        """未匹配任何規則應回傳 None。"""
        assert categorize_package("Unknown.Package", categories) is None

    def test_visual_studio_code_exact(self, categories: list[Category]) -> None:
        """VisualStudioCode 精確匹配。"""
        assert categorize_package("Microsoft.VisualStudioCode", categories) == "開發工具"

    def test_visual_studio_subpackage(self, categories: list[Category]) -> None:
        """VisualStudio.2022.Enterprise 匹配。"""
        assert categorize_package("Microsoft.VisualStudio.2022.Enterprise", categories) == "開發工具"


class TestCategorizeAll:
    """測試批次分類。"""

    def test_categorize_with_uncategorized(self) -> None:
        categories = [
            Category(name="Azure", description="", prefixes=["Microsoft.Azure."]),
        ]
        pkg_ids = ["Microsoft.Azure.CLI", "Microsoft.Git", "Microsoft.Azure.Storage"]
        categorized, uncategorized = categorize_all(pkg_ids, categories)

        assert len(categorized["Azure"]) == 2
        assert "Microsoft.Git" in uncategorized


# ── 風險標注測試 ──


class TestRiskBadge:
    """測試風險標注。"""

    def test_high_risk(self) -> None:
        security = {"Pkg.A": SecurityInfo(package_id="Pkg.A", risk_level="high")}
        assert "🔴" in _risk_badge(security, "Pkg.A")

    def test_medium_risk(self) -> None:
        security = {"Pkg.B": SecurityInfo(package_id="Pkg.B", risk_level="medium")}
        assert "🟡" in _risk_badge(security, "Pkg.B")

    def test_low_risk(self) -> None:
        security = {"Pkg.C": SecurityInfo(package_id="Pkg.C", risk_level="low")}
        assert "🟢" in _risk_badge(security, "Pkg.C")

    def test_no_risk(self) -> None:
        security: dict[str, SecurityInfo] = {}
        assert _risk_badge(security, "Pkg.X") == ""

    def test_none_level(self) -> None:
        security = {"Pkg.D": SecurityInfo(package_id="Pkg.D", risk_level="none")}
        assert _risk_badge(security, "Pkg.D") == ""


# ── 驗證測試 ──


class TestValidateOverlay:
    """測試 overlay 驗證邏輯。"""

    def test_stale_entry_warns(self) -> None:
        """overlay 中有已移除的套件應警告。"""
        security = {
            "Pkg.Removed": SecurityInfo(package_id="Pkg.Removed", risk_level="high"),
        }
        warnings = validate_overlay(security, ["Pkg.A"], ["Pkg.B"])
        assert any("Pkg.Removed" in w for w in warnings)

    def test_blocked_entry_info(self) -> None:
        """overlay 中有被封鎖的套件應提示。"""
        security = {
            "Pkg.Blocked": SecurityInfo(package_id="Pkg.Blocked", risk_level="medium"),
        }
        warnings = validate_overlay(security, ["Pkg.A"], ["Pkg.Blocked"])
        assert any("封鎖" in w for w in warnings)

    def test_valid_entry_no_warning(self) -> None:
        """正常的 overlay 項目不應產生警告。"""
        security = {
            "Pkg.A": SecurityInfo(package_id="Pkg.A", risk_level="high"),
        }
        warnings = validate_overlay(security, ["Pkg.A"], ["Pkg.B"])
        assert len(warnings) == 0


# ── Markdown 產生測試 ──


class TestGenerateMarkdown:
    """測試 Markdown 產生。"""

    def test_basic_structure(self) -> None:
        """產出應包含必要的章節標題。"""
        categories = [
            Category(name="☁️ Azure", description="Azure 工具", prefixes=["Microsoft.Azure."]),
        ]
        security: dict[str, SecurityInfo] = {}
        md = generate_packages_list_md(
            allowed_ids=["Microsoft.Azure.CLI"],
            blocked_ids=["Microsoft.OldTool"],
            categories=categories,
            security=security,
        )
        assert "# winget 套件清單 — 分類報告" in md
        assert "## 📊 分類摘要" in md
        assert "## ⚠️ 資安風險評估" in md
        assert "## ☁️ Azure" in md
        assert "## ❌ 封鎖的套件" in md

    def test_counts_in_header(self) -> None:
        """標題應包含正確的套件數量。"""
        md = generate_packages_list_md(
            allowed_ids=["A", "B", "C"],
            blocked_ids=["D"],
            categories=[],
            security={},
        )
        assert "✅ 允許 3 個" in md
        assert "❌ 封鎖 1 個" in md

    def test_risk_badge_in_category(self) -> None:
        """分類清單中應包含風險標注。"""
        categories = [
            Category(name="Tools", description="工具", prefixes=["Microsoft.Tool"]),
        ]
        security = {
            "Microsoft.Tool.A": SecurityInfo(
                package_id="Microsoft.Tool.A", risk_level="high", risk_reason="危險",
            ),
        }
        md = generate_packages_list_md(
            allowed_ids=["Microsoft.Tool.A"],
            blocked_ids=[],
            categories=categories,
            security=security,
        )
        assert "`Microsoft.Tool.A` 🔴 高" in md

    def test_uncategorized_section(self) -> None:
        """未分類套件應出現在未分類區塊。"""
        md = generate_packages_list_md(
            allowed_ids=["Unknown.Package"],
            blocked_ids=[],
            categories=[],
            security={},
        )
        assert "## ❓ 未分類套件" in md
        assert "`Unknown.Package`" in md

    def test_blocked_section(self) -> None:
        """封鎖套件應出現在封鎖清單。"""
        md = generate_packages_list_md(
            allowed_ids=[],
            blocked_ids=["Old.Package", "Deprecated.Tool"],
            categories=[],
            security={},
        )
        assert "`Deprecated.Tool`" in md
        assert "`Old.Package`" in md

    def test_access_control_section(self) -> None:
        """應包含存取控制分級。"""
        security = {
            "Admin.Tool": SecurityInfo(
                package_id="Admin.Tool", risk_level="high",
                access_tier=1, access_reason="特權工具",
            ),
        }
        md = generate_packages_list_md(
            allowed_ids=["Admin.Tool"],
            blocked_ids=[],
            categories=[],
            security=security,
        )
        assert "僅限 IT 管理員" in md
        assert "特權工具" in md


# ── YAML 載入測試 ──


class TestLoadSecurityYaml:
    """測試 YAML 載入。"""

    def test_load_from_project(self) -> None:
        """應能載入專案中的 packages-security.yaml。"""
        security = load_security_yaml("packages-security.yaml")
        # 至少應有高風險套件
        assert len(security) > 0
        # 檢查已知的高風險套件
        assert "Microsoft.PowerShell" in security
        assert security["Microsoft.PowerShell"].risk_level == "high"

    def test_nonexistent_file(self) -> None:
        """不存在的檔案應回傳空字典。"""
        security = load_security_yaml("nonexistent.yaml")
        assert security == {}


class TestLoadCategories:
    """測試分類規則載入。"""

    def test_load_from_project(self) -> None:
        """應能載入專案中的分類規則。"""
        categories = load_categories("packages-security.yaml")
        assert len(categories) > 0
        names = [c.name for c in categories]
        assert any("Azure" in n for n in names)
        assert any("Sysinternals" in n for n in names)
