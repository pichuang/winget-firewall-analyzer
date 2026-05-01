# generated/ — 程式產出檔案

此資料夾存放由 `main.py` 自動產生的檔案，用於稽核留存與部署參考。

## 檔案說明

| 檔案 | 用途 | 產生方式 |
|---|---|---|
| `firewall-rules.md` | Azure Firewall Policy 規則維護清單 | `python main.py ... -f md` |
| `diff-report.md` | 與前次分析的變更對比報告 | 每次執行自動產生 |
| `deploy.sh` | Azure CLI 部署腳本 | 每次執行自動產生 |
| `download.sh` | Bash 一鍵下載腳本（curl） | 預設自動產生 |
| `download.ps1` | PowerShell 一鍵下載腳本 | 預設自動產生 |
| `rules.json` | ARM Template 相容 JSON | `python main.py ... -f json > generated/rules.json` |
| `rules.csv` | 試算表審閱用 CSV | `python main.py ... -f csv > generated/rules.csv` |

## 注意事項

- **請勿手動編輯** — 這些檔案會在每次執行分析時重新產生
- 提交至 Git 是為了稽核留存，方便追蹤規則變更歷程
- 搭配 `audit_logs/` 可完整回溯每次分析的輸入與輸出
