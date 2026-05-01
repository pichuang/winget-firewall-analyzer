#!/bin/bash
# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 10:32:23
# 套件數量：3
#
# 用法：bash download.sh
# 檔案會下載到 ./downloads/{PackageId}/ 目錄

set -euo pipefail

DOWNLOAD_DIR="./downloads"
TOTAL=0
SKIPPED=0
FAILED=0

echo "🚀 開始下載 winget 安裝檔 ..."
echo ""

# === Microsoft.Git v2.48.0.vfs.0.0 ===
PKG_DIR="$DOWNLOAD_DIR/Microsoft/Git"
mkdir -p "$PKG_DIR"
echo "📦 Microsoft.Git v2.48.0.vfs.0.0"

FILEPATH="$PKG_DIR/Git-2.48.0.vfs.0.0-64-bit.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Git-2.48.0.vfs.0.0-64-bit.exe (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Git-2.48.0.vfs.0.0-64-bit.exe (x64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-64-bit.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Git-2.48.0.vfs.0.0-64-bit.exe"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

FILEPATH="$PKG_DIR/Git-2.48.0.vfs.0.0-arm64.exe"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: Git-2.48.0.vfs.0.0-arm64.exe (arm64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: Git-2.48.0.vfs.0.0-arm64.exe (arm64/user)"
  if curl -fSL -o "$FILEPATH" "https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-arm64.exe" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: Git-2.48.0.vfs.0.0-arm64.exe"
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

echo ""
echo "=============================="
echo "📊 下載結果摘要"
echo "   ✅ 成功下載: $TOTAL 個"
echo "   ⏭️  已略過: $SKIPPED 個"
echo "   ❌ 下載失敗: $FAILED 個"
echo "   📂 下載目錄: $DOWNLOAD_DIR"
echo "=============================="
