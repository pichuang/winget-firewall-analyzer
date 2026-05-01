"""測試 — 資料模型與版本號正規化"""

from src.models import (
    Confidence,
    FqdnCategory,
    FqdnEntry,
    RedirectHop,
    generalize_url_path,
)


class TestRedirectHop:
    """測試 RedirectHop 建構"""

    def test_from_url_basic(self) -> None:
        hop = RedirectHop.from_url(
            "https://github.com/git-for-windows/git/releases/download/v2.54.0/Git.exe",
            status_code=302,
        )
        assert hop.fqdn == "github.com"
        assert hop.path == "/git-for-windows/git/releases/download/v2.54.0/Git.exe"
        assert hop.status_code == 302
        assert hop.is_final is False

    def test_from_url_final(self) -> None:
        hop = RedirectHop.from_url(
            "https://objects.githubusercontent.com/some-asset",
            status_code=200,
            is_final=True,
        )
        assert hop.fqdn == "objects.githubusercontent.com"
        assert hop.is_final is True

    def test_from_url_with_query(self) -> None:
        hop = RedirectHop.from_url(
            "https://example.com/file.exe?token=abc&sig=123",
            status_code=200,
        )
        assert hop.fqdn == "example.com"
        assert hop.path == "/file.exe"


class TestGeneralizeUrlPath:
    """測試 URL path 版本號正規化"""

    def test_github_release_url(self) -> None:
        result = generalize_url_path(
            "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe"
        )
        assert "github.com" in result
        assert "*" in result
        # 版本號應被替換
        assert "2.54.0" not in result

    def test_github_cli_url(self) -> None:
        result = generalize_url_path(
            "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.msi"
        )
        assert "github.com" in result
        assert "*" in result
        assert "2.92.0" not in result

    def test_github_desktop_url(self) -> None:
        result = generalize_url_path(
            "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-x64.exe"
        )
        assert "desktop.githubusercontent.com" in result
        assert "*" in result
        assert "3.5.8" not in result

    def test_url_without_version(self) -> None:
        result = generalize_url_path("https://example.com/downloads/stable/app.exe")
        assert result == "example.com/downloads/stable/app.exe"

    def test_query_string_stripped(self) -> None:
        result = generalize_url_path(
            "https://example.com/file.exe?token=abc&sig=123"
        )
        assert "?" not in result
        assert "token" not in result

    def test_release_assets_url(self) -> None:
        result = generalize_url_path(
            "https://release-assets.githubusercontent.com/github-production-release-asset/23216272/97d75124-837c-4f83-834d-525694b2ed02"
        )
        assert "release-assets.githubusercontent.com" in result
        # UUID 應被替換為萬用字元
        assert "97d75124" not in result
        assert "*" in result


class TestFqdnEntry:
    """測試 FqdnEntry 資料結構"""

    def test_basic_creation(self) -> None:
        entry = FqdnEntry(
            fqdn="github.com",
            category=FqdnCategory.DOWNLOAD,
            confidence=Confidence.HIGH,
            source_package="Git.Git",
            sample_paths=["/git-for-windows/git/releases/download/v2.54.0/Git.exe"],
        )
        assert entry.fqdn == "github.com"
        assert entry.category == FqdnCategory.DOWNLOAD
        assert entry.confidence == Confidence.HIGH
