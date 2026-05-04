# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-04 19:45:20
# 套件數量：279
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

# === GitHub.Copilot v1.0.34 ===
$PkgDir = "$DownloadDir\GitHub\Copilot"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 GitHub.Copilot v1.0.34" -ForegroundColor White

$FilePath = "$PkgDir\copilot-win32-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: copilot-win32-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: copilot-win32-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/github/copilot-cli/releases/download/v1.0.34/copilot-win32-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: copilot-win32-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\copilot-win32-arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: copilot-win32-arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: copilot-win32-arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/github/copilot-cli/releases/download/v1.0.34/copilot-win32-arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: copilot-win32-arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === GitHub.GitHubDesktop v3.5.8 ===
$PkgDir = "$DownloadDir\GitHub\GitHubDesktop"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 GitHub.GitHubDesktop v3.5.8" -ForegroundColor White

$FilePath = "$PkgDir\GitHubDesktopSetup-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubDesktopSetup-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubDesktopSetup-x64.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubDesktopSetup-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\GitHubDesktopSetup-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubDesktopSetup-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubDesktopSetup-x64.msi (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubDesktopSetup-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\GitHubDesktopSetup-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubDesktopSetup-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubDesktopSetup-arm64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubDesktopSetup-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\GitHubDesktopSetup-arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubDesktopSetup-arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubDesktopSetup-arm64.msi (arm64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubDesktopSetup-arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === GitHub.GitLFS v3.7.1 ===
$PkgDir = "$DownloadDir\GitHub\GitLFS"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 GitHub.GitLFS v3.7.1" -ForegroundColor White

$FilePath = "$PkgDir\git-lfs-windows-v3.7.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: git-lfs-windows-v3.7.1.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: git-lfs-windows-v3.7.1.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/git-lfs/git-lfs/releases/download/v3.7.1/git-lfs-windows-v3.7.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: git-lfs-windows-v3.7.1.exe" -ForegroundColor Red
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

# === GitHub.git-sizer v1.5.0 ===
$PkgDir = "$DownloadDir\GitHub\git-sizer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 GitHub.git-sizer v1.5.0" -ForegroundColor White

$FilePath = "$PkgDir\git-sizer-1.5.0-windows-386.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: git-sizer-1.5.0-windows-386.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: git-sizer-1.5.0-windows-386.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-windows-386.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: git-sizer-1.5.0-windows-386.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\git-sizer-1.5.0-windows-amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: git-sizer-1.5.0-windows-amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: git-sizer-1.5.0-windows-amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-windows-amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: git-sizer-1.5.0-windows-amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AKSdesktop v0.1.0-alpha ===
$PkgDir = "$DownloadDir\Microsoft\AKSdesktop"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AKSdesktop v0.1.0-alpha" -ForegroundColor White

$FilePath = "$PkgDir\aks-desktop-0.1.0-alpha-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aks-desktop-0.1.0-alpha-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aks-desktop-0.1.0-alpha-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/aks-desktop/releases/download/v0.1.0-alpha/aks-desktop-0.1.0-alpha-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aks-desktop-0.1.0-alpha-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.APM v0.12.1 ===
$PkgDir = "$DownloadDir\Microsoft\APM"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.APM v0.12.1" -ForegroundColor White

$FilePath = "$PkgDir\apm-windows-x86_64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: apm-windows-x86_64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: apm-windows-x86_64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/apm/releases/download/v0.12.1/apm-windows-x86_64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: apm-windows-x86_64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ASRTestTool v4.13.17600.1000 ===
$PkgDir = "$DownloadDir\Microsoft\ASRTestTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ASRTestTool v4.13.17600.1000" -ForegroundColor White

$FilePath = "$PkgDir\ASRtool.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ASRtool.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ASRtool.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://demo.wd.microsoft.com/Content/ASRtool.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ASRtool.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AccountLockoutStatus v1.0.0.60 ===
$PkgDir = "$DownloadDir\Microsoft\AccountLockoutStatus"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AccountLockoutStatus v1.0.0.60" -ForegroundColor White

$FilePath = "$PkgDir\lockoutstatus.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: lockoutstatus.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: lockoutstatus.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/0/4/c0472410-b4c2-4aef-89d2-e7c708dfc225/lockoutstatus.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: lockoutstatus.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AdministrativeTemplates v11.25H2 ===
$PkgDir = "$DownloadDir\Microsoft\AdministrativeTemplates"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AdministrativeTemplates v11.25H2" -ForegroundColor White

$FilePath = "$PkgDir\Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f35d3000-b6c9-4ca6-bedc-5e4ec15a6b7a/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AppControlPolicyWizard v2.6.0.1 ===
$PkgDir = "$DownloadDir\Microsoft\AppControlPolicyWizard"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AppControlPolicyWizard v2.6.0.1" -ForegroundColor White

$FilePath = "$PkgDir\WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AppInstaller v1.27.470.0 ===
$PkgDir = "$DownloadDir\Microsoft\AppInstaller"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AppInstaller v1.27.470.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.12.470/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AppInstallerFileBuilder v1.2020.221.0 ===
$PkgDir = "$DownloadDir\Microsoft\AppInstallerFileBuilder"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AppInstallerFileBuilder v1.2020.221.0" -ForegroundColor White

$FilePath = "$PkgDir\AppInstallerFileBuilder_1.2020.221.0_x86.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AppInstallerFileBuilder_1.2020.221.0_x86.msix (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AppInstallerFileBuilder_1.2020.221.0_x86.msix (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_1.2020.221.0_x86.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AppInstallerFileBuilder_1.2020.221.0_x86.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AppLockerPolicyConverter v2.0.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\AppLockerPolicyConverter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AppLockerPolicyConverter v2.0.0.0" -ForegroundColor White

$FilePath = "$PkgDir\AppLockerPolicyConverter.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AppLockerPolicyConverter.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AppLockerPolicyConverter.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/v2.0.0.0/AppLockerPolicyConverter.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AppLockerPolicyConverter.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ApplicationInspector v1.9.55 ===
$PkgDir = "$DownloadDir\Microsoft\ApplicationInspector"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ApplicationInspector v1.9.55" -ForegroundColor White

$FilePath = "$PkgDir\ApplicationInspector_win_1.9.55.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ApplicationInspector_win_1.9.55.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ApplicationInspector_win_1.9.55.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/ApplicationInspector/releases/download/v1.9.55/ApplicationInspector_win_1.9.55.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ApplicationInspector_win_1.9.55.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Aspire v13.1.3 ===
$PkgDir = "$DownloadDir\Microsoft\Aspire"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Aspire v13.1.3" -ForegroundColor White

$FilePath = "$PkgDir\aspire-cli-win-x64-13.1.3.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspire-cli-win-x64-13.1.3.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspire-cli-win-x64-13.1.3.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://ci.dot.net/public/aspire/13.1.3-preview.1.26166.8/aspire-cli-win-x64-13.1.3.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspire-cli-win-x64-13.1.3.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspire-cli-win-arm64-13.1.3.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspire-cli-win-arm64-13.1.3.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspire-cli-win-arm64-13.1.3.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://ci.dot.net/public/aspire/13.1.3-preview.1.26166.8/aspire-cli-win-arm64-13.1.3.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspire-cli-win-arm64-13.1.3.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azd v1.24.400 ===
$PkgDir = "$DownloadDir\Microsoft\Azd"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azd v1.24.400" -ForegroundColor White

$FilePath = "$PkgDir\azd-windows-amd64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azd-windows-amd64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azd-windows-amd64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-dev/releases/download/azure-dev-cli_1.24.3/azd-windows-amd64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azd-windows-amd64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\ADConnectSyncDocumenter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0" -ForegroundColor White

$FilePath = "$PkgDir\AzureADConnectSyncDocumenter.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureADConnectSyncDocumenter.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureADConnectSyncDocumenter.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/AADConnectConfigDocumenter/releases/download/v1.20.0917.0/AzureADConnectSyncDocumenter.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureADConnectSyncDocumenter.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.AZCopy.10 v10.32.3 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\AZCopy\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.AZCopy.10 v10.32.3" -ForegroundColor White

$FilePath = "$PkgDir\azcopy_windows_386_10.32.3.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azcopy_windows_386_10.32.3.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azcopy_windows_386_10.32.3.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_386_10.32.3.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azcopy_windows_386_10.32.3.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azcopy_windows_amd64_10.32.3.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azcopy_windows_amd64_10.32.3.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azcopy_windows_amd64_10.32.3.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_amd64_10.32.3.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azcopy_windows_amd64_10.32.3.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azcopy_windows_arm64_10.32.3.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azcopy_windows_arm64_10.32.3.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azcopy_windows_arm64_10.32.3.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_arm64_10.32.3.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azcopy_windows_arm64_10.32.3.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.ArtifactSigningClientTools v0.1.128 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\ArtifactSigningClientTools"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.ArtifactSigningClientTools v0.1.128" -ForegroundColor White

$FilePath = "$PkgDir\ArtifactSigningClientTools.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ArtifactSigningClientTools.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ArtifactSigningClientTools.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/a3c24ba9-ff1f-444f-b626-eff710f345c3/ArtifactSigningClientTools.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ArtifactSigningClientTools.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.Auth v0.9.2 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\Auth"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.Auth v0.9.2" -ForegroundColor White

$FilePath = "$PkgDir\azureauth-0.9.2-win-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azureauth-0.9.2-win-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azureauth-0.9.2-win-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/AzureAD/microsoft-authentication-cli/releases/download/0.9.2/azureauth-0.9.2-win-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azureauth-0.9.2-win-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.Az v15.2.0.40510 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\Az"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.Az v15.2.0.40510" -ForegroundColor White

$FilePath = "$PkgDir\Az-Cmdlets-15.2.0.40510-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Az-Cmdlets-15.2.0.40510-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Az-Cmdlets-15.2.0.40510-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-powershell/releases/download/v15.2.0-January2026/Az-Cmdlets-15.2.0.40510-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Az-Cmdlets-15.2.0.40510-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.AztfExport v0.19.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\AztfExport"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.AztfExport v0.19.0" -ForegroundColor White

$FilePath = "$PkgDir\aztfexport_v0.19.0_x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aztfexport_v0.19.0_x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aztfexport_v0.19.0_x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/aztfexport/releases/download/v0.19.0/aztfexport_v0.19.0_x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aztfexport_v0.19.0_x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aztfexport_v0.19.0_x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aztfexport_v0.19.0_x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aztfexport_v0.19.0_x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/aztfexport/releases/download/v0.19.0/aztfexport_v0.19.0_x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aztfexport_v0.19.0_x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.BatchExplorer v2.23.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\BatchExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.BatchExplorer v2.23.0" -ForegroundColor White

$FilePath = "$PkgDir\BatchExplorer.Setup.2.23.0-stable.1210.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: BatchExplorer.Setup.2.23.0-stable.1210.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: BatchExplorer.Setup.2.23.0-stable.1210.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/BatchExplorer/releases/download/v2.23.0-stable.1210/BatchExplorer.Setup.2.23.0-stable.1210.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: BatchExplorer.Setup.2.23.0-stable.1210.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\CloudHSM-ClientSDK"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2" -ForegroundColor White

$FilePath = "$PkgDir\AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-2.0.2.2/AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\ConnectedMachineAgent"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896" -ForegroundColor White

$FilePath = "$PkgDir\AzureConnectedMachineAgent.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureConnectedMachineAgent.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureConnectedMachineAgent.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureConnectedMachineAgent.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.CosmosEmulator v2.14.27 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\CosmosEmulator"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.CosmosEmulator v2.14.27" -ForegroundColor White

$FilePath = "$PkgDir\azure-cosmosdb-emulator-2.14.27-26220ef4.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azure-cosmosdb-emulator-2.14.27-26220ef4.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azure-cosmosdb-emulator-2.14.27-26220ef4.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-2.14.27-26220ef4.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azure-cosmosdb-emulator-2.14.27-26220ef4.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.DataCLI v20.3.14 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\DataCLI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.DataCLI v20.3.14" -ForegroundColor White

$FilePath = "$PkgDir\azdata-cli-20.3.14.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azdata-cli-20.3.14.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azdata-cli-20.3.14.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f/f/f/fffaa914-d4f7-4885-89c7-696bbfe7670a/azdata-cli-20.3.14.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azdata-cli-20.3.14.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.DataStudio v1.52.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\DataStudio"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.DataStudio v1.52.0" -ForegroundColor White

$FilePath = "$PkgDir\azuredatastudio-windows-user-setup-1.52.0.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azuredatastudio-windows-user-setup-1.52.0.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azuredatastudio-windows-user-setup-1.52.0.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-user-setup-1.52.0.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azuredatastudio-windows-user-setup-1.52.0.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azuredatastudio-windows-arm64-user-setup-1.52.0.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azuredatastudio-windows-arm64-user-setup-1.52.0.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azuredatastudio-windows-arm64-user-setup-1.52.0.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-arm64-user-setup-1.52.0.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azuredatastudio-windows-arm64-user-setup-1.52.0.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azuredatastudio-windows-setup-1.52.0.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azuredatastudio-windows-setup-1.52.0.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azuredatastudio-windows-setup-1.52.0.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-setup-1.52.0.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azuredatastudio-windows-setup-1.52.0.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azuredatastudio-windows-arm64-setup-1.52.0.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azuredatastudio-windows-arm64-setup-1.52.0.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azuredatastudio-windows-arm64-setup-1.52.0.exe (arm64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-arm64-setup-1.52.0.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azuredatastudio-windows-arm64-setup-1.52.0.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.FunctionsCoreTools v4.10.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\FunctionsCoreTools"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.FunctionsCoreTools v4.10.0" -ForegroundColor White

$FilePath = "$PkgDir\func-cli-4.10.0-x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: func-cli-4.10.0-x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: func-cli-4.10.0-x86.msi (x86/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/func-cli-4.10.0-x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: func-cli-4.10.0-x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\func-cli-4.10.0-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: func-cli-4.10.0-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: func-cli-4.10.0-x64.msi (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/func-cli-4.10.0-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: func-cli-4.10.0-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Azure.Functions.Cli.win-x86.4.10.0.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Azure.Functions.Cli.win-x86.4.10.0.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Azure.Functions.Cli.win-x86.4.10.0.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-x86.4.10.0.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Azure.Functions.Cli.win-x86.4.10.0.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Azure.Functions.Cli.win-x64.4.10.0.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Azure.Functions.Cli.win-x64.4.10.0.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Azure.Functions.Cli.win-x64.4.10.0.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-x64.4.10.0.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Azure.Functions.Cli.win-x64.4.10.0.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Azure.Functions.Cli.win-arm64.4.10.0.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Azure.Functions.Cli.win-arm64.4.10.0.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Azure.Functions.Cli.win-arm64.4.10.0.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-arm64.4.10.0.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Azure.Functions.Cli.win-arm64.4.10.0.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.GuestProxyAgent v1.0.39 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\GuestProxyAgent"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.GuestProxyAgent v1.0.39" -ForegroundColor White

$FilePath = "$PkgDir\Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/GuestProxyAgent/releases/download/1.0.39/Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/GuestProxyAgent/releases/download/1.0.39/Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.IoTExplorer v0.15.12 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\IoTExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.IoTExplorer v0.15.12" -ForegroundColor White

$FilePath = "$PkgDir\Azure.IoT.Explorer.Preview.0.15.12.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Azure.IoT.Explorer.Preview.0.15.12.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Azure.IoT.Explorer.Preview.0.15.12.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azure-iot-explorer/releases/download/v0.15.12/Azure.IoT.Explorer.Preview.0.15.12.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Azure.IoT.Explorer.Preview.0.15.12.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.Kubelogin v0.2.13 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\Kubelogin"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.Kubelogin v0.2.13" -ForegroundColor White

$FilePath = "$PkgDir\kubelogin_0.2.13-1_amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: kubelogin_0.2.13-1_amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: kubelogin_0.2.13-1_amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://packages.aks.azure.com/dalec-packages/kubelogin/0.2.13/windows/amd64/kubelogin_0.2.13-1_amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: kubelogin_0.2.13-1_amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.QuickReview v3.1.2 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\QuickReview"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.QuickReview v3.1.2" -ForegroundColor White

$FilePath = "$PkgDir\azqr-win-amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azqr-win-amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azqr-win-amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/azqr/releases/download/v.3.1.2/azqr-win-amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azqr-win-amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.StorageExplorer v1.43.0 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\StorageExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.StorageExplorer v1.43.0" -ForegroundColor White

$FilePath = "$PkgDir\StorageExplorer-windows-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: StorageExplorer-windows-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: StorageExplorer-windows-x64.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/AzureStorageExplorer/releases/download/v1.43.0/StorageExplorer-windows-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: StorageExplorer-windows-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\StorageExplorer-windows-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: StorageExplorer-windows-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: StorageExplorer-windows-arm64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/AzureStorageExplorer/releases/download/v1.43.0/StorageExplorer-windows-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: StorageExplorer-windows-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.TemplateAnalyzer v0.8.5 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\TemplateAnalyzer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.TemplateAnalyzer v0.8.5" -ForegroundColor White

$FilePath = "$PkgDir\TemplateAnalyzer-win-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TemplateAnalyzer-win-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TemplateAnalyzer-win-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/template-analyzer/releases/download/v0.8.5/TemplateAnalyzer-win-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TemplateAnalyzer-win-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\TemplateAnalyzer-win-arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TemplateAnalyzer-win-arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TemplateAnalyzer-win-arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/template-analyzer/releases/download/v0.8.5/TemplateAnalyzer-win-arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TemplateAnalyzer-win-arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Azure.TrustedSigningClientTools v0.1.127 ===
$PkgDir = "$DownloadDir\Microsoft\Azure\TrustedSigningClientTools"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Azure.TrustedSigningClientTools v0.1.127" -ForegroundColor White

$FilePath = "$PkgDir\TrustedSigningClientTools.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TrustedSigningClientTools.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TrustedSigningClientTools.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6d9cb638-4d5f-438d-9f21-23f0f4405944/TrustedSigningClientTools.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TrustedSigningClientTools.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AzureCLI v2.85.0 ===
$PkgDir = "$DownloadDir\Microsoft\AzureCLI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AzureCLI v2.85.0" -ForegroundColor White

$FilePath = "$PkgDir\azure-cli-2.85.0.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azure-cli-2.85.0.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azure-cli-2.85.0.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.85.0.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azure-cli-2.85.0.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\azure-cli-2.85.0-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: azure-cli-2.85.0-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: azure-cli-2.85.0-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.85.0-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: azure-cli-2.85.0-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AzureMonitorAgent v1.41.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\AzureMonitorAgent"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AzureMonitorAgent v1.41.0.0" -ForegroundColor White

$FilePath = "$PkgDir\AzureMonitorAgentClientSetup.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureMonitorAgentClientSetup.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureMonitorAgentClientSetup.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7e4aea1a-060c-4e5a-9ea0-b89ded973c61/AzureMonitorAgentClientSetup.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureMonitorAgentClientSetup.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.AzureVPNClient v4.0.5.0 ===
$PkgDir = "$DownloadDir\Microsoft\AzureVPNClient"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.AzureVPNClient v4.0.5.0" -ForegroundColor White

$FilePath = "$PkgDir\AzVpnAppx_4.0.5.0_sideload.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzVpnAppx_4.0.5.0_sideload.zip (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzVpnAppx_4.0.5.0_sideload.zip (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1fa24e82-5a8b-41be-90a9-957b1064f51e/AzVpnAppx_4.0.5.0_sideload.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzVpnAppx_4.0.5.0_sideload.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.BTP v1.14.0 ===
$PkgDir = "$DownloadDir\Microsoft\BTP"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.BTP v1.14.0" -ForegroundColor White

$FilePath = "$PkgDir\BluetoothTestPlatformPack-1.14.0.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: BluetoothTestPlatformPack-1.14.0.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: BluetoothTestPlatformPack-1.14.0.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e/e/e/eeed3cd5-bdbd-47db-9b8e-ca9d2df2cd29/BluetoothTestPlatformPack-1.14.0.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: BluetoothTestPlatformPack-1.14.0.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Bicep v0.42.1 ===
$PkgDir = "$DownloadDir\Microsoft\Bicep"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Bicep v0.42.1" -ForegroundColor White

$FilePath = "$PkgDir\bicep-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: bicep-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: bicep-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: bicep-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\bicep-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: bicep-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: bicep-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: bicep-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\bicep-setup-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: bicep-setup-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: bicep-setup-win-x64.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-setup-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: bicep-setup-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5 ===
$PkgDir = "$DownloadDir\Microsoft\CLRTypesSQLServer\2019"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5" -ForegroundColor White

$FilePath = "$PkgDir\SQLSysClrTypes.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQLSysClrTypes.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQLSysClrTypes.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/d/d/1/dd194c5c-d859-49b8-ad64-5cbdcbb9b7bd/SQLSysClrTypes.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQLSysClrTypes.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.CertifiedToolAzureVM v1.6 ===
$PkgDir = "$DownloadDir\Microsoft\CertifiedToolAzureVM"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.CertifiedToolAzureVM v1.6" -ForegroundColor White

$FilePath = "$PkgDir\Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/a/f/1/af1bfced-edbf-4991-a78e-775ca8dab151/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.CmdPalAzureExtension v0.200.174.0 ===
$PkgDir = "$DownloadDir\Microsoft\CmdPalAzureExtension"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.CmdPalAzureExtension v0.200.174.0" -ForegroundColor White

$FilePath = "$PkgDir\AzureExtension_release_v0.200.174.0_x64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureExtension_release_v0.200.174.0_x64.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureExtension_release_v0.200.174.0_x64.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/CmdPalAzureExtension/releases/download/v0.200.174.0/AzureExtension_release_v0.200.174.0_x64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureExtension_release_v0.200.174.0_x64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\AzureExtension_release_v0.200.174.0_arm64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AzureExtension_release_v0.200.174.0_arm64.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AzureExtension_release_v0.200.174.0_arm64.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/CmdPalAzureExtension/releases/download/v0.200.174.0/AzureExtension_release_v0.200.174.0_arm64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AzureExtension_release_v0.200.174.0_arm64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.CmdPalGitHubExtension v0.103.178.0 ===
$PkgDir = "$DownloadDir\Microsoft\CmdPalGitHubExtension"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.CmdPalGitHubExtension v0.103.178.0" -ForegroundColor White

$FilePath = "$PkgDir\GitHubExtension_release_v0.103.178.0_x64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubExtension_release_v0.103.178.0_x64.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubExtension_release_v0.103.178.0_x64.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/CmdPalGitHubExtension/releases/download/v0.103.178.0/GitHubExtension_release_v0.103.178.0_x64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubExtension_release_v0.103.178.0_x64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\GitHubExtension_release_v0.103.178.0_arm64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GitHubExtension_release_v0.103.178.0_arm64.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GitHubExtension_release_v0.103.178.0_arm64.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/CmdPalGitHubExtension/releases/download/v0.103.178.0/GitHubExtension_release_v0.103.178.0_arm64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GitHubExtension_release_v0.103.178.0_arm64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DSC v3.1.3 ===
$PkgDir = "$DownloadDir\Microsoft\DSC"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DSC v3.1.3" -ForegroundColor White

$FilePath = "$PkgDir\DSC-3.1.3-Win.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DSC-3.1.3-Win.msixbundle (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DSC-3.1.3-Win.msixbundle (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-Win.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DSC-3.1.3-Win.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\DSC-3.1.3-x86_64-pc-windows-msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DSC-3.1.3-x86_64-pc-windows-msvc.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DSC-3.1.3-x86_64-pc-windows-msvc.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-x86_64-pc-windows-msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DSC-3.1.3-x86_64-pc-windows-msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\DSC-3.1.3-aarch64-pc-windows-msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DSC-3.1.3-aarch64-pc-windows-msvc.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DSC-3.1.3-aarch64-pc-windows-msvc.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-aarch64-pc-windows-msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DSC-3.1.3-aarch64-pc-windows-msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DTrace v2.0 ===
$PkgDir = "$DownloadDir\Microsoft\DTrace"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DTrace v2.0" -ForegroundColor White

$FilePath = "$PkgDir\DTrace.amd64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DTrace.amd64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DTrace.amd64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7/9/d/79d6b79a-5836-4118-a9b7-60bc77c97bf7/DTrace.amd64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DTrace.amd64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\DTrace.arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DTrace.arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DTrace.arm64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7/9/d/79d6b79a-5836-4118-a9b7-60bc77c97bf7/DTrace.arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DTrace.arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DataMigrationAssistant v5.8.5973.1 ===
$PkgDir = "$DownloadDir\Microsoft\DataMigrationAssistant"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DataMigrationAssistant v5.8.5973.1" -ForegroundColor White

$FilePath = "$PkgDir\DataMigrationAssistant.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DataMigrationAssistant.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DataMigrationAssistant.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/6/3/c63d8695-cef2-43c3-af0a-4989507e429b/DataMigrationAssistant.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DataMigrationAssistant.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DataTools.IntegrationServices v17.0.1010.2 ===
$PkgDir = "$DownloadDir\Microsoft\DataTools\IntegrationServices"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DataTools.IntegrationServices v17.0.1010.2" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.DataTools.IntegrationServices.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.DataTools.IntegrationServices.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.DataTools.IntegrationServices.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/2.1.2/1764774570388/Microsoft.DataTools.IntegrationServices.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.DataTools.IntegrationServices.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DebugDiag v2.3.2.11 ===
$PkgDir = "$DownloadDir\Microsoft\DebugDiag"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DebugDiag v2.3.2.11" -ForegroundColor White

$FilePath = "$PkgDir\DebugDiagx64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DebugDiagx64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DebugDiagx64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/9/3/a/93ae9fb0-2f2a-43f1-b0b5-5381b9f629ca/DebugDiagx64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DebugDiagx64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DefenderForCloud.CLI v2.0.03334.114 ===
$PkgDir = "$DownloadDir\Microsoft\DefenderForCloud\CLI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DefenderForCloud.CLI v2.0.03334.114" -ForegroundColor White

$FilePath = "$PkgDir\Defender_win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Defender_win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Defender_win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Defender_win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Defender_win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Defender_win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Defender_win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Defender_win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Defender_win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Defender_win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Defender_win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Defender_win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DependencyAgent v9.10.18 ===
$PkgDir = "$DownloadDir\Microsoft\DependencyAgent"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DependencyAgent v9.10.18" -ForegroundColor White

$FilePath = "$PkgDir\InstallDependencyAgent-Windows.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: InstallDependencyAgent-Windows.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: InstallDependencyAgent-Windows.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: InstallDependencyAgent-Windows.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DeploymentToolkit v6.3.8456.1000 ===
$PkgDir = "$DownloadDir\Microsoft\DeploymentToolkit"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DeploymentToolkit v6.3.8456.1000" -ForegroundColor White

$FilePath = "$PkgDir\MicrosoftDeploymentToolkit_x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftDeploymentToolkit_x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftDeploymentToolkit_x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftDeploymentToolkit_x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MicrosoftDeploymentToolkit_x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftDeploymentToolkit_x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftDeploymentToolkit_x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftDeploymentToolkit_x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DevSkim.CLI.DotNetTool v1.0.59 ===
$PkgDir = "$DownloadDir\Microsoft\DevSkim\CLI\DotNetTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DevSkim.CLI.DotNetTool v1.0.59" -ForegroundColor White

$FilePath = "$PkgDir\DevSkim_CLI_netcoreapp_1.0.59.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DevSkim_CLI_netcoreapp_1.0.59.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DevSkim_CLI_netcoreapp_1.0.59.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DevSkim/releases/download/v1.0.59/DevSkim_CLI_netcoreapp_1.0.59.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DevSkim_CLI_netcoreapp_1.0.59.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DevSkim.CLI.LibraryPackage v1.0.59 ===
$PkgDir = "$DownloadDir\Microsoft\DevSkim\CLI\LibraryPackage"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DevSkim.CLI.LibraryPackage v1.0.59" -ForegroundColor White

$FilePath = "$PkgDir\DevSkim_CLI_win_1.0.59.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DevSkim_CLI_win_1.0.59.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DevSkim_CLI_win_1.0.59.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DevSkim/releases/download/v1.0.59/DevSkim_CLI_win_1.0.59.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DevSkim_CLI_win_1.0.59.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DirectX v9.29.1974.0 ===
$PkgDir = "$DownloadDir\Microsoft\DirectX"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DirectX v9.29.1974.0" -ForegroundColor White

$FilePath = "$PkgDir\UAPSignedBinary_Microsoft.DirectX.x64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: UAPSignedBinary_Microsoft.DirectX.x64.appx (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: UAPSignedBinary_Microsoft.DirectX.x64.appx (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: UAPSignedBinary_Microsoft.DirectX.x64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\UAPSignedBinary_Microsoft.DirectX.x86.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: UAPSignedBinary_Microsoft.DirectX.x86.appx (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: UAPSignedBinary_Microsoft.DirectX.x86.appx (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x86.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: UAPSignedBinary_Microsoft.DirectX.x86.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dxwebsetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dxwebsetup.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dxwebsetup.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/7/1/1718ccc4-6315-4d8e-9543-8e28a4e18c4c/dxwebsetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dxwebsetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DirectXTex.Texassemble v2026.3.31 ===
$PkgDir = "$DownloadDir\Microsoft\DirectXTex\Texassemble"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DirectXTex.Texassemble v2026.3.31" -ForegroundColor White

$FilePath = "$PkgDir\texassemble.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texassemble.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texassemble.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texassemble.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\texassemble_arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texassemble_arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texassemble_arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texassemble_arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DirectXTex.Texconv v2026.3.31 ===
$PkgDir = "$DownloadDir\Microsoft\DirectXTex\Texconv"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DirectXTex.Texconv v2026.3.31" -ForegroundColor White

$FilePath = "$PkgDir\texconv.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texconv.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texconv.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texconv.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\texconv_arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texconv_arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texconv_arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texconv_arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DirectXTex.Texdiag v2026.3.31 ===
$PkgDir = "$DownloadDir\Microsoft\DirectXTex\Texdiag"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DirectXTex.Texdiag v2026.3.31" -ForegroundColor White

$FilePath = "$PkgDir\texdiag.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texdiag.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texdiag.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texdiag.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\texdiag_arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: texdiag_arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: texdiag_arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: texdiag_arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DiskSpd v2.2 ===
$PkgDir = "$DownloadDir\Microsoft\DiskSpd"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DiskSpd v2.2" -ForegroundColor White

$FilePath = "$PkgDir\DiskSpd.ZIP"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DiskSpd.ZIP (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DiskSpd.ZIP (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/diskspd/releases/download/v2.2/DiskSpd.ZIP" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DiskSpd.ZIP" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.AspNetCore.10 v10.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\AspNetCore\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.AspNetCore.10 v10.0.7" -ForegroundColor White

$FilePath = "$PkgDir\aspnetcore-runtime-10.0.7-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-10.0.7-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-10.0.7-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.AspNetCore.8 v8.0.26 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\AspNetCore\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.AspNetCore.8 v8.0.26" -ForegroundColor White

$FilePath = "$PkgDir\aspnetcore-runtime-8.0.26-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-8.0.26-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-8.0.26-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.AspNetCore.9 v9.0.15 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\AspNetCore\9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.AspNetCore.9 v9.0.15" -ForegroundColor White

$FilePath = "$PkgDir\aspnetcore-runtime-9.0.15-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-9.0.15-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\aspnetcore-runtime-9.0.15-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.DesktopRuntime.10 v10.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\DesktopRuntime\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.DesktopRuntime.10 v10.0.7" -ForegroundColor White

$FilePath = "$PkgDir\windowsdesktop-runtime-10.0.7-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-10.0.7-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-10.0.7-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.DesktopRuntime.8 v8.0.26 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\DesktopRuntime\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.DesktopRuntime.8 v8.0.26" -ForegroundColor White

$FilePath = "$PkgDir\windowsdesktop-runtime-8.0.26-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-8.0.26-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-8.0.26-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.DesktopRuntime.9 v9.0.15 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\DesktopRuntime\9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.DesktopRuntime.9 v9.0.15" -ForegroundColor White

$FilePath = "$PkgDir\windowsdesktop-runtime-9.0.15-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-9.0.15-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsdesktop-runtime-9.0.15-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Framework\DeveloperPack_4"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1" -ForegroundColor White

$FilePath = "$PkgDir\NDP481-DevPack-ENU.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: NDP481-DevPack-ENU.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: NDP481-DevPack-ENU.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/1/8/81877d8b-a9b2-4153-9ad2-63a6441d11dd/NDP481-DevPack-ENU.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: NDP481-DevPack-ENU.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Framework.Runtime v4.8.1 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Framework\Runtime"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Framework.Runtime v4.8.1" -ForegroundColor White

$FilePath = "$PkgDir\NDP481-x86-x64-AllOS-ENU.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: NDP481-x86-x64-AllOS-ENU.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: NDP481-x86-x64-AllOS-ENU.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/4/b/2/cd00d4ed-ebdd-49ee-8a33-eabc3d1030e3/NDP481-x86-x64-AllOS-ENU.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: NDP481-x86-x64-AllOS-ENU.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.HostingBundle.10 v10.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\HostingBundle\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.HostingBundle.10 v10.0.7" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-hosting-10.0.7-win.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-hosting-10.0.7-win.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-hosting-10.0.7-win.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/dotnet-hosting-10.0.7-win.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-hosting-10.0.7-win.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.HostingBundle.8 v8.0.26 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\HostingBundle\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.HostingBundle.8 v8.0.26" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-hosting-8.0.26-win.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-hosting-8.0.26-win.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-hosting-8.0.26-win.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/dotnet-hosting-8.0.26-win.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-hosting-8.0.26-win.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.HostingBundle.9 v9.0.15 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\HostingBundle\9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.HostingBundle.9 v9.0.15" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-hosting-9.0.15-win.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-hosting-9.0.15-win.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-hosting-9.0.15-win.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/dotnet-hosting-9.0.15-win.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-hosting-9.0.15-win.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Native.Runtime v2.2.28604.0 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Native\Runtime"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Native.Runtime v2.2.28604.0" -ForegroundColor White

$FilePath = "$PkgDir\Dependencies.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Dependencies.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Dependencies.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/busiotools/releases/download/v2.8.0/Dependencies.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Dependencies.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.RepairTool v1.4 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\RepairTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.RepairTool v1.4" -ForegroundColor White

$FilePath = "$PkgDir\NetFxRepairTool.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: NetFxRepairTool.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: NetFxRepairTool.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/b/d/2bde5459-2225-48b8-830c-ae19caf038f1/NetFxRepairTool.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: NetFxRepairTool.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Runtime.10 v10.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Runtime\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Runtime.10 v10.0.7" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-runtime-10.0.7-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-10.0.7-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-10.0.7-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-10.0.7-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-10.0.7-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-10.0.7-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-10.0.7-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-10.0.7-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-10.0.7-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Runtime.8 v8.0.26 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Runtime\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Runtime.8 v8.0.26" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-runtime-8.0.26-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-8.0.26-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-8.0.26-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-8.0.26-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-8.0.26-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-8.0.26-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-8.0.26-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-8.0.26-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-8.0.26-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.Runtime.9 v9.0.15 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\Runtime\9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.Runtime.9 v9.0.15" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-runtime-9.0.15-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-9.0.15-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-9.0.15-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-9.0.15-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-9.0.15-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-9.0.15-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-runtime-9.0.15-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-runtime-9.0.15-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-runtime-9.0.15-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.SDK.10 v10.0.203 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\SDK\10"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.SDK.10 v10.0.203" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-sdk-10.0.203-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-10.0.203-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-10.0.203-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-10.0.203-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-10.0.203-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-10.0.203-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-10.0.203-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-10.0.203-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-10.0.203-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.SDK.8 v8.0.420 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\SDK\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.SDK.8 v8.0.420" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-sdk-8.0.420-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-8.0.420-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-8.0.420-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-8.0.420-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-8.0.420-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-8.0.420-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-8.0.420-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-8.0.420-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-8.0.420-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.SDK.9 v9.0.313 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\SDK\9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.SDK.9 v9.0.313" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-sdk-9.0.313-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-9.0.313-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-9.0.313-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-9.0.313-win-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-9.0.313-win-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-9.0.313-win-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\dotnet-sdk-9.0.313-win-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-sdk-9.0.313-win-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-sdk-9.0.313-win-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.UninstallTool v1.7.661902 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\UninstallTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.UninstallTool v1.7.661902" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-core-uninstall.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-core-uninstall.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-core-uninstall.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/dotnet/cli-lab/releases/download/1.7.661902/dotnet-core-uninstall.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-core-uninstall.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.DotNet.dotnet-ef v10.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\DotNet\dotnet-ef"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.DotNet.dotnet-ef v10.0.7" -ForegroundColor White

$FilePath = "$PkgDir\dotnet-ef.10.0.7.nupkg"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: dotnet-ef.10.0.7.nupkg (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: dotnet-ef.10.0.7.nupkg (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://globalcdn.nuget.org/packages/dotnet-ef.10.0.7.nupkg" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: dotnet-ef.10.0.7.nupkg" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Edge v147.0.3912.98 ===
$PkgDir = "$DownloadDir\Microsoft\Edge"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Edge v147.0.3912.98" -ForegroundColor White

$FilePath = "$PkgDir\MicrosoftEdgeEnterpriseX86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeEnterpriseX86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeEnterpriseX86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/cfe18d3c-476a-4463-94b4-351752d72059/MicrosoftEdgeEnterpriseX86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeEnterpriseX86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MicrosoftEdgeEnterpriseX64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeEnterpriseX64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeEnterpriseX64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/33a7f26a-babe-4cfd-aa52-de77616e2850/MicrosoftEdgeEnterpriseX64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeEnterpriseX64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MicrosoftEdgeEnterpriseARM64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeEnterpriseARM64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeEnterpriseARM64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/5f4d4555-76af-4fcf-b620-090c8ba3da44/MicrosoftEdgeEnterpriseARM64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeEnterpriseARM64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.EdgeDriver v147.0.3912.98 ===
$PkgDir = "$DownloadDir\Microsoft\EdgeDriver"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.EdgeDriver v147.0.3912.98" -ForegroundColor White

$FilePath = "$PkgDir\edgedriver_win32.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: edgedriver_win32.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: edgedriver_win32.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedgedriver.microsoft.com/147.0.3912.98/edgedriver_win32.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: edgedriver_win32.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\edgedriver_win64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: edgedriver_win64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: edgedriver_win64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedgedriver.microsoft.com/147.0.3912.98/edgedriver_win64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: edgedriver_win64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\edgedriver_arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: edgedriver_arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: edgedriver_arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedgedriver.microsoft.com/147.0.3912.98/edgedriver_arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: edgedriver_arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.EdgeWebView2Runtime v147.0.3912.98 ===
$PkgDir = "$DownloadDir\Microsoft\EdgeWebView2Runtime"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.EdgeWebView2Runtime v147.0.3912.98" -ForegroundColor White

$FilePath = "$PkgDir\MicrosoftEdgeWebView2RuntimeInstallerX86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerX86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerX86.exe (x86/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/897cbefb-29fa-4846-94e9-20e01c74e00c/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerX86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerX64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerX64.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/f67cc405-2a0b-4df8-b641-023a0ee89f01/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerX64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MicrosoftEdgeWebView2RuntimeInstallerARM64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/bf488e2b-bbbe-437d-bab0-436107a31c14/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Edit v2.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\Edit"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Edit v2.0.0" -ForegroundColor White

$FilePath = "$PkgDir\edit-2.0.0-x86_64-windows.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: edit-2.0.0-x86_64-windows.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: edit-2.0.0-x86_64-windows.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/edit/releases/download/v2.0.0/edit-2.0.0-x86_64-windows.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: edit-2.0.0-x86_64-windows.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\edit-2.0.0-aarch64-windows.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: edit-2.0.0-aarch64-windows.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: edit-2.0.0-aarch64-windows.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/edit/releases/download/v2.0.0/edit-2.0.0-aarch64-windows.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: edit-2.0.0-aarch64-windows.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.EnterpriseStateClassify v1.0 ===
$PkgDir = "$DownloadDir\Microsoft\EnterpriseStateClassify"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.EnterpriseStateClassify v1.0" -ForegroundColor White

$FilePath = "$PkgDir\EnterpriseStateClassify.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: EnterpriseStateClassify.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: EnterpriseStateClassify.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/EnterpriseStateClassify/releases/download/v1.0/EnterpriseStateClassify.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: EnterpriseStateClassify.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.EventLogExpert v25.12.11.1105 ===
$PkgDir = "$DownloadDir\Microsoft\EventLogExpert"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.EventLogExpert v25.12.11.1105" -ForegroundColor White

$FilePath = "$PkgDir\EventLogExpert_25.12.11.1105_x64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: EventLogExpert_25.12.11.1105_x64.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: EventLogExpert_25.12.11.1105_x64.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/EventLogExpert/releases/download/v25.12.11.1105/EventLogExpert_25.12.11.1105_x64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: EventLogExpert_25.12.11.1105_x64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.FSLogix v3.26.126.19110 ===
$PkgDir = "$DownloadDir\Microsoft\FSLogix"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.FSLogix v3.26.126.19110" -ForegroundColor White

$FilePath = "$PkgDir\FSLogix_26.01_CU1.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: FSLogix_26.01_CU1.zip (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: FSLogix_26.01_CU1.zip (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e9eed5b4-83ff-4b93-bf87-765509e6fd85/FSLogix_26.01_CU1.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: FSLogix_26.01_CU1.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.FoundryLocal v0.8.119.102 ===
$PkgDir = "$DownloadDir\Microsoft\FoundryLocal"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.FoundryLocal v0.8.119.102" -ForegroundColor White

$FilePath = "$PkgDir\FoundryLocal-x64-0.8.119.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: FoundryLocal-x64-0.8.119.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: FoundryLocal-x64-0.8.119.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://foundry.onnxruntime.ai/FoundryLocal-x64-0.8.119.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: FoundryLocal-x64-0.8.119.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\FoundryLocal-arm64-0.8.119.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: FoundryLocal-arm64-0.8.119.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: FoundryLocal-arm64-0.8.119.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://foundry.onnxruntime.ai/FoundryLocal-arm64-0.8.119.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: FoundryLocal-arm64-0.8.119.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.FuzzyLookupAddExcel v1.3.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\FuzzyLookupAddExcel"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.FuzzyLookupAddExcel v1.3.0.0" -ForegroundColor White

$FilePath = "$PkgDir\Setup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Setup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Setup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/9/8/198838b0-4ddf-4a50-aae3-7210680c3be6/Setup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Setup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Garnet.DN8 v1.0.83 ===
$PkgDir = "$DownloadDir\Microsoft\Garnet\DN8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Garnet.DN8 v1.0.83" -ForegroundColor White

$FilePath = "$PkgDir\win-x64-based-readytorun.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-x64-based-readytorun.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-x64-based-readytorun.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-x64-based-readytorun.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-x64-based-readytorun.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\win-arm64-based-readytorun.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-arm64-based-readytorun.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-arm64-based-readytorun.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-arm64-based-readytorun.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-arm64-based-readytorun.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Garnet.DN9 v1.0.83 ===
$PkgDir = "$DownloadDir\Microsoft\Garnet\DN9"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Garnet.DN9 v1.0.83" -ForegroundColor White

$FilePath = "$PkgDir\win-x64-based-readytorun.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-x64-based-readytorun.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-x64-based-readytorun.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-x64-based-readytorun.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-x64-based-readytorun.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\win-arm64-based-readytorun.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-arm64-based-readytorun.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-arm64-based-readytorun.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-arm64-based-readytorun.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-arm64-based-readytorun.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Git v2.53.0.0.7 ===
$PkgDir = "$DownloadDir\Microsoft\Git"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Git v2.53.0.0.7" -ForegroundColor White

$FilePath = "$PkgDir\Git-2.53.0.vfs.0.7-64-bit.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Git-2.53.0.vfs.0.7-64-bit.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Git-2.53.0.vfs.0.7-64-bit.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/git/releases/download/v2.53.0.vfs.0.7/Git-2.53.0.vfs.0.7-64-bit.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Git-2.53.0.vfs.0.7-64-bit.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Git-2.53.0.vfs.0.7-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Git-2.53.0.vfs.0.7-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Git-2.53.0.vfs.0.7-arm64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/git/releases/download/v2.53.0.vfs.0.7/Git-2.53.0.vfs.0.7-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Git-2.53.0.vfs.0.7-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.GlobalSecureAccessClient v2.26.108 ===
$PkgDir = "$DownloadDir\Microsoft\GlobalSecureAccessClient"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.GlobalSecureAccessClient v2.26.108" -ForegroundColor White

$FilePath = "$PkgDir\GlobalSecureAccessClientArm64Installer"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: GlobalSecureAccessClientArm64Installer (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: GlobalSecureAccessClientArm64Installer (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.msappproxy.net/Subscription/b8795d5c-2a52-4259-9dc9-bff6eb3e15d7/Connector/GlobalSecureAccessClientArm64Installer" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: GlobalSecureAccessClientArm64Installer" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.HIDTools.Waratah v1.90 ===
$PkgDir = "$DownloadDir\Microsoft\HIDTools\Waratah"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.HIDTools.Waratah v1.90" -ForegroundColor White

$FilePath = "$PkgDir\Waratah-Published.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Waratah-Published.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Waratah-Published.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/hidtools/releases/download/Waratah-v1.90/Waratah-Published.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Waratah-Published.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.HwpConverter v15.0.4454.1506 ===
$PkgDir = "$DownloadDir\Microsoft\HwpConverter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.HwpConverter v15.0.4454.1506" -ForegroundColor White

$FilePath = "$PkgDir\HwpConverter_x86_en-us.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: HwpConverter_x86_en-us.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: HwpConverter_x86_en-us.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/1/A/11A1DF9C-D310-498E-B213-53758BFBF168/HwpConverter_x86_en-us.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: HwpConverter_x86_en-us.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\HwpConverter_x64_en-us.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: HwpConverter_x64_en-us.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: HwpConverter_x64_en-us.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/1/A/11A1DF9C-D310-498E-B213-53758BFBF168/HwpConverter_x64_en-us.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: HwpConverter_x64_en-us.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\HwpConverter_x86_ko-kr.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: HwpConverter_x86_ko-kr.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: HwpConverter_x86_ko-kr.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/B/F/8/BF8D9F34-A5BB-49AE-A58B-BC8F73DE0A16/HwpConverter_x86_ko-kr.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: HwpConverter_x86_ko-kr.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\HwpConverter_x64_ko-kr.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: HwpConverter_x64_ko-kr.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: HwpConverter_x64_ko-kr.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/B/F/8/BF8D9F34-A5BB-49AE-A58B-BC8F73DE0A16/HwpConverter_x64_ko-kr.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: HwpConverter_x64_ko-kr.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IIS.Compression v1.0.06502 ===
$PkgDir = "$DownloadDir\Microsoft\IIS\Compression"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IIS.Compression v1.0.06502" -ForegroundColor White

$FilePath = "$PkgDir\iiscompression_amd64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: iiscompression_amd64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: iiscompression_amd64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_amd64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: iiscompression_amd64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\iiscompression_x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: iiscompression_x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: iiscompression_x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: iiscompression_x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IIS.ServiceMonitor v2.0.1.10 ===
$PkgDir = "$DownloadDir\Microsoft\IIS\ServiceMonitor"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IIS.ServiceMonitor v2.0.1.10" -ForegroundColor White

$FilePath = "$PkgDir\ServiceMonitor.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ServiceMonitor.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ServiceMonitor.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/IIS.ServiceMonitor/releases/download/v2.0.1.10/ServiceMonitor.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ServiceMonitor.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IIS.URLRewrite v7.2.1993 ===
$PkgDir = "$DownloadDir\Microsoft\IIS\URLRewrite"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IIS.URLRewrite v7.2.1993" -ForegroundColor White

$FilePath = "$PkgDir\rewrite_amd64_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: rewrite_amd64_en-US.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: rewrite_amd64_en-US.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: rewrite_amd64_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\rewrite_x86_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: rewrite_x86_en-US.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: rewrite_x86_en-US.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/D/8/1/D81E5DD6-1ABB-46B0-9B4B-21894E18B77F/rewrite_x86_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: rewrite_x86_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IISManagerRemoteAdministration v1.2 ===
$PkgDir = "$DownloadDir\Microsoft\IISManagerRemoteAdministration"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IISManagerRemoteAdministration v1.2" -ForegroundColor White

$FilePath = "$PkgDir\inetmgr_amd64_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: inetmgr_amd64_en-US.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: inetmgr_amd64_en-US.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/4/3/24374C5F-95A3-41D5-B1DF-34D98FF610A3/inetmgr_amd64_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: inetmgr_amd64_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\inetmgr_x86_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: inetmgr_x86_en-US.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: inetmgr_x86_en-US.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/4/3/24374C5F-95A3-41D5-B1DF-34D98FF610A3/inetmgr_x86_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: inetmgr_x86_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IdFix v2.6.0.3 ===
$PkgDir = "$DownloadDir\Microsoft\IdFix"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IdFix v2.6.0.3" -ForegroundColor White

$FilePath = "$PkgDir\IdFix.Setup.2.6.0.3.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: IdFix.Setup.2.6.0.3.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: IdFix.Setup.2.6.0.3.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.2.6.0.3.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: IdFix.Setup.2.6.0.3.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IntegrationRuntime v5.65.9593.1 ===
$PkgDir = "$DownloadDir\Microsoft\IntegrationRuntime"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IntegrationRuntime v5.65.9593.1" -ForegroundColor White

$FilePath = "$PkgDir\IntegrationRuntime_5.65.9593.1.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: IntegrationRuntime_5.65.9593.1.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: IntegrationRuntime_5.65.9593.1.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e/4/7/e4771905-1079-445b-8bf9-8a1a075d8a10/IntegrationRuntime_5.65.9593.1.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: IntegrationRuntime_5.65.9593.1.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IntuneWSLPlugin v1.25.4.0 ===
$PkgDir = "$DownloadDir\Microsoft\IntuneWSLPlugin"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IntuneWSLPlugin v1.25.4.0" -ForegroundColor White

$FilePath = "$PkgDir\IntuneWSLPluginInstaller.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: IntuneWSLPluginInstaller.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: IntuneWSLPluginInstaller.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: IntuneWSLPluginInstaller.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.IronPython.3 v3.4.2.1000 ===
$PkgDir = "$DownloadDir\Microsoft\IronPython\3"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.IronPython.3 v3.4.2.1000" -ForegroundColor White

$FilePath = "$PkgDir\IronPython-3.4.2.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: IronPython-3.4.2.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: IronPython-3.4.2.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/IronLanguages/ironpython3/releases/download/v3.4.2/IronPython-3.4.2.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: IronPython-3.4.2.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Kanagawa v1.2.0 ===
$PkgDir = "$DownloadDir\Microsoft\Kanagawa"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Kanagawa v1.2.0" -ForegroundColor White

$FilePath = "$PkgDir\kanagawa-1.2.0-windows-x86_64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: kanagawa-1.2.0-windows-x86_64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: kanagawa-1.2.0-windows-x86_64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/kanagawa/releases/download/v1.2.0/kanagawa-1.2.0-windows-x86_64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: kanagawa-1.2.0-windows-x86_64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.LAPS v6.2.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\LAPS"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.LAPS v6.2.0.0" -ForegroundColor White

$FilePath = "$PkgDir\LAPS.x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LAPS.x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LAPS.x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LAPS.x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\LAPS.x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LAPS.x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LAPS.x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LAPS.x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\LAPS.arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LAPS.arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LAPS.arm64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LAPS.arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.LightGBM v4.6.0 ===
$PkgDir = "$DownloadDir\Microsoft\LightGBM"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.LightGBM v4.6.0" -ForegroundColor White

$FilePath = "$PkgDir\lightgbm.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: lightgbm.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: lightgbm.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/lightgbm-org/LightGBM/releases/download/v4.6.0/lightgbm.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: lightgbm.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.LingeringObjectLiquidator v2.0.21 ===
$PkgDir = "$DownloadDir\Microsoft\LingeringObjectLiquidator"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.LingeringObjectLiquidator v2.0.21" -ForegroundColor White

$FilePath = "$PkgDir\LingeringObjectLiquidatorInstaller.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LingeringObjectLiquidatorInstaller.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LingeringObjectLiquidatorInstaller.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b/a/a/baa58d37-f8d9-4a92-8321-15cab1deff51/LingeringObjectLiquidatorInstaller.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LingeringObjectLiquidatorInstaller.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.LogCheetah v1.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\LogCheetah"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.LogCheetah v1.0.0" -ForegroundColor White

$FilePath = "$PkgDir\LogCheetah-Windows.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LogCheetah-Windows.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LogCheetah-Windows.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/LogCheetah/releases/download/v1.0.0/LogCheetah-Windows.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LogCheetah-Windows.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.LogParser v2.2.10 ===
$PkgDir = "$DownloadDir\Microsoft\LogParser"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.LogParser v2.2.10" -ForegroundColor White

$FilePath = "$PkgDir\LogParser.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LogParser.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LogParser.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f/f/1/ff1819f9-f702-48a5-bbc7-c9656bc74de8/LogParser.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LogParser.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.M365AgentsPlayground v0.2.24 ===
$PkgDir = "$DownloadDir\Microsoft\M365AgentsPlayground"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.M365AgentsPlayground v0.2.24" -ForegroundColor White

$FilePath = "$PkgDir\agentsplayground-win32-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: agentsplayground-win32-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: agentsplayground-win32-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@0.2.24/agentsplayground-win32-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: agentsplayground-win32-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MFCMapi v26.0.26111.02 ===
$PkgDir = "$DownloadDir\Microsoft\MFCMapi"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MFCMapi v26.0.26111.02" -ForegroundColor White

$FilePath = "$PkgDir\MFCMAPI.exe.26.0.26111.02.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MFCMAPI.exe.26.0.26111.02.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MFCMAPI.exe.26.0.26111.02.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/mfcmapi/releases/download/26.0.26111.02/MFCMAPI.exe.26.0.26111.02.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MFCMAPI.exe.26.0.26111.02.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MFCMAPI.x64.exe.26.0.26111.02.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MFCMAPI.x64.exe.26.0.26111.02.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MFCMAPI.x64.exe.26.0.26111.02.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/mfcmapi/releases/download/26.0.26111.02/MFCMAPI.x64.exe.26.0.26111.02.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MFCMAPI.x64.exe.26.0.26111.02.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MIDI.FeatureEnablementChecker v1.1 ===
$PkgDir = "$DownloadDir\Microsoft\MIDI\FeatureEnablementChecker"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MIDI.FeatureEnablementChecker v1.1" -ForegroundColor White

$FilePath = "$PkgDir\midicheckservice_x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: midicheckservice_x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: midicheckservice_x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: midicheckservice_x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\midicheckservice_arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: midicheckservice_arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: midicheckservice_arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: midicheckservice_arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MIDI.SDK v1.0.16-rc.3.7 ===
$PkgDir = "$DownloadDir\Microsoft\MIDI\SDK"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MIDI.SDK v1.0.16-rc.3.7" -ForegroundColor White

$FilePath = "$PkgDir\Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MITT v8.03 ===
$PkgDir = "$DownloadDir\Microsoft\MITT"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MITT v8.03" -ForegroundColor White

$FilePath = "$PkgDir\MITT.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MITT.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MITT.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7/7/0/7703F03C-9D1F-45FC-A625-9647DC495EE2/MITT.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MITT.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MSIX-Toolkit v10.0.19041.1 ===
$PkgDir = "$DownloadDir\Microsoft\MSIX-Toolkit"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MSIX-Toolkit v10.0.19041.1" -ForegroundColor White

$FilePath = "$PkgDir\MSIX-Toolkit.x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSIX-Toolkit.x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSIX-Toolkit.x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSIX-Toolkit.x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MSIX-Toolkit.x86.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSIX-Toolkit.x86.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSIX-Toolkit.x86.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSIX-Toolkit.x86.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MSIXCore v1.2.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\MSIXCore"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MSIXCore v1.2.0.0" -ForegroundColor White

$FilePath = "$PkgDir\msixmgrSetup-1.2.0.0-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msixmgrSetup-1.2.0.0-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msixmgrSetup-1.2.0.0-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-1.2.0.0-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msixmgrSetup-1.2.0.0-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msixmgrSetup-1.2.0.0-x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msixmgrSetup-1.2.0.0-x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msixmgrSetup-1.2.0.0-x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-1.2.0.0-x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msixmgrSetup-1.2.0.0-x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msixmgr.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msixmgr.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msixmgr.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msixmgr.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MSIXPackagingTool v1.2024.405.0 ===
$PkgDir = "$DownloadDir\Microsoft\MSIXPackagingTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MSIXPackagingTool v1.2024.405.0" -ForegroundColor White

$FilePath = "$PkgDir\MSIXPackagingtoolv1.2024.405.0.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSIXPackagingtoolv1.2024.405.0.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSIXPackagingtoolv1.2024.405.0.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e/2/e/e2e923b2-7a3a-4730-969d-ab37001fbb5e/MSIXPackagingtoolv1.2024.405.0.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSIXPackagingtoolv1.2024.405.0.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MUTT v3.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\MUTT"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MUTT v3.0.0" -ForegroundColor White

$FilePath = "$PkgDir\MUTTPackage-3_0_0.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MUTTPackage-3_0_0.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MUTTPackage-3_0_0.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3856f445-db3d-4e15-ac03-622bfd453e12/MUTTPackage-3_0_0.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MUTTPackage-3_0_0.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MaliciousSoftwareRemovalTool v5.139 ===
$PkgDir = "$DownloadDir\Microsoft\MaliciousSoftwareRemovalTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MaliciousSoftwareRemovalTool v5.139" -ForegroundColor White

$FilePath = "$PkgDir\Windows-KB890830-V5.139.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows-KB890830-V5.139.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows-KB890830-V5.139.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/4/a/a/4aa524c6-239d-47ff-860b-5b397199cbf8/Windows-KB890830-V5.139.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows-KB890830-V5.139.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Windows-KB890830-x64-V5.139.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows-KB890830-x64-V5.139.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows-KB890830-x64-V5.139.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/c/5/2c563b99-54d9-4d85-a82b-45d3cd2f53ce/Windows-KB890830-x64-V2/c/5/2c563b99-54d9-4d85-a82b-45d3cd2f53ce/Windows-KB890830-x64-V5.139.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows-KB890830-x64-V5.139.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MediaCreationTool v10.0.26100.7019 ===
$PkgDir = "$DownloadDir\Microsoft\MediaCreationTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MediaCreationTool v10.0.26100.7019" -ForegroundColor White

$FilePath = "$PkgDir\MediaCreationTool.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MediaCreationTool.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MediaCreationTool.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/0a8b07d9-a3bf-47b9-b71b-8e13354cec88/MediaCreationTool.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MediaCreationTool.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MouseWithoutBorders v2.2.1.327 ===
$PkgDir = "$DownloadDir\Microsoft\MouseWithoutBorders"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MouseWithoutBorders v2.2.1.327" -ForegroundColor White

$FilePath = "$PkgDir\MouseWithoutBordersSetup.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MouseWithoutBordersSetup.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MouseWithoutBordersSetup.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/5/8/658AFC4C-DC02-4CB8-839D-10253E89FFF7/MouseWithoutBordersSetup.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MouseWithoutBordersSetup.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.MouseandKeyboardCenter v14.41.137.0 ===
$PkgDir = "$DownloadDir\Microsoft\MouseandKeyboardCenter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.MouseandKeyboardCenter v14.41.137.0" -ForegroundColor White

$FilePath = "$PkgDir\MouseKeyboardCenter_64bit_ENG_14.41.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MouseKeyboardCenter_64bit_ENG_14.41.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MouseKeyboardCenter_64bit_ENG_14.41.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_64bit_ENG_14.41.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MouseKeyboardCenter_64bit_ENG_14.41.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MouseKeyboardCenter_32bit_ENG_14.41.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MouseKeyboardCenter_32bit_ENG_14.41.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MouseKeyboardCenter_32bit_ENG_14.41.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_32bit_ENG_14.41.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MouseKeyboardCenter_32bit_ENG_14.41.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MouseKeyboardCenter_ARM64_ENG_14.41.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MouseKeyboardCenter_ARM64_ENG_14.41.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MouseKeyboardCenter_ARM64_ENG_14.41.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_ARM64_ENG_14.41.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MouseKeyboardCenter_ARM64_ENG_14.41.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Ntttcp v5.40.0.99012574 ===
$PkgDir = "$DownloadDir\Microsoft\Ntttcp"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Ntttcp v5.40.0.99012574" -ForegroundColor White

$FilePath = "$PkgDir\ntttcp.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ntttcp.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ntttcp.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/ntttcp/releases/download/v5.40/ntttcp.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ntttcp.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\ntttcp_arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ntttcp_arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ntttcp_arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/ntttcp/releases/download/v5.40/ntttcp_arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ntttcp_arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.NuGet v7.3.1 ===
$PkgDir = "$DownloadDir\Microsoft\NuGet"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.NuGet v7.3.1" -ForegroundColor White

$FilePath = "$PkgDir\nuget.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: nuget.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: nuget.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/v7.3.1/nuget.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: nuget.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OSCDIMG v2.56 ===
$PkgDir = "$DownloadDir\Microsoft\OSCDIMG"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OSCDIMG v2.56" -ForegroundColor White

$FilePath = "$PkgDir\oscdimg.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: oscdimg.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: oscdimg.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://msdl.microsoft.com/download/symbols/oscdimg.exe/688CABB065000/oscdimg.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: oscdimg.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OSConfig v1.3.10.13 ===
$PkgDir = "$DownloadDir\Microsoft\OSConfig"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OSConfig v1.3.10.13" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.OSConfig-1.3.10.13.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.OSConfig-1.3.10.13.msixbundle (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.OSConfig-1.3.10.13.msixbundle (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/Microsoft.OSConfig-1.3.10.13.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.OSConfig-1.3.10.13.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Office v16.0.19929.20062 ===
$PkgDir = "$DownloadDir\Microsoft\Office"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Office v16.0.19929.20062" -ForegroundColor White

$FilePath = "$PkgDir\setup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: setup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: setup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://officecdn.microsoft.com/pr/wsus/setup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: setup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OfficeDeploymentTool v16.0.19929.20062 ===
$PkgDir = "$DownloadDir\Microsoft\OfficeDeploymentTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OfficeDeploymentTool v16.0.19929.20062" -ForegroundColor White

$FilePath = "$PkgDir\officedeploymenttool_19929-20062.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: officedeploymenttool_19929-20062.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: officedeploymenttool_19929-20062.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19929-20062.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: officedeploymenttool_19929-20062.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OneDrive v26.063.0405.0002 ===
$PkgDir = "$DownloadDir\Microsoft\OneDrive"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OneDrive v26.063.0405.0002" -ForegroundColor White

$FilePath = "$PkgDir\OneDriveSetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: OneDriveSetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: OneDriveSetup.exe (x86/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://oneclient.sfx.ms/Win/Installers/26.063.0405.0002/OneDriveSetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: OneDriveSetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\OneDriveSetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: OneDriveSetup.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: OneDriveSetup.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://oneclient.sfx.ms/Win/Installers/26.063.0405.0002/amd64/OneDriveSetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: OneDriveSetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\OneDriveSetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: OneDriveSetup.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: OneDriveSetup.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://oneclient.sfx.ms/Win/Installers/26.063.0405.0002/arm64/OneDriveSetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: OneDriveSetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OneLakeFileExplorer v1.0.14.0 ===
$PkgDir = "$DownloadDir\Microsoft\OneLakeFileExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OneLakeFileExplorer v1.0.14.0" -ForegroundColor White

$FilePath = "$PkgDir\OneLake_PuPr_1.0.14.0.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: OneLake_PuPr_1.0.14.0.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: OneLake_PuPr_1.0.14.0.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/143fe9b7-9e20-4683-961e-656261c16943/OneLake_PuPr_1.0.14.0.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: OneLake_PuPr_1.0.14.0.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OneNoteDiagnostics v1.0.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\OneNoteDiagnostics"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OneNoteDiagnostics v1.0.0.0" -ForegroundColor White

$FilePath = "$PkgDir\onenotediagnosticsinstaller.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: onenotediagnosticsinstaller.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: onenotediagnosticsinstaller.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/9/a/7/9a798d60-ccb1-4b90-b612-8ea3745b7cbe/onenotediagnosticsinstaller.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: onenotediagnosticsinstaller.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenAPI.Hidi v3.1.2.0 ===
$PkgDir = "$DownloadDir\Microsoft\OpenAPI\Hidi"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenAPI.Hidi v3.1.2.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.OpenApi.Hidi.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.OpenApi.Hidi.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.OpenApi.Hidi.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/OpenAPI.NET/releases/download/v3.1.2/Microsoft.OpenApi.Hidi.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.OpenApi.Hidi.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenAPI.Kiota v1.30.0 ===
$PkgDir = "$DownloadDir\Microsoft\OpenAPI\Kiota"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenAPI.Kiota v1.30.0" -ForegroundColor White

$FilePath = "$PkgDir\win-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\win-x86.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-x86.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-x86.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-x86.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-x86.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\win-arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: win-arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: win-arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: win-arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\OpenCLGLVulkanCompatibilityPack"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0" -ForegroundColor White

$FilePath = "$PkgDir\Universal_D3DMappingLayers_1.2404.1.0_x64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Universal_D3DMappingLayers_1.2404.1.0_x64.appx (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Universal_D3DMappingLayers_1.2404.1.0_x64.appx (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/OpenCLOn12/releases/download/v1.2404.1.0/Universal_D3DMappingLayers_1.2404.1.0_x64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Universal_D3DMappingLayers_1.2404.1.0_x64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Universal_D3DMappingLayers_1.2404.1.0_arm64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/OpenCLOn12/releases/download/v1.2404.1.0/Universal_D3DMappingLayers_1.2404.1.0_arm64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenJDK.11 v11.0.31.11 ===
$PkgDir = "$DownloadDir\Microsoft\OpenJDK\11"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenJDK.11 v11.0.31.11" -ForegroundColor White

$FilePath = "$PkgDir\microsoft-JDK-11.0.31-windows-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-11.0.31-windows-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-11.0.31-windows-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-11.0.31-windows-x64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-11.0.31-windows-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\microsoft-JDK-11.0.31-windows-aarch64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-11.0.31-windows-aarch64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-11.0.31-windows-aarch64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-11.0.31-windows-aarch64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-11.0.31-windows-aarch64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenJDK.17 v17.0.18.8 ===
$PkgDir = "$DownloadDir\Microsoft\OpenJDK\17"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenJDK.17 v17.0.18.8" -ForegroundColor White

$FilePath = "$PkgDir\microsoft-JDK-17.0.18-windows-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-17.0.18-windows-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-17.0.18-windows-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-17.0.18-windows-x64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-17.0.18-windows-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\microsoft-JDK-17.0.18-windows-aarch64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-17.0.18-windows-aarch64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-17.0.18-windows-aarch64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-17.0.18-windows-aarch64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-17.0.18-windows-aarch64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenJDK.21 v21.0.10.7 ===
$PkgDir = "$DownloadDir\Microsoft\OpenJDK\21"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenJDK.21 v21.0.10.7" -ForegroundColor White

$FilePath = "$PkgDir\microsoft-JDK-21.0.10-windows-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-21.0.10-windows-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-21.0.10-windows-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-21.0.10-windows-x64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-21.0.10-windows-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\microsoft-JDK-21.0.10-windows-aarch64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-21.0.10-windows-aarch64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-21.0.10-windows-aarch64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-21.0.10-windows-aarch64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-21.0.10-windows-aarch64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.OpenJDK.25 v25.0.3.9 ===
$PkgDir = "$DownloadDir\Microsoft\OpenJDK\25"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.OpenJDK.25 v25.0.3.9" -ForegroundColor White

$FilePath = "$PkgDir\microsoft-JDK-25.0.3-windows-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-25.0.3-windows-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-25.0.3-windows-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-25.0.3-windows-x64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-25.0.3-windows-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\microsoft-JDK-25.0.3-windows-aarch64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: microsoft-JDK-25.0.3-windows-aarch64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: microsoft-JDK-25.0.3-windows-aarch64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/download-JDK/microsoft-JDK-25.0.3-windows-aarch64.msi#winget" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: microsoft-JDK-25.0.3-windows-aarch64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PICT v3.7.4.0 ===
$PkgDir = "$DownloadDir\Microsoft\PICT"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PICT v3.7.4.0" -ForegroundColor White

$FilePath = "$PkgDir\pict.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: pict.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: pict.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/pict/releases/download/v3.7.4/pict.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: pict.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PIX v2603.25 ===
$PkgDir = "$DownloadDir\Microsoft\PIX"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PIX v2603.25" -ForegroundColor White

$FilePath = "$PkgDir\PIX-2603.25-Installer-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PIX-2603.25-Installer-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PIX-2603.25-Installer-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6a45de18-2ba5-4702-9ab6-9fb654b57f90/PIX-2603.25-Installer-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PIX-2603.25-Installer-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PIX-2603.25-Installer-ARM64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PIX-2603.25-Installer-ARM64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PIX-2603.25-Installer-ARM64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6a45de18-2ba5-4702-9ab6-9fb654b57f90/PIX-2603.25-Installer-ARM64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PIX-2603.25-Installer-ARM64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Pave v0.1.1 ===
$PkgDir = "$DownloadDir\Microsoft\Pave"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Pave v0.1.1" -ForegroundColor White

$FilePath = "$PkgDir\pave-x86_64-pc-windows-msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: pave-x86_64-pc-windows-msvc.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: pave-x86_64-pc-windows-msvc.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/pave/releases/download/v0.1.1/pave-x86_64-pc-windows-msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: pave-x86_64-pc-windows-msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\pave-aarch64-pc-windows-msvc.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: pave-aarch64-pc-windows-msvc.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: pave-aarch64-pc-windows-msvc.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/pave/releases/download/v0.1.1/pave-aarch64-pc-windows-msvc.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: pave-aarch64-pc-windows-msvc.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PerfView v3.2.2 ===
$PkgDir = "$DownloadDir\Microsoft\PerfView"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PerfView v3.2.2" -ForegroundColor White

$FilePath = "$PkgDir\PerfView.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PerfView.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PerfView.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/perfview/releases/download/v3.2.2/PerfView.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PerfView.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerAppsCLI v1.0 ===
$PkgDir = "$DownloadDir\Microsoft\PowerAppsCLI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerAppsCLI v1.0" -ForegroundColor White

$FilePath = "$PkgDir\powerapps-cli-1.0.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: powerapps-cli-1.0.msi (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: powerapps-cli-1.0.msi (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/D/B/E/DBE69906-B4DA-471C-8960-092AB955C681/powerapps-cli-1.0.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: powerapps-cli-1.0.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerAutomateDesktop v2.67.00143.26090 ===
$PkgDir = "$DownloadDir\Microsoft\PowerAutomateDesktop"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerAutomateDesktop v2.67.00143.26090" -ForegroundColor White

$FilePath = "$PkgDir\Setup.Microsoft.PowerAutomate.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Setup.Microsoft.PowerAutomate.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Setup.Microsoft.PowerAutomate.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/09bdb359-3cc5-4f2e-af38-0b75897aa567/Setup.Microsoft.PowerAutomate.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Setup.Microsoft.PowerAutomate.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerAutomateProcessMining v6.1.2506.2252 ===
$PkgDir = "$DownloadDir\Microsoft\PowerAutomateProcessMining"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerAutomateProcessMining v6.1.2506.2252" -ForegroundColor White

$FilePath = "$PkgDir\PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/eead1132-ecfd-44e8-9e95-49996ed93c35/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerBI v2.153.910.0 ===
$PkgDir = "$DownloadDir\Microsoft\PowerBI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerBI v2.153.910.0" -ForegroundColor White

$FilePath = "$PkgDir\PBIDesktopSetup-2026-04_x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PBIDesktopSetup-2026-04_x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PBIDesktopSetup-2026-04_x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup-2026-04_x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PBIDesktopSetup-2026-04_x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerBIReportBuilder v15.7.1817.11 ===
$PkgDir = "$DownloadDir\Microsoft\PowerBIReportBuilder"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerBIReportBuilder v15.7.1817.11" -ForegroundColor White

$FilePath = "$PkgDir\PowerBIReportBuilder.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerBIReportBuilder.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerBIReportBuilder.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/a/2/e/a2ea07b5-5a65-41d7-9ac0-b46ac953ab63/PowerBIReportBuilder.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerBIReportBuilder.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerBIReportServer v1.25.9558.32914 ===
$PkgDir = "$DownloadDir\Microsoft\PowerBIReportServer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerBIReportServer v1.25.9558.32914" -ForegroundColor White

$FilePath = "$PkgDir\PowerBIReportServer.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerBIReportServer.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerBIReportServer.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/2/7/3/2739a88a-4769-4700-8748-1a01ddf60974/PowerBIReportServer.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerBIReportServer.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerShell v7.6.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\PowerShell"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerShell v7.6.1.0" -ForegroundColor White

$FilePath = "$PkgDir\PowerShell-7.6.1.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerShell-7.6.1.msixbundle (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerShell-7.6.1.msixbundle (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerShell-7.6.1.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerShell-7.6.1-win-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerShell-7.6.1-win-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerShell-7.6.1-win-x64.msi (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerShell-7.6.1-win-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerShell-7.6.1-win-x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerShell-7.6.1-win-x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerShell-7.6.1-win-x86.msi (x86/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerShell-7.6.1-win-x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerShell-7.6.1-win-arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerShell-7.6.1-win-arm64.msi (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerShell-7.6.1-win-arm64.msi (arm/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerShell-7.6.1-win-arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PowerToys v0.99.1 ===
$PkgDir = "$DownloadDir\Microsoft\PowerToys"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PowerToys v0.99.1" -ForegroundColor White

$FilePath = "$PkgDir\PowerToysUserSetup-0.99.1-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerToysUserSetup-0.99.1-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerToysUserSetup-0.99.1-x64.exe (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysUserSetup-0.99.1-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerToysUserSetup-0.99.1-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerToysSetup-0.99.1-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerToysSetup-0.99.1-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerToysSetup-0.99.1-x64.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysSetup-0.99.1-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerToysSetup-0.99.1-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerToysUserSetup-0.99.1-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerToysUserSetup-0.99.1-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerToysUserSetup-0.99.1-arm64.exe (arm64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysUserSetup-0.99.1-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerToysUserSetup-0.99.1-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PowerToysSetup-0.99.1-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PowerToysSetup-0.99.1-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PowerToysSetup-0.99.1-arm64.exe (arm64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysSetup-0.99.1-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PowerToysSetup-0.99.1-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PrintMetadataTroubleshooter v1.0.0.1 ===
$PkgDir = "$DownloadDir\Microsoft\PrintMetadataTroubleshooter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PrintMetadataTroubleshooter v1.0.0.1" -ForegroundColor White

$FilePath = "$PkgDir\PrintMetadataTroubleshooterX64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PrintMetadataTroubleshooterX64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PrintMetadataTroubleshooterX64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterX64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PrintMetadataTroubleshooterX64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PrintMetadataTroubleshooterX86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PrintMetadataTroubleshooterX86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PrintMetadataTroubleshooterX86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterX86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PrintMetadataTroubleshooterX86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PrintMetadataTroubleshooterArm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PrintMetadataTroubleshooterArm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PrintMetadataTroubleshooterArm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterArm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PrintMetadataTroubleshooterArm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\PrintMetadataTroubleshooterArm32.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PrintMetadataTroubleshooterArm32.exe (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PrintMetadataTroubleshooterArm32.exe (arm/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterArm32.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PrintMetadataTroubleshooterArm32.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ProfileExplorer v1.2.1 ===
$PkgDir = "$DownloadDir\Microsoft\ProfileExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ProfileExplorer v1.2.1" -ForegroundColor White

$FilePath = "$PkgDir\profile_explorer_installer_1.2.1_x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: profile_explorer_installer_1.2.1_x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: profile_explorer_installer_1.2.1_x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/profile-explorer/releases/download/v1.2.1/profile_explorer_installer_1.2.1_x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: profile_explorer_installer_1.2.1_x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\profile_explorer_installer_1.2.1_arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: profile_explorer_installer_1.2.1_arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: profile_explorer_installer_1.2.1_arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/profile-explorer/releases/download/v1.2.1/profile_explorer_installer_1.2.1_arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: profile_explorer_installer_1.2.1_arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ProjectTelescope v0.15.1 ===
$PkgDir = "$DownloadDir\Microsoft\ProjectTelescope"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ProjectTelescope v0.15.1" -ForegroundColor White

$FilePath = "$PkgDir\telescope-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: telescope-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: telescope-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/project-telescope/releases/download/v0.15.1/telescope-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: telescope-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\telescope-arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: telescope-arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: telescope-arm64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/project-telescope/releases/download/v0.15.1/telescope-arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: telescope-arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Promptflow v1.17.1 ===
$PkgDir = "$DownloadDir\Microsoft\Promptflow"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Promptflow v1.17.1" -ForegroundColor White

$FilePath = "$PkgDir\promptflow-1.17.1.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: promptflow-1.17.1.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: promptflow-1.17.1.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://promptflowartifact.blob.core.windows.net/msi-installer/promptflow-1.17.1.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: promptflow-1.17.1.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.PurviewInformationProtection v3.2.57.0 ===
$PkgDir = "$DownloadDir\Microsoft\PurviewInformationProtection"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.PurviewInformationProtection v3.2.57.0" -ForegroundColor White

$FilePath = "$PkgDir\PurviewInfoProtection.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PurviewInfoProtection.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PurviewInfoProtection.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5e62f7f5-d616-49f8-b506-f1c6b4f79ba7/PurviewInfoProtection.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PurviewInfoProtection.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.RMSClient v1.0.5406.9 ===
$PkgDir = "$DownloadDir\Microsoft\RMSClient"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.RMSClient v1.0.5406.9" -ForegroundColor White

$FilePath = "$PkgDir\setup_msipc_x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: setup_msipc_x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: setup_msipc_x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/c/f/3cf781f5-7d29-4035-9265-c34ff2369fa2/setup_msipc_x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: setup_msipc_x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\setup_msipc_x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: setup_msipc_x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: setup_msipc_x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/c/f/3cf781f5-7d29-4035-9265-c34ff2369fa2/setup_msipc_x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: setup_msipc_x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.RemoteDesktopClient v1.2.7099.0 ===
$PkgDir = "$DownloadDir\Microsoft\RemoteDesktopClient"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.RemoteDesktopClient v1.2.7099.0" -ForegroundColor White

$FilePath = "$PkgDir\RemoteDesktop_1.2.7099.0_x86.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_x86.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_x86.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/b9fc3474-6a78-4034-b4d7-441c5ccc4b75/RemoteDesktop_1.2.7099.0_x86.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_x86.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\RemoteDesktop_1.2.7099.0_x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/86a34a60-807d-4286-9204-79d252f6ac55/RemoteDesktop_1.2.7099.0_x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\RemoteDesktop_1.2.7099.0_ARM64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_ARM64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_ARM64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/761aa081-621a-4855-bdbc-bbf982b6b20a/RemoteDesktop_1.2.7099.0_ARM64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_ARM64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.RemoteDesktopMMRService v1.0.2507.21006 ===
$PkgDir = "$DownloadDir\Microsoft\RemoteDesktopMMRService"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.RemoteDesktopMMRService v1.0.2507.21006" -ForegroundColor White

$FilePath = "$PkgDir\MsMMRHostInstaller_1.0.2507.21006_x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MsMMRHostInstaller_1.0.2507.21006_x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MsMMRHostInstaller_1.0.2507.21006_x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_1.0.2507.21006_x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MsMMRHostInstaller_1.0.2507.21006_x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.RemoteHelp v5.1.1998.0 ===
$PkgDir = "$DownloadDir\Microsoft\RemoteHelp"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.RemoteHelp v5.1.1998.0" -ForegroundColor White

$FilePath = "$PkgDir\remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ReportBuilder v15.1.30001.02 ===
$PkgDir = "$DownloadDir\Microsoft\ReportBuilder"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ReportBuilder v15.1.30001.02" -ForegroundColor White

$FilePath = "$PkgDir\ReportBuilder.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ReportBuilder.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ReportBuilder.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/E/B/5EB40744-DC0A-47C0-8B0A-1830E74D3C23/ReportBuilder.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ReportBuilder.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SBOMTool v4.1.5 ===
$PkgDir = "$DownloadDir\Microsoft\SBOMTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SBOMTool v4.1.5" -ForegroundColor White

$FilePath = "$PkgDir\sbom-tool-win-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: sbom-tool-win-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: sbom-tool-win-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/sbom-tool/releases/download/v4.1.5/sbom-tool-win-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: sbom-tool-win-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2019.Developer v15.2204.5490.2 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2019\Developer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2019.Developer v15.2204.5490.2" -ForegroundColor White

$FilePath = "$PkgDir\SQL2019-SSEI-Dev.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2019-SSEI-Dev.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2019-SSEI-Dev.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/d/a/2/da259851-b941-459d-989c-54a18a5d44dd/SQL2019-SSEI-Dev.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2019-SSEI-Dev.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2019.Express v15.2204.5490.2 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2019\Express"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2019.Express v15.2204.5490.2" -ForegroundColor White

$FilePath = "$PkgDir\SQL2019-SSEI-Expr.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2019-SSEI-Expr.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2019-SSEI-Expr.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2019-SSEI-Expr.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2022.Developer v16.0.1000.6 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2022\Developer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2022.Developer v16.0.1000.6" -ForegroundColor White

$FilePath = "$PkgDir\SQL2022-SSEI-Dev.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2022-SSEI-Dev.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2022-SSEI-Dev.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c/c/9/cc9c6797-383c-4b24-8920-dc057c1de9d3/SQL2022-SSEI-Dev.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2022-SSEI-Dev.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2022.Express v16.0.1000.6 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2022\Express"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2022.Express v16.0.1000.6" -ForegroundColor White

$FilePath = "$PkgDir\SQL2022-SSEI-Expr.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2022-SSEI-Expr.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2022-SSEI-Expr.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/1/4/5145fe04-4d30-4b85-b0d1-39533663a2f1/SQL2022-SSEI-Expr.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2022-SSEI-Expr.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2025.Developer v17.0.1000.7 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2025\Developer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2025.Developer v17.0.1000.7" -ForegroundColor White

$FilePath = "$PkgDir\SQL2025-SSEI-StdDev.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2025-SSEI-StdDev.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2025-SSEI-StdDev.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/77dc60d3-0139-4dad-83c8-bb52ab22db01/SQL2025-SSEI-StdDev.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2025-SSEI-StdDev.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.2025.Express v17.0.1000.7 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\2025\Express"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.2025.Express v17.0.1000.7" -ForegroundColor White

$FilePath = "$PkgDir\SQL2025-SSEI-Expr.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SQL2025-SSEI-Expr.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SQL2025-SSEI-Expr.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7ab8f535-7eb8-4b16-82eb-eca0fa2d38f3/SQL2025-SSEI-Expr.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SQL2025-SSEI-Expr.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.OLEDBDriver v19.4.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\OLEDBDriver"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.OLEDBDriver v19.4.1.0" -ForegroundColor White

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b5865bb8-7bc6-4068-9c1d-fb77c256a865/amd64/1033/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/57d4f147-9469-4cff-b368-3f8e54bff9ef/amd64/1031/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c991431e-d91a-415e-95ef-1621cfcbd75f/amd64/1036/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/db361159-7835-4d2b-9f8b-43629518ccc7/amd64/1040/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/ff6ccd4d-eb33-4d32-bb7d-30d26946d55c/amd64/2052/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/ff5fc86c-a788-454f-b990-959533eb47b4/amd64/1028/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f9cc1edc-db28-4fc9-b90d-cb8392ebad60/amd64/1029/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/aae7ae93-05a9-4b84-9692-aeef824a46f2/amd64/1041/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/476609b7-b54b-415c-b260-b14b0a431ea6/amd64/1055/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/728f1f9a-26ca-40ca-8c89-0da3a769eb3a/amd64/3082/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/255462c2-0631-4132-bef9-696d88d3f643/amd64/1046/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/32ba0fe6-9d74-4dfc-b53d-d6f731050732/amd64/1045/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msoledbsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msoledbsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msoledbsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/d48c2ecf-9bf6-473c-b668-12b4955628d8/amd64/1042/msoledbsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msoledbsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServer.RMLUtilities v09.04.0103 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServer\RMLUtilities"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServer.RMLUtilities v09.04.0103" -ForegroundColor White

$FilePath = "$PkgDir\RMLSetup.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RMLSetup.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RMLSetup.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/5/8/65855c73-97a1-438c-b95e-d610a9bb05b0/RMLSetup.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RMLSetup.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SQLServerManagementStudio v20.2.1 ===
$PkgDir = "$DownloadDir\Microsoft\SQLServerManagementStudio"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SQLServerManagementStudio v20.2.1" -ForegroundColor White

$FilePath = "$PkgDir\SSMS-Setup-DEU.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-DEU.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-DEU.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-DEU.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-DEU.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-ENU.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-ENU.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-ENU.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ENU.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-ENU.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-ESN.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-ESN.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-ESN.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ESN.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-ESN.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-FRA.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-FRA.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-FRA.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-FRA.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-FRA.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-ITA.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-ITA.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-ITA.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ITA.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-ITA.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-JPN.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-JPN.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-JPN.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-JPN.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-JPN.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-KOR.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-KOR.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-KOR.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-KOR.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-KOR.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-PTB.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-PTB.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-PTB.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-PTB.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-PTB.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-RUS.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-RUS.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-RUS.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-RUS.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-RUS.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-CHS.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-CHS.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-CHS.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-CHS.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-CHS.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\SSMS-Setup-CHT.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SSMS-Setup-CHT.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SSMS-Setup-CHT.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-CHT.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SSMS-Setup-CHT.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SaRACmd v17.01.3954.000 ===
$PkgDir = "$DownloadDir\Microsoft\SaRACmd"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SaRACmd v17.01.3954.000" -ForegroundColor White

$FilePath = "$PkgDir\SaRACmd_17_01_3954_000.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SaRACmd_17_01_3954_000.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SaRACmd_17_01_3954_000.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/13eaffaa-0961-4a6a-863b-26d1f8b0ca15/SaRACmd_17_01_3954_000.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SaRACmd_17_01_3954_000.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SafetyScanner v1.449.54.0 ===
$PkgDir = "$DownloadDir\Microsoft\SafetyScanner"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SafetyScanner v1.449.54.0" -ForegroundColor White

$FilePath = "$PkgDir\msert.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msert.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msert.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://definitionupdates.microsoft.com/packages/content/msert.exe?packageType=Scanner&packageVersion=1.449.54.0&arch=x86" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msert.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msert.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msert.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msert.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://definitionupdates.microsoft.com/packages/content/msert.exe?packageType=Scanner&packageVersion=1.449.54.0&arch=amd64" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msert.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ScreenRecorder v0.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\ScreenRecorder"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ScreenRecorder v0.1.0" -ForegroundColor White

$FilePath = "$PkgDir\irexplorer-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: irexplorer-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: irexplorer-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/screenrecorder/releases/download/v0.1.0/irexplorer-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: irexplorer-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001 ===
$PkgDir = "$DownloadDir\Microsoft\SecurityComplianceToolkit\LGPO"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001" -ForegroundColor White

$FilePath = "$PkgDir\LGPO.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: LGPO.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: LGPO.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/LGPO.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: LGPO.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001 ===
$PkgDir = "$DownloadDir\Microsoft\SecurityComplianceToolkit\PolicyAnalyzer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001" -ForegroundColor White

$FilePath = "$PkgDir\PolicyAnalyzer.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: PolicyAnalyzer.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: PolicyAnalyzer.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/PolicyAnalyzer.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: PolicyAnalyzer.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001 ===
$PkgDir = "$DownloadDir\Microsoft\SecurityComplianceToolkit\SetObjectSecurity"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001" -ForegroundColor White

$FilePath = "$PkgDir\SetObjectSecurity.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SetObjectSecurity.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SetObjectSecurity.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/SetObjectSecurity.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SetObjectSecurity.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ServiceFabricRuntime v11.3.475.1 ===
$PkgDir = "$DownloadDir\Microsoft\ServiceFabricRuntime"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ServiceFabricRuntime v11.3.475.1" -ForegroundColor White

$FilePath = "$PkgDir\MicrosoftServiceFabric.11.3.475.1.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftServiceFabric.11.3.475.1.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftServiceFabric.11.3.475.1.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/MicrosoftServiceFabric.11.3.475.1.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftServiceFabric.11.3.475.1.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.ServiceFabricSDK v8.3.475 ===
$PkgDir = "$DownloadDir\Microsoft\ServiceFabricSDK"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.ServiceFabricSDK v8.3.475" -ForegroundColor White

$FilePath = "$PkgDir\MicrosoftServiceFabricSDK.8.3.475.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MicrosoftServiceFabricSDK.8.3.475.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MicrosoftServiceFabricSDK.8.3.475.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/MicrosoftServiceFabricSDK.8.3.475.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MicrosoftServiceFabricSDK.8.3.475.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SetupDiag v1.7.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\SetupDiag"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SetupDiag v1.7.0.0" -ForegroundColor White

$FilePath = "$PkgDir\SetupDiag.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SetupDiag.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SetupDiag.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1/1/1/111c347e-b7de-4510-8e62-a2f046efcc48/SetupDiag.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SetupDiag.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SmartDump v1.13 ===
$PkgDir = "$DownloadDir\Microsoft\SmartDump"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SmartDump v1.13" -ForegroundColor White

$FilePath = "$PkgDir\SmartDump_v1.13.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SmartDump_v1.13.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SmartDump_v1.13.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/SmartDump/releases/download/v1.13/SmartDump_v1.13.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SmartDump_v1.13.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SqlPackage v170.3.93 ===
$PkgDir = "$DownloadDir\Microsoft\SqlPackage"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SqlPackage v170.3.93" -ForegroundColor White

$FilePath = "$PkgDir\fwlink"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: fwlink (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: fwlink (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2350827" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: fwlink" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sqlcmd v1.9.0 ===
$PkgDir = "$DownloadDir\Microsoft\Sqlcmd"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sqlcmd v1.9.0" -ForegroundColor White

$FilePath = "$PkgDir\sqlcmd-amd64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: sqlcmd-amd64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: sqlcmd-amd64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-amd64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: sqlcmd-amd64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\sqlcmd-arm.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: sqlcmd-arm.msi (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: sqlcmd-arm.msi (arm/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-arm.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: sqlcmd-arm.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\sqlcmd-arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: sqlcmd-arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: sqlcmd-arm64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: sqlcmd-arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SurfaceApp v75.11130.117.0 ===
$PkgDir = "$DownloadDir\Microsoft\SurfaceApp"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SurfaceApp v75.11130.117.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1a91fe3e-b6be-465d-bda0-b8f12fd0fca7/Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SurfaceHubRecoveryTool v2.7.139.0 ===
$PkgDir = "$DownloadDir\Microsoft\SurfaceHubRecoveryTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SurfaceHubRecoveryTool v2.7.139.0" -ForegroundColor White

$FilePath = "$PkgDir\SurfaceHub_Recovery_v2.7.139.0.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SurfaceHub_Recovery_v2.7.139.0.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SurfaceHub_Recovery_v2.7.139.0.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/3/f/83fd5089-d14e-42e3-af7c-6fc36f80d347/SurfaceHub_Recovery_v2.7.139.0.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SurfaceHub_Recovery_v2.7.139.0.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.SymCryptUnitTest v103.8.0 ===
$PkgDir = "$DownloadDir\Microsoft\SymCryptUnitTest"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.SymCryptUnitTest v103.8.0" -ForegroundColor White

$FilePath = "$PkgDir\symcrypt-windows-amd64-release-103.8.0-53be637d.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: symcrypt-windows-amd64-release-103.8.0-53be637d.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: symcrypt-windows-amd64-release-103.8.0-53be637d.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/SymCrypt/releases/download/v103.8.0/symcrypt-windows-amd64-release-103.8.0-53be637d.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: symcrypt-windows-amd64-release-103.8.0-53be637d.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\symcrypt-windows-arm64-release-103.8.0-53be637d.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: symcrypt-windows-arm64-release-103.8.0-53be637d.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: symcrypt-windows-arm64-release-103.8.0-53be637d.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/SymCrypt/releases/download/v103.8.0/symcrypt-windows-arm64-release-103.8.0-53be637d.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: symcrypt-windows-arm64-release-103.8.0-53be637d.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Autologon v3.10 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Autologon"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Autologon v3.10" -ForegroundColor White

$FilePath = "$PkgDir\AutoLogon.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: AutoLogon.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: AutoLogon.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/AutoLogon.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: AutoLogon.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Autoruns v14.11 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Autoruns"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Autoruns v14.11" -ForegroundColor White

$FilePath = "$PkgDir\Autoruns.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Autoruns.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Autoruns.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Autoruns.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Autoruns.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.BGInfo v4.33 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\BGInfo"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.BGInfo v4.33" -ForegroundColor White

$FilePath = "$PkgDir\BGInfo.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: BGInfo.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: BGInfo.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/BGInfo.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: BGInfo.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Ctrl2Cap v3.0 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Ctrl2Cap"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Ctrl2Cap v3.0" -ForegroundColor White

$FilePath = "$PkgDir\Ctrl2Cap.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Ctrl2Cap.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Ctrl2Cap.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Ctrl2Cap.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Ctrl2Cap.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.DebugView v5.00 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\DebugView"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.DebugView v5.00" -ForegroundColor White

$FilePath = "$PkgDir\DebugView.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DebugView.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DebugView.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/DebugView.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DebugView.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Desktops v2.01 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Desktops"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Desktops v2.01" -ForegroundColor White

$FilePath = "$PkgDir\Desktops.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Desktops.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Desktops.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Desktops.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Desktops.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.FindLinks v1.1 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\FindLinks"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.FindLinks v1.1" -ForegroundColor White

$FilePath = "$PkgDir\FindLinks.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: FindLinks.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: FindLinks.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/FindLinks.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: FindLinks.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Handle v5.0 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Handle"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Handle v5.0" -ForegroundColor White

$FilePath = "$PkgDir\Handle.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Handle.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Handle.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Handle.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Handle.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.MoveFile v1.02 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\MoveFile"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.MoveFile v1.02" -ForegroundColor White

$FilePath = "$PkgDir\pendmoves.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: pendmoves.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: pendmoves.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/pendmoves.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: pendmoves.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.PendMoves v1.3 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\PendMoves"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.PendMoves v1.3" -ForegroundColor White

$FilePath = "$PkgDir\pendmoves.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: pendmoves.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: pendmoves.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/pendmoves.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: pendmoves.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.ProcessExplorer v17.11 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\ProcessExplorer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.ProcessExplorer v17.11" -ForegroundColor White

$FilePath = "$PkgDir\ProcessExplorer.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ProcessExplorer.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ProcessExplorer.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/ProcessExplorer.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ProcessExplorer.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.ProcessMonitor v4.01 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\ProcessMonitor"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.ProcessMonitor v4.01" -ForegroundColor White

$FilePath = "$PkgDir\ProcessMonitor.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ProcessMonitor.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ProcessMonitor.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/ProcessMonitor.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ProcessMonitor.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.RAMMap v1.63 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\RAMMap"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.RAMMap v1.63" -ForegroundColor White

$FilePath = "$PkgDir\RAMMap.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RAMMap.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RAMMap.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/RAMMap.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RAMMap.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.RDCMan v3.12 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\RDCMan"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.RDCMan v3.12" -ForegroundColor White

$FilePath = "$PkgDir\RDCMan.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RDCMan.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RDCMan.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/RDCMan.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RDCMan.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.RegJump v1.11 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\RegJump"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.RegJump v1.11" -ForegroundColor White

$FilePath = "$PkgDir\regjump.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: regjump.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: regjump.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/regjump.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: regjump.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.SDelete v2.06 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\SDelete"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.SDelete v2.06" -ForegroundColor White

$FilePath = "$PkgDir\SDelete.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: SDelete.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: SDelete.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/SDelete.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: SDelete.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Sigcheck v2.91 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Sigcheck"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Sigcheck v2.91" -ForegroundColor White

$FilePath = "$PkgDir\Sigcheck.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Sigcheck.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Sigcheck.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sigcheck.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Sigcheck.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Strings v2.54 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Strings"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Strings v2.54" -ForegroundColor White

$FilePath = "$PkgDir\Strings.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Strings.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Strings.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Strings.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Strings.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Sysmon v15.20 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Sysmon"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Sysmon v15.20" -ForegroundColor White

$FilePath = "$PkgDir\Sysmon.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Sysmon.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Sysmon.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Sysmon.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.TCPView v4.19 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\TCPView"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.TCPView v4.19" -ForegroundColor White

$FilePath = "$PkgDir\TCPView.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TCPView.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TCPView.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/TCPView.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TCPView.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.VMMap v3.40 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\VMMap"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.VMMap v3.40" -ForegroundColor White

$FilePath = "$PkgDir\VMMap.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VMMap.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VMMap.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/VMMap.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VMMap.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.Whois v1.21 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\Whois"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.Whois v1.21" -ForegroundColor White

$FilePath = "$PkgDir\WhoIs.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WhoIs.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WhoIs.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/WhoIs.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WhoIs.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Sysinternals.ZoomIt v11.00 ===
$PkgDir = "$DownloadDir\Microsoft\Sysinternals\ZoomIt"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Sysinternals.ZoomIt v11.00" -ForegroundColor White

$FilePath = "$PkgDir\ZoomIt.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ZoomIt.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ZoomIt.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.sysinternals.com/files/ZoomIt.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ZoomIt.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.TeamMate v0.1.15 ===
$PkgDir = "$DownloadDir\Microsoft\TeamMate"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.TeamMate v0.1.15" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.Tools.TeamMate.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.Tools.TeamMate.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.Tools.TeamMate.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/TeamMate/releases/download/0.1.15%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.Tools.TeamMate.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Teams v26093.415.4620.1935 ===
$PkgDir = "$DownloadDir\Microsoft\Teams"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Teams v26093.415.4620.1935" -ForegroundColor White

$FilePath = "$PkgDir\MSTeams-x86.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSTeams-x86.msix (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSTeams-x86.msix (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://installer.teams.static.microsoft/production-windows-x86/26093.415.4620.1935/MSTeams-x86.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSTeams-x86.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MSTeams-x64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSTeams-x64.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSTeams-x64.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://installer.teams.static.microsoft/production-windows-x64/26093.415.4620.1935/MSTeams-x64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSTeams-x64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\MSTeams-arm64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: MSTeams-arm64.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: MSTeams-arm64.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://installer.teams.static.microsoft/production-windows-arm64/26093.415.4620.1935/MSTeams-arm64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: MSTeams-arm64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.TeamsTxNDI v2024.8.1.14 ===
$PkgDir = "$DownloadDir\Microsoft\TeamsTxNDI"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.TeamsTxNDI v2024.8.1.14" -ForegroundColor White

$FilePath = "$PkgDir\ndi-win-x64_vs2022-crtdynamic-release.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: ndi-win-x64_vs2022-crtdynamic-release.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: ndi-win-x64_vs2022-crtdynamic-release.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://teams.microsoft.com/core-calling-lib/2024.8.1.14/ndi-win-x64_vs2022-crtdynamic-release.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: ndi-win-x64_vs2022-crtdynamic-release.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.TimeTravelDebugging v1.11.584.0 ===
$PkgDir = "$DownloadDir\Microsoft\TimeTravelDebugging"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.TimeTravelDebugging v1.11.584.0" -ForegroundColor White

$FilePath = "$PkgDir\TTD.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TTD.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TTD.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TTD.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Tokenizer v1.3.3 ===
$PkgDir = "$DownloadDir\Microsoft\Tokenizer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Tokenizer v1.3.3" -ForegroundColor White

$FilePath = "$PkgDir\Tokenizer.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Tokenizer.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Tokenizer.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/Tokenizer/releases/download/v1.3.3/Tokenizer.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Tokenizer.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.UI.Xaml.2.7 v7.2208.15002.0 ===
$PkgDir = "$DownloadDir\Microsoft\UI\Xaml\2\7"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.UI.Xaml.2.7 v7.2208.15002.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.7.x64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.x64.appx (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.x64.appx (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.x64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.7.x86.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.x86.appx (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.x86.appx (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x86.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.x86.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.7.arm.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.arm.appx (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.arm.appx (arm/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.arm.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.arm.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.7.arm64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.arm64.appx (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.arm64.appx (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.arm64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.arm64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.UI.Xaml.2.8 v8.2310.30001.0 ===
$PkgDir = "$DownloadDir\Microsoft\UI\Xaml\2\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.UI.Xaml.2.8 v8.2310.30001.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.8.x64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.x64.appx (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.x64.appx (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.x64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.8.x86.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.x86.appx (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.x86.appx (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x86.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.x86.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.8.arm.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.arm.appx (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.arm.appx (arm/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.arm.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.arm.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.UI.Xaml.2.8.arm64.appx"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.arm64.appx (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.arm64.appx (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.arm64.appx" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.arm64.appx" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.UpdateAssistant v1.4.19041.2183 ===
$PkgDir = "$DownloadDir\Microsoft\UpdateAssistant"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.UpdateAssistant v1.4.19041.2183" -ForegroundColor White

$FilePath = "$PkgDir\Windows10Upgrade9252.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows10Upgrade9252.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows10Upgrade9252.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/4/8/3/483976ae-b4b1-490d-bd5f-74fdc44bb84e/Windows10Upgrade9252.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows10Upgrade9252.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VCLibs.14 v14.0.33519.0 ===
$PkgDir = "$DownloadDir\Microsoft\VCLibs\14"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VCLibs.14 v14.0.33519.0" -ForegroundColor White

$FilePath = "$PkgDir\DesktopAppInstaller_Dependencies.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DesktopAppInstaller_Dependencies.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DesktopAppInstaller_Dependencies.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.12.350/DesktopAppInstaller_Dependencies.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DesktopAppInstaller_Dependencies.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VCLibs.Desktop.14 v14.0.33728.0 ===
$PkgDir = "$DownloadDir\Microsoft\VCLibs\Desktop\14"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VCLibs.Desktop.14 v14.0.33728.0" -ForegroundColor White

$FilePath = "$PkgDir\DesktopAppInstaller_Dependencies.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: DesktopAppInstaller_Dependencies.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: DesktopAppInstaller_Dependencies.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/download/v1.9.25180/DesktopAppInstaller_Dependencies.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: DesktopAppInstaller_Dependencies.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VCRedist.2015+.arm64 v14.50.35719.0 ===
$PkgDir = "$DownloadDir\Microsoft\VCRedist\2015+\arm64"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VCRedist.2015+.arm64 v14.50.35719.0" -ForegroundColor White

$FilePath = "$PkgDir\VC_redist.arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VC_redist.arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VC_redist.arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/FCDA7B24413F170BD456052F08AE49FB60AC1638F083AAB7A35AFEB957AEB1D6/VC_redist.arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VC_redist.arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VCRedist.2015+.x64 v14.50.35719.0 ===
$PkgDir = "$DownloadDir\Microsoft\VCRedist\2015+\x64"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VCRedist.2015+.x64 v14.50.35719.0" -ForegroundColor White

$FilePath = "$PkgDir\VC_redist.x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VC_redist.x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VC_redist.x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/8995548DFFFCDE7C49987029C764355612BA6850EE09A7B6F0FDDC85BDC5C280/VC_redist.x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VC_redist.x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VCRedist.2015+.x86 v14.50.35719.0 ===
$PkgDir = "$DownloadDir\Microsoft\VCRedist\2015+\x86"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VCRedist.2015+.x86 v14.50.35719.0" -ForegroundColor White

$FilePath = "$PkgDir\VC_redist.x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VC_redist.x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VC_redist.x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/E7267C1BDF9237C0B4A28CF027C382B97AA909934F84F1C92D3FB9F04173B33E/VC_redist.x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VC_redist.x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VSDotNetLogCollect v17.0.35214.149 ===
$PkgDir = "$DownloadDir\Microsoft\VSDotNetLogCollect"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VSDotNetLogCollect v17.0.35214.149" -ForegroundColor White

$FilePath = "$PkgDir\Collect.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Collect.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Collect.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8/3/4/834e83f6-c377-4dce-a757-69a418b6c6df/Collect.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Collect.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VSIXBootstrapper v1.0.37 ===
$PkgDir = "$DownloadDir\Microsoft\VSIXBootstrapper"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VSIXBootstrapper v1.0.37" -ForegroundColor White

$FilePath = "$PkgDir\VSIXBootstrapper.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSIXBootstrapper.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSIXBootstrapper.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSIXBootstrapper.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VSTOR v10.0.60917 ===
$PkgDir = "$DownloadDir\Microsoft\VSTOR"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VSTOR v10.0.60917" -ForegroundColor White

$FilePath = "$PkgDir\vstor_redist.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: vstor_redist.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: vstor_redist.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5/d/2/5d24f8f8-efbb-4b63-aa33-3785e3104713/vstor_redist.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: vstor_redist.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisioViewer v16.0.4339.1001 ===
$PkgDir = "$DownloadDir\Microsoft\VisioViewer"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisioViewer v16.0.4339.1001" -ForegroundColor White

$FilePath = "$PkgDir\visioviewer_4339-1001_x64_en-us.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: visioviewer_4339-1001_x64_en-us.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: visioviewer_4339-1001_x64_en-us.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/D/B/7/DB790874-4414-417F-ADF6-348B29572B9F/visioviewer_4339-1001_x64_en-us.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: visioviewer_4339-1001_x64_en-us.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\visioviewer_4339-1001_x86_en-us.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: visioviewer_4339-1001_x86_en-us.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: visioviewer_4339-1001_x86_en-us.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/D/B/7/DB790874-4414-417F-ADF6-348B29572B9F/visioviewer_4339-1001_x86_en-us.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: visioviewer_4339-1001_x86_en-us.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.2022.BuildTools v17.14.31 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\2022\BuildTools"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.2022.BuildTools v17.14.31" -ForegroundColor White

$FilePath = "$PkgDir\vs_BuildTools.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: vs_BuildTools.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: vs_BuildTools.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/b25d20faf12653a27421e4209daadfeb81aa44e9339d160541bb806e13e8769a/vs_BuildTools.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: vs_BuildTools.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.2022.Enterprise v17.14.31 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\2022\Enterprise"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.2022.Enterprise v17.14.31" -ForegroundColor White

$FilePath = "$PkgDir\vs_Enterprise.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: vs_Enterprise.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: vs_Enterprise.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/824a8a0817e4102c9ffa0573844a8b1f1686dd181405c2ef746ee07ea47793b9/vs_Enterprise.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: vs_Enterprise.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\2022\OnecoreMsvsmon"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6" -ForegroundColor White

$FilePath = "$PkgDir\onecore.msvsmon.x86.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: onecore.msvsmon.x86.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: onecore.msvsmon.x86.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/75fb7124f0b39172b065e21ba2f73c39d15c03dc81f7b96432b4c3e4206b4be6/onecore.msvsmon.x86.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: onecore.msvsmon.x86.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\onecore.msvsmon.amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: onecore.msvsmon.amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: onecore.msvsmon.amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/c9792d0f4326ed8e812574df5b94ff06ceb9430e101e041e000e040cb78b536c/onecore.msvsmon.amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: onecore.msvsmon.amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\onecore.msvsmon.arm.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: onecore.msvsmon.arm.zip (arm)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: onecore.msvsmon.arm.zip (arm/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/02cae74d5964feb48ff68a9490f06346ac722b7ff22f98833969cca0191ed35e/onecore.msvsmon.arm.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: onecore.msvsmon.arm.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\onecore.msvsmon.arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: onecore.msvsmon.arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: onecore.msvsmon.arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/8d1b5d05fa95cf9bac2aac9c3effbffd32341a4a37ed4a5d22f5291bb236152d/onecore.msvsmon.arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: onecore.msvsmon.arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.2022.Professional v17.14.31 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\2022\Professional"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.2022.Professional v17.14.31" -ForegroundColor White

$FilePath = "$PkgDir\vs_Professional.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: vs_Professional.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: vs_Professional.exe (x64/machine)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/08809dcedf390bf3ba2349b382ae9bac948b9f716760934d29a9d6437afae16d/vs_Professional.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: vs_Professional.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.2022.RemoteTools v17.14.8 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\2022\RemoteTools"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.2022.RemoteTools v17.14.8" -ForegroundColor White

$FilePath = "$PkgDir\VS_RemoteTools.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VS_RemoteTools.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VS_RemoteTools.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/ee861ad443f2b2f9c38e8f88da972534714100a261894199b453103ec78b229d/VS_RemoteTools.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VS_RemoteTools.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\VS_RemoteTools.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VS_RemoteTools.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VS_RemoteTools.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/4f3a9bb0ac443eff807c8ff04fad7683e98acfe67c0bc293da89cc673e1186a3/VS_RemoteTools.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VS_RemoteTools.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\VS_RemoteTools.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VS_RemoteTools.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VS_RemoteTools.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/fa1d6c1c2dc4fd97889c1f76ebdb50fa040ece18a2f6d63b2cfc09809d20b74a/VS_RemoteTools.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VS_RemoteTools.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.ConfigFinder v1.0.47.55350 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\ConfigFinder"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.ConfigFinder v1.0.47.55350" -ForegroundColor White

$FilePath = "$PkgDir\VSConfigFinder.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: VSConfigFinder.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: VSConfigFinder.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/VSConfigFinder/releases/download/1.0.47-beta/VSConfigFinder.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: VSConfigFinder.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.Extensions.TypeScript v4.3 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\Extensions\TypeScript"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.Extensions.TypeScript v4.3" -ForegroundColor White

$FilePath = "$PkgDir\TypeScript_SDK_4.3.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: TypeScript_SDK_4.3.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: TypeScript_SDK_4.3.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/1622050134497/TypeScript_SDK_4.3.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: TypeScript_SDK_4.3.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.VisualStudio.Locator v3.1.7 ===
$PkgDir = "$DownloadDir\Microsoft\VisualStudio\Locator"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualStudio.Locator v3.1.7" -ForegroundColor White

$FilePath = "$PkgDir\vswhere.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: vswhere.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: vswhere.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/vswhere/releases/download/3.1.7/vswhere.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: vswhere.exe" -ForegroundColor Red
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

# === Microsoft.VisualTrueType v6.35 ===
$PkgDir = "$DownloadDir\Microsoft\VisualTrueType"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.VisualTrueType v6.35" -ForegroundColor White

$FilePath = "$PkgDir\release_binary.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: release_binary.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: release_binary.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/VisualTrueType/releases/download/v0.0.7/release_binary.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: release_binary.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WSL v2.6.3 ===
$PkgDir = "$DownloadDir\Microsoft\WSL"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WSL v2.6.3" -ForegroundColor White

$FilePath = "$PkgDir\wsl.2.6.3.0.x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wsl.2.6.3.0.x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wsl.2.6.3.0.x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wsl.2.6.3.0.x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/WSL/releases/download/2.6.3/Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\wsl.2.6.3.0.arm64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wsl.2.6.3.0.arm64.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wsl.2.6.3.0.arm64.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.arm64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wsl.2.6.3.0.arm64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Wassette v0.4.0 ===
$PkgDir = "$DownloadDir\Microsoft\Wassette"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Wassette v0.4.0" -ForegroundColor White

$FilePath = "$PkgDir\wassette_0.4.0_windows_amd64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wassette_0.4.0_windows_amd64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wassette_0.4.0_windows_amd64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/wassette/releases/download/v0.4.0/wassette_0.4.0_windows_amd64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wassette_0.4.0_windows_amd64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\wassette_0.4.0_windows_arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wassette_0.4.0_windows_arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wassette_0.4.0_windows_arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/wassette/releases/download/v0.4.0/wassette_0.4.0_windows_arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wassette_0.4.0_windows_arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WebDeploy v10.0.2001 ===
$PkgDir = "$DownloadDir\Microsoft\WebDeploy"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WebDeploy v10.0.2001" -ForegroundColor White

$FilePath = "$PkgDir\WebDeploy_x86_zh-TW.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_zh-TW.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_zh-TW.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_zh-TW.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_zh-TW.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_zh-CN.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_zh-CN.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_zh-CN.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_zh-CN.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_zh-CN.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_tr-TR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_tr-TR.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_tr-TR.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_tr-TR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_tr-TR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_ru-RU.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_ru-RU.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_ru-RU.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_ru-RU.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_ru-RU.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_pt-BR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_pt-BR.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_pt-BR.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_pt-BR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_pt-BR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_pl-PL.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_pl-PL.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_pl-PL.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_pl-PL.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_pl-PL.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_ko-KR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_ko-KR.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_ko-KR.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_ko-KR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_ko-KR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_ja-JP.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_ja-JP.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_ja-JP.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_ja-JP.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_ja-JP.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_it-IT.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_it-IT.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_it-IT.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_it-IT.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_it-IT.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_fr-FR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_fr-FR.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_fr-FR.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_fr-FR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_fr-FR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_es-ES.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_es-ES.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_es-ES.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_es-ES.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_es-ES.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_de-DE.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_de-DE.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_de-DE.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_de-DE.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_de-DE.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_en-US.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_en-US.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WebDeploy_x86_cs-CZ.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WebDeploy_x86_cs-CZ.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WebDeploy_x86_cs-CZ.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WebDeploy_x86_cs-CZ.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_zh-TW.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_zh-TW.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_zh-TW.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_zh-TW.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_zh-CN.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_zh-CN.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_zh-CN.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_zh-CN.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_zh-CN.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_tr-TR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_tr-TR.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_tr-TR.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_tr-TR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_tr-TR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_ru-RU.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_ru-RU.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_ru-RU.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_ru-RU.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_ru-RU.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_pt-BR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_pt-BR.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_pt-BR.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_pt-BR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_pt-BR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_pl-PL.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_pl-PL.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_pl-PL.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_pl-PL.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_pl-PL.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_ko-KR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_ko-KR.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_ko-KR.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_ko-KR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_ko-KR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_ja-JP.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_ja-JP.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_ja-JP.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_ja-JP.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_ja-JP.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_it-IT.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_it-IT.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_it-IT.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_it-IT.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_it-IT.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_fr-FR.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_fr-FR.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_fr-FR.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_fr-FR.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_fr-FR.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_es-ES.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_es-ES.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_es-ES.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_es-ES.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_es-ES.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_de-DE.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_de-DE.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_de-DE.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_de-DE.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_de-DE.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_en-US.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_en-US.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_en-US.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_en-US.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_en-US.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\webdeploy_amd64_cs-CZ.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: webdeploy_amd64_cs-CZ.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: webdeploy_amd64_cs-CZ.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: webdeploy_amd64_cs-CZ.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.Win32ContentPrepTool v1.8.7 ===
$PkgDir = "$DownloadDir\Microsoft\Win32ContentPrepTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.Win32ContentPrepTool v1.8.7" -ForegroundColor White

$FilePath = "$PkgDir\v1.8.7.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: v1.8.7.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: v1.8.7.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/v1.8.7.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: v1.8.7.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WinAppCli v0.3.1 ===
$PkgDir = "$DownloadDir\Microsoft\WinAppCli"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WinAppCli v0.3.1" -ForegroundColor White

$FilePath = "$PkgDir\winappcli_x64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: winappcli_x64.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: winappcli_x64.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winappCli/releases/download/v0.3.1/winappcli_x64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: winappcli_x64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\winappcli_arm64.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: winappcli_arm64.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: winappcli_arm64.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winappCli/releases/download/v0.3.1/winappcli_arm64.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: winappcli_arm64.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WinDbg v1.2603.20001.0 ===
$PkgDir = "$DownloadDir\Microsoft\WinDbg"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WinDbg v1.2603.20001.0" -ForegroundColor White

$FilePath = "$PkgDir\windbg.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windbg.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windbg.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windbg.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsADK v10.1.28000.1 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsADK"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsADK v10.1.28000.1" -ForegroundColor White

$FilePath = "$PkgDir\adksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: adksetup.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: adksetup.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/615540bc-be0b-433a-b91b-1f2b0642bb24/adk/adksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: adksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsAdminCenter v2.6.6.18 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsAdminCenter"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsAdminCenter v2.6.6.18" -ForegroundColor White

$FilePath = "$PkgDir\WindowsAdminCenter2511.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsAdminCenter2511.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsAdminCenter2511.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/5e854024-dcf1-4e86-9546-7389fd08a34b/WindowsAdminCenter2511.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsAdminCenter2511.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsApp v2.0.1071.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsApp"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsApp v2.0.1071.0" -ForegroundColor White

$FilePath = "$PkgDir\WindowsApp_x86_Release_2.0.1071.0.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsApp_x86_Release_2.0.1071.0.msix (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsApp_x86_Release_2.0.1071.0.msix (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/db1e6154-852e-468d-a8a0-537ca95d7c2c/WindowsApp_x86_Release_2.0.1071.0.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsApp_x86_Release_2.0.1071.0.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsApp_x64_Release_2.0.1071.0.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsApp_x64_Release_2.0.1071.0.msix (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsApp_x64_Release_2.0.1071.0.msix (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/8d11c978-7f9b-4f0d-83e0-f6e104c263f1/WindowsApp_x64_Release_2.0.1071.0.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsApp_x64_Release_2.0.1071.0.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsApp_arm64_Release_2.0.1071.0.msix"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsApp_arm64_Release_2.0.1071.0.msix (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsApp_arm64_Release_2.0.1071.0.msix (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res.cdn.office.net/remote-desktop-windows-client/ec42c762-f80f-4fde-9190-c3adacffc942/WindowsApp_arm64_Release_2.0.1071.0.msix" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsApp_arm64_Release_2.0.1071.0.msix" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsAppRuntime.1.7 v1.7.9 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsAppRuntime\1\7"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsAppRuntime.1.7 v1.7.9" -ForegroundColor White

$FilePath = "$PkgDir\windowsappruntimeinstall-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsappruntimeinstall-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsappruntimeinstall-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsappruntimeinstall-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsappruntimeinstall-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsappruntimeinstall-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsappruntimeinstall-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsappruntimeinstall-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\windowsappruntimeinstall-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: windowsappruntimeinstall-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: windowsappruntimeinstall-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: windowsappruntimeinstall-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsAppRuntime.1.8 v8000.836.2153.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsAppRuntime\1\8"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsAppRuntime.1.8 v8000.836.2153.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.WindowsAppRuntime.Redist.1.8.260416003.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.WindowsAppRuntime.Redist.1.8.260416003.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.WindowsAppRuntime.Redist.1.8.260416003.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/ec6e81ec-4b72-459e-afa3-0ff5699f831b/Microsoft.WindowsAppRuntime.Redist.1.8.260416003.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.WindowsAppRuntime.Redist.1.8.260416003.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsAppRuntimeInstall-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsAppRuntimeInstall-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsAppRuntimeInstall-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/1c9cc7e4-4453-4ed5-97bf-9347457fa09b/WindowsAppRuntimeInstall-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsAppRuntimeInstall-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsAppRuntimeInstall-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsAppRuntimeInstall-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsAppRuntimeInstall-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/22ba9cfe-9d66-424e-b2de-0e2d9090e777/WindowsAppRuntimeInstall-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsAppRuntimeInstall-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsAppRuntimeInstall-x86.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsAppRuntimeInstall-x86.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsAppRuntimeInstall-x86.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/def0fe17-e9f2-41e8-9b35-c3e93f2c9da5/WindowsAppRuntimeInstall-x86.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsAppRuntimeInstall-x86.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsApplicationDriver v1.2.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsApplicationDriver"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsApplicationDriver v1.2.1.0" -ForegroundColor White

$FilePath = "$PkgDir\WindowsApplicationDriver_1.2.1.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsApplicationDriver_1.2.1.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsApplicationDriver_1.2.1.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/WinAppDriver/releases/download/v1.2.1/WindowsApplicationDriver_1.2.1.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsApplicationDriver_1.2.1.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsBusesTracing v1.1.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsBusesTracing"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsBusesTracing v1.1.0" -ForegroundColor White

$FilePath = "$PkgDir\busestracing-win-x64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: busestracing-win-x64.zip (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: busestracing-win-x64.zip (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/busiotools/releases/download/bt1.1.0/busestracing-win-x64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: busestracing-win-x64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\busestracing-win-arm64.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: busestracing-win-arm64.zip (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: busestracing-win-arm64.zip (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/busiotools/releases/download/bt1.1.0/busestracing-win-arm64.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: busestracing-win-arm64.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsCloudIOProtectionDriver v0.0.693 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsCloudIOProtectionDriver"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsCloudIOProtectionDriver v0.0.693" -ForegroundColor White

$FilePath = "$PkgDir\wcio_protection_driver_installer_x64_0.0.693.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wcio_protection_driver_installer_x64_0.0.693.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wcio_protection_driver_installer_x64_0.0.693.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res-1.cdn.office.net/assets/wcio-protection/msi/2d3f50d6-47fc-42d9-80dc-632e64a7065a/wcio_protection_driver_installer_x64_0.0.693.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wcio_protection_driver_installer_x64_0.0.693.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\wcio_protection_driver_installer_arm_0.0.693.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wcio_protection_driver_installer_arm_0.0.693.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wcio_protection_driver_installer_arm_0.0.693.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://res-1.cdn.office.net/assets/wcio-protection/msi/2d3f50d6-47fc-42d9-80dc-632e64a7065a/wcio_protection_driver_installer_arm_0.0.693.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wcio_protection_driver_installer_arm_0.0.693.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsDeviceRecoveryTool v3.17.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsDeviceRecoveryTool"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsDeviceRecoveryTool v3.17.0" -ForegroundColor White

$FilePath = "$PkgDir\wdrt-hl1.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wdrt-hl1.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wdrt-hl1.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/266c0370-a6b6-4a49-ac55-6cb2e086b14c/wdrt-hl1.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wdrt-hl1.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsInstallationAssistant v1.4.19041.6448 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsInstallationAssistant"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsInstallationAssistant v1.4.19041.6448" -ForegroundColor White

$FilePath = "$PkgDir\Windows11InstallationAssistant.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows11InstallationAssistant.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows11InstallationAssistant.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/db8267b0-3e86-4254-82c7-a127878a9378/Windows11InstallationAssistant.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows11InstallationAssistant.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsMIDIServicesSDK"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209" -ForegroundColor White

$FilePath = "$PkgDir\Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsPCHealthCheck v4.0.2410.23001 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsPCHealthCheck"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsPCHealthCheck v4.0.2410.23001" -ForegroundColor White

$FilePath = "$PkgDir\WindowsPCHealthCheckSetup.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsPCHealthCheckSetup.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsPCHealthCheckSetup.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b/2/9/b2965f3b-0410-4d93-995f-5bc8a5d56916/4.0/x64/WindowsPCHealthCheckSetup.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsPCHealthCheckSetup.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\WindowsPCHealthCheckSetup.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: WindowsPCHealthCheckSetup.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: WindowsPCHealthCheckSetup.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b/2/9/b2965f3b-0410-4d93-995f-5bc8a5d56916/4.0/x86/WindowsPCHealthCheckSetup.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: WindowsPCHealthCheckSetup.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsSDK\10\0\22621"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428" -ForegroundColor White

$FilePath = "$PkgDir\winsdksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: winsdksetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: winsdksetup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3/b/d/3bd97f81-3f5b-4922-b86d-dc5145cd6bfe/windowssdk/winsdksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: winsdksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsSDK\10\0\26100"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705" -ForegroundColor White

$FilePath = "$PkgDir\winsdksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: winsdksetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: winsdksetup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f4b30f2a-4fc3-430e-9b03-c842b5f5f9f1/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: winsdksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsSDK\10\0\28000"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721" -ForegroundColor White

$FilePath = "$PkgDir\winsdksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: winsdksetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: winsdksetup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c5526ca8-88aa-4325-8d72-de642afc7356/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: winsdksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsTerminal v1.24.10921.0 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsTerminal"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsTerminal v1.24.10921.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/terminal/releases/download/v1.24.10921.0/Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsVirtualDesktopAgent"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400" -ForegroundColor White

$FilePath = "$PkgDir\RWrmXv"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RWrmXv (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RWrmXv (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RWrmXv" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsVirtualDesktopBootloader"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100" -ForegroundColor White

$FilePath = "$PkgDir\RWrxrH"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: RWrxrH (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: RWrxrH (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: RWrxrH" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsWDK\10\0\22621"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428" -ForegroundColor White

$FilePath = "$PkgDir\wdksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wdksetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wdksetup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7/b/f/7bfc8dbe-00cb-47de-b856-70e696ef4f46/wdk/wdksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wdksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584 ===
$PkgDir = "$DownloadDir\Microsoft\WindowsWDK\10\0\26100"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584" -ForegroundColor White

$FilePath = "$PkgDir\wdksetup.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wdksetup.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wdksetup.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/41fb59c2-1723-45f9-a270-96b73ad58233/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wdksetup.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.WingetCreate v1.12.8.0 ===
$PkgDir = "$DownloadDir\Microsoft\WingetCreate"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.WingetCreate v1.12.8.0" -ForegroundColor White

$FilePath = "$PkgDir\Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle (x64/user)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-create/releases/download/v1.12.8.0/Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\wingetcreate.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: wingetcreate.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: wingetcreate.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winget-create/releases/download/v1.12.8.0/wingetcreate.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: wingetcreate.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.XMLNotepad v2.9.0.21 ===
$PkgDir = "$DownloadDir\Microsoft\XMLNotepad"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.XMLNotepad v2.9.0.21" -ForegroundColor White

$FilePath = "$PkgDir\XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/XmlNotepad/releases/download/2.9.0.21/XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\XmlNotepadSetup.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: XmlNotepadSetup.zip (neutral)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: XmlNotepadSetup.zip (neutral/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/XmlNotepad/releases/download/2.9.0.21/XmlNotepadSetup.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: XmlNotepadSetup.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.bitsmanager v1.12.0.4 ===
$PkgDir = "$DownloadDir\Microsoft\bitsmanager"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.bitsmanager v1.12.0.4" -ForegroundColor White

$FilePath = "$PkgDir\BITSManager.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: BITSManager.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: BITSManager.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/BITS-Manager/releases/download/v1.12/BITSManager.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: BITSManager.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.err v6.4.5 ===
$PkgDir = "$DownloadDir\Microsoft\err"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.err v6.4.5" -ForegroundColor White

$FilePath = "$PkgDir\Err_6.4.5.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Err_6.4.5.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Err_6.4.5.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/4/3/2/432140e8-fb6c-4145-8192-25242838c542/Err_6.4.5/Err_6.4.5.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Err_6.4.5.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.etl2pcapng v1.11.0 ===
$PkgDir = "$DownloadDir\Microsoft\etl2pcapng"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.etl2pcapng v1.11.0" -ForegroundColor White

$FilePath = "$PkgDir\etl2pcapng.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: etl2pcapng.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: etl2pcapng.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/etl2pcapng/releases/download/v1.11.0/etl2pcapng.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: etl2pcapng.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.msodbcsql.17 v17.10.6.1 ===
$PkgDir = "$DownloadDir\Microsoft\msodbcsql\17"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.msodbcsql.17 v17.10.6.1" -ForegroundColor White

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/en-US/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/en-US/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/de-DE/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/de-DE/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/es-ES/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/es-ES/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/fr-FR/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/fr-FR/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/it-IT/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/it-IT/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ja-JP/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ja-JP/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ko-KR/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ko-KR/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/pt-BR/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/pt-BR/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ru-RU/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ru-RU/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-CN/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-CN/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-TW/17.10.6.1/x86/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-TW/17.10.6.1/x64/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.msodbcsql.18 v18.6.2.1 ===
$PkgDir = "$DownloadDir\Microsoft\msodbcsql\18"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.msodbcsql.18 v18.6.2.1" -ForegroundColor White

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c0d0dcf1-bd9b-46ec-a659-5046ee11d1d1/x86/1033/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/7bf9fad4-0f21-486d-a750-fc990ded5624/amd64/1033/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/76504d2d-06b3-4262-8bc9-855ffd08d7be/arm64/1033/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/be607da2-d2a5-481c-9db8-7ee1f76801d7/x86/1031/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/9686dba9-b962-4715-8380-dea24599e181/amd64/1031/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e77d6889-44b4-4965-88c8-ce196cdd2bdc/arm64/1031/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/6cb6c417-86fc-46fb-9497-776c83cb0111/x86/3082/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/a6da0e01-66c7-4987-89eb-3ee383a4d59b/amd64/3082/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/62c491d2-04e9-4d72-b5a5-9d03af2995ab/arm64/3082/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8d3eb7eb-5a29-4ba3-a86c-6ccdceb055e7/x86/1036/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/23099c35-bb51-4a27-81a7-559d60db69f2/amd64/1036/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/add95ea7-c0bc-4a88-8f4f-11eb8b483c2c/arm64/1036/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/0c8c9e26-3fd3-4b2f-a32c-ccd81862e2ef/x86/1040/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/3996f308-6e1f-4dbb-bb8f-ea9949c30930/amd64/1040/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/30b82b26-d3da-402e-8f8a-3f3686081bc0/arm64/1040/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e637d43c-6b90-4c15-b89a-65c555e7c362/x86/1041/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/747d5a46-d7ed-4cb9-be1e-16f8cfd43d25/amd64/1041/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/fda472bc-bc32-4e50-ac85-c5c4ef8a81cf/arm64/1041/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/0de273df-ab78-43ba-9864-8ccbca6a7797/x86/1042/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/f7f77cd9-dfde-45a3-85b9-0f3fc51164a4/amd64/1042/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/01557ea7-ef5c-4c07-8406-4245257df2e1/arm64/1042/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/b1c469f7-1727-4de5-a2be-9a2f0bb5e14e/x86/1046/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/01b14c42-0e39-4d3a-b6ef-37d6ae6b4cce/amd64/1046/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/8cb64429-090f-493f-aa6f-e17212798add/arm64/1046/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/fd4ee281-198d-4f8e-a4f8-44fdec6cb83a/x86/1049/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/76470099-344e-475e-8de6-703c9b669715/amd64/1049/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/9f6c498c-65bf-410a-b9ac-6b2bdc233aed/arm64/1049/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/c794aa14-cf68-41ab-85da-35c6699ccc96/x86/2052/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e4674677-8370-41f7-a4f0-708e3ed7edf0/amd64/2052/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/ef6bf0f1-5832-4033-aad3-5972f060fb87/arm64/2052/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/099e5f30-1677-4184-a271-327f7ec1ccc3/x86/1028/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/e6a2cd27-87d2-43e4-b212-e2c2ad19a970/amd64/1028/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\msodbcsql.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: msodbcsql.msi (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: msodbcsql.msi (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://download.microsoft.com/download/69f7b105-c55f-4bd6-b7cf-78e69abff9ea/arm64/1028/msodbcsql.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: msodbcsql.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.quicreach v1.3.0 ===
$PkgDir = "$DownloadDir\Microsoft\quicreach"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.quicreach v1.3.0" -ForegroundColor White

$FilePath = "$PkgDir\quicreach.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: quicreach.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: quicreach.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/quicreach/releases/download/v1.3.0/quicreach.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: quicreach.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Microsoft.winfile v10.4.0.0 ===
$PkgDir = "$DownloadDir\Microsoft\winfile"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Microsoft.winfile v10.4.0.0" -ForegroundColor White

$FilePath = "$PkgDir\Winfile_v10.4.0.0.zip"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Winfile_v10.4.0.0.zip (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Winfile_v10.4.0.0.zip (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://github.com/microsoft/winfile/releases/download/v10.4.0.0/Winfile_v10.4.0.0.zip" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Winfile_v10.4.0.0.zip" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === Telerik.Fiddler.Classic v5.0.20253.3311 ===
$PkgDir = "$DownloadDir\Telerik\Fiddler\Classic"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 Telerik.Fiddler.Classic v5.0.20253.3311" -ForegroundColor White

$FilePath = "$PkgDir\FiddlerSetup.5.0.20253.3311-latest.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: FiddlerSetup.5.0.20253.3311-latest.exe (x86)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: FiddlerSetup.5.0.20253.3311-latest.exe (x86/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://downloads.getfiddler.com/fiddler-classic/FiddlerSetup.5.0.20253.3311-latest.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: FiddlerSetup.5.0.20253.3311-latest.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === WiresharkFoundation.Stratoshark v0.9.3 ===
$PkgDir = "$DownloadDir\WiresharkFoundation\Stratoshark"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WiresharkFoundation.Stratoshark v0.9.3" -ForegroundColor White

$FilePath = "$PkgDir\Stratoshark-0.9.3-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Stratoshark-0.9.3-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Stratoshark-0.9.3-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://1.na.dl.wireshark.org/win64/Stratoshark-0.9.3-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Stratoshark-0.9.3-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Stratoshark-0.9.3-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Stratoshark-0.9.3-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Stratoshark-0.9.3-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://1.na.dl.wireshark.org/win64/Stratoshark-0.9.3-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Stratoshark-0.9.3-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

# === WiresharkFoundation.Wireshark v4.6.5 ===
$PkgDir = "$DownloadDir\WiresharkFoundation\Wireshark"
New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null
Write-Host "📦 WiresharkFoundation.Wireshark v4.6.5" -ForegroundColor White

$FilePath = "$PkgDir\Wireshark-4.6.5-x64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Wireshark-4.6.5-x64.exe (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Wireshark-4.6.5-x64.exe (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-x64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Wireshark-4.6.5-x64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Wireshark-4.6.5-arm64.exe"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Wireshark-4.6.5-arm64.exe (arm64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Wireshark-4.6.5-arm64.exe (arm64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-arm64.exe" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Wireshark-4.6.5-arm64.exe" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

$FilePath = "$PkgDir\Wireshark-4.6.5-x64.msi"
if (Test-Path $FilePath) {
    Write-Host "   ⏭️  已存在: Wireshark-4.6.5-x64.msi (x64)" -ForegroundColor DarkGray
    $Skipped++
} else {
    Write-Host "   ⬇️  下載中: Wireshark-4.6.5-x64.msi (x64/default)" -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-x64.msi" -OutFile $FilePath -UseBasicParsing
        $Size = (Get-Item $FilePath).Length / 1MB
        Write-Host ("   ✅ 完成: {0:N1} MB" -f $Size) -ForegroundColor Green
        $Total++
    } catch {
        Write-Host "   ❌ 下載失敗: Wireshark-4.6.5-x64.msi" -ForegroundColor Red
        $Failed++
        Remove-Item $FilePath -ErrorAction SilentlyContinue
    }
}

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
