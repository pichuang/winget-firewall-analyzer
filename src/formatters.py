"""輸出格式化器 — JSON / CSV / Azure CLI / Markdown"""

from __future__ import annotations

import csv
import io
import json
from dataclasses import asdict
from typing import Any

from src.models import FirewallRule, PackageManifest, generalize_url_path


def _rule_to_arm_dict(rule: FirewallRule) -> dict[str, Any]:
    """將 FirewallRule 轉為 ARM Template 格式的 dict。"""
    result: dict[str, Any] = {
        "name": rule.name,
        "ruleType": rule.rule_type,
        "protocols": rule.protocols,
        "sourceAddresses": rule.source_addresses,
    }
    if rule.target_urls:
        result["targetUrls"] = rule.target_urls
    if rule.target_fqdns:
        result["targetFqdns"] = rule.target_fqdns
    if rule.description:
        result["description"] = rule.description
    return result


def format_json(
    rules: list[FirewallRule],
    rule_collection_name: str = "winget-download",
    rule_collection_group_name: str = "winget-rules",
    priority: int = 500,
) -> str:
    """產出 JSON 格式（ARM Template 相容）。"""
    arm_rules = [_rule_to_arm_dict(r) for r in rules]

    output = {
        "ruleCollectionGroupName": rule_collection_group_name,
        "properties": {
            "priority": priority,
            "ruleCollections": [
                {
                    "name": rule_collection_name,
                    "ruleCollectionType": "FirewallPolicyFilterRuleCollection",
                    "action": {"type": "Allow"},
                    "priority": priority,
                    "rules": arm_rules,
                }
            ],
        },
    }
    return json.dumps(output, indent=2, ensure_ascii=False)


def format_csv(rules: list[FirewallRule]) -> str:
    """產出 CSV 格式，方便人工審閱。"""
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "規則名稱", "套件識別碼", "類型", "目標（FQDN 或 URL）",
        "通訊協定", "來源位址", "信心等級", "說明",
    ])

    for rule in rules:
        targets = rule.target_urls if rule.target_urls else rule.target_fqdns
        target_type = "targetUrls" if rule.target_urls else "targetFqdns"

        for target in targets:
            writer.writerow([
                rule.name,
                rule.package_id,
                target_type,
                target,
                "Https:443",
                ";".join(rule.source_addresses),
                rule.confidence.value,
                rule.description,
            ])

    return output.getvalue()


def format_azure_cli(
    rules: list[FirewallRule],
    firewall_policy_name: str = "<FIREWALL_POLICY_NAME>",
    resource_group: str = "<RESOURCE_GROUP>",
    rule_collection_group_name: str = "winget-rules",
    rule_collection_name: str = "winget-download",
    priority: int = 500,
) -> str:
    """產出 Azure CLI 指令。"""
    lines: list[str] = [
        "#!/bin/bash",
        "# Azure Firewall Policy 規則部署指令",
        f"# 產生時間：請自行記錄",
        "",
        f'POLICY_NAME="{firewall_policy_name}"',
        f'RESOURCE_GROUP="{resource_group}"',
        f'RCG_NAME="{rule_collection_group_name}"',
        f'RC_NAME="{rule_collection_name}"',
        f"PRIORITY={priority}",
        "",
        "# 建立 Rule Collection Group（若不存在）",
        "az network firewall policy rule-collection-group create \\",
        '  --name "$RCG_NAME" \\',
        '  --policy-name "$POLICY_NAME" \\',
        '  --resource-group "$RESOURCE_GROUP" \\',
        '  --priority $PRIORITY 2>/dev/null || true',
        "",
        "# 建立 Rule Collection",
        "az network firewall policy rule-collection-group collection add-filter-collection \\",
        '  --name "$RC_NAME" \\',
        '  --policy-name "$POLICY_NAME" \\',
        '  --resource-group "$RESOURCE_GROUP" \\',
        '  --rcg-name "$RCG_NAME" \\',
        "  --rule-type ApplicationRule \\",
        "  --action Allow \\",
        f"  --priority {priority + 100}",
        "",
    ]

    for rule in rules:
        targets = rule.target_urls if rule.target_urls else rule.target_fqdns
        target_flag = "--target-urls" if rule.target_urls else "--target-fqdns"

        targets_str = " ".join(f'"{t}"' for t in targets)
        sources_str = " ".join(f'"{s}"' for s in rule.source_addresses)

        lines.extend([
            f"# {rule.description}",
            "az network firewall policy rule-collection-group collection rule add \\",
            '  --policy-name "$POLICY_NAME" \\',
            '  --resource-group "$RESOURCE_GROUP" \\',
            '  --rcg-name "$RCG_NAME" \\',
            '  --collection-name "$RC_NAME" \\',
            f'  --name "{rule.name}" \\',
            "  --rule-type ApplicationRule \\",
            f"  --protocols Https=443 \\",
            f"  {target_flag} {targets_str} \\",
            f"  --source-addresses {sources_str}",
            "",
        ])

    return "\n".join(lines)


def format_markdown(
    manifests: list[PackageManifest],
    rules: list[FirewallRule],
    base_fqdns: list[dict[str, str]] | None = None,
    firewall_config: dict[str, Any] | None = None,
) -> str:
    """產出 Markdown 格式的防火牆規則維護清單。"""
    from datetime import datetime, timezone, timedelta
    from src.models import Confidence, FqdnCategory

    # 匯入 rule_generator 中的分類函式
    from src.rule_generator import _classify_fqdn

    now = datetime.now(timezone(timedelta(hours=8))).strftime("%Y-%m-%d %H:%M:%S %Z")
    fw = firewall_config or {}
    rcg_name = fw.get("rule_collection_group_name", "winget-rules")
    rc_name = fw.get("rule_collection_name", "winget-download")
    priority = fw.get("priority", 500)
    source_addresses = fw.get("source_addresses", ["10.0.0.0/8"])

    lines: list[str] = [
        "# winget Azure Firewall Policy 規則清單",
        "",
        "> 此文件由 `main.py` 自動產生，記錄每個 winget 套件所需的防火牆放行規則。",
        "> 可作為維護與審閱的依據，建議納入版本控制。",
        "",
    ]

    # ── 部署資訊區塊 ──
    lines.extend([
        "## ⚙️ Azure Firewall Policy 部署資訊",
        "",
        "| 參數 | 值 |",
        "|---|---|",
        f"| Rule Collection Group | `{rcg_name}` |",
        f"| Rule Collection | `{rc_name}` |",
        f"| Priority | `{priority}` |",
        f"| Source Addresses | `{', '.join(source_addresses)}` |",
        f"| 規則總數 | {len(rules)} |",
        f"| 分析時間 | {now} |",
        "",
        "**快速部署參考**：",
        "",
        "```bash",
        "# 套用所有規則（JSON 格式）",
        f"python main.py {' '.join(m.package_id for m in manifests)} -f json > rules.json",
        "",
        "# 產生 Azure CLI 部署指令",
        f"python main.py {' '.join(m.package_id for m in manifests)} -f cli > deploy.sh",
        "```",
        "",
    ])

    # ── 套件摘要 ──
    lines.extend([
        "---",
        "",
        "## 📋 套件摘要",
        "",
        "| 套件識別碼 | 版本 | 安裝檔數 | 涉及 FQDN | 規則名稱（Path） | 規則名稱（FQDN） |",
        "|---|---|---|---|---|---|",
    ])

    path_rules: dict[str, FirewallRule] = {}
    fqdn_rules: dict[str, FirewallRule] = {}
    for rule in rules:
        if rule.package_id == "*":
            continue
        if rule.target_urls:
            path_rules[rule.package_id] = rule
        elif rule.target_fqdns:
            fqdn_rules[rule.package_id] = rule

    for manifest in manifests:
        pkg = manifest.package_id
        all_fqdns: set[str] = set()
        for inst in manifest.installers:
            for hop in inst.redirect_chain:
                if hop.fqdn:
                    all_fqdns.add(hop.fqdn)
        pr = path_rules.get(pkg)
        fr = fqdn_rules.get(pkg)
        pr_name = f"`{pr.name}`" if pr else "—"
        fr_name = f"`{fr.name}`" if fr else "—"
        lines.append(
            f"| `{pkg}` | {manifest.version} | {len(manifest.installers)} "
            f"| {len(all_fqdns)} | {pr_name} | {fr_name} |"
        )

    lines.append("")

    # ── FQDN 彙總表 ──
    # 收集所有套件 + 基礎設施的 FQDN
    fqdn_pkg_map: dict[str, dict[str, Any]] = {}

    # 基礎設施
    if base_fqdns:
        for entry in base_fqdns:
            fqdn = entry["fqdn"]
            fqdn_pkg_map[fqdn] = {
                "category": FqdnCategory.WINGET_SOURCE.value,
                "confidence": Confidence.HIGH.value,
                "packages": ["*（所有套件共用）"],
                "is_final": False,
                "description": entry.get("description", ""),
            }

    # 各套件
    for manifest in manifests:
        for inst in manifest.installers:
            for hop in inst.redirect_chain:
                if not hop.fqdn:
                    continue
                if hop.fqdn not in fqdn_pkg_map:
                    category = _classify_fqdn(hop.fqdn)
                    fqdn_pkg_map[hop.fqdn] = {
                        "category": category.value,
                        "confidence": (Confidence.HIGH if hop.is_final else Confidence.MEDIUM).value,
                        "packages": [],
                        "is_final": hop.is_final,
                        "description": "",
                    }
                entry_data = fqdn_pkg_map[hop.fqdn]
                if manifest.package_id not in entry_data["packages"]:
                    entry_data["packages"].append(manifest.package_id)
                if hop.is_final:
                    entry_data["is_final"] = True
                    entry_data["confidence"] = Confidence.HIGH.value

    lines.extend([
        "---",
        "",
        "## 🌐 FQDN 彙總表（跨套件）",
        "",
        "以下列出所有需要在 Azure Firewall Policy 中放行的 FQDN：",
        "",
        "| FQDN | 用途分類 | 信心等級 | 最終目標 | 涉及套件 |",
        "|---|---|---|---|---|",
    ])

    for fqdn in sorted(fqdn_pkg_map.keys()):
        data = fqdn_pkg_map[fqdn]
        final_mark = "✅" if data["is_final"] else "—"
        pkgs = ", ".join(f"`{p}`" for p in data["packages"])
        lines.append(
            f"| `{fqdn}` | {data['category']} | {data['confidence']} | {final_mark} | {pkgs} |"
        )

    lines.append("")

    # ── 基礎設施規則 ──
    if base_fqdns:
        lines.extend([
            "---",
            "",
            "## 🏗️ winget 基礎設施（所有套件共用）",
            "",
            "| FQDN | 用途 |",
            "|---|---|",
        ])
        for entry in base_fqdns:
            lines.append(f"| `{entry['fqdn']}` | {entry.get('description', '')} |")
        lines.append("")

    # ── 每個套件的詳細規則 ──
    lines.extend(["---", ""])

    for manifest in manifests:
        pkg = manifest.package_id
        lines.extend([
            f"## 📦 {pkg}",
            "",
            f"- **版本**: {manifest.version}",
            f"- **安裝檔數量**: {len(manifest.installers)}",
            "",
        ])

        # 重導向鏈詳情
        lines.append("### 下載路徑分析")
        lines.append("")

        for i, inst in enumerate(manifest.installers, 1):
            arch_label = inst.architecture or "unknown"
            scope_label = inst.scope or "—"
            lines.append(f"**安裝檔 {i}** — `{arch_label}` / `{scope_label}`")
            lines.append("")
            lines.append("| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |")
            lines.append("|---|---|---|---|---|")

            for j, hop in enumerate(inst.redirect_chain, 1):
                hop_type = "✅ 最終目標" if hop.is_final else "↪️ 重導向"
                generalized = generalize_url_path(hop.url)
                lines.append(
                    f"| {j} | `{hop.fqdn}` | {hop.status_code} | {hop_type} | `{generalized}` |"
                )
            lines.append("")

        # Path 層級規則
        pr = path_rules.get(pkg)
        if pr:
            lines.extend([
                "### 🔒 Path 層級規則（TLS Inspection）",
                "",
                f"**規則名稱**: `{pr.name}`",
                "",
                "```",
                "targetUrls:",
            ])
            for url in pr.target_urls:
                lines.append(f"  - {url}")
            lines.extend(["```", ""])

        # FQDN 層級規則
        fr = fqdn_rules.get(pkg)
        if fr:
            lines.extend([
                "### 🌍 FQDN 層級規則（備用）",
                "",
                f"**規則名稱**: `{fr.name}`",
                "",
                "```",
                "targetFqdns:",
            ])
            for fqdn in fr.target_fqdns:
                lines.append(f"  - {fqdn}")
            lines.extend(["```", ""])

        lines.extend(["---", ""])

    # ── 維護追蹤區塊 ──
    lines.extend([
        "## 🔄 規則維護追蹤",
        "",
        "| 套件識別碼 | 分析版本 | 分析日期 | 狀態 |",
        "|---|---|---|---|",
    ])

    for manifest in manifests:
        lines.append(
            f"| `{manifest.package_id}` | {manifest.version} | {now} | ✅ 已分析 |"
        )

    lines.extend([
        "",
        "### 維護建議",
        "",
        "- 建議定期重新執行分析，確認套件版本更新後下載路徑是否變更",
        "- 若有新版本發佈，重新產生規則並比對差異：",
        "  ```bash",
        f"  python main.py {' '.join(m.package_id for m in manifests)} -f md > firewall-rules-new.md",
        "  diff firewall-rules.md firewall-rules-new.md",
        "  ```",
        "- 版本號已正規化為萬用字元 `*`，多數情況下版本更新不需修改規則",
        "- 若安裝檔的下載來源（FQDN）變更，則需更新防火牆規則",
        "",
    ])

    return "\n".join(lines)
