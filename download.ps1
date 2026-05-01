# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 10:32:23
# 套件數量：3
#
# 用法：.\download.ps1
# 檔案會下載到 .\downloads\{PackageId}\ 目錄

$ErrorActionPreference = "Continue"

$DownloadDir = ".\downloads"
$Total = 0
$Skipped = 0
$Failed = 0

Write-Host "🚀 開始下載 winget 安裝檔 ..." -ForegroundColor Cyan
Write-Host ""

# === Git.Git v2.54.0 ===
$PkgDir = "$DownloadDir\Git\Git"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Git.Git v2.54.0" -ForegroundColor White

$FilePath = "$PkgDir\Git-2.54.0-64-bit.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Git-2.54.0-64-bit.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Git-2.54.0-64-bit.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-64-bit.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Git-2.54.0-64-bit.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Git-2.54.0-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Git-2.54.0-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Git-2.54.0-arm64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/git-for-windows/git/releases/download/v2.54.0.windows.1/Git-2.54.0-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Git-2.54.0-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === GitHub.cli v2.92.0 ===
$PkgDir = "$DownloadDir\GitHub\cli"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 GitHub.cli v2.92.0" -ForegroundColor White

$FilePath = "$PkgDir\gh_2.92.0_windows_386.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_386.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_386.msi (x86/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_386.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_386.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\gh_2.92.0_windows_386.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_386.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_386.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_386.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_386.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\gh_2.92.0_windows_amd64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_amd64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_amd64.msi (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_amd64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\gh_2.92.0_windows_amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\gh_2.92.0_windows_arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_arm64.msi (arm64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\gh_2.92.0_windows_arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: gh_2.92.0_windows_arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: gh_2.92.0_windows_arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: gh_2.92.0_windows_arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudioCode v1.118.1 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudioCode"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudioCode v1.118.1" -ForegroundColor White

$FilePath = "$PkgDir\VSCodeSetup-arm64-1.118.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSCodeSetup-arm64-1.118.1.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSCodeSetup-arm64-1.118.1.exe (arm64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeSetup-arm64-1.118.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSCodeSetup-arm64-1.118.1.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\VSCodeUserSetup-arm64-1.118.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSCodeUserSetup-arm64-1.118.1.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSCodeUserSetup-arm64-1.118.1.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeUserSetup-arm64-1.118.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSCodeUserSetup-arm64-1.118.1.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\VSCodeSetup-x64-1.118.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSCodeSetup-x64-1.118.1.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSCodeSetup-x64-1.118.1.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeSetup-x64-1.118.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSCodeSetup-x64-1.118.1.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\VSCodeUserSetup-x64-1.118.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSCodeUserSetup-x64-1.118.1.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSCodeUserSetup-x64-1.118.1.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeUserSetup-x64-1.118.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSCodeUserSetup-x64-1.118.1.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "📊 下載結果摘要" -ForegroundColor Cyan
Write-Host "   ✅ 成功下載: $Total 個"
Write-Host "   ⏭️  已略過: $Skipped 個"
Write-Host "   ❌ 下載失敗: $Failed 個"
Write-Host "   📂 下載目錄: $DownloadDir"
Write-Host "==============================" -ForegroundColor Cyan
