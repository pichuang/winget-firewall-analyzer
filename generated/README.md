# generated/ — 程式產出檔案

此資料夾存放由 `main.py` 自動產生的檔案，用於稽核留存與部署參考。
每次執行會建立獨立的時間戳記子目錄 `YYYYMMDD_HHMMSS/`，檔名同樣包含時間戳記，確保每次產出獨立留存且方便跨次 diff 比對。

## 目錄結構

```text
generated/
├── README.md
├── 20260501_121200/
│   ├── firewall-rules_20260501_121200.md
│   ├── diff-report_20260501_121200.md
│   ├── deploy-tls_20260501_121200.sh     ← TLS Inspection（Path 層級）Draft
│   ├── deploy-fqdn_20260501_121200.sh    ← FQDN 層級 Draft
│   ├── download_20260501_121200.sh
│   └── download_20260501_121200.ps1
├── 20260501_143000/
│   └── ...
```

## 部署腳本說明

| 腳本 | 適用場景 | 規則類型 |
|---|---|---|
| `deploy-tls_*.sh` | 已啟用 TLS Inspection | `targetUrls`（Path 層級精確放行） |
| `deploy-fqdn_*.sh` | 未啟用 TLS Inspection | `targetFqdns`（FQDN 層級放行） |

- **兩份腳本擇一執行**，不要同時部署（避免規則重複）
- 使用 **Azure Firewall Policy Draft 模式**，規則不會直接套用
- 部署流程：執行腳本 → 在 Azure Portal 檢視 Draft → 手動執行 `draft deploy` 確認

## 檔案說明

| 檔案模式 | 用途 |
|---|---|
| `firewall-rules_*.md` | Azure Firewall Policy 規則維護清單 |
| `diff-report_*.md` | 與前次分析的變更對比報告 |
| `deploy-tls_*.sh` | Azure CLI 部署腳本 — TLS Inspection Path 層級（Draft 模式） |
| `deploy-fqdn_*.sh` | Azure CLI 部署腳本 — FQDN 層級（Draft 模式） |
| `download_*.sh` | Bash 一鍵下載腳本（curl） |
| `download_*.ps1` | PowerShell 一鍵下載腳本 |
| `rules_*.json` | ARM Template 相容 JSON |
| `rules_*.csv` | 試算表審閱用 CSV |

## 注意事項

- **請勿手動編輯** — 這些檔案會在每次執行分析時重新產生
- **每次執行獨立留存** — 資料夾與檔名皆含時間戳記，不會覆蓋先前的產出
- 提交至 Git 是為了稽核留存，方便追蹤規則變更歷程
- 搭配 `audit_logs/` 可完整回溯每次分析的輸入與輸出
- 跨次比對：`diff generated/20260501_121200/firewall-rules_*.md generated/20260501_143000/firewall-rules_*.md`
