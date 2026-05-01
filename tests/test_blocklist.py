"""測試 — 封鎖清單與允許清單過濾"""

from src.blocklist import (
    filter_packages,
    is_blocked,
    is_in_allowlist,
    matches_any_pattern,
)


class TestMatchesAnyPattern:
    """測試萬用字元匹配"""

    def test_exact_match(self) -> None:
        assert matches_any_pattern("Microsoft.PowerToys", ["Microsoft.PowerToys"])

    def test_wildcard_suffix(self) -> None:
        assert matches_any_pattern("Microsoft.PowerToys", ["Microsoft.*"])

    def test_wildcard_middle(self) -> None:
        assert matches_any_pattern("Microsoft.VisualStudio.2022.Community", ["Microsoft.VisualStudio.*.Community"])

    def test_case_insensitive(self) -> None:
        assert matches_any_pattern("microsoft.powertoys", ["Microsoft.*"])

    def test_no_match(self) -> None:
        assert not matches_any_pattern("7zip.7zip", ["Microsoft.*"])

    def test_beta_pattern(self) -> None:
        assert matches_any_pattern("Microsoft.Edge.Beta", ["Microsoft.*.Beta"])

    def test_preview_pattern(self) -> None:
        assert matches_any_pattern("Microsoft.WindowsTerminal.Preview", ["Microsoft.*.Preview"])

    def test_emulator_pattern(self) -> None:
        # Microsoft.BotFrameworkEmulator 不匹配 Microsoft.*.Emulator（Emulator 不是獨立段）
        assert not matches_any_pattern("Microsoft.BotFrameworkEmulator", ["Microsoft.*.Emulator"])
        assert not matches_any_pattern("Microsoft.BotFrameworkEmulator", ["Microsoft.*.Emulator.*"])

    def test_emulator_nested(self) -> None:
        # Microsoft.Azure.CosmosEmulator 中 CosmosEmulator 是一個段，不是 .Emulator
        assert not matches_any_pattern("Microsoft.Azure.CosmosEmulator", ["Microsoft.*.Emulator"])
        # 但精確匹配可以
        assert matches_any_pattern("Microsoft.Azure.CosmosEmulator", ["Microsoft.Azure.CosmosEmulator"])


class TestIsBlocked:
    """測試封鎖清單判斷"""

    BLOCKLIST = {
        "blocklist": {
            "enabled": True,
            "publishers": [],
            "packages": [
                "Microsoft.VisualStudio.*.Community",
                "Microsoft.VisualStudio.Community",
                "Microsoft.*.Beta",
                "Microsoft.*.Preview",
                "Microsoft.*.Insider",
                "Microsoft.*.Insiders",
                "Microsoft.*.Canary",
                "Microsoft.*.Dev",
                "GitHub.*.Beta",
                "Microsoft.*.Emulator",
                "Microsoft.*.Emulator.*",
            ],
        }
    }

    def test_vs_community_blocked(self) -> None:
        assert is_blocked("Microsoft.VisualStudio.2022.Community", self.BLOCKLIST)

    def test_vs_community_root_blocked(self) -> None:
        assert is_blocked("Microsoft.VisualStudio.Community", self.BLOCKLIST)

    def test_vs_enterprise_allowed(self) -> None:
        assert not is_blocked("Microsoft.VisualStudio.2022.Enterprise", self.BLOCKLIST)

    def test_edge_beta_blocked(self) -> None:
        assert is_blocked("Microsoft.Edge.Beta", self.BLOCKLIST)

    def test_edge_stable_allowed(self) -> None:
        assert not is_blocked("Microsoft.Edge", self.BLOCKLIST)

    def test_terminal_preview_blocked(self) -> None:
        assert is_blocked("Microsoft.WindowsTerminal.Preview", self.BLOCKLIST)

    def test_terminal_stable_allowed(self) -> None:
        assert not is_blocked("Microsoft.WindowsTerminal", self.BLOCKLIST)

    def test_github_beta_blocked(self) -> None:
        assert is_blocked("GitHub.SomeTool.Beta", self.BLOCKLIST)

    def test_github_stable_allowed(self) -> None:
        assert not is_blocked("GitHub.cli", self.BLOCKLIST)

    def test_emulator_blocked(self) -> None:
        # 精確的 .Emulator 段才會被封鎖，嵌入式名稱不會
        assert not is_blocked("Microsoft.BotFrameworkEmulator", self.BLOCKLIST)

    def test_disabled_blocklist(self) -> None:
        bl = {"blocklist": {"enabled": False, "packages": ["Microsoft.*"]}}
        assert not is_blocked("Microsoft.PowerToys", bl)

    def test_powertoys_allowed(self) -> None:
        assert not is_blocked("Microsoft.PowerToys", self.BLOCKLIST)

    def test_vscode_allowed(self) -> None:
        assert not is_blocked("Microsoft.VisualStudioCode", self.BLOCKLIST)


class TestIsInAllowlist:
    """測試允許清單判斷"""

    ALLOWLIST = {
        "allowlist": {
            "enabled": True,
            "packages": ["Microsoft.*", "GitHub.*"],
        }
    }

    def test_microsoft_allowed(self) -> None:
        assert is_in_allowlist("Microsoft.PowerToys", self.ALLOWLIST)

    def test_github_allowed(self) -> None:
        assert is_in_allowlist("GitHub.cli", self.ALLOWLIST)

    def test_git_not_allowed(self) -> None:
        assert not is_in_allowlist("7zip.7zip", self.ALLOWLIST)

    def test_disabled_allows_all(self) -> None:
        al = {"allowlist": {"enabled": False, "packages": ["Microsoft.*"]}}
        assert is_in_allowlist("7zip.7zip", al)


class TestFilterPackages:
    """測試綜合過濾"""

    def test_blocklist_overrides_allowlist(self) -> None:
        packages = [
            "Microsoft.PowerToys",
            "Microsoft.Edge.Beta",
            "Microsoft.VisualStudio.2022.Community",
            "GitHub.cli",
            "GitHub.SomeTool.Beta",
        ]
        al = {"allowlist": {"enabled": True, "packages": ["Microsoft.*", "GitHub.*"]}}
        bl = {
            "blocklist": {
                "enabled": True,
                "packages": ["Microsoft.*.Beta", "Microsoft.VisualStudio.*.Community", "GitHub.*.Beta"],
            }
        }

        allowed, blocked = filter_packages(packages, al, bl)

        assert "Microsoft.PowerToys" in allowed
        assert "GitHub.cli" in allowed
        assert "Microsoft.Edge.Beta" in blocked
        assert "Microsoft.VisualStudio.2022.Community" in blocked
        assert "GitHub.SomeTool.Beta" in blocked

    def test_no_blocklist(self) -> None:
        packages = ["Microsoft.PowerToys", "7zip.7zip"]
        al = {"allowlist": {"enabled": True, "packages": ["Microsoft.*"]}}

        allowed, blocked = filter_packages(packages, al, None)

        assert allowed == ["Microsoft.PowerToys"]
        assert blocked == ["7zip.7zip"]
