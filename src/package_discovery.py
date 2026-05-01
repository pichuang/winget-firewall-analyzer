"""套件探索 — 遞迴掃描 winget-pkgs 倉庫發現所有匹配的套件"""

from __future__ import annotations

import re
import sys
from typing import Any

import httpx

from src.blocklist import matches_any_pattern
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
    blocklist_patterns: list[str] | None = None,
) -> tuple[list[str], int]:
    """遞迴探索指定 prefix 下的所有 leaf 套件。

    prefix 格式：PackageIdentifier 的前綴，如 "Microsoft" 或 "GitHub"。
    回傳 (發現的 PackageIdentifier 列表, 跳過的封鎖套件數)。
    """
    first_letter = prefix[0].lower()
    base_path = f"manifests/{first_letter}/{prefix.replace('.', '/')}"

    discovered: list[str] = []
    skipped_count: list[int] = [0]
    await _scan_recursive(
        client, base_path, discovered,
        depth=0, max_depth=max_depth,
        blocklist_patterns=blocklist_patterns,
        skipped_count=skipped_count,
    )
    return discovered, skipped_count[0]


def _is_prefix_blocked(prefix: str, blocklist_patterns: list[str]) -> bool:
    """檢查套件 ID 前綴是否整個子樹都被封鎖。

    例如封鎖清單有 "Microsoft.VisualStudio.2017.*"，
    則前綴 "Microsoft.VisualStudio.2017" 整棵子樹可跳過。
    同時也檢查精確匹配（如封鎖 "GitHub.Atom"）。
    """
    prefix_lower = prefix.lower()
    for pattern in blocklist_patterns:
        p = pattern.lower()
        # 精確匹配：封鎖清單直接列出此 ID
        if p == prefix_lower:
            return True
        # 子樹匹配：封鎖清單有 "prefix.*"，整個子樹可跳過
        if p == f"{prefix_lower}.*":
            return True
    return False


async def _scan_recursive(
    client: httpx.AsyncClient,
    path: str,
    results: list[str],
    depth: int,
    max_depth: int,
    blocklist_patterns: list[str] | None = None,
    skipped_count: list[int] | None = None,
) -> None:
    """遞迴掃描目錄樹，收集所有 leaf 套件（跳過封鎖清單中的套件）。"""
    if depth > max_depth:
        return

    if blocklist_patterns is None:
        blocklist_patterns = []
    if skipped_count is None:
        skipped_count = [0]

    # 先檢查當前路徑對應的套件 ID 是否被封鎖（子樹剪枝）
    current_pkg_id = _path_to_package_id(path)
    if blocklist_patterns and _is_prefix_blocked(current_pkg_id, blocklist_patterns):
        skipped_count[0] += 1
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
        # 封鎖清單過濾（fnmatch 萬用字元完整匹配）
        if blocklist_patterns and matches_any_pattern(pkg_id, blocklist_patterns):
            skipped_count[0] += 1
            return
        results.append(pkg_id)
        return

    # 非 leaf → 繼續遞迴
    for subdir in subdirs:
        sub_path = f"{path}/{subdir['name']}"
        print(f"   🔍 掃描: {_path_to_package_id(sub_path)} ...", file=sys.stderr)
        await _scan_recursive(
            client, sub_path, results, depth + 1, max_depth,
            blocklist_patterns, skipped_count,
        )


async def discover_all_packages(
    client: httpx.AsyncClient,
    allowlist_packages: list[str],
    blocklist_patterns: list[str] | None = None,
) -> list[str]:
    """依據 allowlist 的 packages 模式，探索所有匹配的套件。

    只處理以 .* 結尾的萬用字元模式（如 "Microsoft.*"、"GitHub.*"），
    取其前綴進行遞迴掃描。精確 ID 則直接加入。
    傳入 blocklist_patterns 可在探索階段直接跳過封鎖的套件與子樹。
    """
    all_packages: list[str] = []
    total_skipped = 0
    scanned_prefixes: set[str] = set()

    for pattern in allowlist_packages:
        if pattern.endswith(".*"):
            prefix = pattern[:-2]  # "Microsoft.*" → "Microsoft"
            if prefix in scanned_prefixes:
                continue
            scanned_prefixes.add(prefix)

            print(f"\n🔎 探索 {prefix}.* 下的所有套件 ...", file=sys.stderr)
            packages, skipped = await discover_packages_under_prefix(
                client, prefix, blocklist_patterns=blocklist_patterns,
            )
            print(f"   找到 {len(packages)} 個套件", file=sys.stderr)
            if skipped:
                print(f"   🚫 跳過 {skipped} 個封鎖套件", file=sys.stderr)
            total_skipped += skipped
            all_packages.extend(packages)
        else:
            # 精確 ID — 也檢查封鎖清單
            if blocklist_patterns and matches_any_pattern(pattern, blocklist_patterns):
                total_skipped += 1
                continue
            all_packages.append(pattern)

    if total_skipped:
        print(f"\n🚫 探索階段共跳過 {total_skipped} 個封鎖套件/子樹", file=sys.stderr)

    # 去重並排序
    return sorted(set(all_packages))
