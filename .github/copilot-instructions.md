# Copilot Instructions — mitm-firewall-policy

## 語言規範

- 所有程式碼註解、commit message、文件、CLI 輸出訊息一律使用**繁體中文**
- 變數名稱與函式名稱使用英文（snake_case）

## 變更後必做事項

- **每次修改程式碼或行為後，必須同步更新 `README.md`**，確保文件與實際行為一致
- 涉及 CLI 參數、輸出路徑、預設行為、環境需求等變更時尤其重要

## 專案概述

此工具針對 **winget（Windows Package Manager）** 的套件下載流程，
透過 **winget REST API 查詢 + HTTP 重導向追蹤** 的方式，
在 macOS 上分析 winget 安裝特定套件時實際會存取的所有 FQDN，
產生精確的 Azure Firewall Policy Application Rule 清單。
目標是達到最小開放原則（least-privilege），僅放行 winget 運作所需的網域。

### 使用情境

企業環境中透過 Azure Firewall 控管出站流量，需要精確得知 winget 在下載特定套件時會存取哪些網域（CDN、API、驗證端點等），以便建立最小權限的防火牆規則。

### 使用方式

使用者輸入套件識別碼（不區分大小寫），程式自動完成完整分析：

```bash
# 分析單一套件
python main.py Microsoft.Git

# 分析多個套件
python main.py GitHub.cli GitHub.GitHubDesktop

# 分析篩選範圍內的所有套件（依設定檔）
python main.py --all
```

### 測試用套件

開發與驗證時使用以下三個套件作為測試標的，涵蓋不同下載來源類型：

| 套件識別碼 | 預期下載來源 |
|---|---|
| `Microsoft.Git` | GitHub Release（多次重導向） |
| `GitHub.cli` | GitHub Release |
| `GitHub.GitHubDesktop` | GitHub Release / Squirrel 更新機制 |

測試時應確認這三個套件皆能正確產出 path 層級的 Azure Firewall Policy 規則。

輸入 `Microsoft.Git` 時，程式應：

1. 查詢 winget REST API 取得 `Microsoft.Git` 的所有版本 manifest
2. 取出最新版的 `InstallerUrl`（例如 `https://github.com/microsoft/git/releases/download/v2.48.0.vfs.0.0/Git-2.48.0.vfs.0.0-64-bit.exe`）
3. 追蹤該 URL 的完整重導向鏈，記錄每一跳的 FQDN + 完整 URL path
4. 產出該套件所需的 Azure Firewall Policy Application Rule 建議

### 分析範圍（篩選條件）

分析對象以下列 publisher 與套件識別碼為主，兩者為**聯集關係（OR）**——符合任一條件即納入分析：

```yaml
# 依發行者過濾（匹配 manifest 中的 Publisher 欄位）
publishers:
  - "Microsoft"
  - "Microsoft Corporation"
  - "GitHub, Inc."

# 依套件識別碼過濾（匹配 PackageIdentifier 欄位）
# 支援萬用字元模式，例如 "Microsoft.*" 匹配所有 Microsoft 開頭的套件
packages:
  - "Microsoft.*"
  - "GitHub.*"
```

- 上述範圍為**主要分析目標**，程式應優先處理這些套件
- 篩選設定應以設定檔（YAML）管理，方便使用者自行擴充或調整
- 其他不在範圍內的套件可作為輔助分析，但非預設行為

### 分析策略（macOS 離線分析，不需要 Windows 或 winget）

由於開發環境為 macOS，無法直接執行 winget，因此採用 **純 HTTP 分析** 方式：

1. 呼叫 winget REST API（`https://storeedgefd.dsx.mp.microsoft.com/v9.0` 或 `https://cdn.winget.microsoft.com/cache`）查詢套件 manifest
2. 從 manifest 中取得 installer 的下載 URL（`InstallerUrl`）
3. 使用 HTTP HEAD 請求追蹤該 URL 的所有 301/302 重導向鏈，記錄每一跳的 FQDN
4. 彙整所有涉及的 FQDN（API 端點 + CDN + 最終下載位置）
5. 將 FQDN 分類（winget API、CDN 下載、GitHub Release、Microsoft Store 等）
6. 依據 Azure Firewall Policy Application Rule 格式產出建議規則
7. 輸出結果（JSON / CSV / Azure CLI 指令）

### winget REST API 端點

```text
# 套件搜尋
POST https://storeedgefd.dsx.mp.microsoft.com/v9.0/manifestSearch

# 套件 manifest 查詢（較新的 CDN 端點）
GET  https://cdn.winget.microsoft.com/cache/{packageId}/versions/{version}
```

### winget 常見關聯網域

分析時須留意 winget 常見的後端服務網域，包含但不限於：

- `cdn.winget.microsoft.com` — winget 套件來源 REST API / manifest 快取
- `winget.azureedge.net` — 套件 manifest CDN
- `github.com` / `objects.githubusercontent.com` — 從 GitHub Release 下載安裝檔
- `*.dl.delivery.mp.microsoft.com` — Microsoft Store 下載端點
- `storeedgefd.dsx.mp.microsoft.com` — Store 前端服務 / manifest 搜尋 API
- `login.microsoftonline.com` — 若涉及 Microsoft 帳號驗證

產出規則時應標註每個 FQDN 的用途分類，方便管理者判斷是否需要開放。

### 重導向追蹤要點

- 許多 installer URL 會經過多次 302 重導向（例如 GitHub → objects.githubusercontent.com → *.s3.amazonaws.com）
- 追蹤時使用 `allow_redirects=False` 逐跳分析，記錄完整重導向鏈
- 每一跳須記錄 **完整 URL**（含 path + query string），不僅是 FQDN，以便產出 path 層級規則
- 最終下載 FQDN 才是實際需要開放的目標，中繼跳板也須記錄
- URL path 中的版本號應辨識並標記，方便後續替換為萬用字元

## 技術棧

- **Python 3.14**，使用 `venv` 管理虛擬環境
- **httpx** 或 **requests** — 呼叫 winget REST API 與追蹤 HTTP 重導向鏈
- 開發環境為 **macOS**，不依賴 Windows 或 winget 執行檔
- 不使用 Docker，直接在本機執行

## 環境設定

```bash
python3.14 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 程式碼慣例

- 型別標註：所有函式簽章必須包含 type hints
- 輸出格式相關的程式碼集中在獨立模組，與分析邏輯分離
- HTTP 重導向追蹤邏輯與 winget API 查詢邏輯分開為獨立模組
- Azure Firewall Policy 規則結構使用 dataclass 或 Pydantic model 定義

## Azure Firewall Policy 規則格式

企業環境已啟用 **Azure Firewall TLS Inspection**，因此可以將規則精確到 **URL path 等級**，不需僅停留在 FQDN 層級。

### FQDN 層級規則（無 TLS Inspection 時的備用方案）

```json
{
  "name": "winget-git-fqdn",
  "ruleType": "ApplicationRule",
  "protocols": [{"protocolType": "Https", "port": 443}],
  "targetFqdns": ["github.com", "objects.githubusercontent.com"],
  "sourceAddresses": ["10.0.0.0/8"]
}
```

### URL Path 層級規則（啟用 TLS Inspection，建議使用）

```json
{
  "name": "winget-git-path",
  "ruleType": "ApplicationRule",
  "protocols": [{"protocolType": "Https", "port": 443}],
  "targetUrls": [
    "github.com/git-for-windows/git/releases/download/*",
    "objects.githubusercontent.com/github-production-release-asset-*/*"
  ],
  "sourceAddresses": ["10.0.0.0/8"]
}
```

### 規則產出要求

- **預設產出 path 層級規則**（`targetUrls`），同時附帶 FQDN 層級（`targetFqdns`）作為備用
- 每個規則須標註對應的套件識別碼（如 `Microsoft.Git`）與用途分類
- `targetUrls` 中的版本號部分應替換為萬用字元 `*`，以便版本更新時無需修改規則
- `sourceAddresses` 預設為設定檔中的值，不寫死
- 規則命名格式：`winget-{package-id}-{用途}`（如 `winget-microsoft.git-download`）

### 部署腳本行為要求

產出的 deploy 腳本（`deploy-tls_*.sh` / `deploy-fqdn_*.sh`）必須滿足以下要求：

- **全程使用 Draft 模式**：所有規則操作（建立 RCG、Rule Collection、新增/更新規則）皆透過 Azure Firewall Policy Draft API 執行，不直接套用至正式環境。最終需人工在 Azure Portal 確認後執行 `draft deploy` 才生效
- **冪等（Idempotent）**：腳本可安全重複執行
  - 已存在且內容相同的規則 → **跳過**（不重複操作）
  - 已存在但內容不同的規則 → **以當前最新版本覆蓋**（先移除舊規則再新增新規則）
  - 不存在的規則 → **新增**
- **RCG / Rule Collection 也須冪等**：若已存在則跳過建立，不因重複執行而報錯
- **RCG 與 RC 名稱統一**：不論 TLS 或 FQDN 模式，使用相同的 `rule_collection_group_name` 與 `rule_collection_name`（來自 `config.yaml`），確保 Azure Firewall Policy 中僅有一組 RCG + RC 可供維護，避免產生多組規則集合
- **部署摘要**：執行結束時顯示新增、更新、跳過、失敗的規則數量
- **前置檢查**：腳本開頭依序執行以下檢查：
  1. `az config set extension.dynamic_install_allow_preview=true` — 啟用擴充功能自動安裝（含 preview）
  2. 確認 `jq` 已安裝
  3. 確認 `az login` 已完成
  4. 確認 Azure 訂閱 ID 與 `config.yaml` 中的 `firewall.subscription_id` 一致（若有設定）
  5. 確認 Firewall Policy 存在

### 輸出格式

程式應支援多種輸出格式：

- **JSON** — 可直接用於 ARM Template / Bicep 部署
- **CSV** — 方便人工審閱與匯入試算表
- **Azure CLI** — 可直接執行的 `az network firewall policy rule-collection-group` 指令（冪等 + Draft 模式）
