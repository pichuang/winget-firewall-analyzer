"""稽核日誌 — 記錄每次套件清單更新與軟體分析的完整歷程"""

from __future__ import annotations

import getpass
import hashlib
import json
import os
import platform
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

from src.models import PackageManifest

AUDIT_DIR = Path("audit_logs")
TZ = timezone(timedelta(hours=8))


def _now() -> str:
    return datetime.now(TZ).strftime("%Y-%m-%d %H:%M:%S %Z")


def _now_filename() -> str:
    return datetime.now(TZ).strftime("%Y%m%d_%H%M%S")


def _file_sha256(path: str | Path) -> str:
    """計算檔案 SHA-256。"""
    h = hashlib.sha256()
    p = Path(path)
    if not p.exists():
        return ""
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def _get_operator() -> str:
    """取得操作人員資訊。"""
    user = getpass.getuser()
    hostname = platform.node()
    return f"{user}@{hostname}"


def ensure_audit_dir() -> Path:
    """確保稽核日誌目錄存在。"""
    AUDIT_DIR.mkdir(parents=True, exist_ok=True)
    return AUDIT_DIR


def write_audit_log(
    manifests: list[PackageManifest],
    config_path: str = "config.yaml",
    output_files: dict[str, str] | None = None,
) -> Path:
    """寫入稽核日誌（JSON 格式）。

    記錄內容：
    - 操作時間、操作人員、執行環境
    - 設定檔快照（allowlist / blocklist SHA-256）
    - 每個套件的版本、安裝檔 URL、SHA-256（manifest 中的值）
    - 產出檔案清單與 SHA-256
    """
    audit_dir = ensure_audit_dir()
    timestamp = _now_filename()

    # 套件詳細記錄
    packages_record: list[dict[str, Any]] = []
    for manifest in manifests:
        installers_record = []
        for inst in manifest.installers:
            fqdns = []
            for hop in inst.redirect_chain:
                if hop.fqdn:
                    fqdns.append(hop.fqdn)

            installers_record.append({
                "url": inst.url,
                "architecture": inst.architecture,
                "scope": inst.scope,
                "installer_type": inst.installer_type,
                "redirect_chain_fqdns": fqdns,
            })

        packages_record.append({
            "package_id": manifest.package_id,
            "version": manifest.version,
            "publisher": manifest.publisher,
            "installer_count": len(manifest.installers),
            "installers": installers_record,
        })

    # 產出檔案記錄
    output_files_record: dict[str, dict[str, str]] = {}
    if output_files:
        for name, path in output_files.items():
            p = Path(path)
            output_files_record[name] = {
                "path": str(p.resolve()) if p.exists() else path,
                "sha256": _file_sha256(p),
                "size_bytes": str(p.stat().st_size) if p.exists() else "0",
            }

    audit_entry = {
        "audit_version": "1.0",
        "timestamp": _now(),
        "operator": _get_operator(),
        "environment": {
            "os": platform.platform(),
            "python": platform.python_version(),
            "hostname": platform.node(),
        },
        "config": {
            "path": config_path,
            "sha256": _file_sha256(config_path),
        },
        "summary": {
            "total_packages_analyzed": len(manifests),
            "package_ids": [m.package_id for m in manifests],
        },
        "packages": packages_record,
        "output_files": output_files_record,
    }

    # 寫入 JSON
    log_path = audit_dir / f"audit_{timestamp}.json"
    with open(log_path, "w", encoding="utf-8") as f:
        json.dump(audit_entry, f, indent=2, ensure_ascii=False)

    return log_path


def write_changelog_entry(
    manifests: list[PackageManifest],
    previous_log: Path | None = None,
) -> Path:
    """寫入變更記錄（Markdown 追加格式），記錄版本變更。"""
    changelog_path = AUDIT_DIR / "CHANGELOG.md"
    ensure_audit_dir()

    # 讀取上一次的套件版本（若有）
    previous_versions: dict[str, str] = {}
    if previous_log and previous_log.exists():
        with open(previous_log, encoding="utf-8") as f:
            prev_data = json.load(f)
        for pkg in prev_data.get("packages", []):
            previous_versions[pkg["package_id"]] = pkg["version"]

    # 比對差異
    new_packages: list[str] = []
    updated_packages: list[tuple[str, str, str]] = []  # (id, old, new)
    unchanged_packages: list[str] = []

    for manifest in manifests:
        pid = manifest.package_id
        if pid not in previous_versions:
            new_packages.append(f"`{pid}` v{manifest.version}")
        elif previous_versions[pid] != manifest.version:
            updated_packages.append((pid, previous_versions[pid], manifest.version))
        else:
            unchanged_packages.append(pid)

    # 產出 Markdown 段落
    entry_lines = [
        f"## {_now()}",
        "",
        f"- **操作人員**：{_get_operator()}",
        f"- **分析套件數**：{len(manifests)}",
    ]

    if updated_packages:
        entry_lines.extend(["", "### 版本更新", ""])
        entry_lines.append("| 套件 | 舊版本 | 新版本 |")
        entry_lines.append("|---|---|---|")
        for pid, old, new in sorted(updated_packages):
            entry_lines.append(f"| `{pid}` | {old} | {new} |")

    if new_packages:
        entry_lines.extend(["", "### 新增套件", ""])
        for p in sorted(new_packages):
            entry_lines.append(f"- {p}")

    if not updated_packages and not new_packages:
        entry_lines.extend(["", "無版本變更。"])

    entry_lines.extend([
        "",
        f"未變更套件：{len(unchanged_packages)} 個",
        "",
        "---",
        "",
    ])

    entry_text = "\n".join(entry_lines)

    # 追加到 CHANGELOG
    if changelog_path.exists():
        existing = changelog_path.read_text(encoding="utf-8")
        # 插入到標題之後
        if existing.startswith("# "):
            header_end = existing.index("\n") + 1
            new_content = existing[:header_end] + "\n" + entry_text + existing[header_end:]
        else:
            new_content = entry_text + existing
    else:
        new_content = "# winget 套件變更記錄（稽核用）\n\n" + entry_text

    changelog_path.write_text(new_content, encoding="utf-8")
    return changelog_path


def get_latest_audit_log() -> Path | None:
    """取得最新的稽核日誌檔案路徑。"""
    if not AUDIT_DIR.exists():
        return None
    logs = sorted(AUDIT_DIR.glob("audit_*.json"))
    return logs[-1] if logs else None


def _load_audit_data(log_path: Path) -> dict[str, Any]:
    """載入稽核日誌 JSON。"""
    with open(log_path, encoding="utf-8") as f:
        return json.load(f)


def _extract_fqdns_by_package(audit_data: dict[str, Any]) -> dict[str, set[str]]:
    """從稽核資料中擷取每個套件涉及的 FQDN 集合。"""
    result: dict[str, set[str]] = {}
    for pkg in audit_data.get("packages", []):
        pid = pkg["package_id"]
        fqdns: set[str] = set()
        for inst in pkg.get("installers", []):
            for fqdn in inst.get("redirect_chain_fqdns", []):
                fqdns.add(fqdn)
        result[pid] = fqdns
    return result


def _extract_urls_by_package(audit_data: dict[str, Any]) -> dict[str, set[str]]:
    """從稽核資料中擷取每個套件的安裝檔 URL 集合。"""
    result: dict[str, set[str]] = {}
    for pkg in audit_data.get("packages", []):
        pid = pkg["package_id"]
        urls: set[str] = set()
        for inst in pkg.get("installers", []):
            if inst.get("url"):
                urls.add(inst["url"])
        result[pid] = urls
    return result


def generate_diff_report(
    manifests: list[PackageManifest],
    previous_log: Path | None = None,
) -> str:
    """產生前後對比報告（Markdown 格式）。

    比對項目：
    - 套件清單變更（新增 / 移除 / 版本更新）
    - FQDN 變更（新增 / 移除的網域）
    - 安裝檔 URL 變更
    """
    lines: list[str] = [
        "# 🔄 變更對比報告",
        "",
        f"> 產生時間：{_now()}",
        "",
    ]

    # 建構本次資料
    current_pkgs: dict[str, str] = {m.package_id: m.version for m in manifests}
    current_fqdns: dict[str, set[str]] = {}
    current_urls: dict[str, set[str]] = {}
    for m in manifests:
        fqdns: set[str] = set()
        urls: set[str] = set()
        for inst in m.installers:
            urls.add(inst.url)
            for hop in inst.redirect_chain:
                if hop.fqdn:
                    fqdns.add(hop.fqdn)
        current_fqdns[m.package_id] = fqdns
        current_urls[m.package_id] = urls

    # 載入前次資料
    prev_pkgs: dict[str, str] = {}
    prev_fqdns: dict[str, set[str]] = {}
    prev_urls: dict[str, set[str]] = {}
    prev_timestamp = "（無前次紀錄）"

    if previous_log and previous_log.exists():
        prev_data = _load_audit_data(previous_log)
        prev_timestamp = prev_data.get("timestamp", str(previous_log.name))
        for pkg in prev_data.get("packages", []):
            prev_pkgs[pkg["package_id"]] = pkg["version"]
        prev_fqdns = _extract_fqdns_by_package(prev_data)
        prev_urls = _extract_urls_by_package(prev_data)

    # ── 摘要 ──
    new_ids = set(current_pkgs) - set(prev_pkgs)
    removed_ids = set(prev_pkgs) - set(current_pkgs)
    common_ids = set(current_pkgs) & set(prev_pkgs)
    updated_ids = {pid for pid in common_ids if current_pkgs[pid] != prev_pkgs[pid]}
    unchanged_ids = common_ids - updated_ids

    lines.extend([
        "## 📊 摘要",
        "",
        f"| 項目 | 數值 |",
        f"|---|---|",
        f"| 前次分析 | {prev_timestamp}，共 {len(prev_pkgs)} 個套件 |",
        f"| 本次分析 | {_now()}，共 {len(current_pkgs)} 個套件 |",
        f"| 新增套件 | {len(new_ids)} 個 |",
        f"| 移除套件 | {len(removed_ids)} 個 |",
        f"| 版本更新 | {len(updated_ids)} 個 |",
        f"| 未變更 | {len(unchanged_ids)} 個 |",
        "",
    ])

    # 無任何變更
    if not new_ids and not removed_ids and not updated_ids:
        all_fqdns_same = all(
            current_fqdns.get(pid, set()) == prev_fqdns.get(pid, set())
            for pid in common_ids
        )
        if all_fqdns_same:
            lines.extend(["✅ **與前次分析完全一致，無任何變更。**", ""])
            return "\n".join(lines)

    # ── 套件變更 ──
    lines.extend(["---", "", "## 📦 套件變更", ""])

    if new_ids:
        lines.extend(["### ➕ 新增套件", "", "| 套件識別碼 | 版本 |", "|---|---|"])
        for pid in sorted(new_ids):
            lines.append(f"| `{pid}` | {current_pkgs[pid]} |")
        lines.append("")

    if removed_ids:
        lines.extend(["### ➖ 移除套件", "", "| 套件識別碼 | 前次版本 |", "|---|---|"])
        for pid in sorted(removed_ids):
            lines.append(f"| `{pid}` | {prev_pkgs[pid]} |")
        lines.append("")

    if updated_ids:
        lines.extend(["### 🔄 版本更新", "", "| 套件識別碼 | 舊版本 | 新版本 |", "|---|---|---|"])
        for pid in sorted(updated_ids):
            lines.append(f"| `{pid}` | {prev_pkgs[pid]} | {current_pkgs[pid]} |")
        lines.append("")

    # ── FQDN 變更 ──
    all_current_fqdns: set[str] = set()
    all_prev_fqdns: set[str] = set()
    for fqdns in current_fqdns.values():
        all_current_fqdns |= fqdns
    for fqdns in prev_fqdns.values():
        all_prev_fqdns |= fqdns

    new_fqdns = all_current_fqdns - all_prev_fqdns
    removed_fqdns = all_prev_fqdns - all_current_fqdns

    if new_fqdns or removed_fqdns:
        lines.extend(["---", "", "## 🌐 FQDN 變更", ""])

        if new_fqdns:
            lines.extend(["### ➕ 新增 FQDN", "", "| FQDN | 涉及套件 |", "|---|---|"])
            for fqdn in sorted(new_fqdns):
                pkgs = [pid for pid, fs in current_fqdns.items() if fqdn in fs]
                lines.append(f"| `{fqdn}` | {', '.join(f'`{p}`' for p in sorted(pkgs))} |")
            lines.append("")

        if removed_fqdns:
            lines.extend(["### ➖ 移除 FQDN", "", "| FQDN | 原涉及套件 |", "|---|---|"])
            for fqdn in sorted(removed_fqdns):
                pkgs = [pid for pid, fs in prev_fqdns.items() if fqdn in fs]
                lines.append(f"| `{fqdn}` | {', '.join(f'`{p}`' for p in sorted(pkgs))} |")
            lines.append("")
    else:
        lines.extend(["---", "", "## 🌐 FQDN 變更", "", "✅ 無 FQDN 變更。", ""])

    # ── URL 變更（逐套件）──
    url_changes: list[tuple[str, set[str], set[str]]] = []
    for pid in sorted(common_ids):
        cur = current_urls.get(pid, set())
        prev = prev_urls.get(pid, set())
        if cur != prev:
            url_changes.append((pid, cur - prev, prev - cur))

    if url_changes:
        lines.extend(["---", "", "## 🔗 安裝檔 URL 變更", ""])
        for pid, added, removed in url_changes:
            lines.append(f"### `{pid}`")
            lines.append("")
            if added:
                for url in sorted(added):
                    lines.append(f"- ➕ `{url}`")
            if removed:
                for url in sorted(removed):
                    lines.append(f"- ➖ ~~`{url}`~~")
            lines.append("")

    # ── 防火牆規則影響評估 ──
    lines.extend(["---", "", "## 🛡️ 防火牆規則影響評估", ""])

    if new_fqdns:
        lines.append(f"⚠️ **需新增** {len(new_fqdns)} 個 FQDN 至防火牆規則：")
        lines.append("")
        for fqdn in sorted(new_fqdns):
            lines.append(f"- `{fqdn}`")
        lines.append("")

    if removed_fqdns:
        lines.append(f"🗑️ **可考慮移除** {len(removed_fqdns)} 個 FQDN：")
        lines.append("")
        for fqdn in sorted(removed_fqdns):
            lines.append(f"- `{fqdn}`")
        lines.append("")

    if not new_fqdns and not removed_fqdns:
        lines.append("✅ 防火牆規則不需調整。")
        lines.append("")

    return "\n".join(lines)
