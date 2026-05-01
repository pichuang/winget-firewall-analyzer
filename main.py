"""winget 防火牆規則分析工具 — 主程式入口

分析 winget 套件的下載路徑，產生 Azure Firewall Policy Application Rule 建議。
"""

from __future__ import annotations

import argparse
import asyncio
import sys
from pathlib import Path

import httpx
import yaml

from src.blocklist import filter_packages
from src.download_scripts import generate_download_bash, generate_download_ps1
from src.formatters import format_azure_cli, format_csv, format_json, format_markdown
from src.models import FirewallRule, PackageManifest
from src.package_discovery import discover_all_packages
from src.redirect_tracer import trace_redirects
from src.rule_generator import (
    generate_base_infrastructure_rule,
    generate_rules,
)
from src.winget_api import fetch_package
from src.wsl_analyzer import analyze_all_wsl_distros, get_wsl_base_fqdns, load_wsl_distros
from src.audit import generate_diff_report, get_latest_audit_log, write_audit_log, write_changelog_entry


def load_config(config_path: str = "config.yaml") -> dict:
    """載入設定檔。"""
    path = Path(config_path)
    if not path.exists():
        print(f"⚠️  找不到設定檔: {config_path}，使用預設值", file=sys.stderr)
        return {
            "allowlist": {"enabled": True, "publishers": [], "packages": []},
            "blocklist": {"enabled": False, "publishers": [], "packages": []},
            "firewall": {"source_addresses": ["10.0.0.0/8"]},
            "winget_base_fqdns": [],
        }
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f)


async def analyze_package(
    client: httpx.AsyncClient,
    package_id: str,
) -> tuple[PackageManifest, list[FirewallRule]]:
    """分析單一套件，回傳 (manifest, [path_rule, fqdn_rule])。"""
    print(f"\n📦 正在查詢套件: {package_id} ...", file=sys.stderr)
    manifest = await fetch_package(client, package_id)
    print(f"   版本: {manifest.version}，共 {len(manifest.installers)} 個安裝檔", file=sys.stderr)

    # 追蹤每個 installer URL 的重導向鏈
    for installer in manifest.installers:
        print(f"   🔗 追蹤重導向: {installer.url[:80]}...", file=sys.stderr)
        installer.redirect_chain = await trace_redirects(client, installer.url)
        hops_info = " → ".join(hop.fqdn for hop in installer.redirect_chain)
        print(f"      鏈路: {hops_info}", file=sys.stderr)

    rules = list(generate_rules(manifest, source_addresses=[]))
    return manifest, rules


async def main_async(args: argparse.Namespace) -> None:
    """非同步主流程。"""
    config = load_config(args.config)
    firewall_config = config.get("firewall", {})
    source_addresses = firewall_config.get("source_addresses", ["10.0.0.0/8"])
    source_ip_groups = firewall_config.get("source_ip_groups", [])
    base_fqdns = config.get("winget_base_fqdns", [])

    # blocklist 從同一份設定檔讀取
    blocklist_config = {"blocklist": config.get("blocklist", {"enabled": False, "publishers": [], "packages": []})}

    # 建立 HTTP client（支援 GITHUB_TOKEN 環境變數，或自動從 gh CLI 取得）
    import os
    import subprocess
    headers: dict[str, str] = {}
    github_token = os.environ.get("GITHUB_TOKEN")
    if not github_token:
        try:
            result = subprocess.run(
                ["gh", "auth", "token"],
                capture_output=True, text=True, timeout=5,
            )
            if result.returncode == 0 and result.stdout.strip():
                github_token = result.stdout.strip()
                print("🔑 已透過 gh CLI 取得 GITHUB_TOKEN", file=sys.stderr)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass
    if github_token:
        headers["Authorization"] = f"token {github_token}"
        if not os.environ.get("GITHUB_TOKEN"):
            pass  # 已在上方印過訊息
        else:
            print("🔑 已偵測 GITHUB_TOKEN 環境變數，使用認證模式（API 配額較高）", file=sys.stderr)
    else:
        print("⚠️  未偵測到 GITHUB_TOKEN，API 配額較低（建議執行 gh auth login）", file=sys.stderr)

    # 結果容器（winget + WSL 共用）
    all_rules: list[FirewallRule] = []
    all_manifests: list[PackageManifest] = []

    async with httpx.AsyncClient(
        headers=headers,
        follow_redirects=False,
        timeout=30.0,
    ) as client:
        # 決定要分析的套件清單
        if args.all:
            allowlist = config.get("allowlist", {})
            allowed_patterns = allowlist.get("packages", [])
            if not allowed_patterns:
                print("⚠️  config.yaml 中未定義 allowlist.packages", file=sys.stderr)
                sys.exit(1)

            # 取得封鎖清單模式，在探索階段直接跳過封鎖的套件
            bl = blocklist_config.get("blocklist", {})
            bl_patterns = bl.get("packages", []) if bl.get("enabled", False) else []

            print("📂 正在探索 allowlist 中的所有套件 ...", file=sys.stderr)
            all_discovered = await discover_all_packages(
                client, allowed_patterns, blocklist_patterns=bl_patterns,
            )
            print(f"\n📊 共探索到 {len(all_discovered)} 個套件（已排除封鎖項目）", file=sys.stderr)

            package_ids = all_discovered
            blocked_ids: list[str] = []
            print(f"✅ 最終分析目標: {len(package_ids)} 個套件", file=sys.stderr)
        else:
            # 手動指定模式 — 也套用封鎖清單
            package_ids, blocked_ids = filter_packages(
                args.packages,
                blocklist_config=blocklist_config,
            )
            if blocked_ids:
                print(f"🚫 封鎖清單排除: {', '.join(blocked_ids)}", file=sys.stderr)

        # dry-run 模式：僅列出套件清單
        if args.dry_run:
            print("\n📋 套件清單（dry-run 模式，不進行分析）：", file=sys.stderr)
            for pkg_id in package_ids:
                print(f"  ✅ {pkg_id}")
            if blocked_ids:
                print(f"\n🚫 被封鎖的套件：", file=sys.stderr)
                for pkg_id in blocked_ids:
                    print(f"  ❌ {pkg_id}")
            if args.wsl:
                wsl_distros = load_wsl_distros(config)
                if wsl_distros:
                    print(f"\n🐧 WSL 發行版：", file=sys.stderr)
                    for d in wsl_distros:
                        print(f"  🐧 {d.name} ({d.download_url})")
            print(f"\n共 {len(package_ids)} 個允許 / {len(blocked_ids)} 個封鎖", file=sys.stderr)
            return

        # 分析每個套件
        for package_id in package_ids:
            try:
                manifest, rules = await analyze_package(client, package_id)
                for rule in rules:
                    rule.source_addresses = source_addresses
                    rule.source_ip_groups = source_ip_groups
                all_rules.extend(rules)
                all_manifests.append(manifest)
                print(f"   ✅ {manifest.package_id} v{manifest.version} 分析完成", file=sys.stderr)
            except Exception as e:
                print(f"   ❌ {package_id} 分析失敗: {e}", file=sys.stderr)

    # 加入基礎設施規則
    if base_fqdns:
        infra_rule = generate_base_infrastructure_rule(base_fqdns, source_addresses, source_ip_groups)
        all_rules.insert(0, infra_rule)

    # ── WSL 發行版分析 ──
    wsl_manifests: list[PackageManifest] = []
    wsl_rules: list[FirewallRule] = []
    if args.wsl:
        wsl_distros = load_wsl_distros(config)
        wsl_base_fqdns = get_wsl_base_fqdns(config)

        if not wsl_distros:
            print("⚠️  config.yaml 中未定義或未啟用 WSL 發行版", file=sys.stderr)
        else:
            async with httpx.AsyncClient(
                headers=headers,
                follow_redirects=False,
                timeout=30.0,
            ) as wsl_client:
                print(f"\n🐧 開始分析 WSL 發行版（共 {len(wsl_distros)} 個）...", file=sys.stderr)

                wsl_manifests, wsl_rules = await analyze_all_wsl_distros(
                    wsl_client, wsl_distros, source_addresses, source_ip_groups,
                )

                for m in wsl_manifests:
                    for inst in m.installers:
                        hops_info = " → ".join(hop.fqdn for hop in inst.redirect_chain)
                        print(f"   🔗 {m.package_id}: {hops_info}", file=sys.stderr)
                    print(f"   ✅ {m.package_id} ({m.version}) 分析完成", file=sys.stderr)

                print(f"\n📊 WSL 分析完成：{len(wsl_manifests)} 個發行版", file=sys.stderr)

            # 加入 WSL 基礎設施規則
            if wsl_base_fqdns:
                wsl_infra_rule = generate_base_infrastructure_rule(
                    wsl_base_fqdns, source_addresses, source_ip_groups,
                )
                wsl_infra_rule.name = "wsl-infrastructure-fqdn"
                wsl_infra_rule.description = "WSL 基礎設施端點（所有 WSL 發行版共用）：" + "；".join(
                    f"{e['fqdn']} — {e.get('description', '')}" for e in wsl_base_fqdns
                )
                wsl_infra_rule.package_id = "*（WSL）"
                all_rules.append(wsl_infra_rule)

            all_rules.extend(wsl_rules)
            all_manifests.extend(wsl_manifests)

    if not all_rules:
        print("\n⚠️  沒有產出任何規則", file=sys.stderr)
        sys.exit(1)

    # 輸出結果
    print(f"\n📋 共產出 {len(all_rules)} 條規則", file=sys.stderr)

    rc_name = firewall_config.get("rule_collection_name", "action-allow-mirror")
    rcg_name = firewall_config.get("rule_collection_group_name", "rcg-1100-mirror-winget")
    priority = firewall_config.get("priority", 1100)

    # 時間戳記（用於產出資料夾名稱）
    from datetime import datetime, timedelta, timezone
    ts = datetime.now(timezone(timedelta(hours=8))).strftime("%Y%m%d_%H%M%S")

    # 建立時間戳記子目錄：generated/YYYYMMDD_HHMMSS/
    generated_dir = Path("generated") / ts
    generated_dir.mkdir(parents=True, exist_ok=True)

    format_ext_map = {
        "json": f"rules_{ts}.json",
        "csv": f"rules_{ts}.csv",
        "cli": f"deploy_{ts}.sh",
        "md": f"firewall-rules_{ts}.md",
    }

    if args.format == "json":
        output = format_json(all_rules, rc_name, rcg_name, priority)
    elif args.format == "csv":
        output = format_csv(all_rules)
    elif args.format == "cli":
        output = format_azure_cli(
            all_rules,
            rule_collection_group_name=rcg_name,
            rule_collection_name=rc_name,
            priority=priority,
        )
    elif args.format == "md":
        output = format_markdown(
            all_manifests, all_rules, base_fqdns or None, firewall_config,
        )
    else:
        output = format_json(all_rules, rc_name, rcg_name, priority)

    # 自動寫入 generated/{ts}/ 資料夾
    output_filename = format_ext_map.get(args.format, "rules.json")
    output_path = generated_dir / output_filename
    output_path.write_text(output, encoding="utf-8")
    if args.format == "cli":
        output_path.chmod(0o755)
    print(f"\n📄 已寫入: {output_path.resolve()}", file=sys.stderr)

    # 產生下載腳本與部署腳本
    if args.download_scripts and all_manifests:
        bash_script = generate_download_bash(all_manifests)
        ps1_script = generate_download_ps1(all_manifests)
        deploy_script = format_azure_cli(
            all_rules,
            rule_collection_group_name=rcg_name,
            rule_collection_name=rc_name,
            priority=priority,
        )

        bash_path = generated_dir / f"download_{ts}.sh"
        ps1_path = generated_dir / f"download_{ts}.ps1"
        deploy_path = generated_dir / f"deploy_{ts}.sh"

        bash_path.write_text(bash_script, encoding="utf-8")
        ps1_path.write_text(ps1_script, encoding="utf-8")
        deploy_path.write_text(deploy_script, encoding="utf-8")
        bash_path.chmod(0o755)
        deploy_path.chmod(0o755)

        print(f"\n📥 已產生腳本：", file=sys.stderr)
        print(f"   下載 Bash:       {bash_path.resolve()}", file=sys.stderr)
        print(f"   下載 PowerShell: {ps1_path.resolve()}", file=sys.stderr)
        print(f"   部署 Azure CLI:  {deploy_path.resolve()}", file=sys.stderr)

    # 寫入稽核日誌
    if all_manifests:
        output_files: dict[str, str] = {}
        if args.download_scripts:
            output_files["download.sh"] = str(generated_dir / f"download_{ts}.sh")
            output_files["download.ps1"] = str(generated_dir / f"download_{ts}.ps1")
            output_files["deploy.sh"] = str(generated_dir / f"deploy_{ts}.sh")

        # 取得前次稽核日誌（在寫入新日誌之前）
        from src.audit import AUDIT_DIR
        existing_logs = sorted(AUDIT_DIR.glob("audit_*.json")) if AUDIT_DIR.exists() else []
        prev = existing_logs[-1] if existing_logs else None

        # 寫入 JSON 稽核日誌
        log_path = write_audit_log(
            all_manifests,
            config_path=args.config,
            output_files=output_files,
        )
        print(f"\n📝 稽核日誌：{log_path.resolve()}", file=sys.stderr)

        # 寫入變更記錄
        changelog_path = write_changelog_entry(all_manifests, previous_log=prev)
        print(f"📋 變更記錄：{changelog_path.resolve()}", file=sys.stderr)

        # 產生前後對比報告
        diff_report = generate_diff_report(all_manifests, previous_log=prev)
        diff_path = generated_dir / f"diff-report_{ts}.md"
        diff_path.write_text(diff_report, encoding="utf-8")
        print(f"🔄 對比報告：{diff_path.resolve()}", file=sys.stderr)

    print(f"\n📂 本次產出目錄：{generated_dir.resolve()}", file=sys.stderr)


def main() -> None:
    examples = """\
使用範例：
  python main.py                                 # 自動分析 config.yaml 中所有允許的套件 + WSL
  python main.py Microsoft.Git GitHub.cli        # 分析指定套件
  python main.py --wsl                           # 僅分析 WSL 發行版下載路徑
  python main.py Microsoft.Git --wsl             # 分析指定套件 + WSL 發行版
  python main.py --dry-run                       # 僅列出套件清單，不分析
  python main.py -f json                         # 輸出 JSON 格式（ARM Template 相容）
  python main.py -f csv                          # 輸出 CSV（匯入試算表審閱）
  python main.py -f cli                          # 輸出 Azure CLI 部署腳本
  python main.py --no-download-scripts           # 不產生下載腳本

結果自動寫入 generated/ 資料夾，GITHUB_TOKEN 自動從 gh CLI 取得。"""

    parser = argparse.ArgumentParser(
        description="分析 winget 套件下載路徑，產生 Azure Firewall Policy 規則建議",
        epilog=examples,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "packages",
        nargs="*",
        help="要分析的套件識別碼（例如 Microsoft.Git GitHub.cli）",
    )
    parser.add_argument(
        "--all", "-a",
        action="store_true",
        help="依據 config.yaml 的 allowlist 自動探索並分析所有匹配套件",
    )
    parser.add_argument(
        "--wsl",
        action="store_true",
        help="同時分析 WSL 發行版下載路徑（依 config.yaml 的 wsl_distros 設定）",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="僅列出匹配的套件清單，不進行分析",
    )
    parser.add_argument(
        "--format", "-f",
        choices=["json", "csv", "cli", "md"],
        default="md",
        help="輸出格式（預設: md）",
    )
    parser.add_argument(
        "--config", "-c",
        default="config.yaml",
        help="設定檔路徑（預設: config.yaml）",
    )
    parser.add_argument(
        "--download-scripts",
        action="store_true",
        default=True,
        help="同時產生腳本（generated/deploy.sh、generated/download.sh 和 generated/download.ps1，預設啟用）",
    )
    parser.add_argument(
        "--no-download-scripts",
        action="store_false",
        dest="download_scripts",
        help="不產生下載與部署腳本",
    )

    args = parser.parse_args()

    # 未指定任何套件時的預設行為
    if not args.all and not args.packages:
        if args.wsl:
            # 僅指定 --wsl 時，不自動啟用 --all（僅分析 WSL）
            print("ℹ️  僅分析 WSL 發行版（未指定 winget 套件）", file=sys.stderr)
        else:
            args.all = True
            print("ℹ️  未指定套件，自動使用 --all 模式（依 config.yaml 探索）", file=sys.stderr)

    # 自動啟用 WSL 分析（若 config 中已啟用且使用 --all 模式）
    if not args.wsl and args.all:
        _cfg = load_config(args.config)
        if _cfg.get("wsl_distros", {}).get("enabled", False):
            args.wsl = True
            print("ℹ️  WSL 發行版分析已啟用（依 config.yaml 設定）", file=sys.stderr)

    asyncio.run(main_async(args))


if __name__ == "__main__":
    main()
