# winget 套件清單 — 分類報告

> 產生時間：2026-05-01 | 共 399 個探索到的套件 | ✅ 允許 292 個 | ❌ 封鎖 107 個

## 📊 分類摘要

| 分類 | 說明 | 套件數 |
|---|---|---|
| ☁️ Azure 雲端工具 | Azure 雲端平台管理、部署、監控相關工具 | 29 |
| 💻 開發工具與 IDE | 軟體開發、程式碼編輯、建置、偵錯工具 | 35 |
| 🔧 .NET 開發與執行環境 | .NET SDK、Runtime、ASP.NET Core 等開發與部署元件 | 26 |
| 🗄️ 資料庫工具 | SQL Server、資料庫管理、資料遷移工具 | 20 |
| 📊 商業智慧與 AI 工具 | Power BI、資料分析、AI/ML、Foundry 相關工具 | 9 |
| 🏢 Office 與生產力工具 | Microsoft 365、Teams、OneDrive 等辦公生產力工具 | 20 |
| 🖥️ Windows 系統管理 | Windows 作業系統管理、部署、診斷、組態工具 | 48 |
| 🛡️ 資安與合規工具 | 安全性掃描、合規檢查、加密與憑證管理 | 8 |
| 🔍 Sysinternals 診斷工具套件 | Microsoft Sysinternals 系統診斷與監控工具 | 23 |
| 🌐 網路與 Web 工具 | 網路診斷、IIS、Web 部署、通訊協定分析 | 19 |
| 📦 執行環境與程式庫 | VC++ Redistributable、WinUI、Windows App Runtime、Java 等執行環境 | 26 |
| 🔨 Windows SDK 與驅動開發 | Windows SDK、WDK、驅動程式開發與硬體測試工具 | 15 |
| 📋 應用程式封裝與部署 | MSIX 封裝、應用程式部署與散佈工具 | 4 |
| 🤖 Bot 與 API 工具 | Bot Framework、OpenAPI、微服務相關工具 | 7 |
| 🌐 瀏覽器 | Microsoft Edge 瀏覽器與相關元件 | 3 |
| **✅ 允許合計** | | **292** |
| ❌ 封鎖 | 已 EOL / 已停產 / Preview 等 | 107 |

---

## ⚠️ 資安風險評估

> 以下工具雖為 Microsoft 官方套件，但因其功能特性可能被內部有心人士濫用。
> 建議依據風險等級搭配對應的管控措施。

### 🎯 紅隊 / 攻擊者常用工具（MITRE ATT&CK 對照）

> 以下套件是資安紅隊演練或真實攻擊中**經常被使用**的 Living-off-the-Land（LOLBin）工具。
> 這些都是 Microsoft 官方工具，但因功能強大而被攻擊者廣泛濫用。

| 套件識別碼 | ATT&CK 戰術 | 紅隊用途 |
|---|---|---|
| **偵察與發現（Discovery）** | | |
| `Microsoft.Sysinternals.ProcessExplorer` | T1057 程序發現 | 列舉所有執行中程序、檢視安全性 token、識別防毒軟體 |
| `Microsoft.Sysinternals.ProcessMonitor` | T1057 / T1083 | 即時監控檔案、Registry、網路活動，偵察目標系統行為 |
| `Microsoft.Sysinternals.TCPView` | T1049 網路連線發現 | 列舉所有 TCP/UDP 連線，識別內部服務與網路拓撲 |
| `Microsoft.Sysinternals.Handle` | T1057 程序發現 | 識別哪些程序正在存取特定檔案或 Registry |
| `Microsoft.Sysinternals.Autoruns` | T1518 軟體發現 | 列舉所有自動啟動項目，尋找可植入後門的位置 |
| `Microsoft.Sysinternals.Sigcheck` | T1518 軟體發現 | 識別未簽章或異常簽章的執行檔 |
| `Microsoft.Sysinternals.Strings` | T1005 本機資料收集 | 從二進位檔中擷取字串，尋找內嵌密碼、API Key、連線字串 |
| `Microsoft.Sysinternals.Whois` | T1596 搜尋開放技術資料 | 查詢網域註冊資訊，偵察攻擊目標 |
| `Microsoft.LogParser` | T1005 本機資料收集 | 查詢事件日誌擷取帳號、登入、敏感操作記錄 |
| **持久性與權限提升（Persistence / Privilege Escalation）** | | |
| `Microsoft.PowerShell` | T1059.001 PowerShell | **#1 攻擊工具**：執行混淆腳本、下載惡意程式、橫向移動、免檔案攻擊 |
| `Microsoft.Sysinternals.Autologon` | T1078 有效帳號 | 設定自動登入，將密碼明文儲存於 Registry |
| `Microsoft.LAPS` | T1555 憑證儲存 | 查詢本機管理員密碼，若權限控管不當可取得所有機器管理員密碼 |
| `Microsoft.DSC` | T1543 系統服務 | 自動化修改系統組態，可植入持久性設定 |
| **橫向移動（Lateral Movement）** | | |
| `Microsoft.Sysinternals.RDCMan` | T1021.001 RDP | 管理多台機器的遠端桌面連線，連線資訊可能被竊取 |
| `Microsoft.RemoteDesktopClient` | T1021.001 RDP | 連線至內部或外部機器 |
| `Microsoft.RemoteHelp` | T1021 遠端服務 | 允許外部人員操控本機桌面 |
| `Microsoft.WindowsApp` | T1021 遠端服務 | 連線至 Windows 365 / AVD 虛擬桌面 |
| **資料外洩（Exfiltration）** | | |
| `Microsoft.Azure.AZCopy.10` | T1567.002 雲端外洩 | 大量複製資料至 Azure Storage，高速傳輸 |
| `Microsoft.OneDrive` | T1567.002 雲端外洩 | 自動同步本機檔案至個人雲端空間 |
| `Microsoft.Azure.DataCLI` | T1567.002 雲端外洩 | 存取與傳輸雲端資料庫資料 |
| `Microsoft.Git` | T1567 Web 服務外洩 | 推送程式碼/檔案至外部 Git 伺服器 |
| `GitHub.cli` | T1567 Web 服務外洩 | 透過 GitHub API 傳輸資料 |
| `GitHub.GitLFS` | T1567 Web 服務外洩 | 傳輸大型檔案至外部 Git 伺服器 |
| `Microsoft.SqlPackage` | T1005 本機資料收集 | 匯出整個資料庫為 .bacpac 檔案 |
| **防禦規避（Defense Evasion）** | | |
| `Microsoft.WSL` | T1202 間接指令執行 | 在 Linux 子系統中執行命令，繞過 Windows EDR/防毒 |
| `Microsoft.Sysinternals.SDelete` | T1070.004 刪除指標 | 安全刪除檔案，銷毀攻擊痕跡，妨礙數位鑑識 |
| `Microsoft.DTrace` | T1014 Rootkit 手法 | 核心層級追蹤，監控系統呼叫 |
| **記憶體分析（可擷取憑證）** | | |
| `Microsoft.WinDbg` | T1003 憑證傾印 | 分析記憶體傾印，可從 lsass.exe 傾印中擷取密碼 |
| `Microsoft.SmartDump` | T1003 憑證傾印 | 產生程序記憶體傾印，傾印檔可能包含明文憑證 |
| `Microsoft.Sysinternals.VMMap` | T1003 憑證傾印 | 檢視程序記憶體配置 |
| `Microsoft.Sysinternals.RAMMap` | T1003 憑證傾印 | 分析實體記憶體，可能發現敏感資料 |

### 風險等級說明

| 等級 | 說明 | 建議管控 |
|---|---|---|
| 🔴 高風險 | 可直接用於資料外洩、權限提升、繞過安全控制 | 限制安裝權限、啟用稽核日誌、僅授權特定人員使用 |
| 🟡 中風險 | 可間接協助攻擊、收集系統資訊、修改系統組態 | 記錄使用行為、定期審查安裝清單 |
| 🟢 低風險 | 正常用途但需注意，功能可能影響系統組態 | 一般管控即可 |

### 🔴 高風險套件（15 個）

| 套件識別碼 | 風險說明 |
|---|---|
| `Microsoft.Azure.AZCopy.10` | 大量資料複製工具，可將本機資料上傳至任意 Azure Storage，潛在資料外洩管道 |
| `Microsoft.Azure.DataCLI` | Azure 資料操作 CLI，可存取與傳輸雲端資料庫資料 |
| `Microsoft.DTrace` | 核心層級追蹤工具，可監控系統呼叫與核心行為 |
| `Microsoft.OneDrive` | 雲端同步工具，可自動將本機檔案同步至個人 OneDrive，資料外洩風險 |
| `Microsoft.PowerShell` | 功能強大的命令列工具，可執行任意腳本、修改系統、存取網路，常被濫用於攻擊 |
| `Microsoft.RemoteDesktopClient` | 遠端桌面用戶端，可連線至外部機器 |
| `Microsoft.RemoteHelp` | 遠端協助工具，允許外部人員操控本機 |
| `Microsoft.Sysinternals.ProcessExplorer` | 進階工作管理員，可檢視所有程序詳情含安全性 token |
| `Microsoft.Sysinternals.ProcessMonitor` | 即時監控檔案系統、Registry、程序活動，可用於偵察敏感操作 |
| `Microsoft.Sysinternals.PsExec` | 遠端執行工具，常被攻擊者用於橫向移動 |
| `Microsoft.Sysinternals.SDelete` | 安全刪除工具，可不可逆地銷毀檔案，妨礙數位鑑識 |
| `Microsoft.Sysinternals.Sysmon` | 系統監控工具，可記錄所有程序活動，若被攻擊者利用可收集機密資訊 |
| `Microsoft.WSL` | Windows Subsystem for Linux，提供完整 Linux 環境，可繞過 Windows 安全控制 |
| `Microsoft.WindowsApp` | Windows 365 / AVD 用戶端，可連線至外部虛擬桌面 |
| `Microsoft.devtunnel` | 建立 dev tunnel 反向隧道，可將內部服務暴露至公網，繞過防火牆 |

### 🟡 中風險套件（40 個）

| 套件識別碼 | 風險說明 |
|---|---|
| `GitHub.Copilot` | AI 程式碼輔助工具，程式碼會傳送至雲端 AI 服務處理 |
| `GitHub.GitHubDesktop` | GitHub 桌面用戶端，可推送程式碼至外部 repository |
| `GitHub.GitLFS` | Git Large File Storage，可傳輸大型檔案至外部 Git 伺服器 |
| `GitHub.cli` | GitHub CLI，可操作 GitHub repository、建立 PR、存取 API |
| `Microsoft.Azure.Auth` | Azure 認證工具，管理雲端認證 token |
| `Microsoft.Azure.Az` | Azure PowerShell 模組，可管理所有 Azure 資源 |
| `Microsoft.Azure.ConnectedMachineAgent` | Azure Arc Agent，可將機器連線至 Azure 管理平面 |
| `Microsoft.Azure.Kubelogin` | Kubernetes 認證工具，可取得叢集存取權 |
| `Microsoft.AzureCLI` | Azure 命令列工具，可管理所有 Azure 資源，需嚴格控管認證 |
| `Microsoft.DebugDiag` | 診斷與記憶體傾印分析工具 |
| `Microsoft.DeploymentToolkit` | 系統部署工具，可大規模修改作業系統映像 |
| `Microsoft.DiskSpd` | 磁碟效能測試工具，可產生大量 I/O 負載 |
| `Microsoft.Edge` | 網頁瀏覽器，可存取任意網站，需搭配網頁過濾政策 |
| `Microsoft.Git` | 版本控制工具，可推送程式碼至外部 repository |
| `Microsoft.LAPS` | 本機管理員密碼管理，操作不當可能洩露密碼 |
| `Microsoft.LogParser` | 日誌分析工具，可查詢系統事件記錄擷取敏感資訊 |
| `Microsoft.MFCMapi` | MAPI 操作工具，可直接存取 Exchange 信箱資料 |
| `Microsoft.Ntttcp` | 網路效能測試工具，可產生大量網路流量 |
| `Microsoft.OSCDIMG` | 建立 ISO 映像檔工具 |
| `Microsoft.Pave` | 封包驗證工具，可分析網路通訊 |
| `Microsoft.PerfView` | 效能追蹤工具，追蹤檔可能包含敏感資料 |
| `Microsoft.SQLServerManagementStudio` | SQL Server 管理工具，可直接存取與操作資料庫 |
| `Microsoft.SmartDump` | 記憶體傾印工具，傾印檔可能包含敏感資料 |
| `Microsoft.SqlPackage` | 資料庫匯出/匯入工具，可匯出整個資料庫 |
| `Microsoft.Sqlcmd` | SQL 命令列工具，可執行任意 SQL 查詢 |
| `Microsoft.Sysinternals.Autoruns` | 檢視所有自動啟動項目，可用於偵察與植入持久性後門 |
| `Microsoft.Sysinternals.DebugView` | 擷取 debug 輸出訊息，可能包含敏感資訊 |
| `Microsoft.Sysinternals.Handle` | 檢視程序開啟的檔案 handle，可偵察敏感檔案存取 |
| `Microsoft.Sysinternals.RegJump` | 快速跳轉 Registry 位置，協助修改系統設定 |
| `Microsoft.Sysinternals.Sigcheck` | 驗證檔案簽章，可用於識別未簽章的可執行檔 |
| `Microsoft.Sysinternals.Strings` | 擷取二進位檔中的字串，可用於分析程式或擷取內嵌密碼 |
| `Microsoft.Sysinternals.TCPView` | 即時網路連線監控，可偵察網路拓撲與服務端口 |
| `Microsoft.Sysinternals.VMMap` | 記憶體分析工具，可檢視程序記憶體配置 |
| `Microsoft.Sysinternals.Whois` | 網域查詢工具，可用於偵察外部目標 |
| `Microsoft.TimeTravelDebugging` | 時光旅行偵錯，可重播程序執行過程 |
| `Microsoft.VisualStudioCode` | 程式碼編輯器含擴充套件生態系，擴充套件可能有安全風險 |
| `Microsoft.WinDbg` | Windows 核心偵錯工具，可分析記憶體傾印與核心行為 |
| `Microsoft.WindowsADK` | Windows 評定與部署套件，可建立與修改系統映像 |
| `Microsoft.etl2pcapng` | 將 ETL 轉為 pcap 格式，可擷取與分析網路封包 |
| `Microsoft.quicreach` | QUIC 連線測試工具，可探測外部服務 |

### 🟢 低風險套件（8 個）

| 套件識別碼 | 風險說明 |
|---|---|
| `Microsoft.AppInstaller` | winget 安裝器，可從網路下載並安裝任意 winget 套件 |
| `Microsoft.Azd` | Azure Developer CLI，可部署應用程式至 Azure |
| `Microsoft.Bicep` | Azure 基礎設施即程式碼，可建立/修改雲端資源 |
| `Microsoft.DSC` | Desired State Configuration，可自動化系統組態變更 |
| `Microsoft.FSLogix` | Profile Container 管理，處理使用者設定檔 |
| `Microsoft.IntegrationRuntime` | Azure Data Factory 整合執行環境，連接內外部資料來源 |
| `Microsoft.IntuneWSLPlugin` | Intune WSL 外掛，管理 WSL 分配 |
| `Microsoft.PowerToys` | 生產力工具集，部分功能（如 Hosts 編輯）可修改系統設定 |

### 📊 風險統計

- 🔴 高風險：15 個套件
- 🟡 中風險：40 個套件
- 🟢 低風險：8 個套件
- ⚪ 無特殊風險：229 個套件

### 🔐 建議存取控制分級

> 建議搭配 Intune / SCCM 軟體部署政策，依 AD 群組控管安裝權限。

#### 🔒 第一級：僅限 IT 管理員 / 資安團隊（18 個）

需 Privileged Access Workstation（PAW）或特權帳號才可安裝：

| 套件識別碼 | 限制理由 |
|---|---|
| `Microsoft.PowerShell` | 攻擊者 #1 工具，可執行任意腳本 |
| `Microsoft.WSL` | 完整 Linux 環境，繞過 Windows EDR |
| `Microsoft.DTrace` | 核心層級追蹤 |
| `Microsoft.Sysinternals.SDelete` | 銷毀檔案、妨礙鑑識 |
| `Microsoft.Sysinternals.ProcessMonitor` | 系統活動即時監控 |
| `Microsoft.Sysinternals.ProcessExplorer` | 進階程序分析含 token |
| `Microsoft.Sysinternals.Sysmon` | 全系統行為記錄 |
| `Microsoft.Sysinternals.Autoruns` | 自動啟動項偵察 |
| `Microsoft.Sysinternals.Autologon` | 明文儲存登入密碼 |
| `Microsoft.Sysinternals.Strings` | 擷取二進位檔中密碼 |
| `Microsoft.WinDbg` | 記憶體傾印分析、可擷取憑證 |
| `Microsoft.SmartDump` | 記憶體傾印工具 |
| `Microsoft.LAPS` | 查詢本機管理員密碼 |
| `Microsoft.LogParser` | 查詢敏感事件日誌 |
| `Microsoft.MFCMapi` | 直接存取 Exchange 信箱 |
| `Microsoft.WindowsADK` | 建立/修改系統映像 |
| `Microsoft.DeploymentToolkit` | 大規模系統部署 |
| `Microsoft.OSCDIMG` | 建立 ISO 映像 |

#### 👨‍💻 第二級：僅限開發人員（14 個）

需開發者群組審批，一般使用者不可安裝：

| 套件識別碼 | 限制理由 |
|---|---|
| `Microsoft.Azure.AZCopy.10` | 大量資料傳輸，外洩管道 |
| `Microsoft.Azure.DataCLI` | 雲端資料庫操作 |
| `Microsoft.AzureCLI` | 管理所有 Azure 資源 |
| `Microsoft.Azure.Az` | Azure PowerShell 管理 |
| `Microsoft.Azure.Kubelogin` | K8s 叢集認證 |
| `Microsoft.Git` | 推送程式碼至外部 |
| `GitHub.cli` | GitHub API 操作 |
| `GitHub.GitLFS` | 大型檔案外傳 |
| `Microsoft.SQLServerManagementStudio` | 直接操作資料庫 |
| `Microsoft.Sqlcmd` | 執行任意 SQL |
| `Microsoft.SqlPackage` | 匯出整個資料庫 |
| `Microsoft.VisualStudioCode` | 擴充套件有安全風險 |
| `Microsoft.TimeTravelDebugging` | 程序執行重播 |
| `Microsoft.DebugDiag` | 記憶體傾印分析 |

#### 📋 第三級：需申請審批（6 個）

一般使用者提出申請後可開放：

| 套件識別碼 | 限制理由 |
|---|---|
| `Microsoft.RemoteDesktopClient` | 遠端連線需管控目標 |
| `Microsoft.RemoteHelp` | 外部人員操控本機 |
| `Microsoft.WindowsApp` | 連線外部虛擬桌面 |
| `Microsoft.OneDrive` | 同步至個人雲端 |
| `Microsoft.Edge` | 搭配網頁過濾政策即可 |
| `GitHub.Copilot` | 程式碼傳送至雲端 AI |

#### ✅ 第四級：一般使用者可用（254 個）

無需特別限制，可透過 winget 自由安裝。

---

## ☁️ Azure 雲端工具

> Azure 雲端平台管理、部署、監控相關工具

- `Microsoft.AKSdesktop`
- `Microsoft.Azd` 🟢 低
- `Microsoft.Azure.ADConnectSyncDocumenter`
- `Microsoft.Azure.AZCopy.10` 🔴 高
- `Microsoft.Azure.ArtifactSigningClientTools`
- `Microsoft.Azure.Auth` 🟡 中
- `Microsoft.Azure.Az` 🟡 中
- `Microsoft.Azure.AztfExport`
- `Microsoft.Azure.BatchExplorer`
- `Microsoft.Azure.CloudHSM-ClientSDK`
- `Microsoft.Azure.ConnectedMachineAgent` 🟡 中
- `Microsoft.Azure.CosmosEmulator`
- `Microsoft.Azure.DataCLI` 🔴 高
- `Microsoft.Azure.DataStudio`
- `Microsoft.Azure.FunctionsCoreTools`
- `Microsoft.Azure.GuestProxyAgent`
- `Microsoft.Azure.IoTExplorer`
- `Microsoft.Azure.Kubelogin` 🟡 中
- `Microsoft.Azure.QuickReview`
- `Microsoft.Azure.StorageExplorer`
- `Microsoft.Azure.TemplateAnalyzer`
- `Microsoft.Azure.TrustedSigningClientTools`
- `Microsoft.AzureCLI` 🟡 中
- `Microsoft.AzureMonitorAgent`
- `Microsoft.AzureVPNClient`
- `Microsoft.Bicep` 🟢 低
- `Microsoft.CertifiedToolAzureVM`
- `Microsoft.CmdPalAzureExtension`
- `Microsoft.GlobalSecureAccessClient`

---

## 💻 開發工具與 IDE

> 軟體開發、程式碼編輯、建置、偵錯工具

- `GitHub.Copilot` 🟡 中
- `GitHub.GitHubDesktop` 🟡 中
- `GitHub.GitLFS` 🟡 中
- `GitHub.cli` 🟡 中
- `GitHub.git-sizer`
- `Microsoft.ApplicationInspector`
- `Microsoft.Aspire`
- `Microsoft.DebugDiag` 🟡 中
- `Microsoft.DevSkim.CLI.DotNetTool`
- `Microsoft.DevSkim.CLI.LibraryPackage`
- `Microsoft.Edit`
- `Microsoft.Git` 🟡 中
- `Microsoft.NuGet`
- `Microsoft.PICT`
- `Microsoft.PIX`
- `Microsoft.PerfView` 🟡 中
- `Microsoft.Promptflow`
- `Microsoft.SBOMTool`
- `Microsoft.SmartDump` 🟡 中
- `Microsoft.TimeTravelDebugging` 🟡 中
- `Microsoft.VSDotNetLogCollect`
- `Microsoft.VSIXBootstrapper`
- `Microsoft.VSTOR`
- `Microsoft.VisualStudio.2022.BuildTools`
- `Microsoft.VisualStudio.2022.Enterprise`
- `Microsoft.VisualStudio.2022.OnecoreMsvsmon`
- `Microsoft.VisualStudio.2022.Professional`
- `Microsoft.VisualStudio.2022.RemoteTools`
- `Microsoft.VisualStudio.ConfigFinder`
- `Microsoft.VisualStudio.Extensions.TypeScript`
- `Microsoft.VisualStudio.Locator`
- `Microsoft.VisualStudioCode` 🟡 中
- `Microsoft.VisualTrueType`
- `Microsoft.WinDbg` 🟡 中
- `Microsoft.WingetCreate`

---

## 🔧 .NET 開發與執行環境

> .NET SDK、Runtime、ASP.NET Core 等開發與部署元件

- `Microsoft.DotNet.AspNetCore.10`
- `Microsoft.DotNet.AspNetCore.6`
- `Microsoft.DotNet.AspNetCore.8`
- `Microsoft.DotNet.AspNetCore.9`
- `Microsoft.DotNet.DesktopRuntime.10`
- `Microsoft.DotNet.DesktopRuntime.6`
- `Microsoft.DotNet.DesktopRuntime.8`
- `Microsoft.DotNet.DesktopRuntime.9`
- `Microsoft.DotNet.Framework.DeveloperPack.4.6`
- `Microsoft.DotNet.Framework.DeveloperPack_4`
- `Microsoft.DotNet.Framework.Runtime`
- `Microsoft.DotNet.HostingBundle.10`
- `Microsoft.DotNet.HostingBundle.6`
- `Microsoft.DotNet.HostingBundle.8`
- `Microsoft.DotNet.HostingBundle.9`
- `Microsoft.DotNet.RepairTool`
- `Microsoft.DotNet.Runtime.10`
- `Microsoft.DotNet.Runtime.6`
- `Microsoft.DotNet.Runtime.8`
- `Microsoft.DotNet.Runtime.9`
- `Microsoft.DotNet.SDK.10`
- `Microsoft.DotNet.SDK.6`
- `Microsoft.DotNet.SDK.8`
- `Microsoft.DotNet.SDK.9`
- `Microsoft.DotNet.UninstallTool`
- `Microsoft.DotNet.dotnet-ef`

---

## 🗄️ 資料庫工具

> SQL Server、資料庫管理、資料遷移工具

- `Microsoft.CLRTypesSQLServer.2019`
- `Microsoft.DataMigrationAssistant`
- `Microsoft.DataTools.IntegrationServices`
- `Microsoft.Garnet.DN8`
- `Microsoft.Garnet.DN9`
- `Microsoft.IntegrationRuntime` 🟢 低
- `Microsoft.ReportBuilder`
- `Microsoft.SQLServer.2019.Developer`
- `Microsoft.SQLServer.2019.Express`
- `Microsoft.SQLServer.2022.Developer`
- `Microsoft.SQLServer.2022.Express`
- `Microsoft.SQLServer.2025.Developer`
- `Microsoft.SQLServer.2025.Express`
- `Microsoft.SQLServer.OLEDBDriver`
- `Microsoft.SQLServer.RMLUtilities`
- `Microsoft.SQLServerManagementStudio` 🟡 中
- `Microsoft.SqlPackage` 🟡 中
- `Microsoft.Sqlcmd` 🟡 中
- `Microsoft.msodbcsql.17`
- `Microsoft.msodbcsql.18`

---

## 📊 商業智慧與 AI 工具

> Power BI、資料分析、AI/ML、Foundry 相關工具

- `Microsoft.AIShell`
- `Microsoft.FoundryLocal`
- `Microsoft.FuzzyLookupAddExcel`
- `Microsoft.LightGBM`
- `Microsoft.M365AgentsPlayground`
- `Microsoft.PowerBI`
- `Microsoft.PowerBIReportBuilder`
- `Microsoft.PowerBIReportServer`
- `Microsoft.Tokenizer`

---

## 🏢 Office 與生產力工具

> Microsoft 365、Teams、OneDrive 等辦公生產力工具

- `Microsoft.AmendmentAppWordService`
- `Microsoft.HwpConverter`
- `Microsoft.Office`
- `Microsoft.OfficeDeploymentTool`
- `Microsoft.OneDrive` 🔴 高
- `Microsoft.OneLakeFileExplorer`
- `Microsoft.OneNoteDiagnostics`
- `Microsoft.PowerAppsCLI`
- `Microsoft.PowerAutomateDesktop`
- `Microsoft.PowerAutomateProcessMining`
- `Microsoft.PurviewInformationProtection`
- `Microsoft.RMSClient`
- `Microsoft.RemoteDesktopClient` 🔴 高
- `Microsoft.RemoteDesktopMMRService`
- `Microsoft.RemoteHelp` 🔴 高
- `Microsoft.TeamMate`
- `Microsoft.Teams`
- `Microsoft.TeamsTxNDI`
- `Microsoft.VisioViewer`
- `Microsoft.WindowsApp` 🔴 高

---

## 🖥️ Windows 系統管理

> Windows 作業系統管理、部署、診斷、組態工具

- `Microsoft.AdministrativeTemplates`
- `Microsoft.AppInstaller` 🟢 低
- `Microsoft.AppInstallerFileBuilder`
- `Microsoft.BTP`
- `Microsoft.DSC` 🟢 低
- `Microsoft.DTrace` 🔴 高
- `Microsoft.DependencyAgent`
- `Microsoft.DeploymentToolkit` 🟡 中
- `Microsoft.DiskSpd` 🟡 中
- `Microsoft.EventLogExpert`
- `Microsoft.FSLogix` 🟢 低
- `Microsoft.IntuneWSLPlugin` 🟢 低
- `Microsoft.Kanagawa`
- `Microsoft.LAPS` 🟡 中
- `Microsoft.LogCheetah`
- `Microsoft.LogParser` 🟡 中
- `Microsoft.MFCMapi` 🟡 中
- `Microsoft.MaliciousSoftwareRemovalTool`
- `Microsoft.MediaCreationTool`
- `Microsoft.MouseWithoutBorders`
- `Microsoft.MouseandKeyboardCenter`
- `Microsoft.OSCDIMG` 🟡 中
- `Microsoft.OSConfig`
- `Microsoft.PowerShell` 🔴 高
- `Microsoft.PowerToys` 🟢 低
- `Microsoft.PrintMetadataTroubleshooter`
- `Microsoft.ProfileExplorer`
- `Microsoft.SaRACmd`
- `Microsoft.SafetyScanner`
- `Microsoft.ScreenRecorder`
- `Microsoft.SetupDiag`
- `Microsoft.SurfaceApp`
- `Microsoft.SurfaceHubRecoveryTool`
- `Microsoft.UpdateAssistant`
- `Microsoft.WSL` 🔴 高
- `Microsoft.Win32ContentPrepTool`
- `Microsoft.WinAppCli`
- `Microsoft.WindowsADK` 🟡 中
- `Microsoft.WindowsAdminCenter`
- `Microsoft.WindowsCloudIOProtectionDriver`
- `Microsoft.WindowsDeviceRecoveryTool`
- `Microsoft.WindowsInstallationAssistant`
- `Microsoft.WindowsPCHealthCheck`
- `Microsoft.WindowsTerminal`
- `Microsoft.WindowsVirtualDesktopAgent`
- `Microsoft.WindowsVirtualDesktopBootloader`
- `Microsoft.XMLNotepad`
- `Microsoft.winfile`

---

## 🛡️ 資安與合規工具

> 安全性掃描、合規檢查、加密與憑證管理

- `Microsoft.AppControlPolicyWizard`
- `Microsoft.AppLockerPolicyConverter`
- `Microsoft.DefenderForCloud.CLI`
- `Microsoft.EnterpriseStateClassify`
- `Microsoft.SecurityComplianceToolkit.LGPO`
- `Microsoft.SecurityComplianceToolkit.PolicyAnalyzer`
- `Microsoft.SecurityComplianceToolkit.SetObjectSecurity`
- `Microsoft.SymCryptUnitTest`

---

## 🔍 Sysinternals 診斷工具套件

> Microsoft Sysinternals 系統診斷與監控工具

- `Microsoft.Sysinternals.Autologon`
- `Microsoft.Sysinternals.Autoruns` 🟡 中
- `Microsoft.Sysinternals.BGInfo`
- `Microsoft.Sysinternals.Ctrl2Cap`
- `Microsoft.Sysinternals.DebugView` 🟡 中
- `Microsoft.Sysinternals.Desktops`
- `Microsoft.Sysinternals.FindLinks`
- `Microsoft.Sysinternals.Handle` 🟡 中
- `Microsoft.Sysinternals.MoveFile`
- `Microsoft.Sysinternals.PendMoves`
- `Microsoft.Sysinternals.ProcessExplorer` 🔴 高
- `Microsoft.Sysinternals.ProcessMonitor` 🔴 高
- `Microsoft.Sysinternals.RAMMap` �� 中
- `Microsoft.Sysinternals.RDCMan`
- `Microsoft.Sysinternals.RegJump` 🟡 中
- `Microsoft.Sysinternals.SDelete` 🔴 高
- `Microsoft.Sysinternals.Sigcheck` 🟡 中
- `Microsoft.Sysinternals.Strings` 🟡 中
- `Microsoft.Sysinternals.Sysmon` 🔴 高
- `Microsoft.Sysinternals.TCPView` 🟡 中
- `Microsoft.Sysinternals.VMMap` 🟡 中
- `Microsoft.Sysinternals.Whois` 🟡 中
- `Microsoft.Sysinternals.ZoomIt`

---

## 🌐 網路與 Web 工具

> 網路診斷、IIS、Web 部署、通訊協定分析

- `Microsoft.APM`
- `Microsoft.ASRTestTool`
- `Microsoft.AccountLockoutStatus`
- `Microsoft.DirectAccessCTST`
- `Microsoft.FRSDiag`
- `Microsoft.IIS.Compression`
- `Microsoft.IIS.ServiceMonitor`
- `Microsoft.IIS.URLRewrite`
- `Microsoft.IISManagerRemoteAdministration`
- `Microsoft.IdFix`
- `Microsoft.LingeringObjectLiquidator`
- `Microsoft.Ntttcp` 🟡 中
- `Microsoft.Pave` 🟡 中
- `Microsoft.ProjectTelescope`
- `Microsoft.WebDeploy`
- `Microsoft.bitsmanager`
- `Microsoft.err`
- `Microsoft.etl2pcapng` 🟡 中
- `Microsoft.quicreach` 🟡 中

---

## 📦 執行環境與程式庫

> VC++ Redistributable、WinUI、Windows App Runtime、Java 等執行環境

- `Microsoft.DirectX`
- `Microsoft.DirectXTex.Texassemble`
- `Microsoft.DirectXTex.Texconv`
- `Microsoft.DirectXTex.Texdiag`
- `Microsoft.GameInput`
- `Microsoft.IronPython.3`
- `Microsoft.OpenCLGLVulkanCompatibilityPack`
- `Microsoft.OpenJDK.11`
- `Microsoft.OpenJDK.17`
- `Microsoft.OpenJDK.21`
- `Microsoft.OpenJDK.25`
- `Microsoft.UI.Xaml.2.7`
- `Microsoft.UI.Xaml.2.8`
- `Microsoft.VCLibs.14`
- `Microsoft.VCLibs.Desktop.14`
- `Microsoft.VCRedist.2012.x64`
- `Microsoft.VCRedist.2012.x86`
- `Microsoft.VCRedist.2013.x64`
- `Microsoft.VCRedist.2013.x86`
- `Microsoft.VCRedist.2015+.arm64`
- `Microsoft.VCRedist.2015+.x64`
- `Microsoft.VCRedist.2015+.x86`
- `Microsoft.WindowsAppRuntime.1.5`
- `Microsoft.WindowsAppRuntime.1.6`
- `Microsoft.WindowsAppRuntime.1.7`
- `Microsoft.WindowsAppRuntime.1.8`

---

## 🔨 Windows SDK 與驅動開發

> Windows SDK、WDK、驅動程式開發與硬體測試工具

- `Microsoft.HIDTools.Waratah`
- `Microsoft.MIDI.FeatureEnablementChecker`
- `Microsoft.MIDI.SDK`
- `Microsoft.MITT`
- `Microsoft.MUTT`
- `Microsoft.WindowsApplicationDriver`
- `Microsoft.WindowsBusesTracing`
- `Microsoft.WindowsMIDIServicesSDK`
- `Microsoft.WindowsSDK.10.0.22000`
- `Microsoft.WindowsSDK.10.0.22621`
- `Microsoft.WindowsSDK.10.0.26100`
- `Microsoft.WindowsSDK.10.0.28000`
- `Microsoft.WindowsWDK.10.0.22000`
- `Microsoft.WindowsWDK.10.0.22621`
- `Microsoft.WindowsWDK.10.0.26100`

---

## 📋 應用程式封裝與部署

> MSIX 封裝、應用程式部署與散佈工具

- `Microsoft.MSIX-Toolkit`
- `Microsoft.MSIXCore`
- `Microsoft.MSIXPackagingTool`
- `Microsoft.Wassette`

---

## 🤖 Bot 與 API 工具

> Bot Framework、OpenAPI、微服務相關工具

- `Microsoft.BotFrameworkComposer`
- `Microsoft.BotFrameworkEmulator`
- `Microsoft.CmdPalGitHubExtension`
- `Microsoft.OpenAPI.Hidi`
- `Microsoft.OpenAPI.Kiota`
- `Microsoft.ServiceFabricRuntime`
- `Microsoft.ServiceFabricSDK`

---

## 🌐 瀏覽器

> Microsoft Edge 瀏覽器與相關元件

- `Microsoft.Edge` 🟡 中
- `Microsoft.EdgeDriver`
- `Microsoft.EdgeWebView2Runtime`

---

## ❌ 封鎖的套件（107 個）

> 以下套件已被封鎖清單排除（已 EOL、已停產、Preview/Beta 版本等），不進行防火牆規則分析。

- `GitHub.Atom`
- `GitHub.ClassroomAssistant`
- `GitHub.hub`
- `GitHub.smimesign`
- `Microsoft.16BitInstallShieldSupport`
- `Microsoft.AccessDatabaseEngine.2016`
- `Microsoft.Azure.Aztfy`
- `Microsoft.Azure.StorageEmulator`
- `Microsoft.Azure.aks-engine-azurestack`
- `Microsoft.AzureDevOpsOfficeIntegration.2019`
- `Microsoft.AzureMediaServicesExplorer`
- `Microsoft.BingWallpaper`
- `Microsoft.BuildTools2015`
- `Microsoft.DotNet.AspNetCore.2_1`
- `Microsoft.DotNet.AspNetCore.2_2`
- `Microsoft.DotNet.AspNetCore.2_2_402`
- `Microsoft.DotNet.AspNetCore.3_0`
- `Microsoft.DotNet.AspNetCore.3_1`
- `Microsoft.DotNet.AspNetCore.5`
- `Microsoft.DotNet.AspNetCore.7`
- `Microsoft.DotNet.AspNetCore.Preview`
- `Microsoft.DotNet.CodeContracts`
- `Microsoft.DotNet.DesktopRuntime.3_1`
- `Microsoft.DotNet.DesktopRuntime.5`
- `Microsoft.DotNet.DesktopRuntime.7`
- `Microsoft.DotNet.DesktopRuntime.Preview`
- `Microsoft.DotNet.Framework.DeveloperPack.4.5`
- `Microsoft.DotNet.Framework.Redistributable.1_1`
- `Microsoft.DotNet.HostingBundle.3_1`
- `Microsoft.DotNet.HostingBundle.5`
- `Microsoft.DotNet.HostingBundle.7`
- `Microsoft.DotNet.HostingBundle.Preview`
- `Microsoft.DotNet.Runtime.2_2`
- `Microsoft.DotNet.Runtime.3_1`
- `Microsoft.DotNet.Runtime.5`
- `Microsoft.DotNet.Runtime.7`
- `Microsoft.DotNet.Runtime.Preview`
- `Microsoft.DotNet.SDK.3_1`
- `Microsoft.DotNet.SDK.5`
- `Microsoft.DotNet.SDK.7`
- `Microsoft.DotNet.SDK.Preview`
- `Microsoft.Firewire1394LegacyDriver`
- `Microsoft.Gaming.GDK`
- `Microsoft.Gaming.GamingServicesRepairTool`
- `Microsoft.Gaming.RemoteIterationClient`
- `Microsoft.Gaming.RemoteIterationEndpoint`
- `Microsoft.Gaming.TAK.CLI`
- `Microsoft.Gaming.XboxLiveDeveloperTools`
- `Microsoft.HyperlapsePro`
- `Microsoft.IronPython.2`
- `Microsoft.MSNExplorer`
- `Microsoft.MakeBingYourSearchEngine`
- `Microsoft.MixedRealityFeatureTool`
- `Microsoft.NetMon`
- `Microsoft.OpenJDK.16`
- `Microsoft.OpenSSH.Preview`
- `Microsoft.ProjectMyScreen`
- `Microsoft.SQLServer.11.ODBC`
- `Microsoft.SQLServer.2012.NativeClient`
- `Microsoft.SQLServer.2017.Developer`
- `Microsoft.SQLServer.2017.Express`
- `Microsoft.ServerSpeechPlatformRuntime`
- `Microsoft.SmallBasic`
- `Microsoft.SurfaceDuoEmulator.Android11`
- `Microsoft.UI.Xaml.2.5`
- `Microsoft.UI.Xaml.2.6`
- `Microsoft.VCRedist.2005.x64`
- `Microsoft.VCRedist.2005.x86`
- `Microsoft.VCRedist.2008.x64`
- `Microsoft.VCRedist.2008.x86`
- `Microsoft.VCRedist.2010.x64`
- `Microsoft.VCRedist.2010.x86`
- `Microsoft.VFSforGit`
- `Microsoft.VisualStudio.2017.Enterprise`
- `Microsoft.VisualStudio.2019.BuildTools`
- `Microsoft.VisualStudio.2019.Community`
- `Microsoft.VisualStudio.2019.Enterprise`
- `Microsoft.VisualStudio.2019.Professional`
- `Microsoft.VisualStudio.2022.Community`
- `Microsoft.VisualStudio.BuildTools`
- `Microsoft.VisualStudio.Community`
- `Microsoft.VisualStudio.Enterprise`
- `Microsoft.VisualStudio.OnecoreMsvsmon`
- `Microsoft.VisualStudio.Professional`
- `Microsoft.VisualStudio.RemoteTools`
- `Microsoft.WCFDataServices50.ODatav3`
- `Microsoft.WinGetStudio.Experimental`
- `Microsoft.WindowsAppRuntime.1.0`
- `Microsoft.WindowsAppRuntime.1.1`
- `Microsoft.WindowsAppRuntime.1.2`
- `Microsoft.WindowsAppRuntime.1.3`
- `Microsoft.WindowsAppRuntime.1.4`
- `Microsoft.WindowsJournal`
- `Microsoft.WindowsSDK.10.0.17134`
- `Microsoft.WindowsSDK.10.0.17763`
- `Microsoft.WindowsSDK.10.0.18362`
- `Microsoft.WindowsSDK.10.0.19041`
- `Microsoft.WindowsSDK.10.0.20348`
- `Microsoft.WindowsWDK.10.0.19041`
- `Microsoft.XNARedist`
- `Microsoft.devtunnel`
- `Microsoft.msmpi`
- `Microsoft.msmpisdk`
- `Microsoft.msodbcsql.11`
- `Microsoft.msodbcsql.13`
- `Microsoft.vott`
- `Microsoft.webpicmd`
