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
    }
    if rule.source_ip_groups:
        result["sourceIpGroups"] = rule.source_ip_groups
    else:
        result["sourceAddresses"] = rule.source_addresses
    if rule.target_urls:
        result["targetUrls"] = rule.target_urls
    if rule.target_fqdns:
        result["targetFqdns"] = rule.target_fqdns
    if rule.description:
        result["description"] = rule.description
    return result


def format_json(
    rules: list[FirewallRule],
    rule_collection_name: str = "action-allow-mirror",
    rule_collection_group_name: str = "rcg-1100-mirror-winget",
    priority: int = 1100,
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
        "通訊協定", "來源位址", "來源 IP Group", "信心等級", "說明",
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
                ";".join(rule.source_ip_groups),
                rule.confidence.value,
                rule.description,
            ])

    return output.getvalue()


def format_azure_cli(
    rules: list[FirewallRule],
    firewall_policy_name: str = "<FIREWALL_POLICY_NAME>",
    resource_group: str = "<RESOURCE_GROUP>",
    rule_collection_group_name: str = "rcg-1100-mirror-winget",
    rule_collection_name: str = "action-allow-mirror",
    priority: int = 1100,
    rule_filter: str = "all",
) -> str:
    """產出 Azure CLI 指令（使用 Firewall Policy Draft 模式）。

    Args:
        rule_filter: 規則過濾模式
            - "tls": 僅 TLS Inspection path 層級規則（targetUrls）+ 基礎設施規則
            - "fqdn": 僅 FQDN 層級規則（targetFqdns，不含 path 規則）
            - "all": 所有規則（預設，包含 path + fqdn）

    若規則包含 source_ip_groups，預設使用 --source-ip-groups，
    並以註解附帶 --source-addresses 備用方案。
    使用 Draft 模式，規則不會直接套用，需手動執行 deploy 指令確認後才生效。
    """
    # 過濾規則
    if rule_filter == "tls":
        # TLS 模式：path 規則（targetUrls）+ 基礎設施規則（targetFqdns，package_id 含 *）
        filtered_rules = [
            r for r in rules
            if r.target_urls or (r.target_fqdns and "*" in r.package_id)
        ]
        mode_label = "TLS Inspection（Path 層級）"
        rc_suffix = "-tls"
    elif rule_filter == "fqdn":
        # FQDN 模式：純 FQDN 規則（不含 path 規則）
        filtered_rules = [
            r for r in rules
            if r.target_fqdns and not r.target_urls
        ]
        mode_label = "FQDN 層級（無 TLS Inspection）"
        rc_suffix = "-fqdn"
    else:
        filtered_rules = rules
        mode_label = "全部規則（TLS + FQDN）"
        rc_suffix = ""

    rc_name_full = f"{rule_collection_name}{rc_suffix}"

    total_rules = len(filtered_rules)

    lines: list[str] = [
        "#!/bin/bash",
        f"# Azure Firewall Policy 規則部署指令 — {mode_label}",
        "# ⚠️ 使用 Draft 模式：規則不會直接套用，需手動執行 deploy 指令確認後才生效",
        f"# 產生時間：請自行記錄",
        f"# 規則數量：{total_rules}",
        "",
        'set -euo pipefail',
        "",
        f'POLICY_NAME="{firewall_policy_name}"',
        f'RESOURCE_GROUP="{resource_group}"',
        f'RCG_NAME="{rule_collection_group_name}"',
        f'RC_NAME="{rc_name_full}"',
        f"PRIORITY={priority}",
        f"TOTAL_RULES={total_rules}",
        "CURRENT=0",
        "FAILED=0",
        "",
        "# 顏色定義",
        'RED="\\033[0;31m"',
        'GREEN="\\033[0;32m"',
        'YELLOW="\\033[0;33m"',
        'CYAN="\\033[0;36m"',
        'NC="\\033[0m" # No Color',
        "",
        "# =============================================",
        "# 前置檢查",
        "# =============================================",
        'echo -e "${CYAN}🔍 前置檢查...${NC}"',
        "",
        "# 確認 az CLI 已登入",
        'if ! az account show --output none 2>/dev/null; then',
        '  echo -e "${RED}❌ 尚未登入 Azure CLI，請先執行 az login${NC}"',
        "  exit 1",
        "fi",
        'SUBSCRIPTION=$(az account show --query "name" -o tsv)',
        'echo -e "${GREEN}✅ 已登入 Azure：${SUBSCRIPTION}${NC}"',
        "",
        "# 確認 Firewall Policy 存在",
        f'if az network firewall policy show --name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --output none 2>/dev/null; then',
        '  POLICY_SKU=$(az network firewall policy show --name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --query "sku.tier" -o tsv 2>/dev/null || echo "unknown")',
        '  echo -e "${GREEN}✅ Firewall Policy 存在：${POLICY_NAME}（SKU: ${POLICY_SKU}）${NC}"',
        "else",
        '  echo -e "${RED}❌ Firewall Policy 不存在：$POLICY_NAME${NC}"',
        '  echo -e "${RED}   Resource Group: $RESOURCE_GROUP${NC}"',
        "  exit 1",
        "fi",
        "",
        'echo ""',
        f'echo -e "${{CYAN}}📋 部署計畫：${{NC}}"',
        f'echo "   Policy:     $POLICY_NAME"',
        f'echo "   RCG:        $RCG_NAME"',
        f'echo "   Collection: $RC_NAME"',
        f'echo "   Priority:   $PRIORITY"',
        f'echo "   規則數量:   $TOTAL_RULES"',
        f'echo "   模式:       Draft（不會直接套用）"',
        'echo ""',
        "",
        "# =============================================",
        "# 步驟 1：建立 Rule Collection Group（若不存在）",
        "# =============================================",
        'echo -e "${CYAN}📦 步驟 1/6：檢查 Rule Collection Group...${NC}"',
        'if az network firewall policy rule-collection-group show --name "$RCG_NAME" --policy-name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --output none 2>/dev/null; then',
        '  echo -e "${GREEN}   ✅ RCG 已存在：${RCG_NAME}${NC}"',
        "else",
        '  echo -e "${YELLOW}   ⏳ 建立 RCG：${RCG_NAME} ...${NC}"',
        '  if az network firewall policy rule-collection-group create \\',
        '    --name "$RCG_NAME" \\',
        '    --policy-name "$POLICY_NAME" \\',
        '    --resource-group "$RESOURCE_GROUP" \\',
        "    --priority $PRIORITY --output none 2>&1; then",
        '    echo -e "${GREEN}   ✅ RCG 建立成功${NC}"',
        "  else",
        '    echo -e "${RED}   ❌ RCG 建立失敗${NC}"',
        "    exit 1",
        "  fi",
        "fi",
        "",
        "# =============================================",
        "# 步驟 2：建立 Firewall Policy Draft",
        "# =============================================",
        'echo -e "${CYAN}📝 步驟 2/6：建立 Policy Draft...${NC}"',
        "if az network firewall policy draft create \\",
        '  --policy-name "$POLICY_NAME" \\',
        "  --resource-group \"$RESOURCE_GROUP\" --output none 2>&1; then",
        '  echo -e "${GREEN}   ✅ Policy Draft 建立成功${NC}"',
        "else",
        '  echo -e "${YELLOW}   ⚠️  Policy Draft 已存在或建立失敗（繼續執行）${NC}"',
        "fi",
        "",
        "# =============================================",
        "# 步驟 3：建立 RCG Draft",
        "# =============================================",
        'echo -e "${CYAN}📝 步驟 3/6：建立 RCG Draft...${NC}"',
        "if az network firewall policy rule-collection-group draft create \\",
        '  --policy-name "$POLICY_NAME" \\',
        '  --resource-group "$RESOURCE_GROUP" \\',
        '  --rule-collection-group-name "$RCG_NAME" \\',
        "  --priority $PRIORITY --output none 2>&1; then",
        '  echo -e "${GREEN}   ✅ RCG Draft 建立成功${NC}"',
        "else",
        '  echo -e "${RED}   ❌ RCG Draft 建立失敗${NC}"',
        "  exit 1",
        "fi",
        "",
        "# =============================================",
        "# 步驟 4：在 Draft 中建立 Rule Collection",
        "# =============================================",
        'echo -e "${CYAN}📂 步驟 4/6：建立 Rule Collection...${NC}"',
        "if az network firewall policy rule-collection-group draft collection add-filter-collection \\",
        '  --policy-name "$POLICY_NAME" \\',
        '  --resource-group "$RESOURCE_GROUP" \\',
        '  --rule-collection-group-name "$RCG_NAME" \\',
        f'  --name "$RC_NAME" \\',
        "  --rule-type ApplicationRule \\",
        "  --action Allow \\",
    ]

    # TLS 模式啟用 TLS Inspection terminate
    if rule_filter == "tls":
        lines.append("  --enable-tls-insp true \\")

    lines.extend([
        f"  --collection-priority {priority + 100} --output none 2>&1; then",
        '  echo -e "${GREEN}   ✅ Rule Collection 建立成功：$RC_NAME${NC}"',
        "else",
        '  echo -e "${RED}   ❌ Rule Collection 建立失敗${NC}"',
        "  exit 1",
        "fi",
        "",
        "# =============================================",
        f"# 步驟 5：新增規則至 Draft（共 {total_rules} 條）",
        "# =============================================",
        f'echo -e "${{CYAN}}🔧 步驟 5/6：新增 {total_rules} 條規則至 Draft...${{NC}}"',
        'echo ""',
        "",
    ])

    for idx, rule in enumerate(filtered_rules, 1):
        targets = rule.target_urls if rule.target_urls else rule.target_fqdns
        target_flag = "--target-urls" if rule.target_urls else "--target-fqdns"
        targets_str = " ".join(f'"{t}"' for t in targets)

        use_ip_groups = bool(rule.source_ip_groups)
        sources_str = " ".join(f'"{s}"' for s in rule.source_addresses)
        ip_groups_str = " ".join(f'"{g}"' for g in rule.source_ip_groups) if use_ip_groups else ""

        lines.append(f'echo -ne "   [{idx}/{total_rules}] {rule.name} ... "')
        lines.extend([
            "if az network firewall policy rule-collection-group draft collection rule add \\",
            '  --policy-name "$POLICY_NAME" \\',
            '  --resource-group "$RESOURCE_GROUP" \\',
            '  --rule-collection-group-name "$RCG_NAME" \\',
            '  --collection-name "$RC_NAME" \\',
            f'  --name "{rule.name}" \\',
            "  --rule-type ApplicationRule \\",
            f"  --protocols Https=443 \\",
            f"  {target_flag} {targets_str} \\",
        ])

        if use_ip_groups:
            lines.append(f"  --source-ip-groups {ip_groups_str} --output none 2>&1; then")
        else:
            lines.append(f"  --source-addresses {sources_str} --output none 2>&1; then")

        lines.extend([
            '  echo -e "${GREEN}✅${NC}"',
            "  CURRENT=$((CURRENT + 1))",
            "else",
            '  echo -e "${RED}❌${NC}"',
            "  FAILED=$((FAILED + 1))",
            "fi",
            "",
        ])

    # 摘要與部署指引
    lines.extend([
        "# =============================================",
        "# 步驟 6：部署摘要",
        "# =============================================",
        'echo ""',
        'echo "=============================="',
        'echo -e "${CYAN}📊 部署摘要${NC}"',
        'echo "=============================="',
        'echo "   Policy:        $POLICY_NAME"',
        'echo "   RCG:           $RCG_NAME"',
        'echo "   Collection:    $RC_NAME"',
        f'echo -e "   ✅ 成功:        ${{GREEN}}$CURRENT / {total_rules}${{NC}}"',
        "if [ $FAILED -gt 0 ]; then",
        '  echo -e "   ❌ 失敗:        ${RED}$FAILED${NC}"',
        "fi",
        'echo "=============================="',
        'echo ""',
        "",
        "if [ $FAILED -gt 0 ]; then",
        '  echo -e "${YELLOW}⚠️  有 $FAILED 條規則新增失敗，請檢查錯誤訊息${NC}"',
        "fi",
        "",
        'echo -e "${YELLOW}⚠️  規則已寫入 Draft，尚未套用至正式環境${NC}"',
        'echo -e "${YELLOW}   請在 Azure Portal 確認 Draft 內容後，執行以下指令部署：${NC}"',
        'echo ""',
        "echo 'az network firewall policy rule-collection-group draft deploy \\'",
        "echo '  --policy-name \"'$POLICY_NAME'\" \\'",
        "echo '  --resource-group \"'$RESOURCE_GROUP'\" \\'",
        "echo '  --rule-collection-group-name \"'$RCG_NAME'\"'",
        'echo ""',
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
    rcg_name = fw.get("rule_collection_group_name", "rcg-1100-mirror-winget")
    rc_name = fw.get("rule_collection_name", "action-allow-mirror")
    priority = fw.get("priority", 1100)
    source_addresses = fw.get("source_addresses", ["10.0.0.0/8"])
    source_ip_groups = fw.get("source_ip_groups", [])

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
        f"| Source IP Groups | `{', '.join(source_ip_groups)}`{' （主要）' if source_ip_groups else ' —'} |",
        f"| Source Addresses | `{', '.join(source_addresses)}`{' （備用）' if source_ip_groups else ''} |",
        f"| 規則總數 | {len(rules)} |",
        f"| 分析時間 | {now} |",
        "",
        "**快速部署參考**：",
        "",
        "```bash",
        "# 套用所有規則（JSON 格式）",
        "python main.py --all -f json",
        "",
        "# 產生 Azure CLI 部署指令",
        "python main.py --all -f cli",
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
                "```yaml",
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
                "```yaml",
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
        "",
        "  ```bash",
        "  python main.py --all -f md",
        "  diff generated/firewall-rules.md generated/firewall-rules-new.md",
        "  ```",
        "",
        "- 版本號已正規化為萬用字元 `*`，多數情況下版本更新不需修改規則",
        "- 若安裝檔的下載來源（FQDN）變更，則需更新防火牆規則",
        "",
    ])

    return "\n".join(lines)
