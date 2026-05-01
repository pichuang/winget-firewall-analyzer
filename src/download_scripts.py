"""一鍵下載腳本產生器 — 產出 Bash 和 PowerShell 下載腳本"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from pathlib import PurePosixPath
from urllib.parse import urlparse

from src.models import PackageManifest


def _filename_from_url(url: str) -> str:
    """從 URL 取得檔案名稱。"""
    parsed = urlparse(url)
    return PurePosixPath(parsed.path).name or "installer"


def generate_download_bash(manifests: list[PackageManifest]) -> str:
    """產生 Bash 下載腳本（使用 curl）。"""
    now = datetime.now(timezone(timedelta(hours=8))).strftime("%Y-%m-%d %H:%M:%S")

    lines: list[str] = [
        "#!/bin/bash",
        f"# winget 安裝檔一鍵下載腳本",
        f"# 產生時間：{now}",
        f"# 套件數量：{len(manifests)}",
        "#",
        "# 用法：bash generated/download.sh",
        "# 檔案會下載到 ./downloads/{PackageId}/ 目錄",
        "",
        'set -euo pipefail',
        "",
        'DOWNLOAD_DIR="./downloads"',
        'TOTAL=0',
        'SKIPPED=0',
        'FAILED=0',
        "",
        'echo "🚀 開始下載 winget 安裝檔 ..."',
        'echo ""',
        "",
    ]

    for manifest in manifests:
        pkg = manifest.package_id
        pkg_dir = pkg.replace(".", "/")

        lines.extend([
            f"# === {pkg} v{manifest.version} ===",
            f'PKG_DIR="$DOWNLOAD_DIR/{pkg_dir}"',
            f'mkdir -p "$PKG_DIR"',
            f'echo "📦 {pkg} v{manifest.version}"',
            "",
        ])

        for installer in manifest.installers:
            filename = _filename_from_url(installer.url)
            arch = installer.architecture or "unknown"
            scope = installer.scope or "default"

            lines.extend([
                f'FILEPATH="$PKG_DIR/{filename}"',
                f'if [ -f "$FILEPATH" ]; then',
                f'  echo "   ⏭️  已存在: {filename} ({arch})"',
                f'  SKIPPED=$((SKIPPED + 1))',
                f'else',
                f'  echo "   ⬇️  下載中: {filename} ({arch}/{scope})"',
                f'  if curl -fSL -o "$FILEPATH" "{installer.url}" 2>/dev/null; then',
                f'    SIZE=$(du -h "$FILEPATH" | cut -f1)',
                f'    echo "   ✅ 完成: $SIZE"',
                f'    TOTAL=$((TOTAL + 1))',
                f'  else',
                f'    echo "   ❌ 下載失敗: {filename}"',
                f'    FAILED=$((FAILED + 1))',
                f'    rm -f "$FILEPATH"',
                f'  fi',
                f'fi',
                "",
            ])

    lines.extend([
        'echo ""',
        'echo "=============================="',
        'echo "📊 下載結果摘要"',
        'echo "   ✅ 成功下載: $TOTAL 個"',
        'echo "   ⏭️  已略過: $SKIPPED 個"',
        'echo "   ❌ 下載失敗: $FAILED 個"',
        'echo "   📂 下載目錄: $DOWNLOAD_DIR"',
        'echo "=============================="',
        "",
    ])

    return "\n".join(lines)


def generate_download_ps1(manifests: list[PackageManifest]) -> str:
    """產生 PowerShell 下載腳本（使用 Invoke-WebRequest）。"""
    now = datetime.now(timezone(timedelta(hours=8))).strftime("%Y-%m-%d %H:%M:%S")

    lines: list[str] = [
        f"# winget 安裝檔一鍵下載腳本",
        f"# 產生時間：{now}",
        f"# 套件數量：{len(manifests)}",
        "#",
        "# 用法：.\\generated\\download.ps1",
        "# 檔案會下載到 .\\downloads\\{PackageId}\\ 目錄",
        "",
        '$ErrorActionPreference = "Continue"',
        "",
        '$DownloadDir = ".\\downloads"',
        "$Total = 0",
        "$Skipped = 0",
        "$Failed = 0",
        "",
        'Write-Host "🚀 開始下載 winget 安裝檔 ..." -ForegroundColor Cyan',
        'Write-Host ""',
        "",
    ]

    for manifest in manifests:
        pkg = manifest.package_id
        pkg_dir = pkg.replace(".", "\\")

        lines.extend([
            f"# === {pkg} v{manifest.version} ===",
            f'$PkgDir = "$DownloadDir\\{pkg_dir}"',
            f'New-Item -ItemType Directory -Path $PkgDir -Force | Out-Null',
            f'Write-Host "📦 {pkg} v{manifest.version}" -ForegroundColor White',
            "",
        ])

        for installer in manifest.installers:
            filename = _filename_from_url(installer.url)
            arch = installer.architecture or "unknown"
            scope = installer.scope or "default"

            lines.extend([
                f'$FilePath = "$PkgDir\\{filename}"',
                f'if (Test-Path $FilePath) {{',
                f'    Write-Host "   ⏭️  已存在: {filename} ({arch})" -ForegroundColor DarkGray',
                f'    $Skipped++',
                f'}} else {{',
                f'    Write-Host "   ⬇️  下載中: {filename} ({arch}/{scope})" -ForegroundColor Yellow',
                f'    try {{',
                f'        Invoke-WebRequest -Uri "{installer.url}" -OutFile $FilePath -UseBasicParsing',
                f'        $Size = (Get-Item $FilePath).Length / 1MB',
                f'        Write-Host ("   ✅ 完成: {{0:N1}} MB" -f $Size) -ForegroundColor Green',
                f'        $Total++',
                f'    }} catch {{',
                f'        Write-Host "   ❌ 下載失敗: {filename}" -ForegroundColor Red',
                f'        $Failed++',
                f'        Remove-Item $FilePath -ErrorAction SilentlyContinue',
                f'    }}',
                f'}}',
                "",
            ])

    lines.extend([
        'Write-Host ""',
        'Write-Host "==============================" -ForegroundColor Cyan',
        'Write-Host "📊 下載結果摘要" -ForegroundColor Cyan',
        'Write-Host "   ✅ 成功下載: $Total 個"',
        'Write-Host "   ⏭️  已略過: $Skipped 個"',
        'Write-Host "   ❌ 下載失敗: $Failed 個"',
        'Write-Host "   📂 下載目錄: $DownloadDir"',
        'Write-Host "==============================" -ForegroundColor Cyan',
        "",
    ])

    return "\n".join(lines)
