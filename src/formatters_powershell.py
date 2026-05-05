"""PowerShell 5.1 部署腳本格式化器 — Azure Firewall Policy Draft 模式

產生與 format_azure_cli（Bash 版）功能對等的 PowerShell 5.1 部署腳本。
支援冪等執行、Draft 模式、前置檢查、部署摘要。

PowerShell 5.1 注意事項：
  - az CLI 失敗不會自動觸發 terminating error，需透過 $LASTEXITCODE 明確處理
  - 字串比較預設不區分大小寫，規則比對使用 -ceq（case-sensitive）
  - ConvertFrom-Json 回傳 PSCustomObject，需以 @() 確保陣列一致性
  - 輸出檔案需使用 UTF-8 with BOM，否則 Windows PowerShell 5.1 可能亂碼
"""

from __future__ import annotations

from src.models import FirewallRule


def format_azure_powershell(
    rules: list[FirewallRule],
    firewall_policy_name: str = "<FIREWALL_POLICY_NAME>",
    resource_group: str = "<RESOURCE_GROUP>",
    rule_collection_group_name: str = "rcg-1100-mirror-winget",
    rule_collection_name: str = "action-allow-mirror",
    priority: int = 1100,
    rule_filter: str = "all",
    subscription_id: str = "",
) -> str:
    """產出 PowerShell 5.1 部署腳本（冪等 + Draft 模式）。

    Args:
        rule_filter: 規則過濾模式
            - "tls": 僅 TLS Inspection path 層級規則（targetUrls）+ 基礎設施規則
            - "fqdn": 僅 FQDN 層級規則（targetFqdns，不含 path 規則）
            - "all": 所有規則（預設，包含 path + fqdn）

    冪等行為：
    - 重複執行時，已存在且內容相同的規則會跳過
    - 已存在但內容不同的規則會先移除再新增（以當前最新版本為主）
    - 全程使用 Draft 模式，規則不會直接套用，需手動 deploy 確認
    """
    # 過濾規則
    if rule_filter == "tls":
        filtered_rules = [
            r for r in rules
            if r.target_urls or (r.target_fqdns and "*" in r.package_id)
        ]
        mode_label = "TLS Inspection（Path 層級）"
    elif rule_filter == "fqdn":
        filtered_rules = [
            r for r in rules
            if r.target_fqdns and not r.target_urls
        ]
        mode_label = "FQDN 層級（無 TLS Inspection）"
    else:
        filtered_rules = rules
        mode_label = "全部規則（TLS + FQDN）"

    rc_name_full = rule_collection_name
    total_rules = len(filtered_rules)

    lines: list[str] = []

    # ── 檔頭 ──
    lines.extend([
        f"# Azure Firewall Policy 規則部署指令 — {mode_label}",
        "# ⚠️ 使用 Draft 模式：規則不會直接套用，需手動執行 deploy 指令確認後才生效",
        "# 🔄 冪等執行：相同規則自動跳過，不同規則以最新版本覆蓋",
        "# 產生時間：請自行記錄",
        f"# 規則數量：{total_rules}",
        "# PowerShell 版本需求：5.1 以上",
        "",
        "#Requires -Version 5.1",
        "",
        "$ErrorActionPreference = 'Stop'",
        "Set-StrictMode -Version Latest",
        "",
        f'$PolicyName = "{firewall_policy_name}"',
        f'$ResourceGroup = "{resource_group}"',
        f'$RcgName = "{rule_collection_group_name}"',
        f'$RcName = "{rc_name_full}"',
        f"$Priority = {priority}",
        f'$ExpectedSubscriptionId = "{subscription_id}"',
        f"$TotalRules = {total_rules}",
        "$Current = 0",
        "$Failed = 0",
        "$Skipped = 0",
        "$Updated = 0",
        "",
    ])

    # ── 輔助函式：Invoke-AzCli ──
    lines.extend([
        "# =============================================",
        "# 輔助函式：安全執行 az CLI（檢查 $LASTEXITCODE）",
        "# =============================================",
        "function Invoke-AzCli {",
        "    [CmdletBinding()]",
        "    param(",
        "        [Parameter(Mandatory = $true)]",
        "        [string[]]$Arguments,",
        "        [switch]$IgnoreError,",
        "        [switch]$ReturnJson",
        "    )",
        "",
        "    $output = & az @Arguments 2>&1",
        "    $exitCode = $LASTEXITCODE",
        "",
        "    # 分離 stdout 與 stderr",
        "    $stdout = @($output | Where-Object { $_ -is [string] }) -join \"`n\"",
        "    $stderr = @($output | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }) -join \"`n\"",
        "",
        "    if ($exitCode -ne 0 -and -not $IgnoreError) {",
        '        throw "az CLI 執行失敗（exit code: $exitCode）：$stderr"',
        "    }",
        "",
        "    if ($ReturnJson -and $exitCode -eq 0 -and $stdout.Trim()) {",
        "        try {",
        "            return $stdout | ConvertFrom-Json",
        "        }",
        "        catch {",
        '            throw "無法解析 az CLI JSON 輸出：$($_.Exception.Message)"',
        "        }",
        "    }",
        "",
        "    return $stdout",
        "}",
        "",
    ])

    # ── 輔助函式：比對規則 ──
    lines.extend([
        "# =============================================",
        "# 輔助函式：比對規則是否已存在且內容相同",
        "# =============================================",
        "function Test-RuleExistsAndMatches {",
        "    [CmdletBinding()]",
        "    param(",
        "        [string]$RuleName,",
        "        [string[]]$ExpectedTargets,",
        '        [ValidateSet("targetUrls", "targetFqdns")]',
        "        [string]$TargetType",
        "    )",
        "",
        "    # 從 Draft 中查詢現有規則",
        "    try {",
        "        $existing = Invoke-AzCli -Arguments @(",
        '            "network", "firewall", "policy", "rule-collection-group",',
        '            "draft", "collection", "rule", "show",',
        '            "--policy-name", $PolicyName,',
        '            "--resource-group", $ResourceGroup,',
        '            "--rule-collection-group-name", $RcgName,',
        '            "--collection-name", $RcName,',
        '            "--name", $RuleName,',
        '            "--output", "json"',
        "        ) -ReturnJson -IgnoreError",
        "    }",
        "    catch {",
        "        return 'not_found'",
        "    }",
        "",
        "    if ($null -eq $existing) {",
        "        return 'not_found'",
        "    }",
        "",
        "    # 取出目前的 targets（依類型選擇欄位）",
        '    if ($TargetType -ceq "targetUrls") {',
        "        $currentTargets = @($existing.targetUrls)",
        "    }",
        "    else {",
        "        $currentTargets = @($existing.targetFqdns)",
        "    }",
        "",
        "    # 過濾 $null",
        "    $currentTargets = @($currentTargets | Where-Object { $null -ne $_ })",
        "    $ExpectedTargets = @($ExpectedTargets | Where-Object { $null -ne $_ })",
        "",
        "    # 排序後做 case-sensitive 比較",
        "    $sortedCurrent = @($currentTargets | Sort-Object)",
        "    $sortedExpected = @($ExpectedTargets | Sort-Object)",
        "",
        "    if ($sortedCurrent.Count -ne $sortedExpected.Count) {",
        "        return 'different'",
        "    }",
        "",
        "    for ($i = 0; $i -lt $sortedCurrent.Count; $i++) {",
        "        if ($sortedCurrent[$i] -cne $sortedExpected[$i]) {",
        "            return 'different'",
        "        }",
        "    }",
        "",
        "    return 'match'",
        "}",
        "",
    ])

    # ── 輔助函式：移除 Draft 規則 ──
    lines.extend([
        "# 移除 Draft 中的指定規則",
        "function Remove-DraftRule {",
        "    [CmdletBinding()]",
        "    param([string]$RuleName)",
        "",
        "    try {",
        "        Invoke-AzCli -Arguments @(",
        '            "network", "firewall", "policy", "rule-collection-group",',
        '            "draft", "collection", "rule", "remove",',
        '            "--policy-name", $PolicyName,',
        '            "--resource-group", $ResourceGroup,',
        '            "--rule-collection-group-name", $RcgName,',
        '            "--collection-name", $RcName,',
        '            "--name", $RuleName,',
        '            "--output", "none"',
        "        ) -IgnoreError | Out-Null",
        "    }",
        "    catch {",
        "        # 忽略移除失敗",
        "    }",
        "}",
        "",
    ])

    # ── 前置檢查 ──
    lines.extend([
        "# =============================================",
        "# 前置檢查",
        "# =============================================",
        'Write-Host "🔍 前置檢查..." -ForegroundColor Cyan',
        "",
        "# 啟用 Azure CLI 擴充功能自動安裝（含 preview）",
        "try {",
        '    Invoke-AzCli -Arguments @("config", "set", "extension.dynamic_install_allow_preview=true", "--only-show-errors") -IgnoreError | Out-Null',
        "}",
        "catch {",
        "    # 忽略 config 設定失敗",
        "}",
        'Write-Host "✅ 已啟用 az CLI 擴充功能自動安裝" -ForegroundColor Green',
        "",
        "# 確認 az CLI 已安裝",
        "try {",
        "    $null = Get-Command az -ErrorAction Stop",
        "}",
        "catch {",
        '    Write-Host "❌ 需要 Azure CLI（az），請先安裝：https://aka.ms/installazurecli" -ForegroundColor Red',
        "    exit 1",
        "}",
        "",
        "# 確認 az CLI 已登入",
        "try {",
        '    $account = Invoke-AzCli -Arguments @("account", "show", "--output", "json") -ReturnJson',
        "}",
        "catch {",
        '    Write-Host "❌ 尚未登入 Azure CLI，請先執行 az login" -ForegroundColor Red',
        "    exit 1",
        "}",
        '$CurrentSubName = $account.name',
        '$CurrentSubId = $account.id',
        'Write-Host "✅ 已登入 Azure：$CurrentSubName ($CurrentSubId)" -ForegroundColor Green',
        "",
        "# 確認 Azure 訂閱正確",
        "if ($ExpectedSubscriptionId) {",
        "    if ($CurrentSubId -cne $ExpectedSubscriptionId) {",
        '        Write-Host "❌ Azure 訂閱不符" -ForegroundColor Red',
        '        Write-Host "   預期: $ExpectedSubscriptionId" -ForegroundColor Red',
        '        Write-Host "   目前: $CurrentSubId ($CurrentSubName)" -ForegroundColor Red',
        '        Write-Host "   請執行: az account set --subscription $ExpectedSubscriptionId" -ForegroundColor Yellow',
        "        exit 1",
        "    }",
        '    Write-Host "✅ Azure 訂閱正確：$CurrentSubId" -ForegroundColor Green',
        "}",
        "else {",
        '    Write-Host "⚠️  未設定預期訂閱 ID（config.yaml firewall.subscription_id），跳過訂閱檢查" -ForegroundColor Yellow',
        '    Write-Host "   目前訂閱：$CurrentSubName ($CurrentSubId)" -ForegroundColor Yellow',
        "}",
        "",
        "# 確認 Firewall Policy 存在",
        "try {",
        '    $policyInfo = Invoke-AzCli -Arguments @("network", "firewall", "policy", "show", "--name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "json") -ReturnJson',
        '    $policySku = if ($policyInfo.sku -and $policyInfo.sku.tier) { $policyInfo.sku.tier } else { "unknown" }',
        '    Write-Host "✅ Firewall Policy 存在：$PolicyName（SKU: $policySku）" -ForegroundColor Green',
        "}",
        "catch {",
        '    Write-Host "❌ Firewall Policy 不存在：$PolicyName" -ForegroundColor Red',
        '    Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor Red',
        "    exit 1",
        "}",
        "",
        'Write-Host ""',
        'Write-Host "📋 部署計畫：" -ForegroundColor Cyan',
        'Write-Host "   Policy:     $PolicyName"',
        'Write-Host "   RCG:        $RcgName"',
        'Write-Host "   Collection: $RcName"',
        'Write-Host "   Priority:   $Priority"',
        'Write-Host "   規則數量:   $TotalRules"',
        'Write-Host "   模式:       Draft（冪等，不會直接套用）"',
        'Write-Host ""',
        "",
    ])

    # ── 步驟 1：建立 RCG ──
    lines.extend([
        "# =============================================",
        "# 步驟 1：建立 Rule Collection Group（若不存在）",
        "# =============================================",
        'Write-Host "📦 步驟 1/6：檢查 Rule Collection Group..." -ForegroundColor Cyan',
        "try {",
        '    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "show", "--name", $RcgName, "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "none") | Out-Null',
        '    Write-Host "   ✅ RCG 已存在：$RcgName" -ForegroundColor Green',
        "}",
        "catch {",
        '    Write-Host "   ⏳ 建立 RCG：$RcgName ..." -ForegroundColor Yellow',
        "    try {",
        '        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "create", "--name", $RcgName, "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--priority", "$Priority", "--output", "none") | Out-Null',
        '        Write-Host "   ✅ RCG 建立成功" -ForegroundColor Green',
        "    }",
        "    catch {",
        '        Write-Host "   ❌ RCG 建立失敗：$($_.Exception.Message)" -ForegroundColor Red',
        "        exit 1",
        "    }",
        "}",
        "",
    ])

    # ── 步驟 2：建立 Policy Draft ──
    lines.extend([
        "# =============================================",
        "# 步驟 2：建立 Firewall Policy Draft",
        "# =============================================",
        'Write-Host "📝 步驟 2/6：建立 Policy Draft..." -ForegroundColor Cyan',
        "try {",
        '    Invoke-AzCli -Arguments @("network", "firewall", "policy", "draft", "create", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "none") | Out-Null',
        '    Write-Host "   ✅ Policy Draft 建立成功" -ForegroundColor Green',
        "}",
        "catch {",
        '    Write-Host "   ⚠️  Policy Draft 已存在或建立失敗（繼續執行）" -ForegroundColor Yellow',
        "}",
        "",
    ])

    # ── 步驟 3：建立 RCG Draft ──
    lines.extend([
        "# =============================================",
        "# 步驟 3：建立 RCG Draft",
        "# =============================================",
        'Write-Host "📝 步驟 3/6：建立 RCG Draft..." -ForegroundColor Cyan',
        "try {",
        '    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "create", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--priority", "$Priority", "--output", "none") | Out-Null',
        '    Write-Host "   ✅ RCG Draft 建立成功" -ForegroundColor Green',
        "}",
        "catch {",
        '    Write-Host "   ⚠️  RCG Draft 已存在（繼續執行）" -ForegroundColor Yellow',
        "}",
        "",
    ])

    # ── 步驟 4：確認 Rule Collection ──
    enable_tls_args = ""
    if rule_filter == "tls":
        enable_tls_args = ', "--enable-tls-insp", "true"'

    lines.extend([
        "# =============================================",
        "# 步驟 4：確認 Rule Collection（沿用既有或建立新的）",
        "# =============================================",
        'Write-Host "📂 步驟 4/6：檢查 Rule Collection..." -ForegroundColor Cyan',
        "$RcExists = $false",
        "",
        "# 先檢查 Draft 中是否已有 Rule Collection",
        "try {",
        '    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "show", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--output", "none") | Out-Null',
        "    $RcExists = $true",
        '    Write-Host "   ✅ Rule Collection 已存在於 Draft 中：$RcName（沿用）" -ForegroundColor Green',
        "}",
        "catch {",
        "    # Draft 中不存在",
        "}",
        "",
        "# 若 Draft 中不存在，檢查正式環境",
        "if (-not $RcExists) {",
        "    try {",
        '        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "collection", "show", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--output", "none") | Out-Null',
        "        $RcExists = $true",
        '        Write-Host "   ✅ Rule Collection 已存在於正式環境：$RcName（Draft 會自動沿用）" -ForegroundColor Green',
        "    }",
        "    catch {",
        "        # 正式環境也不存在",
        "    }",
        "}",
        "",
        "# 都不存在才建立",
        "if (-not $RcExists) {",
        '    Write-Host "   ⏳ 建立 Rule Collection：$RcName ..." -ForegroundColor Yellow',
        "    try {",
        f'        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "add-filter-collection", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--rule-type", "ApplicationRule", "--action", "Allow"{enable_tls_args}, "--collection-priority", "{priority + 100}", "--output", "none") | Out-Null',
        '        Write-Host "   ✅ Rule Collection 建立成功：$RcName" -ForegroundColor Green',
        "    }",
        "    catch {",
        '        Write-Host "   ❌ Rule Collection 建立失敗：$($_.Exception.Message)" -ForegroundColor Red',
        "        exit 1",
        "    }",
        "}",
        "",
    ])

    # ── 步驟 5：新增/更新規則 ──
    lines.extend([
        "# =============================================",
        f"# 步驟 5：新增/更新規則至 Draft（共 {total_rules} 條）",
        "# =============================================",
        f'Write-Host "🔧 步驟 5/6：同步 {total_rules} 條規則至 Draft（冪等模式）..." -ForegroundColor Cyan',
        'Write-Host ""',
        "",
    ])

    for idx, rule in enumerate(filtered_rules, 1):
        targets = rule.target_urls if rule.target_urls else rule.target_fqdns
        target_flag = "--target-urls" if rule.target_urls else "--target-fqdns"
        target_type = "targetUrls" if rule.target_urls else "targetFqdns"

        # 建構 targets 陣列字串（PowerShell 格式）
        targets_ps_array = ", ".join(f'"{t}"' for t in targets)

        use_ip_groups = bool(rule.source_ip_groups)
        if use_ip_groups:
            sources_ps_array = ", ".join(f'"{g}"' for g in rule.source_ip_groups)
            source_flag = "--source-ip-groups"
        else:
            sources_ps_array = ", ".join(f'"{s}"' for s in rule.source_addresses)
            source_flag = "--source-addresses"

        # 建構 az CLI 參數的 target 清單
        targets_args = ", ".join(f'"{t}"' for t in targets)
        if use_ip_groups:
            sources_args = ", ".join(f'"{g}"' for g in rule.source_ip_groups)
        else:
            sources_args = ", ".join(f'"{s}"' for s in rule.source_addresses)

        lines.append(f'Write-Host -NoNewline "   [{idx}/{total_rules}] {rule.name} ... "')
        lines.append(f'$expectedTargets = @({targets_ps_array})')
        lines.append(f'$result = Test-RuleExistsAndMatches -RuleName "{rule.name}" -ExpectedTargets $expectedTargets -TargetType "{target_type}"')
        lines.append("")

        # case: match → 跳過
        lines.append("if ($result -ceq 'match') {")
        lines.append('    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan')
        lines.append("    $Skipped++")
        lines.append("}")

        # case: different → 更新
        lines.append("elseif ($result -ceq 'different') {")
        lines.append('    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow')
        lines.append(f'    Remove-DraftRule -RuleName "{rule.name}"')
        lines.append("    try {")
        lines.append(f'        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "{rule.name}", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "{target_flag}", {targets_args}, "{source_flag}", {sources_args}, "--output", "none") | Out-Null')
        lines.append('        Write-Host "✅ 已更新" -ForegroundColor Green')
        lines.append("        $Updated++")
        lines.append("    }")
        lines.append("    catch {")
        lines.append('        Write-Host "❌" -ForegroundColor Red')
        lines.append("        $Failed++")
        lines.append("    }")
        lines.append("}")

        # case: not_found → 新增
        lines.append("else {")
        lines.append("    try {")
        lines.append(f'        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "{rule.name}", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "{target_flag}", {targets_args}, "{source_flag}", {sources_args}, "--output", "none") | Out-Null')
        lines.append('        Write-Host "✅ 新增" -ForegroundColor Green')
        lines.append("        $Current++")
        lines.append("    }")
        lines.append("    catch {")
        lines.append('        Write-Host "❌" -ForegroundColor Red')
        lines.append("        $Failed++")
        lines.append("    }")
        lines.append("}")
        lines.append("")

    # ── 步驟 6：部署摘要 ──
    lines.extend([
        "# =============================================",
        "# 步驟 6：部署摘要",
        "# =============================================",
        'Write-Host ""',
        'Write-Host "=============================="',
        'Write-Host "📊 部署摘要" -ForegroundColor Cyan',
        'Write-Host "=============================="',
        'Write-Host "   Policy:        $PolicyName"',
        'Write-Host "   RCG:           $RcgName"',
        'Write-Host "   Collection:    $RcName"',
        'Write-Host "   ✅ 新增:        $Current" -ForegroundColor Green',
        'Write-Host "   🔄 更新:        $Updated" -ForegroundColor Yellow',
        'Write-Host "   ⏭️  跳過:        $Skipped"',
        "if ($Failed -gt 0) {",
        '    Write-Host "   ❌ 失敗:        $Failed" -ForegroundColor Red',
        "}",
        'Write-Host "=============================="',
        'Write-Host ""',
        "",
        "if ($Failed -gt 0) {",
        '    Write-Host "⚠️  有 $Failed 條規則處理失敗，請檢查錯誤訊息" -ForegroundColor Yellow',
        "}",
        "",
        'Write-Host "⚠️  規則已寫入 Draft，尚未套用至正式環境" -ForegroundColor Yellow',
        'Write-Host "   請在 Azure Portal 確認 Draft 內容後，執行以下指令部署：" -ForegroundColor Yellow',
        'Write-Host ""',
        'Write-Host "az network firewall policy rule-collection-group draft deploy ``"',
        'Write-Host "  --policy-name `"$PolicyName`" ``"',
        'Write-Host "  --resource-group `"$ResourceGroup`" ``"',
        'Write-Host "  --rule-collection-group-name `"$RcgName`""',
        'Write-Host ""',
        "",
    ])

    return "\n".join(lines)
