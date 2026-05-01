"""WSL 發行版分析器測試"""

from __future__ import annotations

import pytest

from src.models import FirewallRule, InstallerInfo, PackageManifest, RedirectHop
from src.wsl_analyzer import (
    WslDistro,
    get_wsl_base_fqdns,
    load_wsl_distros,
)


# ── load_wsl_distros 測試 ──

def test_load_wsl_distros_enabled() -> None:
    """已啟用時回傳所有有 download_url 的發行版。"""
    config = {
        "wsl_distros": {
            "enabled": True,
            "distributions": [
                {"name": "Ubuntu 22.04 LTS", "id": "WSL.Ubuntu-22.04",
                 "download_url": "https://aka.ms/wslubuntu2204",
                 "install_cmd": "wsl --install -d Ubuntu-22.04"},
                {"name": "Ubuntu 20.04 LTS", "id": "WSL.Ubuntu-20.04",
                 "download_url": "https://aka.ms/wslubuntu2004"},
            ],
        }
    }
    distros = load_wsl_distros(config)
    assert len(distros) == 2
    assert distros[0].id == "WSL.Ubuntu-22.04"
    assert distros[0].download_url == "https://aka.ms/wslubuntu2204"
    assert distros[0].install_cmd == "wsl --install -d Ubuntu-22.04"
    assert distros[1].id == "WSL.Ubuntu-20.04"


def test_load_wsl_distros_disabled() -> None:
    """未啟用時回傳空清單。"""
    config = {
        "wsl_distros": {
            "enabled": False,
            "distributions": [
                {"name": "Ubuntu 22.04 LTS", "id": "WSL.Ubuntu-22.04",
                 "download_url": "https://aka.ms/wslubuntu2204"},
            ],
        }
    }
    assert load_wsl_distros(config) == []


def test_load_wsl_distros_missing_config() -> None:
    """設定檔中無 wsl_distros 區塊時回傳空清單。"""
    assert load_wsl_distros({}) == []
    assert load_wsl_distros({"other": "value"}) == []


def test_load_wsl_distros_skip_no_url() -> None:
    """跳過沒有 download_url 的項目。"""
    config = {
        "wsl_distros": {
            "enabled": True,
            "distributions": [
                {"name": "RHEL 9", "id": "WSL.RHEL-9"},
                {"name": "Ubuntu 22.04 LTS", "id": "WSL.Ubuntu-22.04",
                 "download_url": "https://aka.ms/wslubuntu2204"},
            ],
        }
    }
    distros = load_wsl_distros(config)
    assert len(distros) == 1
    assert distros[0].id == "WSL.Ubuntu-22.04"


# ── get_wsl_base_fqdns 測試 ──

def test_get_wsl_base_fqdns() -> None:
    """正確取得 WSL 基礎設施 FQDN。"""
    config = {
        "wsl_distros": {
            "base_fqdns": [
                {"fqdn": "wslstorestorage.blob.core.windows.net",
                 "category": "wsl-infrastructure",
                 "description": "WSL 核心元件"},
            ],
        }
    }
    fqdns = get_wsl_base_fqdns(config)
    assert len(fqdns) == 1
    assert fqdns[0]["fqdn"] == "wslstorestorage.blob.core.windows.net"


def test_get_wsl_base_fqdns_empty() -> None:
    """無設定時回傳空清單。"""
    assert get_wsl_base_fqdns({}) == []
    assert get_wsl_base_fqdns({"wsl_distros": {}}) == []


# ── WslDistro 資料模型測試 ──

def test_wsl_distro_defaults() -> None:
    """WslDistro 預設值。"""
    d = WslDistro(name="Test", id="WSL.Test", download_url="https://example.com")
    assert d.install_cmd == ""


# ── analyze_wsl_distro 產生的 PackageManifest 測試（以模擬方式）──

def test_wsl_manifest_structure() -> None:
    """驗證 WSL 分析結果可映射為 PackageManifest 結構。"""
    # 模擬分析結果（不實際進行 HTTP 請求）
    hop1 = RedirectHop(
        url="https://aka.ms/wslubuntu2204",
        fqdn="aka.ms",
        path="/wslubuntu2204",
        status_code=301,
    )
    hop2 = RedirectHop(
        url="https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204.appx",
        fqdn="wslstorestorage.blob.core.windows.net",
        path="/wslblob/Ubuntu2204.appx",
        status_code=200,
        is_final=True,
    )
    installer = InstallerInfo(
        url="https://aka.ms/wslubuntu2204",
        architecture="x64",
        scope="machine",
        installer_type="appx",
        redirect_chain=[hop1, hop2],
    )
    manifest = PackageManifest(
        package_id="WSL.Ubuntu-22.04",
        version="Ubuntu 22.04 LTS",
        installers=[installer],
        publisher="Canonical",
    )

    assert manifest.package_id == "WSL.Ubuntu-22.04"
    assert manifest.version == "Ubuntu 22.04 LTS"
    assert len(manifest.installers) == 1
    assert len(manifest.installers[0].redirect_chain) == 2
    assert manifest.installers[0].redirect_chain[1].is_final


def test_wsl_manifest_rule_generation() -> None:
    """驗證 WSL PackageManifest 可正確產生防火牆規則。"""
    from src.rule_generator import generate_rules

    hop = RedirectHop(
        url="https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204.appx",
        fqdn="wslstorestorage.blob.core.windows.net",
        path="/wslblob/Ubuntu2204.appx",
        status_code=200,
        is_final=True,
    )
    installer = InstallerInfo(
        url="https://aka.ms/wslubuntu2204",
        architecture="x64",
        installer_type="appx",
        redirect_chain=[hop],
    )
    manifest = PackageManifest(
        package_id="WSL.Ubuntu-22.04",
        version="Ubuntu 22.04 LTS",
        installers=[installer],
        publisher="Canonical",
    )

    path_rule, fqdn_rule = generate_rules(manifest, source_addresses=["10.0.0.0/8"])

    # 規則名稱包含 WSL 識別碼
    assert "wsl-ubuntu-22-04" in path_rule.name
    assert "wsl-ubuntu-22-04" in fqdn_rule.name

    # FQDN 規則包含下載端點
    assert "wslstorestorage.blob.core.windows.net" in fqdn_rule.target_fqdns
