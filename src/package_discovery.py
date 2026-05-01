"""套件探索 — 遞迴掃描 winget-pkgs 倉庫發現所有匹配的套件"""

from __future__ import annotations

import re
import sys
from typing import Any

import httpx

from src.winget_api import GITHUB_API_BASE, WINGET_PKGS_REPO

# 版本目錄判斷：需符合 x.y 或 x.y.z 等多段數字格式，單一數字（如 2022）不算版本
_VERSION_DIR_PATTERN = re.compile(r"^\d+\.\d+")  # 至少 x.y


async def _list_directory(
    client: httpx.AsyncClient,
    path: str,
) -> list[dict[str, Any]]:
    """列出 winget-pkgs 倉庫中指定路徑的內容（含 rate limit 重試）。"""
    import asyncio

    url = f"{GITHUB_API_BASE}/repos/{WINGET_PKGS_REPO}/contents/{path}"

    for attempt in range(3):
        resp = await client.get(url, headers={"Accept": "application/vnd.github.v3+json"})

        if resp.status_code == 403 and "rate limit" in resp.text.lower():
            # 等待後重試
            wait = 5 * (attempt + 1)
            print(f"   ⏳ GitHub API rate limit，等待 {wait} 秒後重試 ...", file=sys.stderr)
            await asyncio.sleep(wait)
            continue

        resp.raise_for_status()
        return resp.json()

    resp.raise_for_status()
    return []


async def _is_package_dir(
    client: httpx.AsyncClient,
    path: str,
    children: list[dict[str, Any]] | None = None,
) -> bool:
    """判斷指定目錄是否為 leaf 套件目錄（子目錄為版本號目錄）。"""
    if children is None:
        children = await _list_directory(client, path)

    subdirs = [d for d in children if d.get("type") == "dir"]
    if not subdirs:
        return False

    # 若有任何子目錄名稱以數字開頭，視為版本目錄 → 此目錄是 leaf 套件
    return any(_VERSION_DIR_PATTERN.match(d["name"]) for d in subdirs)


def _path_to_package_id(path: str) -> str:
    """將倉庫路徑轉回 PackageIdentifier。

    manifests/m/Microsoft/VisualStudio/2022/Community → Microsoft.VisualStudio.2022.Community
    """
    # 去掉 manifests/{letter}/ 前綴
    parts = path.split("/")
    if len(parts) > 2 and parts[0] == "manifests":
        return ".".join(parts[2:])
    return ".".join(parts)


async def discover_packages_under_prefix(
    client: httpx.AsyncClient,
    prefix: str,
    max_depth: int = 6,
) -> list[str]:
    """遞迴探索指定 prefix 下的所有 leaf 套件。

    prefix 格式：PackageIdentifier 的前綴，如 "Microsoft" 或 "GitHub"。
    回傳所有發現的 PackageIdentifier 列表。
    """
    first_letter = prefix[0].lower()
    base_path = f"manifests/{first_letter}/{prefix.replace('.', '/')}"

    discovered: list[str] = []
    await _scan_recursive(client, base_path, discovered, depth=0, max_depth=max_depth)
    return discovered


async def _scan_recursive(
    client: httpx.AsyncClient,
    path: str,
    results: list[str],
    depth: int,
    max_depth: int,
) -> None:
    """遞迴掃描目錄樹，收集所有 leaf 套件。"""
    if depth > max_depth:
        return

    try:
        children = await _list_directory(client, path)
    except httpx.HTTPStatusError as e:
        if e.response.status_code == 404:
            return
        raise

    subdirs = [d for d in children if d.get("type") == "dir"]

    if not subdirs:
        return

    # 檢查是否為 leaf 套件目錄
    if await _is_package_dir(client, path, children):
        pkg_id = _path_to_package_id(path)
        results.append(pkg_id)
        return

    # 非 leaf → 繼續遞迴
    for subdir in subdirs:
        sub_path = f"{path}/{subdir['name']}"
        print(f"   🔍 掃描: {_path_to_package_id(sub_path)} ...", file=sys.stderr)
        await _scan_recursive(client, sub_path, results, depth + 1, max_depth)


async def discover_all_packages(
    client: httpx.AsyncClient,
    allowlist_packages: list[str],
) -> list[str]:
    """依據 allowlist 的 packages 模式，探索所有匹配的套件。

    只處理以 .* 結尾的萬用字元模式（如 "Microsoft.*"、"GitHub.*"），
    取其前綴進行遞迴掃描。精確 ID 則直接加入。
    """
    all_packages: list[str] = []
    scanned_prefixes: set[str] = set()

    for pattern in allowlist_packages:
        if pattern.endswith(".*"):
            prefix = pattern[:-2]  # "Microsoft.*" → "Microsoft"
            if prefix in scanned_prefixes:
                continue
            scanned_prefixes.add(prefix)

            print(f"\n🔎 探索 {prefix}.* 下的所有套件 ...", file=sys.stderr)
            packages = await discover_packages_under_prefix(client, prefix)
            print(f"   找到 {len(packages)} 個套件", file=sys.stderr)
            all_packages.extend(packages)
        else:
            # 精確 ID，直接加入
            all_packages.append(pattern)

    # 去重並排序
    return sorted(set(all_packages))
