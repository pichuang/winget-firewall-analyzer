"""winget 套件 manifest 查詢 — 透過 GitHub API 存取 microsoft/winget-pkgs 倉庫"""

from __future__ import annotations

import re
from typing import Any

import httpx
import yaml

from src.models import InstallerInfo, PackageManifest

WINGET_PKGS_REPO = "microsoft/winget-pkgs"
GITHUB_API_BASE = "https://api.github.com"
RAW_CONTENT_BASE = "https://raw.githubusercontent.com"


def _build_manifest_path(package_id: str) -> str:
    """根據 PackageIdentifier 建構 manifest 在 winget-pkgs 倉庫中的路徑。

    winget-pkgs 路徑慣例：manifests/{首字母小寫}/{以斜線分隔的 PackageIdentifier}/{version}/
    PackageIdentifier 以第一個 '.' 分割為 Publisher 與 PackageName 部分。

    範例：
        Git.Git         → manifests/g/Git/Git
        GitHub.cli      → manifests/g/GitHub/cli
        GitHub.GitHubDesktop → manifests/g/GitHub/GitHubDesktop
        Microsoft.VisualStudioCode → manifests/m/Microsoft/VisualStudioCode
    """
    parts = package_id.split(".")
    first_letter = parts[0][0].lower()
    return f"manifests/{first_letter}/{'/'.join(parts)}"


def _parse_version_key(version_str: str) -> tuple[bool, list[int | str]]:
    """將版本字串轉為可排序的 key，數字版本排在非數字前面。"""
    is_numeric = bool(re.match(r"^\d", version_str))
    segments: list[int | str] = []
    for part in re.split(r"[.\-_]", version_str):
        if part.isdigit():
            segments.append(int(part))
        else:
            segments.append(part)
    # 數字版本排在前面（is_numeric=True → 0），非數字在後（1）
    return (0 if is_numeric else 1, segments)


async def list_versions(
    client: httpx.AsyncClient,
    package_id: str,
) -> list[str]:
    """列出指定套件的所有可用版本號。"""
    path = _build_manifest_path(package_id)
    url = f"{GITHUB_API_BASE}/repos/{WINGET_PKGS_REPO}/contents/{path}"
    resp = await client.get(url, headers={"Accept": "application/vnd.github.v3+json"})
    resp.raise_for_status()

    entries: list[dict[str, Any]] = resp.json()
    versions = [
        e["name"] for e in entries
        if e.get("type") == "dir" and re.match(r"^\d+\.\d+", e["name"])
    ]
    versions.sort(key=_parse_version_key)
    return versions


async def get_latest_version(
    client: httpx.AsyncClient,
    package_id: str,
) -> str:
    """取得指定套件的最新穩定版本號。"""
    versions = await list_versions(client, package_id)
    if not versions:
        raise ValueError(f"找不到套件 {package_id} 的任何版本")
    return versions[-1]


async def fetch_installer_manifest(
    client: httpx.AsyncClient,
    package_id: str,
    version: str,
) -> PackageManifest:
    """下載並解析指定套件版本的 installer manifest。"""
    path = _build_manifest_path(package_id)
    parts = package_id.split(".")
    manifest_filename = f"{'.'.join(parts)}.installer.yaml"

    raw_url = (
        f"{RAW_CONTENT_BASE}/{WINGET_PKGS_REPO}/master/"
        f"{path}/{version}/{manifest_filename}"
    )
    resp = await client.get(raw_url)
    resp.raise_for_status()

    data = yaml.safe_load(resp.text)

    installers: list[InstallerInfo] = []
    seen_urls: set[str] = set()

    for inst in data.get("Installers", []):
        url = inst.get("InstallerUrl", "")
        if not url or url in seen_urls:
            continue
        seen_urls.add(url)
        installers.append(InstallerInfo(
            url=url,
            architecture=inst.get("Architecture", ""),
            scope=inst.get("Scope", ""),
            installer_type=inst.get("InstallerType", data.get("InstallerType", "")),
        ))

    return PackageManifest(
        package_id=data.get("PackageIdentifier", package_id),
        version=data.get("PackageVersion", version),
        installers=installers,
        publisher=parts[0] if parts else "",
    )


async def fetch_package(
    client: httpx.AsyncClient,
    package_id: str,
    version: str | None = None,
) -> PackageManifest:
    """取得套件的完整 manifest（含 installer 資訊）。

    若未指定版本，自動取最新版。
    """
    if version is None:
        version = await get_latest_version(client, package_id)
    return await fetch_installer_manifest(client, package_id, version)
