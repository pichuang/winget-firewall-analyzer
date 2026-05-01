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
from src.audit import get_latest_audit_log, write_audit_log, write_changelog_entry


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
    base_fqdns = config.get("winget_base_fqdns", [])

    # blocklist 從同一份設定檔讀取
    blocklist_config = {"blocklist": config.get("blocklist", {"enabled": False, "publishers": [], "packages": []})}

    # 建立 HTTP client（支援 GITHUB_TOKEN 環境變數）
    import os
    headers: dict[str, str] = {}
    github_token = os.environ.get("GITHUB_TOKEN")
    if github_token:
        headers["Authorization"] = f"token {github_token}"
        print("🔑 已偵測 GITHUB_TOKEN，使用認證模式（API 配額較高）", file=sys.stderr)

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

            print("📂 正在探索 allowlist 中的所有套件 ...", file=sys.stderr)
            all_discovered = await discover_all_packages(client, allowed_patterns)
            print(f"\n📊 共探索到 {len(all_discovered)} 個套件", file=sys.stderr)

            # 套用封鎖清單
            package_ids, blocked_ids = filter_packages(
                all_discovered,
                allowlist_config=config.get("allowlist"),
                blocklist_config=blocklist_config,
            )
            if blocked_ids:
                print(f"🚫 封鎖清單排除 {len(blocked_ids)} 個套件", file=sys.stderr)

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
            print(f"\n共 {len(package_ids)} 個允許 / {len(blocked_ids)} 個封鎖", file=sys.stderr)
            return

        # 分析每個套件
        all_rules: list[FirewallRule] = []
        all_manifests: list[PackageManifest] = []

        for package_id in package_ids:
            try:
                manifest, rules = await analyze_package(client, package_id)
                for rule in rules:
                    rule.source_addresses = source_addresses
                all_rules.extend(rules)
                all_manifests.append(manifest)
                print(f"   ✅ {manifest.package_id} v{manifest.version} 分析完成", file=sys.stderr)
            except Exception as e:
                print(f"   ❌ {package_id} 分析失敗: {e}", file=sys.stderr)

    # 加入基礎設施規則
    if base_fqdns:
        infra_rule = generate_base_infrastructure_rule(base_fqdns, source_addresses)
        all_rules.insert(0, infra_rule)

    if not all_rules:
        print("\n⚠️  沒有產出任何規則", file=sys.stderr)
        sys.exit(1)

    # 輸出結果
    print(f"\n📋 共產出 {len(all_rules)} 條規則", file=sys.stderr)

    rc_name = firewall_config.get("rule_collection_name", "winget-download")
    rcg_name = firewall_config.get("rule_collection_group_name", "winget-rules")
    priority = firewall_config.get("priority", 500)

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

    print(output)

    # 產生下載腳本
    if args.download_scripts and all_manifests:
        bash_script = generate_download_bash(all_manifests)
        ps1_script = generate_download_ps1(all_manifests)

        generated_dir = Path("generated")
        generated_dir.mkdir(exist_ok=True)
        bash_path = generated_dir / "download.sh"
        ps1_path = generated_dir / "download.ps1"

        bash_path.write_text(bash_script, encoding="utf-8")
        ps1_path.write_text(ps1_script, encoding="utf-8")
        bash_path.chmod(0o755)

        print(f"\n📥 已產生下載腳本：", file=sys.stderr)
        print(f"   Bash:       {bash_path.resolve()}", file=sys.stderr)
        print(f"   PowerShell: {ps1_path.resolve()}", file=sys.stderr)

    # 寫入稽核日誌
    if all_manifests:
        output_files: dict[str, str] = {}
        if args.download_scripts:
            output_files["download.sh"] = "generated/download.sh"
            output_files["download.ps1"] = "generated/download.ps1"

        # 寫入 JSON 稽核日誌
        log_path = write_audit_log(
            all_manifests,
            config_path=args.config,
            output_files=output_files,
        )
        print(f"\n📝 稽核日誌：{log_path.resolve()}", file=sys.stderr)

        # 寫入變更記錄（與上次比對）
        previous_log = get_latest_audit_log()
        # 取得倒數第二個日誌（剛才寫入的是最新的）
        from src.audit import AUDIT_DIR
        logs = sorted(AUDIT_DIR.glob("audit_*.json"))
        prev = logs[-2] if len(logs) >= 2 else None

        changelog_path = write_changelog_entry(all_manifests, previous_log=prev)
        print(f"📋 變更記錄：{changelog_path.resolve()}", file=sys.stderr)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="分析 winget 套件下載路徑，產生 Azure Firewall Policy 規則建議",
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
        help="同時產生一鍵下載腳本（generated/download.sh 和 generated/download.ps1，預設啟用）",
    )
    parser.add_argument(
        "--no-download-scripts",
        action="store_false",
        dest="download_scripts",
        help="不產生下載腳本",
    )

    args = parser.parse_args()

    if not args.all and not args.packages:
        parser.error("請指定套件識別碼，或使用 --all 從 config.yaml 自動探索")

    asyncio.run(main_async(args))


if __name__ == "__main__":
    main()
