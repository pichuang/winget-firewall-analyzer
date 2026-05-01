#!/bin/bash
# winget 安裝檔一鍵下載腳本
# 產生時間：2026-05-01 12:06:36
# 套件數量：2
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

# === WSL.Ubuntu-20.04 vUbuntu 20.04 LTS ===
PKG_DIR="$DOWNLOAD_DIR/WSL/Ubuntu-20/04"
mkdir -p "$PKG_DIR"
echo "📦 WSL.Ubuntu-20.04 vUbuntu 20.04 LTS"

FILEPATH="$PKG_DIR/wslubuntu2004"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wslubuntu2004 (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wslubuntu2004 (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/wslubuntu2004" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wslubuntu2004"
    FAILED=$((FAILED + 1))
    rm -f "$FILEPATH"
  fi
fi

# === WSL.Ubuntu-22.04 vUbuntu 22.04 LTS ===
PKG_DIR="$DOWNLOAD_DIR/WSL/Ubuntu-22/04"
mkdir -p "$PKG_DIR"
echo "📦 WSL.Ubuntu-22.04 vUbuntu 22.04 LTS"

FILEPATH="$PKG_DIR/wslubuntu2204"
if [ -f "$FILEPATH" ]; then
  echo "   ⏭️  已存在: wslubuntu2204 (x64)"
  SKIPPED=$((SKIPPED + 1))
else
  echo "   ⬇️  下載中: wslubuntu2204 (x64/machine)"
  if curl -fSL -o "$FILEPATH" "https://aka.ms/wslubuntu2204" 2>/dev/null; then
    SIZE=$(du -h "$FILEPATH" | cut -f1)
    echo "   ✅ 完成: $SIZE"
    TOTAL=$((TOTAL + 1))
  else
    echo "   ❌ 下載失敗: wslubuntu2204"
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
