#!/bin/bash
# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 11:46:52
# 套件數量：295
#
# 用法：bash generated/download.sh
# 檔案會下載到 ./downloads/{PackageId}/ 目錄

set -euo pipefail

DOWNLOAD_DIR="./downloads"
TOTAL=0
SKIPPED=0
FAILED=0

echo "🚀 開始下載 winget 安裝檔 ..."
echo ""

# === GitHub.Copilot v1.0.34 ===
PKG_DIR="$DOWNLOAD_DIR/GitHub/Copilot"
mkdir -p "$PKG_DIR"
echo "📦 GitHub.Copilot v1.0.34"

FILEPATH="$PKG_DIR/copilot-win32-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: copilot-win32-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: copilot-win32-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/github/copilot-cli/releases/download/v1.0.34/copilot-win32-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: copilot-win32-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/copilot-win32-arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: copilot-win32-arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: copilot-win32-arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/github/copilot-cli/releases/download/v1.0.34/copilot-win32-arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: copilot-win32-arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === GitHub.GitHubDesktop v3.5.8 ===
PKG_DIR="$DOWNLOAD_DIR/GitHub/GitHubDesktop"
mkdir -p "$PKG_DIR"
echo "📦 GitHub.GitHubDesktop v3.5.8"

FILEPATH="$PKG_DIR/GitHubDesktopSetup-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubDesktopSetup-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubDesktopSetup-x64.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubDesktopSetup-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/GitHubDesktopSetup-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubDesktopSetup-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubDesktopSetup-x64.msi (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubDesktopSetup-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/GitHubDesktopSetup-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubDesktopSetup-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubDesktopSetup-arm64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubDesktopSetup-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/GitHubDesktopSetup-arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubDesktopSetup-arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubDesktopSetup-arm64.msi (arm64/machine)"
  if curl -fSL -o "$FILEPATH" "https://desktop.githubusercontent.com/releases/3.5.8-b1d863ab/GitHubDesktopSetup-arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubDesktopSetup-arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === GitHub.GitLFS v3.7.1 ===
PKG_DIR="$DOWNLOAD_DIR/GitHub/GitLFS"
mkdir -p "$PKG_DIR"
echo "📦 GitHub.GitLFS v3.7.1"

FILEPATH="$PKG_DIR/git-lfs-windows-v3.7.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: git-lfs-windows-v3.7.1.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: git-lfs-windows-v3.7.1.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/git-lfs/git-lfs/releases/download/v3.7.1/git-lfs-windows-v3.7.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: git-lfs-windows-v3.7.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === GitHub.cli v2.92.0 ===
PKG_DIR="$DOWNLOAD_DIR/GitHub/cli"
mkdir -p "$PKG_DIR"
echo "📦 GitHub.cli v2.92.0"

FILEPATH="$PKG_DIR/gh_2.92.0_windows_386.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_386.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_386.msi (x86/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_386.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_386.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/gh_2.92.0_windows_386.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_386.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_386.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_386.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_386.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/gh_2.92.0_windows_amd64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_amd64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_amd64.msi (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_amd64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/gh_2.92.0_windows_amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/gh_2.92.0_windows_arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_arm64.msi (arm64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/gh_2.92.0_windows_arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: gh_2.92.0_windows_arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: gh_2.92.0_windows_arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/cli/cli/releases/download/v2.92.0/gh_2.92.0_windows_arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: gh_2.92.0_windows_arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === GitHub.git-sizer v1.5.0 ===
PKG_DIR="$DOWNLOAD_DIR/GitHub/git-sizer"
mkdir -p "$PKG_DIR"
echo "📦 GitHub.git-sizer v1.5.0"

FILEPATH="$PKG_DIR/git-sizer-1.5.0-windows-386.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: git-sizer-1.5.0-windows-386.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: git-sizer-1.5.0-windows-386.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-windows-386.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: git-sizer-1.5.0-windows-386.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/git-sizer-1.5.0-windows-amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: git-sizer-1.5.0-windows-amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: git-sizer-1.5.0-windows-amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/github/git-sizer/releases/download/v1.5.0/git-sizer-1.5.0-windows-amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: git-sizer-1.5.0-windows-amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AIShell v1.0.0-preview.8 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AIShell"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AIShell v1.0.0-preview.8"

FILEPATH="$PKG_DIR/AIShell-1.0.0-preview.8-win-x86.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AIShell-1.0.0-preview.8-win-x86.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AIShell-1.0.0-preview.8-win-x86.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/AIShell/releases/download/v1.0.0-preview.8/AIShell-1.0.0-preview.8-win-x86.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AIShell-1.0.0-preview.8-win-x86.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/AIShell-1.0.0-preview.8-win-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AIShell-1.0.0-preview.8-win-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AIShell-1.0.0-preview.8-win-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/AIShell/releases/download/v1.0.0-preview.8/AIShell-1.0.0-preview.8-win-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AIShell-1.0.0-preview.8-win-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/AIShell-1.0.0-preview.8-win-arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AIShell-1.0.0-preview.8-win-arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AIShell-1.0.0-preview.8-win-arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/AIShell/releases/download/v1.0.0-preview.8/AIShell-1.0.0-preview.8-win-arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AIShell-1.0.0-preview.8-win-arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AKSdesktop v0.1.0-alpha ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AKSdesktop"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AKSdesktop v0.1.0-alpha"

FILEPATH="$PKG_DIR/aks-desktop-0.1.0-alpha-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aks-desktop-0.1.0-alpha-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aks-desktop-0.1.0-alpha-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/aks-desktop/releases/download/v0.1.0-alpha/aks-desktop-0.1.0-alpha-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aks-desktop-0.1.0-alpha-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.APM v0.11.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/APM"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.APM v0.11.0"

FILEPATH="$PKG_DIR/apm-windows-x86_64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: apm-windows-x86_64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: apm-windows-x86_64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/apm/releases/download/v0.11.0/apm-windows-x86_64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: apm-windows-x86_64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ASRTestTool v4.13.17600.1000 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ASRTestTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ASRTestTool v4.13.17600.1000"

FILEPATH="$PKG_DIR/ASRtool.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ASRtool.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ASRtool.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://demo.wd.microsoft.com/Content/ASRtool.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ASRtool.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AccountLockoutStatus v1.0.0.60 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AccountLockoutStatus"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AccountLockoutStatus v1.0.0.60"

FILEPATH="$PKG_DIR/lockoutstatus.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: lockoutstatus.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: lockoutstatus.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/0/4/c0472410-b4c2-4aef-89d2-e7c708dfc225/lockoutstatus.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: lockoutstatus.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AdministrativeTemplates v11.25H2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AdministrativeTemplates"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AdministrativeTemplates v11.25H2"

FILEPATH="$PKG_DIR/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f35d3000-b6c9-4ca6-bedc-5e4ec15a6b7a/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AmendmentAppWordService v4.2.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AmendmentAppWordService"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AmendmentAppWordService v4.2.0.0"

FILEPATH="$PKG_DIR/AmendmentAppWordServiceV4.2.Setup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AmendmentAppWordServiceV4.2.Setup.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AmendmentAppWordServiceV4.2.Setup.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://amendmentservice.azurewebsites.net/assets/AmendmentAppWordServiceV4.2.Setup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AmendmentAppWordServiceV4.2.Setup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AppControlPolicyWizard v2.6.0.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AppControlPolicyWizard"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AppControlPolicyWizard v2.6.0.1"

FILEPATH="$PKG_DIR/WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WDACWizard_2.6.0.1_x64_8wekyb3d8bbwe.MSIX"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AppInstaller v1.27.470.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AppInstaller"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AppInstaller v1.27.470.0"

FILEPATH="$PKG_DIR/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winget-cli/releases/download/v1.12.470/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AppInstallerFileBuilder v1.2020.221.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AppInstallerFileBuilder"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AppInstallerFileBuilder v1.2020.221.0"

FILEPATH="$PKG_DIR/AppInstallerFileBuilder_1.2020.221.0_x86.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AppInstallerFileBuilder_1.2020.221.0_x86.msix (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AppInstallerFileBuilder_1.2020.221.0_x86.msix (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_1.2020.221.0_x86.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AppInstallerFileBuilder_1.2020.221.0_x86.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AppLockerPolicyConverter v2.0.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AppLockerPolicyConverter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AppLockerPolicyConverter v2.0.0.0"

FILEPATH="$PKG_DIR/AppLockerPolicyConverter.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AppLockerPolicyConverter.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AppLockerPolicyConverter.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/v2.0.0.0/AppLockerPolicyConverter.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AppLockerPolicyConverter.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ApplicationInspector v1.9.55 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ApplicationInspector"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ApplicationInspector v1.9.55"

FILEPATH="$PKG_DIR/ApplicationInspector_win_1.9.55.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ApplicationInspector_win_1.9.55.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ApplicationInspector_win_1.9.55.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/ApplicationInspector/releases/download/v1.9.55/ApplicationInspector_win_1.9.55.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ApplicationInspector_win_1.9.55.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Aspire v13.1.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Aspire"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Aspire v13.1.3"

FILEPATH="$PKG_DIR/aspire-cli-win-x64-13.1.3.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspire-cli-win-x64-13.1.3.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspire-cli-win-x64-13.1.3.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://ci.dot.net/public/aspire/13.1.3-preview.1.26166.8/aspire-cli-win-x64-13.1.3.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspire-cli-win-x64-13.1.3.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspire-cli-win-arm64-13.1.3.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspire-cli-win-arm64-13.1.3.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspire-cli-win-arm64-13.1.3.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://ci.dot.net/public/aspire/13.1.3-preview.1.26166.8/aspire-cli-win-arm64-13.1.3.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspire-cli-win-arm64-13.1.3.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azd v1.24.300 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azd"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azd v1.24.300"

FILEPATH="$PKG_DIR/azd-windows-amd64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azd-windows-amd64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azd-windows-amd64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-dev/releases/download/azure-dev-cli_1.24.2/azd-windows-amd64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azd-windows-amd64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/ADConnectSyncDocumenter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0"

FILEPATH="$PKG_DIR/AzureADConnectSyncDocumenter.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureADConnectSyncDocumenter.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureADConnectSyncDocumenter.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/AADConnectConfigDocumenter/releases/download/v1.20.0917.0/AzureADConnectSyncDocumenter.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureADConnectSyncDocumenter.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.AZCopy.10 v10.32.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/AZCopy/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.AZCopy.10 v10.32.3"

FILEPATH="$PKG_DIR/azcopy_windows_386_10.32.3.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azcopy_windows_386_10.32.3.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azcopy_windows_386_10.32.3.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_386_10.32.3.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azcopy_windows_386_10.32.3.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azcopy_windows_amd64_10.32.3.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azcopy_windows_amd64_10.32.3.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azcopy_windows_amd64_10.32.3.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_amd64_10.32.3.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azcopy_windows_amd64_10.32.3.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azcopy_windows_arm64_10.32.3.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azcopy_windows_arm64_10.32.3.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azcopy_windows_arm64_10.32.3.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-storage-azcopy/releases/download/v10.32.3/azcopy_windows_arm64_10.32.3.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azcopy_windows_arm64_10.32.3.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.ArtifactSigningClientTools v0.1.128 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/ArtifactSigningClientTools"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.ArtifactSigningClientTools v0.1.128"

FILEPATH="$PKG_DIR/ArtifactSigningClientTools.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ArtifactSigningClientTools.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ArtifactSigningClientTools.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/a3c24ba9-ff1f-444f-b626-eff710f345c3/ArtifactSigningClientTools.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ArtifactSigningClientTools.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.Auth v0.9.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/Auth"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.Auth v0.9.2"

FILEPATH="$PKG_DIR/azureauth-0.9.2-win-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azureauth-0.9.2-win-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azureauth-0.9.2-win-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/AzureAD/microsoft-authentication-cli/releases/download/0.9.2/azureauth-0.9.2-win-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azureauth-0.9.2-win-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.Az v15.2.0.40510 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/Az"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.Az v15.2.0.40510"

FILEPATH="$PKG_DIR/Az-Cmdlets-15.2.0.40510-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Az-Cmdlets-15.2.0.40510-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Az-Cmdlets-15.2.0.40510-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-powershell/releases/download/v15.2.0-January2026/Az-Cmdlets-15.2.0.40510-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Az-Cmdlets-15.2.0.40510-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.AztfExport v0.19.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/AztfExport"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.AztfExport v0.19.0"

FILEPATH="$PKG_DIR/aztfexport_v0.19.0_x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aztfexport_v0.19.0_x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aztfexport_v0.19.0_x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/aztfexport/releases/download/v0.19.0/aztfexport_v0.19.0_x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aztfexport_v0.19.0_x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aztfexport_v0.19.0_x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aztfexport_v0.19.0_x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aztfexport_v0.19.0_x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/aztfexport/releases/download/v0.19.0/aztfexport_v0.19.0_x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aztfexport_v0.19.0_x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.BatchExplorer v2.23.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/BatchExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.BatchExplorer v2.23.0"

FILEPATH="$PKG_DIR/BatchExplorer.Setup.2.23.0-stable.1210.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BatchExplorer.Setup.2.23.0-stable.1210.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BatchExplorer.Setup.2.23.0-stable.1210.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/BatchExplorer/releases/download/v2.23.0-stable.1210/BatchExplorer.Setup.2.23.0-stable.1210.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BatchExplorer.Setup.2.23.0-stable.1210.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/CloudHSM-ClientSDK"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2"

FILEPATH="$PKG_DIR/AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-2.0.2.2/AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureCloudHSM-ClientSDK-Windows-2.0.2.2.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/ConnectedMachineAgent"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896"

FILEPATH="$PKG_DIR/AzureConnectedMachineAgent.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureConnectedMachineAgent.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureConnectedMachineAgent.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureConnectedMachineAgent.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.CosmosEmulator v2.14.27 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/CosmosEmulator"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.CosmosEmulator v2.14.27"

FILEPATH="$PKG_DIR/azure-cosmosdb-emulator-2.14.27-26220ef4.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azure-cosmosdb-emulator-2.14.27-26220ef4.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azure-cosmosdb-emulator-2.14.27-26220ef4.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-2.14.27-26220ef4.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azure-cosmosdb-emulator-2.14.27-26220ef4.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.DataCLI v20.3.14 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/DataCLI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.DataCLI v20.3.14"

FILEPATH="$PKG_DIR/azdata-cli-20.3.14.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azdata-cli-20.3.14.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azdata-cli-20.3.14.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f/f/f/fffaa914-d4f7-4885-89c7-696bbfe7670a/azdata-cli-20.3.14.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azdata-cli-20.3.14.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.DataStudio v1.52.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/DataStudio"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.DataStudio v1.52.0"

FILEPATH="$PKG_DIR/azuredatastudio-windows-user-setup-1.52.0.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azuredatastudio-windows-user-setup-1.52.0.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azuredatastudio-windows-user-setup-1.52.0.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-user-setup-1.52.0.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azuredatastudio-windows-user-setup-1.52.0.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azuredatastudio-windows-arm64-user-setup-1.52.0.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azuredatastudio-windows-arm64-user-setup-1.52.0.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azuredatastudio-windows-arm64-user-setup-1.52.0.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-arm64-user-setup-1.52.0.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azuredatastudio-windows-arm64-user-setup-1.52.0.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azuredatastudio-windows-setup-1.52.0.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azuredatastudio-windows-setup-1.52.0.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azuredatastudio-windows-setup-1.52.0.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-setup-1.52.0.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azuredatastudio-windows-setup-1.52.0.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azuredatastudio-windows-arm64-setup-1.52.0.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azuredatastudio-windows-arm64-setup-1.52.0.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azuredatastudio-windows-arm64-setup-1.52.0.exe (arm64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6b2bfeac-9c1b-4182-9a2f-ce86ff8cc371/azuredatastudio-windows-arm64-setup-1.52.0.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azuredatastudio-windows-arm64-setup-1.52.0.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.FunctionsCoreTools v4.10.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/FunctionsCoreTools"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.FunctionsCoreTools v4.10.0"

FILEPATH="$PKG_DIR/func-cli-4.10.0-x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: func-cli-4.10.0-x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: func-cli-4.10.0-x86.msi (x86/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/func-cli-4.10.0-x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: func-cli-4.10.0-x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/func-cli-4.10.0-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: func-cli-4.10.0-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: func-cli-4.10.0-x64.msi (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/func-cli-4.10.0-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: func-cli-4.10.0-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Azure.Functions.Cli.win-x86.4.10.0.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Azure.Functions.Cli.win-x86.4.10.0.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Azure.Functions.Cli.win-x86.4.10.0.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-x86.4.10.0.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Azure.Functions.Cli.win-x86.4.10.0.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Azure.Functions.Cli.win-x64.4.10.0.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Azure.Functions.Cli.win-x64.4.10.0.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Azure.Functions.Cli.win-x64.4.10.0.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-x64.4.10.0.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Azure.Functions.Cli.win-x64.4.10.0.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Azure.Functions.Cli.win-arm64.4.10.0.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Azure.Functions.Cli.win-arm64.4.10.0.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Azure.Functions.Cli.win-arm64.4.10.0.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-functions-core-tools/releases/download/4.10.0/Azure.Functions.Cli.win-arm64.4.10.0.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Azure.Functions.Cli.win-arm64.4.10.0.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.GuestProxyAgent v1.0.39 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/GuestProxyAgent"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.GuestProxyAgent v1.0.39"

FILEPATH="$PKG_DIR/Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/GuestProxyAgent/releases/download/1.0.39/Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows_148993103_GuestProxyAgent_AMD64_1.0.39.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/GuestProxyAgent/releases/download/1.0.39/Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows_148993103_GuestProxyAgent_ARM64_1.0.39.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.IoTExplorer v0.15.12 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/IoTExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.IoTExplorer v0.15.12"

FILEPATH="$PKG_DIR/Azure.IoT.Explorer.Preview.0.15.12.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Azure.IoT.Explorer.Preview.0.15.12.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Azure.IoT.Explorer.Preview.0.15.12.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azure-iot-explorer/releases/download/v0.15.12/Azure.IoT.Explorer.Preview.0.15.12.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Azure.IoT.Explorer.Preview.0.15.12.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.Kubelogin v0.2.13 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/Kubelogin"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.Kubelogin v0.2.13"

FILEPATH="$PKG_DIR/kubelogin_0.2.13-1_amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: kubelogin_0.2.13-1_amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: kubelogin_0.2.13-1_amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://packages.aks.azure.com/dalec-packages/kubelogin/0.2.13/windows/amd64/kubelogin_0.2.13-1_amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: kubelogin_0.2.13-1_amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.QuickReview v3.1.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/QuickReview"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.QuickReview v3.1.2"

FILEPATH="$PKG_DIR/azqr-win-amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azqr-win-amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azqr-win-amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/azqr/releases/download/v.3.1.2/azqr-win-amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azqr-win-amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.StorageExplorer v1.43.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/StorageExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.StorageExplorer v1.43.0"

FILEPATH="$PKG_DIR/StorageExplorer-windows-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: StorageExplorer-windows-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: StorageExplorer-windows-x64.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/AzureStorageExplorer/releases/download/v1.43.0/StorageExplorer-windows-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: StorageExplorer-windows-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/StorageExplorer-windows-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: StorageExplorer-windows-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: StorageExplorer-windows-arm64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/AzureStorageExplorer/releases/download/v1.43.0/StorageExplorer-windows-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: StorageExplorer-windows-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.TemplateAnalyzer v0.8.5 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/TemplateAnalyzer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.TemplateAnalyzer v0.8.5"

FILEPATH="$PKG_DIR/TemplateAnalyzer-win-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TemplateAnalyzer-win-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TemplateAnalyzer-win-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/template-analyzer/releases/download/v0.8.5/TemplateAnalyzer-win-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TemplateAnalyzer-win-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/TemplateAnalyzer-win-arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TemplateAnalyzer-win-arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TemplateAnalyzer-win-arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/template-analyzer/releases/download/v0.8.5/TemplateAnalyzer-win-arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TemplateAnalyzer-win-arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Azure.TrustedSigningClientTools v0.1.127 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Azure/TrustedSigningClientTools"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Azure.TrustedSigningClientTools v0.1.127"

FILEPATH="$PKG_DIR/TrustedSigningClientTools.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TrustedSigningClientTools.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TrustedSigningClientTools.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6d9cb638-4d5f-438d-9f21-23f0f4405944/TrustedSigningClientTools.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TrustedSigningClientTools.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AzureCLI v2.85.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AzureCLI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AzureCLI v2.85.0"

FILEPATH="$PKG_DIR/azure-cli-2.85.0.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azure-cli-2.85.0.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azure-cli-2.85.0.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.85.0.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azure-cli-2.85.0.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/azure-cli-2.85.0-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: azure-cli-2.85.0-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: azure-cli-2.85.0-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.85.0-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: azure-cli-2.85.0-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AzureMonitorAgent v1.41.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AzureMonitorAgent"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AzureMonitorAgent v1.41.0.0"

FILEPATH="$PKG_DIR/AzureMonitorAgentClientSetup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureMonitorAgentClientSetup.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureMonitorAgentClientSetup.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7e4aea1a-060c-4e5a-9ea0-b89ded973c61/AzureMonitorAgentClientSetup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureMonitorAgentClientSetup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.AzureVPNClient v4.0.5.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/AzureVPNClient"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.AzureVPNClient v4.0.5.0"

FILEPATH="$PKG_DIR/AzVpnAppx_4.0.5.0_sideload.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzVpnAppx_4.0.5.0_sideload.zip (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzVpnAppx_4.0.5.0_sideload.zip (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1fa24e82-5a8b-41be-90a9-957b1064f51e/AzVpnAppx_4.0.5.0_sideload.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzVpnAppx_4.0.5.0_sideload.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.BTP v1.14.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/BTP"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.BTP v1.14.0"

FILEPATH="$PKG_DIR/BluetoothTestPlatformPack-1.14.0.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BluetoothTestPlatformPack-1.14.0.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BluetoothTestPlatformPack-1.14.0.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e/e/e/eeed3cd5-bdbd-47db-9b8e-ca9d2df2cd29/BluetoothTestPlatformPack-1.14.0.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BluetoothTestPlatformPack-1.14.0.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Bicep v0.42.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Bicep"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Bicep v0.42.1"

FILEPATH="$PKG_DIR/bicep-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: bicep-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: bicep-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: bicep-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/bicep-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: bicep-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: bicep-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: bicep-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/bicep-setup-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: bicep-setup-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: bicep-setup-win-x64.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/Azure/bicep/releases/download/v0.42.1/bicep-setup-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: bicep-setup-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.BotFrameworkComposer v2.1.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/BotFrameworkComposer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.BotFrameworkComposer v2.1.2"

FILEPATH="$PKG_DIR/BotFramework-Composer-2.1.2-windows-setup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BotFramework-Composer-2.1.2-windows-setup.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BotFramework-Composer-2.1.2-windows-setup.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/BotFramework-Composer/releases/download/v2.1.2/BotFramework-Composer-2.1.2-windows-setup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BotFramework-Composer-2.1.2-windows-setup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.BotFrameworkEmulator v4.15.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/BotFrameworkEmulator"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.BotFrameworkEmulator v4.15.1"

FILEPATH="$PKG_DIR/BotFramework-Emulator-4.15.1-windows-setup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BotFramework-Emulator-4.15.1-windows-setup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BotFramework-Emulator-4.15.1-windows-setup.exe (x86/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/BotFramework-Emulator/releases/download/v4.15.1/BotFramework-Emulator-4.15.1-windows-setup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BotFramework-Emulator-4.15.1-windows-setup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/CLRTypesSQLServer/2019"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5"

FILEPATH="$PKG_DIR/SQLSysClrTypes.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQLSysClrTypes.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQLSysClrTypes.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/d/d/1/dd194c5c-d859-49b8-ad64-5cbdcbb9b7bd/SQLSysClrTypes.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQLSysClrTypes.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.CertifiedToolAzureVM v1.6 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/CertifiedToolAzureVM"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.CertifiedToolAzureVM v1.6"

FILEPATH="$PKG_DIR/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/a/f/1/af1bfced-edbf-4991-a78e-775ca8dab151/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.CmdPalAzureExtension v0.200.174.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/CmdPalAzureExtension"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.CmdPalAzureExtension v0.200.174.0"

FILEPATH="$PKG_DIR/AzureExtension_release_v0.200.174.0_x64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureExtension_release_v0.200.174.0_x64.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureExtension_release_v0.200.174.0_x64.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/CmdPalAzureExtension/releases/download/v0.200.174.0/AzureExtension_release_v0.200.174.0_x64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureExtension_release_v0.200.174.0_x64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/AzureExtension_release_v0.200.174.0_arm64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AzureExtension_release_v0.200.174.0_arm64.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AzureExtension_release_v0.200.174.0_arm64.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/CmdPalAzureExtension/releases/download/v0.200.174.0/AzureExtension_release_v0.200.174.0_arm64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AzureExtension_release_v0.200.174.0_arm64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.CmdPalGitHubExtension v0.103.178.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/CmdPalGitHubExtension"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.CmdPalGitHubExtension v0.103.178.0"

FILEPATH="$PKG_DIR/GitHubExtension_release_v0.103.178.0_x64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubExtension_release_v0.103.178.0_x64.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubExtension_release_v0.103.178.0_x64.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/CmdPalGitHubExtension/releases/download/v0.103.178.0/GitHubExtension_release_v0.103.178.0_x64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubExtension_release_v0.103.178.0_x64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/GitHubExtension_release_v0.103.178.0_arm64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GitHubExtension_release_v0.103.178.0_arm64.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GitHubExtension_release_v0.103.178.0_arm64.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/CmdPalGitHubExtension/releases/download/v0.103.178.0/GitHubExtension_release_v0.103.178.0_arm64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GitHubExtension_release_v0.103.178.0_arm64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DSC v3.1.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DSC"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DSC v3.1.3"

FILEPATH="$PKG_DIR/DSC-3.1.3-Win.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DSC-3.1.3-Win.msixbundle (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DSC-3.1.3-Win.msixbundle (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-Win.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DSC-3.1.3-Win.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/DSC-3.1.3-x86_64-pc-windows-msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DSC-3.1.3-x86_64-pc-windows-msvc.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DSC-3.1.3-x86_64-pc-windows-msvc.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-x86_64-pc-windows-msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DSC-3.1.3-x86_64-pc-windows-msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/DSC-3.1.3-aarch64-pc-windows-msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DSC-3.1.3-aarch64-pc-windows-msvc.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DSC-3.1.3-aarch64-pc-windows-msvc.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/DSC/releases/download/v3.1.3/DSC-3.1.3-aarch64-pc-windows-msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DSC-3.1.3-aarch64-pc-windows-msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DTrace v2.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DTrace"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DTrace v2.0"

FILEPATH="$PKG_DIR/DTrace.amd64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DTrace.amd64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DTrace.amd64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/9/d/79d6b79a-5836-4118-a9b7-60bc77c97bf7/DTrace.amd64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DTrace.amd64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/DTrace.arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DTrace.arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DTrace.arm64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/9/d/79d6b79a-5836-4118-a9b7-60bc77c97bf7/DTrace.arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DTrace.arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DataMigrationAssistant v5.8.5973.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DataMigrationAssistant"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DataMigrationAssistant v5.8.5973.1"

FILEPATH="$PKG_DIR/DataMigrationAssistant.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DataMigrationAssistant.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DataMigrationAssistant.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/6/3/c63d8695-cef2-43c3-af0a-4989507e429b/DataMigrationAssistant.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DataMigrationAssistant.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DataTools.IntegrationServices v17.0.1010.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DataTools/IntegrationServices"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DataTools.IntegrationServices v17.0.1010.2"

FILEPATH="$PKG_DIR/Microsoft.DataTools.IntegrationServices.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.DataTools.IntegrationServices.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.DataTools.IntegrationServices.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/2.1.2/1764774570388/Microsoft.DataTools.IntegrationServices.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.DataTools.IntegrationServices.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DebugDiag v2.3.2.11 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DebugDiag"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DebugDiag v2.3.2.11"

FILEPATH="$PKG_DIR/DebugDiagx64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DebugDiagx64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DebugDiagx64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/9/3/a/93ae9fb0-2f2a-43f1-b0b5-5381b9f629ca/DebugDiagx64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DebugDiagx64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DefenderForCloud.CLI v2.0.03334.114 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DefenderForCloud/CLI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DefenderForCloud.CLI v2.0.03334.114"

FILEPATH="$PKG_DIR/Defender_win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Defender_win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Defender_win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Defender_win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Defender_win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Defender_win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Defender_win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Defender_win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Defender_win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Defender_win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Defender_win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Defender_win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DependencyAgent v9.10.18 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DependencyAgent"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DependencyAgent v9.10.18"

FILEPATH="$PKG_DIR/InstallDependencyAgent-Windows.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: InstallDependencyAgent-Windows.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: InstallDependencyAgent-Windows.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: InstallDependencyAgent-Windows.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DeploymentToolkit v6.3.8456.1000 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DeploymentToolkit"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DeploymentToolkit v6.3.8456.1000"

FILEPATH="$PKG_DIR/MicrosoftDeploymentToolkit_x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftDeploymentToolkit_x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftDeploymentToolkit_x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftDeploymentToolkit_x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MicrosoftDeploymentToolkit_x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftDeploymentToolkit_x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftDeploymentToolkit_x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftDeploymentToolkit_x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DevSkim.CLI.DotNetTool v1.0.59 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DevSkim/CLI/DotNetTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DevSkim.CLI.DotNetTool v1.0.59"

FILEPATH="$PKG_DIR/DevSkim_CLI_netcoreapp_1.0.59.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DevSkim_CLI_netcoreapp_1.0.59.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DevSkim_CLI_netcoreapp_1.0.59.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DevSkim/releases/download/v1.0.59/DevSkim_CLI_netcoreapp_1.0.59.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DevSkim_CLI_netcoreapp_1.0.59.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DevSkim.CLI.LibraryPackage v1.0.59 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DevSkim/CLI/LibraryPackage"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DevSkim.CLI.LibraryPackage v1.0.59"

FILEPATH="$PKG_DIR/DevSkim_CLI_win_1.0.59.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DevSkim_CLI_win_1.0.59.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DevSkim_CLI_win_1.0.59.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DevSkim/releases/download/v1.0.59/DevSkim_CLI_win_1.0.59.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DevSkim_CLI_win_1.0.59.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DirectAccessCTST v1.4.4.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DirectAccessCTST"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DirectAccessCTST v1.4.4.0"

FILEPATH="$PKG_DIR/DirectAccessClientTroubleshooter.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DirectAccessClientTroubleshooter.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DirectAccessClientTroubleshooter.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/a/d/0/ad0ef574-fa76-430e-b122-ae0f36dba55e/DirectAccessClientTroubleshooter.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DirectAccessClientTroubleshooter.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DirectX v9.29.1974.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DirectX"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DirectX v9.29.1974.0"

FILEPATH="$PKG_DIR/UAPSignedBinary_Microsoft.DirectX.x64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: UAPSignedBinary_Microsoft.DirectX.x64.appx (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: UAPSignedBinary_Microsoft.DirectX.x64.appx (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: UAPSignedBinary_Microsoft.DirectX.x64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/UAPSignedBinary_Microsoft.DirectX.x86.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: UAPSignedBinary_Microsoft.DirectX.x86.appx (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: UAPSignedBinary_Microsoft.DirectX.x86.appx (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/c/2/cc291a37-2ebd-4ac2-ba5f-4c9124733bf1/UAPSignedBinary_Microsoft.DirectX.x86.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: UAPSignedBinary_Microsoft.DirectX.x86.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dxwebsetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dxwebsetup.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dxwebsetup.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/7/1/1718ccc4-6315-4d8e-9543-8e28a4e18c4c/dxwebsetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dxwebsetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DirectXTex.Texassemble v2026.3.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DirectXTex/Texassemble"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DirectXTex.Texassemble v2026.3.31"

FILEPATH="$PKG_DIR/texassemble.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texassemble.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texassemble.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texassemble.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/texassemble_arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texassemble_arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texassemble_arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texassemble_arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DirectXTex.Texconv v2026.3.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DirectXTex/Texconv"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DirectXTex.Texconv v2026.3.31"

FILEPATH="$PKG_DIR/texconv.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texconv.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texconv.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texconv.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/texconv_arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texconv_arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texconv_arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texconv_arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DirectXTex.Texdiag v2026.3.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DirectXTex/Texdiag"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DirectXTex.Texdiag v2026.3.31"

FILEPATH="$PKG_DIR/texdiag.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texdiag.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texdiag.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texdiag.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/texdiag_arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: texdiag_arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: texdiag_arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: texdiag_arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DiskSpd v2.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DiskSpd"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DiskSpd v2.2"

FILEPATH="$PKG_DIR/DiskSpd.ZIP"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DiskSpd.ZIP (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DiskSpd.ZIP (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/diskspd/releases/download/v2.2/DiskSpd.ZIP" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DiskSpd.ZIP"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.AspNetCore.10 v10.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/AspNetCore/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.AspNetCore.10 v10.0.7"

FILEPATH="$PKG_DIR/aspnetcore-runtime-10.0.7-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-10.0.7-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-10.0.7-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-10.0.7-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-10.0.7-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-10.0.7-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.AspNetCore.6 v6.0.36 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/AspNetCore/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.AspNetCore.6 v6.0.36"

FILEPATH="$PKG_DIR/aspnetcore-runtime-6.0.36-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-6.0.36-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-6.0.36-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/aspnetcore-runtime-6.0.36-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-6.0.36-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-6.0.36-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-6.0.36-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-6.0.36-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/aspnetcore-runtime-6.0.36-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-6.0.36-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.AspNetCore.8 v8.0.26 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/AspNetCore/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.AspNetCore.8 v8.0.26"

FILEPATH="$PKG_DIR/aspnetcore-runtime-8.0.26-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-8.0.26-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-8.0.26-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-8.0.26-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-8.0.26-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/aspnetcore-runtime-8.0.26-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-8.0.26-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.AspNetCore.9 v9.0.15 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/AspNetCore/9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.AspNetCore.9 v9.0.15"

FILEPATH="$PKG_DIR/aspnetcore-runtime-9.0.15-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-9.0.15-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/aspnetcore-runtime-9.0.15-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: aspnetcore-runtime-9.0.15-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: aspnetcore-runtime-9.0.15-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/aspnetcore-runtime-9.0.15-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: aspnetcore-runtime-9.0.15-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.DesktopRuntime.10 v10.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/DesktopRuntime/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.DesktopRuntime.10 v10.0.7"

FILEPATH="$PKG_DIR/windowsdesktop-runtime-10.0.7-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-10.0.7-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-10.0.7-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-10.0.7-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-10.0.7-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.7/windowsdesktop-runtime-10.0.7-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-10.0.7-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.DesktopRuntime.6 v6.0.36 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/DesktopRuntime/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.DesktopRuntime.6 v6.0.36"

FILEPATH="$PKG_DIR/windowsdesktop-runtime-6.0.36-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-6.0.36-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-6.0.36-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-6.0.36-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-6.0.36-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-6.0.36-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-6.0.36-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-6.0.36-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-6.0.36-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-6.0.36-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-6.0.36-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-6.0.36-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.DesktopRuntime.8 v8.0.26 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/DesktopRuntime/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.DesktopRuntime.8 v8.0.26"

FILEPATH="$PKG_DIR/windowsdesktop-runtime-8.0.26-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-8.0.26-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-8.0.26-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-8.0.26-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-8.0.26-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/8.0.26/windowsdesktop-runtime-8.0.26-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-8.0.26-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.DesktopRuntime.9 v9.0.15 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/DesktopRuntime/9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.DesktopRuntime.9 v9.0.15"

FILEPATH="$PKG_DIR/windowsdesktop-runtime-9.0.15-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-9.0.15-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsdesktop-runtime-9.0.15-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsdesktop-runtime-9.0.15-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsdesktop-runtime-9.0.15-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/9.0.15/windowsdesktop-runtime-9.0.15-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsdesktop-runtime-9.0.15-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Framework.DeveloperPack.4.6 v4.6.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Framework/DeveloperPack/4/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Framework.DeveloperPack.4.6 v4.6.2"

FILEPATH="$PKG_DIR/NDP462-DevPack-KB3151934-ENU.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: NDP462-DevPack-KB3151934-ENU.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: NDP462-DevPack-KB3151934-ENU.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e/e/c/eec79116-8305-4bd0-aa83-27610987eec6/NDP462-DevPack-KB3151934-ENU.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: NDP462-DevPack-KB3151934-ENU.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Framework/DeveloperPack_4"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1"

FILEPATH="$PKG_DIR/NDP481-DevPack-ENU.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: NDP481-DevPack-ENU.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: NDP481-DevPack-ENU.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/1/8/81877d8b-a9b2-4153-9ad2-63a6441d11dd/NDP481-DevPack-ENU.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: NDP481-DevPack-ENU.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Framework.Runtime v4.8.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Framework/Runtime"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Framework.Runtime v4.8.1"

FILEPATH="$PKG_DIR/NDP481-x86-x64-AllOS-ENU.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: NDP481-x86-x64-AllOS-ENU.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: NDP481-x86-x64-AllOS-ENU.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/4/b/2/cd00d4ed-ebdd-49ee-8a33-eabc3d1030e3/NDP481-x86-x64-AllOS-ENU.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: NDP481-x86-x64-AllOS-ENU.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.HostingBundle.10 v10.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/HostingBundle/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.HostingBundle.10 v10.0.7"

FILEPATH="$PKG_DIR/dotnet-hosting-10.0.7-win.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-hosting-10.0.7-win.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-hosting-10.0.7-win.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/dotnet-hosting-10.0.7-win.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-hosting-10.0.7-win.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.HostingBundle.6 v6.0.36 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/HostingBundle/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.HostingBundle.6 v6.0.36"

FILEPATH="$PKG_DIR/dotnet-hosting-6.0.36-win.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-hosting-6.0.36-win.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-hosting-6.0.36-win.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/6.0.36/dotnet-hosting-6.0.36-win.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-hosting-6.0.36-win.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.HostingBundle.8 v8.0.26 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/HostingBundle/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.HostingBundle.8 v8.0.26"

FILEPATH="$PKG_DIR/dotnet-hosting-8.0.26-win.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-hosting-8.0.26-win.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-hosting-8.0.26-win.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.26/dotnet-hosting-8.0.26-win.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-hosting-8.0.26-win.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.HostingBundle.9 v9.0.15 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/HostingBundle/9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.HostingBundle.9 v9.0.15"

FILEPATH="$PKG_DIR/dotnet-hosting-9.0.15-win.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-hosting-9.0.15-win.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-hosting-9.0.15-win.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/9.0.15/dotnet-hosting-9.0.15-win.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-hosting-9.0.15-win.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.RepairTool v1.4 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/RepairTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.RepairTool v1.4"

FILEPATH="$PKG_DIR/NetFxRepairTool.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: NetFxRepairTool.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: NetFxRepairTool.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/2/b/d/2bde5459-2225-48b8-830c-ae19caf038f1/NetFxRepairTool.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: NetFxRepairTool.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Runtime.10 v10.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Runtime/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Runtime.10 v10.0.7"

FILEPATH="$PKG_DIR/dotnet-runtime-10.0.7-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-10.0.7-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-10.0.7-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-10.0.7-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-10.0.7-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-10.0.7-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-10.0.7-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-10.0.7-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-10.0.7-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/10.0.7/dotnet-runtime-10.0.7-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-10.0.7-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Runtime.6 v6.0.36 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Runtime/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Runtime.6 v6.0.36"

FILEPATH="$PKG_DIR/dotnet-runtime-6.0.36-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-6.0.36-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-6.0.36-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-6.0.36-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-6.0.36-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-6.0.36-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-6.0.36-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-6.0.36-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-6.0.36-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-6.0.36-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-6.0.36-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/6.0.36/dotnet-runtime-6.0.36-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-6.0.36-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Runtime.8 v8.0.26 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Runtime/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Runtime.8 v8.0.26"

FILEPATH="$PKG_DIR/dotnet-runtime-8.0.26-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-8.0.26-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-8.0.26-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-8.0.26-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-8.0.26-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-8.0.26-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-8.0.26-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-8.0.26-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-8.0.26-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/8.0.26/dotnet-runtime-8.0.26-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-8.0.26-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.Runtime.9 v9.0.15 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/Runtime/9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.Runtime.9 v9.0.15"

FILEPATH="$PKG_DIR/dotnet-runtime-9.0.15-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-9.0.15-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-9.0.15-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-9.0.15-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-9.0.15-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-9.0.15-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-runtime-9.0.15-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-runtime-9.0.15-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-runtime-9.0.15-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Runtime/9.0.15/dotnet-runtime-9.0.15-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-runtime-9.0.15-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.SDK.10 v10.0.203 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/SDK/10"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.SDK.10 v10.0.203"

FILEPATH="$PKG_DIR/dotnet-sdk-10.0.203-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-10.0.203-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-10.0.203-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-10.0.203-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-10.0.203-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-10.0.203-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-10.0.203-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-10.0.203-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-10.0.203-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/10.0.203/dotnet-sdk-10.0.203-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-10.0.203-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.SDK.6 v6.0.428 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/SDK/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.SDK.6 v6.0.428"

FILEPATH="$PKG_DIR/dotnet-sdk-6.0.428-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-6.0.428-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-6.0.428-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/6.0.428/dotnet-sdk-6.0.428-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-6.0.428-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-6.0.428-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-6.0.428-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-6.0.428-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/6.0.428/dotnet-sdk-6.0.428-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-6.0.428-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-6.0.428-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-6.0.428-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-6.0.428-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/6.0.428/dotnet-sdk-6.0.428-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-6.0.428-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.SDK.8 v8.0.420 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/SDK/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.SDK.8 v8.0.420"

FILEPATH="$PKG_DIR/dotnet-sdk-8.0.420-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-8.0.420-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-8.0.420-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-8.0.420-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-8.0.420-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-8.0.420-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-8.0.420-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-8.0.420-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-8.0.420-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/8.0.420/dotnet-sdk-8.0.420-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-8.0.420-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.SDK.9 v9.0.313 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/SDK/9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.SDK.9 v9.0.313"

FILEPATH="$PKG_DIR/dotnet-sdk-9.0.313-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-9.0.313-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-9.0.313-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-9.0.313-win-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-9.0.313-win-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-9.0.313-win-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/dotnet-sdk-9.0.313-win-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-sdk-9.0.313-win-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-sdk-9.0.313-win-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://builds.dotnet.microsoft.com/dotnet/Sdk/9.0.313/dotnet-sdk-9.0.313-win-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-sdk-9.0.313-win-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.UninstallTool v1.7.661902 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/UninstallTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.UninstallTool v1.7.661902"

FILEPATH="$PKG_DIR/dotnet-core-uninstall.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-core-uninstall.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-core-uninstall.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/dotnet/cli-lab/releases/download/1.7.661902/dotnet-core-uninstall.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-core-uninstall.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.DotNet.dotnet-ef v10.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/DotNet/dotnet-ef"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.DotNet.dotnet-ef v10.0.7"

FILEPATH="$PKG_DIR/dotnet-ef.10.0.7.nupkg"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: dotnet-ef.10.0.7.nupkg (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: dotnet-ef.10.0.7.nupkg (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://globalcdn.nuget.org/packages/dotnet-ef.10.0.7.nupkg" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: dotnet-ef.10.0.7.nupkg"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Edge v147.0.3912.86 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Edge"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Edge v147.0.3912.86"

FILEPATH="$PKG_DIR/MicrosoftEdgeEnterpriseX86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeEnterpriseX86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeEnterpriseX86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/ecf38857-d903-464d-8194-e0c53cf12d70/MicrosoftEdgeEnterpriseX86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeEnterpriseX86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MicrosoftEdgeEnterpriseX64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeEnterpriseX64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeEnterpriseX64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/2d48f894-08d6-4212-99bc-319200435457/MicrosoftEdgeEnterpriseX64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeEnterpriseX64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MicrosoftEdgeEnterpriseARM64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeEnterpriseARM64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeEnterpriseARM64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/3affa9c5-86b9-4dc6-8a78-6332060dca2e/MicrosoftEdgeEnterpriseARM64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeEnterpriseARM64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.EdgeDriver v147.0.3912.86 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/EdgeDriver"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.EdgeDriver v147.0.3912.86"

FILEPATH="$PKG_DIR/edgedriver_win32.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: edgedriver_win32.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: edgedriver_win32.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://msedgedriver.microsoft.com/147.0.3912.86/edgedriver_win32.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: edgedriver_win32.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/edgedriver_win64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: edgedriver_win64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: edgedriver_win64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://msedgedriver.microsoft.com/147.0.3912.86/edgedriver_win64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: edgedriver_win64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/edgedriver_arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: edgedriver_arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: edgedriver_arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://msedgedriver.microsoft.com/147.0.3912.86/edgedriver_arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: edgedriver_arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.EdgeWebView2Runtime v147.0.3912.98 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/EdgeWebView2Runtime"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.EdgeWebView2Runtime v147.0.3912.98"

FILEPATH="$PKG_DIR/MicrosoftEdgeWebView2RuntimeInstallerX86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerX86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerX86.exe (x86/user)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/897cbefb-29fa-4846-94e9-20e01c74e00c/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerX86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerX64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerX64.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/f67cc405-2a0b-4df8-b641-023a0ee89f01/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/bf488e2b-bbbe-437d-bab0-436107a31c14/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftEdgeWebView2RuntimeInstallerARM64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Edit v2.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Edit"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Edit v2.0.0"

FILEPATH="$PKG_DIR/edit-2.0.0-x86_64-windows.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: edit-2.0.0-x86_64-windows.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: edit-2.0.0-x86_64-windows.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/edit/releases/download/v2.0.0/edit-2.0.0-x86_64-windows.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: edit-2.0.0-x86_64-windows.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/edit-2.0.0-aarch64-windows.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: edit-2.0.0-aarch64-windows.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: edit-2.0.0-aarch64-windows.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/edit/releases/download/v2.0.0/edit-2.0.0-aarch64-windows.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: edit-2.0.0-aarch64-windows.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.EnterpriseStateClassify v1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/EnterpriseStateClassify"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.EnterpriseStateClassify v1.0"

FILEPATH="$PKG_DIR/EnterpriseStateClassify.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: EnterpriseStateClassify.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: EnterpriseStateClassify.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/EnterpriseStateClassify/releases/download/v1.0/EnterpriseStateClassify.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: EnterpriseStateClassify.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.EventLogExpert v25.12.11.1105 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/EventLogExpert"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.EventLogExpert v25.12.11.1105"

FILEPATH="$PKG_DIR/EventLogExpert_25.12.11.1105_x64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: EventLogExpert_25.12.11.1105_x64.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: EventLogExpert_25.12.11.1105_x64.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/EventLogExpert/releases/download/v25.12.11.1105/EventLogExpert_25.12.11.1105_x64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: EventLogExpert_25.12.11.1105_x64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.FRSDiag v1.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/FRSDiag"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.FRSDiag v1.7"

FILEPATH="$PKG_DIR/frsdiag.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: frsdiag.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: frsdiag.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/4/c/5/4c5144f0-44cd-4a86-aca9-1cd5fdcde9ec/frsdiag.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: frsdiag.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.FSLogix v3.26.126.19110 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/FSLogix"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.FSLogix v3.26.126.19110"

FILEPATH="$PKG_DIR/FSLogix_26.01_CU1.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: FSLogix_26.01_CU1.zip (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: FSLogix_26.01_CU1.zip (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e9eed5b4-83ff-4b93-bf87-765509e6fd85/FSLogix_26.01_CU1.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: FSLogix_26.01_CU1.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.FoundryLocal v0.8.119.102 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/FoundryLocal"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.FoundryLocal v0.8.119.102"

FILEPATH="$PKG_DIR/FoundryLocal-x64-0.8.119.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: FoundryLocal-x64-0.8.119.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: FoundryLocal-x64-0.8.119.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://foundry.onnxruntime.ai/FoundryLocal-x64-0.8.119.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: FoundryLocal-x64-0.8.119.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/FoundryLocal-arm64-0.8.119.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: FoundryLocal-arm64-0.8.119.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: FoundryLocal-arm64-0.8.119.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://foundry.onnxruntime.ai/FoundryLocal-arm64-0.8.119.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: FoundryLocal-arm64-0.8.119.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.FuzzyLookupAddExcel v1.3.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/FuzzyLookupAddExcel"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.FuzzyLookupAddExcel v1.3.0.0"

FILEPATH="$PKG_DIR/Setup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Setup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Setup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/9/8/198838b0-4ddf-4a50-aae3-7210680c3be6/Setup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Setup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.GameInput v3.3.195.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/GameInput"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.GameInput v3.3.195.0"

FILEPATH="$PKG_DIR/GameInputRedist.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GameInputRedist.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GameInputRedist.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoftconnect/GameInput/releases/download/v3.3.195.0/GameInputRedist.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GameInputRedist.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Garnet.DN8 v1.0.83 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Garnet/DN8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Garnet.DN8 v1.0.83"

FILEPATH="$PKG_DIR/win-x64-based-readytorun.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-x64-based-readytorun.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-x64-based-readytorun.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-x64-based-readytorun.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-x64-based-readytorun.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/win-arm64-based-readytorun.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-arm64-based-readytorun.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-arm64-based-readytorun.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-arm64-based-readytorun.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-arm64-based-readytorun.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Garnet.DN9 v1.0.83 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Garnet/DN9"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Garnet.DN9 v1.0.83"

FILEPATH="$PKG_DIR/win-x64-based-readytorun.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-x64-based-readytorun.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-x64-based-readytorun.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-x64-based-readytorun.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-x64-based-readytorun.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/win-arm64-based-readytorun.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-arm64-based-readytorun.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-arm64-based-readytorun.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/garnet/releases/download/v1.0.83/win-arm64-based-readytorun.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-arm64-based-readytorun.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Git v2.53.0.0.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Git"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Git v2.53.0.0.7"

FILEPATH="$PKG_DIR/Git-2.53.0.vfs.0.7-64-bit.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Git-2.53.0.vfs.0.7-64-bit.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Git-2.53.0.vfs.0.7-64-bit.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/git/releases/download/v2.53.0.vfs.0.7/Git-2.53.0.vfs.0.7-64-bit.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Git-2.53.0.vfs.0.7-64-bit.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Git-2.53.0.vfs.0.7-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Git-2.53.0.vfs.0.7-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Git-2.53.0.vfs.0.7-arm64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/git/releases/download/v2.53.0.vfs.0.7/Git-2.53.0.vfs.0.7-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Git-2.53.0.vfs.0.7-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.GlobalSecureAccessClient v2.26.108 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/GlobalSecureAccessClient"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.GlobalSecureAccessClient v2.26.108"

FILEPATH="$PKG_DIR/GlobalSecureAccessClientArm64Installer"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: GlobalSecureAccessClientArm64Installer (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: GlobalSecureAccessClientArm64Installer (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.msappproxy.net/Subscription/b8795d5c-2a52-4259-9dc9-bff6eb3e15d7/Connector/GlobalSecureAccessClientArm64Installer" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: GlobalSecureAccessClientArm64Installer"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.HIDTools.Waratah v1.90 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/HIDTools/Waratah"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.HIDTools.Waratah v1.90"

FILEPATH="$PKG_DIR/Waratah-Published.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Waratah-Published.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Waratah-Published.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/hidtools/releases/download/Waratah-v1.90/Waratah-Published.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Waratah-Published.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.HwpConverter v15.0.4454.1506 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/HwpConverter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.HwpConverter v15.0.4454.1506"

FILEPATH="$PKG_DIR/HwpConverter_x86_en-us.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: HwpConverter_x86_en-us.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: HwpConverter_x86_en-us.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/1/A/11A1DF9C-D310-498E-B213-53758BFBF168/HwpConverter_x86_en-us.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: HwpConverter_x86_en-us.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/HwpConverter_x64_en-us.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: HwpConverter_x64_en-us.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: HwpConverter_x64_en-us.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/1/A/11A1DF9C-D310-498E-B213-53758BFBF168/HwpConverter_x64_en-us.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: HwpConverter_x64_en-us.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/HwpConverter_x86_ko-kr.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: HwpConverter_x86_ko-kr.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: HwpConverter_x86_ko-kr.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/B/F/8/BF8D9F34-A5BB-49AE-A58B-BC8F73DE0A16/HwpConverter_x86_ko-kr.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: HwpConverter_x86_ko-kr.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/HwpConverter_x64_ko-kr.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: HwpConverter_x64_ko-kr.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: HwpConverter_x64_ko-kr.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/B/F/8/BF8D9F34-A5BB-49AE-A58B-BC8F73DE0A16/HwpConverter_x64_ko-kr.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: HwpConverter_x64_ko-kr.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IIS.Compression v1.0.06502 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IIS/Compression"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IIS.Compression v1.0.06502"

FILEPATH="$PKG_DIR/iiscompression_amd64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: iiscompression_amd64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: iiscompression_amd64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_amd64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: iiscompression_amd64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/iiscompression_x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: iiscompression_x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: iiscompression_x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/1/C/61CC0718-ED0E-4351-BC54-46495EBF5CC3/iiscompression_x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: iiscompression_x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IIS.ServiceMonitor v2.0.1.10 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IIS/ServiceMonitor"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IIS.ServiceMonitor v2.0.1.10"

FILEPATH="$PKG_DIR/ServiceMonitor.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ServiceMonitor.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ServiceMonitor.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/IIS.ServiceMonitor/releases/download/v2.0.1.10/ServiceMonitor.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ServiceMonitor.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IIS.URLRewrite v7.2.1993 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IIS/URLRewrite"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IIS.URLRewrite v7.2.1993"

FILEPATH="$PKG_DIR/rewrite_amd64_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: rewrite_amd64_en-US.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: rewrite_amd64_en-US.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: rewrite_amd64_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/rewrite_x86_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: rewrite_x86_en-US.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: rewrite_x86_en-US.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/D/8/1/D81E5DD6-1ABB-46B0-9B4B-21894E18B77F/rewrite_x86_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: rewrite_x86_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IISManagerRemoteAdministration v1.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IISManagerRemoteAdministration"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IISManagerRemoteAdministration v1.2"

FILEPATH="$PKG_DIR/inetmgr_amd64_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: inetmgr_amd64_en-US.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: inetmgr_amd64_en-US.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/2/4/3/24374C5F-95A3-41D5-B1DF-34D98FF610A3/inetmgr_amd64_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: inetmgr_amd64_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/inetmgr_x86_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: inetmgr_x86_en-US.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: inetmgr_x86_en-US.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/2/4/3/24374C5F-95A3-41D5-B1DF-34D98FF610A3/inetmgr_x86_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: inetmgr_x86_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IdFix v2.6.0.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IdFix"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IdFix v2.6.0.3"

FILEPATH="$PKG_DIR/IdFix.Setup.2.6.0.3.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: IdFix.Setup.2.6.0.3.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: IdFix.Setup.2.6.0.3.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.2.6.0.3.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: IdFix.Setup.2.6.0.3.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IntegrationRuntime v5.65.9593.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IntegrationRuntime"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IntegrationRuntime v5.65.9593.1"

FILEPATH="$PKG_DIR/IntegrationRuntime_5.65.9593.1.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: IntegrationRuntime_5.65.9593.1.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: IntegrationRuntime_5.65.9593.1.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e/4/7/e4771905-1079-445b-8bf9-8a1a075d8a10/IntegrationRuntime_5.65.9593.1.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: IntegrationRuntime_5.65.9593.1.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IntuneWSLPlugin v1.25.4.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IntuneWSLPlugin"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IntuneWSLPlugin v1.25.4.0"

FILEPATH="$PKG_DIR/IntuneWSLPluginInstaller.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: IntuneWSLPluginInstaller.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: IntuneWSLPluginInstaller.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: IntuneWSLPluginInstaller.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.IronPython.3 v3.4.2.1000 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/IronPython/3"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.IronPython.3 v3.4.2.1000"

FILEPATH="$PKG_DIR/IronPython-3.4.2.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: IronPython-3.4.2.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: IronPython-3.4.2.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/IronLanguages/ironpython3/releases/download/v3.4.2/IronPython-3.4.2.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: IronPython-3.4.2.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Kanagawa v1.2.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Kanagawa"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Kanagawa v1.2.0"

FILEPATH="$PKG_DIR/kanagawa-1.2.0-windows-x86_64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: kanagawa-1.2.0-windows-x86_64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: kanagawa-1.2.0-windows-x86_64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/kanagawa/releases/download/v1.2.0/kanagawa-1.2.0-windows-x86_64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: kanagawa-1.2.0-windows-x86_64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.LAPS v6.2.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/LAPS"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.LAPS v6.2.0.0"

FILEPATH="$PKG_DIR/LAPS.x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LAPS.x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LAPS.x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LAPS.x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/LAPS.x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LAPS.x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LAPS.x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LAPS.x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/LAPS.arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LAPS.arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LAPS.arm64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LAPS.arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.LightGBM v4.6.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/LightGBM"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.LightGBM v4.6.0"

FILEPATH="$PKG_DIR/lightgbm.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: lightgbm.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: lightgbm.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/lightgbm-org/LightGBM/releases/download/v4.6.0/lightgbm.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: lightgbm.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.LingeringObjectLiquidator v2.0.21 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/LingeringObjectLiquidator"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.LingeringObjectLiquidator v2.0.21"

FILEPATH="$PKG_DIR/LingeringObjectLiquidatorInstaller.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LingeringObjectLiquidatorInstaller.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LingeringObjectLiquidatorInstaller.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b/a/a/baa58d37-f8d9-4a92-8321-15cab1deff51/LingeringObjectLiquidatorInstaller.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LingeringObjectLiquidatorInstaller.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.LogCheetah v1.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/LogCheetah"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.LogCheetah v1.0.0"

FILEPATH="$PKG_DIR/LogCheetah-Windows.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LogCheetah-Windows.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LogCheetah-Windows.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/LogCheetah/releases/download/v1.0.0/LogCheetah-Windows.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LogCheetah-Windows.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.LogParser v2.2.10 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/LogParser"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.LogParser v2.2.10"

FILEPATH="$PKG_DIR/LogParser.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LogParser.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LogParser.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f/f/1/ff1819f9-f702-48a5-bbc7-c9656bc74de8/LogParser.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LogParser.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.M365AgentsPlayground v0.2.24 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/M365AgentsPlayground"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.M365AgentsPlayground v0.2.24"

FILEPATH="$PKG_DIR/agentsplayground-win32-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: agentsplayground-win32-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: agentsplayground-win32-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@0.2.24/agentsplayground-win32-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: agentsplayground-win32-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MFCMapi v26.0.26111.02 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MFCMapi"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MFCMapi v26.0.26111.02"

FILEPATH="$PKG_DIR/MFCMAPI.exe.26.0.26111.02.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MFCMAPI.exe.26.0.26111.02.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MFCMAPI.exe.26.0.26111.02.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/mfcmapi/releases/download/26.0.26111.02/MFCMAPI.exe.26.0.26111.02.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MFCMAPI.exe.26.0.26111.02.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MFCMAPI.x64.exe.26.0.26111.02.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MFCMAPI.x64.exe.26.0.26111.02.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MFCMAPI.x64.exe.26.0.26111.02.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/mfcmapi/releases/download/26.0.26111.02/MFCMAPI.x64.exe.26.0.26111.02.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MFCMAPI.x64.exe.26.0.26111.02.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MIDI.FeatureEnablementChecker v1.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MIDI/FeatureEnablementChecker"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MIDI.FeatureEnablementChecker v1.1"

FILEPATH="$PKG_DIR/midicheckservice_x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: midicheckservice_x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: midicheckservice_x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: midicheckservice_x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/midicheckservice_arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: midicheckservice_arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: midicheckservice_arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: midicheckservice_arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MIDI.SDK v1.0.16-rc.3.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MIDI/SDK"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MIDI.SDK v1.0.16-rc.3.7"

FILEPATH="$PKG_DIR/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.16-rc.3.7-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MITT v8.03 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MITT"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MITT v8.03"

FILEPATH="$PKG_DIR/MITT.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MITT.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MITT.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/7/0/7703F03C-9D1F-45FC-A625-9647DC495EE2/MITT.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MITT.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MSIX-Toolkit v10.0.19041.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MSIX-Toolkit"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MSIX-Toolkit v10.0.19041.1"

FILEPATH="$PKG_DIR/MSIX-Toolkit.x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSIX-Toolkit.x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSIX-Toolkit.x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSIX-Toolkit.x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MSIX-Toolkit.x86.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSIX-Toolkit.x86.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSIX-Toolkit.x86.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSIX-Toolkit.x86.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MSIXCore v1.2.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MSIXCore"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MSIXCore v1.2.0.0"

FILEPATH="$PKG_DIR/msixmgrSetup-1.2.0.0-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msixmgrSetup-1.2.0.0-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msixmgrSetup-1.2.0.0-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-1.2.0.0-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msixmgrSetup-1.2.0.0-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msixmgrSetup-1.2.0.0-x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msixmgrSetup-1.2.0.0-x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msixmgrSetup-1.2.0.0-x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-1.2.0.0-x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msixmgrSetup-1.2.0.0-x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msixmgr.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msixmgr.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msixmgr.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msixmgr.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MSIXPackagingTool v1.2024.405.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MSIXPackagingTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MSIXPackagingTool v1.2024.405.0"

FILEPATH="$PKG_DIR/MSIXPackagingtoolv1.2024.405.0.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSIXPackagingtoolv1.2024.405.0.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSIXPackagingtoolv1.2024.405.0.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e/2/e/e2e923b2-7a3a-4730-969d-ab37001fbb5e/MSIXPackagingtoolv1.2024.405.0.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSIXPackagingtoolv1.2024.405.0.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MUTT v3.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MUTT"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MUTT v3.0.0"

FILEPATH="$PKG_DIR/MUTTPackage-3_0_0.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MUTTPackage-3_0_0.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MUTTPackage-3_0_0.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3856f445-db3d-4e15-ac03-622bfd453e12/MUTTPackage-3_0_0.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MUTTPackage-3_0_0.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MaliciousSoftwareRemovalTool v5.139 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MaliciousSoftwareRemovalTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MaliciousSoftwareRemovalTool v5.139"

FILEPATH="$PKG_DIR/Windows-KB890830-V5.139.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows-KB890830-V5.139.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows-KB890830-V5.139.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/4/a/a/4aa524c6-239d-47ff-860b-5b397199cbf8/Windows-KB890830-V5.139.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows-KB890830-V5.139.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Windows-KB890830-x64-V5.139.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows-KB890830-x64-V5.139.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows-KB890830-x64-V5.139.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/2/c/5/2c563b99-54d9-4d85-a82b-45d3cd2f53ce/Windows-KB890830-x64-V2/c/5/2c563b99-54d9-4d85-a82b-45d3cd2f53ce/Windows-KB890830-x64-V5.139.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows-KB890830-x64-V5.139.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MediaCreationTool v10.0.26100.7019 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MediaCreationTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MediaCreationTool v10.0.26100.7019"

FILEPATH="$PKG_DIR/MediaCreationTool.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MediaCreationTool.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MediaCreationTool.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/0a8b07d9-a3bf-47b9-b71b-8e13354cec88/MediaCreationTool.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MediaCreationTool.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MouseWithoutBorders v2.2.1.327 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MouseWithoutBorders"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MouseWithoutBorders v2.2.1.327"

FILEPATH="$PKG_DIR/MouseWithoutBordersSetup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MouseWithoutBordersSetup.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MouseWithoutBordersSetup.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/5/8/658AFC4C-DC02-4CB8-839D-10253E89FFF7/MouseWithoutBordersSetup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MouseWithoutBordersSetup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.MouseandKeyboardCenter v14.41.137.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/MouseandKeyboardCenter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.MouseandKeyboardCenter v14.41.137.0"

FILEPATH="$PKG_DIR/MouseKeyboardCenter_64bit_ENG_14.41.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MouseKeyboardCenter_64bit_ENG_14.41.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MouseKeyboardCenter_64bit_ENG_14.41.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_64bit_ENG_14.41.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MouseKeyboardCenter_64bit_ENG_14.41.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MouseKeyboardCenter_32bit_ENG_14.41.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MouseKeyboardCenter_32bit_ENG_14.41.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MouseKeyboardCenter_32bit_ENG_14.41.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_32bit_ENG_14.41.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MouseKeyboardCenter_32bit_ENG_14.41.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MouseKeyboardCenter_ARM64_ENG_14.41.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MouseKeyboardCenter_ARM64_ENG_14.41.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MouseKeyboardCenter_ARM64_ENG_14.41.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/3/5/c35ae8d6-d607-4095-8eb8-ca1860dc2175/MouseKeyboardCenter_ARM64_ENG_14.41.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MouseKeyboardCenter_ARM64_ENG_14.41.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Ntttcp v5.40.0.99012574 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Ntttcp"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Ntttcp v5.40.0.99012574"

FILEPATH="$PKG_DIR/ntttcp.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ntttcp.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ntttcp.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/ntttcp/releases/download/v5.40/ntttcp.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ntttcp.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/ntttcp_arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ntttcp_arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ntttcp_arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/ntttcp/releases/download/v5.40/ntttcp_arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ntttcp_arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.NuGet v7.3.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/NuGet"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.NuGet v7.3.1"

FILEPATH="$PKG_DIR/nuget.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: nuget.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: nuget.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://dist.nuget.org/win-x86-commandline/v7.3.1/nuget.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: nuget.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OSCDIMG v2.56 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OSCDIMG"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OSCDIMG v2.56"

FILEPATH="$PKG_DIR/oscdimg.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: oscdimg.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: oscdimg.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://msdl.microsoft.com/download/symbols/oscdimg.exe/688CABB065000/oscdimg.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: oscdimg.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OSConfig v1.3.10.13 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OSConfig"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OSConfig v1.3.10.13"

FILEPATH="$PKG_DIR/Microsoft.OSConfig-1.3.10.13.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.OSConfig-1.3.10.13.msixbundle (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.OSConfig-1.3.10.13.msixbundle (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/Microsoft.OSConfig-1.3.10.13.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.OSConfig-1.3.10.13.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: oscfg-1.3.10-preview13-aarch64_pc_windows_msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/osconfig/releases/download/1.3.10-preview13/oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: oscfg-1.3.10-preview13-x86_64_pc_windows_msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Office v16.0.19929.20062 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Office"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Office v16.0.19929.20062"

FILEPATH="$PKG_DIR/setup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: setup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: setup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://officecdn.microsoft.com/pr/wsus/setup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: setup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OfficeDeploymentTool v16.0.19929.20062 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OfficeDeploymentTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OfficeDeploymentTool v16.0.19929.20062"

FILEPATH="$PKG_DIR/officedeploymenttool_19929-20062.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: officedeploymenttool_19929-20062.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: officedeploymenttool_19929-20062.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6c1eeb25-cf8b-41d9-8d0d-cc1dbc032140/officedeploymenttool_19929-20062.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: officedeploymenttool_19929-20062.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OneDrive v26.062.0402.0002 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OneDrive"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OneDrive v26.062.0402.0002"

FILEPATH="$PKG_DIR/OneDriveSetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: OneDriveSetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: OneDriveSetup.exe (x86/user)"
  if curl -fSL -o "$FILEPATH" "https://oneclient.sfx.ms/Win/Installers/26.062.0402.0002/OneDriveSetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: OneDriveSetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/OneDriveSetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: OneDriveSetup.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: OneDriveSetup.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://oneclient.sfx.ms/Win/Installers/26.062.0402.0002/amd64/OneDriveSetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: OneDriveSetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/OneDriveSetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: OneDriveSetup.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: OneDriveSetup.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://oneclient.sfx.ms/Win/Installers/26.062.0402.0002/arm64/OneDriveSetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: OneDriveSetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OneLakeFileExplorer v1.0.14.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OneLakeFileExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OneLakeFileExplorer v1.0.14.0"

FILEPATH="$PKG_DIR/OneLake_PuPr_1.0.14.0.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: OneLake_PuPr_1.0.14.0.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: OneLake_PuPr_1.0.14.0.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/143fe9b7-9e20-4683-961e-656261c16943/OneLake_PuPr_1.0.14.0.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: OneLake_PuPr_1.0.14.0.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OneNoteDiagnostics v1.0.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OneNoteDiagnostics"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OneNoteDiagnostics v1.0.0.0"

FILEPATH="$PKG_DIR/onenotediagnosticsinstaller.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: onenotediagnosticsinstaller.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: onenotediagnosticsinstaller.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/9/a/7/9a798d60-ccb1-4b90-b612-8ea3745b7cbe/onenotediagnosticsinstaller.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: onenotediagnosticsinstaller.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenAPI.Hidi v3.1.2.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenAPI/Hidi"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenAPI.Hidi v3.1.2.0"

FILEPATH="$PKG_DIR/Microsoft.OpenApi.Hidi.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.OpenApi.Hidi.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.OpenApi.Hidi.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/OpenAPI.NET/releases/download/v3.1.2/Microsoft.OpenApi.Hidi.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.OpenApi.Hidi.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenAPI.Kiota v1.30.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenAPI/Kiota"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenAPI.Kiota v1.30.0"

FILEPATH="$PKG_DIR/win-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/win-x86.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-x86.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-x86.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-x86.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-x86.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/win-arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: win-arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: win-arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/kiota/releases/download/v1.30.0/win-arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: win-arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenCLGLVulkanCompatibilityPack"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0"

FILEPATH="$PKG_DIR/Universal_D3DMappingLayers_1.2404.1.0_x64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Universal_D3DMappingLayers_1.2404.1.0_x64.appx (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Universal_D3DMappingLayers_1.2404.1.0_x64.appx (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/OpenCLOn12/releases/download/v1.2404.1.0/Universal_D3DMappingLayers_1.2404.1.0_x64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Universal_D3DMappingLayers_1.2404.1.0_x64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Universal_D3DMappingLayers_1.2404.1.0_arm64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/OpenCLOn12/releases/download/v1.2404.1.0/Universal_D3DMappingLayers_1.2404.1.0_arm64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Universal_D3DMappingLayers_1.2404.1.0_arm64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenJDK.11 v11.0.30.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenJDK/11"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenJDK.11 v11.0.30.7"

FILEPATH="$PKG_DIR/microsoft-JDK-11.0.30-windows-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-11.0.30-windows-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-11.0.30-windows-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-11.0.30-windows-x64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-11.0.30-windows-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/microsoft-JDK-11.0.30-windows-aarch64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-11.0.30-windows-aarch64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-11.0.30-windows-aarch64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-11.0.30-windows-aarch64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-11.0.30-windows-aarch64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenJDK.17 v17.0.18.8 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenJDK/17"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenJDK.17 v17.0.18.8"

FILEPATH="$PKG_DIR/microsoft-JDK-17.0.18-windows-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-17.0.18-windows-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-17.0.18-windows-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-17.0.18-windows-x64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-17.0.18-windows-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/microsoft-JDK-17.0.18-windows-aarch64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-17.0.18-windows-aarch64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-17.0.18-windows-aarch64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-17.0.18-windows-aarch64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-17.0.18-windows-aarch64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenJDK.21 v21.0.10.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenJDK/21"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenJDK.21 v21.0.10.7"

FILEPATH="$PKG_DIR/microsoft-JDK-21.0.10-windows-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-21.0.10-windows-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-21.0.10-windows-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-21.0.10-windows-x64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-21.0.10-windows-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/microsoft-JDK-21.0.10-windows-aarch64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-21.0.10-windows-aarch64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-21.0.10-windows-aarch64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-21.0.10-windows-aarch64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-21.0.10-windows-aarch64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.OpenJDK.25 v25.0.2.10 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/OpenJDK/25"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.OpenJDK.25 v25.0.2.10"

FILEPATH="$PKG_DIR/microsoft-JDK-25.0.2-windows-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-25.0.2-windows-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-25.0.2-windows-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-25.0.2-windows-x64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-25.0.2-windows-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/microsoft-JDK-25.0.2-windows-aarch64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: microsoft-JDK-25.0.2-windows-aarch64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: microsoft-JDK-25.0.2-windows-aarch64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/download-JDK/microsoft-JDK-25.0.2-windows-aarch64.msi#winget" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: microsoft-JDK-25.0.2-windows-aarch64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PICT v3.7.4.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PICT"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PICT v3.7.4.0"

FILEPATH="$PKG_DIR/pict.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: pict.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: pict.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/pict/releases/download/v3.7.4/pict.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: pict.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PIX v2603.25 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PIX"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PIX v2603.25"

FILEPATH="$PKG_DIR/PIX-2603.25-Installer-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PIX-2603.25-Installer-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PIX-2603.25-Installer-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6a45de18-2ba5-4702-9ab6-9fb654b57f90/PIX-2603.25-Installer-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PIX-2603.25-Installer-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PIX-2603.25-Installer-ARM64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PIX-2603.25-Installer-ARM64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PIX-2603.25-Installer-ARM64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6a45de18-2ba5-4702-9ab6-9fb654b57f90/PIX-2603.25-Installer-ARM64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PIX-2603.25-Installer-ARM64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Pave v0.1.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Pave"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Pave v0.1.1"

FILEPATH="$PKG_DIR/pave-x86_64-pc-windows-msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: pave-x86_64-pc-windows-msvc.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: pave-x86_64-pc-windows-msvc.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/pave/releases/download/v0.1.1/pave-x86_64-pc-windows-msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: pave-x86_64-pc-windows-msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/pave-aarch64-pc-windows-msvc.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: pave-aarch64-pc-windows-msvc.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: pave-aarch64-pc-windows-msvc.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/pave/releases/download/v0.1.1/pave-aarch64-pc-windows-msvc.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: pave-aarch64-pc-windows-msvc.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PerfView v3.2.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PerfView"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PerfView v3.2.2"

FILEPATH="$PKG_DIR/PerfView.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PerfView.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PerfView.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/perfview/releases/download/v3.2.2/PerfView.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PerfView.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerAppsCLI v1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerAppsCLI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerAppsCLI v1.0"

FILEPATH="$PKG_DIR/powerapps-cli-1.0.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: powerapps-cli-1.0.msi (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: powerapps-cli-1.0.msi (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/D/B/E/DBE69906-B4DA-471C-8960-092AB955C681/powerapps-cli-1.0.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: powerapps-cli-1.0.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerAutomateDesktop v2.67.00143.26090 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerAutomateDesktop"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerAutomateDesktop v2.67.00143.26090"

FILEPATH="$PKG_DIR/Setup.Microsoft.PowerAutomate.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Setup.Microsoft.PowerAutomate.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Setup.Microsoft.PowerAutomate.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/09bdb359-3cc5-4f2e-af38-0b75897aa567/Setup.Microsoft.PowerAutomate.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Setup.Microsoft.PowerAutomate.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerAutomateProcessMining v6.1.2506.2252 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerAutomateProcessMining"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerAutomateProcessMining v6.1.2506.2252"

FILEPATH="$PKG_DIR/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/eead1132-ecfd-44e8-9e95-49996ed93c35/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerBI v2.153.910.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerBI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerBI v2.153.910.0"

FILEPATH="$PKG_DIR/PBIDesktopSetup-2026-04_x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PBIDesktopSetup-2026-04_x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PBIDesktopSetup-2026-04_x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/8/0/880BCA75-79DD-466A-927D-1ABF1F5454B0/PBIDesktopSetup-2026-04_x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PBIDesktopSetup-2026-04_x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerBIReportBuilder v15.7.1817.11 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerBIReportBuilder"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerBIReportBuilder v15.7.1817.11"

FILEPATH="$PKG_DIR/PowerBIReportBuilder.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerBIReportBuilder.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerBIReportBuilder.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/a/2/e/a2ea07b5-5a65-41d7-9ac0-b46ac953ab63/PowerBIReportBuilder.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerBIReportBuilder.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerBIReportServer v1.25.9558.32914 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerBIReportServer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerBIReportServer v1.25.9558.32914"

FILEPATH="$PKG_DIR/PowerBIReportServer.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerBIReportServer.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerBIReportServer.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/2/7/3/2739a88a-4769-4700-8748-1a01ddf60974/PowerBIReportServer.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerBIReportServer.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerShell v7.6.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerShell"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerShell v7.6.1.0"

FILEPATH="$PKG_DIR/PowerShell-7.6.1.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerShell-7.6.1.msixbundle (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerShell-7.6.1.msixbundle (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerShell-7.6.1.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerShell-7.6.1-win-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerShell-7.6.1-win-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerShell-7.6.1-win-x64.msi (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerShell-7.6.1-win-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerShell-7.6.1-win-x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerShell-7.6.1-win-x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerShell-7.6.1-win-x86.msi (x86/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerShell-7.6.1-win-x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerShell-7.6.1-win-arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerShell-7.6.1-win-arm64.msi (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerShell-7.6.1-win-arm64.msi (arm/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/PowerShell/PowerShell/releases/download/v7.6.1/PowerShell-7.6.1-win-arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerShell-7.6.1-win-arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PowerToys v0.99.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PowerToys"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PowerToys v0.99.1"

FILEPATH="$PKG_DIR/PowerToysUserSetup-0.99.1-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerToysUserSetup-0.99.1-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerToysUserSetup-0.99.1-x64.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysUserSetup-0.99.1-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerToysUserSetup-0.99.1-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerToysSetup-0.99.1-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerToysSetup-0.99.1-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerToysSetup-0.99.1-x64.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysSetup-0.99.1-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerToysSetup-0.99.1-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerToysUserSetup-0.99.1-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerToysUserSetup-0.99.1-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerToysUserSetup-0.99.1-arm64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysUserSetup-0.99.1-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerToysUserSetup-0.99.1-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PowerToysSetup-0.99.1-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PowerToysSetup-0.99.1-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PowerToysSetup-0.99.1-arm64.exe (arm64/machine)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/PowerToys/releases/download/v0.99.1/PowerToysSetup-0.99.1-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PowerToysSetup-0.99.1-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PrintMetadataTroubleshooter v1.0.0.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PrintMetadataTroubleshooter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PrintMetadataTroubleshooter v1.0.0.1"

FILEPATH="$PKG_DIR/PrintMetadataTroubleshooterX64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PrintMetadataTroubleshooterX64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PrintMetadataTroubleshooterX64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterX64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PrintMetadataTroubleshooterX64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PrintMetadataTroubleshooterX86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PrintMetadataTroubleshooterX86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PrintMetadataTroubleshooterX86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterX86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PrintMetadataTroubleshooterX86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PrintMetadataTroubleshooterArm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PrintMetadataTroubleshooterArm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PrintMetadataTroubleshooterArm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterArm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PrintMetadataTroubleshooterArm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/PrintMetadataTroubleshooterArm32.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PrintMetadataTroubleshooterArm32.exe (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PrintMetadataTroubleshooterArm32.exe (arm/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/f/2/cf2eb746-25ad-43dc-a542-abb2a3633237/PrintMetadataTroubleshooterArm32.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PrintMetadataTroubleshooterArm32.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ProfileExplorer v1.2.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ProfileExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ProfileExplorer v1.2.1"

FILEPATH="$PKG_DIR/profile_explorer_installer_1.2.1_x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: profile_explorer_installer_1.2.1_x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: profile_explorer_installer_1.2.1_x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/profile-explorer/releases/download/v1.2.1/profile_explorer_installer_1.2.1_x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: profile_explorer_installer_1.2.1_x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/profile_explorer_installer_1.2.1_arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: profile_explorer_installer_1.2.1_arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: profile_explorer_installer_1.2.1_arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/profile-explorer/releases/download/v1.2.1/profile_explorer_installer_1.2.1_arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: profile_explorer_installer_1.2.1_arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ProjectTelescope v0.15.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ProjectTelescope"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ProjectTelescope v0.15.1"

FILEPATH="$PKG_DIR/telescope-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: telescope-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: telescope-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/project-telescope/releases/download/v0.15.1/telescope-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: telescope-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/telescope-arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: telescope-arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: telescope-arm64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/project-telescope/releases/download/v0.15.1/telescope-arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: telescope-arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Promptflow v1.17.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Promptflow"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Promptflow v1.17.1"

FILEPATH="$PKG_DIR/promptflow-1.17.1.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: promptflow-1.17.1.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: promptflow-1.17.1.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://promptflowartifact.blob.core.windows.net/msi-installer/promptflow-1.17.1.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: promptflow-1.17.1.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.PurviewInformationProtection v3.2.57.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/PurviewInformationProtection"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.PurviewInformationProtection v3.2.57.0"

FILEPATH="$PKG_DIR/PurviewInfoProtection.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PurviewInfoProtection.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PurviewInfoProtection.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/5e62f7f5-d616-49f8-b506-f1c6b4f79ba7/PurviewInfoProtection.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PurviewInfoProtection.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.RMSClient v1.0.5406.9 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/RMSClient"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.RMSClient v1.0.5406.9"

FILEPATH="$PKG_DIR/setup_msipc_x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: setup_msipc_x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: setup_msipc_x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3/c/f/3cf781f5-7d29-4035-9265-c34ff2369fa2/setup_msipc_x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: setup_msipc_x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/setup_msipc_x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: setup_msipc_x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: setup_msipc_x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3/c/f/3cf781f5-7d29-4035-9265-c34ff2369fa2/setup_msipc_x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: setup_msipc_x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.RemoteDesktopClient v1.2.7099.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/RemoteDesktopClient"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.RemoteDesktopClient v1.2.7099.0"

FILEPATH="$PKG_DIR/RemoteDesktop_1.2.7099.0_x86.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_x86.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_x86.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/b9fc3474-6a78-4034-b4d7-441c5ccc4b75/RemoteDesktop_1.2.7099.0_x86.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_x86.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/RemoteDesktop_1.2.7099.0_x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/86a34a60-807d-4286-9204-79d252f6ac55/RemoteDesktop_1.2.7099.0_x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/RemoteDesktop_1.2.7099.0_ARM64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RemoteDesktop_1.2.7099.0_ARM64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RemoteDesktop_1.2.7099.0_ARM64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/761aa081-621a-4855-bdbc-bbf982b6b20a/RemoteDesktop_1.2.7099.0_ARM64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RemoteDesktop_1.2.7099.0_ARM64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.RemoteDesktopMMRService v1.0.2507.21006 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/RemoteDesktopMMRService"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.RemoteDesktopMMRService v1.0.2507.21006"

FILEPATH="$PKG_DIR/MsMMRHostInstaller_1.0.2507.21006_x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MsMMRHostInstaller_1.0.2507.21006_x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MsMMRHostInstaller_1.0.2507.21006_x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_1.0.2507.21006_x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MsMMRHostInstaller_1.0.2507.21006_x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.RemoteHelp v5.1.1998.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/RemoteHelp"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.RemoteHelp v5.1.1998.0"

FILEPATH="$PKG_DIR/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ReportBuilder v15.1.30001.02 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ReportBuilder"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ReportBuilder v15.1.30001.02"

FILEPATH="$PKG_DIR/ReportBuilder.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ReportBuilder.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ReportBuilder.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/5/E/B/5EB40744-DC0A-47C0-8B0A-1830E74D3C23/ReportBuilder.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ReportBuilder.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SBOMTool v4.1.5 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SBOMTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SBOMTool v4.1.5"

FILEPATH="$PKG_DIR/sbom-tool-win-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: sbom-tool-win-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: sbom-tool-win-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/sbom-tool/releases/download/v4.1.5/sbom-tool-win-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: sbom-tool-win-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2019.Developer v15.2204.5490.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2019/Developer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2019.Developer v15.2204.5490.2"

FILEPATH="$PKG_DIR/SQL2019-SSEI-Dev.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2019-SSEI-Dev.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2019-SSEI-Dev.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/d/a/2/da259851-b941-459d-989c-54a18a5d44dd/SQL2019-SSEI-Dev.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2019-SSEI-Dev.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2019.Express v15.2204.5490.2 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2019/Express"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2019.Express v15.2204.5490.2"

FILEPATH="$PKG_DIR/SQL2019-SSEI-Expr.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2019-SSEI-Expr.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2019-SSEI-Expr.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2019-SSEI-Expr.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2022.Developer v16.0.1000.6 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2022/Developer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2022.Developer v16.0.1000.6"

FILEPATH="$PKG_DIR/SQL2022-SSEI-Dev.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2022-SSEI-Dev.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2022-SSEI-Dev.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c/c/9/cc9c6797-383c-4b24-8920-dc057c1de9d3/SQL2022-SSEI-Dev.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2022-SSEI-Dev.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2022.Express v16.0.1000.6 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2022/Express"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2022.Express v16.0.1000.6"

FILEPATH="$PKG_DIR/SQL2022-SSEI-Expr.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2022-SSEI-Expr.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2022-SSEI-Expr.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/5/1/4/5145fe04-4d30-4b85-b0d1-39533663a2f1/SQL2022-SSEI-Expr.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2022-SSEI-Expr.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2025.Developer v17.0.1000.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2025/Developer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2025.Developer v17.0.1000.7"

FILEPATH="$PKG_DIR/SQL2025-SSEI-StdDev.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2025-SSEI-StdDev.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2025-SSEI-StdDev.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/77dc60d3-0139-4dad-83c8-bb52ab22db01/SQL2025-SSEI-StdDev.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2025-SSEI-StdDev.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.2025.Express v17.0.1000.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/2025/Express"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.2025.Express v17.0.1000.7"

FILEPATH="$PKG_DIR/SQL2025-SSEI-Expr.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SQL2025-SSEI-Expr.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SQL2025-SSEI-Expr.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7ab8f535-7eb8-4b16-82eb-eca0fa2d38f3/SQL2025-SSEI-Expr.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SQL2025-SSEI-Expr.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.OLEDBDriver v19.4.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/OLEDBDriver"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.OLEDBDriver v19.4.1.0"

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b5865bb8-7bc6-4068-9c1d-fb77c256a865/amd64/1033/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/57d4f147-9469-4cff-b368-3f8e54bff9ef/amd64/1031/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c991431e-d91a-415e-95ef-1621cfcbd75f/amd64/1036/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/db361159-7835-4d2b-9f8b-43629518ccc7/amd64/1040/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/ff6ccd4d-eb33-4d32-bb7d-30d26946d55c/amd64/2052/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/ff5fc86c-a788-454f-b990-959533eb47b4/amd64/1028/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f9cc1edc-db28-4fc9-b90d-cb8392ebad60/amd64/1029/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/aae7ae93-05a9-4b84-9692-aeef824a46f2/amd64/1041/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/476609b7-b54b-415c-b260-b14b0a431ea6/amd64/1055/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/728f1f9a-26ca-40ca-8c89-0da3a769eb3a/amd64/3082/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/255462c2-0631-4132-bef9-696d88d3f643/amd64/1046/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/32ba0fe6-9d74-4dfc-b53d-d6f731050732/amd64/1045/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msoledbsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msoledbsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msoledbsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/d48c2ecf-9bf6-473c-b668-12b4955628d8/amd64/1042/msoledbsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msoledbsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServer.RMLUtilities v09.04.0103 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServer/RMLUtilities"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServer.RMLUtilities v09.04.0103"

FILEPATH="$PKG_DIR/RMLSetup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RMLSetup.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RMLSetup.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/5/8/65855c73-97a1-438c-b95e-d610a9bb05b0/RMLSetup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RMLSetup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SQLServerManagementStudio v20.2.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SQLServerManagementStudio"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SQLServerManagementStudio v20.2.1"

FILEPATH="$PKG_DIR/SSMS-Setup-DEU.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-DEU.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-DEU.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-DEU.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-DEU.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-ENU.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-ENU.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-ENU.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ENU.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-ENU.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-ESN.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-ESN.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-ESN.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ESN.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-ESN.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-FRA.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-FRA.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-FRA.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-FRA.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-FRA.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-ITA.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-ITA.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-ITA.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-ITA.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-ITA.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-JPN.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-JPN.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-JPN.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-JPN.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-JPN.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-KOR.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-KOR.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-KOR.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-KOR.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-KOR.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-PTB.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-PTB.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-PTB.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-PTB.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-PTB.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-RUS.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-RUS.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-RUS.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-RUS.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-RUS.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-CHS.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-CHS.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-CHS.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-CHS.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-CHS.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/SSMS-Setup-CHT.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SSMS-Setup-CHT.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SSMS-Setup-CHT.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7519f0ff-997c-4f36-b5aa-9a51d47dd34c/SSMS-Setup-CHT.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SSMS-Setup-CHT.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SaRACmd v17.01.3954.000 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SaRACmd"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SaRACmd v17.01.3954.000"

FILEPATH="$PKG_DIR/SaRACmd_17_01_3954_000.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SaRACmd_17_01_3954_000.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SaRACmd_17_01_3954_000.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/13eaffaa-0961-4a6a-863b-26d1f8b0ca15/SaRACmd_17_01_3954_000.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SaRACmd_17_01_3954_000.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SafetyScanner v1.449.54.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SafetyScanner"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SafetyScanner v1.449.54.0"

FILEPATH="$PKG_DIR/msert.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msert.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msert.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://definitionupdates.microsoft.com/packages/content/msert.exe?packageType=Scanner&packageVersion=1.449.54.0&arch=x86" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msert.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msert.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msert.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msert.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://definitionupdates.microsoft.com/packages/content/msert.exe?packageType=Scanner&packageVersion=1.449.54.0&arch=amd64" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msert.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ScreenRecorder v0.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ScreenRecorder"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ScreenRecorder v0.1.0"

FILEPATH="$PKG_DIR/irexplorer-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: irexplorer-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: irexplorer-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/screenrecorder/releases/download/v0.1.0/irexplorer-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: irexplorer-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SecurityComplianceToolkit/LGPO"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001"

FILEPATH="$PKG_DIR/LGPO.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: LGPO.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: LGPO.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/LGPO.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: LGPO.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SecurityComplianceToolkit/PolicyAnalyzer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001"

FILEPATH="$PKG_DIR/PolicyAnalyzer.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: PolicyAnalyzer.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: PolicyAnalyzer.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/PolicyAnalyzer.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: PolicyAnalyzer.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SecurityComplianceToolkit/SetObjectSecurity"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001"

FILEPATH="$PKG_DIR/SetObjectSecurity.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SetObjectSecurity.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SetObjectSecurity.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/5/c/85c25433-a1b0-4ffa-9429-7e023e7da8d8/SetObjectSecurity.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SetObjectSecurity.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ServiceFabricRuntime v11.3.475.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ServiceFabricRuntime"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ServiceFabricRuntime v11.3.475.1"

FILEPATH="$PKG_DIR/MicrosoftServiceFabric.11.3.475.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftServiceFabric.11.3.475.1.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftServiceFabric.11.3.475.1.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/MicrosoftServiceFabric.11.3.475.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftServiceFabric.11.3.475.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.ServiceFabricSDK v8.3.475 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/ServiceFabricSDK"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.ServiceFabricSDK v8.3.475"

FILEPATH="$PKG_DIR/MicrosoftServiceFabricSDK.8.3.475.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MicrosoftServiceFabricSDK.8.3.475.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MicrosoftServiceFabricSDK.8.3.475.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b/8/a/b8a2fb98-0ec1-41e5-be98-9d8b5abf7856/MicrosoftServiceFabricSDK.8.3.475.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MicrosoftServiceFabricSDK.8.3.475.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SetupDiag v1.7.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SetupDiag"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SetupDiag v1.7.0.0"

FILEPATH="$PKG_DIR/SetupDiag.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SetupDiag.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SetupDiag.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/1/1/111c347e-b7de-4510-8e62-a2f046efcc48/SetupDiag.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SetupDiag.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SmartDump v1.13 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SmartDump"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SmartDump v1.13"

FILEPATH="$PKG_DIR/SmartDump_v1.13.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SmartDump_v1.13.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SmartDump_v1.13.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/SmartDump/releases/download/v1.13/SmartDump_v1.13.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SmartDump_v1.13.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SqlPackage v170.3.93 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SqlPackage"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SqlPackage v170.3.93"

FILEPATH="$PKG_DIR/fwlink"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: fwlink (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: fwlink (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://go.microsoft.com/fwlink/?linkid=2350827" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: fwlink"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sqlcmd v1.9.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sqlcmd"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sqlcmd v1.9.0"

FILEPATH="$PKG_DIR/sqlcmd-amd64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: sqlcmd-amd64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: sqlcmd-amd64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-amd64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: sqlcmd-amd64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/sqlcmd-arm.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: sqlcmd-arm.msi (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: sqlcmd-arm.msi (arm/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-arm.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: sqlcmd-arm.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/sqlcmd-arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: sqlcmd-arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: sqlcmd-arm64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/go-sqlcmd/releases/download/v1.9.0/sqlcmd-arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: sqlcmd-arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SurfaceApp v75.11130.117.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SurfaceApp"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SurfaceApp v75.11130.117.0"

FILEPATH="$PKG_DIR/Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1a91fe3e-b6be-465d-bda0-b8f12fd0fca7/Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.SurfaceHub_75.11130.117.0_Desktop_X64.Arm64.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SurfaceHubRecoveryTool v2.7.139.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SurfaceHubRecoveryTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SurfaceHubRecoveryTool v2.7.139.0"

FILEPATH="$PKG_DIR/SurfaceHub_Recovery_v2.7.139.0.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SurfaceHub_Recovery_v2.7.139.0.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SurfaceHub_Recovery_v2.7.139.0.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/3/f/83fd5089-d14e-42e3-af7c-6fc36f80d347/SurfaceHub_Recovery_v2.7.139.0.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SurfaceHub_Recovery_v2.7.139.0.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.SymCryptUnitTest v103.8.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/SymCryptUnitTest"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.SymCryptUnitTest v103.8.0"

FILEPATH="$PKG_DIR/symcrypt-windows-amd64-release-103.8.0-53be637d.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: symcrypt-windows-amd64-release-103.8.0-53be637d.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: symcrypt-windows-amd64-release-103.8.0-53be637d.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/SymCrypt/releases/download/v103.8.0/symcrypt-windows-amd64-release-103.8.0-53be637d.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: symcrypt-windows-amd64-release-103.8.0-53be637d.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/symcrypt-windows-arm64-release-103.8.0-53be637d.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: symcrypt-windows-arm64-release-103.8.0-53be637d.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: symcrypt-windows-arm64-release-103.8.0-53be637d.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/SymCrypt/releases/download/v103.8.0/symcrypt-windows-arm64-release-103.8.0-53be637d.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: symcrypt-windows-arm64-release-103.8.0-53be637d.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Autologon v3.10 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Autologon"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Autologon v3.10"

FILEPATH="$PKG_DIR/AutoLogon.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: AutoLogon.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: AutoLogon.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/AutoLogon.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: AutoLogon.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Autoruns v14.11 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Autoruns"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Autoruns v14.11"

FILEPATH="$PKG_DIR/Autoruns.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Autoruns.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Autoruns.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Autoruns.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Autoruns.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.BGInfo v4.33 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/BGInfo"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.BGInfo v4.33"

FILEPATH="$PKG_DIR/BGInfo.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BGInfo.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BGInfo.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/BGInfo.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BGInfo.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Ctrl2Cap v3.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Ctrl2Cap"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Ctrl2Cap v3.0"

FILEPATH="$PKG_DIR/Ctrl2Cap.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Ctrl2Cap.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Ctrl2Cap.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Ctrl2Cap.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Ctrl2Cap.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.DebugView v5.00 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/DebugView"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.DebugView v5.00"

FILEPATH="$PKG_DIR/DebugView.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DebugView.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DebugView.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/DebugView.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DebugView.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Desktops v2.01 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Desktops"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Desktops v2.01"

FILEPATH="$PKG_DIR/Desktops.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Desktops.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Desktops.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Desktops.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Desktops.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.FindLinks v1.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/FindLinks"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.FindLinks v1.1"

FILEPATH="$PKG_DIR/FindLinks.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: FindLinks.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: FindLinks.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/FindLinks.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: FindLinks.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Handle v5.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Handle"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Handle v5.0"

FILEPATH="$PKG_DIR/Handle.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Handle.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Handle.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Handle.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Handle.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.MoveFile v1.02 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/MoveFile"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.MoveFile v1.02"

FILEPATH="$PKG_DIR/pendmoves.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: pendmoves.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: pendmoves.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/pendmoves.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: pendmoves.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.PendMoves v1.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/PendMoves"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.PendMoves v1.3"

FILEPATH="$PKG_DIR/pendmoves.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: pendmoves.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: pendmoves.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/pendmoves.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: pendmoves.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.ProcessExplorer v17.11 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/ProcessExplorer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.ProcessExplorer v17.11"

FILEPATH="$PKG_DIR/ProcessExplorer.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ProcessExplorer.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ProcessExplorer.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/ProcessExplorer.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ProcessExplorer.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.ProcessMonitor v4.01 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/ProcessMonitor"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.ProcessMonitor v4.01"

FILEPATH="$PKG_DIR/ProcessMonitor.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ProcessMonitor.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ProcessMonitor.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/ProcessMonitor.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ProcessMonitor.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.RAMMap v1.63 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/RAMMap"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.RAMMap v1.63"

FILEPATH="$PKG_DIR/RAMMap.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RAMMap.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RAMMap.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/RAMMap.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RAMMap.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.RDCMan v3.12 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/RDCMan"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.RDCMan v3.12"

FILEPATH="$PKG_DIR/RDCMan.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RDCMan.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RDCMan.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/RDCMan.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RDCMan.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.RegJump v1.11 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/RegJump"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.RegJump v1.11"

FILEPATH="$PKG_DIR/regjump.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: regjump.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: regjump.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/regjump.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: regjump.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.SDelete v2.06 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/SDelete"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.SDelete v2.06"

FILEPATH="$PKG_DIR/SDelete.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: SDelete.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: SDelete.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/SDelete.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: SDelete.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Sigcheck v2.91 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Sigcheck"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Sigcheck v2.91"

FILEPATH="$PKG_DIR/Sigcheck.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Sigcheck.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Sigcheck.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Sigcheck.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Sigcheck.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Strings v2.54 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Strings"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Strings v2.54"

FILEPATH="$PKG_DIR/Strings.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Strings.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Strings.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Strings.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Strings.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Sysmon v15.20 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Sysmon"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Sysmon v15.20"

FILEPATH="$PKG_DIR/Sysmon.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Sysmon.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Sysmon.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/Sysmon.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Sysmon.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.TCPView v4.19 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/TCPView"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.TCPView v4.19"

FILEPATH="$PKG_DIR/TCPView.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TCPView.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TCPView.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/TCPView.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TCPView.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.VMMap v3.40 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/VMMap"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.VMMap v3.40"

FILEPATH="$PKG_DIR/VMMap.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VMMap.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VMMap.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/VMMap.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VMMap.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.Whois v1.21 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/Whois"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.Whois v1.21"

FILEPATH="$PKG_DIR/WhoIs.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WhoIs.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WhoIs.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/WhoIs.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WhoIs.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Sysinternals.ZoomIt v11.00 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Sysinternals/ZoomIt"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Sysinternals.ZoomIt v11.00"

FILEPATH="$PKG_DIR/ZoomIt.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ZoomIt.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ZoomIt.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.sysinternals.com/files/ZoomIt.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ZoomIt.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.TeamMate v0.1.15 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/TeamMate"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.TeamMate v0.1.15"

FILEPATH="$PKG_DIR/Microsoft.Tools.TeamMate.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.Tools.TeamMate.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.Tools.TeamMate.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/TeamMate/releases/download/0.1.15%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.Tools.TeamMate.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Teams v26072.521.4595.7966 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Teams"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Teams v26072.521.4595.7966"

FILEPATH="$PKG_DIR/MSTeams-x86.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSTeams-x86.msix (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSTeams-x86.msix (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://installer.teams.static.microsoft/production-windows-x86/26072.521.4595.7966/MSTeams-x86.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSTeams-x86.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MSTeams-x64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSTeams-x64.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSTeams-x64.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://installer.teams.static.microsoft/production-windows-x64/26072.521.4595.7966/MSTeams-x64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSTeams-x64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/MSTeams-arm64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: MSTeams-arm64.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: MSTeams-arm64.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://installer.teams.static.microsoft/production-windows-arm64/26072.521.4595.7966/MSTeams-arm64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: MSTeams-arm64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.TeamsTxNDI v2024.8.1.14 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/TeamsTxNDI"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.TeamsTxNDI v2024.8.1.14"

FILEPATH="$PKG_DIR/ndi-win-x64_vs2022-crtdynamic-release.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: ndi-win-x64_vs2022-crtdynamic-release.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: ndi-win-x64_vs2022-crtdynamic-release.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://teams.microsoft.com/core-calling-lib/2024.8.1.14/ndi-win-x64_vs2022-crtdynamic-release.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: ndi-win-x64_vs2022-crtdynamic-release.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.TimeTravelDebugging v1.11.584.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/TimeTravelDebugging"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.TimeTravelDebugging v1.11.584.0"

FILEPATH="$PKG_DIR/TTD.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TTD.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TTD.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TTD.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Tokenizer v1.3.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Tokenizer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Tokenizer v1.3.3"

FILEPATH="$PKG_DIR/Tokenizer.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Tokenizer.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Tokenizer.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/Tokenizer/releases/download/v1.3.3/Tokenizer.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Tokenizer.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.UI.Xaml.2.7 v7.2208.15002.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/UI/Xaml/2/7"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.UI.Xaml.2.7 v7.2208.15002.0"

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.7.x64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.x64.appx (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.x64.appx (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.x64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.7.x86.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.x86.appx (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.x86.appx (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x86.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.x86.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.7.arm.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.arm.appx (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.arm.appx (arm/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.arm.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.arm.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.7.arm64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.7.arm64.appx (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.7.arm64.appx (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.arm64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.7.arm64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.UI.Xaml.2.8 v8.2310.30001.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/UI/Xaml/2/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.UI.Xaml.2.8 v8.2310.30001.0"

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.8.x64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.x64.appx (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.x64.appx (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.x64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.8.x86.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.x86.appx (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.x86.appx (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x86.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.x86.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.8.arm.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.arm.appx (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.arm.appx (arm/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.arm.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.arm.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.UI.Xaml.2.8.arm64.appx"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.UI.Xaml.2.8.arm64.appx (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.UI.Xaml.2.8.arm64.appx (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.arm64.appx" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.UI.Xaml.2.8.arm64.appx"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.UpdateAssistant v1.4.19041.2183 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/UpdateAssistant"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.UpdateAssistant v1.4.19041.2183"

FILEPATH="$PKG_DIR/Windows10Upgrade9252.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows10Upgrade9252.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows10Upgrade9252.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/4/8/3/483976ae-b4b1-490d-bd5f-74fdc44bb84e/Windows10Upgrade9252.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows10Upgrade9252.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCLibs.14 v14.0.33519.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCLibs/14"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCLibs.14 v14.0.33519.0"

FILEPATH="$PKG_DIR/DesktopAppInstaller_Dependencies.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DesktopAppInstaller_Dependencies.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DesktopAppInstaller_Dependencies.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winget-cli/releases/download/v1.12.350/DesktopAppInstaller_Dependencies.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DesktopAppInstaller_Dependencies.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCLibs.Desktop.14 v14.0.33728.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCLibs/Desktop/14"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCLibs.Desktop.14 v14.0.33728.0"

FILEPATH="$PKG_DIR/DesktopAppInstaller_Dependencies.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: DesktopAppInstaller_Dependencies.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: DesktopAppInstaller_Dependencies.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winget-cli/releases/download/v1.9.25180/DesktopAppInstaller_Dependencies.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: DesktopAppInstaller_Dependencies.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2012.x64 v11.0.61030.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2012/x64"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2012.x64 v11.0.61030.0"

FILEPATH="$PKG_DIR/vcredist_x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vcredist_x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vcredist_x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vcredist_x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2012.x86 v11.0.61030.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2012/x86"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2012.x86 v11.0.61030.0"

FILEPATH="$PKG_DIR/vcredist_x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vcredist_x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vcredist_x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vcredist_x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2013.x64 v12.0.40664.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2013/x64"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2013.x64 v12.0.40664.0"

FILEPATH="$PKG_DIR/vcredist_x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vcredist_x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vcredist_x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vcredist_x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2013.x86 v12.0.40664.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2013/x86"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2013.x86 v12.0.40664.0"

FILEPATH="$PKG_DIR/vcredist_x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vcredist_x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vcredist_x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vcredist_x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2015+.arm64 v14.50.35719.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2015+/arm64"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2015+.arm64 v14.50.35719.0"

FILEPATH="$PKG_DIR/VC_redist.arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VC_redist.arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VC_redist.arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/FCDA7B24413F170BD456052F08AE49FB60AC1638F083AAB7A35AFEB957AEB1D6/VC_redist.arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VC_redist.arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2015+.x64 v14.50.35719.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2015+/x64"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2015+.x64 v14.50.35719.0"

FILEPATH="$PKG_DIR/VC_redist.x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VC_redist.x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VC_redist.x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/8995548DFFFCDE7C49987029C764355612BA6850EE09A7B6F0FDDC85BDC5C280/VC_redist.x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VC_redist.x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VCRedist.2015+.x86 v14.50.35719.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VCRedist/2015+/x86"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VCRedist.2015+.x86 v14.50.35719.0"

FILEPATH="$PKG_DIR/VC_redist.x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VC_redist.x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VC_redist.x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/6f02464a-5e9b-486d-a506-c99a17db9a83/E7267C1BDF9237C0B4A28CF027C382B97AA909934F84F1C92D3FB9F04173B33E/VC_redist.x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VC_redist.x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VSDotNetLogCollect v17.0.35214.149 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VSDotNetLogCollect"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VSDotNetLogCollect v17.0.35214.149"

FILEPATH="$PKG_DIR/Collect.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Collect.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Collect.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8/3/4/834e83f6-c377-4dce-a757-69a418b6c6df/Collect.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Collect.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VSIXBootstrapper v1.0.37 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VSIXBootstrapper"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VSIXBootstrapper v1.0.37"

FILEPATH="$PKG_DIR/VSIXBootstrapper.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSIXBootstrapper.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSIXBootstrapper.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/vsixbootstrapper/releases/download/1.0.37/VSIXBootstrapper.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSIXBootstrapper.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VSTOR v10.0.60917 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VSTOR"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VSTOR v10.0.60917"

FILEPATH="$PKG_DIR/vstor_redist.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vstor_redist.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vstor_redist.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/5/d/2/5d24f8f8-efbb-4b63-aa33-3785e3104713/vstor_redist.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vstor_redist.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisioViewer v16.0.4339.1001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisioViewer"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisioViewer v16.0.4339.1001"

FILEPATH="$PKG_DIR/visioviewer_4339-1001_x64_en-us.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: visioviewer_4339-1001_x64_en-us.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: visioviewer_4339-1001_x64_en-us.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/D/B/7/DB790874-4414-417F-ADF6-348B29572B9F/visioviewer_4339-1001_x64_en-us.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: visioviewer_4339-1001_x64_en-us.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/visioviewer_4339-1001_x86_en-us.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: visioviewer_4339-1001_x86_en-us.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: visioviewer_4339-1001_x86_en-us.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/D/B/7/DB790874-4414-417F-ADF6-348B29572B9F/visioviewer_4339-1001_x86_en-us.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: visioviewer_4339-1001_x86_en-us.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.2022.BuildTools v17.14.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/2022/BuildTools"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.2022.BuildTools v17.14.31"

FILEPATH="$PKG_DIR/vs_BuildTools.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vs_BuildTools.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vs_BuildTools.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/b25d20faf12653a27421e4209daadfeb81aa44e9339d160541bb806e13e8769a/vs_BuildTools.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vs_BuildTools.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.2022.Enterprise v17.14.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/2022/Enterprise"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.2022.Enterprise v17.14.31"

FILEPATH="$PKG_DIR/vs_Enterprise.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vs_Enterprise.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vs_Enterprise.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/824a8a0817e4102c9ffa0573844a8b1f1686dd181405c2ef746ee07ea47793b9/vs_Enterprise.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vs_Enterprise.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/2022/OnecoreMsvsmon"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6"

FILEPATH="$PKG_DIR/onecore.msvsmon.x86.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: onecore.msvsmon.x86.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: onecore.msvsmon.x86.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/75fb7124f0b39172b065e21ba2f73c39d15c03dc81f7b96432b4c3e4206b4be6/onecore.msvsmon.x86.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: onecore.msvsmon.x86.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/onecore.msvsmon.amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: onecore.msvsmon.amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: onecore.msvsmon.amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/c9792d0f4326ed8e812574df5b94ff06ceb9430e101e041e000e040cb78b536c/onecore.msvsmon.amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: onecore.msvsmon.amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/onecore.msvsmon.arm.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: onecore.msvsmon.arm.zip (arm)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: onecore.msvsmon.arm.zip (arm/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/02cae74d5964feb48ff68a9490f06346ac722b7ff22f98833969cca0191ed35e/onecore.msvsmon.arm.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: onecore.msvsmon.arm.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/onecore.msvsmon.arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: onecore.msvsmon.arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: onecore.msvsmon.arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d7450eb5-03e1-436d-9e7e-deb5fe4759b3/8d1b5d05fa95cf9bac2aac9c3effbffd32341a4a37ed4a5d22f5291bb236152d/onecore.msvsmon.arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: onecore.msvsmon.arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.2022.Professional v17.14.31 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/2022/Professional"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.2022.Professional v17.14.31"

FILEPATH="$PKG_DIR/vs_Professional.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vs_Professional.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vs_Professional.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/d9ce9498-b5ec-4730-a7b2-b0589eab2d27/08809dcedf390bf3ba2349b382ae9bac948b9f716760934d29a9d6437afae16d/vs_Professional.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vs_Professional.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.2022.RemoteTools v17.14.8 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/2022/RemoteTools"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.2022.RemoteTools v17.14.8"

FILEPATH="$PKG_DIR/VS_RemoteTools.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VS_RemoteTools.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VS_RemoteTools.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/ee861ad443f2b2f9c38e8f88da972534714100a261894199b453103ec78b229d/VS_RemoteTools.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VS_RemoteTools.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/VS_RemoteTools.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VS_RemoteTools.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VS_RemoteTools.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/4f3a9bb0ac443eff807c8ff04fad7683e98acfe67c0bc293da89cc673e1186a3/VS_RemoteTools.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VS_RemoteTools.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/VS_RemoteTools.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VS_RemoteTools.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VS_RemoteTools.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.visualstudio.microsoft.com/download/pr/7ebf5fdb-36dc-4145-b0a0-90d3d5990a61/fa1d6c1c2dc4fd97889c1f76ebdb50fa040ece18a2f6d63b2cfc09809d20b74a/VS_RemoteTools.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VS_RemoteTools.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.ConfigFinder v1.0.47.55350 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/ConfigFinder"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.ConfigFinder v1.0.47.55350"

FILEPATH="$PKG_DIR/VSConfigFinder.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSConfigFinder.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSConfigFinder.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/VSConfigFinder/releases/download/1.0.47-beta/VSConfigFinder.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSConfigFinder.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.Extensions.TypeScript v4.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/Extensions/TypeScript"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.Extensions.TypeScript v4.3"

FILEPATH="$PKG_DIR/TypeScript_SDK_4.3.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: TypeScript_SDK_4.3.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: TypeScript_SDK_4.3.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/1622050134497/TypeScript_SDK_4.3.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: TypeScript_SDK_4.3.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudio.Locator v3.1.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudio/Locator"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudio.Locator v3.1.7"

FILEPATH="$PKG_DIR/vswhere.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: vswhere.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: vswhere.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/vswhere/releases/download/3.1.7/vswhere.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: vswhere.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualStudioCode v1.118.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualStudioCode"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualStudioCode v1.118.1"

FILEPATH="$PKG_DIR/VSCodeSetup-arm64-1.118.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSCodeSetup-arm64-1.118.1.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSCodeSetup-arm64-1.118.1.exe (arm64/machine)"
  if curl -fSL -o "$FILEPATH" "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeSetup-arm64-1.118.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSCodeSetup-arm64-1.118.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/VSCodeUserSetup-arm64-1.118.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSCodeUserSetup-arm64-1.118.1.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSCodeUserSetup-arm64-1.118.1.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeUserSetup-arm64-1.118.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSCodeUserSetup-arm64-1.118.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/VSCodeSetup-x64-1.118.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSCodeSetup-x64-1.118.1.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSCodeSetup-x64-1.118.1.exe (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeSetup-x64-1.118.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSCodeSetup-x64-1.118.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/VSCodeUserSetup-x64-1.118.1.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: VSCodeUserSetup-x64-1.118.1.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: VSCodeUserSetup-x64-1.118.1.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://vscode.download.prss.microsoft.com/dbazure/download/stable/034f571df509819cc10b0c8129f66ef77a542f0e/VSCodeUserSetup-x64-1.118.1.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: VSCodeUserSetup-x64-1.118.1.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.VisualTrueType v6.35 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/VisualTrueType"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.VisualTrueType v6.35"

FILEPATH="$PKG_DIR/release_binary.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: release_binary.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: release_binary.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/VisualTrueType/releases/download/v0.0.7/release_binary.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: release_binary.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WSL v2.6.3 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WSL"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WSL v2.6.3"

FILEPATH="$PKG_DIR/wsl.2.6.3.0.x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wsl.2.6.3.0.x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wsl.2.6.3.0.x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wsl.2.6.3.0.x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/WSL/releases/download/2.6.3/Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.WSL_2.6.3.0_x64_ARM64.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/wsl.2.6.3.0.arm64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wsl.2.6.3.0.arm64.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wsl.2.6.3.0.arm64.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/WSL/releases/download/2.6.3/wsl.2.6.3.0.arm64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wsl.2.6.3.0.arm64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Wassette v0.4.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Wassette"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Wassette v0.4.0"

FILEPATH="$PKG_DIR/wassette_0.4.0_windows_amd64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wassette_0.4.0_windows_amd64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wassette_0.4.0_windows_amd64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/wassette/releases/download/v0.4.0/wassette_0.4.0_windows_amd64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wassette_0.4.0_windows_amd64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/wassette_0.4.0_windows_arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wassette_0.4.0_windows_arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wassette_0.4.0_windows_arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/wassette/releases/download/v0.4.0/wassette_0.4.0_windows_arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wassette_0.4.0_windows_arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WebDeploy v10.0.2001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WebDeploy"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WebDeploy v10.0.2001"

FILEPATH="$PKG_DIR/WebDeploy_x86_zh-TW.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_zh-TW.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_zh-TW.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_zh-TW.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_zh-TW.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_zh-CN.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_zh-CN.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_zh-CN.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_zh-CN.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_zh-CN.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_tr-TR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_tr-TR.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_tr-TR.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_tr-TR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_tr-TR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_ru-RU.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_ru-RU.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_ru-RU.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_ru-RU.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_ru-RU.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_pt-BR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_pt-BR.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_pt-BR.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_pt-BR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_pt-BR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_pl-PL.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_pl-PL.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_pl-PL.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_pl-PL.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_pl-PL.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_ko-KR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_ko-KR.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_ko-KR.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_ko-KR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_ko-KR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_ja-JP.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_ja-JP.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_ja-JP.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_ja-JP.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_ja-JP.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_it-IT.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_it-IT.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_it-IT.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_it-IT.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_it-IT.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_fr-FR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_fr-FR.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_fr-FR.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_fr-FR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_fr-FR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_es-ES.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_es-ES.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_es-ES.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_es-ES.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_es-ES.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_de-DE.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_de-DE.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_de-DE.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_de-DE.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_de-DE.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_en-US.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_en-US.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WebDeploy_x86_cs-CZ.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WebDeploy_x86_cs-CZ.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WebDeploy_x86_cs-CZ.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WebDeploy_x86_cs-CZ.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_zh-TW.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_zh-TW.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_zh-TW.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_zh-TW.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_zh-CN.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_zh-CN.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_zh-CN.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_zh-CN.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_zh-CN.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_tr-TR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_tr-TR.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_tr-TR.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_tr-TR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_tr-TR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_ru-RU.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_ru-RU.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_ru-RU.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_ru-RU.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_ru-RU.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_pt-BR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_pt-BR.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_pt-BR.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_pt-BR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_pt-BR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_pl-PL.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_pl-PL.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_pl-PL.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_pl-PL.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_pl-PL.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_ko-KR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_ko-KR.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_ko-KR.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_ko-KR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_ko-KR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_ja-JP.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_ja-JP.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_ja-JP.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_ja-JP.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_ja-JP.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_it-IT.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_it-IT.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_it-IT.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_it-IT.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_it-IT.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_fr-FR.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_fr-FR.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_fr-FR.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_fr-FR.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_fr-FR.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_es-ES.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_es-ES.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_es-ES.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_es-ES.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_es-ES.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_de-DE.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_de-DE.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_de-DE.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_de-DE.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_de-DE.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_en-US.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_en-US.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_en-US.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_en-US.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_en-US.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/webdeploy_amd64_cs-CZ.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: webdeploy_amd64_cs-CZ.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: webdeploy_amd64_cs-CZ.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: webdeploy_amd64_cs-CZ.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.Win32ContentPrepTool v1.8.7 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Win32ContentPrepTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Win32ContentPrepTool v1.8.7"

FILEPATH="$PKG_DIR/v1.8.7.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: v1.8.7.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: v1.8.7.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/v1.8.7.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: v1.8.7.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WinAppCli v0.3.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WinAppCli"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WinAppCli v0.3.0"

FILEPATH="$PKG_DIR/winappcli_x64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winappcli_x64.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winappcli_x64.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winappCli/releases/download/v0.3.0/winappcli_x64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winappcli_x64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/winappcli_arm64.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winappcli_arm64.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winappcli_arm64.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winappCli/releases/download/v0.3.0/winappcli_arm64.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winappcli_arm64.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WinDbg v1.2603.20001.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WinDbg"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WinDbg v1.2603.20001.0"

FILEPATH="$PKG_DIR/windbg.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windbg.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windbg.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windbg.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsADK v10.1.28000.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsADK"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsADK v10.1.28000.1"

FILEPATH="$PKG_DIR/adksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: adksetup.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: adksetup.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/615540bc-be0b-433a-b91b-1f2b0642bb24/adk/adksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: adksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsAdminCenter v2.6.6.18 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsAdminCenter"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsAdminCenter v2.6.6.18"

FILEPATH="$PKG_DIR/WindowsAdminCenter2511.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsAdminCenter2511.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsAdminCenter2511.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/5e854024-dcf1-4e86-9546-7389fd08a34b/WindowsAdminCenter2511.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsAdminCenter2511.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsApp v2.0.1071.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsApp"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsApp v2.0.1071.0"

FILEPATH="$PKG_DIR/WindowsApp_x86_Release_2.0.1071.0.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsApp_x86_Release_2.0.1071.0.msix (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsApp_x86_Release_2.0.1071.0.msix (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/db1e6154-852e-468d-a8a0-537ca95d7c2c/WindowsApp_x86_Release_2.0.1071.0.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsApp_x86_Release_2.0.1071.0.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WindowsApp_x64_Release_2.0.1071.0.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsApp_x64_Release_2.0.1071.0.msix (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsApp_x64_Release_2.0.1071.0.msix (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/8d11c978-7f9b-4f0d-83e0-f6e104c263f1/WindowsApp_x64_Release_2.0.1071.0.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsApp_x64_Release_2.0.1071.0.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WindowsApp_arm64_Release_2.0.1071.0.msix"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsApp_arm64_Release_2.0.1071.0.msix (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsApp_arm64_Release_2.0.1071.0.msix (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://res.cdn.office.net/remote-desktop-windows-client/ec42c762-f80f-4fde-9190-c3adacffc942/WindowsApp_arm64_Release_2.0.1071.0.msix" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsApp_arm64_Release_2.0.1071.0.msix"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsAppRuntime.1.5 v1.5.8 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsAppRuntime/1/5"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsAppRuntime.1.5 v1.5.8"

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.5/1.5.241107002/windowsappruntimeinstall-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.5/1.5.241107002/windowsappruntimeinstall-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.5/1.5.241107002/windowsappruntimeinstall-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsAppRuntime.1.6 v1.6.9 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsAppRuntime/1/6"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsAppRuntime.1.6 v1.6.9"

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.6/1.6.250602001/windowsappruntimeinstall-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsAppRuntime.1.7 v1.7.9 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsAppRuntime/1/7"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsAppRuntime.1.7 v1.7.9"

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.7/1.7.260224002/windowsappruntimeinstall-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsAppRuntime.1.8 v1.8.6 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsAppRuntime/1/8"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsAppRuntime.1.8 v1.8.6"

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x86.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x86.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x86.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.8/1.8.260317003/windowsappruntimeinstall-x86.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x86.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.8/1.8.260317003/windowsappruntimeinstall-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/windowsappruntimeinstall-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: windowsappruntimeinstall-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: windowsappruntimeinstall-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/windowsappsdk/1.8/1.8.260317003/windowsappruntimeinstall-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: windowsappruntimeinstall-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsApplicationDriver v1.2.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsApplicationDriver"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsApplicationDriver v1.2.1.0"

FILEPATH="$PKG_DIR/WindowsApplicationDriver_1.2.1.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsApplicationDriver_1.2.1.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsApplicationDriver_1.2.1.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/WinAppDriver/releases/download/v1.2.1/WindowsApplicationDriver_1.2.1.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsApplicationDriver_1.2.1.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsBusesTracing v1.1.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsBusesTracing"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsBusesTracing v1.1.0"

FILEPATH="$PKG_DIR/busestracing-win-x64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: busestracing-win-x64.zip (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: busestracing-win-x64.zip (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/busiotools/releases/download/bt1.1.0/busestracing-win-x64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: busestracing-win-x64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/busestracing-win-arm64.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: busestracing-win-arm64.zip (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: busestracing-win-arm64.zip (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/busiotools/releases/download/bt1.1.0/busestracing-win-arm64.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: busestracing-win-arm64.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsCloudIOProtectionDriver v0.0.693 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsCloudIOProtectionDriver"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsCloudIOProtectionDriver v0.0.693"

FILEPATH="$PKG_DIR/wcio_protection_driver_installer_x64_0.0.693.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wcio_protection_driver_installer_x64_0.0.693.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wcio_protection_driver_installer_x64_0.0.693.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://res-1.cdn.office.net/assets/wcio-protection/msi/2d3f50d6-47fc-42d9-80dc-632e64a7065a/wcio_protection_driver_installer_x64_0.0.693.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wcio_protection_driver_installer_x64_0.0.693.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/wcio_protection_driver_installer_arm_0.0.693.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wcio_protection_driver_installer_arm_0.0.693.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wcio_protection_driver_installer_arm_0.0.693.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://res-1.cdn.office.net/assets/wcio-protection/msi/2d3f50d6-47fc-42d9-80dc-632e64a7065a/wcio_protection_driver_installer_arm_0.0.693.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wcio_protection_driver_installer_arm_0.0.693.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsDeviceRecoveryTool v3.17.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsDeviceRecoveryTool"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsDeviceRecoveryTool v3.17.0"

FILEPATH="$PKG_DIR/wdrt-hl1.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wdrt-hl1.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wdrt-hl1.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/266c0370-a6b6-4a49-ac55-6cb2e086b14c/wdrt-hl1.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wdrt-hl1.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsInstallationAssistant v1.4.19041.6448 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsInstallationAssistant"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsInstallationAssistant v1.4.19041.6448"

FILEPATH="$PKG_DIR/Windows11InstallationAssistant.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows11InstallationAssistant.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows11InstallationAssistant.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/db8267b0-3e86-4254-82c7-a127878a9378/Windows11InstallationAssistant.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows11InstallationAssistant.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsMIDIServicesSDK"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209"

FILEPATH="$PKG_DIR/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Windows.MIDI.Services.SDK.Runtime.and.Tools.1.0.14-rc.1.209-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsPCHealthCheck v4.0.2410.23001 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsPCHealthCheck"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsPCHealthCheck v4.0.2410.23001"

FILEPATH="$PKG_DIR/WindowsPCHealthCheckSetup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsPCHealthCheckSetup.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsPCHealthCheckSetup.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b/2/9/b2965f3b-0410-4d93-995f-5bc8a5d56916/4.0/x64/WindowsPCHealthCheckSetup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsPCHealthCheckSetup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/WindowsPCHealthCheckSetup.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: WindowsPCHealthCheckSetup.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: WindowsPCHealthCheckSetup.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b/2/9/b2965f3b-0410-4d93-995f-5bc8a5d56916/4.0/x86/WindowsPCHealthCheckSetup.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: WindowsPCHealthCheckSetup.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsSDK.10.0.22000 v10.0.22000.832 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsSDK/10/0/22000"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsSDK.10.0.22000 v10.0.22000.832"

FILEPATH="$PKG_DIR/winsdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winsdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winsdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/1/0/e/10e6da02-01f7-40d4-8942-b98b53b36cf9/windowssdk/winsdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winsdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsSDK/10/0/22621"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428"

FILEPATH="$PKG_DIR/winsdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winsdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winsdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3/b/d/3bd97f81-3f5b-4922-b86d-dc5145cd6bfe/windowssdk/winsdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winsdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsSDK/10/0/26100"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705"

FILEPATH="$PKG_DIR/winsdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winsdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winsdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f4b30f2a-4fc3-430e-9b03-c842b5f5f9f1/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winsdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsSDK/10/0/28000"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721"

FILEPATH="$PKG_DIR/winsdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: winsdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: winsdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c5526ca8-88aa-4325-8d72-de642afc7356/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: winsdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsTerminal v1.24.10921.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsTerminal"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsTerminal v1.24.10921.0"

FILEPATH="$PKG_DIR/Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/terminal/releases/download/v1.24.10921.0/Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.WindowsTerminal_1.24.10921.0_8wekyb3d8bbwe.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsVirtualDesktopAgent"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400"

FILEPATH="$PKG_DIR/RWrmXv"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RWrmXv (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RWrmXv (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RWrmXv"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsVirtualDesktopBootloader"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100"

FILEPATH="$PKG_DIR/RWrxrH"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: RWrxrH (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: RWrxrH (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: RWrxrH"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsWDK.10.0.22000 v10.1.22000.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsWDK/10/0/22000"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsWDK.10.0.22000 v10.1.22000.1"

FILEPATH="$PKG_DIR/wdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/d/6/7d602355-8ae9-414c-ae36-109ece2aade6/wdk/wdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsWDK/10/0/22621"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428"

FILEPATH="$PKG_DIR/wdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7/b/f/7bfc8dbe-00cb-47de-b856-70e696ef4f46/wdk/wdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WindowsWDK/10/0/26100"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584"

FILEPATH="$PKG_DIR/wdksetup.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wdksetup.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wdksetup.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/41fb59c2-1723-45f9-a270-96b73ad58233/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wdksetup.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.WingetCreate v1.12.8.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/WingetCreate"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.WingetCreate v1.12.8.0"

FILEPATH="$PKG_DIR/Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winget-create/releases/download/v1.12.8.0/Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Microsoft.WindowsPackageManagerManifestCreator_1.12.8.0_8wekyb3d8bbwe.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/wingetcreate.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wingetcreate.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wingetcreate.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winget-create/releases/download/v1.12.8.0/wingetcreate.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wingetcreate.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.XMLNotepad v2.9.0.21 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/XMLNotepad"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.XMLNotepad v2.9.0.21"

FILEPATH="$PKG_DIR/XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/XmlNotepad/releases/download/2.9.0.21/XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: XmlNotepadPackage_2.9.0.21_AnyCPU.msixbundle"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/XmlNotepadSetup.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: XmlNotepadSetup.zip (neutral)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: XmlNotepadSetup.zip (neutral/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/XmlNotepad/releases/download/2.9.0.21/XmlNotepadSetup.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: XmlNotepadSetup.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.bitsmanager v1.12.0.4 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/bitsmanager"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.bitsmanager v1.12.0.4"

FILEPATH="$PKG_DIR/BITSManager.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: BITSManager.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: BITSManager.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/BITS-Manager/releases/download/v1.12/BITSManager.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: BITSManager.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.err v6.4.5 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/err"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.err v6.4.5"

FILEPATH="$PKG_DIR/Err_6.4.5.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Err_6.4.5.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Err_6.4.5.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/4/3/2/432140e8-fb6c-4145-8192-25242838c542/Err_6.4.5/Err_6.4.5.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Err_6.4.5.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.etl2pcapng v1.11.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/etl2pcapng"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.etl2pcapng v1.11.0"

FILEPATH="$PKG_DIR/etl2pcapng.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: etl2pcapng.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: etl2pcapng.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/etl2pcapng/releases/download/v1.11.0/etl2pcapng.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: etl2pcapng.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.msodbcsql.17 v17.10.6.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/msodbcsql/17"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.msodbcsql.17 v17.10.6.1"

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/en-US/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/en-US/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/de-DE/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/de-DE/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/es-ES/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/es-ES/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/fr-FR/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/fr-FR/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/it-IT/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/it-IT/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ja-JP/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ja-JP/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ko-KR/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ko-KR/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/pt-BR/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/pt-BR/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ru-RU/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/ru-RU/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-CN/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-CN/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-TW/17.10.6.1/x86/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6/f/f/6ffefc73-39ab-4cc0-bb7c-4093d64c2669/zh-TW/17.10.6.1/x64/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.msodbcsql.18 v18.6.2.1 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/msodbcsql/18"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.msodbcsql.18 v18.6.2.1"

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c0d0dcf1-bd9b-46ec-a659-5046ee11d1d1/x86/1033/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/7bf9fad4-0f21-486d-a750-fc990ded5624/amd64/1033/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/76504d2d-06b3-4262-8bc9-855ffd08d7be/arm64/1033/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/be607da2-d2a5-481c-9db8-7ee1f76801d7/x86/1031/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/9686dba9-b962-4715-8380-dea24599e181/amd64/1031/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e77d6889-44b4-4965-88c8-ce196cdd2bdc/arm64/1031/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/6cb6c417-86fc-46fb-9497-776c83cb0111/x86/3082/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/a6da0e01-66c7-4987-89eb-3ee383a4d59b/amd64/3082/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/62c491d2-04e9-4d72-b5a5-9d03af2995ab/arm64/3082/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8d3eb7eb-5a29-4ba3-a86c-6ccdceb055e7/x86/1036/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/23099c35-bb51-4a27-81a7-559d60db69f2/amd64/1036/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/add95ea7-c0bc-4a88-8f4f-11eb8b483c2c/arm64/1036/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/0c8c9e26-3fd3-4b2f-a32c-ccd81862e2ef/x86/1040/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/3996f308-6e1f-4dbb-bb8f-ea9949c30930/amd64/1040/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/30b82b26-d3da-402e-8f8a-3f3686081bc0/arm64/1040/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e637d43c-6b90-4c15-b89a-65c555e7c362/x86/1041/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/747d5a46-d7ed-4cb9-be1e-16f8cfd43d25/amd64/1041/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/fda472bc-bc32-4e50-ac85-c5c4ef8a81cf/arm64/1041/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/0de273df-ab78-43ba-9864-8ccbca6a7797/x86/1042/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/f7f77cd9-dfde-45a3-85b9-0f3fc51164a4/amd64/1042/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/01557ea7-ef5c-4c07-8406-4245257df2e1/arm64/1042/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/b1c469f7-1727-4de5-a2be-9a2f0bb5e14e/x86/1046/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/01b14c42-0e39-4d3a-b6ef-37d6ae6b4cce/amd64/1046/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/8cb64429-090f-493f-aa6f-e17212798add/arm64/1046/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/fd4ee281-198d-4f8e-a4f8-44fdec6cb83a/x86/1049/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/76470099-344e-475e-8de6-703c9b669715/amd64/1049/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/9f6c498c-65bf-410a-b9ac-6b2bdc233aed/arm64/1049/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/c794aa14-cf68-41ab-85da-35c6699ccc96/x86/2052/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e4674677-8370-41f7-a4f0-708e3ed7edf0/amd64/2052/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/ef6bf0f1-5832-4033-aad3-5972f060fb87/arm64/2052/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/099e5f30-1677-4184-a271-327f7ec1ccc3/x86/1028/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/e6a2cd27-87d2-43e4-b212-e2c2ad19a970/amd64/1028/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/msodbcsql.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: msodbcsql.msi (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: msodbcsql.msi (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://download.microsoft.com/download/69f7b105-c55f-4bd6-b7cf-78e69abff9ea/arm64/1028/msodbcsql.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: msodbcsql.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.quicreach v1.3.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/quicreach"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.quicreach v1.3.0"

FILEPATH="$PKG_DIR/quicreach.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: quicreach.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: quicreach.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/quicreach/releases/download/v1.3.0/quicreach.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: quicreach.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Microsoft.winfile v10.4.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/winfile"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.winfile v10.4.0.0"

FILEPATH="$PKG_DIR/Winfile_v10.4.0.0.zip"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Winfile_v10.4.0.0.zip (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Winfile_v10.4.0.0.zip (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/winfile/releases/download/v10.4.0.0/Winfile_v10.4.0.0.zip" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Winfile_v10.4.0.0.zip"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === Telerik.Fiddler.Classic v5.0.20253.3311 ===
PKG_DIR="$DOWNLOAD_DIR/Telerik/Fiddler/Classic"
mkdir -p "$PKG_DIR"
echo "📦 Telerik.Fiddler.Classic v5.0.20253.3311"

FILEPATH="$PKG_DIR/FiddlerSetup.5.0.20253.3311-latest.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: FiddlerSetup.5.0.20253.3311-latest.exe (x86)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: FiddlerSetup.5.0.20253.3311-latest.exe (x86/default)"
  if curl -fSL -o "$FILEPATH" "https://downloads.getfiddler.com/fiddler-classic/FiddlerSetup.5.0.20253.3311-latest.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: FiddlerSetup.5.0.20253.3311-latest.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === WiresharkFoundation.Stratoshark v0.9.3 ===
PKG_DIR="$DOWNLOAD_DIR/WiresharkFoundation/Stratoshark"
mkdir -p "$PKG_DIR"
echo "📦 WiresharkFoundation.Stratoshark v0.9.3"

FILEPATH="$PKG_DIR/Stratoshark-0.9.3-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Stratoshark-0.9.3-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Stratoshark-0.9.3-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://1.na.dl.wireshark.org/win64/Stratoshark-0.9.3-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Stratoshark-0.9.3-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Stratoshark-0.9.3-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Stratoshark-0.9.3-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Stratoshark-0.9.3-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://1.na.dl.wireshark.org/win64/Stratoshark-0.9.3-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Stratoshark-0.9.3-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === WiresharkFoundation.Wireshark v4.6.5 ===
PKG_DIR="$DOWNLOAD_DIR/WiresharkFoundation/Wireshark"
mkdir -p "$PKG_DIR"
echo "📦 WiresharkFoundation.Wireshark v4.6.5"

FILEPATH="$PKG_DIR/Wireshark-4.6.5-x64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Wireshark-4.6.5-x64.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Wireshark-4.6.5-x64.exe (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-x64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Wireshark-4.6.5-x64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Wireshark-4.6.5-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Wireshark-4.6.5-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Wireshark-4.6.5-arm64.exe (arm64/default)"
  if curl -fSL -o "$FILEPATH" "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Wireshark-4.6.5-arm64.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Wireshark-4.6.5-x64.msi"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Wireshark-4.6.5-x64.msi (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Wireshark-4.6.5-x64.msi (x64/default)"
  if curl -fSL -o "$FILEPATH" "https://2.na.dl.wireshark.org/win64/all-versions/Wireshark-4.6.5-x64.msi" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Wireshark-4.6.5-x64.msi"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

echo ""
echo "=============================="
echo "📊 下載結果摘要"
echo "   ✅ 成功下載: $TOTAL 個"
echo "   ⏭️  已略過: $SKIPPED 個"
echo "   ❌ 下載失敗: $FAILED 個"
echo "   📂 下載目錄: $DOWNLOAD_DIR"
echo "=============================="
