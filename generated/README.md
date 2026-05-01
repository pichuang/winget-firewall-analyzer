# generated/ — 程式產出檔案

此資料夾存放由 `main.py` 自動產生的檔案，用於稽核留存與部署參考。
所有檔名皆包含時間戳記 `YYYYMMDD_HHMMSS`（精確到秒），確保每次執行的產出獨立留存、不會被覆蓋。

## 檔案說明

| 檔案模式 | 用途 |
|---|---|
| `firewall-rules_YYYYMMDD_HHMMSS.md` | Azure Firewall Policy 規則維護清單 |
| `diff-report_YYYYMMDD_HHMMSS.md` | 與前次分析的變更對比報告 |
| `deploy_YYYYMMDD_HHMMSS.sh` | Azure CLI 部署腳本 |
| `download_YYYYMMDD_HHMMSS.sh` | Bash 一鍵下載腳本（curl） |
| `download_YYYYMMDD_HHMMSS.ps1` | PowerShell 一鍵下載腳本 |
| `rules_YYYYMMDD_HHMMSS.json` | ARM Template 相容 JSON |
| `rules_YYYYMMDD_HHMMSS.csv` | 試算表審閱用 CSV |

## 注意事項

- **請勿手動編輯** — 這些檔案會在每次執行分析時重新產生
- **每次執行獨立留存** — 時間戳記精確到秒，不會覆蓋先前的產出
- 提交至 Git 是為了稽核留存，方便追蹤規則變更歷程
- 搭配 `audit_logs/` 可完整回溯每次分析的輸入與輸出
