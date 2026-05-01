"""HTTP 重導向鏈追蹤器 — 逐跳追蹤 URL 的所有 301/302 重導向"""

from __future__ import annotations

from urllib.parse import urljoin

import httpx

from src.models import RedirectHop

MAX_REDIRECTS = 15
REDIRECT_STATUS_CODES = {301, 302, 303, 307, 308}


async def trace_redirects(
    client: httpx.AsyncClient,
    url: str,
    max_hops: int = MAX_REDIRECTS,
) -> list[RedirectHop]:
    """追蹤 URL 的完整重導向鏈，記錄每一跳的 FQDN 與完整 URL。

    策略：
    1. 優先使用 HEAD 請求（避免下載完整檔案）
    2. 若 HEAD 失敗（403/405），改用 GET + Range header
    3. 記錄每一跳的完整 URL（含 path），供 path 層級規則使用
    """
    hops: list[RedirectHop] = []
    current_url = url

    for _ in range(max_hops):
        status_code, location = await _probe_url(client, current_url)

        is_redirect = status_code in REDIRECT_STATUS_CODES and location is not None
        is_final = not is_redirect

        hops.append(RedirectHop.from_url(
            url=current_url,
            status_code=status_code,
            is_final=is_final,
        ))

        if is_final:
            break

        # 處理相對路徑的 Location
        current_url = urljoin(current_url, location)  # type: ignore[arg-type]

    return hops


async def _probe_url(
    client: httpx.AsyncClient,
    url: str,
) -> tuple[int, str | None]:
    """探測 URL，回傳 (status_code, location_header)。

    優先 HEAD，失敗時 fallback 到 GET + Range。
    """
    try:
        resp = await client.head(
            url,
            follow_redirects=False,
            timeout=15.0,
        )
        location = resp.headers.get("location")

        # HEAD 被拒絕時 fallback
        if resp.status_code in {403, 405, 501}:
            return await _probe_with_get(client, url)

        return resp.status_code, location

    except httpx.HTTPError:
        return await _probe_with_get(client, url)


async def _probe_with_get(
    client: httpx.AsyncClient,
    url: str,
) -> tuple[int, str | None]:
    """使用 GET + Range header 作為 HEAD 的替代方案。"""
    try:
        resp = await client.get(
            url,
            follow_redirects=False,
            headers={"Range": "bytes=0-0"},
            timeout=15.0,
        )
        return resp.status_code, resp.headers.get("location")
    except httpx.HTTPError:
        return 0, None
