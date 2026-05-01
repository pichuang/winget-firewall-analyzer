"""封鎖清單與允許清單過濾 — 支援 fnmatch 萬用字元匹配"""

from __future__ import annotations

import fnmatch
from typing import Any


def load_blocklist(config: dict[str, Any] | None = None) -> dict[str, Any]:
    """從設定檔中取得封鎖清單區塊。"""
    if config is None:
        return {"blocklist": {"enabled": False, "publishers": [], "packages": []}}
    bl = config.get("blocklist", {"enabled": False, "publishers": [], "packages": []})
    return {"blocklist": bl}


def matches_any_pattern(value: str, patterns: list[str]) -> bool:
    """檢查 value 是否匹配任一 fnmatch 萬用字元模式（不區分大小寫）。"""
    value_lower = value.lower()
    return any(fnmatch.fnmatch(value_lower, p.lower()) for p in patterns)


def is_blocked(
    package_id: str,
    blocklist_config: dict[str, Any],
    publisher: str = "",
) -> bool:
    """檢查套件是否在封鎖清單中。

    封鎖條件（OR）：
    - package_id 匹配 blocklist.packages 中的任一模式
    - publisher 匹配 blocklist.publishers 中的任一值
    """
    bl = blocklist_config.get("blocklist", {})
    if not bl.get("enabled", False):
        return False

    # 套件 ID 匹配
    blocked_packages = bl.get("packages", [])
    if matches_any_pattern(package_id, blocked_packages):
        return True

    # 發行者匹配
    blocked_publishers = bl.get("publishers", [])
    if publisher and matches_any_pattern(publisher, blocked_publishers):
        return True

    return False


def is_in_allowlist(
    package_id: str,
    allowlist_config: dict[str, Any],
) -> bool:
    """檢查套件是否在允許清單中。

    允許條件（OR）：
    - package_id 匹配 allowlist.packages 中的任一模式
    - （publisher 匹配需在取得 manifest 後才能判斷，此處僅檢查 ID）
    """
    al = allowlist_config.get("allowlist", allowlist_config)
    if not al.get("enabled", True):
        return True  # 未啟用 = 全部允許

    allowed_packages = al.get("packages", [])
    return matches_any_pattern(package_id, allowed_packages)


def filter_packages(
    package_ids: list[str],
    allowlist_config: dict[str, Any] | None = None,
    blocklist_config: dict[str, Any] | None = None,
) -> tuple[list[str], list[str]]:
    """過濾套件清單，回傳 (允許的套件, 被封鎖的套件)。

    封鎖清單優先於允許清單。
    """
    allowed: list[str] = []
    blocked: list[str] = []

    for pkg_id in package_ids:
        # 封鎖清單優先
        if blocklist_config and is_blocked(pkg_id, blocklist_config):
            blocked.append(pkg_id)
            continue

        # 允許清單檢查（若有提供）
        if allowlist_config and not is_in_allowlist(pkg_id, allowlist_config):
            blocked.append(pkg_id)
            continue

        allowed.append(pkg_id)

    return allowed, blocked
