"""Azure Firewall Policy 規則產生器"""

from __future__ import annotations

from src.models import (
    Confidence,
    FirewallRule,
    FqdnCategory,
    FqdnEntry,
    PackageManifest,
    RedirectHop,
    generalize_url_path,
)


def _classify_fqdn(fqdn: str) -> FqdnCategory:
    """依據 FQDN 判斷用途分類。"""
    fqdn_lower = fqdn.lower()

    if any(kw in fqdn_lower for kw in ("cdn.winget", "winget.azureedge")):
        return FqdnCategory.WINGET_SOURCE
    if any(kw in fqdn_lower for kw in ("github.com",)):
        return FqdnCategory.DOWNLOAD
    if any(kw in fqdn_lower for kw in (
        "githubusercontent.com", "desktop.githubusercontent.com",
        "release-assets.githubusercontent.com",
    )):
        return FqdnCategory.CDN
    if any(kw in fqdn_lower for kw in ("dl.delivery.mp.microsoft.com",)):
        return FqdnCategory.CDN
    if any(kw in fqdn_lower for kw in ("login.microsoftonline.com",)):
        return FqdnCategory.AUTH
    if any(kw in fqdn_lower for kw in ("azureedge.net", "akamai", "cloudfront")):
        return FqdnCategory.CDN

    return FqdnCategory.UNKNOWN


def collect_fqdn_entries(
    manifest: PackageManifest,
) -> list[FqdnEntry]:
    """從套件 manifest 的重導向鏈中收集所有不重複的 FQDN。"""
    fqdn_map: dict[str, FqdnEntry] = {}

    for installer in manifest.installers:
        for hop in installer.redirect_chain:
            fqdn = hop.fqdn
            if not fqdn:
                continue

            if fqdn not in fqdn_map:
                fqdn_map[fqdn] = FqdnEntry(
                    fqdn=fqdn,
                    category=_classify_fqdn(fqdn),
                    confidence=Confidence.HIGH if hop.is_final else Confidence.MEDIUM,
                    source_package=manifest.package_id,
                    sample_paths=[],
                )

            entry = fqdn_map[fqdn]
            # 收集不重複的 path 範例
            path = hop.path
            if path and path not in entry.sample_paths:
                entry.sample_paths.append(path)

            # 最終目標的信心等級較高
            if hop.is_final and entry.confidence != Confidence.HIGH:
                entry.confidence = Confidence.HIGH

    return list(fqdn_map.values())


def generate_rules(
    manifest: PackageManifest,
    source_addresses: list[str],
    base_fqdns: list[dict[str, str]] | None = None,
) -> tuple[FirewallRule, FirewallRule]:
    """為單一套件產生防火牆規則（path 層級 + FQDN 層級）。

    回傳 (path_rule, fqdn_rule) 元組。
    """
    package_slug = (
        manifest.package_id.lower()
        .replace(".", "-")
        .replace("microsoft-", "ms-")
        .replace("github-", "gh-")
    )

    # 收集所有重導向鏈中的 FQDN 與 URL
    all_fqdns: set[str] = set()
    all_target_urls: set[str] = set()

    for installer in manifest.installers:
        for hop in installer.redirect_chain:
            if hop.fqdn:
                all_fqdns.add(hop.fqdn)
                generalized = generalize_url_path(hop.url)
                all_target_urls.add(generalized)

    # 加入 winget 基礎設施 FQDN
    if base_fqdns:
        for entry in base_fqdns:
            all_fqdns.add(entry["fqdn"])

    sorted_fqdns = sorted(all_fqdns)
    sorted_urls = sorted(all_target_urls)

    # Path 層級規則（TLS Inspection 啟用時使用）
    path_rule = FirewallRule(
        name=f"mirror-to-{package_slug}-https",
        target_urls=sorted_urls,
        source_addresses=source_addresses,
        description=f"winget 套件 {manifest.package_id} v{manifest.version} 下載所需路徑（TLS Inspection）",
        package_id=manifest.package_id,
        confidence=Confidence.HIGH,
    )

    # FQDN 層級規則（備用方案）
    fqdn_rule = FirewallRule(
        name=f"mirror-to-{package_slug}-https",
        target_fqdns=sorted_fqdns,
        source_addresses=source_addresses,
        description=f"winget 套件 {manifest.package_id} v{manifest.version} 下載所需網域（FQDN 層級）",
        package_id=manifest.package_id,
        confidence=Confidence.HIGH,
    )

    return path_rule, fqdn_rule


def generate_base_infrastructure_rule(
    base_fqdns: list[dict[str, str]],
    source_addresses: list[str],
    source_ip_groups: list[str] | None = None,
) -> FirewallRule:
    """產生 winget 基礎設施的通用防火牆規則（所有套件共用）。"""
    fqdns = [entry["fqdn"] for entry in base_fqdns]
    descriptions = [f"{e['fqdn']} — {e.get('description', '')}" for e in base_fqdns]

    return FirewallRule(
        name="mirror-to-winget-infra-https",
        target_fqdns=sorted(fqdns),
        source_addresses=source_addresses,
        source_ip_groups=source_ip_groups or [],
        description="winget 基礎設施端點（所有套件共用）：" + "；".join(descriptions),
        package_id="*",
        confidence=Confidence.HIGH,
    )
