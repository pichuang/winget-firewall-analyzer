"""WSL 發行版分析器 — 分析 WSL 發行版下載路徑，產生防火牆規則

支援的分析對象：
- Ubuntu 20.04 LTS（aka.ms/wslubuntu2004）
- Ubuntu 22.04 LTS（aka.ms/wslubuntu2204）

分析策略與 winget 套件一致：透過 HTTP 重導向追蹤取得完整下載鏈路，
產出 Azure Firewall Policy Application Rule 建議。
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import httpx

from src.models import FirewallRule, InstallerInfo, PackageManifest
from src.redirect_tracer import trace_redirects
from src.rule_generator import generate_rules


@dataclass
class WslDistro:
    """WSL 發行版定義"""
    name: str
    id: str
    download_url: str
    install_cmd: str = ""


def load_wsl_distros(config: dict[str, Any]) -> list[WslDistro]:
    """從設定檔載入已啟用的 WSL 發行版清單。

    若 wsl_distros.enabled 為 False 或未設定，回傳空清單。
    """
    wsl_config = config.get("wsl_distros", {})
    if not wsl_config.get("enabled", False):
        return []

    distros: list[WslDistro] = []
    for entry in wsl_config.get("distributions", []):
        url = entry.get("download_url")
        if not url:
            continue
        distros.append(WslDistro(
            name=entry.get("name", ""),
            id=entry.get("id", ""),
            download_url=url,
            install_cmd=entry.get("install_cmd", ""),
        ))
    return distros


def get_wsl_base_fqdns(config: dict[str, Any]) -> list[dict[str, str]]:
    """取得 WSL 基礎設施 FQDN 清單。"""
    wsl_config = config.get("wsl_distros", {})
    return wsl_config.get("base_fqdns", [])


async def analyze_wsl_distro(
    client: httpx.AsyncClient,
    distro: WslDistro,
) -> PackageManifest:
    """分析單一 WSL 發行版的下載路徑。

    將 WSL 發行版映射為 PackageManifest，以便複用現有的
    規則產生器、格式化器和下載腳本產生器。
    """
    installer = InstallerInfo(
        url=distro.download_url,
        architecture="x64",
        scope="machine",
        installer_type="appx",
    )

    # 追蹤重導向鏈
    installer.redirect_chain = await trace_redirects(client, distro.download_url)

    manifest = PackageManifest(
        package_id=distro.id,
        version=distro.name,
        installers=[installer],
        publisher="Canonical" if "Ubuntu" in distro.name else "Unknown",
    )

    return manifest


async def analyze_all_wsl_distros(
    client: httpx.AsyncClient,
    distros: list[WslDistro],
    source_addresses: list[str],
    source_ip_groups: list[str] | None = None,
) -> tuple[list[PackageManifest], list[FirewallRule], list[tuple[str, str]]]:
    """分析所有 WSL 發行版，回傳 (manifests, rules, failed)。"""
    all_manifests: list[PackageManifest] = []
    all_rules: list[FirewallRule] = []
    failed: list[tuple[str, str]] = []

    for distro in distros:
        try:
            manifest = await analyze_wsl_distro(client, distro)
            rules = list(generate_rules(manifest, source_addresses=[]))
            for rule in rules:
                rule.source_addresses = source_addresses
                rule.source_ip_groups = source_ip_groups or []
            all_rules.extend(rules)
            all_manifests.append(manifest)
        except Exception as e:
            import sys
            print(f"   ❌ WSL {distro.name} 分析失敗: {e}", file=sys.stderr)
            failed.append((f"WSL:{distro.name}", str(e)))

    return all_manifests, all_rules, failed
