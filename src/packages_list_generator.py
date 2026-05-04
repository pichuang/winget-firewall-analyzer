"""套件清單產生器 — 自動產生 packages-list.md 的基礎架構

結合 config.yaml 的允許/封鎖清單與 packages-security.yaml 的人工資安評估，
自動產生分類套件清單與風險標注。
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import yaml

from src.blocklist import filter_packages, is_blocked, load_blocklist


# ── 資料模型 ──


@dataclass
class SecurityInfo:
    """單一套件的資安評估資料。"""
    package_id: str
    risk_level: str  # "high" / "medium" / "low" / "none"
    risk_reason: str = ""
    mitre_tactic: str = ""
    mitre_technique: str = ""
    red_team_use: str = ""
    access_tier: int = 4  # 1=IT 管理員, 2=開發人員, 3=需審批, 4=一般使用者
    access_reason: str = ""


@dataclass
class Category:
    """套件分類定義。"""
    name: str
    description: str
    prefixes: list[str] = field(default_factory=list)


# ── 載入函式 ──


def load_security_yaml(path: str = "packages-security.yaml") -> dict[str, SecurityInfo]:
    """載入資安評估 YAML，回傳 {package_id: SecurityInfo} 對照表。"""
    yaml_path = Path(path)
    if not yaml_path.exists():
        return {}

    with open(yaml_path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    result: dict[str, SecurityInfo] = {}

    for level_key, level_name in [
        ("high_risk", "high"),
        ("medium_risk", "medium"),
        ("low_risk", "low"),
    ]:
        for item in data.get(level_key, []):
            pkg_id = item["package_id"]
            result[pkg_id] = SecurityInfo(
                package_id=pkg_id,
                risk_level=level_name,
                risk_reason=item.get("risk_reason", ""),
                mitre_tactic=item.get("mitre_tactic", ""),
                mitre_technique=item.get("mitre_technique", ""),
                red_team_use=item.get("red_team_use", ""),
                access_tier=item.get("access_tier", 4),
                access_reason=item.get("access_reason", ""),
            )

    return result


def load_categories(path: str = "packages-security.yaml") -> list[Category]:
    """載入分類規則。"""
    yaml_path = Path(path)
    if not yaml_path.exists():
        return []

    with open(yaml_path, encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    categories: list[Category] = []
    for item in data.get("categories", []):
        categories.append(Category(
            name=item["name"],
            description=item.get("description", ""),
            prefixes=item.get("prefixes", []),
        ))
    return categories


# ── 分類邏輯 ──


def categorize_package(package_id: str, categories: list[Category]) -> str | None:
    """依最長前綴匹配規則，將套件分類。回傳分類名稱或 None。"""
    best_match: str | None = None
    best_prefix_len = 0

    for cat in categories:
        for prefix in cat.prefixes:
            # 精確匹配
            if package_id == prefix:
                if len(prefix) > best_prefix_len:
                    best_match = cat.name
                    best_prefix_len = len(prefix)
            # 前綴匹配（prefix 以 "." 結尾表示子命名空間）
            elif prefix.endswith(".") and package_id.startswith(prefix):
                if len(prefix) > best_prefix_len:
                    best_match = cat.name
                    best_prefix_len = len(prefix)
            # 前綴匹配（精確 ID 開頭，需完全匹配或後接 "."）
            elif package_id == prefix or package_id.startswith(prefix + "."):
                if len(prefix) > best_prefix_len:
                    best_match = cat.name
                    best_prefix_len = len(prefix)

    return best_match


def categorize_all(
    package_ids: list[str],
    categories: list[Category],
) -> tuple[dict[str, list[str]], list[str]]:
    """將所有套件分類，回傳 ({分類名稱: [套件ID]}, [未分類套件])。"""
    categorized: dict[str, list[str]] = {cat.name: [] for cat in categories}
    uncategorized: list[str] = []

    for pkg_id in sorted(package_ids):
        cat_name = categorize_package(pkg_id, categories)
        if cat_name:
            categorized[cat_name].append(pkg_id)
        else:
            uncategorized.append(pkg_id)

    return categorized, uncategorized


# ── 風險標注 ──


_RISK_EMOJI = {
    "high": "🔴 高",
    "medium": "🟡 中",
    "low": "🟢 低",
    "none": "",
}


def _risk_badge(security: dict[str, SecurityInfo], pkg_id: str) -> str:
    """取得套件的風險標注文字（空字串表示無風險）。"""
    info = security.get(pkg_id)
    if not info or info.risk_level == "none":
        return ""
    return f" {_RISK_EMOJI[info.risk_level]}"


# ── 驗證 ──


def validate_overlay(
    security: dict[str, SecurityInfo],
    allowed_ids: list[str],
    blocked_ids: list[str],
) -> list[str]:
    """驗證 overlay YAML 與實際套件清單的一致性，回傳警告訊息。"""
    warnings: list[str] = []
    all_known = set(allowed_ids) | set(blocked_ids)

    for pkg_id in security:
        if pkg_id not in all_known:
            warnings.append(f"⚠️  packages-security.yaml 中的 '{pkg_id}' 不在任何套件清單中（可能已移除或改名）")
        elif pkg_id in set(blocked_ids):
            warnings.append(f"ℹ️  packages-security.yaml 中的 '{pkg_id}' 已在封鎖清單中")

    return warnings


# ── Markdown 產生 ──


def generate_packages_list_md(
    allowed_ids: list[str],
    blocked_ids: list[str],
    categories: list[Category],
    security: dict[str, SecurityInfo],
) -> str:
    """產生完整的 packages-list.md 內容。"""
    now = datetime.now(timezone(timedelta(hours=8)))
    ts = now.strftime("%Y-%m-%d")

    lines: list[str] = []

    # ── 標題 ──
    lines.append("# winget 套件清單 — 分類報告")
    lines.append("")
    lines.append(f"> 產生時間：{ts} | 共 {len(allowed_ids) + len(blocked_ids)} 個探索到的套件"
                 f" | ✅ 允許 {len(allowed_ids)} 個 | ❌ 封鎖 {len(blocked_ids)} 個")
    lines.append("")

    # ── 分類 ──
    categorized, uncategorized = categorize_all(allowed_ids, categories)

    # ── 分類摘要表 ──
    lines.append("## 📊 分類摘要")
    lines.append("")
    lines.append("| 分類 | 說明 | 套件數 |")
    lines.append("|---|---|---|")
    total_allowed = 0
    for cat in categories:
        count = len(categorized.get(cat.name, []))
        if count > 0:
            lines.append(f"| {cat.name} | {cat.description} | {count} |")
            total_allowed += count
    if uncategorized:
        lines.append(f"| ❓ 未分類 | 無法自動歸類的套件 | {len(uncategorized)} |")
        total_allowed += len(uncategorized)
    lines.append(f"| **✅ 允許合計** | | **{total_allowed}** |")
    lines.append(f"| ❌ 封鎖 | 已 EOL / 已停產 / Preview 等 | {len(blocked_ids)} |")
    lines.append("")
    lines.append("---")
    lines.append("")

    # ── 資安風險評估 ──
    high_risk = [s for s in security.values() if s.risk_level == "high" and s.package_id in set(allowed_ids)]
    medium_risk = [s for s in security.values() if s.risk_level == "medium" and s.package_id in set(allowed_ids)]
    low_risk = [s for s in security.values() if s.risk_level == "low" and s.package_id in set(allowed_ids)]
    no_risk_count = len(allowed_ids) - len(high_risk) - len(medium_risk) - len(low_risk)

    lines.append("## ⚠️ 資安風險評估")
    lines.append("")
    lines.append("> 以下工具雖為 Microsoft 官方套件，但因其功能特性可能被內部有心人士濫用。")
    lines.append("> 建議依據風險等級搭配對應的管控措施。")
    lines.append("")

    # ── 紅隊工具表 ──
    red_team_items = [s for s in security.values()
                      if s.red_team_use and s.package_id in set(allowed_ids)]
    if red_team_items:
        lines.append("### 🎯 紅隊 / 攻擊者常用工具（MITRE ATT&CK 對照）")
        lines.append("")
        lines.append("> 以下套件是資安紅隊演練或真實攻擊中**經常被使用**的 Living-off-the-Land（LOLBin）工具。")
        lines.append("> 這些都是 Microsoft 官方工具，但因功能強大而被攻擊者廣泛濫用。")
        lines.append("")
        lines.append("| 套件識別碼 | ATT&CK 戰術 | 紅隊用途 |")
        lines.append("|---|---|---|")

        # 依戰術分組
        tactic_groups: dict[str, list[SecurityInfo]] = {}
        for item in red_team_items:
            tactic = item.mitre_tactic or "其他"
            tactic_groups.setdefault(tactic, []).append(item)

        for tactic, items in tactic_groups.items():
            lines.append(f"| **{tactic}** | | |")
            for item in sorted(items, key=lambda x: x.package_id):
                lines.append(
                    f"| `{item.package_id}` | {item.mitre_technique} | {item.red_team_use} |"
                )
        lines.append("")

    # ── 風險等級說明 ──
    lines.append("### 風險等級說明")
    lines.append("")
    lines.append("| 等級 | 說明 | 建議管控 |")
    lines.append("|---|---|---|")
    lines.append("| 🔴 高風險 | 可直接用於資料外洩、權限提升、繞過安全控制 | 限制安裝權限、啟用稽核日誌、僅授權特定人員使用 |")
    lines.append("| 🟡 中風險 | 可間接協助攻擊、收集系統資訊、修改系統組態 | 記錄使用行為、定期審查安裝清單 |")
    lines.append("| 🟢 低風險 | 正常用途但需注意，功能可能影響系統組態 | 一般管控即可 |")
    lines.append("")

    # ── 各風險等級套件表 ──
    for level_name, level_items, count_label in [
        ("🔴 高風險", high_risk, "高風險"),
        ("🟡 中風險", medium_risk, "中風險"),
        ("🟢 低風險", low_risk, "低風險"),
    ]:
        if level_items:
            lines.append(f"### {level_name}套件（{len(level_items)} 個）")
            lines.append("")
            lines.append("| 套件識別碼 | 風險說明 |")
            lines.append("|---|---|")
            for item in sorted(level_items, key=lambda x: x.package_id):
                lines.append(f"| `{item.package_id}` | {item.risk_reason} |")
            lines.append("")

    # ── 風險統計 ──
    lines.append("### 📊 風險統計")
    lines.append("")
    lines.append(f"- 🔴 高風險：{len(high_risk)} 個套件")
    lines.append(f"- 🟡 中風險：{len(medium_risk)} 個套件")
    lines.append(f"- 🟢 低風險：{len(low_risk)} 個套件")
    lines.append(f"- ⚪ 無特殊風險：{no_risk_count} 個套件")
    lines.append("")

    # ── 存取控制分級 ──
    _generate_access_control_section(lines, security, allowed_ids)

    lines.append("---")
    lines.append("")

    # ── 各分類套件清單 ──
    for cat in categories:
        pkgs = categorized.get(cat.name, [])
        if not pkgs:
            continue
        lines.append(f"## {cat.name}")
        lines.append("")
        lines.append(f"> {cat.description}")
        lines.append("")
        for pkg_id in sorted(pkgs):
            badge = _risk_badge(security, pkg_id)
            lines.append(f"- `{pkg_id}`{badge}")
        lines.append("")
        lines.append("---")
        lines.append("")

    # ── 未分類套件 ──
    if uncategorized:
        lines.append("## ❓ 未分類套件")
        lines.append("")
        lines.append("> 以下套件無法自動歸類，請在 `packages-security.yaml` 的 `categories` 中新增對應的前綴規則。")
        lines.append("")
        for pkg_id in sorted(uncategorized):
            badge = _risk_badge(security, pkg_id)
            lines.append(f"- `{pkg_id}`{badge}")
        lines.append("")
        lines.append("---")
        lines.append("")

    # ── 封鎖套件清單 ──
    lines.append(f"## ❌ 封鎖的套件（{len(blocked_ids)} 個）")
    lines.append("")
    lines.append("> 以下套件已被封鎖清單排除（已 EOL、已停產、Preview/Beta 版本等），不進行防火牆規則分析。")
    lines.append("")
    for pkg_id in sorted(blocked_ids):
        lines.append(f"- `{pkg_id}`")
    lines.append("")

    return "\n".join(lines)


def _generate_access_control_section(
    lines: list[str],
    security: dict[str, SecurityInfo],
    allowed_ids: list[str],
) -> None:
    """產生存取控制分級區塊。"""
    allowed_set = set(allowed_ids)

    tier_labels = {
        1: ("🔒 第一級：僅限 IT 管理員 / 資安團隊", "需 Privileged Access Workstation（PAW）或特權帳號才可安裝："),
        2: ("👨\u200d💻 第二級：僅限開發人員", "需開發者群組審批，一般使用者不可安裝："),
        3: ("📋 第三級：需申請審批", "一般使用者提出申請後可開放："),
    }

    # 收集各分級套件
    tiers: dict[int, list[SecurityInfo]] = {1: [], 2: [], 3: []}
    for info in security.values():
        if info.package_id in allowed_set and info.access_tier in (1, 2, 3):
            tiers[info.access_tier].append(info)

    tier4_count = len(allowed_ids) - sum(len(v) for v in tiers.values())

    lines.append("### 🔐 建議存取控制分級")
    lines.append("")
    lines.append("> 建議搭配 Intune / SCCM 軟體部署政策，依 AD 群組控管安裝權限。")
    lines.append("")

    for tier_num in (1, 2, 3):
        items = tiers[tier_num]
        if not items:
            continue
        title, desc = tier_labels[tier_num]
        lines.append(f"#### {title}（{len(items)} 個）")
        lines.append("")
        lines.append(desc)
        lines.append("")
        lines.append("| 套件識別碼 | 限制理由 |")
        lines.append("|---|---|")
        for item in sorted(items, key=lambda x: x.package_id):
            lines.append(f"| `{item.package_id}` | {item.access_reason} |")
        lines.append("")

    lines.append(f"#### ✅ 第四級：一般使用者可用（{tier4_count} 個）")
    lines.append("")
    lines.append("無需特別限制，可透過 winget 自由安裝。")
    lines.append("")


# ── 主流程入口 ──


def generate_from_config(
    config: dict[str, Any],
    discovered_ids: list[str] | None = None,
    security_yaml_path: str = "packages-security.yaml",
) -> tuple[str, list[str]]:
    """從 config 與探索結果產生 packages-list.md。

    Args:
        config: 已載入的 config.yaml 內容
        discovered_ids: 已探索到的套件 ID（若為 None 則從 config 推算）
        security_yaml_path: 資安評估 YAML 路徑

    Returns:
        (markdown 內容, 警告訊息列表)
    """
    # 載入資安評估與分類規則
    security = load_security_yaml(security_yaml_path)
    categories = load_categories(security_yaml_path)

    # 決定套件清單
    if discovered_ids is not None:
        # 從外部提供的完整清單分離允許/封鎖
        blocklist_config = load_blocklist(config)
        allowed_ids, blocked_ids = filter_packages(
            discovered_ids,
            allowlist_config=config.get("allowlist"),
            blocklist_config=blocklist_config,
        )
    else:
        # 無外部清單時無法產生（需網路探索）
        allowed_ids = []
        blocked_ids = []

    # 驗證 overlay 一致性
    warnings = validate_overlay(security, allowed_ids, blocked_ids)

    # 產生 Markdown
    md = generate_packages_list_md(allowed_ids, blocked_ids, categories, security)

    return md, warnings
