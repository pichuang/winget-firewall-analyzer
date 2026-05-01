"""資料模型定義 — 套件資訊、重導向跳板、防火牆規則"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from enum import Enum
from urllib.parse import urlparse


class Confidence(str, Enum):
    """規則信心等級"""
    HIGH = "high"          # 直接從 manifest InstallerUrl 追蹤得出
    MEDIUM = "medium"      # 重導向中繼跳板
    LOW = "low"            # 推測性（如 bootstrapper 可能的額外下載）


class FqdnCategory(str, Enum):
    """FQDN 用途分類"""
    WINGET_SOURCE = "winget-source"
    DOWNLOAD = "download"
    REDIRECT_HOP = "redirect-hop"
    CDN = "cdn"
    AUTH = "auth"
    UNKNOWN = "unknown"


@dataclass
class RedirectHop:
    """重導向鏈中的單一跳板"""
    url: str
    fqdn: str
    path: str
    status_code: int
    is_final: bool = False

    @classmethod
    def from_url(cls, url: str, status_code: int, is_final: bool = False) -> RedirectHop:
        parsed = urlparse(url)
        return cls(
            url=url,
            fqdn=parsed.hostname or "",
            path=parsed.path or "/",
            status_code=status_code,
            is_final=is_final,
        )


@dataclass
class InstallerInfo:
    """單一安裝檔資訊"""
    url: str
    architecture: str = ""
    scope: str = ""
    installer_type: str = ""
    redirect_chain: list[RedirectHop] = field(default_factory=list)


@dataclass
class PackageManifest:
    """套件 manifest 摘要"""
    package_id: str
    version: str
    installers: list[InstallerInfo] = field(default_factory=list)
    publisher: str = ""


@dataclass
class FqdnEntry:
    """單一 FQDN 記錄（含分類與來源套件）"""
    fqdn: str
    category: FqdnCategory
    confidence: Confidence
    source_package: str
    sample_paths: list[str] = field(default_factory=list)
    description: str = ""


# 需正規化的 URL path 模式 — 版本號、UUID、雜湊值
GENERALIZE_PATTERNS: list[re.Pattern[str]] = [
    # UUID（含連字號格式）
    re.compile(r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"),
    # 長雜湊值（git commit SHA 等，12+ hex chars）
    re.compile(r"(?<=/)[0-9a-fA-F]{12,}(?=/|$)"),
    # 版本號（含 windows 後綴等）
    re.compile(r"v?\d+\.\d+\.\d+(?:\.\d+)*(?:[._-]\w+)*"),
    re.compile(r"v\d+"),
]


def generalize_url_path(url: str) -> str:
    """將 URL path 中的版本號、UUID、雜湊值替換為萬用字元 *，並移除 query string。

    範例：
        github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe
        → github.com/git-for-windows/git/releases/download/*/Git-*-64-bit.exe

        release-assets.githubusercontent.com/github-production-release-asset/23216272/97d75124-...
        → release-assets.githubusercontent.com/github-production-release-asset/*/*
    """
    parsed = urlparse(url)
    path = parsed.path

    for pattern in GENERALIZE_PATTERNS:
        path = pattern.sub("*", path)

    # 合併連續萬用字元（以 / . _ - 分隔）
    path = re.sub(r"\*[./_-]*\*", "*", path)
    # 合併路徑中連續的 /*/* 為 /*/*（保留層級）
    while "/*/*" in path:
        path = path.replace("/*/*", "/*")

    return f"{parsed.hostname}{path}"


@dataclass
class FirewallRule:
    """Azure Firewall Policy Application Rule"""
    name: str
    rule_type: str = "ApplicationRule"
    protocols: list[dict[str, str | int]] = field(default_factory=lambda: [
        {"protocolType": "Https", "port": 443}
    ])
    target_urls: list[str] = field(default_factory=list)
    target_fqdns: list[str] = field(default_factory=list)
    source_addresses: list[str] = field(default_factory=list)
    source_ip_groups: list[str] = field(default_factory=list)
    description: str = ""
    package_id: str = ""
    confidence: Confidence = Confidence.HIGH
