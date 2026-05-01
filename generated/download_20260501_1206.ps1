# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 12:06:36
# 套件數量：2
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

Write-Host ""
Write-Host "==============================" -ForegroundColor Cyan
Write-Host "📊 下載結果摘要" -ForegroundColor Cyan
Write-Host "   ✅ 成功下載: $Total 個"
Write-Host "   ⏭️  已略過: $Skipped 個"
Write-Host "   ❌ 下載失敗: $Failed 個"
Write-Host "   📂 下載目錄: $DownloadDir"
Write-Host "==============================" -ForegroundColor Cyan
