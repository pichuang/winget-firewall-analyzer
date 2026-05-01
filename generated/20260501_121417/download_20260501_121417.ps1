# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 12:14:17
# 套件數量：4
#
# 用法：.\generated\download.ps1
# 檔案會下載到 .\downloads\{PackageId}\ 目錄

$ErrorActionPreference = "Continue"

$DownloadDir = ".\downloads"
$Total = 0
$Skipped = 0
$Failed = 0

Write-Host "🚀 開始下載 winget 安裝檔 ..." -ForegroundColor Cyan
Write-Host ""

# === WSL.Ubuntu-20.04 vUbuntu 20.04 LTS ===
$PkgDir = "$DownloadDir\WSL\Ubuntu-20\04"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WSL.Ubuntu-20.04 vUbuntu 20.04 LTS" -ForegroundColor White

$FilePath = "$PkgDir\wslubuntu2004"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wslubuntu2004 (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wslubuntu2004 (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2004" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wslubuntu2004" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === WSL.Ubuntu-22.04 vUbuntu 22.04 LTS ===
$PkgDir = "$DownloadDir\WSL\Ubuntu-22\04"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WSL.Ubuntu-22.04 vUbuntu 22.04 LTS" -ForegroundColor White

$FilePath = "$PkgDir\wslubuntu2204"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wslubuntu2204 (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wslubuntu2204 (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2204" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wslubuntu2204" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === WSL.Ubuntu-24.04 vUbuntu 24.04 LTS ===
$PkgDir = "$DownloadDir\WSL\Ubuntu-24\04"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WSL.Ubuntu-24.04 vUbuntu 24.04 LTS" -ForegroundColor White

$FilePath = "$PkgDir\noble-wsl-amd64.wsl"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: noble-wsl-amd64.wsl (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: noble-wsl-amd64.wsl (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: noble-wsl-amd64.wsl" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === WSL.Ubuntu-26.04 vUbuntu 26.04 LTS ===
$PkgDir = "$DownloadDir\WSL\Ubuntu-26\04"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WSL.Ubuntu-26.04 vUbuntu 26.04 LTS" -ForegroundColor White

$FilePath = "$PkgDir\resolute-wsl-amd64.wsl"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: resolute-wsl-amd64.wsl (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: resolute-wsl-amd64.wsl (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: resolute-wsl-amd64.wsl" -ForegroundColor Red
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
