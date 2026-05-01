# winget Azure Firewall Policy 規則清單

> 此文件由 `main.py` 自動產生，記錄每個 winget 套件所需的防火牆放行規則。
> 可作為維護與審閱的依據，建議納入版本控制。

## ⚙️ Azure Firewall Policy 部署資訊

| 參數 | 值 |
|---|---|
| Rule Collection Group | `winget-rules` |
| Rule Collection | `winget-download` |
| Priority | `500` |
| Source Addresses | `10.0.0.0/8` |
| 規則總數 | 7 |
| 分析時間 | 2026-05-01 10:31:21 UTC+08:00 |

**快速部署參考**：

```bash
# 套用所有規則（JSON 格式）
python main.py Git.Git GitHub.cli Microsoft.VisualStudioCode -f json > rules.json

# 產生 Azure CLI 部署指令
python main.py Git.Git GitHub.cli Microsoft.VisualStudioCode -f cli > deploy.sh
```

---

## 📋 套件摘要

| 套件識別碼 | 版本 | 安裝檔數 | 涉及 FQDN | 規則名稱（Path） | 規則名稱（FQDN） |
|---|---|---|---|---|---|
| `Git.Git` | 2.54.0 | 2 | 2 | `winget-git-git-path` | `winget-git-git-fqdn` |
| `GitHub.cli` | 2.92.0 | 6 | 2 | `winget-github-cli-path` | `winget-github-cli-fqdn` |
| `Microsoft.VisualStudioCode` | 1.118.1 | 4 | 1 | `winget-microsoft-visualstudiocode-path` | `winget-microsoft-visualstudiocode-fqdn` |

---

## 🌐 FQDN 彙總表（跨套件）

以下列出所有需要在 Azure Firewall Policy 中放行的 FQDN：

| FQDN | 用途分類 | 信心等級 | 最終目標 | 涉及套件 |
|---|---|---|---|---|
| `cdn.winget.microsoft.com` | winget-source | high | — | `*（所有套件共用）` |
| `github.com` | download | medium | — | `Git.Git`, `GitHub.cli` |
| `objects.githubusercontent.com` | cdn | high | ✅ | `Git.Git`, `GitHub.cli` |
| `vscode.download.prss.microsoft.com` | unknown | high | ✅ | `Microsoft.VisualStudioCode` |
| `winget.azureedge.net` | winget-source | high | — | `*（所有套件共用）` |

---

## 🏗️ winget 基礎設施（所有套件共用）

| FQDN | 用途 |
|---|---|
| `cdn.winget.microsoft.com` | winget 套件來源索引與 manifest |
| `winget.azureedge.net` | winget 套件來源 CDN |

---

## 📦 Git.Git

- **版本**: 2.54.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/git-for-windows/git/releases/download/*/Git-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/23216272/*` |

**安裝檔 2** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/git-for-windows/git/releases/download/*/Git-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/23216272/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-git-git-path`

```
targetUrls:
  - github.com/git-for-windows/git/releases/download/*/Git-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/23216272/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-git-git-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 GitHub.cli

- **版本**: 2.92.0
- **安裝檔數量**: 6

### 下載路徑分析

**安裝檔 1** — `x86` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

**安裝檔 3** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

**安裝檔 4** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

**安裝檔 5** — `arm64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

**安裝檔 6** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/cli/cli/releases/download/*/gh_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-github-cli-path`

```
targetUrls:
  - github.com/cli/cli/releases/download/*/gh_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-github-cli-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.VisualStudioCode

- **版本**: 1.118.1
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `arm64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `vscode.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*` |

**安裝檔 2** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `vscode.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*` |

**安裝檔 3** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `vscode.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*` |

**安裝檔 4** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `vscode.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudiocode-path`

```
targetUrls:
  - vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*
  - vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*
  - vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*
  - vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudiocode-fqdn`

```
targetFqdns:
  - vscode.download.prss.microsoft.com
```

---

## 🔄 規則維護追蹤

| 套件識別碼 | 分析版本 | 分析日期 | 狀態 |
|---|---|---|---|
| `Git.Git` | 2.54.0 | 2026-05-01 10:31:21 UTC+08:00 | ✅ 已分析 |
| `GitHub.cli` | 2.92.0 | 2026-05-01 10:31:21 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudioCode` | 1.118.1 | 2026-05-01 10:31:21 UTC+08:00 | ✅ 已分析 |

### 維護建議

- 建議定期重新執行分析，確認套件版本更新後下載路徑是否變更
- 若有新版本發佈，重新產生規則並比對差異：
  ```bash
  python main.py Git.Git GitHub.cli Microsoft.VisualStudioCode -f md > firewall-rules-new.md
  diff firewall-rules.md firewall-rules-new.md
  ```
- 版本號已正規化為萬用字元 `*`，多數情況下版本更新不需修改規則
- 若安裝檔的下載來源（FQDN）變更，則需更新防火牆規則

