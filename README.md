# winget Azure Firewall Policy 分析工具

分析 winget 套件的下載路徑，自動產生 Azure Firewall Policy Application Rule 建議，確保企業環境中 winget 可正常運作。

## 這個工具解決什麼問題？

企業透過 Azure Firewall 控管出站流量時，需要知道 winget 安裝每個套件時會存取哪些網域。手動測試數百個套件不切實際，這個工具自動化完成：

1. 查詢 winget 套件的安裝檔下載 URL
2. 追蹤每個 URL 的 HTTP 重導向鏈（github.com → CDN → 最終下載位置）
3. 產出精確到 **URL path 層級**的 Azure Firewall 規則（需啟用 TLS Inspection）
4. 同時提供 FQDN 層級規則作為備用

---

## 👤 給套件維護人員

### 快速開始

```bash
# 1. 設定環境（首次）
python3.14 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2. 一鍵分析（自動探索 config.yaml 中所有允許的套件）
python main.py
```

- 未指定套件時，自動使用 `--all` 模式依 `config.yaml` 探索
- 自動偵測 `gh auth token` 取得 GITHUB_TOKEN（無需手動設定）
- 結果自動寫入 `generated/` 資料夾

執行後會產生：
- **generated/firewall-rules.md** — 防火牆規則維護清單（Markdown）
- **generated/diff-report.md** — 與前次分析的變更對比報告
- **generated/deploy.sh** — Azure CLI 部署腳本
- **generated/download.sh** — Bash 一鍵下載腳本（使用 curl）
- **generated/download.ps1** — PowerShell 一鍵下載腳本（使用 Invoke-WebRequest）

### 日常維護流程

#### 分析特定套件

```bash
python main.py Microsoft.PowerToys
python main.py Microsoft.Git GitHub.cli Microsoft.VisualStudioCode
```

#### 批次分析所有允許的套件

```bash
# 先確認會分析哪些套件（dry-run）
python main.py --dry-run

# 正式分析（⚠️ 約 300 個套件，需要數分鐘）
python main.py
```

#### 不同輸出格式

```bash
# Markdown 維護清單（預設）
python main.py Microsoft.Git -f md

# JSON（ARM Template 相容，可直接部署）
python main.py Microsoft.Git -f json

# CSV（匯入試算表審閱）
python main.py Microsoft.Git -f csv

# Azure CLI 部署腳本
python main.py Microsoft.Git -f cli
```

所有格式皆自動寫入 `generated/` 資料夾（`firewall-rules.md`、`rules.json`、`rules.csv`、`deploy.sh`）。

#### 不需要下載腳本時

```bash
python main.py Microsoft.Git --no-download-scripts
```

### 管理允許/封鎖清單

編輯 `config.yaml` 即可：

```yaml
# 允許清單 — 定義要分析的套件範圍
allowlist:
  packages:
    - "Microsoft.*"
    - "GitHub.*"

# 封鎖清單 — 排除不需要的套件（優先於允許清單）
blocklist:
  packages:
    - "Microsoft.*.Preview"      # Preview 版本
    - "Microsoft.*.Beta"         # Beta 版本
    - "Microsoft.VisualStudio.*.Community"  # VS Community
```

修改後重新執行 `--all --dry-run` 確認結果。

### 套件清單與資安報告

`packages-list.md` 包含：
- **分類摘要** — 16 個分類，每個分類的套件數量
- **資安風險評估** — 🔴 高 / 🟡 中 / 🟢 低風險標注
- **紅隊工具對照** — MITRE ATT&CK 戰術對應
- **存取控制建議** — 四級分級（IT 管理員 / 開發人員 / 需審批 / 一般使用者）

### GITHUB_TOKEN

`--all` 模式需要大量 GitHub API 呼叫（約 400+ 次），未認證配額僅 60 次/小時。

程式會自動透過 `gh auth token` 取得認證，前提是已執行過 `gh auth login`。也可手動設定：

```bash
# 手動設定環境變數（覆蓋自動偵測）
export GITHUB_TOKEN="ghp_你的token"
python main.py
```

---

## 🛠️ 給開發人員

### 專案結構

```
├── main.py                        # CLI 入口
├── config.yaml                    # 允許/封鎖清單與防火牆設定
├── requirements.txt               # Python 依賴
├── pyproject.toml                 # pytest 設定
├── packages-list.md               # 套件分類與資安報告
├── generated/                     # 程式產出檔案（稽核留存）
│   ├── firewall-rules.md          # 防火牆規則維護清單
│   ├── diff-report.md             # 與前次分析的變更對比報告
│   ├── deploy.sh                  # Azure CLI 部署腳本
│   ├── download.sh                # Bash 一鍵下載腳本
│   └── download.ps1               # PowerShell 一鍵下載腳本
├── audit_logs/                    # 稽核日誌
├── src/
│   ├── models.py                  # 資料模型（RedirectHop, FirewallRule 等）
│   ├── winget_api.py              # GitHub API 查詢 winget-pkgs manifest
│   ├── redirect_tracer.py         # HTTP 重導向鏈追蹤（HEAD 優先，GET fallback）
│   ├── rule_generator.py          # Azure Firewall 規則產生器
│   ├── formatters.py              # 輸出格式化（JSON/CSV/CLI/Markdown）
│   ├── download_scripts.py        # 下載腳本產生器（Bash/PowerShell）
│   ├── package_discovery.py       # 遞迴掃描 winget-pkgs 探索套件
│   └── blocklist.py               # 允許/封鎖清單 fnmatch 過濾
└── tests/
    ├── test_models.py
    ├── test_winget_api.py
    ├── test_redirect_tracer.py
    ├── test_rule_generator.py
    ├── test_formatters.py
    ├── test_download_scripts.py
    ├── test_blocklist.py
    ├── test_package_discovery.py
    └── test_integration.py        # 整合測試（需網路）
```

### 開發環境設定

```bash
python3.14 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 執行測試

```bash
# 單元測試（120 個，不需網路）
python -m pytest tests/ --ignore=tests/test_integration.py -v

# 整合測試（需網路，測試 Microsoft.Git / GitHub.cli / GitHub.GitHubDesktop）
python -m pytest tests/test_integration.py -v

# 執行單一測試
python -m pytest tests/test_blocklist.py::TestIsBlocked::test_edge_beta_blocked -v
```

### 核心流程

```
使用者輸入套件 ID
    │
    ▼
winget_api.py ── GitHub API 查詢 winget-pkgs 倉庫
    │              └─ manifests/{letter}/{Publisher}/{Name}/{version}/
    │                  └─ *.installer.yaml → InstallerUrl
    ▼
redirect_tracer.py ── HEAD 請求逐跳追蹤重導向鏈
    │                   └─ github.com → 302 → release-assets.githubusercontent.com → 200
    ▼
rule_generator.py ── 收集所有 FQDN，產生規則
    │                  ├─ targetUrls（path 層級，TLS Inspection）
    │                  └─ targetFqdns（FQDN 層級，備用）
    ▼
formatters.py ── 輸出 JSON / CSV / CLI / Markdown
```

### 關鍵設計決策

- **資料來源**：GitHub API 查詢 `microsoft/winget-pkgs`，非 winget REST API（社群套件不在 storeedgefd 端點）
- **重導向追蹤**：HEAD 優先，403/405 時 fallback 到 GET + `Range: bytes=0-0`，避免下載完整檔案
- **版本萬用字元**：URL path 中的版本號與 UUID 自動替換為 `*`，版本更新時不需修改規則
- **Query string 移除**：`targetUrls` 不包含 query string（簽章參數會過期）
- **Leaf 套件判斷**：子目錄名稱符合 `x.y` 格式才視為版本目錄（避免 `2022` 被誤判）

### 新增輸出格式

在 `src/formatters.py` 新增函式，然後在 `main.py` 的 format 分支加入即可。

### 新增封鎖規則

編輯 `config.yaml` 的 `blocklist.packages`，支援 `fnmatch` 萬用字元：
- `Microsoft.*.Beta` — 匹配所有 Beta 版
- `Microsoft.VisualStudio.*.Community` — 匹配所有年份的 VS Community

---

## 授權

內部工具，僅供企業內部使用。
