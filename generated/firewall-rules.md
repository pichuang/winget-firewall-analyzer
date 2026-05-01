# winget Azure Firewall Policy 規則清單

> 此文件由 `main.py` 自動產生，記錄每個 winget 套件所需的防火牆放行規則。
> 可作為維護與審閱的依據，建議納入版本控制。

## ⚙️ Azure Firewall Policy 部署資訊

| 參數 | 值 |
|---|---|
| Rule Collection Group | `winget-rules` |
| Rule Collection | `winget-download` |
| Priority | `500` |
| Source IP Groups | `ipgroup-corp-clients, ipgroup-dev-clients` （主要） |
| Source Addresses | `10.0.0.0/8` （備用） |
| 規則總數 | 591 |
| 分析時間 | 2026-05-01 11:46:52 UTC+08:00 |

**快速部署參考**：

```bash
# 套用所有規則（JSON 格式）
python main.py GitHub.Copilot GitHub.GitHubDesktop GitHub.GitLFS GitHub.cli GitHub.git-sizer Microsoft.AIShell Microsoft.AKSdesktop Microsoft.APM Microsoft.ASRTestTool Microsoft.AccountLockoutStatus Microsoft.AdministrativeTemplates Microsoft.AmendmentAppWordService Microsoft.AppControlPolicyWizard Microsoft.AppInstaller Microsoft.AppInstallerFileBuilder Microsoft.AppLockerPolicyConverter Microsoft.ApplicationInspector Microsoft.Aspire Microsoft.Azd Microsoft.Azure.ADConnectSyncDocumenter Microsoft.Azure.AZCopy.10 Microsoft.Azure.ArtifactSigningClientTools Microsoft.Azure.Auth Microsoft.Azure.Az Microsoft.Azure.AztfExport Microsoft.Azure.BatchExplorer Microsoft.Azure.CloudHSM-ClientSDK Microsoft.Azure.ConnectedMachineAgent Microsoft.Azure.CosmosEmulator Microsoft.Azure.DataCLI Microsoft.Azure.DataStudio Microsoft.Azure.FunctionsCoreTools Microsoft.Azure.GuestProxyAgent Microsoft.Azure.IoTExplorer Microsoft.Azure.Kubelogin Microsoft.Azure.QuickReview Microsoft.Azure.StorageExplorer Microsoft.Azure.TemplateAnalyzer Microsoft.Azure.TrustedSigningClientTools Microsoft.AzureCLI Microsoft.AzureMonitorAgent Microsoft.AzureVPNClient Microsoft.BTP Microsoft.Bicep Microsoft.BotFrameworkComposer Microsoft.BotFrameworkEmulator Microsoft.CLRTypesSQLServer.2019 Microsoft.CertifiedToolAzureVM Microsoft.CmdPalAzureExtension Microsoft.CmdPalGitHubExtension Microsoft.DSC Microsoft.DTrace Microsoft.DataMigrationAssistant Microsoft.DataTools.IntegrationServices Microsoft.DebugDiag Microsoft.DefenderForCloud.CLI Microsoft.DependencyAgent Microsoft.DeploymentToolkit Microsoft.DevSkim.CLI.DotNetTool Microsoft.DevSkim.CLI.LibraryPackage Microsoft.DirectAccessCTST Microsoft.DirectX Microsoft.DirectXTex.Texassemble Microsoft.DirectXTex.Texconv Microsoft.DirectXTex.Texdiag Microsoft.DiskSpd Microsoft.DotNet.AspNetCore.10 Microsoft.DotNet.AspNetCore.6 Microsoft.DotNet.AspNetCore.8 Microsoft.DotNet.AspNetCore.9 Microsoft.DotNet.DesktopRuntime.10 Microsoft.DotNet.DesktopRuntime.6 Microsoft.DotNet.DesktopRuntime.8 Microsoft.DotNet.DesktopRuntime.9 Microsoft.DotNet.Framework.DeveloperPack.4.6 Microsoft.DotNet.Framework.DeveloperPack_4 Microsoft.DotNet.Framework.Runtime Microsoft.DotNet.HostingBundle.10 Microsoft.DotNet.HostingBundle.6 Microsoft.DotNet.HostingBundle.8 Microsoft.DotNet.HostingBundle.9 Microsoft.DotNet.RepairTool Microsoft.DotNet.Runtime.10 Microsoft.DotNet.Runtime.6 Microsoft.DotNet.Runtime.8 Microsoft.DotNet.Runtime.9 Microsoft.DotNet.SDK.10 Microsoft.DotNet.SDK.6 Microsoft.DotNet.SDK.8 Microsoft.DotNet.SDK.9 Microsoft.DotNet.UninstallTool Microsoft.DotNet.dotnet-ef Microsoft.Edge Microsoft.EdgeDriver Microsoft.EdgeWebView2Runtime Microsoft.Edit Microsoft.EnterpriseStateClassify Microsoft.EventLogExpert Microsoft.FRSDiag Microsoft.FSLogix Microsoft.FoundryLocal Microsoft.FuzzyLookupAddExcel Microsoft.GameInput Microsoft.Garnet.DN8 Microsoft.Garnet.DN9 Microsoft.Git Microsoft.GlobalSecureAccessClient Microsoft.HIDTools.Waratah Microsoft.HwpConverter Microsoft.IIS.Compression Microsoft.IIS.ServiceMonitor Microsoft.IIS.URLRewrite Microsoft.IISManagerRemoteAdministration Microsoft.IdFix Microsoft.IntegrationRuntime Microsoft.IntuneWSLPlugin Microsoft.IronPython.3 Microsoft.Kanagawa Microsoft.LAPS Microsoft.LightGBM Microsoft.LingeringObjectLiquidator Microsoft.LogCheetah Microsoft.LogParser Microsoft.M365AgentsPlayground Microsoft.MFCMapi Microsoft.MIDI.FeatureEnablementChecker Microsoft.MIDI.SDK Microsoft.MITT Microsoft.MSIX-Toolkit Microsoft.MSIXCore Microsoft.MSIXPackagingTool Microsoft.MUTT Microsoft.MaliciousSoftwareRemovalTool Microsoft.MediaCreationTool Microsoft.MouseWithoutBorders Microsoft.MouseandKeyboardCenter Microsoft.Ntttcp Microsoft.NuGet Microsoft.OSCDIMG Microsoft.OSConfig Microsoft.Office Microsoft.OfficeDeploymentTool Microsoft.OneDrive Microsoft.OneLakeFileExplorer Microsoft.OneNoteDiagnostics Microsoft.OpenAPI.Hidi Microsoft.OpenAPI.Kiota Microsoft.OpenCLGLVulkanCompatibilityPack Microsoft.OpenJDK.11 Microsoft.OpenJDK.17 Microsoft.OpenJDK.21 Microsoft.OpenJDK.25 Microsoft.PICT Microsoft.PIX Microsoft.Pave Microsoft.PerfView Microsoft.PowerAppsCLI Microsoft.PowerAutomateDesktop Microsoft.PowerAutomateProcessMining Microsoft.PowerBI Microsoft.PowerBIReportBuilder Microsoft.PowerBIReportServer Microsoft.PowerShell Microsoft.PowerToys Microsoft.PrintMetadataTroubleshooter Microsoft.ProfileExplorer Microsoft.ProjectTelescope Microsoft.Promptflow Microsoft.PurviewInformationProtection Microsoft.RMSClient Microsoft.RemoteDesktopClient Microsoft.RemoteDesktopMMRService Microsoft.RemoteHelp Microsoft.ReportBuilder Microsoft.SBOMTool Microsoft.SQLServer.2019.Developer Microsoft.SQLServer.2019.Express Microsoft.SQLServer.2022.Developer Microsoft.SQLServer.2022.Express Microsoft.SQLServer.2025.Developer Microsoft.SQLServer.2025.Express Microsoft.SQLServer.OLEDBDriver Microsoft.SQLServer.RMLUtilities Microsoft.SQLServerManagementStudio Microsoft.SaRACmd Microsoft.SafetyScanner Microsoft.ScreenRecorder Microsoft.SecurityComplianceToolkit.LGPO Microsoft.SecurityComplianceToolkit.PolicyAnalyzer Microsoft.SecurityComplianceToolkit.SetObjectSecurity Microsoft.ServiceFabricRuntime Microsoft.ServiceFabricSDK Microsoft.SetupDiag Microsoft.SmartDump Microsoft.SqlPackage Microsoft.Sqlcmd Microsoft.SurfaceApp Microsoft.SurfaceHubRecoveryTool Microsoft.SymCryptUnitTest Microsoft.Sysinternals.Autologon Microsoft.Sysinternals.Autoruns Microsoft.Sysinternals.BGInfo Microsoft.Sysinternals.Ctrl2Cap Microsoft.Sysinternals.DebugView Microsoft.Sysinternals.Desktops Microsoft.Sysinternals.FindLinks Microsoft.Sysinternals.Handle Microsoft.Sysinternals.MoveFile Microsoft.Sysinternals.PendMoves Microsoft.Sysinternals.ProcessExplorer Microsoft.Sysinternals.ProcessMonitor Microsoft.Sysinternals.RAMMap Microsoft.Sysinternals.RDCMan Microsoft.Sysinternals.RegJump Microsoft.Sysinternals.SDelete Microsoft.Sysinternals.Sigcheck Microsoft.Sysinternals.Strings Microsoft.Sysinternals.Sysmon Microsoft.Sysinternals.TCPView Microsoft.Sysinternals.VMMap Microsoft.Sysinternals.Whois Microsoft.Sysinternals.ZoomIt Microsoft.TeamMate Microsoft.Teams Microsoft.TeamsTxNDI Microsoft.TimeTravelDebugging Microsoft.Tokenizer Microsoft.UI.Xaml.2.7 Microsoft.UI.Xaml.2.8 Microsoft.UpdateAssistant Microsoft.VCLibs.14 Microsoft.VCLibs.Desktop.14 Microsoft.VCRedist.2012.x64 Microsoft.VCRedist.2012.x86 Microsoft.VCRedist.2013.x64 Microsoft.VCRedist.2013.x86 Microsoft.VCRedist.2015+.arm64 Microsoft.VCRedist.2015+.x64 Microsoft.VCRedist.2015+.x86 Microsoft.VSDotNetLogCollect Microsoft.VSIXBootstrapper Microsoft.VSTOR Microsoft.VisioViewer Microsoft.VisualStudio.2022.BuildTools Microsoft.VisualStudio.2022.Enterprise Microsoft.VisualStudio.2022.OnecoreMsvsmon Microsoft.VisualStudio.2022.Professional Microsoft.VisualStudio.2022.RemoteTools Microsoft.VisualStudio.ConfigFinder Microsoft.VisualStudio.Extensions.TypeScript Microsoft.VisualStudio.Locator Microsoft.VisualStudioCode Microsoft.VisualTrueType Microsoft.WSL Microsoft.Wassette Microsoft.WebDeploy Microsoft.Win32ContentPrepTool Microsoft.WinAppCli Microsoft.WinDbg Microsoft.WindowsADK Microsoft.WindowsAdminCenter Microsoft.WindowsApp Microsoft.WindowsAppRuntime.1.5 Microsoft.WindowsAppRuntime.1.6 Microsoft.WindowsAppRuntime.1.7 Microsoft.WindowsAppRuntime.1.8 Microsoft.WindowsApplicationDriver Microsoft.WindowsBusesTracing Microsoft.WindowsCloudIOProtectionDriver Microsoft.WindowsDeviceRecoveryTool Microsoft.WindowsInstallationAssistant Microsoft.WindowsMIDIServicesSDK Microsoft.WindowsPCHealthCheck Microsoft.WindowsSDK.10.0.22000 Microsoft.WindowsSDK.10.0.22621 Microsoft.WindowsSDK.10.0.26100 Microsoft.WindowsSDK.10.0.28000 Microsoft.WindowsTerminal Microsoft.WindowsVirtualDesktopAgent Microsoft.WindowsVirtualDesktopBootloader Microsoft.WindowsWDK.10.0.22000 Microsoft.WindowsWDK.10.0.22621 Microsoft.WindowsWDK.10.0.26100 Microsoft.WingetCreate Microsoft.XMLNotepad Microsoft.bitsmanager Microsoft.err Microsoft.etl2pcapng Microsoft.msodbcsql.17 Microsoft.msodbcsql.18 Microsoft.quicreach Microsoft.winfile Telerik.Fiddler.Classic WiresharkFoundation.Stratoshark WiresharkFoundation.Wireshark -f json > generated/rules.json

# 產生 Azure CLI 部署指令
python main.py GitHub.Copilot GitHub.GitHubDesktop GitHub.GitLFS GitHub.cli GitHub.git-sizer Microsoft.AIShell Microsoft.AKSdesktop Microsoft.APM Microsoft.ASRTestTool Microsoft.AccountLockoutStatus Microsoft.AdministrativeTemplates Microsoft.AmendmentAppWordService Microsoft.AppControlPolicyWizard Microsoft.AppInstaller Microsoft.AppInstallerFileBuilder Microsoft.AppLockerPolicyConverter Microsoft.ApplicationInspector Microsoft.Aspire Microsoft.Azd Microsoft.Azure.ADConnectSyncDocumenter Microsoft.Azure.AZCopy.10 Microsoft.Azure.ArtifactSigningClientTools Microsoft.Azure.Auth Microsoft.Azure.Az Microsoft.Azure.AztfExport Microsoft.Azure.BatchExplorer Microsoft.Azure.CloudHSM-ClientSDK Microsoft.Azure.ConnectedMachineAgent Microsoft.Azure.CosmosEmulator Microsoft.Azure.DataCLI Microsoft.Azure.DataStudio Microsoft.Azure.FunctionsCoreTools Microsoft.Azure.GuestProxyAgent Microsoft.Azure.IoTExplorer Microsoft.Azure.Kubelogin Microsoft.Azure.QuickReview Microsoft.Azure.StorageExplorer Microsoft.Azure.TemplateAnalyzer Microsoft.Azure.TrustedSigningClientTools Microsoft.AzureCLI Microsoft.AzureMonitorAgent Microsoft.AzureVPNClient Microsoft.BTP Microsoft.Bicep Microsoft.BotFrameworkComposer Microsoft.BotFrameworkEmulator Microsoft.CLRTypesSQLServer.2019 Microsoft.CertifiedToolAzureVM Microsoft.CmdPalAzureExtension Microsoft.CmdPalGitHubExtension Microsoft.DSC Microsoft.DTrace Microsoft.DataMigrationAssistant Microsoft.DataTools.IntegrationServices Microsoft.DebugDiag Microsoft.DefenderForCloud.CLI Microsoft.DependencyAgent Microsoft.DeploymentToolkit Microsoft.DevSkim.CLI.DotNetTool Microsoft.DevSkim.CLI.LibraryPackage Microsoft.DirectAccessCTST Microsoft.DirectX Microsoft.DirectXTex.Texassemble Microsoft.DirectXTex.Texconv Microsoft.DirectXTex.Texdiag Microsoft.DiskSpd Microsoft.DotNet.AspNetCore.10 Microsoft.DotNet.AspNetCore.6 Microsoft.DotNet.AspNetCore.8 Microsoft.DotNet.AspNetCore.9 Microsoft.DotNet.DesktopRuntime.10 Microsoft.DotNet.DesktopRuntime.6 Microsoft.DotNet.DesktopRuntime.8 Microsoft.DotNet.DesktopRuntime.9 Microsoft.DotNet.Framework.DeveloperPack.4.6 Microsoft.DotNet.Framework.DeveloperPack_4 Microsoft.DotNet.Framework.Runtime Microsoft.DotNet.HostingBundle.10 Microsoft.DotNet.HostingBundle.6 Microsoft.DotNet.HostingBundle.8 Microsoft.DotNet.HostingBundle.9 Microsoft.DotNet.RepairTool Microsoft.DotNet.Runtime.10 Microsoft.DotNet.Runtime.6 Microsoft.DotNet.Runtime.8 Microsoft.DotNet.Runtime.9 Microsoft.DotNet.SDK.10 Microsoft.DotNet.SDK.6 Microsoft.DotNet.SDK.8 Microsoft.DotNet.SDK.9 Microsoft.DotNet.UninstallTool Microsoft.DotNet.dotnet-ef Microsoft.Edge Microsoft.EdgeDriver Microsoft.EdgeWebView2Runtime Microsoft.Edit Microsoft.EnterpriseStateClassify Microsoft.EventLogExpert Microsoft.FRSDiag Microsoft.FSLogix Microsoft.FoundryLocal Microsoft.FuzzyLookupAddExcel Microsoft.GameInput Microsoft.Garnet.DN8 Microsoft.Garnet.DN9 Microsoft.Git Microsoft.GlobalSecureAccessClient Microsoft.HIDTools.Waratah Microsoft.HwpConverter Microsoft.IIS.Compression Microsoft.IIS.ServiceMonitor Microsoft.IIS.URLRewrite Microsoft.IISManagerRemoteAdministration Microsoft.IdFix Microsoft.IntegrationRuntime Microsoft.IntuneWSLPlugin Microsoft.IronPython.3 Microsoft.Kanagawa Microsoft.LAPS Microsoft.LightGBM Microsoft.LingeringObjectLiquidator Microsoft.LogCheetah Microsoft.LogParser Microsoft.M365AgentsPlayground Microsoft.MFCMapi Microsoft.MIDI.FeatureEnablementChecker Microsoft.MIDI.SDK Microsoft.MITT Microsoft.MSIX-Toolkit Microsoft.MSIXCore Microsoft.MSIXPackagingTool Microsoft.MUTT Microsoft.MaliciousSoftwareRemovalTool Microsoft.MediaCreationTool Microsoft.MouseWithoutBorders Microsoft.MouseandKeyboardCenter Microsoft.Ntttcp Microsoft.NuGet Microsoft.OSCDIMG Microsoft.OSConfig Microsoft.Office Microsoft.OfficeDeploymentTool Microsoft.OneDrive Microsoft.OneLakeFileExplorer Microsoft.OneNoteDiagnostics Microsoft.OpenAPI.Hidi Microsoft.OpenAPI.Kiota Microsoft.OpenCLGLVulkanCompatibilityPack Microsoft.OpenJDK.11 Microsoft.OpenJDK.17 Microsoft.OpenJDK.21 Microsoft.OpenJDK.25 Microsoft.PICT Microsoft.PIX Microsoft.Pave Microsoft.PerfView Microsoft.PowerAppsCLI Microsoft.PowerAutomateDesktop Microsoft.PowerAutomateProcessMining Microsoft.PowerBI Microsoft.PowerBIReportBuilder Microsoft.PowerBIReportServer Microsoft.PowerShell Microsoft.PowerToys Microsoft.PrintMetadataTroubleshooter Microsoft.ProfileExplorer Microsoft.ProjectTelescope Microsoft.Promptflow Microsoft.PurviewInformationProtection Microsoft.RMSClient Microsoft.RemoteDesktopClient Microsoft.RemoteDesktopMMRService Microsoft.RemoteHelp Microsoft.ReportBuilder Microsoft.SBOMTool Microsoft.SQLServer.2019.Developer Microsoft.SQLServer.2019.Express Microsoft.SQLServer.2022.Developer Microsoft.SQLServer.2022.Express Microsoft.SQLServer.2025.Developer Microsoft.SQLServer.2025.Express Microsoft.SQLServer.OLEDBDriver Microsoft.SQLServer.RMLUtilities Microsoft.SQLServerManagementStudio Microsoft.SaRACmd Microsoft.SafetyScanner Microsoft.ScreenRecorder Microsoft.SecurityComplianceToolkit.LGPO Microsoft.SecurityComplianceToolkit.PolicyAnalyzer Microsoft.SecurityComplianceToolkit.SetObjectSecurity Microsoft.ServiceFabricRuntime Microsoft.ServiceFabricSDK Microsoft.SetupDiag Microsoft.SmartDump Microsoft.SqlPackage Microsoft.Sqlcmd Microsoft.SurfaceApp Microsoft.SurfaceHubRecoveryTool Microsoft.SymCryptUnitTest Microsoft.Sysinternals.Autologon Microsoft.Sysinternals.Autoruns Microsoft.Sysinternals.BGInfo Microsoft.Sysinternals.Ctrl2Cap Microsoft.Sysinternals.DebugView Microsoft.Sysinternals.Desktops Microsoft.Sysinternals.FindLinks Microsoft.Sysinternals.Handle Microsoft.Sysinternals.MoveFile Microsoft.Sysinternals.PendMoves Microsoft.Sysinternals.ProcessExplorer Microsoft.Sysinternals.ProcessMonitor Microsoft.Sysinternals.RAMMap Microsoft.Sysinternals.RDCMan Microsoft.Sysinternals.RegJump Microsoft.Sysinternals.SDelete Microsoft.Sysinternals.Sigcheck Microsoft.Sysinternals.Strings Microsoft.Sysinternals.Sysmon Microsoft.Sysinternals.TCPView Microsoft.Sysinternals.VMMap Microsoft.Sysinternals.Whois Microsoft.Sysinternals.ZoomIt Microsoft.TeamMate Microsoft.Teams Microsoft.TeamsTxNDI Microsoft.TimeTravelDebugging Microsoft.Tokenizer Microsoft.UI.Xaml.2.7 Microsoft.UI.Xaml.2.8 Microsoft.UpdateAssistant Microsoft.VCLibs.14 Microsoft.VCLibs.Desktop.14 Microsoft.VCRedist.2012.x64 Microsoft.VCRedist.2012.x86 Microsoft.VCRedist.2013.x64 Microsoft.VCRedist.2013.x86 Microsoft.VCRedist.2015+.arm64 Microsoft.VCRedist.2015+.x64 Microsoft.VCRedist.2015+.x86 Microsoft.VSDotNetLogCollect Microsoft.VSIXBootstrapper Microsoft.VSTOR Microsoft.VisioViewer Microsoft.VisualStudio.2022.BuildTools Microsoft.VisualStudio.2022.Enterprise Microsoft.VisualStudio.2022.OnecoreMsvsmon Microsoft.VisualStudio.2022.Professional Microsoft.VisualStudio.2022.RemoteTools Microsoft.VisualStudio.ConfigFinder Microsoft.VisualStudio.Extensions.TypeScript Microsoft.VisualStudio.Locator Microsoft.VisualStudioCode Microsoft.VisualTrueType Microsoft.WSL Microsoft.Wassette Microsoft.WebDeploy Microsoft.Win32ContentPrepTool Microsoft.WinAppCli Microsoft.WinDbg Microsoft.WindowsADK Microsoft.WindowsAdminCenter Microsoft.WindowsApp Microsoft.WindowsAppRuntime.1.5 Microsoft.WindowsAppRuntime.1.6 Microsoft.WindowsAppRuntime.1.7 Microsoft.WindowsAppRuntime.1.8 Microsoft.WindowsApplicationDriver Microsoft.WindowsBusesTracing Microsoft.WindowsCloudIOProtectionDriver Microsoft.WindowsDeviceRecoveryTool Microsoft.WindowsInstallationAssistant Microsoft.WindowsMIDIServicesSDK Microsoft.WindowsPCHealthCheck Microsoft.WindowsSDK.10.0.22000 Microsoft.WindowsSDK.10.0.22621 Microsoft.WindowsSDK.10.0.26100 Microsoft.WindowsSDK.10.0.28000 Microsoft.WindowsTerminal Microsoft.WindowsVirtualDesktopAgent Microsoft.WindowsVirtualDesktopBootloader Microsoft.WindowsWDK.10.0.22000 Microsoft.WindowsWDK.10.0.22621 Microsoft.WindowsWDK.10.0.26100 Microsoft.WingetCreate Microsoft.XMLNotepad Microsoft.bitsmanager Microsoft.err Microsoft.etl2pcapng Microsoft.msodbcsql.17 Microsoft.msodbcsql.18 Microsoft.quicreach Microsoft.winfile Telerik.Fiddler.Classic WiresharkFoundation.Stratoshark WiresharkFoundation.Wireshark -f cli > generated/deploy.sh
```

---

## 📋 套件摘要

| 套件識別碼 | 版本 | 安裝檔數 | 涉及 FQDN | 規則名稱（Path） | 規則名稱（FQDN） |
|---|---|---|---|---|---|
| `GitHub.Copilot` | 1.0.34 | 2 | 2 | `winget-github-copilot-path` | `winget-github-copilot-fqdn` |
| `GitHub.GitHubDesktop` | 3.5.8 | 4 | 1 | `winget-github-githubdesktop-path` | `winget-github-githubdesktop-fqdn` |
| `GitHub.GitLFS` | 3.7.1 | 1 | 2 | `winget-github-gitlfs-path` | `winget-github-gitlfs-fqdn` |
| `GitHub.cli` | 2.92.0 | 6 | 2 | `winget-github-cli-path` | `winget-github-cli-fqdn` |
| `GitHub.git-sizer` | 1.5.0 | 2 | 2 | `winget-github-git-sizer-path` | `winget-github-git-sizer-fqdn` |
| `Microsoft.AIShell` | 1.0.0-preview.8 | 3 | 2 | `winget-microsoft-aishell-path` | `winget-microsoft-aishell-fqdn` |
| `Microsoft.AKSdesktop` | 0.1.0-alpha | 1 | 2 | `winget-microsoft-aksdesktop-path` | `winget-microsoft-aksdesktop-fqdn` |
| `Microsoft.APM` | 0.11.0 | 1 | 2 | `winget-microsoft-apm-path` | `winget-microsoft-apm-fqdn` |
| `Microsoft.ASRTestTool` | 4.13.17600.1000 | 1 | 1 | `winget-microsoft-asrtesttool-path` | `winget-microsoft-asrtesttool-fqdn` |
| `Microsoft.AccountLockoutStatus` | 1.0.0.60 | 1 | 1 | `winget-microsoft-accountlockoutstatus-path` | `winget-microsoft-accountlockoutstatus-fqdn` |
| `Microsoft.AdministrativeTemplates` | 11.25H2 | 1 | 1 | `winget-microsoft-administrativetemplates-path` | `winget-microsoft-administrativetemplates-fqdn` |
| `Microsoft.AmendmentAppWordService` | 4.2.0.0 | 1 | 1 | `winget-microsoft-amendmentappwordservice-path` | `winget-microsoft-amendmentappwordservice-fqdn` |
| `Microsoft.AppControlPolicyWizard` | 2.6.0.1 | 1 | 1 | `winget-microsoft-appcontrolpolicywizard-path` | `winget-microsoft-appcontrolpolicywizard-fqdn` |
| `Microsoft.AppInstaller` | 1.27.470.0 | 1 | 2 | `winget-microsoft-appinstaller-path` | `winget-microsoft-appinstaller-fqdn` |
| `Microsoft.AppInstallerFileBuilder` | 1.2020.221.0 | 1 | 2 | `winget-microsoft-appinstallerfilebuilder-path` | `winget-microsoft-appinstallerfilebuilder-fqdn` |
| `Microsoft.AppLockerPolicyConverter` | 2.0.0.0 | 1 | 2 | `winget-microsoft-applockerpolicyconverter-path` | `winget-microsoft-applockerpolicyconverter-fqdn` |
| `Microsoft.ApplicationInspector` | 1.9.55 | 1 | 2 | `winget-microsoft-applicationinspector-path` | `winget-microsoft-applicationinspector-fqdn` |
| `Microsoft.Aspire` | 13.1.3 | 2 | 1 | `winget-microsoft-aspire-path` | `winget-microsoft-aspire-fqdn` |
| `Microsoft.Azd` | 1.24.300 | 1 | 2 | `winget-microsoft-azd-path` | `winget-microsoft-azd-fqdn` |
| `Microsoft.Azure.ADConnectSyncDocumenter` | 1.20.0917.0 | 1 | 2 | `winget-microsoft-azure-adconnectsyncdocumenter-path` | `winget-microsoft-azure-adconnectsyncdocumenter-fqdn` |
| `Microsoft.Azure.AZCopy.10` | 10.32.3 | 3 | 2 | `winget-microsoft-azure-azcopy-10-path` | `winget-microsoft-azure-azcopy-10-fqdn` |
| `Microsoft.Azure.ArtifactSigningClientTools` | 0.1.128 | 1 | 1 | `winget-microsoft-azure-artifactsigningclienttools-path` | `winget-microsoft-azure-artifactsigningclienttools-fqdn` |
| `Microsoft.Azure.Auth` | 0.9.2 | 1 | 2 | `winget-microsoft-azure-auth-path` | `winget-microsoft-azure-auth-fqdn` |
| `Microsoft.Azure.Az` | 15.2.0.40510 | 1 | 2 | `winget-microsoft-azure-az-path` | `winget-microsoft-azure-az-fqdn` |
| `Microsoft.Azure.AztfExport` | 0.19.0 | 2 | 2 | `winget-microsoft-azure-aztfexport-path` | `winget-microsoft-azure-aztfexport-fqdn` |
| `Microsoft.Azure.BatchExplorer` | 2.23.0 | 1 | 2 | `winget-microsoft-azure-batchexplorer-path` | `winget-microsoft-azure-batchexplorer-fqdn` |
| `Microsoft.Azure.CloudHSM-ClientSDK` | 2.0.2.2 | 1 | 1 | `winget-microsoft-azure-cloudhsm-clientsdk-path` | `winget-microsoft-azure-cloudhsm-clientsdk-fqdn` |
| `Microsoft.Azure.ConnectedMachineAgent` | 1.63.03384.2896 | 1 | 1 | `winget-microsoft-azure-connectedmachineagent-path` | `winget-microsoft-azure-connectedmachineagent-fqdn` |
| `Microsoft.Azure.CosmosEmulator` | 2.14.27 | 1 | 1 | `winget-microsoft-azure-cosmosemulator-path` | `winget-microsoft-azure-cosmosemulator-fqdn` |
| `Microsoft.Azure.DataCLI` | 20.3.14 | 1 | 1 | `winget-microsoft-azure-datacli-path` | `winget-microsoft-azure-datacli-fqdn` |
| `Microsoft.Azure.DataStudio` | 1.52.0 | 4 | 1 | `winget-microsoft-azure-datastudio-path` | `winget-microsoft-azure-datastudio-fqdn` |
| `Microsoft.Azure.FunctionsCoreTools` | 4.10.0 | 5 | 2 | `winget-microsoft-azure-functionscoretools-path` | `winget-microsoft-azure-functionscoretools-fqdn` |
| `Microsoft.Azure.GuestProxyAgent` | 1.0.39 | 2 | 2 | `winget-microsoft-azure-guestproxyagent-path` | `winget-microsoft-azure-guestproxyagent-fqdn` |
| `Microsoft.Azure.IoTExplorer` | 0.15.12 | 1 | 2 | `winget-microsoft-azure-iotexplorer-path` | `winget-microsoft-azure-iotexplorer-fqdn` |
| `Microsoft.Azure.Kubelogin` | 0.2.13 | 1 | 1 | `winget-microsoft-azure-kubelogin-path` | `winget-microsoft-azure-kubelogin-fqdn` |
| `Microsoft.Azure.QuickReview` | 3.1.2 | 1 | 2 | `winget-microsoft-azure-quickreview-path` | `winget-microsoft-azure-quickreview-fqdn` |
| `Microsoft.Azure.StorageExplorer` | 1.43.0 | 2 | 2 | `winget-microsoft-azure-storageexplorer-path` | `winget-microsoft-azure-storageexplorer-fqdn` |
| `Microsoft.Azure.TemplateAnalyzer` | 0.8.5 | 2 | 2 | `winget-microsoft-azure-templateanalyzer-path` | `winget-microsoft-azure-templateanalyzer-fqdn` |
| `Microsoft.Azure.TrustedSigningClientTools` | 0.1.127 | 1 | 1 | `winget-microsoft-azure-trustedsigningclienttools-path` | `winget-microsoft-azure-trustedsigningclienttools-fqdn` |
| `Microsoft.AzureCLI` | 2.85.0 | 2 | 1 | `winget-microsoft-azurecli-path` | `winget-microsoft-azurecli-fqdn` |
| `Microsoft.AzureMonitorAgent` | 1.41.0.0 | 1 | 1 | `winget-microsoft-azuremonitoragent-path` | `winget-microsoft-azuremonitoragent-fqdn` |
| `Microsoft.AzureVPNClient` | 4.0.5.0 | 1 | 1 | `winget-microsoft-azurevpnclient-path` | `winget-microsoft-azurevpnclient-fqdn` |
| `Microsoft.BTP` | 1.14.0 | 1 | 1 | `winget-microsoft-btp-path` | `winget-microsoft-btp-fqdn` |
| `Microsoft.Bicep` | 0.42.1 | 3 | 2 | `winget-microsoft-bicep-path` | `winget-microsoft-bicep-fqdn` |
| `Microsoft.BotFrameworkComposer` | 2.1.2 | 1 | 2 | `winget-microsoft-botframeworkcomposer-path` | `winget-microsoft-botframeworkcomposer-fqdn` |
| `Microsoft.BotFrameworkEmulator` | 4.15.1 | 1 | 2 | `winget-microsoft-botframeworkemulator-path` | `winget-microsoft-botframeworkemulator-fqdn` |
| `Microsoft.CLRTypesSQLServer.2019` | 15.0.2000.5 | 1 | 1 | `winget-microsoft-clrtypessqlserver-2019-path` | `winget-microsoft-clrtypessqlserver-2019-fqdn` |
| `Microsoft.CertifiedToolAzureVM` | 1.6 | 1 | 1 | `winget-microsoft-certifiedtoolazurevm-path` | `winget-microsoft-certifiedtoolazurevm-fqdn` |
| `Microsoft.CmdPalAzureExtension` | 0.200.174.0 | 2 | 2 | `winget-microsoft-cmdpalazureextension-path` | `winget-microsoft-cmdpalazureextension-fqdn` |
| `Microsoft.CmdPalGitHubExtension` | 0.103.178.0 | 2 | 2 | `winget-microsoft-cmdpalgithubextension-path` | `winget-microsoft-cmdpalgithubextension-fqdn` |
| `Microsoft.DSC` | 3.1.3 | 3 | 2 | `winget-microsoft-dsc-path` | `winget-microsoft-dsc-fqdn` |
| `Microsoft.DTrace` | 2.0 | 2 | 1 | `winget-microsoft-dtrace-path` | `winget-microsoft-dtrace-fqdn` |
| `Microsoft.DataMigrationAssistant` | 5.8.5973.1 | 1 | 1 | `winget-microsoft-datamigrationassistant-path` | `winget-microsoft-datamigrationassistant-fqdn` |
| `Microsoft.DataTools.IntegrationServices` | 17.0.1010.2 | 1 | 1 | `winget-microsoft-datatools-integrationservices-path` | `winget-microsoft-datatools-integrationservices-fqdn` |
| `Microsoft.DebugDiag` | 2.3.2.11 | 1 | 1 | `winget-microsoft-debugdiag-path` | `winget-microsoft-debugdiag-fqdn` |
| `Microsoft.DefenderForCloud.CLI` | 2.0.03334.114 | 3 | 1 | `winget-microsoft-defenderforcloud-cli-path` | `winget-microsoft-defenderforcloud-cli-fqdn` |
| `Microsoft.DependencyAgent` | 9.10.18 | 1 | 1 | `winget-microsoft-dependencyagent-path` | `winget-microsoft-dependencyagent-fqdn` |
| `Microsoft.DeploymentToolkit` | 6.3.8456.1000 | 2 | 1 | `winget-microsoft-deploymenttoolkit-path` | `winget-microsoft-deploymenttoolkit-fqdn` |
| `Microsoft.DevSkim.CLI.DotNetTool` | 1.0.59 | 1 | 2 | `winget-microsoft-devskim-cli-dotnettool-path` | `winget-microsoft-devskim-cli-dotnettool-fqdn` |
| `Microsoft.DevSkim.CLI.LibraryPackage` | 1.0.59 | 1 | 2 | `winget-microsoft-devskim-cli-librarypackage-path` | `winget-microsoft-devskim-cli-librarypackage-fqdn` |
| `Microsoft.DirectAccessCTST` | 1.4.4.0 | 1 | 1 | `winget-microsoft-directaccessctst-path` | `winget-microsoft-directaccessctst-fqdn` |
| `Microsoft.DirectX` | 9.29.1974.0 | 3 | 1 | `winget-microsoft-directx-path` | `winget-microsoft-directx-fqdn` |
| `Microsoft.DirectXTex.Texassemble` | 2026.3.31 | 2 | 2 | `winget-microsoft-directxtex-texassemble-path` | `winget-microsoft-directxtex-texassemble-fqdn` |
| `Microsoft.DirectXTex.Texconv` | 2026.3.31 | 2 | 2 | `winget-microsoft-directxtex-texconv-path` | `winget-microsoft-directxtex-texconv-fqdn` |
| `Microsoft.DirectXTex.Texdiag` | 2026.3.31 | 2 | 2 | `winget-microsoft-directxtex-texdiag-path` | `winget-microsoft-directxtex-texdiag-fqdn` |
| `Microsoft.DiskSpd` | 2.2 | 1 | 2 | `winget-microsoft-diskspd-path` | `winget-microsoft-diskspd-fqdn` |
| `Microsoft.DotNet.AspNetCore.10` | 10.0.7 | 3 | 1 | `winget-microsoft-dotnet-aspnetcore-10-path` | `winget-microsoft-dotnet-aspnetcore-10-fqdn` |
| `Microsoft.DotNet.AspNetCore.6` | 6.0.36 | 2 | 1 | `winget-microsoft-dotnet-aspnetcore-6-path` | `winget-microsoft-dotnet-aspnetcore-6-fqdn` |
| `Microsoft.DotNet.AspNetCore.8` | 8.0.26 | 3 | 1 | `winget-microsoft-dotnet-aspnetcore-8-path` | `winget-microsoft-dotnet-aspnetcore-8-fqdn` |
| `Microsoft.DotNet.AspNetCore.9` | 9.0.15 | 3 | 1 | `winget-microsoft-dotnet-aspnetcore-9-path` | `winget-microsoft-dotnet-aspnetcore-9-fqdn` |
| `Microsoft.DotNet.DesktopRuntime.10` | 10.0.7 | 3 | 1 | `winget-microsoft-dotnet-desktopruntime-10-path` | `winget-microsoft-dotnet-desktopruntime-10-fqdn` |
| `Microsoft.DotNet.DesktopRuntime.6` | 6.0.36 | 3 | 1 | `winget-microsoft-dotnet-desktopruntime-6-path` | `winget-microsoft-dotnet-desktopruntime-6-fqdn` |
| `Microsoft.DotNet.DesktopRuntime.8` | 8.0.26 | 3 | 1 | `winget-microsoft-dotnet-desktopruntime-8-path` | `winget-microsoft-dotnet-desktopruntime-8-fqdn` |
| `Microsoft.DotNet.DesktopRuntime.9` | 9.0.15 | 3 | 1 | `winget-microsoft-dotnet-desktopruntime-9-path` | `winget-microsoft-dotnet-desktopruntime-9-fqdn` |
| `Microsoft.DotNet.Framework.DeveloperPack.4.6` | 4.6.2 | 1 | 1 | `winget-microsoft-dotnet-framework-developerpack-4-6-path` | `winget-microsoft-dotnet-framework-developerpack-4-6-fqdn` |
| `Microsoft.DotNet.Framework.DeveloperPack_4` | 4.8.1 | 1 | 1 | `winget-microsoft-dotnet-framework-developerpack_4-path` | `winget-microsoft-dotnet-framework-developerpack_4-fqdn` |
| `Microsoft.DotNet.Framework.Runtime` | 4.8.1 | 1 | 1 | `winget-microsoft-dotnet-framework-runtime-path` | `winget-microsoft-dotnet-framework-runtime-fqdn` |
| `Microsoft.DotNet.HostingBundle.10` | 10.0.7 | 1 | 1 | `winget-microsoft-dotnet-hostingbundle-10-path` | `winget-microsoft-dotnet-hostingbundle-10-fqdn` |
| `Microsoft.DotNet.HostingBundle.6` | 6.0.36 | 1 | 1 | `winget-microsoft-dotnet-hostingbundle-6-path` | `winget-microsoft-dotnet-hostingbundle-6-fqdn` |
| `Microsoft.DotNet.HostingBundle.8` | 8.0.26 | 1 | 1 | `winget-microsoft-dotnet-hostingbundle-8-path` | `winget-microsoft-dotnet-hostingbundle-8-fqdn` |
| `Microsoft.DotNet.HostingBundle.9` | 9.0.15 | 1 | 1 | `winget-microsoft-dotnet-hostingbundle-9-path` | `winget-microsoft-dotnet-hostingbundle-9-fqdn` |
| `Microsoft.DotNet.RepairTool` | 1.4 | 1 | 1 | `winget-microsoft-dotnet-repairtool-path` | `winget-microsoft-dotnet-repairtool-fqdn` |
| `Microsoft.DotNet.Runtime.10` | 10.0.7 | 3 | 1 | `winget-microsoft-dotnet-runtime-10-path` | `winget-microsoft-dotnet-runtime-10-fqdn` |
| `Microsoft.DotNet.Runtime.6` | 6.0.36 | 3 | 1 | `winget-microsoft-dotnet-runtime-6-path` | `winget-microsoft-dotnet-runtime-6-fqdn` |
| `Microsoft.DotNet.Runtime.8` | 8.0.26 | 3 | 1 | `winget-microsoft-dotnet-runtime-8-path` | `winget-microsoft-dotnet-runtime-8-fqdn` |
| `Microsoft.DotNet.Runtime.9` | 9.0.15 | 3 | 1 | `winget-microsoft-dotnet-runtime-9-path` | `winget-microsoft-dotnet-runtime-9-fqdn` |
| `Microsoft.DotNet.SDK.10` | 10.0.203 | 3 | 1 | `winget-microsoft-dotnet-sdk-10-path` | `winget-microsoft-dotnet-sdk-10-fqdn` |
| `Microsoft.DotNet.SDK.6` | 6.0.428 | 3 | 1 | `winget-microsoft-dotnet-sdk-6-path` | `winget-microsoft-dotnet-sdk-6-fqdn` |
| `Microsoft.DotNet.SDK.8` | 8.0.420 | 3 | 1 | `winget-microsoft-dotnet-sdk-8-path` | `winget-microsoft-dotnet-sdk-8-fqdn` |
| `Microsoft.DotNet.SDK.9` | 9.0.313 | 3 | 1 | `winget-microsoft-dotnet-sdk-9-path` | `winget-microsoft-dotnet-sdk-9-fqdn` |
| `Microsoft.DotNet.UninstallTool` | 1.7.661902 | 1 | 2 | `winget-microsoft-dotnet-uninstalltool-path` | `winget-microsoft-dotnet-uninstalltool-fqdn` |
| `Microsoft.DotNet.dotnet-ef` | 10.0.7 | 1 | 1 | `winget-microsoft-dotnet-dotnet-ef-path` | `winget-microsoft-dotnet-dotnet-ef-fqdn` |
| `Microsoft.Edge` | 147.0.3912.86 | 3 | 1 | `winget-microsoft-edge-path` | `winget-microsoft-edge-fqdn` |
| `Microsoft.EdgeDriver` | 147.0.3912.86 | 3 | 1 | `winget-microsoft-edgedriver-path` | `winget-microsoft-edgedriver-fqdn` |
| `Microsoft.EdgeWebView2Runtime` | 147.0.3912.98 | 3 | 1 | `winget-microsoft-edgewebview2runtime-path` | `winget-microsoft-edgewebview2runtime-fqdn` |
| `Microsoft.Edit` | 2.0.0 | 2 | 2 | `winget-microsoft-edit-path` | `winget-microsoft-edit-fqdn` |
| `Microsoft.EnterpriseStateClassify` | 1.0 | 1 | 2 | `winget-microsoft-enterprisestateclassify-path` | `winget-microsoft-enterprisestateclassify-fqdn` |
| `Microsoft.EventLogExpert` | 25.12.11.1105 | 1 | 2 | `winget-microsoft-eventlogexpert-path` | `winget-microsoft-eventlogexpert-fqdn` |
| `Microsoft.FRSDiag` | 1.7 | 1 | 1 | `winget-microsoft-frsdiag-path` | `winget-microsoft-frsdiag-fqdn` |
| `Microsoft.FSLogix` | 3.26.126.19110 | 1 | 1 | `winget-microsoft-fslogix-path` | `winget-microsoft-fslogix-fqdn` |
| `Microsoft.FoundryLocal` | 0.8.119.102 | 2 | 1 | `winget-microsoft-foundrylocal-path` | `winget-microsoft-foundrylocal-fqdn` |
| `Microsoft.FuzzyLookupAddExcel` | 1.3.0.0 | 1 | 1 | `winget-microsoft-fuzzylookupaddexcel-path` | `winget-microsoft-fuzzylookupaddexcel-fqdn` |
| `Microsoft.GameInput` | 3.3.195.0 | 1 | 2 | `winget-microsoft-gameinput-path` | `winget-microsoft-gameinput-fqdn` |
| `Microsoft.Garnet.DN8` | 1.0.83 | 2 | 2 | `winget-microsoft-garnet-dn8-path` | `winget-microsoft-garnet-dn8-fqdn` |
| `Microsoft.Garnet.DN9` | 1.0.83 | 2 | 2 | `winget-microsoft-garnet-dn9-path` | `winget-microsoft-garnet-dn9-fqdn` |
| `Microsoft.Git` | 2.53.0.0.7 | 2 | 2 | `winget-microsoft-git-path` | `winget-microsoft-git-fqdn` |
| `Microsoft.GlobalSecureAccessClient` | 2.26.108 | 1 | 1 | `winget-microsoft-globalsecureaccessclient-path` | `winget-microsoft-globalsecureaccessclient-fqdn` |
| `Microsoft.HIDTools.Waratah` | 1.90 | 1 | 2 | `winget-microsoft-hidtools-waratah-path` | `winget-microsoft-hidtools-waratah-fqdn` |
| `Microsoft.HwpConverter` | 15.0.4454.1506 | 4 | 1 | `winget-microsoft-hwpconverter-path` | `winget-microsoft-hwpconverter-fqdn` |
| `Microsoft.IIS.Compression` | 1.0.06502 | 2 | 1 | `winget-microsoft-iis-compression-path` | `winget-microsoft-iis-compression-fqdn` |
| `Microsoft.IIS.ServiceMonitor` | 2.0.1.10 | 1 | 2 | `winget-microsoft-iis-servicemonitor-path` | `winget-microsoft-iis-servicemonitor-fqdn` |
| `Microsoft.IIS.URLRewrite` | 7.2.1993 | 2 | 1 | `winget-microsoft-iis-urlrewrite-path` | `winget-microsoft-iis-urlrewrite-fqdn` |
| `Microsoft.IISManagerRemoteAdministration` | 1.2 | 2 | 1 | `winget-microsoft-iismanagerremoteadministration-path` | `winget-microsoft-iismanagerremoteadministration-fqdn` |
| `Microsoft.IdFix` | 2.6.0.3 | 1 | 2 | `winget-microsoft-idfix-path` | `winget-microsoft-idfix-fqdn` |
| `Microsoft.IntegrationRuntime` | 5.65.9593.1 | 1 | 1 | `winget-microsoft-integrationruntime-path` | `winget-microsoft-integrationruntime-fqdn` |
| `Microsoft.IntuneWSLPlugin` | 1.25.4.0 | 1 | 2 | `winget-microsoft-intunewslplugin-path` | `winget-microsoft-intunewslplugin-fqdn` |
| `Microsoft.IronPython.3` | 3.4.2.1000 | 1 | 2 | `winget-microsoft-ironpython-3-path` | `winget-microsoft-ironpython-3-fqdn` |
| `Microsoft.Kanagawa` | 1.2.0 | 1 | 2 | `winget-microsoft-kanagawa-path` | `winget-microsoft-kanagawa-fqdn` |
| `Microsoft.LAPS` | 6.2.0.0 | 3 | 1 | `winget-microsoft-laps-path` | `winget-microsoft-laps-fqdn` |
| `Microsoft.LightGBM` | 4.6.0 | 1 | 2 | `winget-microsoft-lightgbm-path` | `winget-microsoft-lightgbm-fqdn` |
| `Microsoft.LingeringObjectLiquidator` | 2.0.21 | 1 | 1 | `winget-microsoft-lingeringobjectliquidator-path` | `winget-microsoft-lingeringobjectliquidator-fqdn` |
| `Microsoft.LogCheetah` | 1.0.0 | 1 | 2 | `winget-microsoft-logcheetah-path` | `winget-microsoft-logcheetah-fqdn` |
| `Microsoft.LogParser` | 2.2.10 | 1 | 1 | `winget-microsoft-logparser-path` | `winget-microsoft-logparser-fqdn` |
| `Microsoft.M365AgentsPlayground` | 0.2.24 | 1 | 2 | `winget-microsoft-m365agentsplayground-path` | `winget-microsoft-m365agentsplayground-fqdn` |
| `Microsoft.MFCMapi` | 26.0.26111.02 | 2 | 2 | `winget-microsoft-mfcmapi-path` | `winget-microsoft-mfcmapi-fqdn` |
| `Microsoft.MIDI.FeatureEnablementChecker` | 1.1 | 2 | 2 | `winget-microsoft-midi-featureenablementchecker-path` | `winget-microsoft-midi-featureenablementchecker-fqdn` |
| `Microsoft.MIDI.SDK` | 1.0.16-rc.3.7 | 2 | 2 | `winget-microsoft-midi-sdk-path` | `winget-microsoft-midi-sdk-fqdn` |
| `Microsoft.MITT` | 8.03 | 1 | 1 | `winget-microsoft-mitt-path` | `winget-microsoft-mitt-fqdn` |
| `Microsoft.MSIX-Toolkit` | 10.0.19041.1 | 2 | 2 | `winget-microsoft-msix-toolkit-path` | `winget-microsoft-msix-toolkit-fqdn` |
| `Microsoft.MSIXCore` | 1.2.0.0 | 3 | 2 | `winget-microsoft-msixcore-path` | `winget-microsoft-msixcore-fqdn` |
| `Microsoft.MSIXPackagingTool` | 1.2024.405.0 | 1 | 1 | `winget-microsoft-msixpackagingtool-path` | `winget-microsoft-msixpackagingtool-fqdn` |
| `Microsoft.MUTT` | 3.0.0 | 1 | 1 | `winget-microsoft-mutt-path` | `winget-microsoft-mutt-fqdn` |
| `Microsoft.MaliciousSoftwareRemovalTool` | 5.139 | 2 | 1 | `winget-microsoft-malicioussoftwareremovaltool-path` | `winget-microsoft-malicioussoftwareremovaltool-fqdn` |
| `Microsoft.MediaCreationTool` | 10.0.26100.7019 | 1 | 1 | `winget-microsoft-mediacreationtool-path` | `winget-microsoft-mediacreationtool-fqdn` |
| `Microsoft.MouseWithoutBorders` | 2.2.1.327 | 1 | 1 | `winget-microsoft-mousewithoutborders-path` | `winget-microsoft-mousewithoutborders-fqdn` |
| `Microsoft.MouseandKeyboardCenter` | 14.41.137.0 | 3 | 1 | `winget-microsoft-mouseandkeyboardcenter-path` | `winget-microsoft-mouseandkeyboardcenter-fqdn` |
| `Microsoft.Ntttcp` | 5.40.0.99012574 | 2 | 2 | `winget-microsoft-ntttcp-path` | `winget-microsoft-ntttcp-fqdn` |
| `Microsoft.NuGet` | 7.3.1 | 1 | 1 | `winget-microsoft-nuget-path` | `winget-microsoft-nuget-fqdn` |
| `Microsoft.OSCDIMG` | 2.56 | 1 | 2 | `winget-microsoft-oscdimg-path` | `winget-microsoft-oscdimg-fqdn` |
| `Microsoft.OSConfig` | 1.3.10.13 | 3 | 2 | `winget-microsoft-osconfig-path` | `winget-microsoft-osconfig-fqdn` |
| `Microsoft.Office` | 16.0.19929.20062 | 1 | 1 | `winget-microsoft-office-path` | `winget-microsoft-office-fqdn` |
| `Microsoft.OfficeDeploymentTool` | 16.0.19929.20062 | 1 | 1 | `winget-microsoft-officedeploymenttool-path` | `winget-microsoft-officedeploymenttool-fqdn` |
| `Microsoft.OneDrive` | 26.062.0402.0002 | 3 | 1 | `winget-microsoft-onedrive-path` | `winget-microsoft-onedrive-fqdn` |
| `Microsoft.OneLakeFileExplorer` | 1.0.14.0 | 1 | 1 | `winget-microsoft-onelakefileexplorer-path` | `winget-microsoft-onelakefileexplorer-fqdn` |
| `Microsoft.OneNoteDiagnostics` | 1.0.0.0 | 1 | 1 | `winget-microsoft-onenotediagnostics-path` | `winget-microsoft-onenotediagnostics-fqdn` |
| `Microsoft.OpenAPI.Hidi` | 3.1.2.0 | 1 | 2 | `winget-microsoft-openapi-hidi-path` | `winget-microsoft-openapi-hidi-fqdn` |
| `Microsoft.OpenAPI.Kiota` | 1.30.0 | 3 | 2 | `winget-microsoft-openapi-kiota-path` | `winget-microsoft-openapi-kiota-fqdn` |
| `Microsoft.OpenCLGLVulkanCompatibilityPack` | 1.2404.1.0 | 2 | 2 | `winget-microsoft-openclglvulkancompatibilitypack-path` | `winget-microsoft-openclglvulkancompatibilitypack-fqdn` |
| `Microsoft.OpenJDK.11` | 11.0.30.7 | 2 | 2 | `winget-microsoft-openjdk-11-path` | `winget-microsoft-openjdk-11-fqdn` |
| `Microsoft.OpenJDK.17` | 17.0.18.8 | 2 | 2 | `winget-microsoft-openjdk-17-path` | `winget-microsoft-openjdk-17-fqdn` |
| `Microsoft.OpenJDK.21` | 21.0.10.7 | 2 | 2 | `winget-microsoft-openjdk-21-path` | `winget-microsoft-openjdk-21-fqdn` |
| `Microsoft.OpenJDK.25` | 25.0.2.10 | 2 | 2 | `winget-microsoft-openjdk-25-path` | `winget-microsoft-openjdk-25-fqdn` |
| `Microsoft.PICT` | 3.7.4.0 | 1 | 2 | `winget-microsoft-pict-path` | `winget-microsoft-pict-fqdn` |
| `Microsoft.PIX` | 2603.25 | 2 | 1 | `winget-microsoft-pix-path` | `winget-microsoft-pix-fqdn` |
| `Microsoft.Pave` | 0.1.1 | 2 | 2 | `winget-microsoft-pave-path` | `winget-microsoft-pave-fqdn` |
| `Microsoft.PerfView` | 3.2.2 | 1 | 2 | `winget-microsoft-perfview-path` | `winget-microsoft-perfview-fqdn` |
| `Microsoft.PowerAppsCLI` | 1.0 | 1 | 1 | `winget-microsoft-powerappscli-path` | `winget-microsoft-powerappscli-fqdn` |
| `Microsoft.PowerAutomateDesktop` | 2.67.00143.26090 | 1 | 1 | `winget-microsoft-powerautomatedesktop-path` | `winget-microsoft-powerautomatedesktop-fqdn` |
| `Microsoft.PowerAutomateProcessMining` | 6.1.2506.2252 | 1 | 1 | `winget-microsoft-powerautomateprocessmining-path` | `winget-microsoft-powerautomateprocessmining-fqdn` |
| `Microsoft.PowerBI` | 2.153.910.0 | 1 | 1 | `winget-microsoft-powerbi-path` | `winget-microsoft-powerbi-fqdn` |
| `Microsoft.PowerBIReportBuilder` | 15.7.1817.11 | 1 | 1 | `winget-microsoft-powerbireportbuilder-path` | `winget-microsoft-powerbireportbuilder-fqdn` |
| `Microsoft.PowerBIReportServer` | 1.25.9558.32914 | 1 | 1 | `winget-microsoft-powerbireportserver-path` | `winget-microsoft-powerbireportserver-fqdn` |
| `Microsoft.PowerShell` | 7.6.1.0 | 4 | 2 | `winget-microsoft-powershell-path` | `winget-microsoft-powershell-fqdn` |
| `Microsoft.PowerToys` | 0.99.1 | 4 | 2 | `winget-microsoft-powertoys-path` | `winget-microsoft-powertoys-fqdn` |
| `Microsoft.PrintMetadataTroubleshooter` | 1.0.0.1 | 4 | 1 | `winget-microsoft-printmetadatatroubleshooter-path` | `winget-microsoft-printmetadatatroubleshooter-fqdn` |
| `Microsoft.ProfileExplorer` | 1.2.1 | 2 | 2 | `winget-microsoft-profileexplorer-path` | `winget-microsoft-profileexplorer-fqdn` |
| `Microsoft.ProjectTelescope` | 0.15.1 | 2 | 2 | `winget-microsoft-projecttelescope-path` | `winget-microsoft-projecttelescope-fqdn` |
| `Microsoft.Promptflow` | 1.17.1 | 1 | 1 | `winget-microsoft-promptflow-path` | `winget-microsoft-promptflow-fqdn` |
| `Microsoft.PurviewInformationProtection` | 3.2.57.0 | 1 | 1 | `winget-microsoft-purviewinformationprotection-path` | `winget-microsoft-purviewinformationprotection-fqdn` |
| `Microsoft.RMSClient` | 1.0.5406.9 | 2 | 1 | `winget-microsoft-rmsclient-path` | `winget-microsoft-rmsclient-fqdn` |
| `Microsoft.RemoteDesktopClient` | 1.2.7099.0 | 3 | 1 | `winget-microsoft-remotedesktopclient-path` | `winget-microsoft-remotedesktopclient-fqdn` |
| `Microsoft.RemoteDesktopMMRService` | 1.0.2507.21006 | 1 | 1 | `winget-microsoft-remotedesktopmmrservice-path` | `winget-microsoft-remotedesktopmmrservice-fqdn` |
| `Microsoft.RemoteHelp` | 5.1.1998.0 | 1 | 1 | `winget-microsoft-remotehelp-path` | `winget-microsoft-remotehelp-fqdn` |
| `Microsoft.ReportBuilder` | 15.1.30001.02 | 1 | 1 | `winget-microsoft-reportbuilder-path` | `winget-microsoft-reportbuilder-fqdn` |
| `Microsoft.SBOMTool` | 4.1.5 | 1 | 2 | `winget-microsoft-sbomtool-path` | `winget-microsoft-sbomtool-fqdn` |
| `Microsoft.SQLServer.2019.Developer` | 15.2204.5490.2 | 1 | 1 | `winget-microsoft-sqlserver-2019-developer-path` | `winget-microsoft-sqlserver-2019-developer-fqdn` |
| `Microsoft.SQLServer.2019.Express` | 15.2204.5490.2 | 1 | 1 | `winget-microsoft-sqlserver-2019-express-path` | `winget-microsoft-sqlserver-2019-express-fqdn` |
| `Microsoft.SQLServer.2022.Developer` | 16.0.1000.6 | 1 | 1 | `winget-microsoft-sqlserver-2022-developer-path` | `winget-microsoft-sqlserver-2022-developer-fqdn` |
| `Microsoft.SQLServer.2022.Express` | 16.0.1000.6 | 1 | 1 | `winget-microsoft-sqlserver-2022-express-path` | `winget-microsoft-sqlserver-2022-express-fqdn` |
| `Microsoft.SQLServer.2025.Developer` | 17.0.1000.7 | 1 | 1 | `winget-microsoft-sqlserver-2025-developer-path` | `winget-microsoft-sqlserver-2025-developer-fqdn` |
| `Microsoft.SQLServer.2025.Express` | 17.0.1000.7 | 1 | 1 | `winget-microsoft-sqlserver-2025-express-path` | `winget-microsoft-sqlserver-2025-express-fqdn` |
| `Microsoft.SQLServer.OLEDBDriver` | 19.4.1.0 | 13 | 1 | `winget-microsoft-sqlserver-oledbdriver-path` | `winget-microsoft-sqlserver-oledbdriver-fqdn` |
| `Microsoft.SQLServer.RMLUtilities` | 09.04.0103 | 1 | 1 | `winget-microsoft-sqlserver-rmlutilities-path` | `winget-microsoft-sqlserver-rmlutilities-fqdn` |
| `Microsoft.SQLServerManagementStudio` | 20.2.1 | 11 | 1 | `winget-microsoft-sqlservermanagementstudio-path` | `winget-microsoft-sqlservermanagementstudio-fqdn` |
| `Microsoft.SaRACmd` | 17.01.3954.000 | 1 | 1 | `winget-microsoft-saracmd-path` | `winget-microsoft-saracmd-fqdn` |
| `Microsoft.SafetyScanner` | 1.449.54.0 | 2 | 1 | `winget-microsoft-safetyscanner-path` | `winget-microsoft-safetyscanner-fqdn` |
| `Microsoft.ScreenRecorder` | 0.1.0 | 1 | 2 | `winget-microsoft-screenrecorder-path` | `winget-microsoft-screenrecorder-fqdn` |
| `Microsoft.SecurityComplianceToolkit.LGPO` | 3.0.2004.13001 | 1 | 1 | `winget-microsoft-securitycompliancetoolkit-lgpo-path` | `winget-microsoft-securitycompliancetoolkit-lgpo-fqdn` |
| `Microsoft.SecurityComplianceToolkit.PolicyAnalyzer` | 4.0.2004.13001 | 1 | 1 | `winget-microsoft-securitycompliancetoolkit-policyanalyzer-path` | `winget-microsoft-securitycompliancetoolkit-policyanalyzer-fqdn` |
| `Microsoft.SecurityComplianceToolkit.SetObjectSecurity` | 1.0.2004.13001 | 1 | 1 | `winget-microsoft-securitycompliancetoolkit-setobjectsecurity-path` | `winget-microsoft-securitycompliancetoolkit-setobjectsecurity-fqdn` |
| `Microsoft.ServiceFabricRuntime` | 11.3.475.1 | 1 | 1 | `winget-microsoft-servicefabricruntime-path` | `winget-microsoft-servicefabricruntime-fqdn` |
| `Microsoft.ServiceFabricSDK` | 8.3.475 | 1 | 1 | `winget-microsoft-servicefabricsdk-path` | `winget-microsoft-servicefabricsdk-fqdn` |
| `Microsoft.SetupDiag` | 1.7.0.0 | 1 | 1 | `winget-microsoft-setupdiag-path` | `winget-microsoft-setupdiag-fqdn` |
| `Microsoft.SmartDump` | 1.13 | 1 | 2 | `winget-microsoft-smartdump-path` | `winget-microsoft-smartdump-fqdn` |
| `Microsoft.SqlPackage` | 170.3.93 | 1 | 2 | `winget-microsoft-sqlpackage-path` | `winget-microsoft-sqlpackage-fqdn` |
| `Microsoft.Sqlcmd` | 1.9.0 | 3 | 2 | `winget-microsoft-sqlcmd-path` | `winget-microsoft-sqlcmd-fqdn` |
| `Microsoft.SurfaceApp` | 75.11130.117.0 | 1 | 1 | `winget-microsoft-surfaceapp-path` | `winget-microsoft-surfaceapp-fqdn` |
| `Microsoft.SurfaceHubRecoveryTool` | 2.7.139.0 | 1 | 1 | `winget-microsoft-surfacehubrecoverytool-path` | `winget-microsoft-surfacehubrecoverytool-fqdn` |
| `Microsoft.SymCryptUnitTest` | 103.8.0 | 2 | 2 | `winget-microsoft-symcryptunittest-path` | `winget-microsoft-symcryptunittest-fqdn` |
| `Microsoft.Sysinternals.Autologon` | 3.10 | 1 | 1 | `winget-microsoft-sysinternals-autologon-path` | `winget-microsoft-sysinternals-autologon-fqdn` |
| `Microsoft.Sysinternals.Autoruns` | 14.11 | 1 | 1 | `winget-microsoft-sysinternals-autoruns-path` | `winget-microsoft-sysinternals-autoruns-fqdn` |
| `Microsoft.Sysinternals.BGInfo` | 4.33 | 1 | 1 | `winget-microsoft-sysinternals-bginfo-path` | `winget-microsoft-sysinternals-bginfo-fqdn` |
| `Microsoft.Sysinternals.Ctrl2Cap` | 3.0 | 1 | 1 | `winget-microsoft-sysinternals-ctrl2cap-path` | `winget-microsoft-sysinternals-ctrl2cap-fqdn` |
| `Microsoft.Sysinternals.DebugView` | 5.00 | 1 | 1 | `winget-microsoft-sysinternals-debugview-path` | `winget-microsoft-sysinternals-debugview-fqdn` |
| `Microsoft.Sysinternals.Desktops` | 2.01 | 1 | 1 | `winget-microsoft-sysinternals-desktops-path` | `winget-microsoft-sysinternals-desktops-fqdn` |
| `Microsoft.Sysinternals.FindLinks` | 1.1 | 1 | 1 | `winget-microsoft-sysinternals-findlinks-path` | `winget-microsoft-sysinternals-findlinks-fqdn` |
| `Microsoft.Sysinternals.Handle` | 5.0 | 1 | 1 | `winget-microsoft-sysinternals-handle-path` | `winget-microsoft-sysinternals-handle-fqdn` |
| `Microsoft.Sysinternals.MoveFile` | 1.02 | 1 | 1 | `winget-microsoft-sysinternals-movefile-path` | `winget-microsoft-sysinternals-movefile-fqdn` |
| `Microsoft.Sysinternals.PendMoves` | 1.3 | 1 | 1 | `winget-microsoft-sysinternals-pendmoves-path` | `winget-microsoft-sysinternals-pendmoves-fqdn` |
| `Microsoft.Sysinternals.ProcessExplorer` | 17.11 | 1 | 1 | `winget-microsoft-sysinternals-processexplorer-path` | `winget-microsoft-sysinternals-processexplorer-fqdn` |
| `Microsoft.Sysinternals.ProcessMonitor` | 4.01 | 1 | 1 | `winget-microsoft-sysinternals-processmonitor-path` | `winget-microsoft-sysinternals-processmonitor-fqdn` |
| `Microsoft.Sysinternals.RAMMap` | 1.63 | 1 | 1 | `winget-microsoft-sysinternals-rammap-path` | `winget-microsoft-sysinternals-rammap-fqdn` |
| `Microsoft.Sysinternals.RDCMan` | 3.12 | 1 | 1 | `winget-microsoft-sysinternals-rdcman-path` | `winget-microsoft-sysinternals-rdcman-fqdn` |
| `Microsoft.Sysinternals.RegJump` | 1.11 | 1 | 1 | `winget-microsoft-sysinternals-regjump-path` | `winget-microsoft-sysinternals-regjump-fqdn` |
| `Microsoft.Sysinternals.SDelete` | 2.06 | 1 | 1 | `winget-microsoft-sysinternals-sdelete-path` | `winget-microsoft-sysinternals-sdelete-fqdn` |
| `Microsoft.Sysinternals.Sigcheck` | 2.91 | 1 | 1 | `winget-microsoft-sysinternals-sigcheck-path` | `winget-microsoft-sysinternals-sigcheck-fqdn` |
| `Microsoft.Sysinternals.Strings` | 2.54 | 1 | 1 | `winget-microsoft-sysinternals-strings-path` | `winget-microsoft-sysinternals-strings-fqdn` |
| `Microsoft.Sysinternals.Sysmon` | 15.20 | 1 | 1 | `winget-microsoft-sysinternals-sysmon-path` | `winget-microsoft-sysinternals-sysmon-fqdn` |
| `Microsoft.Sysinternals.TCPView` | 4.19 | 1 | 1 | `winget-microsoft-sysinternals-tcpview-path` | `winget-microsoft-sysinternals-tcpview-fqdn` |
| `Microsoft.Sysinternals.VMMap` | 3.40 | 1 | 1 | `winget-microsoft-sysinternals-vmmap-path` | `winget-microsoft-sysinternals-vmmap-fqdn` |
| `Microsoft.Sysinternals.Whois` | 1.21 | 1 | 1 | `winget-microsoft-sysinternals-whois-path` | `winget-microsoft-sysinternals-whois-fqdn` |
| `Microsoft.Sysinternals.ZoomIt` | 11.00 | 1 | 1 | `winget-microsoft-sysinternals-zoomit-path` | `winget-microsoft-sysinternals-zoomit-fqdn` |
| `Microsoft.TeamMate` | 0.1.15 | 1 | 2 | `winget-microsoft-teammate-path` | `winget-microsoft-teammate-fqdn` |
| `Microsoft.Teams` | 26072.521.4595.7966 | 3 | 1 | `winget-microsoft-teams-path` | `winget-microsoft-teams-fqdn` |
| `Microsoft.TeamsTxNDI` | 2024.8.1.14 | 1 | 1 | `winget-microsoft-teamstxndi-path` | `winget-microsoft-teamstxndi-fqdn` |
| `Microsoft.TimeTravelDebugging` | 1.11.584.0 | 1 | 1 | `winget-microsoft-timetraveldebugging-path` | `winget-microsoft-timetraveldebugging-fqdn` |
| `Microsoft.Tokenizer` | 1.3.3 | 1 | 2 | `winget-microsoft-tokenizer-path` | `winget-microsoft-tokenizer-fqdn` |
| `Microsoft.UI.Xaml.2.7` | 7.2208.15002.0 | 4 | 2 | `winget-microsoft-ui-xaml-2-7-path` | `winget-microsoft-ui-xaml-2-7-fqdn` |
| `Microsoft.UI.Xaml.2.8` | 8.2310.30001.0 | 4 | 2 | `winget-microsoft-ui-xaml-2-8-path` | `winget-microsoft-ui-xaml-2-8-fqdn` |
| `Microsoft.UpdateAssistant` | 1.4.19041.2183 | 1 | 1 | `winget-microsoft-updateassistant-path` | `winget-microsoft-updateassistant-fqdn` |
| `Microsoft.VCLibs.14` | 14.0.33519.0 | 1 | 2 | `winget-microsoft-vclibs-14-path` | `winget-microsoft-vclibs-14-fqdn` |
| `Microsoft.VCLibs.Desktop.14` | 14.0.33728.0 | 1 | 2 | `winget-microsoft-vclibs-desktop-14-path` | `winget-microsoft-vclibs-desktop-14-fqdn` |
| `Microsoft.VCRedist.2012.x64` | 11.0.61030.0 | 1 | 1 | `winget-microsoft-vcredist-2012-x64-path` | `winget-microsoft-vcredist-2012-x64-fqdn` |
| `Microsoft.VCRedist.2012.x86` | 11.0.61030.0 | 1 | 1 | `winget-microsoft-vcredist-2012-x86-path` | `winget-microsoft-vcredist-2012-x86-fqdn` |
| `Microsoft.VCRedist.2013.x64` | 12.0.40664.0 | 1 | 1 | `winget-microsoft-vcredist-2013-x64-path` | `winget-microsoft-vcredist-2013-x64-fqdn` |
| `Microsoft.VCRedist.2013.x86` | 12.0.40664.0 | 1 | 1 | `winget-microsoft-vcredist-2013-x86-path` | `winget-microsoft-vcredist-2013-x86-fqdn` |
| `Microsoft.VCRedist.2015+.arm64` | 14.50.35719.0 | 1 | 1 | `winget-microsoft-vcredist-2015+-arm64-path` | `winget-microsoft-vcredist-2015+-arm64-fqdn` |
| `Microsoft.VCRedist.2015+.x64` | 14.50.35719.0 | 1 | 1 | `winget-microsoft-vcredist-2015+-x64-path` | `winget-microsoft-vcredist-2015+-x64-fqdn` |
| `Microsoft.VCRedist.2015+.x86` | 14.50.35719.0 | 1 | 1 | `winget-microsoft-vcredist-2015+-x86-path` | `winget-microsoft-vcredist-2015+-x86-fqdn` |
| `Microsoft.VSDotNetLogCollect` | 17.0.35214.149 | 1 | 1 | `winget-microsoft-vsdotnetlogcollect-path` | `winget-microsoft-vsdotnetlogcollect-fqdn` |
| `Microsoft.VSIXBootstrapper` | 1.0.37 | 1 | 2 | `winget-microsoft-vsixbootstrapper-path` | `winget-microsoft-vsixbootstrapper-fqdn` |
| `Microsoft.VSTOR` | 10.0.60917 | 1 | 1 | `winget-microsoft-vstor-path` | `winget-microsoft-vstor-fqdn` |
| `Microsoft.VisioViewer` | 16.0.4339.1001 | 2 | 1 | `winget-microsoft-visioviewer-path` | `winget-microsoft-visioviewer-fqdn` |
| `Microsoft.VisualStudio.2022.BuildTools` | 17.14.31 | 1 | 1 | `winget-microsoft-visualstudio-2022-buildtools-path` | `winget-microsoft-visualstudio-2022-buildtools-fqdn` |
| `Microsoft.VisualStudio.2022.Enterprise` | 17.14.31 | 1 | 1 | `winget-microsoft-visualstudio-2022-enterprise-path` | `winget-microsoft-visualstudio-2022-enterprise-fqdn` |
| `Microsoft.VisualStudio.2022.OnecoreMsvsmon` | 17.14.6 | 4 | 1 | `winget-microsoft-visualstudio-2022-onecoremsvsmon-path` | `winget-microsoft-visualstudio-2022-onecoremsvsmon-fqdn` |
| `Microsoft.VisualStudio.2022.Professional` | 17.14.31 | 1 | 1 | `winget-microsoft-visualstudio-2022-professional-path` | `winget-microsoft-visualstudio-2022-professional-fqdn` |
| `Microsoft.VisualStudio.2022.RemoteTools` | 17.14.8 | 3 | 1 | `winget-microsoft-visualstudio-2022-remotetools-path` | `winget-microsoft-visualstudio-2022-remotetools-fqdn` |
| `Microsoft.VisualStudio.ConfigFinder` | 1.0.47.55350 | 1 | 2 | `winget-microsoft-visualstudio-configfinder-path` | `winget-microsoft-visualstudio-configfinder-fqdn` |
| `Microsoft.VisualStudio.Extensions.TypeScript` | 4.3 | 1 | 1 | `winget-microsoft-visualstudio-extensions-typescript-path` | `winget-microsoft-visualstudio-extensions-typescript-fqdn` |
| `Microsoft.VisualStudio.Locator` | 3.1.7 | 1 | 2 | `winget-microsoft-visualstudio-locator-path` | `winget-microsoft-visualstudio-locator-fqdn` |
| `Microsoft.VisualStudioCode` | 1.118.1 | 4 | 1 | `winget-microsoft-visualstudiocode-path` | `winget-microsoft-visualstudiocode-fqdn` |
| `Microsoft.VisualTrueType` | 6.35 | 1 | 2 | `winget-microsoft-visualtruetype-path` | `winget-microsoft-visualtruetype-fqdn` |
| `Microsoft.WSL` | 2.6.3 | 3 | 2 | `winget-microsoft-wsl-path` | `winget-microsoft-wsl-fqdn` |
| `Microsoft.Wassette` | 0.4.0 | 2 | 2 | `winget-microsoft-wassette-path` | `winget-microsoft-wassette-fqdn` |
| `Microsoft.WebDeploy` | 10.0.2001 | 28 | 1 | `winget-microsoft-webdeploy-path` | `winget-microsoft-webdeploy-fqdn` |
| `Microsoft.Win32ContentPrepTool` | 1.8.7 | 1 | 2 | `winget-microsoft-win32contentpreptool-path` | `winget-microsoft-win32contentpreptool-fqdn` |
| `Microsoft.WinAppCli` | 0.3.0 | 2 | 2 | `winget-microsoft-winappcli-path` | `winget-microsoft-winappcli-fqdn` |
| `Microsoft.WinDbg` | 1.2603.20001.0 | 1 | 1 | `winget-microsoft-windbg-path` | `winget-microsoft-windbg-fqdn` |
| `Microsoft.WindowsADK` | 10.1.28000.1 | 1 | 1 | `winget-microsoft-windowsadk-path` | `winget-microsoft-windowsadk-fqdn` |
| `Microsoft.WindowsAdminCenter` | 2.6.6.18 | 1 | 1 | `winget-microsoft-windowsadmincenter-path` | `winget-microsoft-windowsadmincenter-fqdn` |
| `Microsoft.WindowsApp` | 2.0.1071.0 | 3 | 1 | `winget-microsoft-windowsapp-path` | `winget-microsoft-windowsapp-fqdn` |
| `Microsoft.WindowsAppRuntime.1.5` | 1.5.8 | 3 | 2 | `winget-microsoft-windowsappruntime-1-5-path` | `winget-microsoft-windowsappruntime-1-5-fqdn` |
| `Microsoft.WindowsAppRuntime.1.6` | 1.6.9 | 3 | 2 | `winget-microsoft-windowsappruntime-1-6-path` | `winget-microsoft-windowsappruntime-1-6-fqdn` |
| `Microsoft.WindowsAppRuntime.1.7` | 1.7.9 | 3 | 2 | `winget-microsoft-windowsappruntime-1-7-path` | `winget-microsoft-windowsappruntime-1-7-fqdn` |
| `Microsoft.WindowsAppRuntime.1.8` | 1.8.6 | 3 | 2 | `winget-microsoft-windowsappruntime-1-8-path` | `winget-microsoft-windowsappruntime-1-8-fqdn` |
| `Microsoft.WindowsApplicationDriver` | 1.2.1.0 | 1 | 2 | `winget-microsoft-windowsapplicationdriver-path` | `winget-microsoft-windowsapplicationdriver-fqdn` |
| `Microsoft.WindowsBusesTracing` | 1.1.0 | 2 | 2 | `winget-microsoft-windowsbusestracing-path` | `winget-microsoft-windowsbusestracing-fqdn` |
| `Microsoft.WindowsCloudIOProtectionDriver` | 0.0.693 | 2 | 1 | `winget-microsoft-windowscloudioprotectiondriver-path` | `winget-microsoft-windowscloudioprotectiondriver-fqdn` |
| `Microsoft.WindowsDeviceRecoveryTool` | 3.17.0 | 1 | 1 | `winget-microsoft-windowsdevicerecoverytool-path` | `winget-microsoft-windowsdevicerecoverytool-fqdn` |
| `Microsoft.WindowsInstallationAssistant` | 1.4.19041.6448 | 1 | 1 | `winget-microsoft-windowsinstallationassistant-path` | `winget-microsoft-windowsinstallationassistant-fqdn` |
| `Microsoft.WindowsMIDIServicesSDK` | 1.0.14-rc.1.209 | 2 | 2 | `winget-microsoft-windowsmidiservicessdk-path` | `winget-microsoft-windowsmidiservicessdk-fqdn` |
| `Microsoft.WindowsPCHealthCheck` | 4.0.2410.23001 | 2 | 1 | `winget-microsoft-windowspchealthcheck-path` | `winget-microsoft-windowspchealthcheck-fqdn` |
| `Microsoft.WindowsSDK.10.0.22000` | 10.0.22000.832 | 1 | 1 | `winget-microsoft-windowssdk-10-0-22000-path` | `winget-microsoft-windowssdk-10-0-22000-fqdn` |
| `Microsoft.WindowsSDK.10.0.22621` | 10.0.22621.2428 | 1 | 1 | `winget-microsoft-windowssdk-10-0-22621-path` | `winget-microsoft-windowssdk-10-0-22621-fqdn` |
| `Microsoft.WindowsSDK.10.0.26100` | 10.0.26100.7705 | 1 | 1 | `winget-microsoft-windowssdk-10-0-26100-path` | `winget-microsoft-windowssdk-10-0-26100-fqdn` |
| `Microsoft.WindowsSDK.10.0.28000` | 10.0.28000.1721 | 1 | 1 | `winget-microsoft-windowssdk-10-0-28000-path` | `winget-microsoft-windowssdk-10-0-28000-fqdn` |
| `Microsoft.WindowsTerminal` | 1.24.10921.0 | 1 | 2 | `winget-microsoft-windowsterminal-path` | `winget-microsoft-windowsterminal-fqdn` |
| `Microsoft.WindowsVirtualDesktopAgent` | 1.0.12684.400 | 1 | 3 | `winget-microsoft-windowsvirtualdesktopagent-path` | `winget-microsoft-windowsvirtualdesktopagent-fqdn` |
| `Microsoft.WindowsVirtualDesktopBootloader` | 1.0.9023.1100 | 1 | 2 | `winget-microsoft-windowsvirtualdesktopbootloader-path` | `winget-microsoft-windowsvirtualdesktopbootloader-fqdn` |
| `Microsoft.WindowsWDK.10.0.22000` | 10.1.22000.1 | 1 | 1 | `winget-microsoft-windowswdk-10-0-22000-path` | `winget-microsoft-windowswdk-10-0-22000-fqdn` |
| `Microsoft.WindowsWDK.10.0.22621` | 10.1.22621.2428 | 1 | 1 | `winget-microsoft-windowswdk-10-0-22621-path` | `winget-microsoft-windowswdk-10-0-22621-fqdn` |
| `Microsoft.WindowsWDK.10.0.26100` | 10.1.26100.6584 | 1 | 1 | `winget-microsoft-windowswdk-10-0-26100-path` | `winget-microsoft-windowswdk-10-0-26100-fqdn` |
| `Microsoft.WingetCreate` | 1.12.8.0 | 2 | 2 | `winget-microsoft-wingetcreate-path` | `winget-microsoft-wingetcreate-fqdn` |
| `Microsoft.XMLNotepad` | 2.9.0.21 | 2 | 2 | `winget-microsoft-xmlnotepad-path` | `winget-microsoft-xmlnotepad-fqdn` |
| `Microsoft.bitsmanager` | 1.12.0.4 | 1 | 2 | `winget-microsoft-bitsmanager-path` | `winget-microsoft-bitsmanager-fqdn` |
| `Microsoft.err` | 6.4.5 | 1 | 1 | `winget-microsoft-err-path` | `winget-microsoft-err-fqdn` |
| `Microsoft.etl2pcapng` | 1.11.0 | 1 | 2 | `winget-microsoft-etl2pcapng-path` | `winget-microsoft-etl2pcapng-fqdn` |
| `Microsoft.msodbcsql.17` | 17.10.6.1 | 22 | 1 | `winget-microsoft-msodbcsql-17-path` | `winget-microsoft-msodbcsql-17-fqdn` |
| `Microsoft.msodbcsql.18` | 18.6.2.1 | 33 | 1 | `winget-microsoft-msodbcsql-18-path` | `winget-microsoft-msodbcsql-18-fqdn` |
| `Microsoft.quicreach` | 1.3.0 | 1 | 2 | `winget-microsoft-quicreach-path` | `winget-microsoft-quicreach-fqdn` |
| `Microsoft.winfile` | 10.4.0.0 | 1 | 2 | `winget-microsoft-winfile-path` | `winget-microsoft-winfile-fqdn` |
| `Telerik.Fiddler.Classic` | 5.0.20253.3311 | 1 | 1 | `winget-telerik-fiddler-classic-path` | `winget-telerik-fiddler-classic-fqdn` |
| `WiresharkFoundation.Stratoshark` | 0.9.3 | 2 | 1 | `winget-wiresharkfoundation-stratoshark-path` | `winget-wiresharkfoundation-stratoshark-fqdn` |
| `WiresharkFoundation.Wireshark` | 4.6.5 | 3 | 1 | `winget-wiresharkfoundation-wireshark-path` | `winget-wiresharkfoundation-wireshark-fqdn` |

---

## 🌐 FQDN 彙總表（跨套件）

以下列出所有需要在 Azure Firewall Policy 中放行的 FQDN：

| FQDN | 用途分類 | 信心等級 | 最終目標 | 涉及套件 |
|---|---|---|---|---|
| `1.na.dl.wireshark.org` | unknown | high | ✅ | `WiresharkFoundation.Stratoshark` |
| `2.na.dl.wireshark.org` | unknown | high | ✅ | `WiresharkFoundation.Wireshark` |
| `aka.ms` | unknown | medium | — | `Microsoft.OpenJDK.11`, `Microsoft.OpenJDK.17`, `Microsoft.OpenJDK.21`, `Microsoft.OpenJDK.25`, `Microsoft.WindowsAppRuntime.1.5`, `Microsoft.WindowsAppRuntime.1.6`, `Microsoft.WindowsAppRuntime.1.7`, `Microsoft.WindowsAppRuntime.1.8` |
| `amendmentservice.azurewebsites.net` | unknown | high | ✅ | `Microsoft.AmendmentAppWordService` |
| `azcliprod.blob.core.windows.net` | unknown | high | ✅ | `Microsoft.AzureCLI` |
| `builds.dotnet.microsoft.com` | unknown | high | ✅ | `Microsoft.DotNet.AspNetCore.10`, `Microsoft.DotNet.AspNetCore.6`, `Microsoft.DotNet.AspNetCore.8`, `Microsoft.DotNet.AspNetCore.9`, `Microsoft.DotNet.DesktopRuntime.10`, `Microsoft.DotNet.DesktopRuntime.6`, `Microsoft.DotNet.DesktopRuntime.8`, `Microsoft.DotNet.DesktopRuntime.9`, `Microsoft.DotNet.HostingBundle.10`, `Microsoft.DotNet.HostingBundle.6`, `Microsoft.DotNet.HostingBundle.8`, `Microsoft.DotNet.HostingBundle.9`, `Microsoft.DotNet.Runtime.10`, `Microsoft.DotNet.Runtime.6`, `Microsoft.DotNet.Runtime.8`, `Microsoft.DotNet.Runtime.9`, `Microsoft.DotNet.SDK.10`, `Microsoft.DotNet.SDK.6`, `Microsoft.DotNet.SDK.8`, `Microsoft.DotNet.SDK.9` |
| `catalog.s.download.windowsupdate.com` | unknown | high | ✅ | `Microsoft.RemoteHelp` |
| `cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net` | unknown | high | ✅ | `Microsoft.Azure.CosmosEmulator` |
| `cdn.winget.microsoft.com` | winget-source | high | — | `*（所有套件共用）` |
| `ci.dot.net` | unknown | high | ✅ | `Microsoft.Aspire` |
| `cli.dfd.security.azure.com` | unknown | high | ✅ | `Microsoft.DefenderForCloud.CLI` |
| `codeload.github.com` | download | high | ✅ | `Microsoft.Win32ContentPrepTool` |
| `da-release-ehacb6gnczcma8hc.b01.azurefd.net` | unknown | high | ✅ | `Microsoft.DependencyAgent` |
| `definitionupdates.microsoft.com` | unknown | high | ✅ | `Microsoft.SafetyScanner` |
| `demo.wd.microsoft.com` | unknown | high | ✅ | `Microsoft.ASRTestTool` |
| `desktop.githubusercontent.com` | cdn | high | ✅ | `GitHub.GitHubDesktop` |
| `dist.nuget.org` | unknown | high | ✅ | `Microsoft.NuGet` |
| `download.microsoft.com` | unknown | high | ✅ | `Microsoft.AccountLockoutStatus`, `Microsoft.AdministrativeTemplates`, `Microsoft.Azure.ArtifactSigningClientTools`, `Microsoft.Azure.DataCLI`, `Microsoft.Azure.DataStudio`, `Microsoft.Azure.TrustedSigningClientTools`, `Microsoft.AzureMonitorAgent`, `Microsoft.AzureVPNClient`, `Microsoft.BTP`, `Microsoft.CLRTypesSQLServer.2019`, `Microsoft.CertifiedToolAzureVM`, `Microsoft.DTrace`, `Microsoft.DataMigrationAssistant`, `Microsoft.DebugDiag`, `Microsoft.DeploymentToolkit`, `Microsoft.DirectAccessCTST`, `Microsoft.DirectX`, `Microsoft.DotNet.Framework.DeveloperPack.4.6`, `Microsoft.DotNet.Framework.DeveloperPack_4`, `Microsoft.DotNet.Framework.Runtime`, `Microsoft.DotNet.RepairTool`, `Microsoft.FRSDiag`, `Microsoft.FSLogix`, `Microsoft.FuzzyLookupAddExcel`, `Microsoft.HwpConverter`, `Microsoft.IIS.Compression`, `Microsoft.IIS.URLRewrite`, `Microsoft.IISManagerRemoteAdministration`, `Microsoft.IntegrationRuntime`, `Microsoft.LAPS`, `Microsoft.LingeringObjectLiquidator`, `Microsoft.LogParser`, `Microsoft.MITT`, `Microsoft.MSIXPackagingTool`, `Microsoft.MUTT`, `Microsoft.MaliciousSoftwareRemovalTool`, `Microsoft.MediaCreationTool`, `Microsoft.MouseWithoutBorders`, `Microsoft.MouseandKeyboardCenter`, `Microsoft.OfficeDeploymentTool`, `Microsoft.OneLakeFileExplorer`, `Microsoft.OneNoteDiagnostics`, `Microsoft.PIX`, `Microsoft.PowerAppsCLI`, `Microsoft.PowerAutomateDesktop`, `Microsoft.PowerAutomateProcessMining`, `Microsoft.PowerBI`, `Microsoft.PowerBIReportBuilder`, `Microsoft.PowerBIReportServer`, `Microsoft.PrintMetadataTroubleshooter`, `Microsoft.PurviewInformationProtection`, `Microsoft.RMSClient`, `Microsoft.ReportBuilder`, `Microsoft.SQLServer.2019.Developer`, `Microsoft.SQLServer.2019.Express`, `Microsoft.SQLServer.2022.Developer`, `Microsoft.SQLServer.2022.Express`, `Microsoft.SQLServer.2025.Developer`, `Microsoft.SQLServer.2025.Express`, `Microsoft.SQLServer.OLEDBDriver`, `Microsoft.SQLServer.RMLUtilities`, `Microsoft.SQLServerManagementStudio`, `Microsoft.SaRACmd`, `Microsoft.SecurityComplianceToolkit.LGPO`, `Microsoft.SecurityComplianceToolkit.PolicyAnalyzer`, `Microsoft.SecurityComplianceToolkit.SetObjectSecurity`, `Microsoft.ServiceFabricRuntime`, `Microsoft.ServiceFabricSDK`, `Microsoft.SetupDiag`, `Microsoft.SqlPackage`, `Microsoft.SurfaceApp`, `Microsoft.SurfaceHubRecoveryTool`, `Microsoft.UpdateAssistant`, `Microsoft.VCRedist.2012.x64`, `Microsoft.VCRedist.2012.x86`, `Microsoft.VSDotNetLogCollect`, `Microsoft.VSTOR`, `Microsoft.VisioViewer`, `Microsoft.WebDeploy`, `Microsoft.WindowsADK`, `Microsoft.WindowsAdminCenter`, `Microsoft.WindowsAppRuntime.1.5`, `Microsoft.WindowsAppRuntime.1.6`, `Microsoft.WindowsAppRuntime.1.7`, `Microsoft.WindowsAppRuntime.1.8`, `Microsoft.WindowsDeviceRecoveryTool`, `Microsoft.WindowsInstallationAssistant`, `Microsoft.WindowsPCHealthCheck`, `Microsoft.WindowsSDK.10.0.22000`, `Microsoft.WindowsSDK.10.0.22621`, `Microsoft.WindowsSDK.10.0.26100`, `Microsoft.WindowsSDK.10.0.28000`, `Microsoft.WindowsWDK.10.0.22000`, `Microsoft.WindowsWDK.10.0.22621`, `Microsoft.WindowsWDK.10.0.26100`, `Microsoft.err`, `Microsoft.msodbcsql.17`, `Microsoft.msodbcsql.18` |
| `download.msappproxy.net` | unknown | high | ✅ | `Microsoft.GlobalSecureAccessClient` |
| `download.sysinternals.com` | unknown | high | ✅ | `Microsoft.Sysinternals.Autologon`, `Microsoft.Sysinternals.Autoruns`, `Microsoft.Sysinternals.BGInfo`, `Microsoft.Sysinternals.Ctrl2Cap`, `Microsoft.Sysinternals.DebugView`, `Microsoft.Sysinternals.Desktops`, `Microsoft.Sysinternals.FindLinks`, `Microsoft.Sysinternals.Handle`, `Microsoft.Sysinternals.MoveFile`, `Microsoft.Sysinternals.PendMoves`, `Microsoft.Sysinternals.ProcessExplorer`, `Microsoft.Sysinternals.ProcessMonitor`, `Microsoft.Sysinternals.RAMMap`, `Microsoft.Sysinternals.RDCMan`, `Microsoft.Sysinternals.RegJump`, `Microsoft.Sysinternals.SDelete`, `Microsoft.Sysinternals.Sigcheck`, `Microsoft.Sysinternals.Strings`, `Microsoft.Sysinternals.Sysmon`, `Microsoft.Sysinternals.TCPView`, `Microsoft.Sysinternals.VMMap`, `Microsoft.Sysinternals.Whois`, `Microsoft.Sysinternals.ZoomIt` |
| `download.visualstudio.microsoft.com` | unknown | high | ✅ | `Microsoft.OpenJDK.11`, `Microsoft.OpenJDK.17`, `Microsoft.OpenJDK.21`, `Microsoft.OpenJDK.25`, `Microsoft.VCRedist.2013.x64`, `Microsoft.VCRedist.2013.x86`, `Microsoft.VCRedist.2015+.arm64`, `Microsoft.VCRedist.2015+.x64`, `Microsoft.VCRedist.2015+.x86`, `Microsoft.VisualStudio.2022.BuildTools`, `Microsoft.VisualStudio.2022.Enterprise`, `Microsoft.VisualStudio.2022.OnecoreMsvsmon`, `Microsoft.VisualStudio.2022.Professional`, `Microsoft.VisualStudio.2022.RemoteTools` |
| `downloads.getfiddler.com` | unknown | high | ✅ | `Telerik.Fiddler.Classic` |
| `foundry.onnxruntime.ai` | unknown | high | ✅ | `Microsoft.FoundryLocal` |
| `gbl.his.arc.azure.com` | unknown | high | ✅ | `Microsoft.Azure.ConnectedMachineAgent` |
| `github.com` | download | high | ✅ | `GitHub.Copilot`, `GitHub.GitLFS`, `GitHub.cli`, `GitHub.git-sizer`, `Microsoft.AIShell`, `Microsoft.AKSdesktop`, `Microsoft.APM`, `Microsoft.AppInstaller`, `Microsoft.AppInstallerFileBuilder`, `Microsoft.AppLockerPolicyConverter`, `Microsoft.ApplicationInspector`, `Microsoft.Azd`, `Microsoft.Azure.ADConnectSyncDocumenter`, `Microsoft.Azure.AZCopy.10`, `Microsoft.Azure.Auth`, `Microsoft.Azure.Az`, `Microsoft.Azure.AztfExport`, `Microsoft.Azure.BatchExplorer`, `Microsoft.Azure.CloudHSM-ClientSDK`, `Microsoft.Azure.FunctionsCoreTools`, `Microsoft.Azure.GuestProxyAgent`, `Microsoft.Azure.IoTExplorer`, `Microsoft.Azure.QuickReview`, `Microsoft.Azure.StorageExplorer`, `Microsoft.Azure.TemplateAnalyzer`, `Microsoft.Bicep`, `Microsoft.BotFrameworkComposer`, `Microsoft.BotFrameworkEmulator`, `Microsoft.CmdPalAzureExtension`, `Microsoft.CmdPalGitHubExtension`, `Microsoft.DSC`, `Microsoft.DevSkim.CLI.DotNetTool`, `Microsoft.DevSkim.CLI.LibraryPackage`, `Microsoft.DirectXTex.Texassemble`, `Microsoft.DirectXTex.Texconv`, `Microsoft.DirectXTex.Texdiag`, `Microsoft.DiskSpd`, `Microsoft.DotNet.UninstallTool`, `Microsoft.Edit`, `Microsoft.EnterpriseStateClassify`, `Microsoft.EventLogExpert`, `Microsoft.GameInput`, `Microsoft.Garnet.DN8`, `Microsoft.Garnet.DN9`, `Microsoft.Git`, `Microsoft.HIDTools.Waratah`, `Microsoft.IIS.ServiceMonitor`, `Microsoft.IdFix`, `Microsoft.IntuneWSLPlugin`, `Microsoft.IronPython.3`, `Microsoft.Kanagawa`, `Microsoft.LightGBM`, `Microsoft.LogCheetah`, `Microsoft.M365AgentsPlayground`, `Microsoft.MFCMapi`, `Microsoft.MIDI.FeatureEnablementChecker`, `Microsoft.MIDI.SDK`, `Microsoft.MSIX-Toolkit`, `Microsoft.MSIXCore`, `Microsoft.Ntttcp`, `Microsoft.OSConfig`, `Microsoft.OpenAPI.Hidi`, `Microsoft.OpenAPI.Kiota`, `Microsoft.OpenCLGLVulkanCompatibilityPack`, `Microsoft.PICT`, `Microsoft.Pave`, `Microsoft.PerfView`, `Microsoft.PowerShell`, `Microsoft.PowerToys`, `Microsoft.ProfileExplorer`, `Microsoft.ProjectTelescope`, `Microsoft.SBOMTool`, `Microsoft.ScreenRecorder`, `Microsoft.SmartDump`, `Microsoft.Sqlcmd`, `Microsoft.SymCryptUnitTest`, `Microsoft.TeamMate`, `Microsoft.Tokenizer`, `Microsoft.UI.Xaml.2.7`, `Microsoft.UI.Xaml.2.8`, `Microsoft.VCLibs.14`, `Microsoft.VCLibs.Desktop.14`, `Microsoft.VSIXBootstrapper`, `Microsoft.VisualStudio.ConfigFinder`, `Microsoft.VisualStudio.Locator`, `Microsoft.VisualTrueType`, `Microsoft.WSL`, `Microsoft.Wassette`, `Microsoft.Win32ContentPrepTool`, `Microsoft.WinAppCli`, `Microsoft.WindowsApplicationDriver`, `Microsoft.WindowsBusesTracing`, `Microsoft.WindowsMIDIServicesSDK`, `Microsoft.WindowsTerminal`, `Microsoft.WingetCreate`, `Microsoft.XMLNotepad`, `Microsoft.bitsmanager`, `Microsoft.etl2pcapng`, `Microsoft.quicreach`, `Microsoft.winfile` |
| `globalcdn.nuget.org` | unknown | high | ✅ | `Microsoft.DotNet.dotnet-ef` |
| `go.microsoft.com` | unknown | medium | — | `Microsoft.SqlPackage`, `Microsoft.WindowsVirtualDesktopAgent` |
| `installer.teams.static.microsoft` | unknown | high | ✅ | `Microsoft.Teams` |
| `intstreamreleases.z22.web.core.windows.net` | unknown | high | ✅ | `Microsoft.RemoteDesktopMMRService` |
| `msdl.microsoft.com` | unknown | medium | — | `Microsoft.OSCDIMG` |
| `msedge.sf.dl.delivery.mp.microsoft.com` | cdn | high | ✅ | `Microsoft.Edge`, `Microsoft.EdgeWebView2Runtime` |
| `msedgedriver.microsoft.com` | unknown | high | ✅ | `Microsoft.EdgeDriver` |
| `objects.githubusercontent.com` | cdn | high | ✅ | `GitHub.Copilot`, `GitHub.GitLFS`, `GitHub.cli`, `GitHub.git-sizer`, `Microsoft.AIShell`, `Microsoft.AKSdesktop`, `Microsoft.APM`, `Microsoft.AppInstaller`, `Microsoft.AppInstallerFileBuilder`, `Microsoft.AppLockerPolicyConverter`, `Microsoft.ApplicationInspector`, `Microsoft.Azd`, `Microsoft.Azure.ADConnectSyncDocumenter`, `Microsoft.Azure.AZCopy.10`, `Microsoft.Azure.Auth`, `Microsoft.Azure.Az`, `Microsoft.Azure.AztfExport`, `Microsoft.Azure.BatchExplorer`, `Microsoft.Azure.FunctionsCoreTools`, `Microsoft.Azure.GuestProxyAgent`, `Microsoft.Azure.IoTExplorer`, `Microsoft.Azure.QuickReview`, `Microsoft.Azure.StorageExplorer`, `Microsoft.Azure.TemplateAnalyzer`, `Microsoft.Bicep`, `Microsoft.BotFrameworkComposer`, `Microsoft.BotFrameworkEmulator`, `Microsoft.CmdPalAzureExtension`, `Microsoft.CmdPalGitHubExtension`, `Microsoft.DSC`, `Microsoft.DevSkim.CLI.DotNetTool`, `Microsoft.DevSkim.CLI.LibraryPackage`, `Microsoft.DirectXTex.Texassemble`, `Microsoft.DirectXTex.Texconv`, `Microsoft.DirectXTex.Texdiag`, `Microsoft.DiskSpd`, `Microsoft.DotNet.UninstallTool`, `Microsoft.Edit`, `Microsoft.EnterpriseStateClassify`, `Microsoft.EventLogExpert`, `Microsoft.GameInput`, `Microsoft.Garnet.DN8`, `Microsoft.Garnet.DN9`, `Microsoft.Git`, `Microsoft.HIDTools.Waratah`, `Microsoft.IIS.ServiceMonitor`, `Microsoft.IronPython.3`, `Microsoft.Kanagawa`, `Microsoft.LightGBM`, `Microsoft.LogCheetah`, `Microsoft.M365AgentsPlayground`, `Microsoft.MFCMapi`, `Microsoft.MIDI.FeatureEnablementChecker`, `Microsoft.MIDI.SDK`, `Microsoft.MSIX-Toolkit`, `Microsoft.MSIXCore`, `Microsoft.Ntttcp`, `Microsoft.OSConfig`, `Microsoft.OpenAPI.Hidi`, `Microsoft.OpenAPI.Kiota`, `Microsoft.OpenCLGLVulkanCompatibilityPack`, `Microsoft.PICT`, `Microsoft.Pave`, `Microsoft.PerfView`, `Microsoft.PowerShell`, `Microsoft.PowerToys`, `Microsoft.ProfileExplorer`, `Microsoft.ProjectTelescope`, `Microsoft.SBOMTool`, `Microsoft.ScreenRecorder`, `Microsoft.SmartDump`, `Microsoft.Sqlcmd`, `Microsoft.SymCryptUnitTest`, `Microsoft.TeamMate`, `Microsoft.Tokenizer`, `Microsoft.UI.Xaml.2.7`, `Microsoft.UI.Xaml.2.8`, `Microsoft.VCLibs.14`, `Microsoft.VCLibs.Desktop.14`, `Microsoft.VSIXBootstrapper`, `Microsoft.VisualStudio.ConfigFinder`, `Microsoft.VisualStudio.Locator`, `Microsoft.VisualTrueType`, `Microsoft.WSL`, `Microsoft.Wassette`, `Microsoft.WinAppCli`, `Microsoft.WindowsApplicationDriver`, `Microsoft.WindowsBusesTracing`, `Microsoft.WindowsMIDIServicesSDK`, `Microsoft.WindowsTerminal`, `Microsoft.WingetCreate`, `Microsoft.XMLNotepad`, `Microsoft.bitsmanager`, `Microsoft.etl2pcapng`, `Microsoft.quicreach`, `Microsoft.winfile` |
| `officecdn.microsoft.com` | unknown | high | ✅ | `Microsoft.Office` |
| `oneclient.sfx.ms` | unknown | high | ✅ | `Microsoft.OneDrive` |
| `packages.aks.azure.com` | unknown | high | ✅ | `Microsoft.Azure.Kubelogin` |
| `promptflowartifact.blob.core.windows.net` | unknown | high | ✅ | `Microsoft.Promptflow` |
| `query.prod.cms.rt.microsoft.com` | unknown | medium | — | `Microsoft.WindowsVirtualDesktopAgent`, `Microsoft.WindowsVirtualDesktopBootloader` |
| `raw.githubusercontent.com` | cdn | high | ✅ | `Microsoft.IdFix`, `Microsoft.IntuneWSLPlugin` |
| `res-1.cdn.office.net` | unknown | high | ✅ | `Microsoft.WindowsCloudIOProtectionDriver` |
| `res.cdn.office.net` | unknown | high | ✅ | `Microsoft.RemoteDesktopClient`, `Microsoft.WindowsApp`, `Microsoft.WindowsVirtualDesktopAgent`, `Microsoft.WindowsVirtualDesktopBootloader` |
| `ssis.gallerycdn.vsassets.io` | unknown | high | ✅ | `Microsoft.DataTools.IntegrationServices` |
| `teams.microsoft.com` | unknown | high | ✅ | `Microsoft.TeamsTxNDI` |
| `typescriptteam.gallerycdn.vsassets.io` | unknown | high | ✅ | `Microsoft.VisualStudio.Extensions.TypeScript` |
| `vsblobprodscussu5shard61.blob.core.windows.net` | unknown | high | ✅ | `Microsoft.OSCDIMG` |
| `vscode.download.prss.microsoft.com` | unknown | high | ✅ | `Microsoft.VisualStudioCode` |
| `webapp-wdac-wizard.azurewebsites.net` | unknown | high | ✅ | `Microsoft.AppControlPolicyWizard` |
| `windbg.download.prss.microsoft.com` | unknown | high | ✅ | `Microsoft.TimeTravelDebugging`, `Microsoft.WinDbg` |
| `winget.azureedge.net` | winget-source | high | — | `*（所有套件共用）` |

---

## 🏗️ winget 基礎設施（所有套件共用）

| FQDN | 用途 |
|---|---|
| `cdn.winget.microsoft.com` | winget 套件來源索引與 manifest |
| `winget.azureedge.net` | winget 套件來源 CDN |

---

## 📦 GitHub.Copilot

- **版本**: 1.0.34
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-github-copilot-path`

```
targetUrls:
  - github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip
  - github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-github-copilot-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 GitHub.GitHubDesktop

- **版本**: 3.5.8
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `desktop.githubusercontent.com` | 200 | ✅ 最終目標 | `desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe` |

**安裝檔 2** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `desktop.githubusercontent.com` | 200 | ✅ 最終目標 | `desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi` |

**安裝檔 3** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `desktop.githubusercontent.com` | 200 | ✅ 最終目標 | `desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe` |

**安裝檔 4** — `arm64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `desktop.githubusercontent.com` | 200 | ✅ 最終目標 | `desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-github-githubdesktop-path`

```
targetUrls:
  - desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe
  - desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi
  - desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe
  - desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-github-githubdesktop-fqdn`

```
targetFqdns:
  - desktop.githubusercontent.com
```

---

## 📦 GitHub.GitLFS

- **版本**: 3.7.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-github-gitlfs-path`

```
targetUrls:
  - github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-github-gitlfs-fqdn`

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

## 📦 GitHub.git-sizer

- **版本**: 1.5.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/github/git-sizer/releases/download/*/git-sizer-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/github/git-sizer/releases/download/*/git-sizer-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-github-git-sizer-path`

```
targetUrls:
  - github.com/github/git-sizer/releases/download/*/git-sizer-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-github-git-sizer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.AIShell

- **版本**: 1.0.0-preview.8
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/AIShell/releases/download/*/AIShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/622343786/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/AIShell/releases/download/*/AIShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/622343786/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/AIShell/releases/download/*/AIShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/622343786/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-aishell-path`

```
targetUrls:
  - github.com/PowerShell/AIShell/releases/download/*/AIShell-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/622343786/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-aishell-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.AKSdesktop

- **版本**: 0.1.0-alpha
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-aksdesktop-path`

```
targetUrls:
  - github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-aksdesktop-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.APM

- **版本**: 0.11.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-apm-path`

```
targetUrls:
  - github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-apm-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.ASRTestTool

- **版本**: 4.13.17600.1000
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `demo.wd.microsoft.com` | 200 | ✅ 最終目標 | `demo.wd.microsoft.com/Content/ASRtool.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-asrtesttool-path`

```
targetUrls:
  - demo.wd.microsoft.com/Content/ASRtool.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-asrtesttool-fqdn`

```
targetFqdns:
  - demo.wd.microsoft.com
```

---

## 📦 Microsoft.AccountLockoutStatus

- **版本**: 1.0.0.60
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/0/4/*/lockoutstatus.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-accountlockoutstatus-path`

```
targetUrls:
  - download.microsoft.com/download/c/0/4/*/lockoutstatus.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-accountlockoutstatus-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.AdministrativeTemplates

- **版本**: 11.25H2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-administrativetemplates-path`

```
targetUrls:
  - download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-administrativetemplates-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.AmendmentAppWordService

- **版本**: 4.2.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `amendmentservice.azurewebsites.net` | 0 | ✅ 最終目標 | `amendmentservice.azurewebsites.net/assets/AmendmentAppWordServiceV4.2.Setup.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-amendmentappwordservice-path`

```
targetUrls:
  - amendmentservice.azurewebsites.net/assets/AmendmentAppWordServiceV4.2.Setup.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-amendmentappwordservice-fqdn`

```
targetFqdns:
  - amendmentservice.azurewebsites.net
```

---

## 📦 Microsoft.AppControlPolicyWizard

- **版本**: 2.6.0.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `webapp-wdac-wizard.azurewebsites.net` | 200 | ✅ 最終目標 | `webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-appcontrolpolicywizard-path`

```
targetUrls:
  - webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-appcontrolpolicywizard-fqdn`

```
targetFqdns:
  - webapp-wdac-wizard.azurewebsites.net
```

---

## 📦 Microsoft.AppInstaller

- **版本**: 1.27.470.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-appinstaller-path`

```
targetUrls:
  - github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
  - objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-appinstaller-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.AppInstallerFileBuilder

- **版本**: 1.2020.221.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-appinstallerfilebuilder-path`

```
targetUrls:
  - github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-appinstallerfilebuilder-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.AppLockerPolicyConverter

- **版本**: 2.0.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-applockerpolicyconverter-path`

```
targetUrls:
  - github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-applockerpolicyconverter-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.ApplicationInspector

- **版本**: 1.9.55
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-applicationinspector-path`

```
targetUrls:
  - github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-applicationinspector-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Aspire

- **版本**: 13.1.3
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `ci.dot.net` | 200 | ✅ 最終目標 | `ci.dot.net/public/aspire/*/aspire-cli-win-x64-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `ci.dot.net` | 200 | ✅ 最終目標 | `ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-aspire-path`

```
targetUrls:
  - ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*
  - ci.dot.net/public/aspire/*/aspire-cli-win-x64-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-aspire-fqdn`

```
targetFqdns:
  - ci.dot.net
```

---

## 📦 Microsoft.Azd

- **版本**: 1.24.300
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azd-path`

```
targetUrls:
  - github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azd-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.ADConnectSyncDocumenter

- **版本**: 1.20.0917.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-adconnectsyncdocumenter-path`

```
targetUrls:
  - github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-adconnectsyncdocumenter-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.AZCopy.10

- **版本**: 10.32.3
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-azcopy-10-path`

```
targetUrls:
  - github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*
  - github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*
  - github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-azcopy-10-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.ArtifactSigningClientTools

- **版本**: 0.1.128
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/ArtifactSigningClientTools.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-artifactsigningclienttools-path`

```
targetUrls:
  - download.microsoft.com/download/*/ArtifactSigningClientTools.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-artifactsigningclienttools-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Azure.Auth

- **版本**: 0.9.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-auth-path`

```
targetUrls:
  - github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-auth-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.Az

- **版本**: 15.2.0.40510
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-az-path`

```
targetUrls:
  - github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-az-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.AztfExport

- **版本**: 0.19.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/aztfexport/releases/download/*/aztfexport_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/aztfexport/releases/download/*/aztfexport_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-aztfexport-path`

```
targetUrls:
  - github.com/Azure/aztfexport/releases/download/*/aztfexport_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-aztfexport-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.BatchExplorer

- **版本**: 2.23.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-batchexplorer-path`

```
targetUrls:
  - github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-batchexplorer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.CloudHSM-ClientSDK

- **版本**: 2.0.2.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 404 | ✅ 最終目標 | `github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-cloudhsm-clientsdk-path`

```
targetUrls:
  - github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-cloudhsm-clientsdk-fqdn`

```
targetFqdns:
  - github.com
```

---

## 📦 Microsoft.Azure.ConnectedMachineAgent

- **版本**: 1.63.03384.2896
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `gbl.his.arc.azure.com` | 403 | ✅ 最終目標 | `gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-connectedmachineagent-path`

```
targetUrls:
  - gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-connectedmachineagent-fqdn`

```
targetFqdns:
  - gbl.his.arc.azure.com
```

---

## 📦 Microsoft.Azure.CosmosEmulator

- **版本**: 2.14.27
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net` | 200 | ✅ 最終目標 | `cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-cosmosemulator-path`

```
targetUrls:
  - cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-cosmosemulator-fqdn`

```
targetFqdns:
  - cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net
```

---

## 📦 Microsoft.Azure.DataCLI

- **版本**: 20.3.14
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/f/f/f/*/azdata-cli-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-datacli-path`

```
targetUrls:
  - download.microsoft.com/download/f/f/f/*/azdata-cli-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-datacli-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Azure.DataStudio

- **版本**: 1.52.0
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*` |

**安裝檔 2** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*` |

**安裝檔 3** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/azuredatastudio-windows-setup-*` |

**安裝檔 4** — `arm64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-datastudio-path`

```
targetUrls:
  - download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*
  - download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*
  - download.microsoft.com/download/*/azuredatastudio-windows-setup-*
  - download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-datastudio-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Azure.FunctionsCoreTools

- **版本**: 4.10.0
- **安裝檔數量**: 5

### 下載路徑分析

**安裝檔 1** — `x86` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*` |

**安裝檔 2** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*` |

**安裝檔 4** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*` |

**安裝檔 5** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-functionscoretools-path`

```
targetUrls:
  - github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*
  - github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*
  - github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-functionscoretools-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.GuestProxyAgent

- **版本**: 1.0.39
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-guestproxyagent-path`

```
targetUrls:
  - github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*
  - github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-guestproxyagent-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.IoTExplorer

- **版本**: 0.15.12
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-iotexplorer-path`

```
targetUrls:
  - github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-iotexplorer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.Kubelogin

- **版本**: 0.2.13
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `packages.aks.azure.com` | 403 | ✅ 最終目標 | `packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-kubelogin-path`

```
targetUrls:
  - packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-kubelogin-fqdn`

```
targetFqdns:
  - packages.aks.azure.com
```

---

## 📦 Microsoft.Azure.QuickReview

- **版本**: 3.1.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-quickreview-path`

```
targetUrls:
  - github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-quickreview-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.StorageExplorer

- **版本**: 1.43.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*` |

**安裝檔 2** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-storageexplorer-path`

```
targetUrls:
  - github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe
  - github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-storageexplorer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.TemplateAnalyzer

- **版本**: 0.8.5
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-templateanalyzer-path`

```
targetUrls:
  - github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip
  - github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-templateanalyzer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Azure.TrustedSigningClientTools

- **版本**: 0.1.127
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/TrustedSigningClientTools.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azure-trustedsigningclienttools-path`

```
targetUrls:
  - download.microsoft.com/download/*/TrustedSigningClientTools.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azure-trustedsigningclienttools-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.AzureCLI

- **版本**: 2.85.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `azcliprod.blob.core.windows.net` | 403 | ✅ 最終目標 | `azcliprod.blob.core.windows.net/msi/azure-cli-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `azcliprod.blob.core.windows.net` | 403 | ✅ 最終目標 | `azcliprod.blob.core.windows.net/msi/azure-cli-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azurecli-path`

```
targetUrls:
  - azcliprod.blob.core.windows.net/msi/azure-cli-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azurecli-fqdn`

```
targetFqdns:
  - azcliprod.blob.core.windows.net
```

---

## 📦 Microsoft.AzureMonitorAgent

- **版本**: 1.41.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azuremonitoragent-path`

```
targetUrls:
  - download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azuremonitoragent-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.AzureVPNClient

- **版本**: 4.0.5.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/AzVpnAppx_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-azurevpnclient-path`

```
targetUrls:
  - download.microsoft.com/download/*/AzVpnAppx_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-azurevpnclient-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.BTP

- **版本**: 1.14.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-btp-path`

```
targetUrls:
  - download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-btp-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Bicep

- **版本**: 0.42.1
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*` |

**安裝檔 3** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-bicep-path`

```
targetUrls:
  - github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe
  - github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe
  - github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-bicep-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.BotFrameworkComposer

- **版本**: 2.1.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/BotFramework-Composer/releases/download/*/BotFramework-Composer-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/170615717/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-botframeworkcomposer-path`

```
targetUrls:
  - github.com/microsoft/BotFramework-Composer/releases/download/*/BotFramework-Composer-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/170615717/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-botframeworkcomposer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.BotFrameworkEmulator

- **版本**: 4.15.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/BotFramework-Emulator/releases/download/*/BotFramework-Emulator-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/73518607/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-botframeworkemulator-path`

```
targetUrls:
  - github.com/microsoft/BotFramework-Emulator/releases/download/*/BotFramework-Emulator-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/73518607/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-botframeworkemulator-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.CLRTypesSQLServer.2019

- **版本**: 15.0.2000.5
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-clrtypessqlserver-2019-path`

```
targetUrls:
  - download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-clrtypessqlserver-2019-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.CertifiedToolAzureVM

- **版本**: 1.6
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-certifiedtoolazurevm-path`

```
targetUrls:
  - download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-certifiedtoolazurevm-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.CmdPalAzureExtension

- **版本**: 0.200.174.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-cmdpalazureextension-path`

```
targetUrls:
  - github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-cmdpalazureextension-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.CmdPalGitHubExtension

- **版本**: 0.103.178.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-cmdpalgithubextension-path`

```
targetUrls:
  - github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-cmdpalgithubextension-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DSC

- **版本**: 3.1.3
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/DSC/releases/download/*/DSC-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/DSC/releases/download/*/DSC-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/DSC/releases/download/*/DSC-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dsc-path`

```
targetUrls:
  - github.com/PowerShell/DSC/releases/download/*/DSC-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dsc-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DTrace

- **版本**: 2.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dtrace-path`

```
targetUrls:
  - download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi
  - download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dtrace-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DataMigrationAssistant

- **版本**: 5.8.5973.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-datamigrationassistant-path`

```
targetUrls:
  - download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-datamigrationassistant-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DataTools.IntegrationServices

- **版本**: 17.0.1010.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `ssis.gallerycdn.vsassets.io` | 403 | ✅ 最終目標 | `ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-datatools-integrationservices-path`

```
targetUrls:
  - ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-datatools-integrationservices-fqdn`

```
targetFqdns:
  - ssis.gallerycdn.vsassets.io
```

---

## 📦 Microsoft.DebugDiag

- **版本**: 2.3.2.11
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-debugdiag-path`

```
targetUrls:
  - download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-debugdiag-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DefenderForCloud.CLI

- **版本**: 2.0.03334.114
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `cli.dfd.security.azure.com` | 200 | ✅ 最終目標 | `cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `cli.dfd.security.azure.com` | 200 | ✅ 最終目標 | `cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `cli.dfd.security.azure.com` | 200 | ✅ 最終目標 | `cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-defenderforcloud-cli-path`

```
targetUrls:
  - cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe
  - cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe
  - cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-defenderforcloud-cli-fqdn`

```
targetFqdns:
  - cli.dfd.security.azure.com
```

---

## 📦 Microsoft.DependencyAgent

- **版本**: 9.10.18
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `da-release-ehacb6gnczcma8hc.b01.azurefd.net` | 200 | ✅ 最終目標 | `da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dependencyagent-path`

```
targetUrls:
  - da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dependencyagent-fqdn`

```
targetFqdns:
  - da-release-ehacb6gnczcma8hc.b01.azurefd.net
```

---

## 📦 Microsoft.DeploymentToolkit

- **版本**: 6.3.8456.1000
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 404 | ✅ 最終目標 | `download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 404 | ✅ 最終目標 | `download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-deploymenttoolkit-path`

```
targetUrls:
  - download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi
  - download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-deploymenttoolkit-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DevSkim.CLI.DotNetTool

- **版本**: 1.0.59
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-devskim-cli-dotnettool-path`

```
targetUrls:
  - github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-devskim-cli-dotnettool-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DevSkim.CLI.LibraryPackage

- **版本**: 1.0.59
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-devskim-cli-librarypackage-path`

```
targetUrls:
  - github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-devskim-cli-librarypackage-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DirectAccessCTST

- **版本**: 1.4.4.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/a/d/0/*/DirectAccessClientTroubleshooter.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-directaccessctst-path`

```
targetUrls:
  - download.microsoft.com/download/a/d/0/*/DirectAccessClientTroubleshooter.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-directaccessctst-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DirectX

- **版本**: 9.29.1974.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx` |

**安裝檔 3** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/7/1/*/dxwebsetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-directx-path`

```
targetUrls:
  - download.microsoft.com/download/1/7/1/*/dxwebsetup.exe
  - download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx
  - download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-directx-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DirectXTex.Texassemble

- **版本**: 2026.3.31
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-directxtex-texassemble-path`

```
targetUrls:
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-directxtex-texassemble-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DirectXTex.Texconv

- **版本**: 2026.3.31
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-directxtex-texconv-path`

```
targetUrls:
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-directxtex-texconv-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DirectXTex.Texdiag

- **版本**: 2026.3.31
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-directxtex-texdiag-path`

```
targetUrls:
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe
  - github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-directxtex-texdiag-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DiskSpd

- **版本**: 2.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-diskspd-path`

```
targetUrls:
  - github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP
  - objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-diskspd-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DotNet.AspNetCore.10

- **版本**: 10.0.7
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-10-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-10-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.AspNetCore.6

- **版本**: 6.0.36
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-6-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-6-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.AspNetCore.8

- **版本**: 8.0.26
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-8-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-8-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.AspNetCore.9

- **版本**: 9.0.15
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-9-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-aspnetcore-9-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.DesktopRuntime.10

- **版本**: 10.0.7
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-10-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-10-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.DesktopRuntime.6

- **版本**: 6.0.36
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-6-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-6-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.DesktopRuntime.8

- **版本**: 8.0.26
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-8-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-8-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.DesktopRuntime.9

- **版本**: 9.0.15
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-9-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-desktopruntime-9-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.Framework.DeveloperPack.4.6

- **版本**: 4.6.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/e/e/c/*/NDP462-DevPack-KB3151934-ENU.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-framework-developerpack-4-6-path`

```
targetUrls:
  - download.microsoft.com/download/e/e/c/*/NDP462-DevPack-KB3151934-ENU.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-framework-developerpack-4-6-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DotNet.Framework.DeveloperPack_4

- **版本**: 4.8.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-framework-developerpack_4-path`

```
targetUrls:
  - download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-framework-developerpack_4-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DotNet.Framework.Runtime

- **版本**: 4.8.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-framework-runtime-path`

```
targetUrls:
  - download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-framework-runtime-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DotNet.HostingBundle.10

- **版本**: 10.0.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-10-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-10-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.HostingBundle.6

- **版本**: 6.0.36
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-6-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-6-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.HostingBundle.8

- **版本**: 8.0.26
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-8-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-8-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.HostingBundle.9

- **版本**: 9.0.15
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-9-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-hostingbundle-9-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.RepairTool

- **版本**: 1.4
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-repairtool-path`

```
targetUrls:
  - download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-repairtool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.DotNet.Runtime.10

- **版本**: 10.0.7
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-runtime-10-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-runtime-10-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.Runtime.6

- **版本**: 6.0.36
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-runtime-6-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-runtime-6-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.Runtime.8

- **版本**: 8.0.26
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-runtime-8-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-runtime-8-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.Runtime.9

- **版本**: 9.0.15
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-runtime-9-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-runtime-9-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.SDK.10

- **版本**: 10.0.203
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-sdk-10-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-sdk-10-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.SDK.6

- **版本**: 6.0.428
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-sdk-6-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-sdk-6-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.SDK.8

- **版本**: 8.0.420
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-sdk-8-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-sdk-8-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.SDK.9

- **版本**: 9.0.313
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 200 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 403 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `builds.dotnet.microsoft.com` | 206 | ✅ 最終目標 | `builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-sdk-9-path`

```
targetUrls:
  - builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-sdk-9-fqdn`

```
targetFqdns:
  - builds.dotnet.microsoft.com
```

---

## 📦 Microsoft.DotNet.UninstallTool

- **版本**: 1.7.661902
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-uninstalltool-path`

```
targetUrls:
  - github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-uninstalltool-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.DotNet.dotnet-ef

- **版本**: 10.0.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `globalcdn.nuget.org` | 403 | ✅ 最終目標 | `globalcdn.nuget.org/packages/dotnet-ef.*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-dotnet-dotnet-ef-path`

```
targetUrls:
  - globalcdn.nuget.org/packages/dotnet-ef.*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-dotnet-dotnet-ef-fqdn`

```
targetFqdns:
  - globalcdn.nuget.org
```

---

## 📦 Microsoft.Edge

- **版本**: 147.0.3912.86
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-edge-path`

```
targetUrls:
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-edge-fqdn`

```
targetFqdns:
  - msedge.sf.dl.delivery.mp.microsoft.com
```

---

## 📦 Microsoft.EdgeDriver

- **版本**: 147.0.3912.86
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedgedriver.microsoft.com` | 200 | ✅ 最終目標 | `msedgedriver.microsoft.com/*/edgedriver_win32.zip` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedgedriver.microsoft.com` | 200 | ✅ 最終目標 | `msedgedriver.microsoft.com/*/edgedriver_win64.zip` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedgedriver.microsoft.com` | 200 | ✅ 最終目標 | `msedgedriver.microsoft.com/*/edgedriver_arm64.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-edgedriver-path`

```
targetUrls:
  - msedgedriver.microsoft.com/*/edgedriver_arm64.zip
  - msedgedriver.microsoft.com/*/edgedriver_win32.zip
  - msedgedriver.microsoft.com/*/edgedriver_win64.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-edgedriver-fqdn`

```
targetFqdns:
  - msedgedriver.microsoft.com
```

---

## 📦 Microsoft.EdgeWebView2Runtime

- **版本**: 147.0.3912.98
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe` |

**安裝檔 2** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe` |

**安裝檔 3** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msedge.sf.dl.delivery.mp.microsoft.com` | 200 | ✅ 最終目標 | `msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-edgewebview2runtime-path`

```
targetUrls:
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe
  - msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-edgewebview2runtime-fqdn`

```
targetFqdns:
  - msedge.sf.dl.delivery.mp.microsoft.com
```

---

## 📦 Microsoft.Edit

- **版本**: 2.0.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/edit/releases/download/*/edit-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/edit/releases/download/*/edit-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-edit-path`

```
targetUrls:
  - github.com/microsoft/edit/releases/download/*/edit-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-edit-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.EnterpriseStateClassify

- **版本**: 1.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-enterprisestateclassify-path`

```
targetUrls:
  - github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-enterprisestateclassify-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.EventLogExpert

- **版本**: 25.12.11.1105
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-eventlogexpert-path`

```
targetUrls:
  - github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-eventlogexpert-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.FRSDiag

- **版本**: 1.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/4/c/5/*/frsdiag.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-frsdiag-path`

```
targetUrls:
  - download.microsoft.com/download/4/c/5/*/frsdiag.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-frsdiag-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.FSLogix

- **版本**: 3.26.126.19110
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/FSLogix_26.01_CU1.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-fslogix-path`

```
targetUrls:
  - download.microsoft.com/download/*/FSLogix_26.01_CU1.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-fslogix-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.FoundryLocal

- **版本**: 0.8.119.102
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `foundry.onnxruntime.ai` | 200 | ✅ 最終目標 | `foundry.onnxruntime.ai/FoundryLocal-x64-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `foundry.onnxruntime.ai` | 200 | ✅ 最終目標 | `foundry.onnxruntime.ai/FoundryLocal-arm64-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-foundrylocal-path`

```
targetUrls:
  - foundry.onnxruntime.ai/FoundryLocal-arm64-*
  - foundry.onnxruntime.ai/FoundryLocal-x64-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-foundrylocal-fqdn`

```
targetFqdns:
  - foundry.onnxruntime.ai
```

---

## 📦 Microsoft.FuzzyLookupAddExcel

- **版本**: 1.3.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/9/8/*/Setup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-fuzzylookupaddexcel-path`

```
targetUrls:
  - download.microsoft.com/download/1/9/8/*/Setup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-fuzzylookupaddexcel-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.GameInput

- **版本**: 3.3.195.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoftconnect/GameInput/releases/download/*/GameInputRedist.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1008697947/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-gameinput-path`

```
targetUrls:
  - github.com/microsoftconnect/GameInput/releases/download/*/GameInputRedist.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1008697947/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-gameinput-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Garnet.DN8

- **版本**: 1.0.83
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-garnet-dn8-path`

```
targetUrls:
  - github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip
  - github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-garnet-dn8-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Garnet.DN9

- **版本**: 1.0.83
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-garnet-dn9-path`

```
targetUrls:
  - github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip
  - github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-garnet-dn9-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Git

- **版本**: 2.53.0.0.7
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/git/releases/download/*/Git-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*` |

**安裝檔 2** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/git/releases/download/*/Git-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-git-path`

```
targetUrls:
  - github.com/microsoft/git/releases/download/*/Git-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-git-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.GlobalSecureAccessClient

- **版本**: 2.26.108
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.msappproxy.net` | 404 | ✅ 最終目標 | `download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-globalsecureaccessclient-path`

```
targetUrls:
  - download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-globalsecureaccessclient-fqdn`

```
targetFqdns:
  - download.msappproxy.net
```

---

## 📦 Microsoft.HIDTools.Waratah

- **版本**: 1.90
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-hidtools-waratah-path`

```
targetUrls:
  - github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-hidtools-waratah-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.HwpConverter

- **版本**: 15.0.4454.1506
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe` |

**安裝檔 4** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-hwpconverter-path`

```
targetUrls:
  - download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe
  - download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe
  - download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe
  - download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-hwpconverter-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.IIS.Compression

- **版本**: 1.0.06502
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-iis-compression-path`

```
targetUrls:
  - download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi
  - download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-iis-compression-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.IIS.ServiceMonitor

- **版本**: 2.0.1.10
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-iis-servicemonitor-path`

```
targetUrls:
  - github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-iis-servicemonitor-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.IIS.URLRewrite

- **版本**: 7.2.1993
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-iis-urlrewrite-path`

```
targetUrls:
  - download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi
  - download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-iis-urlrewrite-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.IISManagerRemoteAdministration

- **版本**: 1.2
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-iismanagerremoteadministration-path`

```
targetUrls:
  - download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi
  - download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-iismanagerremoteadministration-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.IdFix

- **版本**: 2.6.0.3
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*` |
| 2 | `raw.githubusercontent.com` | 200 | ✅ 最終目標 | `raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-idfix-path`

```
targetUrls:
  - github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*
  - raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-idfix-fqdn`

```
targetFqdns:
  - github.com
  - raw.githubusercontent.com
```

---

## 📦 Microsoft.IntegrationRuntime

- **版本**: 5.65.9593.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-integrationruntime-path`

```
targetUrls:
  - download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-integrationruntime-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.IntuneWSLPlugin

- **版本**: 1.25.4.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi` |
| 2 | `raw.githubusercontent.com` | 200 | ✅ 最終目標 | `raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-intunewslplugin-path`

```
targetUrls:
  - github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi
  - raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-intunewslplugin-fqdn`

```
targetFqdns:
  - github.com
  - raw.githubusercontent.com
```

---

## 📦 Microsoft.IronPython.3

- **版本**: 3.4.2.1000
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-ironpython-3-path`

```
targetUrls:
  - github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-ironpython-3-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Kanagawa

- **版本**: 1.2.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/kanagawa/releases/download/*/kanagawa-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-kanagawa-path`

```
targetUrls:
  - github.com/microsoft/kanagawa/releases/download/*/kanagawa-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-kanagawa-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.LAPS

- **版本**: 6.2.0.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/C/7/A/*/LAPS.x86.msi` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/C/7/A/*/LAPS.x64.msi` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-laps-path`

```
targetUrls:
  - download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi
  - download.microsoft.com/download/C/7/A/*/LAPS.x64.msi
  - download.microsoft.com/download/C/7/A/*/LAPS.x86.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-laps-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.LightGBM

- **版本**: 4.6.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-lightgbm-path`

```
targetUrls:
  - github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-lightgbm-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.LingeringObjectLiquidator

- **版本**: 2.0.21
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-lingeringobjectliquidator-path`

```
targetUrls:
  - download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-lingeringobjectliquidator-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.LogCheetah

- **版本**: 1.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-logcheetah-path`

```
targetUrls:
  - github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-logcheetah-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.LogParser

- **版本**: 2.2.10
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/f/f/1/*/LogParser.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-logparser-path`

```
targetUrls:
  - download.microsoft.com/download/f/f/1/*/LogParser.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-logparser-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.M365AgentsPlayground

- **版本**: 0.2.24
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-m365agentsplayground-path`

```
targetUrls:
  - github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-m365agentsplayground-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MFCMapi

- **版本**: 26.0.26111.02
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mfcmapi-path`

```
targetUrls:
  - github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*
  - github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mfcmapi-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MIDI.FeatureEnablementChecker

- **版本**: 1.1
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-midi-featureenablementchecker-path`

```
targetUrls:
  - github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip
  - github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-midi-featureenablementchecker-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MIDI.SDK

- **版本**: 1.0.16-rc.3.7
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-midi-sdk-path`

```
targetUrls:
  - github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-midi-sdk-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MITT

- **版本**: 8.03
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/7/0/*/MITT.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mitt-path`

```
targetUrls:
  - download.microsoft.com/download/7/7/0/*/MITT.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mitt-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MSIX-Toolkit

- **版本**: 10.0.19041.1
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-msix-toolkit-path`

```
targetUrls:
  - github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip
  - github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-msix-toolkit-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MSIXCore

- **版本**: 1.2.0.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*` |

**安裝檔 3** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-msixcore-path`

```
targetUrls:
  - github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip
  - github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-msixcore-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.MSIXPackagingTool

- **版本**: 1.2024.405.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-msixpackagingtool-path`

```
targetUrls:
  - download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-msixpackagingtool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MUTT

- **版本**: 3.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/MUTTPackage-3_0_0.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mutt-path`

```
targetUrls:
  - download.microsoft.com/download/*/MUTTPackage-3_0_0.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mutt-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MaliciousSoftwareRemovalTool

- **版本**: 5.139
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-malicioussoftwareremovaltool-path`

```
targetUrls:
  - download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe
  - download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-malicioussoftwareremovaltool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MediaCreationTool

- **版本**: 10.0.26100.7019
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/MediaCreationTool.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mediacreationtool-path`

```
targetUrls:
  - download.microsoft.com/download/*/MediaCreationTool.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mediacreationtool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MouseWithoutBorders

- **版本**: 2.2.1.327
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mousewithoutborders-path`

```
targetUrls:
  - download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mousewithoutborders-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.MouseandKeyboardCenter

- **版本**: 14.41.137.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-mouseandkeyboardcenter-path`

```
targetUrls:
  - download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe
  - download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe
  - download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-mouseandkeyboardcenter-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Ntttcp

- **版本**: 5.40.0.99012574
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-ntttcp-path`

```
targetUrls:
  - github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe
  - github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-ntttcp-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.NuGet

- **版本**: 7.3.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `dist.nuget.org` | 200 | ✅ 最終目標 | `dist.nuget.org/win-x86-commandline/*/nuget.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-nuget-path`

```
targetUrls:
  - dist.nuget.org/win-x86-commandline/*/nuget.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-nuget-fqdn`

```
targetFqdns:
  - dist.nuget.org
```

---

## 📦 Microsoft.OSCDIMG

- **版本**: 2.56
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `msdl.microsoft.com` | 302 | ↪️ 重導向 | `msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe` |
| 2 | `vsblobprodscussu5shard61.blob.core.windows.net` | 403 | ✅ 最終目標 | `vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-oscdimg-path`

```
targetUrls:
  - msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe
  - vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-oscdimg-fqdn`

```
targetFqdns:
  - msdl.microsoft.com
  - vsblobprodscussu5shard61.blob.core.windows.net
```

---

## 📦 Microsoft.OSConfig

- **版本**: 1.3.10.13
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/osconfig/releases/download/*/oscfg-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*` |

**安裝檔 3** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/osconfig/releases/download/*/oscfg-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-osconfig-path`

```
targetUrls:
  - github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*
  - github.com/microsoft/osconfig/releases/download/*/oscfg-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-osconfig-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Office

- **版本**: 16.0.19929.20062
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `officecdn.microsoft.com` | 200 | ✅ 最終目標 | `officecdn.microsoft.com/pr/wsus/setup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-office-path`

```
targetUrls:
  - officecdn.microsoft.com/pr/wsus/setup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-office-fqdn`

```
targetFqdns:
  - officecdn.microsoft.com
```

---

## 📦 Microsoft.OfficeDeploymentTool

- **版本**: 16.0.19929.20062
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-officedeploymenttool-path`

```
targetUrls:
  - download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-officedeploymenttool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.OneDrive

- **版本**: 26.062.0402.0002
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `oneclient.sfx.ms` | 200 | ✅ 最終目標 | `oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe` |

**安裝檔 2** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `oneclient.sfx.ms` | 200 | ✅ 最終目標 | `oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe` |

**安裝檔 3** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `oneclient.sfx.ms` | 200 | ✅ 最終目標 | `oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-onedrive-path`

```
targetUrls:
  - oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe
  - oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe
  - oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-onedrive-fqdn`

```
targetFqdns:
  - oneclient.sfx.ms
```

---

## 📦 Microsoft.OneLakeFileExplorer

- **版本**: 1.0.14.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/OneLake_PuPr_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-onelakefileexplorer-path`

```
targetUrls:
  - download.microsoft.com/download/*/OneLake_PuPr_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-onelakefileexplorer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.OneNoteDiagnostics

- **版本**: 1.0.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-onenotediagnostics-path`

```
targetUrls:
  - download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-onenotediagnostics-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.OpenAPI.Hidi

- **版本**: 3.1.2.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openapi-hidi-path`

```
targetUrls:
  - github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openapi-hidi-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.OpenAPI.Kiota

- **版本**: 1.30.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/kiota/releases/download/*/win-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/kiota/releases/download/*/win-x86.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/kiota/releases/download/*/win-arm64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openapi-kiota-path`

```
targetUrls:
  - github.com/microsoft/kiota/releases/download/*/win-arm64.zip
  - github.com/microsoft/kiota/releases/download/*/win-x64.zip
  - github.com/microsoft/kiota/releases/download/*/win-x86.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openapi-kiota-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.OpenCLGLVulkanCompatibilityPack

- **版本**: 1.2404.1.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openclglvulkancompatibilitypack-path`

```
targetUrls:
  - github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openclglvulkancompatibilitypack-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.OpenJDK.11

- **版本**: 11.0.30.7
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openjdk-11-path`

```
targetUrls:
  - aka.ms/download-JDK/microsoft-JDK-*
  - download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openjdk-11-fqdn`

```
targetFqdns:
  - aka.ms
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.OpenJDK.17

- **版本**: 17.0.18.8
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openjdk-17-path`

```
targetUrls:
  - aka.ms/download-JDK/microsoft-JDK-*
  - download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openjdk-17-fqdn`

```
targetFqdns:
  - aka.ms
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.OpenJDK.21

- **版本**: 21.0.10.7
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openjdk-21-path`

```
targetUrls:
  - aka.ms/download-JDK/microsoft-JDK-*
  - download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openjdk-21-fqdn`

```
targetFqdns:
  - aka.ms
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.OpenJDK.25

- **版本**: 25.0.2.10
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/download-JDK/microsoft-JDK-*` |
| 2 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-openjdk-25-path`

```
targetUrls:
  - aka.ms/download-JDK/microsoft-JDK-*
  - download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-openjdk-25-fqdn`

```
targetFqdns:
  - aka.ms
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.PICT

- **版本**: 3.7.4.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/pict/releases/download/*/pict.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-pict-path`

```
targetUrls:
  - github.com/microsoft/pict/releases/download/*/pict.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-pict-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.PIX

- **版本**: 2603.25
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-pix-path`

```
targetUrls:
  - download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe
  - download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-pix-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Pave

- **版本**: 0.1.1
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-pave-path`

```
targetUrls:
  - github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip
  - github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-pave-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.PerfView

- **版本**: 3.2.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/perfview/releases/download/*/PerfView.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-perfview-path`

```
targetUrls:
  - github.com/microsoft/perfview/releases/download/*/PerfView.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-perfview-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.PowerAppsCLI

- **版本**: 1.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerappscli-path`

```
targetUrls:
  - download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerappscli-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerAutomateDesktop

- **版本**: 2.67.00143.26090
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerautomatedesktop-path`

```
targetUrls:
  - download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerautomatedesktop-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerAutomateProcessMining

- **版本**: 6.1.2506.2252
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerautomateprocessmining-path`

```
targetUrls:
  - download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerautomateprocessmining-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerBI

- **版本**: 2.153.910.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerbi-path`

```
targetUrls:
  - download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerbi-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerBIReportBuilder

- **版本**: 15.7.1817.11
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerbireportbuilder-path`

```
targetUrls:
  - download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerbireportbuilder-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerBIReportServer

- **版本**: 1.25.9558.32914
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powerbireportserver-path`

```
targetUrls:
  - download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powerbireportserver-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.PowerShell

- **版本**: 7.6.1.0
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*` |

**安裝檔 2** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*` |

**安裝檔 3** — `x86` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*` |

**安裝檔 4** — `arm` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powershell-path`

```
targetUrls:
  - github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powershell-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.PowerToys

- **版本**: 0.99.1
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*` |

**安裝檔 2** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*` |

**安裝檔 3** — `arm64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*` |

**安裝檔 4** — `arm64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-powertoys-path`

```
targetUrls:
  - github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*
  - github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-powertoys-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.PrintMetadataTroubleshooter

- **版本**: 1.0.0.1
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe` |

**安裝檔 4** — `arm` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-printmetadatatroubleshooter-path`

```
targetUrls:
  - download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe
  - download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe
  - download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe
  - download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-printmetadatatroubleshooter-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.ProfileExplorer

- **版本**: 1.2.1
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-profileexplorer-path`

```
targetUrls:
  - github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-profileexplorer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.ProjectTelescope

- **版本**: 0.15.1
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-projecttelescope-path`

```
targetUrls:
  - github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi
  - github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-projecttelescope-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Promptflow

- **版本**: 1.17.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `promptflowartifact.blob.core.windows.net` | 403 | ✅ 最終目標 | `promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-promptflow-path`

```
targetUrls:
  - promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-promptflow-fqdn`

```
targetFqdns:
  - promptflowartifact.blob.core.windows.net
```

---

## 📦 Microsoft.PurviewInformationProtection

- **版本**: 3.2.57.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/PurviewInfoProtection.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-purviewinformationprotection-path`

```
targetUrls:
  - download.microsoft.com/download/*/PurviewInfoProtection.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-purviewinformationprotection-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.RMSClient

- **版本**: 1.0.5406.9
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-rmsclient-path`

```
targetUrls:
  - download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe
  - download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-rmsclient-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.RemoteDesktopClient

- **版本**: 1.2.7099.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 200 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-remotedesktopclient-path`

```
targetUrls:
  - res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-remotedesktopclient-fqdn`

```
targetFqdns:
  - res.cdn.office.net
```

---

## 📦 Microsoft.RemoteDesktopMMRService

- **版本**: 1.0.2507.21006
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `intstreamreleases.z22.web.core.windows.net` | 200 | ✅ 最終目標 | `intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-remotedesktopmmrservice-path`

```
targetUrls:
  - intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-remotedesktopmmrservice-fqdn`

```
targetFqdns:
  - intstreamreleases.z22.web.core.windows.net
```

---

## 📦 Microsoft.RemoteHelp

- **版本**: 5.1.1998.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `catalog.s.download.windowsupdate.com` | 200 | ✅ 最終目標 | `catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-remotehelp-path`

```
targetUrls:
  - catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-remotehelp-fqdn`

```
targetFqdns:
  - catalog.s.download.windowsupdate.com
```

---

## 📦 Microsoft.ReportBuilder

- **版本**: 15.1.30001.02
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/5/E/B/*/ReportBuilder.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-reportbuilder-path`

```
targetUrls:
  - download.microsoft.com/download/5/E/B/*/ReportBuilder.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-reportbuilder-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SBOMTool

- **版本**: 4.1.5
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sbomtool-path`

```
targetUrls:
  - github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sbomtool-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.SQLServer.2019.Developer

- **版本**: 15.2204.5490.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2019-developer-path`

```
targetUrls:
  - download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2019-developer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.2019.Express

- **版本**: 15.2204.5490.2
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2019-express-path`

```
targetUrls:
  - download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2019-express-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.2022.Developer

- **版本**: 16.0.1000.6
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2022-developer-path`

```
targetUrls:
  - download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2022-developer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.2022.Express

- **版本**: 16.0.1000.6
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2022-express-path`

```
targetUrls:
  - download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2022-express-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.2025.Developer

- **版本**: 17.0.1000.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2025-developer-path`

```
targetUrls:
  - download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2025-developer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.2025.Express

- **版本**: 17.0.1000.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-2025-express-path`

```
targetUrls:
  - download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-2025-express-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.OLEDBDriver

- **版本**: 19.4.1.0
- **安裝檔數量**: 13

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1033/msoledbsql.msi` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1031/msoledbsql.msi` |

**安裝檔 3** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1036/msoledbsql.msi` |

**安裝檔 4** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1040/msoledbsql.msi` |

**安裝檔 5** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/2052/msoledbsql.msi` |

**安裝檔 6** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1028/msoledbsql.msi` |

**安裝檔 7** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1029/msoledbsql.msi` |

**安裝檔 8** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1041/msoledbsql.msi` |

**安裝檔 9** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1055/msoledbsql.msi` |

**安裝檔 10** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/3082/msoledbsql.msi` |

**安裝檔 11** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1046/msoledbsql.msi` |

**安裝檔 12** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1045/msoledbsql.msi` |

**安裝檔 13** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1042/msoledbsql.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-oledbdriver-path`

```
targetUrls:
  - download.microsoft.com/download/*/amd64/1028/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1029/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1031/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1033/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1036/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1040/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1041/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1042/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1045/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1046/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/1055/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/2052/msoledbsql.msi
  - download.microsoft.com/download/*/amd64/3082/msoledbsql.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-oledbdriver-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServer.RMLUtilities

- **版本**: 09.04.0103
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/5/8/*/RMLSetup.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlserver-rmlutilities-path`

```
targetUrls:
  - download.microsoft.com/download/6/5/8/*/RMLSetup.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlserver-rmlutilities-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SQLServerManagementStudio

- **版本**: 20.2.1
- **安裝檔數量**: 11

### 下載路徑分析

**安裝檔 1** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-DEU.exe` |

**安裝檔 2** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-ENU.exe` |

**安裝檔 3** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-ESN.exe` |

**安裝檔 4** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-FRA.exe` |

**安裝檔 5** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-ITA.exe` |

**安裝檔 6** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-JPN.exe` |

**安裝檔 7** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-KOR.exe` |

**安裝檔 8** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-PTB.exe` |

**安裝檔 9** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-RUS.exe` |

**安裝檔 10** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-CHS.exe` |

**安裝檔 11** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SSMS-Setup-CHT.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlservermanagementstudio-path`

```
targetUrls:
  - download.microsoft.com/download/*/SSMS-Setup-CHS.exe
  - download.microsoft.com/download/*/SSMS-Setup-CHT.exe
  - download.microsoft.com/download/*/SSMS-Setup-DEU.exe
  - download.microsoft.com/download/*/SSMS-Setup-ENU.exe
  - download.microsoft.com/download/*/SSMS-Setup-ESN.exe
  - download.microsoft.com/download/*/SSMS-Setup-FRA.exe
  - download.microsoft.com/download/*/SSMS-Setup-ITA.exe
  - download.microsoft.com/download/*/SSMS-Setup-JPN.exe
  - download.microsoft.com/download/*/SSMS-Setup-KOR.exe
  - download.microsoft.com/download/*/SSMS-Setup-PTB.exe
  - download.microsoft.com/download/*/SSMS-Setup-RUS.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlservermanagementstudio-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SaRACmd

- **版本**: 17.01.3954.000
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-saracmd-path`

```
targetUrls:
  - download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-saracmd-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SafetyScanner

- **版本**: 1.449.54.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `definitionupdates.microsoft.com` | 200 | ✅ 最終目標 | `definitionupdates.microsoft.com/packages/content/msert.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `definitionupdates.microsoft.com` | 200 | ✅ 最終目標 | `definitionupdates.microsoft.com/packages/content/msert.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-safetyscanner-path`

```
targetUrls:
  - definitionupdates.microsoft.com/packages/content/msert.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-safetyscanner-fqdn`

```
targetFqdns:
  - definitionupdates.microsoft.com
```

---

## 📦 Microsoft.ScreenRecorder

- **版本**: 0.1.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-screenrecorder-path`

```
targetUrls:
  - github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-screenrecorder-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.SecurityComplianceToolkit.LGPO

- **版本**: 3.0.2004.13001
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/5/c/*/LGPO.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-lgpo-path`

```
targetUrls:
  - download.microsoft.com/download/8/5/c/*/LGPO.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-lgpo-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SecurityComplianceToolkit.PolicyAnalyzer

- **版本**: 4.0.2004.13001
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-policyanalyzer-path`

```
targetUrls:
  - download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-policyanalyzer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SecurityComplianceToolkit.SetObjectSecurity

- **版本**: 1.0.2004.13001
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-setobjectsecurity-path`

```
targetUrls:
  - download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-securitycompliancetoolkit-setobjectsecurity-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.ServiceFabricRuntime

- **版本**: 11.3.475.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-servicefabricruntime-path`

```
targetUrls:
  - download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-servicefabricruntime-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.ServiceFabricSDK

- **版本**: 8.3.475
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-servicefabricsdk-path`

```
targetUrls:
  - download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-servicefabricsdk-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SetupDiag

- **版本**: 1.7.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/1/1/*/SetupDiag.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-setupdiag-path`

```
targetUrls:
  - download.microsoft.com/download/1/1/1/*/SetupDiag.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-setupdiag-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SmartDump

- **版本**: 1.13
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-smartdump-path`

```
targetUrls:
  - github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-smartdump-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.SqlPackage

- **版本**: 170.3.93
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `go.microsoft.com` | 302 | ↪️ 重導向 | `go.microsoft.com/fwlink/` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/sqlpackage-win-x64-en-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlpackage-path`

```
targetUrls:
  - download.microsoft.com/download/*/sqlpackage-win-x64-en-*
  - go.microsoft.com/fwlink/
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlpackage-fqdn`

```
targetFqdns:
  - download.microsoft.com
  - go.microsoft.com
```

---

## 📦 Microsoft.Sqlcmd

- **版本**: 1.9.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*` |

**安裝檔 2** — `arm` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sqlcmd-path`

```
targetUrls:
  - github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi
  - github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi
  - github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sqlcmd-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.SurfaceApp

- **版本**: 75.11130.117.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 404 | ✅ 最終目標 | `download.microsoft.com/download/*/Microsoft.SurfaceHub_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-surfaceapp-path`

```
targetUrls:
  - download.microsoft.com/download/*/Microsoft.SurfaceHub_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-surfaceapp-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SurfaceHubRecoveryTool

- **版本**: 2.7.139.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-surfacehubrecoverytool-path`

```
targetUrls:
  - download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-surfacehubrecoverytool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.SymCryptUnitTest

- **版本**: 103.8.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-symcryptunittest-path`

```
targetUrls:
  - github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*
  - github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-symcryptunittest-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Sysinternals.Autologon

- **版本**: 3.10
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/AutoLogon.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-autologon-path`

```
targetUrls:
  - download.sysinternals.com/files/AutoLogon.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-autologon-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Autoruns

- **版本**: 14.11
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/Autoruns.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-autoruns-path`

```
targetUrls:
  - download.sysinternals.com/files/Autoruns.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-autoruns-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.BGInfo

- **版本**: 4.33
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/BGInfo.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-bginfo-path`

```
targetUrls:
  - download.sysinternals.com/files/BGInfo.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-bginfo-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Ctrl2Cap

- **版本**: 3.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Ctrl2Cap.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-ctrl2cap-path`

```
targetUrls:
  - download.sysinternals.com/files/Ctrl2Cap.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-ctrl2cap-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.DebugView

- **版本**: 5.00
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/DebugView.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-debugview-path`

```
targetUrls:
  - download.sysinternals.com/files/DebugView.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-debugview-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Desktops

- **版本**: 2.01
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Desktops.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-desktops-path`

```
targetUrls:
  - download.sysinternals.com/files/Desktops.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-desktops-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.FindLinks

- **版本**: 1.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/FindLinks.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-findlinks-path`

```
targetUrls:
  - download.sysinternals.com/files/FindLinks.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-findlinks-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Handle

- **版本**: 5.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Handle.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-handle-path`

```
targetUrls:
  - download.sysinternals.com/files/Handle.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-handle-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.MoveFile

- **版本**: 1.02
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/pendmoves.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-movefile-path`

```
targetUrls:
  - download.sysinternals.com/files/pendmoves.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-movefile-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.PendMoves

- **版本**: 1.3
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/pendmoves.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-pendmoves-path`

```
targetUrls:
  - download.sysinternals.com/files/pendmoves.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-pendmoves-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.ProcessExplorer

- **版本**: 17.11
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/ProcessExplorer.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-processexplorer-path`

```
targetUrls:
  - download.sysinternals.com/files/ProcessExplorer.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-processexplorer-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.ProcessMonitor

- **版本**: 4.01
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 200 | ✅ 最終目標 | `download.sysinternals.com/files/ProcessMonitor.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-processmonitor-path`

```
targetUrls:
  - download.sysinternals.com/files/ProcessMonitor.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-processmonitor-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.RAMMap

- **版本**: 1.63
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/RAMMap.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-rammap-path`

```
targetUrls:
  - download.sysinternals.com/files/RAMMap.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-rammap-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.RDCMan

- **版本**: 3.12
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/RDCMan.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-rdcman-path`

```
targetUrls:
  - download.sysinternals.com/files/RDCMan.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-rdcman-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.RegJump

- **版本**: 1.11
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/regjump.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-regjump-path`

```
targetUrls:
  - download.sysinternals.com/files/regjump.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-regjump-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.SDelete

- **版本**: 2.06
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/SDelete.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-sdelete-path`

```
targetUrls:
  - download.sysinternals.com/files/SDelete.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-sdelete-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Sigcheck

- **版本**: 2.91
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Sigcheck.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-sigcheck-path`

```
targetUrls:
  - download.sysinternals.com/files/Sigcheck.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-sigcheck-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Strings

- **版本**: 2.54
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Strings.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-strings-path`

```
targetUrls:
  - download.sysinternals.com/files/Strings.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-strings-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Sysmon

- **版本**: 15.20
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/Sysmon.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-sysmon-path`

```
targetUrls:
  - download.sysinternals.com/files/Sysmon.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-sysmon-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.TCPView

- **版本**: 4.19
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/TCPView.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-tcpview-path`

```
targetUrls:
  - download.sysinternals.com/files/TCPView.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-tcpview-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.VMMap

- **版本**: 3.40
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/VMMap.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-vmmap-path`

```
targetUrls:
  - download.sysinternals.com/files/VMMap.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-vmmap-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.Whois

- **版本**: 1.21
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 206 | ✅ 最終目標 | `download.sysinternals.com/files/WhoIs.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-whois-path`

```
targetUrls:
  - download.sysinternals.com/files/WhoIs.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-whois-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.Sysinternals.ZoomIt

- **版本**: 11.00
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.sysinternals.com` | 403 | ✅ 最終目標 | `download.sysinternals.com/files/ZoomIt.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-sysinternals-zoomit-path`

```
targetUrls:
  - download.sysinternals.com/files/ZoomIt.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-sysinternals-zoomit-fqdn`

```
targetFqdns:
  - download.sysinternals.com
```

---

## 📦 Microsoft.TeamMate

- **版本**: 0.1.15
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-teammate-path`

```
targetUrls:
  - github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-teammate-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Teams

- **版本**: 26072.521.4595.7966
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `installer.teams.static.microsoft` | 200 | ✅ 最終目標 | `installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `installer.teams.static.microsoft` | 200 | ✅ 最終目標 | `installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `installer.teams.static.microsoft` | 200 | ✅ 最終目標 | `installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-teams-path`

```
targetUrls:
  - installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix
  - installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix
  - installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-teams-fqdn`

```
targetFqdns:
  - installer.teams.static.microsoft
```

---

## 📦 Microsoft.TeamsTxNDI

- **版本**: 2024.8.1.14
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `teams.microsoft.com` | 403 | ✅ 最終目標 | `teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-teamstxndi-path`

```
targetUrls:
  - teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-teamstxndi-fqdn`

```
targetFqdns:
  - teams.microsoft.com
```

---

## 📦 Microsoft.TimeTravelDebugging

- **版本**: 1.11.584.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `windbg.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-timetraveldebugging-path`

```
targetUrls:
  - windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-timetraveldebugging-fqdn`

```
targetFqdns:
  - windbg.download.prss.microsoft.com
```

---

## 📦 Microsoft.Tokenizer

- **版本**: 1.3.3
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-tokenizer-path`

```
targetUrls:
  - github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-tokenizer-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.UI.Xaml.2.7

- **版本**: 7.2208.15002.0
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 3** — `arm` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 4** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-ui-xaml-2-7-path`

```
targetUrls:
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx
  - objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-ui-xaml-2-7-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.UI.Xaml.2.8

- **版本**: 8.2310.30001.0
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 3** — `arm` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

**安裝檔 4** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-ui-xaml-2-8-path`

```
targetUrls:
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx
  - github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx
  - objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-ui-xaml-2-8-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.UpdateAssistant

- **版本**: 1.4.19041.2183
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-updateassistant-path`

```
targetUrls:
  - download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-updateassistant-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VCLibs.14

- **版本**: 14.0.33519.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vclibs-14-path`

```
targetUrls:
  - github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vclibs-14-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.VCLibs.Desktop.14

- **版本**: 14.0.33728.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vclibs-desktop-14-path`

```
targetUrls:
  - github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vclibs-desktop-14-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.VCRedist.2012.x64

- **版本**: 11.0.61030.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2012-x64-path`

```
targetUrls:
  - download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2012-x64-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2012.x86

- **版本**: 11.0.61030.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x86.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2012-x86-path`

```
targetUrls:
  - download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2012-x86-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2013.x64

- **版本**: 12.0.40664.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/10912041/*/vcredist_x64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2013-x64-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/10912041/*/vcredist_x64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2013-x64-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2013.x86

- **版本**: 12.0.40664.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/10912113/*/vcredist_x86.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2013-x86-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/10912113/*/vcredist_x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2013-x86-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2015+.arm64

- **版本**: 14.50.35719.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2015+-arm64-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2015+-arm64-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2015+.x64

- **版本**: 14.50.35719.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2015+-x64-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2015+-x64-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VCRedist.2015+.x86

- **版本**: 14.50.35719.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vcredist-2015+-x86-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vcredist-2015+-x86-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VSDotNetLogCollect

- **版本**: 17.0.35214.149
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/8/3/4/*/Collect.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vsdotnetlogcollect-path`

```
targetUrls:
  - download.microsoft.com/download/8/3/4/*/Collect.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vsdotnetlogcollect-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VSIXBootstrapper

- **版本**: 1.0.37
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vsixbootstrapper-path`

```
targetUrls:
  - github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vsixbootstrapper-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.VSTOR

- **版本**: 10.0.60917
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/5/d/2/*/vstor_redist.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-vstor-path`

```
targetUrls:
  - download.microsoft.com/download/5/d/2/*/vstor_redist.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-vstor-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VisioViewer

- **版本**: 16.0.4339.1001
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visioviewer-path`

```
targetUrls:
  - download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe
  - download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visioviewer-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.2022.BuildTools

- **版本**: 17.14.31
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-2022-buildtools-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-2022-buildtools-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.2022.Enterprise

- **版本**: 17.14.31
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-2022-enterprise-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-2022-enterprise-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.2022.OnecoreMsvsmon

- **版本**: 17.14.6
- **安裝檔數量**: 4

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip` |

**安裝檔 3** — `arm` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip` |

**安裝檔 4** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-2022-onecoremsvsmon-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip
  - download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip
  - download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip
  - download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-2022-onecoremsvsmon-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.2022.Professional

- **版本**: 17.14.31
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `machine`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-2022-professional-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-2022-professional-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.2022.RemoteTools

- **版本**: 17.14.8
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.visualstudio.microsoft.com` | 200 | ✅ 最終目標 | `download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-2022-remotetools-path`

```
targetUrls:
  - download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-2022-remotetools-fqdn`

```
targetFqdns:
  - download.visualstudio.microsoft.com
```

---

## 📦 Microsoft.VisualStudio.ConfigFinder

- **版本**: 1.0.47.55350
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-configfinder-path`

```
targetUrls:
  - github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-configfinder-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.VisualStudio.Extensions.TypeScript

- **版本**: 4.3
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `typescriptteam.gallerycdn.vsassets.io` | 403 | ✅ 最終目標 | `typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-extensions-typescript-path`

```
targetUrls:
  - typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-extensions-typescript-fqdn`

```
targetFqdns:
  - typescriptteam.gallerycdn.vsassets.io
```

---

## 📦 Microsoft.VisualStudio.Locator

- **版本**: 3.1.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/vswhere/releases/download/*/vswhere.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualstudio-locator-path`

```
targetUrls:
  - github.com/microsoft/vswhere/releases/download/*/vswhere.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualstudio-locator-fqdn`

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

## 📦 Microsoft.VisualTrueType

- **版本**: 6.35
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-visualtruetype-path`

```
targetUrls:
  - github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-visualtruetype-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WSL

- **版本**: 2.6.3
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/WSL/releases/download/*/wsl.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/WSL/releases/download/*/wsl.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-wsl-path`

```
targetUrls:
  - github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*
  - github.com/microsoft/WSL/releases/download/*/wsl.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-wsl-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.Wassette

- **版本**: 0.4.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/wassette/releases/download/*/wassette_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/wassette/releases/download/*/wassette_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-wassette-path`

```
targetUrls:
  - github.com/microsoft/wassette/releases/download/*/wassette_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-wassette-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WebDeploy

- **版本**: 10.0.2001
- **安裝檔數量**: 28

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_zh-TW.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_zh-CN.msi` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_tr-TR.msi` |

**安裝檔 4** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_ru-RU.msi` |

**安裝檔 5** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_pt-BR.msi` |

**安裝檔 6** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_pl-PL.msi` |

**安裝檔 7** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_ko-KR.msi` |

**安裝檔 8** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_ja-JP.msi` |

**安裝檔 9** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_it-IT.msi` |

**安裝檔 10** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_fr-FR.msi` |

**安裝檔 11** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_es-ES.msi` |

**安裝檔 12** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_de-DE.msi` |

**安裝檔 13** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_en-US.msi` |

**安裝檔 14** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi` |

**安裝檔 15** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_zh-TW.msi` |

**安裝檔 16** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_zh-CN.msi` |

**安裝檔 17** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_tr-TR.msi` |

**安裝檔 18** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_ru-RU.msi` |

**安裝檔 19** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_pt-BR.msi` |

**安裝檔 20** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_pl-PL.msi` |

**安裝檔 21** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_ko-KR.msi` |

**安裝檔 22** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_ja-JP.msi` |

**安裝檔 23** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_it-IT.msi` |

**安裝檔 24** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_fr-FR.msi` |

**安裝檔 25** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_es-ES.msi` |

**安裝檔 26** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_de-DE.msi` |

**安裝檔 27** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_en-US.msi` |

**安裝檔 28** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-webdeploy-path`

```
targetUrls:
  - download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi
  - download.microsoft.com/download/WebDeploy_x86_de-DE.msi
  - download.microsoft.com/download/WebDeploy_x86_en-US.msi
  - download.microsoft.com/download/WebDeploy_x86_es-ES.msi
  - download.microsoft.com/download/WebDeploy_x86_fr-FR.msi
  - download.microsoft.com/download/WebDeploy_x86_it-IT.msi
  - download.microsoft.com/download/WebDeploy_x86_ja-JP.msi
  - download.microsoft.com/download/WebDeploy_x86_ko-KR.msi
  - download.microsoft.com/download/WebDeploy_x86_pl-PL.msi
  - download.microsoft.com/download/WebDeploy_x86_pt-BR.msi
  - download.microsoft.com/download/WebDeploy_x86_ru-RU.msi
  - download.microsoft.com/download/WebDeploy_x86_tr-TR.msi
  - download.microsoft.com/download/WebDeploy_x86_zh-CN.msi
  - download.microsoft.com/download/WebDeploy_x86_zh-TW.msi
  - download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi
  - download.microsoft.com/download/webdeploy_amd64_de-DE.msi
  - download.microsoft.com/download/webdeploy_amd64_en-US.msi
  - download.microsoft.com/download/webdeploy_amd64_es-ES.msi
  - download.microsoft.com/download/webdeploy_amd64_fr-FR.msi
  - download.microsoft.com/download/webdeploy_amd64_it-IT.msi
  - download.microsoft.com/download/webdeploy_amd64_ja-JP.msi
  - download.microsoft.com/download/webdeploy_amd64_ko-KR.msi
  - download.microsoft.com/download/webdeploy_amd64_pl-PL.msi
  - download.microsoft.com/download/webdeploy_amd64_pt-BR.msi
  - download.microsoft.com/download/webdeploy_amd64_ru-RU.msi
  - download.microsoft.com/download/webdeploy_amd64_tr-TR.msi
  - download.microsoft.com/download/webdeploy_amd64_zh-CN.msi
  - download.microsoft.com/download/webdeploy_amd64_zh-TW.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-webdeploy-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.Win32ContentPrepTool

- **版本**: 1.8.7
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*` |
| 2 | `codeload.github.com` | 200 | ✅ 最終目標 | `codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-win32contentpreptool-path`

```
targetUrls:
  - codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*
  - github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-win32contentpreptool-fqdn`

```
targetFqdns:
  - codeload.github.com
  - github.com
```

---

## 📦 Microsoft.WinAppCli

- **版本**: 0.3.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-winappcli-path`

```
targetUrls:
  - github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix
  - github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix
  - objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-winappcli-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WinDbg

- **版本**: 1.2603.20001.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `windbg.download.prss.microsoft.com` | 200 | ✅ 最終目標 | `windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windbg-path`

```
targetUrls:
  - windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windbg-fqdn`

```
targetFqdns:
  - windbg.download.prss.microsoft.com
```

---

## 📦 Microsoft.WindowsADK

- **版本**: 10.1.28000.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/adk/adksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsadk-path`

```
targetUrls:
  - download.microsoft.com/download/*/adk/adksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsadk-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsAdminCenter

- **版本**: 2.6.6.18
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAdminCenter2511.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsadmincenter-path`

```
targetUrls:
  - download.microsoft.com/download/*/WindowsAdminCenter2511.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsadmincenter-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsApp

- **版本**: 2.0.1071.0
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 200 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsapp-path`

```
targetUrls:
  - res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*
  - res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*
  - res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsapp-fqdn`

```
targetFqdns:
  - res.cdn.office.net
```

---

## 📦 Microsoft.WindowsAppRuntime.1.5

- **版本**: 1.5.8
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x86.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-arm64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsappruntime-1-5-path`

```
targetUrls:
  - aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-arm64.exe
  - aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x64.exe
  - aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x86.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsappruntime-1-5-fqdn`

```
targetFqdns:
  - aka.ms
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsAppRuntime.1.6

- **版本**: 1.6.9
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x86.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-arm64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsappruntime-1-6-path`

```
targetUrls:
  - aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-arm64.exe
  - aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x64.exe
  - aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x86.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsappruntime-1-6-fqdn`

```
targetFqdns:
  - aka.ms
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsAppRuntime.1.7

- **版本**: 1.7.9
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsappruntime-1-7-path`

```
targetUrls:
  - aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe
  - aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe
  - aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsappruntime-1-7-fqdn`

```
targetFqdns:
  - aka.ms
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsAppRuntime.1.8

- **版本**: 1.8.6
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x86.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `aka.ms` | 301 | ↪️ 重導向 | `aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-arm64.exe` |
| 2 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsappruntime-1-8-path`

```
targetUrls:
  - aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-arm64.exe
  - aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x64.exe
  - aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x86.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe
  - download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsappruntime-1-8-fqdn`

```
targetFqdns:
  - aka.ms
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsApplicationDriver

- **版本**: 1.2.1.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsapplicationdriver-path`

```
targetUrls:
  - github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsapplicationdriver-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WindowsBusesTracing

- **版本**: 1.1.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsbusestracing-path`

```
targetUrls:
  - github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip
  - github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsbusestracing-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WindowsCloudIOProtectionDriver

- **版本**: 0.0.693
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res-1.cdn.office.net` | 403 | ✅ 最終目標 | `res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `res-1.cdn.office.net` | 403 | ✅ 最終目標 | `res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowscloudioprotectiondriver-path`

```
targetUrls:
  - res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*
  - res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowscloudioprotectiondriver-fqdn`

```
targetFqdns:
  - res-1.cdn.office.net
```

---

## 📦 Microsoft.WindowsDeviceRecoveryTool

- **版本**: 3.17.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/wdrt-hl1.zip` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsdevicerecoverytool-path`

```
targetUrls:
  - download.microsoft.com/download/*/wdrt-hl1.zip
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsdevicerecoverytool-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsInstallationAssistant

- **版本**: 1.4.19041.6448
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/Windows11InstallationAssistant.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsinstallationassistant-path`

```
targetUrls:
  - download.microsoft.com/download/*/Windows11InstallationAssistant.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsinstallationassistant-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsMIDIServicesSDK

- **版本**: 1.0.14-rc.1.209
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsmidiservicessdk-path`

```
targetUrls:
  - github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsmidiservicessdk-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WindowsPCHealthCheck

- **版本**: 4.0.2410.23001
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi` |

**安裝檔 2** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowspchealthcheck-path`

```
targetUrls:
  - download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi
  - download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowspchealthcheck-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsSDK.10.0.22000

- **版本**: 10.0.22000.832
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/1/0/e/*/windowssdk/winsdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowssdk-10-0-22000-path`

```
targetUrls:
  - download.microsoft.com/download/1/0/e/*/windowssdk/winsdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowssdk-10-0-22000-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsSDK.10.0.22621

- **版本**: 10.0.22621.2428
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowssdk-10-0-22621-path`

```
targetUrls:
  - download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowssdk-10-0-22621-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsSDK.10.0.26100

- **版本**: 10.0.26100.7705
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowssdk-10-0-26100-path`

```
targetUrls:
  - download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowssdk-10-0-26100-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsSDK.10.0.28000

- **版本**: 10.0.28000.1721
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowssdk-10-0-28000-path`

```
targetUrls:
  - download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowssdk-10-0-28000-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsTerminal

- **版本**: 1.24.10921.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsterminal-path`

```
targetUrls:
  - github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsterminal-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.WindowsVirtualDesktopAgent

- **版本**: 1.0.12684.400
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `query.prod.cms.rt.microsoft.com` | 301 | ↪️ 重導向 | `query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv` |
| 2 | `go.microsoft.com` | 302 | ↪️ 重導向 | `go.microsoft.com/fwlink/` |
| 3 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsvirtualdesktopagent-path`

```
targetUrls:
  - go.microsoft.com/fwlink/
  - query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv
  - res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsvirtualdesktopagent-fqdn`

```
targetFqdns:
  - go.microsoft.com
  - query.prod.cms.rt.microsoft.com
  - res.cdn.office.net
```

---

## 📦 Microsoft.WindowsVirtualDesktopBootloader

- **版本**: 1.0.9023.1100
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `query.prod.cms.rt.microsoft.com` | 301 | ↪️ 重導向 | `query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH` |
| 2 | `res.cdn.office.net` | 403 | ✅ 最終目標 | `res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowsvirtualdesktopbootloader-path`

```
targetUrls:
  - query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH
  - res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowsvirtualdesktopbootloader-fqdn`

```
targetFqdns:
  - query.prod.cms.rt.microsoft.com
  - res.cdn.office.net
```

---

## 📦 Microsoft.WindowsWDK.10.0.22000

- **版本**: 10.1.22000.1
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/d/6/*/wdk/wdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowswdk-10-0-22000-path`

```
targetUrls:
  - download.microsoft.com/download/7/d/6/*/wdk/wdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowswdk-10-0-22000-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsWDK.10.0.22621

- **版本**: 10.1.22621.2428
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowswdk-10-0-22621-path`

```
targetUrls:
  - download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowswdk-10-0-22621-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WindowsWDK.10.0.26100

- **版本**: 10.1.26100.6584
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-windowswdk-10-0-26100-path`

```
targetUrls:
  - download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-windowswdk-10-0-26100-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.WingetCreate

- **版本**: 1.12.8.0
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `user`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-wingetcreate-path`

```
targetUrls:
  - github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*
  - github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-wingetcreate-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.XMLNotepad

- **版本**: 2.9.0.21
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*` |

**安裝檔 2** — `neutral` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-xmlnotepad-path`

```
targetUrls:
  - github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*
  - github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip
  - objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-xmlnotepad-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.bitsmanager

- **版本**: 1.12.0.4
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-bitsmanager-path`

```
targetUrls:
  - github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-bitsmanager-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.err

- **版本**: 6.4.5
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/4/3/2/*/Err_*/Err_*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-err-path`

```
targetUrls:
  - download.microsoft.com/download/4/3/2/*/Err_*/Err_*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-err-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.etl2pcapng

- **版本**: 1.11.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-etl2pcapng-path`

```
targetUrls:
  - github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe
  - objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-etl2pcapng-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.msodbcsql.17

- **版本**: 17.10.6.1
- **安裝檔數量**: 22

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/en-US/*/x86/msodbcsql.msi` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/en-US/*/x64/msodbcsql.msi` |

**安裝檔 3** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/de-DE/*/x86/msodbcsql.msi` |

**安裝檔 4** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/de-DE/*/x64/msodbcsql.msi` |

**安裝檔 5** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/es-ES/*/x86/msodbcsql.msi` |

**安裝檔 6** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/es-ES/*/x64/msodbcsql.msi` |

**安裝檔 7** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/fr-FR/*/x86/msodbcsql.msi` |

**安裝檔 8** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/fr-FR/*/x64/msodbcsql.msi` |

**安裝檔 9** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/it-IT/*/x86/msodbcsql.msi` |

**安裝檔 10** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/it-IT/*/x64/msodbcsql.msi` |

**安裝檔 11** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ja-JP/*/x86/msodbcsql.msi` |

**安裝檔 12** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ja-JP/*/x64/msodbcsql.msi` |

**安裝檔 13** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ko-KR/*/x86/msodbcsql.msi` |

**安裝檔 14** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ko-KR/*/x64/msodbcsql.msi` |

**安裝檔 15** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/pt-BR/*/x86/msodbcsql.msi` |

**安裝檔 16** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/pt-BR/*/x64/msodbcsql.msi` |

**安裝檔 17** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ru-RU/*/x86/msodbcsql.msi` |

**安裝檔 18** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/ru-RU/*/x64/msodbcsql.msi` |

**安裝檔 19** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/zh-CN/*/x86/msodbcsql.msi` |

**安裝檔 20** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/zh-CN/*/x64/msodbcsql.msi` |

**安裝檔 21** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/zh-TW/*/x86/msodbcsql.msi` |

**安裝檔 22** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/6/f/f/*/zh-TW/*/x64/msodbcsql.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-msodbcsql-17-path`

```
targetUrls:
  - download.microsoft.com/download/6/f/f/*/de-DE/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/de-DE/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/en-US/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/en-US/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/es-ES/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/es-ES/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/fr-FR/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/fr-FR/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/it-IT/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/it-IT/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ja-JP/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ja-JP/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ko-KR/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ko-KR/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/pt-BR/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/pt-BR/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ru-RU/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/ru-RU/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/zh-CN/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/zh-CN/*/x86/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/zh-TW/*/x64/msodbcsql.msi
  - download.microsoft.com/download/6/f/f/*/zh-TW/*/x86/msodbcsql.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-msodbcsql-17-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.msodbcsql.18

- **版本**: 18.6.2.1
- **安裝檔數量**: 33

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1033/msodbcsql.msi` |

**安裝檔 2** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1033/msodbcsql.msi` |

**安裝檔 3** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1033/msodbcsql.msi` |

**安裝檔 4** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1031/msodbcsql.msi` |

**安裝檔 5** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1031/msodbcsql.msi` |

**安裝檔 6** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1031/msodbcsql.msi` |

**安裝檔 7** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/3082/msodbcsql.msi` |

**安裝檔 8** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/3082/msodbcsql.msi` |

**安裝檔 9** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/3082/msodbcsql.msi` |

**安裝檔 10** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1036/msodbcsql.msi` |

**安裝檔 11** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1036/msodbcsql.msi` |

**安裝檔 12** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1036/msodbcsql.msi` |

**安裝檔 13** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1040/msodbcsql.msi` |

**安裝檔 14** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1040/msodbcsql.msi` |

**安裝檔 15** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1040/msodbcsql.msi` |

**安裝檔 16** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1041/msodbcsql.msi` |

**安裝檔 17** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1041/msodbcsql.msi` |

**安裝檔 18** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1041/msodbcsql.msi` |

**安裝檔 19** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1042/msodbcsql.msi` |

**安裝檔 20** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1042/msodbcsql.msi` |

**安裝檔 21** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1042/msodbcsql.msi` |

**安裝檔 22** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1046/msodbcsql.msi` |

**安裝檔 23** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1046/msodbcsql.msi` |

**安裝檔 24** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1046/msodbcsql.msi` |

**安裝檔 25** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1049/msodbcsql.msi` |

**安裝檔 26** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1049/msodbcsql.msi` |

**安裝檔 27** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1049/msodbcsql.msi` |

**安裝檔 28** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/2052/msodbcsql.msi` |

**安裝檔 29** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/2052/msodbcsql.msi` |

**安裝檔 30** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/2052/msodbcsql.msi` |

**安裝檔 31** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/x86/1028/msodbcsql.msi` |

**安裝檔 32** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/amd64/1028/msodbcsql.msi` |

**安裝檔 33** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `download.microsoft.com` | 200 | ✅ 最終目標 | `download.microsoft.com/download/*/arm64/1028/msodbcsql.msi` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-msodbcsql-18-path`

```
targetUrls:
  - download.microsoft.com/download/*/amd64/1028/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1031/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1033/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1036/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1040/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1041/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1042/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1046/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/1049/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/2052/msodbcsql.msi
  - download.microsoft.com/download/*/amd64/3082/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1028/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1031/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1033/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1036/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1040/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1041/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1042/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1046/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/1049/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/2052/msodbcsql.msi
  - download.microsoft.com/download/*/arm64/3082/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1028/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1031/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1033/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1036/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1040/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1041/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1042/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1046/msodbcsql.msi
  - download.microsoft.com/download/*/x86/1049/msodbcsql.msi
  - download.microsoft.com/download/*/x86/2052/msodbcsql.msi
  - download.microsoft.com/download/*/x86/3082/msodbcsql.msi
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-msodbcsql-18-fqdn`

```
targetFqdns:
  - download.microsoft.com
```

---

## 📦 Microsoft.quicreach

- **版本**: 1.3.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/quicreach/releases/download/*/quicreach.msi` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-quicreach-path`

```
targetUrls:
  - github.com/microsoft/quicreach/releases/download/*/quicreach.msi
  - objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-quicreach-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Microsoft.winfile

- **版本**: 10.4.0.0
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `github.com` | 302 | ↪️ 重導向 | `github.com/microsoft/winfile/releases/download/*/Winfile_*` |
| 2 | `objects.githubusercontent.com` | 401 | ✅ 最終目標 | `objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-microsoft-winfile-path`

```
targetUrls:
  - github.com/microsoft/winfile/releases/download/*/Winfile_*
  - objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-microsoft-winfile-fqdn`

```
targetFqdns:
  - github.com
  - objects.githubusercontent.com
```

---

## 📦 Telerik.Fiddler.Classic

- **版本**: 5.0.20253.3311
- **安裝檔數量**: 1

### 下載路徑分析

**安裝檔 1** — `x86` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `downloads.getfiddler.com` | 200 | ✅ 最終目標 | `downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-telerik-fiddler-classic-path`

```
targetUrls:
  - downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-telerik-fiddler-classic-fqdn`

```
targetFqdns:
  - downloads.getfiddler.com
```

---

## 📦 WiresharkFoundation.Stratoshark

- **版本**: 0.9.3
- **安裝檔數量**: 2

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `1.na.dl.wireshark.org` | 200 | ✅ 最終目標 | `1.na.dl.wireshark.org/win64/Stratoshark-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `1.na.dl.wireshark.org` | 200 | ✅ 最終目標 | `1.na.dl.wireshark.org/win64/Stratoshark-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-wiresharkfoundation-stratoshark-path`

```
targetUrls:
  - 1.na.dl.wireshark.org/win64/Stratoshark-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-wiresharkfoundation-stratoshark-fqdn`

```
targetFqdns:
  - 1.na.dl.wireshark.org
```

---

## 📦 WiresharkFoundation.Wireshark

- **版本**: 4.6.5
- **安裝檔數量**: 3

### 下載路徑分析

**安裝檔 1** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `2.na.dl.wireshark.org` | 200 | ✅ 最終目標 | `2.na.dl.wireshark.org/win64/all-versions/Wireshark-*` |

**安裝檔 2** — `arm64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `2.na.dl.wireshark.org` | 200 | ✅ 最終目標 | `2.na.dl.wireshark.org/win64/all-versions/Wireshark-*` |

**安裝檔 3** — `x64` / `—`

| 順序 | FQDN | 狀態碼 | 類型 | 正規化路徑 |
|---|---|---|---|---|
| 1 | `2.na.dl.wireshark.org` | 200 | ✅ 最終目標 | `2.na.dl.wireshark.org/win64/all-versions/Wireshark-*` |

### 🔒 Path 層級規則（TLS Inspection）

**規則名稱**: `winget-wiresharkfoundation-wireshark-path`

```
targetUrls:
  - 2.na.dl.wireshark.org/win64/all-versions/Wireshark-*
```

### 🌍 FQDN 層級規則（備用）

**規則名稱**: `winget-wiresharkfoundation-wireshark-fqdn`

```
targetFqdns:
  - 2.na.dl.wireshark.org
```

---

## 🔄 規則維護追蹤

| 套件識別碼 | 分析版本 | 分析日期 | 狀態 |
|---|---|---|---|
| `GitHub.Copilot` | 1.0.34 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `GitHub.GitHubDesktop` | 3.5.8 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `GitHub.GitLFS` | 3.7.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `GitHub.cli` | 2.92.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `GitHub.git-sizer` | 1.5.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AIShell` | 1.0.0-preview.8 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AKSdesktop` | 0.1.0-alpha | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.APM` | 0.11.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ASRTestTool` | 4.13.17600.1000 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AccountLockoutStatus` | 1.0.0.60 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AdministrativeTemplates` | 11.25H2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AmendmentAppWordService` | 4.2.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AppControlPolicyWizard` | 2.6.0.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AppInstaller` | 1.27.470.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AppInstallerFileBuilder` | 1.2020.221.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AppLockerPolicyConverter` | 2.0.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ApplicationInspector` | 1.9.55 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Aspire` | 13.1.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azd` | 1.24.300 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.ADConnectSyncDocumenter` | 1.20.0917.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.AZCopy.10` | 10.32.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.ArtifactSigningClientTools` | 0.1.128 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.Auth` | 0.9.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.Az` | 15.2.0.40510 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.AztfExport` | 0.19.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.BatchExplorer` | 2.23.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.CloudHSM-ClientSDK` | 2.0.2.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.ConnectedMachineAgent` | 1.63.03384.2896 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.CosmosEmulator` | 2.14.27 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.DataCLI` | 20.3.14 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.DataStudio` | 1.52.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.FunctionsCoreTools` | 4.10.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.GuestProxyAgent` | 1.0.39 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.IoTExplorer` | 0.15.12 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.Kubelogin` | 0.2.13 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.QuickReview` | 3.1.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.StorageExplorer` | 1.43.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.TemplateAnalyzer` | 0.8.5 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Azure.TrustedSigningClientTools` | 0.1.127 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AzureCLI` | 2.85.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AzureMonitorAgent` | 1.41.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.AzureVPNClient` | 4.0.5.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.BTP` | 1.14.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Bicep` | 0.42.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.BotFrameworkComposer` | 2.1.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.BotFrameworkEmulator` | 4.15.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.CLRTypesSQLServer.2019` | 15.0.2000.5 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.CertifiedToolAzureVM` | 1.6 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.CmdPalAzureExtension` | 0.200.174.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.CmdPalGitHubExtension` | 0.103.178.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DSC` | 3.1.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DTrace` | 2.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DataMigrationAssistant` | 5.8.5973.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DataTools.IntegrationServices` | 17.0.1010.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DebugDiag` | 2.3.2.11 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DefenderForCloud.CLI` | 2.0.03334.114 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DependencyAgent` | 9.10.18 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DeploymentToolkit` | 6.3.8456.1000 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DevSkim.CLI.DotNetTool` | 1.0.59 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DevSkim.CLI.LibraryPackage` | 1.0.59 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DirectAccessCTST` | 1.4.4.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DirectX` | 9.29.1974.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DirectXTex.Texassemble` | 2026.3.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DirectXTex.Texconv` | 2026.3.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DirectXTex.Texdiag` | 2026.3.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DiskSpd` | 2.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.AspNetCore.10` | 10.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.AspNetCore.6` | 6.0.36 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.AspNetCore.8` | 8.0.26 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.AspNetCore.9` | 9.0.15 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.DesktopRuntime.10` | 10.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.DesktopRuntime.6` | 6.0.36 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.DesktopRuntime.8` | 8.0.26 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.DesktopRuntime.9` | 9.0.15 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Framework.DeveloperPack.4.6` | 4.6.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Framework.DeveloperPack_4` | 4.8.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Framework.Runtime` | 4.8.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.HostingBundle.10` | 10.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.HostingBundle.6` | 6.0.36 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.HostingBundle.8` | 8.0.26 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.HostingBundle.9` | 9.0.15 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.RepairTool` | 1.4 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Runtime.10` | 10.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Runtime.6` | 6.0.36 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Runtime.8` | 8.0.26 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.Runtime.9` | 9.0.15 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.SDK.10` | 10.0.203 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.SDK.6` | 6.0.428 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.SDK.8` | 8.0.420 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.SDK.9` | 9.0.313 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.UninstallTool` | 1.7.661902 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.DotNet.dotnet-ef` | 10.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Edge` | 147.0.3912.86 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.EdgeDriver` | 147.0.3912.86 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.EdgeWebView2Runtime` | 147.0.3912.98 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Edit` | 2.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.EnterpriseStateClassify` | 1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.EventLogExpert` | 25.12.11.1105 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.FRSDiag` | 1.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.FSLogix` | 3.26.126.19110 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.FoundryLocal` | 0.8.119.102 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.FuzzyLookupAddExcel` | 1.3.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.GameInput` | 3.3.195.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Garnet.DN8` | 1.0.83 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Garnet.DN9` | 1.0.83 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Git` | 2.53.0.0.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.GlobalSecureAccessClient` | 2.26.108 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.HIDTools.Waratah` | 1.90 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.HwpConverter` | 15.0.4454.1506 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IIS.Compression` | 1.0.06502 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IIS.ServiceMonitor` | 2.0.1.10 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IIS.URLRewrite` | 7.2.1993 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IISManagerRemoteAdministration` | 1.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IdFix` | 2.6.0.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IntegrationRuntime` | 5.65.9593.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IntuneWSLPlugin` | 1.25.4.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.IronPython.3` | 3.4.2.1000 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Kanagawa` | 1.2.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.LAPS` | 6.2.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.LightGBM` | 4.6.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.LingeringObjectLiquidator` | 2.0.21 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.LogCheetah` | 1.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.LogParser` | 2.2.10 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.M365AgentsPlayground` | 0.2.24 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MFCMapi` | 26.0.26111.02 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MIDI.FeatureEnablementChecker` | 1.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MIDI.SDK` | 1.0.16-rc.3.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MITT` | 8.03 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MSIX-Toolkit` | 10.0.19041.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MSIXCore` | 1.2.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MSIXPackagingTool` | 1.2024.405.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MUTT` | 3.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MaliciousSoftwareRemovalTool` | 5.139 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MediaCreationTool` | 10.0.26100.7019 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MouseWithoutBorders` | 2.2.1.327 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.MouseandKeyboardCenter` | 14.41.137.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Ntttcp` | 5.40.0.99012574 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.NuGet` | 7.3.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OSCDIMG` | 2.56 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OSConfig` | 1.3.10.13 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Office` | 16.0.19929.20062 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OfficeDeploymentTool` | 16.0.19929.20062 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OneDrive` | 26.062.0402.0002 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OneLakeFileExplorer` | 1.0.14.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OneNoteDiagnostics` | 1.0.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenAPI.Hidi` | 3.1.2.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenAPI.Kiota` | 1.30.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenCLGLVulkanCompatibilityPack` | 1.2404.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenJDK.11` | 11.0.30.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenJDK.17` | 17.0.18.8 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenJDK.21` | 21.0.10.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.OpenJDK.25` | 25.0.2.10 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PICT` | 3.7.4.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PIX` | 2603.25 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Pave` | 0.1.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PerfView` | 3.2.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerAppsCLI` | 1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerAutomateDesktop` | 2.67.00143.26090 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerAutomateProcessMining` | 6.1.2506.2252 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerBI` | 2.153.910.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerBIReportBuilder` | 15.7.1817.11 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerBIReportServer` | 1.25.9558.32914 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerShell` | 7.6.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PowerToys` | 0.99.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PrintMetadataTroubleshooter` | 1.0.0.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ProfileExplorer` | 1.2.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ProjectTelescope` | 0.15.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Promptflow` | 1.17.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.PurviewInformationProtection` | 3.2.57.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.RMSClient` | 1.0.5406.9 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.RemoteDesktopClient` | 1.2.7099.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.RemoteDesktopMMRService` | 1.0.2507.21006 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.RemoteHelp` | 5.1.1998.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ReportBuilder` | 15.1.30001.02 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SBOMTool` | 4.1.5 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2019.Developer` | 15.2204.5490.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2019.Express` | 15.2204.5490.2 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2022.Developer` | 16.0.1000.6 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2022.Express` | 16.0.1000.6 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2025.Developer` | 17.0.1000.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.2025.Express` | 17.0.1000.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.OLEDBDriver` | 19.4.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServer.RMLUtilities` | 09.04.0103 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SQLServerManagementStudio` | 20.2.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SaRACmd` | 17.01.3954.000 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SafetyScanner` | 1.449.54.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ScreenRecorder` | 0.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SecurityComplianceToolkit.LGPO` | 3.0.2004.13001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SecurityComplianceToolkit.PolicyAnalyzer` | 4.0.2004.13001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SecurityComplianceToolkit.SetObjectSecurity` | 1.0.2004.13001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ServiceFabricRuntime` | 11.3.475.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.ServiceFabricSDK` | 8.3.475 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SetupDiag` | 1.7.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SmartDump` | 1.13 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SqlPackage` | 170.3.93 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sqlcmd` | 1.9.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SurfaceApp` | 75.11130.117.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SurfaceHubRecoveryTool` | 2.7.139.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.SymCryptUnitTest` | 103.8.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Autologon` | 3.10 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Autoruns` | 14.11 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.BGInfo` | 4.33 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Ctrl2Cap` | 3.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.DebugView` | 5.00 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Desktops` | 2.01 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.FindLinks` | 1.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Handle` | 5.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.MoveFile` | 1.02 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.PendMoves` | 1.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.ProcessExplorer` | 17.11 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.ProcessMonitor` | 4.01 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.RAMMap` | 1.63 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.RDCMan` | 3.12 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.RegJump` | 1.11 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.SDelete` | 2.06 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Sigcheck` | 2.91 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Strings` | 2.54 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Sysmon` | 15.20 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.TCPView` | 4.19 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.VMMap` | 3.40 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.Whois` | 1.21 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Sysinternals.ZoomIt` | 11.00 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.TeamMate` | 0.1.15 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Teams` | 26072.521.4595.7966 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.TeamsTxNDI` | 2024.8.1.14 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.TimeTravelDebugging` | 1.11.584.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Tokenizer` | 1.3.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.UI.Xaml.2.7` | 7.2208.15002.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.UI.Xaml.2.8` | 8.2310.30001.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.UpdateAssistant` | 1.4.19041.2183 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCLibs.14` | 14.0.33519.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCLibs.Desktop.14` | 14.0.33728.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2012.x64` | 11.0.61030.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2012.x86` | 11.0.61030.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2013.x64` | 12.0.40664.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2013.x86` | 12.0.40664.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2015+.arm64` | 14.50.35719.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2015+.x64` | 14.50.35719.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VCRedist.2015+.x86` | 14.50.35719.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VSDotNetLogCollect` | 17.0.35214.149 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VSIXBootstrapper` | 1.0.37 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VSTOR` | 10.0.60917 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisioViewer` | 16.0.4339.1001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.2022.BuildTools` | 17.14.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.2022.Enterprise` | 17.14.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.2022.OnecoreMsvsmon` | 17.14.6 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.2022.Professional` | 17.14.31 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.2022.RemoteTools` | 17.14.8 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.ConfigFinder` | 1.0.47.55350 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.Extensions.TypeScript` | 4.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudio.Locator` | 3.1.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualStudioCode` | 1.118.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.VisualTrueType` | 6.35 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WSL` | 2.6.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Wassette` | 0.4.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WebDeploy` | 10.0.2001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.Win32ContentPrepTool` | 1.8.7 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WinAppCli` | 0.3.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WinDbg` | 1.2603.20001.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsADK` | 10.1.28000.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsAdminCenter` | 2.6.6.18 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsApp` | 2.0.1071.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsAppRuntime.1.5` | 1.5.8 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsAppRuntime.1.6` | 1.6.9 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsAppRuntime.1.7` | 1.7.9 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsAppRuntime.1.8` | 1.8.6 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsApplicationDriver` | 1.2.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsBusesTracing` | 1.1.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsCloudIOProtectionDriver` | 0.0.693 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsDeviceRecoveryTool` | 3.17.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsInstallationAssistant` | 1.4.19041.6448 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsMIDIServicesSDK` | 1.0.14-rc.1.209 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsPCHealthCheck` | 4.0.2410.23001 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsSDK.10.0.22000` | 10.0.22000.832 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsSDK.10.0.22621` | 10.0.22621.2428 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsSDK.10.0.26100` | 10.0.26100.7705 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsSDK.10.0.28000` | 10.0.28000.1721 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsTerminal` | 1.24.10921.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsVirtualDesktopAgent` | 1.0.12684.400 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsVirtualDesktopBootloader` | 1.0.9023.1100 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsWDK.10.0.22000` | 10.1.22000.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsWDK.10.0.22621` | 10.1.22621.2428 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WindowsWDK.10.0.26100` | 10.1.26100.6584 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.WingetCreate` | 1.12.8.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.XMLNotepad` | 2.9.0.21 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.bitsmanager` | 1.12.0.4 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.err` | 6.4.5 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.etl2pcapng` | 1.11.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.msodbcsql.17` | 17.10.6.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.msodbcsql.18` | 18.6.2.1 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.quicreach` | 1.3.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Microsoft.winfile` | 10.4.0.0 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `Telerik.Fiddler.Classic` | 5.0.20253.3311 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `WiresharkFoundation.Stratoshark` | 0.9.3 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |
| `WiresharkFoundation.Wireshark` | 4.6.5 | 2026-05-01 11:46:52 UTC+08:00 | ✅ 已分析 |

### 維護建議

- 建議定期重新執行分析，確認套件版本更新後下載路徑是否變更
- 若有新版本發佈，重新產生規則並比對差異：
  ```bash
  python main.py GitHub.Copilot GitHub.GitHubDesktop GitHub.GitLFS GitHub.cli GitHub.git-sizer Microsoft.AIShell Microsoft.AKSdesktop Microsoft.APM Microsoft.ASRTestTool Microsoft.AccountLockoutStatus Microsoft.AdministrativeTemplates Microsoft.AmendmentAppWordService Microsoft.AppControlPolicyWizard Microsoft.AppInstaller Microsoft.AppInstallerFileBuilder Microsoft.AppLockerPolicyConverter Microsoft.ApplicationInspector Microsoft.Aspire Microsoft.Azd Microsoft.Azure.ADConnectSyncDocumenter Microsoft.Azure.AZCopy.10 Microsoft.Azure.ArtifactSigningClientTools Microsoft.Azure.Auth Microsoft.Azure.Az Microsoft.Azure.AztfExport Microsoft.Azure.BatchExplorer Microsoft.Azure.CloudHSM-ClientSDK Microsoft.Azure.ConnectedMachineAgent Microsoft.Azure.CosmosEmulator Microsoft.Azure.DataCLI Microsoft.Azure.DataStudio Microsoft.Azure.FunctionsCoreTools Microsoft.Azure.GuestProxyAgent Microsoft.Azure.IoTExplorer Microsoft.Azure.Kubelogin Microsoft.Azure.QuickReview Microsoft.Azure.StorageExplorer Microsoft.Azure.TemplateAnalyzer Microsoft.Azure.TrustedSigningClientTools Microsoft.AzureCLI Microsoft.AzureMonitorAgent Microsoft.AzureVPNClient Microsoft.BTP Microsoft.Bicep Microsoft.BotFrameworkComposer Microsoft.BotFrameworkEmulator Microsoft.CLRTypesSQLServer.2019 Microsoft.CertifiedToolAzureVM Microsoft.CmdPalAzureExtension Microsoft.CmdPalGitHubExtension Microsoft.DSC Microsoft.DTrace Microsoft.DataMigrationAssistant Microsoft.DataTools.IntegrationServices Microsoft.DebugDiag Microsoft.DefenderForCloud.CLI Microsoft.DependencyAgent Microsoft.DeploymentToolkit Microsoft.DevSkim.CLI.DotNetTool Microsoft.DevSkim.CLI.LibraryPackage Microsoft.DirectAccessCTST Microsoft.DirectX Microsoft.DirectXTex.Texassemble Microsoft.DirectXTex.Texconv Microsoft.DirectXTex.Texdiag Microsoft.DiskSpd Microsoft.DotNet.AspNetCore.10 Microsoft.DotNet.AspNetCore.6 Microsoft.DotNet.AspNetCore.8 Microsoft.DotNet.AspNetCore.9 Microsoft.DotNet.DesktopRuntime.10 Microsoft.DotNet.DesktopRuntime.6 Microsoft.DotNet.DesktopRuntime.8 Microsoft.DotNet.DesktopRuntime.9 Microsoft.DotNet.Framework.DeveloperPack.4.6 Microsoft.DotNet.Framework.DeveloperPack_4 Microsoft.DotNet.Framework.Runtime Microsoft.DotNet.HostingBundle.10 Microsoft.DotNet.HostingBundle.6 Microsoft.DotNet.HostingBundle.8 Microsoft.DotNet.HostingBundle.9 Microsoft.DotNet.RepairTool Microsoft.DotNet.Runtime.10 Microsoft.DotNet.Runtime.6 Microsoft.DotNet.Runtime.8 Microsoft.DotNet.Runtime.9 Microsoft.DotNet.SDK.10 Microsoft.DotNet.SDK.6 Microsoft.DotNet.SDK.8 Microsoft.DotNet.SDK.9 Microsoft.DotNet.UninstallTool Microsoft.DotNet.dotnet-ef Microsoft.Edge Microsoft.EdgeDriver Microsoft.EdgeWebView2Runtime Microsoft.Edit Microsoft.EnterpriseStateClassify Microsoft.EventLogExpert Microsoft.FRSDiag Microsoft.FSLogix Microsoft.FoundryLocal Microsoft.FuzzyLookupAddExcel Microsoft.GameInput Microsoft.Garnet.DN8 Microsoft.Garnet.DN9 Microsoft.Git Microsoft.GlobalSecureAccessClient Microsoft.HIDTools.Waratah Microsoft.HwpConverter Microsoft.IIS.Compression Microsoft.IIS.ServiceMonitor Microsoft.IIS.URLRewrite Microsoft.IISManagerRemoteAdministration Microsoft.IdFix Microsoft.IntegrationRuntime Microsoft.IntuneWSLPlugin Microsoft.IronPython.3 Microsoft.Kanagawa Microsoft.LAPS Microsoft.LightGBM Microsoft.LingeringObjectLiquidator Microsoft.LogCheetah Microsoft.LogParser Microsoft.M365AgentsPlayground Microsoft.MFCMapi Microsoft.MIDI.FeatureEnablementChecker Microsoft.MIDI.SDK Microsoft.MITT Microsoft.MSIX-Toolkit Microsoft.MSIXCore Microsoft.MSIXPackagingTool Microsoft.MUTT Microsoft.MaliciousSoftwareRemovalTool Microsoft.MediaCreationTool Microsoft.MouseWithoutBorders Microsoft.MouseandKeyboardCenter Microsoft.Ntttcp Microsoft.NuGet Microsoft.OSCDIMG Microsoft.OSConfig Microsoft.Office Microsoft.OfficeDeploymentTool Microsoft.OneDrive Microsoft.OneLakeFileExplorer Microsoft.OneNoteDiagnostics Microsoft.OpenAPI.Hidi Microsoft.OpenAPI.Kiota Microsoft.OpenCLGLVulkanCompatibilityPack Microsoft.OpenJDK.11 Microsoft.OpenJDK.17 Microsoft.OpenJDK.21 Microsoft.OpenJDK.25 Microsoft.PICT Microsoft.PIX Microsoft.Pave Microsoft.PerfView Microsoft.PowerAppsCLI Microsoft.PowerAutomateDesktop Microsoft.PowerAutomateProcessMining Microsoft.PowerBI Microsoft.PowerBIReportBuilder Microsoft.PowerBIReportServer Microsoft.PowerShell Microsoft.PowerToys Microsoft.PrintMetadataTroubleshooter Microsoft.ProfileExplorer Microsoft.ProjectTelescope Microsoft.Promptflow Microsoft.PurviewInformationProtection Microsoft.RMSClient Microsoft.RemoteDesktopClient Microsoft.RemoteDesktopMMRService Microsoft.RemoteHelp Microsoft.ReportBuilder Microsoft.SBOMTool Microsoft.SQLServer.2019.Developer Microsoft.SQLServer.2019.Express Microsoft.SQLServer.2022.Developer Microsoft.SQLServer.2022.Express Microsoft.SQLServer.2025.Developer Microsoft.SQLServer.2025.Express Microsoft.SQLServer.OLEDBDriver Microsoft.SQLServer.RMLUtilities Microsoft.SQLServerManagementStudio Microsoft.SaRACmd Microsoft.SafetyScanner Microsoft.ScreenRecorder Microsoft.SecurityComplianceToolkit.LGPO Microsoft.SecurityComplianceToolkit.PolicyAnalyzer Microsoft.SecurityComplianceToolkit.SetObjectSecurity Microsoft.ServiceFabricRuntime Microsoft.ServiceFabricSDK Microsoft.SetupDiag Microsoft.SmartDump Microsoft.SqlPackage Microsoft.Sqlcmd Microsoft.SurfaceApp Microsoft.SurfaceHubRecoveryTool Microsoft.SymCryptUnitTest Microsoft.Sysinternals.Autologon Microsoft.Sysinternals.Autoruns Microsoft.Sysinternals.BGInfo Microsoft.Sysinternals.Ctrl2Cap Microsoft.Sysinternals.DebugView Microsoft.Sysinternals.Desktops Microsoft.Sysinternals.FindLinks Microsoft.Sysinternals.Handle Microsoft.Sysinternals.MoveFile Microsoft.Sysinternals.PendMoves Microsoft.Sysinternals.ProcessExplorer Microsoft.Sysinternals.ProcessMonitor Microsoft.Sysinternals.RAMMap Microsoft.Sysinternals.RDCMan Microsoft.Sysinternals.RegJump Microsoft.Sysinternals.SDelete Microsoft.Sysinternals.Sigcheck Microsoft.Sysinternals.Strings Microsoft.Sysinternals.Sysmon Microsoft.Sysinternals.TCPView Microsoft.Sysinternals.VMMap Microsoft.Sysinternals.Whois Microsoft.Sysinternals.ZoomIt Microsoft.TeamMate Microsoft.Teams Microsoft.TeamsTxNDI Microsoft.TimeTravelDebugging Microsoft.Tokenizer Microsoft.UI.Xaml.2.7 Microsoft.UI.Xaml.2.8 Microsoft.UpdateAssistant Microsoft.VCLibs.14 Microsoft.VCLibs.Desktop.14 Microsoft.VCRedist.2012.x64 Microsoft.VCRedist.2012.x86 Microsoft.VCRedist.2013.x64 Microsoft.VCRedist.2013.x86 Microsoft.VCRedist.2015+.arm64 Microsoft.VCRedist.2015+.x64 Microsoft.VCRedist.2015+.x86 Microsoft.VSDotNetLogCollect Microsoft.VSIXBootstrapper Microsoft.VSTOR Microsoft.VisioViewer Microsoft.VisualStudio.2022.BuildTools Microsoft.VisualStudio.2022.Enterprise Microsoft.VisualStudio.2022.OnecoreMsvsmon Microsoft.VisualStudio.2022.Professional Microsoft.VisualStudio.2022.RemoteTools Microsoft.VisualStudio.ConfigFinder Microsoft.VisualStudio.Extensions.TypeScript Microsoft.VisualStudio.Locator Microsoft.VisualStudioCode Microsoft.VisualTrueType Microsoft.WSL Microsoft.Wassette Microsoft.WebDeploy Microsoft.Win32ContentPrepTool Microsoft.WinAppCli Microsoft.WinDbg Microsoft.WindowsADK Microsoft.WindowsAdminCenter Microsoft.WindowsApp Microsoft.WindowsAppRuntime.1.5 Microsoft.WindowsAppRuntime.1.6 Microsoft.WindowsAppRuntime.1.7 Microsoft.WindowsAppRuntime.1.8 Microsoft.WindowsApplicationDriver Microsoft.WindowsBusesTracing Microsoft.WindowsCloudIOProtectionDriver Microsoft.WindowsDeviceRecoveryTool Microsoft.WindowsInstallationAssistant Microsoft.WindowsMIDIServicesSDK Microsoft.WindowsPCHealthCheck Microsoft.WindowsSDK.10.0.22000 Microsoft.WindowsSDK.10.0.22621 Microsoft.WindowsSDK.10.0.26100 Microsoft.WindowsSDK.10.0.28000 Microsoft.WindowsTerminal Microsoft.WindowsVirtualDesktopAgent Microsoft.WindowsVirtualDesktopBootloader Microsoft.WindowsWDK.10.0.22000 Microsoft.WindowsWDK.10.0.22621 Microsoft.WindowsWDK.10.0.26100 Microsoft.WingetCreate Microsoft.XMLNotepad Microsoft.bitsmanager Microsoft.err Microsoft.etl2pcapng Microsoft.msodbcsql.17 Microsoft.msodbcsql.18 Microsoft.quicreach Microsoft.winfile Telerik.Fiddler.Classic WiresharkFoundation.Stratoshark WiresharkFoundation.Wireshark -f md > generated/firewall-rules-new.md
  diff generated/firewall-rules.md generated/firewall-rules-new.md
  ```
- 版本號已正規化為萬用字元 `*`，多數情況下版本更新不需修改規則
- 若安裝檔的下載來源（FQDN）變更，則需更新防火牆規則
