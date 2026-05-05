# Azure Firewall Policy 規則部署指令 — TLS Inspection（Path 層級）
# ⚠️ 使用 Draft 模式：規則不會直接套用，需手動執行 deploy 指令確認後才生效
# 🔄 冪等執行：相同規則自動跳過，不同規則以最新版本覆蓋
# 產生時間：請自行記錄
# 規則數量：285
# PowerShell 版本需求：5.1 以上

#Requires -Version 5.1

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$PolicyName = "afwp-global-01"
$ResourceGroup = "rg-vdss-afwp-prd-global"
$RcgName = "rcg-1100-mirror-winget"
$RcName = "action-allow-mirror"
$Priority = 1100
$ExpectedSubscriptionId = ""
$TotalRules = 285
$Current = 0
$Failed = 0
$Skipped = 0
$Updated = 0

# =============================================
# 輔助函式：安全執行 az CLI（檢查 $LASTEXITCODE）
# =============================================
function Invoke-AzCli {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,
        [switch]$IgnoreError,
        [switch]$ReturnJson
    )

    $output = & az @Arguments 2>&1
    $exitCode = $LASTEXITCODE

    # 分離 stdout 與 stderr
    $stdout = @($output | Where-Object { $_ -is [string] }) -join "`n"
    $stderr = @($output | Where-Object { $_ -is [System.Management.Automation.ErrorRecord] }) -join "`n"

    if ($exitCode -ne 0 -and -not $IgnoreError) {
        throw "az CLI 執行失敗（exit code: $exitCode）：$stderr"
    }

    if ($ReturnJson -and $exitCode -eq 0 -and $stdout.Trim()) {
        try {
            return $stdout | ConvertFrom-Json
        }
        catch {
            throw "無法解析 az CLI JSON 輸出：$($_.Exception.Message)"
        }
    }

    return $stdout
}

# =============================================
# 輔助函式：比對規則是否已存在且內容相同
# =============================================
function Test-RuleExistsAndMatches {
    [CmdletBinding()]
    param(
        [string]$RuleName,
        [string[]]$ExpectedTargets,
        [ValidateSet("targetUrls", "targetFqdns")]
        [string]$TargetType
    )

    # 從 Draft 中查詢現有規則
    try {
        $existing = Invoke-AzCli -Arguments @(
            "network", "firewall", "policy", "rule-collection-group",
            "draft", "collection", "rule", "show",
            "--policy-name", $PolicyName,
            "--resource-group", $ResourceGroup,
            "--rule-collection-group-name", $RcgName,
            "--collection-name", $RcName,
            "--name", $RuleName,
            "--output", "json"
        ) -ReturnJson -IgnoreError
    }
    catch {
        return 'not_found'
    }

    if ($null -eq $existing) {
        return 'not_found'
    }

    # 取出目前的 targets（依類型選擇欄位）
    if ($TargetType -ceq "targetUrls") {
        $currentTargets = @($existing.targetUrls)
    }
    else {
        $currentTargets = @($existing.targetFqdns)
    }

    # 過濾 $null
    $currentTargets = @($currentTargets | Where-Object { $null -ne $_ })
    $ExpectedTargets = @($ExpectedTargets | Where-Object { $null -ne $_ })

    # 排序後做 case-sensitive 比較
    $sortedCurrent = @($currentTargets | Sort-Object)
    $sortedExpected = @($ExpectedTargets | Sort-Object)

    if ($sortedCurrent.Count -ne $sortedExpected.Count) {
        return 'different'
    }

    for ($i = 0; $i -lt $sortedCurrent.Count; $i++) {
        if ($sortedCurrent[$i] -cne $sortedExpected[$i]) {
            return 'different'
        }
    }

    return 'match'
}

# 移除 Draft 中的指定規則
function Remove-DraftRule {
    [CmdletBinding()]
    param([string]$RuleName)

    try {
        Invoke-AzCli -Arguments @(
            "network", "firewall", "policy", "rule-collection-group",
            "draft", "collection", "rule", "remove",
            "--policy-name", $PolicyName,
            "--resource-group", $ResourceGroup,
            "--rule-collection-group-name", $RcgName,
            "--collection-name", $RcName,
            "--name", $RuleName,
            "--output", "none"
        ) -IgnoreError | Out-Null
    }
    catch {
        # 忽略移除失敗
    }
}

# =============================================
# 前置檢查
# =============================================
Write-Host "🔍 前置檢查..." -ForegroundColor Cyan

# 啟用 Azure CLI 擴充功能自動安裝（含 preview）
try {
    Invoke-AzCli -Arguments @("config", "set", "extension.dynamic_install_allow_preview=true", "--only-show-errors") -IgnoreError | Out-Null
}
catch {
    # 忽略 config 設定失敗
}
Write-Host "✅ 已啟用 az CLI 擴充功能自動安裝" -ForegroundColor Green

# 確認 az CLI 已安裝
try {
    $null = Get-Command az -ErrorAction Stop
}
catch {
    Write-Host "❌ 需要 Azure CLI（az），請先安裝：https://aka.ms/installazurecli" -ForegroundColor Red
    exit 1
}

# 確認 az CLI 已登入
try {
    $account = Invoke-AzCli -Arguments @("account", "show", "--output", "json") -ReturnJson
}
catch {
    Write-Host "❌ 尚未登入 Azure CLI，請先執行 az login" -ForegroundColor Red
    exit 1
}
$CurrentSubName = $account.name
$CurrentSubId = $account.id
Write-Host "✅ 已登入 Azure：$CurrentSubName ($CurrentSubId)" -ForegroundColor Green

# 確認 Azure 訂閱正確
if ($ExpectedSubscriptionId) {
    if ($CurrentSubId -cne $ExpectedSubscriptionId) {
        Write-Host "❌ Azure 訂閱不符" -ForegroundColor Red
        Write-Host "   預期: $ExpectedSubscriptionId" -ForegroundColor Red
        Write-Host "   目前: $CurrentSubId ($CurrentSubName)" -ForegroundColor Red
        Write-Host "   請執行: az account set --subscription $ExpectedSubscriptionId" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "✅ Azure 訂閱正確：$CurrentSubId" -ForegroundColor Green
}
else {
    Write-Host "⚠️  未設定預期訂閱 ID（config.yaml firewall.subscription_id），跳過訂閱檢查" -ForegroundColor Yellow
    Write-Host "   目前訂閱：$CurrentSubName ($CurrentSubId)" -ForegroundColor Yellow
}

# 確認 Firewall Policy 存在
try {
    $policyInfo = Invoke-AzCli -Arguments @("network", "firewall", "policy", "show", "--name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "json") -ReturnJson
    $policySku = if ($policyInfo.sku -and $policyInfo.sku.tier) { $policyInfo.sku.tier } else { "unknown" }
    Write-Host "✅ Firewall Policy 存在：$PolicyName（SKU: $policySku）" -ForegroundColor Green
}
catch {
    Write-Host "❌ Firewall Policy 不存在：$PolicyName" -ForegroundColor Red
    Write-Host "   Resource Group: $ResourceGroup" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📋 部署計畫：" -ForegroundColor Cyan
Write-Host "   Policy:     $PolicyName"
Write-Host "   RCG:        $RcgName"
Write-Host "   Collection: $RcName"
Write-Host "   Priority:   $Priority"
Write-Host "   規則數量:   $TotalRules"
Write-Host "   模式:       Draft（冪等，不會直接套用）"
Write-Host ""

# =============================================
# 步驟 1：建立 Rule Collection Group（若不存在）
# =============================================
Write-Host "📦 步驟 1/6：檢查 Rule Collection Group..." -ForegroundColor Cyan
try {
    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "show", "--name", $RcgName, "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "none") | Out-Null
    Write-Host "   ✅ RCG 已存在：$RcgName" -ForegroundColor Green
}
catch {
    Write-Host "   ⏳ 建立 RCG：$RcgName ..." -ForegroundColor Yellow
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "create", "--name", $RcgName, "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--priority", "$Priority", "--output", "none") | Out-Null
        Write-Host "   ✅ RCG 建立成功" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ RCG 建立失敗：$($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# =============================================
# 步驟 2：建立 Firewall Policy Draft
# =============================================
Write-Host "📝 步驟 2/6：建立 Policy Draft..." -ForegroundColor Cyan
try {
    Invoke-AzCli -Arguments @("network", "firewall", "policy", "draft", "create", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--output", "none") | Out-Null
    Write-Host "   ✅ Policy Draft 建立成功" -ForegroundColor Green
}
catch {
    Write-Host "   ⚠️  Policy Draft 已存在或建立失敗（繼續執行）" -ForegroundColor Yellow
}

# =============================================
# 步驟 3：建立 RCG Draft
# =============================================
Write-Host "📝 步驟 3/6：建立 RCG Draft..." -ForegroundColor Cyan
try {
    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "create", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--priority", "$Priority", "--output", "none") | Out-Null
    Write-Host "   ✅ RCG Draft 建立成功" -ForegroundColor Green
}
catch {
    Write-Host "   ⚠️  RCG Draft 已存在（繼續執行）" -ForegroundColor Yellow
}

# =============================================
# 步驟 4：確認 Rule Collection（沿用既有或建立新的）
# =============================================
Write-Host "📂 步驟 4/6：檢查 Rule Collection..." -ForegroundColor Cyan
$RcExists = $false

# 先檢查 Draft 中是否已有 Rule Collection
try {
    Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "show", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--output", "none") | Out-Null
    $RcExists = $true
    Write-Host "   ✅ Rule Collection 已存在於 Draft 中：$RcName（沿用）" -ForegroundColor Green
}
catch {
    # Draft 中不存在
}

# 若 Draft 中不存在，檢查正式環境
if (-not $RcExists) {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "collection", "show", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--output", "none") | Out-Null
        $RcExists = $true
        Write-Host "   ✅ Rule Collection 已存在於正式環境：$RcName（Draft 會自動沿用）" -ForegroundColor Green
    }
    catch {
        # 正式環境也不存在
    }
}

# 都不存在才建立
if (-not $RcExists) {
    Write-Host "   ⏳ 建立 Rule Collection：$RcName ..." -ForegroundColor Yellow
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "add-filter-collection", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--name", $RcName, "--rule-type", "ApplicationRule", "--action", "Allow", "--enable-tls-insp", "true", "--collection-priority", "1200", "--output", "none") | Out-Null
        Write-Host "   ✅ Rule Collection 建立成功：$RcName" -ForegroundColor Green
    }
    catch {
        Write-Host "   ❌ Rule Collection 建立失敗：$($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

# =============================================
# 步驟 5：新增/更新規則至 Draft（共 285 條）
# =============================================
Write-Host "🔧 步驟 5/6：同步 285 條規則至 Draft（冪等模式）..." -ForegroundColor Cyan
Write-Host ""

Write-Host -NoNewline "   [1/285] mirror-to-winget-infra-https ... "
$expectedTargets = @("cdn.winget.microsoft.com", "winget.azureedge.net")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-winget-infra-https" -ExpectedTargets $expectedTargets -TargetType "targetFqdns"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-winget-infra-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-winget-infra-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-fqdns", "cdn.winget.microsoft.com", "winget.azureedge.net", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-winget-infra-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-fqdns", "cdn.winget.microsoft.com", "winget.azureedge.net", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [2/285] mirror-to-gh-copilot-https ... "
$expectedTargets = @("github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip", "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-gh-copilot-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-gh-copilot-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-copilot-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip", "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-copilot-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip", "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [3/285] mirror-to-gh-githubdesktop-https ... "
$expectedTargets = @("desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-gh-githubdesktop-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-gh-githubdesktop-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-githubdesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-githubdesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe", "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [4/285] mirror-to-gh-gitlfs-https ... "
$expectedTargets = @("github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-gh-gitlfs-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-gh-gitlfs-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-gitlfs-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-gitlfs-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [5/285] mirror-to-gh-cli-https ... "
$expectedTargets = @("github.com/cli/cli/releases/download/*/gh_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-gh-cli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-gh-cli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-cli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/cli/cli/releases/download/*/gh_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-cli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/cli/cli/releases/download/*/gh_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [6/285] mirror-to-gh-git-sizer-https ... "
$expectedTargets = @("github.com/github/git-sizer/releases/download/*/git-sizer-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-gh-git-sizer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-gh-git-sizer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-git-sizer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/github/git-sizer/releases/download/*/git-sizer-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-gh-git-sizer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/github/git-sizer/releases/download/*/git-sizer-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [7/285] mirror-to-ms-aksdesktop-https ... "
$expectedTargets = @("github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-aksdesktop-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-aksdesktop-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-aksdesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-aksdesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [8/285] mirror-to-ms-apm-https ... "
$expectedTargets = @("github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-apm-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-apm-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-apm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-apm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [9/285] mirror-to-ms-asrtesttool-https ... "
$expectedTargets = @("demo.wd.microsoft.com/Content/ASRtool.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-asrtesttool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-asrtesttool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-asrtesttool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "demo.wd.microsoft.com/Content/ASRtool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-asrtesttool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "demo.wd.microsoft.com/Content/ASRtool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [10/285] mirror-to-ms-accessdatabaseengine2016-https ... "
$expectedTargets = @("download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe", "download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-accessdatabaseengine2016-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-accessdatabaseengine2016-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-accessdatabaseengine2016-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe", "download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-accessdatabaseengine2016-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe", "download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [11/285] mirror-to-ms-accountlockoutstatus-https ... "
$expectedTargets = @("download.microsoft.com/download/c/0/4/*/lockoutstatus.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-accountlockoutstatus-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-accountlockoutstatus-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-accountlockoutstatus-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-accountlockoutstatus-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [12/285] mirror-to-ms-administrativetemplates-https ... "
$expectedTargets = @("download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-administrativetemplates-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-administrativetemplates-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-administrativetemplates-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-administrativetemplates-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [13/285] mirror-to-ms-advertisingeditor-https ... "
$expectedTargets = @("prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-advertisingeditor-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-advertisingeditor-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-advertisingeditor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-advertisingeditor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [14/285] mirror-to-ms-appcontrolpolicywizard-https ... "
$expectedTargets = @("webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-appcontrolpolicywizard-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-appcontrolpolicywizard-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appcontrolpolicywizard-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appcontrolpolicywizard-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [15/285] mirror-to-ms-appinstaller-https ... "
$expectedTargets = @("github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-appinstaller-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-appinstaller-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appinstaller-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appinstaller-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [16/285] mirror-to-ms-appinstallerfilebuilder-https ... "
$expectedTargets = @("github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-appinstallerfilebuilder-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-appinstallerfilebuilder-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appinstallerfilebuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-appinstallerfilebuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [17/285] mirror-to-ms-applockerpolicyconverter-https ... "
$expectedTargets = @("github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-applockerpolicyconverter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-applockerpolicyconverter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-applockerpolicyconverter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-applockerpolicyconverter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [18/285] mirror-to-ms-applicationinspector-https ... "
$expectedTargets = @("github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-applicationinspector-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-applicationinspector-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-applicationinspector-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-applicationinspector-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [19/285] mirror-to-ms-aspire-https ... "
$expectedTargets = @("ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*", "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-aspire-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-aspire-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-aspire-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*", "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-aspire-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*", "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [20/285] mirror-to-ms-azd-https ... "
$expectedTargets = @("github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azd-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azd-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [21/285] mirror-to-ms-azure-adconnectsyncdocumenter-https ... "
$expectedTargets = @("github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-adconnectsyncdocumenter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-adconnectsyncdocumenter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-adconnectsyncdocumenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-adconnectsyncdocumenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [22/285] mirror-to-ms-azure-azcopy-10-https ... "
$expectedTargets = @("github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-azcopy-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-azcopy-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-azcopy-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-azcopy-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*", "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [23/285] mirror-to-ms-azure-artifactsigningclienttools-https ... "
$expectedTargets = @("download.microsoft.com/download/*/ArtifactSigningClientTools.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-artifactsigningclienttools-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-artifactsigningclienttools-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-artifactsigningclienttools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/ArtifactSigningClientTools.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-artifactsigningclienttools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/ArtifactSigningClientTools.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [24/285] mirror-to-ms-azure-auth-https ... "
$expectedTargets = @("github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-auth-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-auth-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-auth-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-auth-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [25/285] mirror-to-ms-azure-az-https ... "
$expectedTargets = @("github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-az-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-az-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-az-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-az-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [26/285] mirror-to-ms-azure-aztfexport-https ... "
$expectedTargets = @("github.com/Azure/aztfexport/releases/download/*/aztfexport_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-aztfexport-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-aztfexport-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-aztfexport-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/aztfexport/releases/download/*/aztfexport_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-aztfexport-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/aztfexport/releases/download/*/aztfexport_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [27/285] mirror-to-ms-azure-batchexplorer-https ... "
$expectedTargets = @("github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-batchexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-batchexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-batchexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-batchexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [28/285] mirror-to-ms-azure-cloudhsm-clientsdk-https ... "
$expectedTargets = @("github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-cloudhsm-clientsdk-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-cloudhsm-clientsdk-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-cloudhsm-clientsdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-cloudhsm-clientsdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [29/285] mirror-to-ms-azure-connectedmachineagent-https ... "
$expectedTargets = @("gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-connectedmachineagent-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-connectedmachineagent-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-connectedmachineagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-connectedmachineagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [30/285] mirror-to-ms-azure-cosmosemulator-https ... "
$expectedTargets = @("cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-cosmosemulator-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-cosmosemulator-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-cosmosemulator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-cosmosemulator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [31/285] mirror-to-ms-azure-datacli-https ... "
$expectedTargets = @("download.microsoft.com/download/f/f/f/*/azdata-cli-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-datacli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-datacli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-datacli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/f/f/f/*/azdata-cli-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-datacli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/f/f/f/*/azdata-cli-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [32/285] mirror-to-ms-azure-datastudio-https ... "
$expectedTargets = @("download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-datastudio-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-datastudio-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-datastudio-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-datastudio-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-setup-*", "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [33/285] mirror-to-ms-azure-functionscoretools-https ... "
$expectedTargets = @("github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*", "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*", "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-functionscoretools-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-functionscoretools-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-functionscoretools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*", "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*", "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-functionscoretools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*", "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*", "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [34/285] mirror-to-ms-azure-guestproxyagent-https ... "
$expectedTargets = @("github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*", "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-guestproxyagent-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-guestproxyagent-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-guestproxyagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*", "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-guestproxyagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*", "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [35/285] mirror-to-ms-azure-iotexplorer-https ... "
$expectedTargets = @("github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-iotexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-iotexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-iotexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-iotexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [36/285] mirror-to-ms-azure-kubelogin-https ... "
$expectedTargets = @("packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-kubelogin-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-kubelogin-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-kubelogin-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-kubelogin-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [37/285] mirror-to-ms-azure-quickreview-https ... "
$expectedTargets = @("github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-quickreview-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-quickreview-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-quickreview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-quickreview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [38/285] mirror-to-ms-azure-storageexplorer-https ... "
$expectedTargets = @("github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe", "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-storageexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-storageexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-storageexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe", "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-storageexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe", "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [39/285] mirror-to-ms-azure-templateanalyzer-https ... "
$expectedTargets = @("github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip", "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-templateanalyzer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-templateanalyzer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-templateanalyzer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip", "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-templateanalyzer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip", "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [40/285] mirror-to-ms-azure-trustedsigningclienttools-https ... "
$expectedTargets = @("download.microsoft.com/download/*/TrustedSigningClientTools.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azure-trustedsigningclienttools-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azure-trustedsigningclienttools-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-trustedsigningclienttools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/TrustedSigningClientTools.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azure-trustedsigningclienttools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/TrustedSigningClientTools.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [41/285] mirror-to-ms-azurecli-https ... "
$expectedTargets = @("azcliprod.blob.core.windows.net/msi/azure-cli-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azurecli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azurecli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azurecli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "azcliprod.blob.core.windows.net/msi/azure-cli-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azurecli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "azcliprod.blob.core.windows.net/msi/azure-cli-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [42/285] mirror-to-ms-azuremonitoragent-https ... "
$expectedTargets = @("download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azuremonitoragent-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azuremonitoragent-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azuremonitoragent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azuremonitoragent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [43/285] mirror-to-ms-azurevpnclient-https ... "
$expectedTargets = @("download.microsoft.com/download/*/AzVpnAppx_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-azurevpnclient-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-azurevpnclient-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azurevpnclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/AzVpnAppx_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-azurevpnclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/AzVpnAppx_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [44/285] mirror-to-ms-btp-https ... "
$expectedTargets = @("download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-btp-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-btp-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-btp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-btp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [45/285] mirror-to-ms-bicep-https ... "
$expectedTargets = @("github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-bicep-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-bicep-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-bicep-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-bicep-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe", "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [46/285] mirror-to-ms-clrtypessqlserver-2019-https ... "
$expectedTargets = @("download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-clrtypessqlserver-2019-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-clrtypessqlserver-2019-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-clrtypessqlserver-2019-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-clrtypessqlserver-2019-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [47/285] mirror-to-ms-certifiedtoolazurevm-https ... "
$expectedTargets = @("download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-certifiedtoolazurevm-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-certifiedtoolazurevm-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-certifiedtoolazurevm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-certifiedtoolazurevm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [48/285] mirror-to-ms-cmdpalazureextension-https ... "
$expectedTargets = @("github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-cmdpalazureextension-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-cmdpalazureextension-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-cmdpalazureextension-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-cmdpalazureextension-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [49/285] mirror-to-ms-cmdpalgithubextension-https ... "
$expectedTargets = @("github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-cmdpalgithubextension-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-cmdpalgithubextension-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-cmdpalgithubextension-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-cmdpalgithubextension-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [50/285] mirror-to-ms-dsc-https ... "
$expectedTargets = @("github.com/PowerShell/DSC/releases/download/*/DSC-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dsc-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dsc-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dsc-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/PowerShell/DSC/releases/download/*/DSC-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dsc-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/PowerShell/DSC/releases/download/*/DSC-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [51/285] mirror-to-ms-dtrace-https ... "
$expectedTargets = @("download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi", "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dtrace-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dtrace-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dtrace-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi", "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dtrace-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi", "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [52/285] mirror-to-ms-datamigrationassistant-https ... "
$expectedTargets = @("download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-datamigrationassistant-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-datamigrationassistant-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-datamigrationassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-datamigrationassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [53/285] mirror-to-ms-datatools-integrationservices-https ... "
$expectedTargets = @("ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-datatools-integrationservices-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-datatools-integrationservices-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-datatools-integrationservices-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-datatools-integrationservices-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [54/285] mirror-to-ms-debugdiag-https ... "
$expectedTargets = @("download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-debugdiag-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-debugdiag-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-debugdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-debugdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [55/285] mirror-to-ms-defenderforcloud-cli-https ... "
$expectedTargets = @("cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-defenderforcloud-cli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-defenderforcloud-cli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-defenderforcloud-cli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-defenderforcloud-cli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe", "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [56/285] mirror-to-ms-dependencyagent-https ... "
$expectedTargets = @("da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dependencyagent-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dependencyagent-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dependencyagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dependencyagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [57/285] mirror-to-ms-deploymenttoolkit-https ... "
$expectedTargets = @("download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi", "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-deploymenttoolkit-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-deploymenttoolkit-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-deploymenttoolkit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi", "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-deploymenttoolkit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi", "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [58/285] mirror-to-ms-devskim-cli-dotnettool-https ... "
$expectedTargets = @("github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-devskim-cli-dotnettool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-devskim-cli-dotnettool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-devskim-cli-dotnettool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-devskim-cli-dotnettool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [59/285] mirror-to-ms-devskim-cli-librarypackage-https ... "
$expectedTargets = @("github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-devskim-cli-librarypackage-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-devskim-cli-librarypackage-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-devskim-cli-librarypackage-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-devskim-cli-librarypackage-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [60/285] mirror-to-ms-directx-https ... "
$expectedTargets = @("download.microsoft.com/download/1/7/1/*/dxwebsetup.exe", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-directx-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-directx-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directx-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directx-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx", "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [61/285] mirror-to-ms-directxtex-texassemble-https ... "
$expectedTargets = @("github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-directxtex-texassemble-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-directxtex-texassemble-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texassemble-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texassemble-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [62/285] mirror-to-ms-directxtex-texconv-https ... "
$expectedTargets = @("github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-directxtex-texconv-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-directxtex-texconv-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texconv-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texconv-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [63/285] mirror-to-ms-directxtex-texdiag-https ... "
$expectedTargets = @("github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-directxtex-texdiag-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-directxtex-texdiag-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-directxtex-texdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe", "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [64/285] mirror-to-ms-diskspd-https ... "
$expectedTargets = @("github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP", "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-diskspd-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-diskspd-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-diskspd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP", "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-diskspd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP", "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [65/285] mirror-to-ms-dotnet-aspnetcore-10-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-aspnetcore-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-aspnetcore-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [66/285] mirror-to-ms-dotnet-aspnetcore-8-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-aspnetcore-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-aspnetcore-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [67/285] mirror-to-ms-dotnet-aspnetcore-9-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-aspnetcore-9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-aspnetcore-9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-aspnetcore-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [68/285] mirror-to-ms-dotnet-desktopruntime-10-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-desktopruntime-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-desktopruntime-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [69/285] mirror-to-ms-dotnet-desktopruntime-8-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-desktopruntime-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-desktopruntime-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [70/285] mirror-to-ms-dotnet-desktopruntime-9-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-desktopruntime-9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-desktopruntime-9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-desktopruntime-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [71/285] mirror-to-ms-dotnet-framework-developerpack_4-https ... "
$expectedTargets = @("download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-framework-developerpack_4-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-framework-developerpack_4-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-framework-developerpack_4-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-framework-developerpack_4-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [72/285] mirror-to-ms-dotnet-framework-runtime-https ... "
$expectedTargets = @("download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-framework-runtime-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-framework-runtime-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-framework-runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-framework-runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [73/285] mirror-to-ms-dotnet-hostingbundle-10-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-hostingbundle-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-hostingbundle-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [74/285] mirror-to-ms-dotnet-hostingbundle-8-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-hostingbundle-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-hostingbundle-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [75/285] mirror-to-ms-dotnet-hostingbundle-9-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-hostingbundle-9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-hostingbundle-9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-hostingbundle-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [76/285] mirror-to-ms-dotnet-native-runtime-https ... "
$expectedTargets = @("github.com/microsoft/busiotools/releases/download/*/Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-native-runtime-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-native-runtime-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-native-runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/busiotools/releases/download/*/Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-native-runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/busiotools/releases/download/*/Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [77/285] mirror-to-ms-dotnet-repairtool-https ... "
$expectedTargets = @("download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-repairtool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-repairtool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-repairtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-repairtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [78/285] mirror-to-ms-dotnet-runtime-10-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-runtime-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-runtime-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [79/285] mirror-to-ms-dotnet-runtime-8-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-runtime-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-runtime-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [80/285] mirror-to-ms-dotnet-runtime-9-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-runtime-9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-runtime-9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-runtime-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [81/285] mirror-to-ms-dotnet-sdk-10-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-sdk-10-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-sdk-10-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-10-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [82/285] mirror-to-ms-dotnet-sdk-8-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-sdk-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-sdk-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [83/285] mirror-to-ms-dotnet-sdk-9-https ... "
$expectedTargets = @("builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-sdk-9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-sdk-9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-sdk-9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [84/285] mirror-to-ms-dotnet-uninstalltool-https ... "
$expectedTargets = @("github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-uninstalltool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-uninstalltool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-uninstalltool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-uninstalltool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [85/285] mirror-to-ms-dotnet-dotnet-ef-https ... "
$expectedTargets = @("globalcdn.nuget.org/packages/dotnet-ef.*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-dotnet-dotnet-ef-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-dotnet-dotnet-ef-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-dotnet-ef-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "globalcdn.nuget.org/packages/dotnet-ef.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-dotnet-dotnet-ef-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "globalcdn.nuget.org/packages/dotnet-ef.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [86/285] mirror-to-ms-edge-https ... "
$expectedTargets = @("msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-edge-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-edge-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edge-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edge-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [87/285] mirror-to-ms-edgedriver-https ... "
$expectedTargets = @("msedgedriver.microsoft.com/*/edgedriver_arm64.zip", "msedgedriver.microsoft.com/*/edgedriver_win32.zip", "msedgedriver.microsoft.com/*/edgedriver_win64.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-edgedriver-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-edgedriver-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edgedriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedgedriver.microsoft.com/*/edgedriver_arm64.zip", "msedgedriver.microsoft.com/*/edgedriver_win32.zip", "msedgedriver.microsoft.com/*/edgedriver_win64.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edgedriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedgedriver.microsoft.com/*/edgedriver_arm64.zip", "msedgedriver.microsoft.com/*/edgedriver_win32.zip", "msedgedriver.microsoft.com/*/edgedriver_win64.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [88/285] mirror-to-ms-edgewebview2runtime-https ... "
$expectedTargets = @("msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-edgewebview2runtime-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-edgewebview2runtime-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edgewebview2runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edgewebview2runtime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe", "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [89/285] mirror-to-ms-edit-https ... "
$expectedTargets = @("github.com/microsoft/edit/releases/download/*/edit-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-edit-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-edit-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/edit/releases/download/*/edit-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-edit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/edit/releases/download/*/edit-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [90/285] mirror-to-ms-enterprisestateclassify-https ... "
$expectedTargets = @("github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-enterprisestateclassify-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-enterprisestateclassify-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-enterprisestateclassify-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-enterprisestateclassify-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [91/285] mirror-to-ms-eventlogexpert-https ... "
$expectedTargets = @("github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-eventlogexpert-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-eventlogexpert-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-eventlogexpert-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-eventlogexpert-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [92/285] mirror-to-ms-fslogix-https ... "
$expectedTargets = @("download.microsoft.com/download/*/FSLogix_26.01_CU1.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-fslogix-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-fslogix-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-fslogix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-fslogix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [93/285] mirror-to-ms-foundrylocal-https ... "
$expectedTargets = @("foundry.onnxruntime.ai/FoundryLocal-arm64-*", "foundry.onnxruntime.ai/FoundryLocal-x64-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-foundrylocal-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-foundrylocal-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-foundrylocal-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "foundry.onnxruntime.ai/FoundryLocal-arm64-*", "foundry.onnxruntime.ai/FoundryLocal-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-foundrylocal-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "foundry.onnxruntime.ai/FoundryLocal-arm64-*", "foundry.onnxruntime.ai/FoundryLocal-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [94/285] mirror-to-ms-fuzzylookupaddexcel-https ... "
$expectedTargets = @("download.microsoft.com/download/1/9/8/*/Setup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-fuzzylookupaddexcel-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-fuzzylookupaddexcel-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-fuzzylookupaddexcel-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/9/8/*/Setup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-fuzzylookupaddexcel-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/9/8/*/Setup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [95/285] mirror-to-ms-garnet-dn8-https ... "
$expectedTargets = @("github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-garnet-dn8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-garnet-dn8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-garnet-dn8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-garnet-dn8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [96/285] mirror-to-ms-garnet-dn9-https ... "
$expectedTargets = @("github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-garnet-dn9-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-garnet-dn9-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-garnet-dn9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-garnet-dn9-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip", "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [97/285] mirror-to-ms-git-https ... "
$expectedTargets = @("github.com/microsoft/git/releases/download/*/Git-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-git-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-git-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-git-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/git/releases/download/*/Git-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-git-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/git/releases/download/*/Git-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [98/285] mirror-to-ms-globalsecureaccessclient-https ... "
$expectedTargets = @("download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-globalsecureaccessclient-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-globalsecureaccessclient-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-globalsecureaccessclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-globalsecureaccessclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [99/285] mirror-to-ms-hidtools-waratah-https ... "
$expectedTargets = @("github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-hidtools-waratah-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-hidtools-waratah-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-hidtools-waratah-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-hidtools-waratah-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [100/285] mirror-to-ms-hwpconverter-https ... "
$expectedTargets = @("download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe", "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-hwpconverter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-hwpconverter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-hwpconverter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe", "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-hwpconverter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe", "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe", "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [101/285] mirror-to-ms-iis-applicationrequestrouting-https ... "
$expectedTargets = @("download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi", "download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi", "go.microsoft.com/fwlink/")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-iis-applicationrequestrouting-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-iis-applicationrequestrouting-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-applicationrequestrouting-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi", "download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi", "go.microsoft.com/fwlink/", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-applicationrequestrouting-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi", "download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi", "go.microsoft.com/fwlink/", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [102/285] mirror-to-ms-iis-compression-https ... "
$expectedTargets = @("download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi", "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-iis-compression-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-iis-compression-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-compression-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi", "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-compression-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi", "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [103/285] mirror-to-ms-iis-servicemonitor-https ... "
$expectedTargets = @("github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-iis-servicemonitor-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-iis-servicemonitor-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-servicemonitor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-servicemonitor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [104/285] mirror-to-ms-iis-urlrewrite-https ... "
$expectedTargets = @("download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi", "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-iis-urlrewrite-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-iis-urlrewrite-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-urlrewrite-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi", "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iis-urlrewrite-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi", "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [105/285] mirror-to-ms-iismanagerremoteadministration-https ... "
$expectedTargets = @("download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi", "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-iismanagerremoteadministration-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-iismanagerremoteadministration-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iismanagerremoteadministration-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi", "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-iismanagerremoteadministration-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi", "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [106/285] mirror-to-ms-idfix-https ... "
$expectedTargets = @("github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*", "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-idfix-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-idfix-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-idfix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*", "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-idfix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*", "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [107/285] mirror-to-ms-integrationruntime-https ... "
$expectedTargets = @("download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-integrationruntime-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-integrationruntime-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-integrationruntime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-integrationruntime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [108/285] mirror-to-ms-intunewslplugin-https ... "
$expectedTargets = @("github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi", "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-intunewslplugin-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-intunewslplugin-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-intunewslplugin-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi", "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-intunewslplugin-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi", "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [109/285] mirror-to-ms-ironpython-3-https ... "
$expectedTargets = @("github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-ironpython-3-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-ironpython-3-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ironpython-3-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ironpython-3-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [110/285] mirror-to-ms-kanagawa-https ... "
$expectedTargets = @("github.com/microsoft/kanagawa/releases/download/*/kanagawa-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-kanagawa-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-kanagawa-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-kanagawa-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/kanagawa/releases/download/*/kanagawa-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-kanagawa-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/kanagawa/releases/download/*/kanagawa-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [111/285] mirror-to-ms-laps-https ... "
$expectedTargets = @("download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-laps-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-laps-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-laps-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-laps-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi", "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [112/285] mirror-to-ms-lightgbm-https ... "
$expectedTargets = @("github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-lightgbm-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-lightgbm-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-lightgbm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-lightgbm-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [113/285] mirror-to-ms-lingeringobjectliquidator-https ... "
$expectedTargets = @("download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-lingeringobjectliquidator-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-lingeringobjectliquidator-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-lingeringobjectliquidator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-lingeringobjectliquidator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [114/285] mirror-to-ms-logcheetah-https ... "
$expectedTargets = @("github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-logcheetah-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-logcheetah-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-logcheetah-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-logcheetah-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [115/285] mirror-to-ms-logparser-https ... "
$expectedTargets = @("download.microsoft.com/download/f/f/1/*/LogParser.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-logparser-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-logparser-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-logparser-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/f/f/1/*/LogParser.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-logparser-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/f/f/1/*/LogParser.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [116/285] mirror-to-ms-m365agentsplayground-https ... "
$expectedTargets = @("github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-m365agentsplayground-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-m365agentsplayground-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-m365agentsplayground-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-m365agentsplayground-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [117/285] mirror-to-ms-mfcmapi-https ... "
$expectedTargets = @("github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*", "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mfcmapi-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mfcmapi-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mfcmapi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*", "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mfcmapi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*", "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [118/285] mirror-to-ms-midi-featureenablementchecker-https ... "
$expectedTargets = @("github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip", "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-midi-featureenablementchecker-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-midi-featureenablementchecker-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-midi-featureenablementchecker-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip", "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-midi-featureenablementchecker-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip", "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [119/285] mirror-to-ms-midi-sdk-https ... "
$expectedTargets = @("github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-midi-sdk-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-midi-sdk-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-midi-sdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-midi-sdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [120/285] mirror-to-ms-mitt-https ... "
$expectedTargets = @("download.microsoft.com/download/7/7/0/*/MITT.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mitt-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mitt-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mitt-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/7/0/*/MITT.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mitt-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/7/0/*/MITT.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [121/285] mirror-to-ms-msix-toolkit-https ... "
$expectedTargets = @("github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-msix-toolkit-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-msix-toolkit-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msix-toolkit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msix-toolkit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip", "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [122/285] mirror-to-ms-msixcore-https ... "
$expectedTargets = @("github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip", "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-msixcore-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-msixcore-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msixcore-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip", "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msixcore-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip", "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [123/285] mirror-to-ms-msixpackagingtool-https ... "
$expectedTargets = @("download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-msixpackagingtool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-msixpackagingtool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msixpackagingtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msixpackagingtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [124/285] mirror-to-ms-mutt-https ... "
$expectedTargets = @("download.microsoft.com/download/*/MUTTPackage-3_0_0.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mutt-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mutt-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mutt-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mutt-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [125/285] mirror-to-ms-malicioussoftwareremovaltool-https ... "
$expectedTargets = @("download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe", "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-malicioussoftwareremovaltool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-malicioussoftwareremovaltool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-malicioussoftwareremovaltool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe", "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-malicioussoftwareremovaltool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe", "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [126/285] mirror-to-ms-mediacreationtool-https ... "
$expectedTargets = @("download.microsoft.com/download/*/MediaCreationTool.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mediacreationtool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mediacreationtool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mediacreationtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/MediaCreationTool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mediacreationtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/MediaCreationTool.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [127/285] mirror-to-ms-mousewithoutborders-https ... "
$expectedTargets = @("download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mousewithoutborders-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mousewithoutborders-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mousewithoutborders-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mousewithoutborders-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [128/285] mirror-to-ms-mouseandkeyboardcenter-https ... "
$expectedTargets = @("download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-mouseandkeyboardcenter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-mouseandkeyboardcenter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mouseandkeyboardcenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-mouseandkeyboardcenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe", "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [129/285] mirror-to-ms-ntttcp-https ... "
$expectedTargets = @("github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe", "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-ntttcp-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-ntttcp-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ntttcp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe", "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ntttcp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe", "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [130/285] mirror-to-ms-nuget-https ... "
$expectedTargets = @("dist.nuget.org/win-x86-commandline/*/nuget.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-nuget-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-nuget-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-nuget-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "dist.nuget.org/win-x86-commandline/*/nuget.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-nuget-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "dist.nuget.org/win-x86-commandline/*/nuget.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [131/285] mirror-to-ms-oscdimg-https ... "
$expectedTargets = @("msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe", "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-oscdimg-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-oscdimg-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-oscdimg-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe", "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-oscdimg-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe", "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [132/285] mirror-to-ms-osconfig-https ... "
$expectedTargets = @("github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*", "github.com/microsoft/osconfig/releases/download/*/oscfg-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-osconfig-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-osconfig-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-osconfig-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*", "github.com/microsoft/osconfig/releases/download/*/oscfg-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-osconfig-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*", "github.com/microsoft/osconfig/releases/download/*/oscfg-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [133/285] mirror-to-ms-office-https ... "
$expectedTargets = @("officecdn.microsoft.com/pr/wsus/setup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-office-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-office-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-office-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "officecdn.microsoft.com/pr/wsus/setup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-office-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "officecdn.microsoft.com/pr/wsus/setup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [134/285] mirror-to-ms-officedeploymenttool-https ... "
$expectedTargets = @("download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-officedeploymenttool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-officedeploymenttool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-officedeploymenttool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-officedeploymenttool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [135/285] mirror-to-ms-onedrive-https ... "
$expectedTargets = @("oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-onedrive-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-onedrive-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onedrive-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onedrive-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe", "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [136/285] mirror-to-ms-onelakefileexplorer-https ... "
$expectedTargets = @("download.microsoft.com/download/*/OneLake_PuPr_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-onelakefileexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-onelakefileexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onelakefileexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/OneLake_PuPr_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onelakefileexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/OneLake_PuPr_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [137/285] mirror-to-ms-onenotediagnostics-https ... "
$expectedTargets = @("download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-onenotediagnostics-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-onenotediagnostics-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onenotediagnostics-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-onenotediagnostics-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [138/285] mirror-to-ms-openapi-hidi-https ... "
$expectedTargets = @("github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openapi-hidi-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openapi-hidi-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openapi-hidi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openapi-hidi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [139/285] mirror-to-ms-openapi-kiota-https ... "
$expectedTargets = @("github.com/microsoft/kiota/releases/download/*/win-arm64.zip", "github.com/microsoft/kiota/releases/download/*/win-x64.zip", "github.com/microsoft/kiota/releases/download/*/win-x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openapi-kiota-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openapi-kiota-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openapi-kiota-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/kiota/releases/download/*/win-arm64.zip", "github.com/microsoft/kiota/releases/download/*/win-x64.zip", "github.com/microsoft/kiota/releases/download/*/win-x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openapi-kiota-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/kiota/releases/download/*/win-arm64.zip", "github.com/microsoft/kiota/releases/download/*/win-x64.zip", "github.com/microsoft/kiota/releases/download/*/win-x86.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [140/285] mirror-to-ms-openclglvulkancompatibilitypack-https ... "
$expectedTargets = @("github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openclglvulkancompatibilitypack-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openclglvulkancompatibilitypack-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openclglvulkancompatibilitypack-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openclglvulkancompatibilitypack-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [141/285] mirror-to-ms-openjdk-11-https ... "
$expectedTargets = @("aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openjdk-11-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openjdk-11-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-11-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-11-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [142/285] mirror-to-ms-openjdk-17-https ... "
$expectedTargets = @("aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openjdk-17-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openjdk-17-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-17-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-17-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [143/285] mirror-to-ms-openjdk-21-https ... "
$expectedTargets = @("aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openjdk-21-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openjdk-21-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-21-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-21-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [144/285] mirror-to-ms-openjdk-25-https ... "
$expectedTargets = @("aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-openjdk-25-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-openjdk-25-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-25-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-openjdk-25-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/download-JDK/microsoft-JDK-*", "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [145/285] mirror-to-ms-pict-https ... "
$expectedTargets = @("github.com/microsoft/pict/releases/download/*/pict.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-pict-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-pict-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pict-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/pict/releases/download/*/pict.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pict-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/pict/releases/download/*/pict.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [146/285] mirror-to-ms-pix-https ... "
$expectedTargets = @("download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe", "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-pix-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-pix-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe", "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pix-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe", "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [147/285] mirror-to-ms-pave-https ... "
$expectedTargets = @("github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip", "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-pave-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-pave-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pave-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip", "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-pave-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip", "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [148/285] mirror-to-ms-perfview-https ... "
$expectedTargets = @("github.com/microsoft/perfview/releases/download/*/PerfView.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-perfview-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-perfview-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-perfview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/perfview/releases/download/*/PerfView.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-perfview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/perfview/releases/download/*/PerfView.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [149/285] mirror-to-ms-powerappscli-https ... "
$expectedTargets = @("download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerappscli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerappscli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerappscli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerappscli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [150/285] mirror-to-ms-powerautomatedesktop-https ... "
$expectedTargets = @("download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerautomatedesktop-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerautomatedesktop-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerautomatedesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerautomatedesktop-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [151/285] mirror-to-ms-powerautomateprocessmining-https ... "
$expectedTargets = @("download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerautomateprocessmining-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerautomateprocessmining-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerautomateprocessmining-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerautomateprocessmining-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [152/285] mirror-to-ms-powerbi-https ... "
$expectedTargets = @("download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerbi-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerbi-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [153/285] mirror-to-ms-powerbireportbuilder-https ... "
$expectedTargets = @("download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerbireportbuilder-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerbireportbuilder-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbireportbuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbireportbuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [154/285] mirror-to-ms-powerbireportserver-https ... "
$expectedTargets = @("download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powerbireportserver-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powerbireportserver-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbireportserver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powerbireportserver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [155/285] mirror-to-ms-powershell-https ... "
$expectedTargets = @("github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powershell-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powershell-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powershell-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powershell-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [156/285] mirror-to-ms-powertoys-https ... "
$expectedTargets = @("github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*", "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-powertoys-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-powertoys-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powertoys-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*", "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-powertoys-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*", "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [157/285] mirror-to-ms-printmetadatatroubleshooter-https ... "
$expectedTargets = @("download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-printmetadatatroubleshooter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-printmetadatatroubleshooter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-printmetadatatroubleshooter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-printmetadatatroubleshooter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe", "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [158/285] mirror-to-ms-profileexplorer-https ... "
$expectedTargets = @("github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-profileexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-profileexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-profileexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-profileexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [159/285] mirror-to-ms-projecttelescope-https ... "
$expectedTargets = @("github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi", "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-projecttelescope-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-projecttelescope-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-projecttelescope-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi", "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-projecttelescope-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi", "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [160/285] mirror-to-ms-promptflow-https ... "
$expectedTargets = @("promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-promptflow-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-promptflow-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-promptflow-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-promptflow-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [161/285] mirror-to-ms-purviewinformationprotection-https ... "
$expectedTargets = @("download.microsoft.com/download/*/PurviewInfoProtection.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-purviewinformationprotection-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-purviewinformationprotection-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-purviewinformationprotection-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PurviewInfoProtection.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-purviewinformationprotection-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/PurviewInfoProtection.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [162/285] mirror-to-ms-rmsclient-https ... "
$expectedTargets = @("download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe", "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-rmsclient-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-rmsclient-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-rmsclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe", "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-rmsclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe", "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [163/285] mirror-to-ms-remotedesktopclient-https ... "
$expectedTargets = @("res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-remotedesktopclient-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-remotedesktopclient-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotedesktopclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotedesktopclient-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [164/285] mirror-to-ms-remotedesktopmmrservice-https ... "
$expectedTargets = @("intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-remotedesktopmmrservice-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-remotedesktopmmrservice-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotedesktopmmrservice-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotedesktopmmrservice-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [165/285] mirror-to-ms-remotehelp-https ... "
$expectedTargets = @("catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-remotehelp-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-remotehelp-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotehelp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-remotehelp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [166/285] mirror-to-ms-reportbuilder-https ... "
$expectedTargets = @("download.microsoft.com/download/5/E/B/*/ReportBuilder.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-reportbuilder-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-reportbuilder-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-reportbuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-reportbuilder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [167/285] mirror-to-ms-sbomtool-https ... "
$expectedTargets = @("github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sbomtool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sbomtool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sbomtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sbomtool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [168/285] mirror-to-ms-sqlserver-2019-developer-https ... "
$expectedTargets = @("download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2019-developer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2019-developer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2019-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2019-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [169/285] mirror-to-ms-sqlserver-2019-express-https ... "
$expectedTargets = @("download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2019-express-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2019-express-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2019-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2019-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [170/285] mirror-to-ms-sqlserver-2022-developer-https ... "
$expectedTargets = @("download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2022-developer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2022-developer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2022-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2022-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [171/285] mirror-to-ms-sqlserver-2022-express-https ... "
$expectedTargets = @("download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2022-express-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2022-express-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2022-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2022-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [172/285] mirror-to-ms-sqlserver-2025-developer-https ... "
$expectedTargets = @("download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2025-developer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2025-developer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2025-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2025-developer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [173/285] mirror-to-ms-sqlserver-2025-express-https ... "
$expectedTargets = @("download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-2025-express-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-2025-express-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2025-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-2025-express-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [174/285] mirror-to-ms-sqlserver-oledbdriver-https ... "
$expectedTargets = @("download.microsoft.com/download/*/amd64/1028/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi", "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi", "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-oledbdriver-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-oledbdriver-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-oledbdriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi", "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi", "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-oledbdriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi", "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi", "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi", "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [175/285] mirror-to-ms-sqlserver-rmlutilities-https ... "
$expectedTargets = @("download.microsoft.com/download/6/5/8/*/RMLSetup.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlserver-rmlutilities-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlserver-rmlutilities-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-rmlutilities-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/5/8/*/RMLSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlserver-rmlutilities-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/6/5/8/*/RMLSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [176/285] mirror-to-ms-sqlservermanagementstudio-https ... "
$expectedTargets = @("download.microsoft.com/download/*/SSMS-Setup-CHS.exe", "download.microsoft.com/download/*/SSMS-Setup-CHT.exe", "download.microsoft.com/download/*/SSMS-Setup-DEU.exe", "download.microsoft.com/download/*/SSMS-Setup-ENU.exe", "download.microsoft.com/download/*/SSMS-Setup-ESN.exe", "download.microsoft.com/download/*/SSMS-Setup-FRA.exe", "download.microsoft.com/download/*/SSMS-Setup-ITA.exe", "download.microsoft.com/download/*/SSMS-Setup-JPN.exe", "download.microsoft.com/download/*/SSMS-Setup-KOR.exe", "download.microsoft.com/download/*/SSMS-Setup-PTB.exe", "download.microsoft.com/download/*/SSMS-Setup-RUS.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlservermanagementstudio-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlservermanagementstudio-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlservermanagementstudio-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SSMS-Setup-CHS.exe", "download.microsoft.com/download/*/SSMS-Setup-CHT.exe", "download.microsoft.com/download/*/SSMS-Setup-DEU.exe", "download.microsoft.com/download/*/SSMS-Setup-ENU.exe", "download.microsoft.com/download/*/SSMS-Setup-ESN.exe", "download.microsoft.com/download/*/SSMS-Setup-FRA.exe", "download.microsoft.com/download/*/SSMS-Setup-ITA.exe", "download.microsoft.com/download/*/SSMS-Setup-JPN.exe", "download.microsoft.com/download/*/SSMS-Setup-KOR.exe", "download.microsoft.com/download/*/SSMS-Setup-PTB.exe", "download.microsoft.com/download/*/SSMS-Setup-RUS.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlservermanagementstudio-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SSMS-Setup-CHS.exe", "download.microsoft.com/download/*/SSMS-Setup-CHT.exe", "download.microsoft.com/download/*/SSMS-Setup-DEU.exe", "download.microsoft.com/download/*/SSMS-Setup-ENU.exe", "download.microsoft.com/download/*/SSMS-Setup-ESN.exe", "download.microsoft.com/download/*/SSMS-Setup-FRA.exe", "download.microsoft.com/download/*/SSMS-Setup-ITA.exe", "download.microsoft.com/download/*/SSMS-Setup-JPN.exe", "download.microsoft.com/download/*/SSMS-Setup-KOR.exe", "download.microsoft.com/download/*/SSMS-Setup-PTB.exe", "download.microsoft.com/download/*/SSMS-Setup-RUS.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [177/285] mirror-to-ms-saracmd-https ... "
$expectedTargets = @("download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-saracmd-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-saracmd-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-saracmd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-saracmd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [178/285] mirror-to-ms-safetyscanner-https ... "
$expectedTargets = @("definitionupdates.microsoft.com/packages/content/msert.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-safetyscanner-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-safetyscanner-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-safetyscanner-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "definitionupdates.microsoft.com/packages/content/msert.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-safetyscanner-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "definitionupdates.microsoft.com/packages/content/msert.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [179/285] mirror-to-ms-screenrecorder-https ... "
$expectedTargets = @("github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-screenrecorder-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-screenrecorder-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-screenrecorder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-screenrecorder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [180/285] mirror-to-ms-securitycompliancetoolkit-lgpo-https ... "
$expectedTargets = @("download.microsoft.com/download/8/5/c/*/LGPO.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-securitycompliancetoolkit-lgpo-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-securitycompliancetoolkit-lgpo-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-lgpo-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/LGPO.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-lgpo-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/LGPO.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [181/285] mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https ... "
$expectedTargets = @("download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [182/285] mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https ... "
$expectedTargets = @("download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [183/285] mirror-to-ms-servicefabricruntime-https ... "
$expectedTargets = @("download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-servicefabricruntime-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-servicefabricruntime-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-servicefabricruntime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-servicefabricruntime-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [184/285] mirror-to-ms-servicefabricsdk-https ... "
$expectedTargets = @("download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-servicefabricsdk-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-servicefabricsdk-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-servicefabricsdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-servicefabricsdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [185/285] mirror-to-ms-setupdiag-https ... "
$expectedTargets = @("download.microsoft.com/download/1/1/1/*/SetupDiag.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-setupdiag-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-setupdiag-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-setupdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/1/1/*/SetupDiag.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-setupdiag-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/1/1/1/*/SetupDiag.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [186/285] mirror-to-ms-smartdump-https ... "
$expectedTargets = @("github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-smartdump-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-smartdump-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-smartdump-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-smartdump-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [187/285] mirror-to-ms-sqlpackage-https ... "
$expectedTargets = @("download.microsoft.com/download/*/sqlpackage-win-x64-en-*", "go.microsoft.com/fwlink/")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlpackage-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlpackage-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlpackage-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/sqlpackage-win-x64-en-*", "go.microsoft.com/fwlink/", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlpackage-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/sqlpackage-win-x64-en-*", "go.microsoft.com/fwlink/", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [188/285] mirror-to-ms-sqlcmd-https ... "
$expectedTargets = @("github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sqlcmd-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sqlcmd-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlcmd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sqlcmd-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi", "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [189/285] mirror-to-ms-surfaceapp-https ... "
$expectedTargets = @("download.microsoft.com/download/*/Microsoft.SurfaceHub_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-surfaceapp-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-surfaceapp-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-surfaceapp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Microsoft.SurfaceHub_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-surfaceapp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Microsoft.SurfaceHub_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [190/285] mirror-to-ms-surfacehubrecoverytool-https ... "
$expectedTargets = @("download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-surfacehubrecoverytool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-surfacehubrecoverytool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-surfacehubrecoverytool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-surfacehubrecoverytool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [191/285] mirror-to-ms-symcryptunittest-https ... "
$expectedTargets = @("github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*", "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-symcryptunittest-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-symcryptunittest-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-symcryptunittest-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*", "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-symcryptunittest-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*", "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*", "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [192/285] mirror-to-ms-sysinternals-autologon-https ... "
$expectedTargets = @("download.sysinternals.com/files/AutoLogon.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-autologon-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-autologon-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-autologon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/AutoLogon.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-autologon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/AutoLogon.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [193/285] mirror-to-ms-sysinternals-autoruns-https ... "
$expectedTargets = @("download.sysinternals.com/files/Autoruns.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-autoruns-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-autoruns-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-autoruns-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Autoruns.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-autoruns-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Autoruns.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [194/285] mirror-to-ms-sysinternals-bginfo-https ... "
$expectedTargets = @("download.sysinternals.com/files/BGInfo.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-bginfo-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-bginfo-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-bginfo-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/BGInfo.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-bginfo-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/BGInfo.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [195/285] mirror-to-ms-sysinternals-ctrl2cap-https ... "
$expectedTargets = @("download.sysinternals.com/files/Ctrl2Cap.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-ctrl2cap-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-ctrl2cap-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-ctrl2cap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Ctrl2Cap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-ctrl2cap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Ctrl2Cap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [196/285] mirror-to-ms-sysinternals-debugview-https ... "
$expectedTargets = @("download.sysinternals.com/files/DebugView.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-debugview-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-debugview-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-debugview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/DebugView.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-debugview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/DebugView.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [197/285] mirror-to-ms-sysinternals-desktops-https ... "
$expectedTargets = @("download.sysinternals.com/files/Desktops.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-desktops-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-desktops-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-desktops-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Desktops.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-desktops-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Desktops.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [198/285] mirror-to-ms-sysinternals-findlinks-https ... "
$expectedTargets = @("download.sysinternals.com/files/FindLinks.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-findlinks-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-findlinks-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-findlinks-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/FindLinks.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-findlinks-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/FindLinks.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [199/285] mirror-to-ms-sysinternals-handle-https ... "
$expectedTargets = @("download.sysinternals.com/files/Handle.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-handle-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-handle-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-handle-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Handle.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-handle-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Handle.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [200/285] mirror-to-ms-sysinternals-movefile-https ... "
$expectedTargets = @("download.sysinternals.com/files/pendmoves.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-movefile-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-movefile-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-movefile-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/pendmoves.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-movefile-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/pendmoves.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [201/285] mirror-to-ms-sysinternals-pendmoves-https ... "
$expectedTargets = @("download.sysinternals.com/files/pendmoves.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-pendmoves-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-pendmoves-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-pendmoves-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/pendmoves.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-pendmoves-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/pendmoves.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [202/285] mirror-to-ms-sysinternals-processexplorer-https ... "
$expectedTargets = @("download.sysinternals.com/files/ProcessExplorer.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-processexplorer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-processexplorer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-processexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ProcessExplorer.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-processexplorer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ProcessExplorer.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [203/285] mirror-to-ms-sysinternals-processmonitor-https ... "
$expectedTargets = @("download.sysinternals.com/files/ProcessMonitor.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-processmonitor-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-processmonitor-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-processmonitor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ProcessMonitor.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-processmonitor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ProcessMonitor.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [204/285] mirror-to-ms-sysinternals-rammap-https ... "
$expectedTargets = @("download.sysinternals.com/files/RAMMap.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-rammap-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-rammap-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-rammap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/RAMMap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-rammap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/RAMMap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [205/285] mirror-to-ms-sysinternals-rdcman-https ... "
$expectedTargets = @("download.sysinternals.com/files/RDCMan.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-rdcman-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-rdcman-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-rdcman-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/RDCMan.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-rdcman-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/RDCMan.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [206/285] mirror-to-ms-sysinternals-regjump-https ... "
$expectedTargets = @("download.sysinternals.com/files/regjump.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-regjump-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-regjump-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-regjump-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/regjump.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-regjump-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/regjump.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [207/285] mirror-to-ms-sysinternals-sdelete-https ... "
$expectedTargets = @("download.sysinternals.com/files/SDelete.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-sdelete-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-sdelete-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sdelete-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/SDelete.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sdelete-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/SDelete.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [208/285] mirror-to-ms-sysinternals-sigcheck-https ... "
$expectedTargets = @("download.sysinternals.com/files/Sigcheck.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-sigcheck-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-sigcheck-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sigcheck-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Sigcheck.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sigcheck-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Sigcheck.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [209/285] mirror-to-ms-sysinternals-strings-https ... "
$expectedTargets = @("download.sysinternals.com/files/Strings.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-strings-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-strings-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-strings-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Strings.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-strings-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Strings.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [210/285] mirror-to-ms-sysinternals-sysmon-https ... "
$expectedTargets = @("download.sysinternals.com/files/Sysmon.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-sysmon-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-sysmon-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sysmon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Sysmon.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-sysmon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/Sysmon.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [211/285] mirror-to-ms-sysinternals-tcpview-https ... "
$expectedTargets = @("download.sysinternals.com/files/TCPView.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-tcpview-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-tcpview-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-tcpview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/TCPView.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-tcpview-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/TCPView.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [212/285] mirror-to-ms-sysinternals-vmmap-https ... "
$expectedTargets = @("download.sysinternals.com/files/VMMap.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-vmmap-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-vmmap-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-vmmap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/VMMap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-vmmap-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/VMMap.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [213/285] mirror-to-ms-sysinternals-whois-https ... "
$expectedTargets = @("download.sysinternals.com/files/WhoIs.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-whois-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-whois-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-whois-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/WhoIs.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-whois-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/WhoIs.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [214/285] mirror-to-ms-sysinternals-zoomit-https ... "
$expectedTargets = @("download.sysinternals.com/files/ZoomIt.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-sysinternals-zoomit-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-sysinternals-zoomit-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-zoomit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ZoomIt.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-sysinternals-zoomit-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.sysinternals.com/files/ZoomIt.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [215/285] mirror-to-ms-teammate-https ... "
$expectedTargets = @("github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-teammate-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-teammate-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teammate-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teammate-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [216/285] mirror-to-ms-teams-https ... "
$expectedTargets = @("installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix", "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix", "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-teams-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-teams-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teams-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix", "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix", "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teams-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix", "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix", "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [217/285] mirror-to-ms-teamstxndi-https ... "
$expectedTargets = @("teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-teamstxndi-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-teamstxndi-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teamstxndi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-teamstxndi-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [218/285] mirror-to-ms-timetraveldebugging-https ... "
$expectedTargets = @("windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-timetraveldebugging-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-timetraveldebugging-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-timetraveldebugging-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-timetraveldebugging-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [219/285] mirror-to-ms-tokenizer-https ... "
$expectedTargets = @("github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-tokenizer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-tokenizer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-tokenizer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-tokenizer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [220/285] mirror-to-ms-ui-xaml-2-7-https ... "
$expectedTargets = @("github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-ui-xaml-2-7-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-ui-xaml-2-7-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ui-xaml-2-7-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ui-xaml-2-7-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [221/285] mirror-to-ms-ui-xaml-2-8-https ... "
$expectedTargets = @("github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-ui-xaml-2-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-ui-xaml-2-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ui-xaml-2-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ui-xaml-2-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx", "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx", "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [222/285] mirror-to-ms-updateassistant-https ... "
$expectedTargets = @("download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-updateassistant-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-updateassistant-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-updateassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-updateassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [223/285] mirror-to-ms-vclibs-14-https ... "
$expectedTargets = @("github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vclibs-14-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vclibs-14-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vclibs-14-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vclibs-14-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [224/285] mirror-to-ms-vclibs-desktop-14-https ... "
$expectedTargets = @("github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vclibs-desktop-14-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vclibs-desktop-14-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vclibs-desktop-14-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vclibs-desktop-14-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [225/285] mirror-to-ms-vcredist-2015+-arm64-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vcredist-2015+-arm64-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vcredist-2015+-arm64-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-arm64-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-arm64-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [226/285] mirror-to-ms-vcredist-2015+-x64-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vcredist-2015+-x64-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vcredist-2015+-x64-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-x64-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-x64-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [227/285] mirror-to-ms-vcredist-2015+-x86-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vcredist-2015+-x86-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vcredist-2015+-x86-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-x86-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vcredist-2015+-x86-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [228/285] mirror-to-ms-vsdotnetlogcollect-https ... "
$expectedTargets = @("download.microsoft.com/download/8/3/4/*/Collect.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vsdotnetlogcollect-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vsdotnetlogcollect-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vsdotnetlogcollect-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/3/4/*/Collect.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vsdotnetlogcollect-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/8/3/4/*/Collect.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [229/285] mirror-to-ms-vsixbootstrapper-https ... "
$expectedTargets = @("github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vsixbootstrapper-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vsixbootstrapper-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vsixbootstrapper-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vsixbootstrapper-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [230/285] mirror-to-ms-vstor-https ... "
$expectedTargets = @("download.microsoft.com/download/5/d/2/*/vstor_redist.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-vstor-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-vstor-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vstor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/d/2/*/vstor_redist.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-vstor-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/5/d/2/*/vstor_redist.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [231/285] mirror-to-ms-visioviewer-https ... "
$expectedTargets = @("download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe", "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visioviewer-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visioviewer-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visioviewer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe", "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visioviewer-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe", "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [232/285] mirror-to-ms-visualstudio-2022-buildtools-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-2022-buildtools-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-2022-buildtools-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-buildtools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-buildtools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [233/285] mirror-to-ms-visualstudio-2022-enterprise-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-2022-enterprise-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-2022-enterprise-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-enterprise-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-enterprise-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [234/285] mirror-to-ms-visualstudio-2022-onecoremsvsmon-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip", "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [235/285] mirror-to-ms-visualstudio-2022-professional-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-2022-professional-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-2022-professional-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-professional-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-professional-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [236/285] mirror-to-ms-visualstudio-2022-remotetools-https ... "
$expectedTargets = @("download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-2022-remotetools-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-2022-remotetools-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-remotetools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-2022-remotetools-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [237/285] mirror-to-ms-visualstudio-configfinder-https ... "
$expectedTargets = @("github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-configfinder-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-configfinder-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-configfinder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-configfinder-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [238/285] mirror-to-ms-visualstudio-extensions-typescript-https ... "
$expectedTargets = @("typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-extensions-typescript-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-extensions-typescript-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-extensions-typescript-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-extensions-typescript-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [239/285] mirror-to-ms-visualstudio-locator-https ... "
$expectedTargets = @("github.com/microsoft/vswhere/releases/download/*/vswhere.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudio-locator-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudio-locator-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-locator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/vswhere/releases/download/*/vswhere.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudio-locator-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/vswhere/releases/download/*/vswhere.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [240/285] mirror-to-ms-visualstudiocode-https ... "
$expectedTargets = @("vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualstudiocode-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualstudiocode-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudiocode-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualstudiocode-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*", "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [241/285] mirror-to-ms-visualtruetype-https ... "
$expectedTargets = @("github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-visualtruetype-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-visualtruetype-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualtruetype-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-visualtruetype-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [242/285] mirror-to-ms-wsl-https ... "
$expectedTargets = @("github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*", "github.com/microsoft/WSL/releases/download/*/wsl.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-wsl-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-wsl-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wsl-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*", "github.com/microsoft/WSL/releases/download/*/wsl.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wsl-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*", "github.com/microsoft/WSL/releases/download/*/wsl.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [243/285] mirror-to-ms-wassette-https ... "
$expectedTargets = @("github.com/microsoft/wassette/releases/download/*/wassette_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-wassette-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-wassette-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wassette-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/wassette/releases/download/*/wassette_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wassette-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/wassette/releases/download/*/wassette_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [244/285] mirror-to-ms-webdeploy-https ... "
$expectedTargets = @("download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi", "download.microsoft.com/download/WebDeploy_x86_de-DE.msi", "download.microsoft.com/download/WebDeploy_x86_en-US.msi", "download.microsoft.com/download/WebDeploy_x86_es-ES.msi", "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi", "download.microsoft.com/download/WebDeploy_x86_it-IT.msi", "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi", "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi", "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi", "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi", "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi", "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi", "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi", "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi", "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi", "download.microsoft.com/download/webdeploy_amd64_de-DE.msi", "download.microsoft.com/download/webdeploy_amd64_en-US.msi", "download.microsoft.com/download/webdeploy_amd64_es-ES.msi", "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi", "download.microsoft.com/download/webdeploy_amd64_it-IT.msi", "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi", "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi", "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi", "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi", "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi", "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi", "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi", "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-webdeploy-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-webdeploy-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-webdeploy-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi", "download.microsoft.com/download/WebDeploy_x86_de-DE.msi", "download.microsoft.com/download/WebDeploy_x86_en-US.msi", "download.microsoft.com/download/WebDeploy_x86_es-ES.msi", "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi", "download.microsoft.com/download/WebDeploy_x86_it-IT.msi", "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi", "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi", "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi", "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi", "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi", "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi", "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi", "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi", "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi", "download.microsoft.com/download/webdeploy_amd64_de-DE.msi", "download.microsoft.com/download/webdeploy_amd64_en-US.msi", "download.microsoft.com/download/webdeploy_amd64_es-ES.msi", "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi", "download.microsoft.com/download/webdeploy_amd64_it-IT.msi", "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi", "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi", "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi", "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi", "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi", "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi", "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi", "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-webdeploy-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi", "download.microsoft.com/download/WebDeploy_x86_de-DE.msi", "download.microsoft.com/download/WebDeploy_x86_en-US.msi", "download.microsoft.com/download/WebDeploy_x86_es-ES.msi", "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi", "download.microsoft.com/download/WebDeploy_x86_it-IT.msi", "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi", "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi", "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi", "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi", "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi", "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi", "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi", "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi", "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi", "download.microsoft.com/download/webdeploy_amd64_de-DE.msi", "download.microsoft.com/download/webdeploy_amd64_en-US.msi", "download.microsoft.com/download/webdeploy_amd64_es-ES.msi", "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi", "download.microsoft.com/download/webdeploy_amd64_it-IT.msi", "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi", "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi", "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi", "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi", "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi", "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi", "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi", "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [245/285] mirror-to-ms-win32contentpreptool-https ... "
$expectedTargets = @("codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*", "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-win32contentpreptool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-win32contentpreptool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-win32contentpreptool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*", "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-win32contentpreptool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*", "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [246/285] mirror-to-ms-winappcli-https ... "
$expectedTargets = @("github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix", "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix", "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-winappcli-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-winappcli-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-winappcli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix", "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix", "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-winappcli-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix", "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix", "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [247/285] mirror-to-ms-windbg-https ... "
$expectedTargets = @("windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windbg-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windbg-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windbg-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windbg-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [248/285] mirror-to-ms-windowsadk-https ... "
$expectedTargets = @("download.microsoft.com/download/*/adk/adksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsadk-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsadk-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsadk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/adk/adksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsadk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/adk/adksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [249/285] mirror-to-ms-windowsadmincenter-https ... "
$expectedTargets = @("download.microsoft.com/download/*/WindowsAdminCenter2511.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsadmincenter-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsadmincenter-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsadmincenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/WindowsAdminCenter2511.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsadmincenter-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/WindowsAdminCenter2511.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [250/285] mirror-to-ms-windowsapp-https ... "
$expectedTargets = @("res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsapp-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsapp-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsapp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsapp-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*", "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [251/285] mirror-to-ms-windowsappruntime-1-7-https ... "
$expectedTargets = @("aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsappruntime-1-7-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsappruntime-1-7-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsappruntime-1-7-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsappruntime-1-7-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe", "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [252/285] mirror-to-ms-windowsappruntime-1-8-https ... "
$expectedTargets = @("download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.*", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsappruntime-1-8-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsappruntime-1-8-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsappruntime-1-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.*", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsappruntime-1-8-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.*", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe", "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [253/285] mirror-to-ms-windowsapplicationdriver-https ... "
$expectedTargets = @("github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsapplicationdriver-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsapplicationdriver-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsapplicationdriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsapplicationdriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [254/285] mirror-to-ms-windowsbusestracing-https ... "
$expectedTargets = @("github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip", "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsbusestracing-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsbusestracing-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsbusestracing-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip", "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsbusestracing-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip", "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [255/285] mirror-to-ms-windowscloudioprotectiondriver-https ... "
$expectedTargets = @("res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*", "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowscloudioprotectiondriver-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowscloudioprotectiondriver-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowscloudioprotectiondriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*", "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowscloudioprotectiondriver-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*", "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [256/285] mirror-to-ms-windowsdevicerecoverytool-https ... "
$expectedTargets = @("download.microsoft.com/download/*/wdrt-hl1.zip")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsdevicerecoverytool-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsdevicerecoverytool-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsdevicerecoverytool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/wdrt-hl1.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsdevicerecoverytool-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/wdrt-hl1.zip", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [257/285] mirror-to-ms-windowsinstallationassistant-https ... "
$expectedTargets = @("download.microsoft.com/download/*/Windows11InstallationAssistant.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsinstallationassistant-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsinstallationassistant-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsinstallationassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Windows11InstallationAssistant.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsinstallationassistant-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/Windows11InstallationAssistant.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [258/285] mirror-to-ms-windowsmidiservicessdk-https ... "
$expectedTargets = @("github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsmidiservicessdk-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsmidiservicessdk-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsmidiservicessdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsmidiservicessdk-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*", "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [259/285] mirror-to-ms-windowspchealthcheck-https ... "
$expectedTargets = @("download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi", "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowspchealthcheck-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowspchealthcheck-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowspchealthcheck-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi", "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowspchealthcheck-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi", "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [260/285] mirror-to-ms-windowssdk-10-0-22621-https ... "
$expectedTargets = @("download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowssdk-10-0-22621-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowssdk-10-0-22621-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-22621-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-22621-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [261/285] mirror-to-ms-windowssdk-10-0-26100-https ... "
$expectedTargets = @("download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowssdk-10-0-26100-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowssdk-10-0-26100-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-26100-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-26100-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [262/285] mirror-to-ms-windowssdk-10-0-28000-https ... "
$expectedTargets = @("download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowssdk-10-0-28000-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowssdk-10-0-28000-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-28000-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowssdk-10-0-28000-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [263/285] mirror-to-ms-windowsterminal-https ... "
$expectedTargets = @("github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsterminal-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsterminal-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsterminal-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsterminal-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [264/285] mirror-to-ms-windowsvirtualdesktopagent-https ... "
$expectedTargets = @("go.microsoft.com/fwlink/", "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsvirtualdesktopagent-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsvirtualdesktopagent-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsvirtualdesktopagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "go.microsoft.com/fwlink/", "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsvirtualdesktopagent-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "go.microsoft.com/fwlink/", "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [265/285] mirror-to-ms-windowsvirtualdesktopbootloader-https ... "
$expectedTargets = @("query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowsvirtualdesktopbootloader-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowsvirtualdesktopbootloader-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsvirtualdesktopbootloader-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowsvirtualdesktopbootloader-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH", "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [266/285] mirror-to-ms-windowswdk-10-0-22621-https ... "
$expectedTargets = @("download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowswdk-10-0-22621-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowswdk-10-0-22621-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowswdk-10-0-22621-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowswdk-10-0-22621-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [267/285] mirror-to-ms-windowswdk-10-0-26100-https ... "
$expectedTargets = @("download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-windowswdk-10-0-26100-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-windowswdk-10-0-26100-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowswdk-10-0-26100-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-windowswdk-10-0-26100-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [268/285] mirror-to-ms-wingetcreate-https ... "
$expectedTargets = @("github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*", "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-wingetcreate-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-wingetcreate-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wingetcreate-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*", "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-wingetcreate-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*", "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [269/285] mirror-to-ms-xmlnotepad-https ... "
$expectedTargets = @("github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*", "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-xmlnotepad-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-xmlnotepad-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-xmlnotepad-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*", "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-xmlnotepad-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*", "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [270/285] mirror-to-ms-bitsmanager-https ... "
$expectedTargets = @("github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-bitsmanager-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-bitsmanager-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-bitsmanager-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-bitsmanager-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [271/285] mirror-to-ms-ebpfforwindows-https ... "
$expectedTargets = @("github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip", "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-ebpfforwindows-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-ebpfforwindows-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ebpfforwindows-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip", "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-ebpfforwindows-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip", "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip", "objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [272/285] mirror-to-ms-err-https ... "
$expectedTargets = @("download.microsoft.com/download/4/3/2/*/Err_*/Err_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-err-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-err-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-err-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/3/2/*/Err_*/Err_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-err-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/4/3/2/*/Err_*/Err_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [273/285] mirror-to-ms-etl2pcapng-https ... "
$expectedTargets = @("github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-etl2pcapng-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-etl2pcapng-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-etl2pcapng-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-etl2pcapng-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe", "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [274/285] mirror-to-ms-msodbcsql-17-https ... "
$expectedTargets = @("download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-msodbcsql-17-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-msodbcsql-17-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msodbcsql-17-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msodbcsql-17-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [275/285] mirror-to-ms-msodbcsql-18-https ... "
$expectedTargets = @("download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi", "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi", "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-msodbcsql-18-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-msodbcsql-18-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msodbcsql-18-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi", "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi", "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-msodbcsql-18-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi", "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi", "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi", "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi", "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi", "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi", "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi", "download.microsoft.com/download/*/x86/1028/msodbcsql.msi", "download.microsoft.com/download/*/x86/1031/msodbcsql.msi", "download.microsoft.com/download/*/x86/1033/msodbcsql.msi", "download.microsoft.com/download/*/x86/1036/msodbcsql.msi", "download.microsoft.com/download/*/x86/1040/msodbcsql.msi", "download.microsoft.com/download/*/x86/1041/msodbcsql.msi", "download.microsoft.com/download/*/x86/1042/msodbcsql.msi", "download.microsoft.com/download/*/x86/1046/msodbcsql.msi", "download.microsoft.com/download/*/x86/1049/msodbcsql.msi", "download.microsoft.com/download/*/x86/2052/msodbcsql.msi", "download.microsoft.com/download/*/x86/3082/msodbcsql.msi", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [276/285] mirror-to-ms-quicreach-https ... "
$expectedTargets = @("github.com/microsoft/quicreach/releases/download/*/quicreach.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-quicreach-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-quicreach-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-quicreach-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/quicreach/releases/download/*/quicreach.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-quicreach-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/quicreach/releases/download/*/quicreach.msi", "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [277/285] mirror-to-ms-winfile-https ... "
$expectedTargets = @("github.com/microsoft/winfile/releases/download/*/Winfile_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-ms-winfile-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-ms-winfile-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-winfile-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winfile/releases/download/*/Winfile_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-ms-winfile-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "github.com/microsoft/winfile/releases/download/*/Winfile_*", "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [278/285] mirror-to-telerik-fiddler-classic-https ... "
$expectedTargets = @("downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-telerik-fiddler-classic-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-telerik-fiddler-classic-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-telerik-fiddler-classic-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-telerik-fiddler-classic-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [279/285] mirror-to-wiresharkfoundation-stratoshark-https ... "
$expectedTargets = @("1.na.dl.wireshark.org/win64/Stratoshark-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wiresharkfoundation-stratoshark-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wiresharkfoundation-stratoshark-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wiresharkfoundation-stratoshark-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "1.na.dl.wireshark.org/win64/Stratoshark-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wiresharkfoundation-stratoshark-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "1.na.dl.wireshark.org/win64/Stratoshark-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [280/285] mirror-to-wiresharkfoundation-wireshark-https ... "
$expectedTargets = @("2.na.dl.wireshark.org/win64/all-versions/Wireshark-*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wiresharkfoundation-wireshark-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wiresharkfoundation-wireshark-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wiresharkfoundation-wireshark-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wiresharkfoundation-wireshark-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [281/285] mirror-to-wsl-infra-https ... "
$expectedTargets = @("cdimages.ubuntu.com", "wslstorestorage.blob.core.windows.net")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wsl-infra-https" -ExpectedTargets $expectedTargets -TargetType "targetFqdns"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wsl-infra-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-infra-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-fqdns", "cdimages.ubuntu.com", "wslstorestorage.blob.core.windows.net", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-infra-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-fqdns", "cdimages.ubuntu.com", "wslstorestorage.blob.core.windows.net", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [282/285] mirror-to-wsl-ubuntu-20-04-https ... "
$expectedTargets = @("aka.ms/wslubuntu2004", "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wsl-ubuntu-20-04-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wsl-ubuntu-20-04-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-20-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/wslubuntu2004", "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-20-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/wslubuntu2004", "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [283/285] mirror-to-wsl-ubuntu-22-04-https ... "
$expectedTargets = @("aka.ms/wslubuntu2204", "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wsl-ubuntu-22-04-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wsl-ubuntu-22-04-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-22-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/wslubuntu2204", "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-22-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "aka.ms/wslubuntu2204", "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [284/285] mirror-to-wsl-ubuntu-24-04-https ... "
$expectedTargets = @("cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wsl-ubuntu-24-04-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wsl-ubuntu-24-04-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-24-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-24-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

Write-Host -NoNewline "   [285/285] mirror-to-wsl-ubuntu-26-04-https ... "
$expectedTargets = @("cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl")
$result = Test-RuleExistsAndMatches -RuleName "mirror-to-wsl-ubuntu-26-04-https" -ExpectedTargets $expectedTargets -TargetType "targetUrls"

if ($result -ceq 'match') {
    Write-Host "⏭️  跳過（已存在且相同）" -ForegroundColor Cyan
    $Skipped++
}
elseif ($result -ceq 'different') {
    Write-Host -NoNewline "🔄 更新中... " -ForegroundColor Yellow
    Remove-DraftRule -RuleName "mirror-to-wsl-ubuntu-26-04-https"
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-26-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 已更新" -ForegroundColor Green
        $Updated++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}
else {
    try {
        Invoke-AzCli -Arguments @("network", "firewall", "policy", "rule-collection-group", "draft", "collection", "rule", "add", "--policy-name", $PolicyName, "--resource-group", $ResourceGroup, "--rule-collection-group-name", $RcgName, "--collection-name", $RcName, "--name", "mirror-to-wsl-ubuntu-26-04-https", "--rule-type", "ApplicationRule", "--protocols", "Https=443", "--target-urls", "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl", "--source-ip-groups", "ipgroup-corp-clients", "ipgroup-dev-clients", "--output", "none") | Out-Null
        Write-Host "✅ 新增" -ForegroundColor Green
        $Current++
    }
    catch {
        Write-Host "❌" -ForegroundColor Red
        $Failed++
    }
}

# =============================================
# 步驟 6：部署摘要
# =============================================
Write-Host ""
Write-Host "=============================="
Write-Host "📊 部署摘要" -ForegroundColor Cyan
Write-Host "=============================="
Write-Host "   Policy:        $PolicyName"
Write-Host "   RCG:           $RcgName"
Write-Host "   Collection:    $RcName"
Write-Host "   ✅ 新增:        $Current" -ForegroundColor Green
Write-Host "   🔄 更新:        $Updated" -ForegroundColor Yellow
Write-Host "   ⏭️  跳過:        $Skipped"
if ($Failed -gt 0) {
    Write-Host "   ❌ 失敗:        $Failed" -ForegroundColor Red
}
Write-Host "=============================="
Write-Host ""

if ($Failed -gt 0) {
    Write-Host "⚠️  有 $Failed 條規則處理失敗，請檢查錯誤訊息" -ForegroundColor Yellow
}

Write-Host "⚠️  規則已寫入 Draft，尚未套用至正式環境" -ForegroundColor Yellow
Write-Host "   請在 Azure Portal 確認 Draft 內容後，執行以下指令部署：" -ForegroundColor Yellow
Write-Host ""
Write-Host "az network firewall policy rule-collection-group draft deploy ``"
Write-Host "  --policy-name `"$PolicyName`" ``"
Write-Host "  --resource-group `"$ResourceGroup`" ``"
Write-Host "  --rule-collection-group-name `"$RcgName`""
Write-Host ""
