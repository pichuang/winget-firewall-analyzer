# winget 防火牆規則分析工具 — 維護作業標準程序 (SOP)

> 本文件供**套件維護人員**日常操作使用，涵蓋定期分析、設定調整、異常處理等流程。

---

## 目錄

1. [環境準備](#1-環境準備)
2. [定期分析作業（建議每週執行）](#2-定期分析作業建議每週執行)
3. [新增或移除套件](#3-新增或移除套件)
4. [新增或移除 WSL 發行版](#4-新增或移除-wsl-發行版)
5. [審閱變更對比報告](#5-審閱變更對比報告)
6. [部署防火牆規則至 Azure](#6-部署防火牆規則至-azure)
7. [封鎖清單維護](#7-封鎖清單維護)
8. [GITHUB_TOKEN 管理](#8-github_token-管理)
9. [稽核日誌管理](#9-稽核日誌管理)
10. [異常處理與疑難排解](#10-異常處理與疑難排解)
11. [附錄：關鍵檔案對照表](#附錄關鍵檔案對照表)

---

## 1. 環境準備

### 首次設定

```bash
# 1. 建立 Python 虛擬環境
python3.14 -m venv .venv
source .venv/bin/activate

# 2. 安裝依賴
pip install -r requirements.txt

# 3. 確認 GitHub CLI 已登入（用於自動取得 GITHUB_TOKEN）
gh auth login
gh auth status   # 確認狀態為 Logged in
```

### 每次操作前確認

```bash
# 啟動虛擬環境
source .venv/bin/activate

# 確認 gh auth 有效
gh auth status
```

> ⚠️ `--all` 模式約需 400+ 次 GitHub API 呼叫，未認證配額僅 60 次/小時，務必確認 `gh auth` 有效。

---

## 2. 定期分析作業（建議每週執行）

### 步驟一：Dry-Run 預覽

先確認即將分析的套件清單，不實際呼叫 API：

```bash
python main.py --dry-run
```

- 檢查套件數量是否合理（目前約 280 個）
- 確認沒有意外包含不需要的套件

### 步驟二：執行完整分析

```bash
python main.py
```

- 預設自動分析 `config.yaml` 中所有允許的套件 + WSL 發行版
- 約需 **5–15 分鐘**（視網路與 API 回應速度）
- 執行期間會在 stderr 顯示進度

### 步驟三：確認產出檔案

每次執行會在 `generated/YYYYMMDD_HHMMSS/` 建立獨立資料夾，包含：

| 檔案 | 用途 |
|---|---|
| `firewall-rules_*.md` | 防火牆規則維護清單（主要審閱文件） |
| `diff-report_*.md` | 與前次分析的變更對比報告 |
| `deploy-tls_*.sh` | Azure CLI 部署腳本（TLS Inspection / Path 層級） |
| `deploy-fqdn_*.sh` | Azure CLI 部署腳本（FQDN 層級備用） |
| `download_*.sh` | Bash 下載腳本 |
| `download_*.ps1` | PowerShell 下載腳本 |

### 步驟四：審閱 diff-report

```bash
# 開啟最新的變更報告
open generated/$(ls generated/ | grep -v README | sort | tail -1)/diff-report_*.md
```

重點關注：

- **新增套件** — 確認是否為預期的新套件
- **移除套件** — 確認是否已從 winget-pkgs 移除或被封鎖
- **版本更新** — 版本號是否合理（注意異常跳版）
- **FQDN 變更** — 新增/移除的網域是否合理
- **URL 變更** — 下載路徑是否改變

### 步驟五：提交至版本控制

```bash
git add generated/ audit_logs/
git commit -m "chore: 定期分析更新 $(date +%Y-%m-%d)"
git push
```

---

## 3. 新增或移除套件

### 新增套件至允許清單

1. **編輯 `config.yaml`**，在 `allowlist.packages` 加入套件識別碼：

   ```yaml
   allowlist:
     packages:
       - "Microsoft.*"
       - "GitHub.*"
       - "NewPublisher.NewApp"    # ← 新增
   ```

2. **驗證單一套件**（先測試再全量執行）：

   ```bash
   python main.py NewPublisher.NewApp
   ```

3. **確認產出規則合理**，檢查 `generated/` 下最新的 `firewall-rules_*.md`

4. **執行完整分析**確認無衝突：

   ```bash
   python main.py --dry-run   # 確認套件清單
   python main.py              # 正式分析
   ```

### 將套件加入封鎖清單

參見 [第 7 節：封鎖清單維護](#7-封鎖清單維護)。

---

## 4. 新增或移除 WSL 發行版

### 新增 WSL 發行版

1. **編輯 `config.yaml`**，在 `wsl_distros.distributions` 新增項目：

   ```yaml
   wsl_distros:
     distributions:
       # ...（既有項目）
       - name: "Debian 13 Trixie"
         id: "WSL.Debian-13"
         download_url: "https://aka.ms/wsl-debian-trixie"
         install_cmd: "wsl --install -d Debian"
   ```

2. **測試 WSL 分析**：

   ```bash
   python main.py --wsl
   ```

3. 確認重導向鏈追蹤正常，產出規則包含新增發行版

### 移除已 EOL 的 WSL 發行版

直接從 `config.yaml` 的 `wsl_distros.distributions` 刪除對應項目，重新執行分析即可。

---

## 5. 審閱變更對比報告

`diff-report_*.md` 自動比對前後兩次分析結果，以下為各區塊的審閱要點：

| 區塊 | 審閱要點 |
|---|---|
| **摘要** | 套件總數變化是否合理 |
| **新增套件** | 是否為新上架的合法套件；是否需加入封鎖清單 |
| **移除套件** | 原因為何（下架？改名？被封鎖？） |
| **版本更新** | 版本號是否合理；異常大幅跳版需留意 |
| **FQDN 變更** | 新增網域是否為已知 CDN；移除網域是否仍有其他套件使用 |
| **URL 變更** | 下載路徑變化可能影響 TLS Inspection 規則 |

> 💡 如有 FQDN 大幅變更，建議先在測試環境驗證防火牆規則，再部署至正式環境。

---

## 6. 部署防火牆規則至 Azure

### 前置確認

```bash
# 確認 Azure CLI 已登入且訂閱正確
az account show --query "{name:name, id:id}" -o table
```

### 部署流程

產出的部署腳本預設為 **Draft 模式**（腳本內指令已註解），需手動取消註解再執行：

```bash
# 1. 檢閱部署腳本
cat generated/YYYYMMDD_HHMMSS/deploy-tls_*.sh

# 2. 確認 config.yaml 中的防火牆設定
#    - firewall_policy_name: "afwp-global-01"
#    - resource_group: "rg-vdss-afwp-prd-global"
#    - rule_collection_group_name: "rcg-1100-mirror-winget"

# 3. 在測試環境先行驗證（建議）
# 4. 正式部署（取消腳本內的註解後執行）
bash generated/YYYYMMDD_HHMMSS/deploy-tls_*.sh
```

### TLS Inspection vs FQDN 層級

| 腳本 | 規則精細度 | 條件 |
|---|---|---|
| `deploy-tls_*.sh` | URL Path 層級（`targetUrls`） | 需啟用 Azure Firewall TLS Inspection |
| `deploy-fqdn_*.sh` | FQDN 層級（`targetFqdns`） | 不需 TLS Inspection，較寬鬆 |

> ⚠️ 建議優先使用 TLS Inspection (Path 層級) 規則，最小化開放範圍。

---

## 7. 封鎖清單維護

### 何時需要封鎖套件

- 套件已 **EOL / 停止維護**（如 .NET 6 已於 2024/11 EOL）
- 套件為 **Preview / Beta / Insider** 等非正式版本
- 套件具有 **資安風險**（如 `Microsoft.devtunnel` 可繞過防火牆）
- 套件 **非企業所需**（如遊戲開發工具）
- GitHub 倉庫 **已歸檔**

### 操作步驟

1. **編輯 `config.yaml`** 的 `blocklist.packages`：

   ```yaml
   blocklist:
     packages:
       - "Publisher.DeprecatedApp"    # 原因說明
   ```

2. **支援萬用字元**（`fnmatch` 語法）：

   ```yaml
   - "Microsoft.*.Beta"              # 所有 Beta 版
   - "Microsoft.DotNet.SDK.6"        # .NET 6 SDK（已 EOL）
   - "Microsoft.Gaming.*"            # 所有遊戲相關
   ```

3. **驗證封鎖效果**：

   ```bash
   python main.py --dry-run
   # 確認被封鎖的套件不在清單中
   ```

4. **在封鎖項目旁加入註解**，說明封鎖原因與日期，便於後續維護。

> ⚠️ 封鎖清單 **優先於** 允許清單。即使套件符合 `allowlist` 條件，只要在 `blocklist` 中就會被排除。

---

## 8. GITHUB_TOKEN 管理

### 自動取得（建議）

程式會自動執行 `gh auth token` 取得認證，前提是 `gh auth login` 已完成。

```bash
# 確認 token 有效
gh auth status
```

### 手動設定（備用）

```bash
export GITHUB_TOKEN="ghp_你的token"
python main.py
```

### Token 過期處理

若出現 `403 Forbidden` 或 `401 Unauthorized`：

```bash
# 重新登入 GitHub CLI
gh auth login

# 或重新產生 PAT 並設定
export GITHUB_TOKEN="ghp_新的token"
```

---

## 9. 稽核日誌管理

### 日誌結構

- `audit_logs/audit_YYYYMMDD_HHMMSS.json` — 每次分析的完整結果（JSON）
- `audit_logs/CHANGELOG.md` — 累積式變更記錄，包含版本更新、新增/移除套件

### CHANGELOG 內容

每次執行自動追加記錄，包含：

- 操作人員（主機名稱）
- 分析套件數
- 版本更新清單
- 新增/移除套件

### 建議

- 將 `audit_logs/` 與 `generated/` 納入 **Git 版本控制**
- 定期清理過舊的 `audit_logs/audit_*.json`（例如保留最近 90 天）
- `CHANGELOG.md` 為累積式，不需手動清理

---

## 10. 異常處理與疑難排解

### 常見問題

| 症狀 | 可能原因 | 處理方式 |
|---|---|---|
| `403 rate limit exceeded` | GitHub API 配額用盡 | 確認 `gh auth status` 有效；等待配額重置（1 小時） |
| `401 Bad credentials` | Token 無效或已過期 | `gh auth login` 重新認證 |
| 套件查詢失敗 | 套件已從 winget-pkgs 移除 | 將套件加入封鎖清單 |
| 重導向追蹤逾時 | CDN 端點暫時無回應 | 重試；若持續發生，檢查該 URL 是否已失效 |
| 規則數量異常增減 | config.yaml 被意外修改 | 用 `git diff config.yaml` 檢查變更 |
| WSL 分析失敗 | aka.ms 短網址已變更 | 更新 `config.yaml` 中的 `download_url` |
| `ModuleNotFoundError` | 虛擬環境未啟動 | `source .venv/bin/activate` |
| 產出與前次無 diff | 套件與 FQDN 均無變化 | 正常現象，無需處理 |

### 重新分析特定套件

若某套件分析結果異常，可單獨重新分析：

```bash
python main.py Microsoft.Git -f md
```

### 執行測試確認工具正常

```bash
# 單元測試（不需網路，約 10 秒）
python -m pytest tests/ --ignore=tests/test_integration.py -v

# 整合測試（需網路，測試三個標準套件）
python -m pytest tests/test_integration.py -v
```

---

## 附錄：關鍵檔案對照表

| 檔案 | 用途 | 維護頻率 |
|---|---|---|
| `config.yaml` | 允許/封鎖清單、防火牆設定、WSL 發行版 | 依需求調整 |
| `main.py` | CLI 入口 | 一般不需修改 |
| `generated/` | 程式產出檔案（規則、腳本、報告） | 每次分析自動產出 |
| `audit_logs/` | 稽核日誌 | 自動累積，定期清理 |
| `packages-list.md` | 套件分類與資安報告 | 依需求更新 |
| `requirements.txt` | Python 依賴 | 依賴升級時更新 |
| `README.md` | 完整說明文件 | 功能變更時同步更新 |

---

## 附錄：定期維護 Checklist

以下為建議的**每週維護**清單：

- [ ] `gh auth status` 確認 GitHub 認證有效
- [ ] `python main.py --dry-run` 確認套件清單合理
- [ ] `python main.py` 執行完整分析
- [ ] 審閱 `diff-report_*.md` 變更內容
- [ ] 如有 FQDN 變更，評估是否需更新防火牆規則
- [ ] `git add && git commit && git push` 提交分析結果
- [ ] 如有需要，部署新規則至 Azure Firewall

以下為建議的**每月維護**清單：

- [ ] 檢查是否有新的 EOL 套件需加入封鎖清單
- [ ] 檢查是否有新的 WSL 發行版需加入分析
- [ ] 清理 90 天以上的 `audit_logs/audit_*.json`
- [ ] `pip install -r requirements.txt --upgrade` 更新 Python 依賴
- [ ] `python -m pytest tests/ --ignore=tests/test_integration.py -v` 確認測試通過
