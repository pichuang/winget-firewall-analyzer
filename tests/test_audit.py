"""測試 — 稽核日誌與變更對比報告"""

from __future__ import annotations

import json
import tempfile
from pathlib import Path

from src.audit import generate_diff_report
from src.models import InstallerInfo, PackageManifest, RedirectHop


def _make_manifest(
    package_id: str,
    version: str,
    urls: list[str] | None = None,
    fqdns: list[list[str]] | None = None,
) -> PackageManifest:
    """建立測試用 manifest。"""
    if urls is None:
        urls = [f"https://example.com/{package_id}/{version}/setup.exe"]
    if fqdns is None:
        fqdns = [["example.com"]] * len(urls)

    installers = []
    for url, fqdn_list in zip(urls, fqdns):
        chain = [RedirectHop(url=f"https://{f}/path", fqdn=f, path="/path", status_code=302) for f in fqdn_list]
        installers.append(InstallerInfo(url=url, architecture="x64", redirect_chain=chain))
    return PackageManifest(
        package_id=package_id,
        version=version,
        publisher="Test",
        installers=installers,
    )


def _write_prev_log(manifests: list[PackageManifest], tmp_dir: Path) -> Path:
    """寫入模擬的前次稽核日誌 JSON。"""
    packages = []
    for m in manifests:
        installers = []
        for inst in m.installers:
            installers.append({
                "url": inst.url,
                "architecture": inst.architecture,
                "redirect_chain_fqdns": [h.fqdn for h in inst.redirect_chain],
            })
        packages.append({
            "package_id": m.package_id,
            "version": m.version,
            "publisher": m.publisher,
            "installers": installers,
        })

    data = {
        "timestamp": "2026-04-30 10:00:00 UTC+08:00",
        "summary": {"total_packages_analyzed": len(manifests)},
        "packages": packages,
    }
    log_path = tmp_dir / "audit_prev.json"
    log_path.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    return log_path


class TestGenerateDiffReport:
    """測試變更對比報告"""

    def test_no_previous_log(self) -> None:
        """無前次紀錄時應顯示所有套件為新增"""
        manifests = [_make_manifest("Microsoft.Git", "2.48.0")]
        report = generate_diff_report(manifests, previous_log=None)

        assert "變更對比報告" in report
        assert "新增套件" in report
        assert "`Microsoft.Git`" in report

    def test_no_changes(self) -> None:
        """完全一致時應顯示無變更"""
        manifests = [_make_manifest("Microsoft.Git", "2.48.0")]
        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(manifests, Path(tmp))
            report = generate_diff_report(manifests, previous_log=prev)

        assert "完全一致" in report

    def test_version_update(self) -> None:
        """版本更新應顯示舊版本與新版本"""
        old = [_make_manifest("Microsoft.Git", "2.47.0")]
        new = [_make_manifest("Microsoft.Git", "2.48.0")]

        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(old, Path(tmp))
            report = generate_diff_report(new, previous_log=prev)

        assert "版本更新" in report
        assert "2.47.0" in report
        assert "2.48.0" in report

    def test_new_package(self) -> None:
        """新增套件應出現在新增區塊"""
        old = [_make_manifest("Microsoft.Git", "2.48.0")]
        new = [
            _make_manifest("Microsoft.Git", "2.48.0"),
            _make_manifest("GitHub.cli", "2.92.0"),
        ]

        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(old, Path(tmp))
            report = generate_diff_report(new, previous_log=prev)

        assert "新增套件" in report
        assert "`GitHub.cli`" in report

    def test_removed_package(self) -> None:
        """移除套件應出現在移除區塊"""
        old = [
            _make_manifest("Microsoft.Git", "2.48.0"),
            _make_manifest("GitHub.cli", "2.92.0"),
        ]
        new = [_make_manifest("Microsoft.Git", "2.48.0")]

        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(old, Path(tmp))
            report = generate_diff_report(new, previous_log=prev)

        assert "移除套件" in report
        assert "`GitHub.cli`" in report

    def test_fqdn_changes(self) -> None:
        """FQDN 變更應顯示新增與移除的網域"""
        old = [_make_manifest("Microsoft.Git", "2.47.0", fqdns=[["github.com", "old-cdn.example.com"]])]
        new = [_make_manifest("Microsoft.Git", "2.48.0", fqdns=[["github.com", "new-cdn.example.com"]])]

        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(old, Path(tmp))
            report = generate_diff_report(new, previous_log=prev)

        assert "FQDN 變更" in report
        assert "`new-cdn.example.com`" in report
        assert "`old-cdn.example.com`" in report

    def test_firewall_impact(self) -> None:
        """有新 FQDN 時應顯示防火牆規則影響"""
        old = [_make_manifest("Microsoft.Git", "2.47.0", fqdns=[["github.com"]])]
        new = [_make_manifest("Microsoft.Git", "2.48.0", fqdns=[["github.com", "new-cdn.example.com"]])]

        with tempfile.TemporaryDirectory() as tmp:
            prev = _write_prev_log(old, Path(tmp))
            report = generate_diff_report(new, previous_log=prev)

        assert "防火牆規則影響" in report
        assert "需新增" in report
        assert "`new-cdn.example.com`" in report
