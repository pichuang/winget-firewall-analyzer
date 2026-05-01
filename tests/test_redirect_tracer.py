"""測試 — HTTP 重導向追蹤（使用 mock）"""

from __future__ import annotations

from unittest.mock import AsyncMock, patch

import httpx
import pytest

from src.redirect_tracer import trace_redirects


def _make_response(status: int, location: str | None = None) -> httpx.Response:
    """建立模擬的 httpx.Response。"""
    headers = {}
    if location:
        headers["location"] = location
    return httpx.Response(
        status,
        headers=headers,
        request=httpx.Request("HEAD", "https://example.com"),
    )


class TestTraceRedirects:
    """測試重導向鏈追蹤"""

    @pytest.mark.asyncio
    async def test_single_redirect(self) -> None:
        """測試單一重導向（GitHub Release 典型情境）"""
        client = AsyncMock(spec=httpx.AsyncClient)
        client.head = AsyncMock(side_effect=[
            _make_response(302, "https://release-assets.githubusercontent.com/asset-123"),
            _make_response(200),
        ])

        hops = await trace_redirects(client, "https://github.com/repo/releases/download/v1.0/app.exe")

        assert len(hops) == 2
        assert hops[0].fqdn == "github.com"
        assert hops[0].status_code == 302
        assert hops[0].is_final is False
        assert hops[1].fqdn == "release-assets.githubusercontent.com"
        assert hops[1].status_code == 200
        assert hops[1].is_final is True

    @pytest.mark.asyncio
    async def test_multiple_redirects(self) -> None:
        """測試多次重導向鏈"""
        client = AsyncMock(spec=httpx.AsyncClient)
        client.head = AsyncMock(side_effect=[
            _make_response(302, "https://cdn1.example.com/step1"),
            _make_response(301, "https://cdn2.example.com/step2"),
            _make_response(200),
        ])

        hops = await trace_redirects(client, "https://origin.example.com/download")

        assert len(hops) == 3
        assert hops[0].fqdn == "origin.example.com"
        assert hops[1].fqdn == "cdn1.example.com"
        assert hops[2].fqdn == "cdn2.example.com"
        assert hops[2].is_final is True

    @pytest.mark.asyncio
    async def test_no_redirect(self) -> None:
        """測試無重導向（直接下載）"""
        client = AsyncMock(spec=httpx.AsyncClient)
        client.head = AsyncMock(return_value=_make_response(200))

        hops = await trace_redirects(client, "https://direct.example.com/file.exe")

        assert len(hops) == 1
        assert hops[0].is_final is True
        assert hops[0].fqdn == "direct.example.com"

    @pytest.mark.asyncio
    async def test_head_fallback_to_get(self) -> None:
        """測試 HEAD 被拒絕時 fallback 到 GET"""
        client = AsyncMock(spec=httpx.AsyncClient)
        # HEAD 回 405，fallback 到 GET
        client.head = AsyncMock(return_value=_make_response(405))
        client.get = AsyncMock(return_value=_make_response(200))

        hops = await trace_redirects(client, "https://strict-server.example.com/file.exe")

        assert len(hops) == 1
        assert hops[0].is_final is True

    @pytest.mark.asyncio
    async def test_max_hops_limit(self) -> None:
        """測試最大跳數限制"""
        client = AsyncMock(spec=httpx.AsyncClient)
        # 無限重導向
        client.head = AsyncMock(
            return_value=_make_response(302, "https://loop.example.com/next")
        )

        hops = await trace_redirects(client, "https://loop.example.com/start", max_hops=5)

        assert len(hops) == 5

    @pytest.mark.asyncio
    async def test_head_exception_fallback(self) -> None:
        """測試 HEAD 發生例外時 fallback 到 GET"""
        client = AsyncMock(spec=httpx.AsyncClient)
        client.head = AsyncMock(side_effect=httpx.ConnectError("連線失敗"))
        client.get = AsyncMock(return_value=_make_response(200))

        hops = await trace_redirects(client, "https://flaky.example.com/file.exe")

        assert len(hops) == 1
        assert hops[0].is_final is True

    @pytest.mark.asyncio
    async def test_relative_location(self) -> None:
        """測試相對路徑的 Location header"""
        client = AsyncMock(spec=httpx.AsyncClient)
        client.head = AsyncMock(side_effect=[
            _make_response(302, "/new-path/file.exe"),
            _make_response(200),
        ])

        hops = await trace_redirects(client, "https://example.com/old-path/file.exe")

        assert len(hops) == 2
        # 相對路徑應解析為同一 host
        assert hops[1].fqdn == "example.com"
        assert "/new-path/file.exe" in hops[1].url
