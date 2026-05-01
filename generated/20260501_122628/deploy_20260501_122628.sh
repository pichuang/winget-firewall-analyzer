#!/bin/bash
# Azure Firewall Policy 規則部署指令
# 產生時間：請自行記錄

POLICY_NAME="<FIREWALL_POLICY_NAME>"
RESOURCE_GROUP="<RESOURCE_GROUP>"
RCG_NAME="winget-rules"
RC_NAME="winget-download"
PRIORITY=500

# 建立 Rule Collection Group（若不存在）
az network firewall policy rule-collection-group create \
  --name "$RCG_NAME" \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --priority $PRIORITY 2>/dev/null || true

# 建立 Rule Collection
az network firewall policy rule-collection-group collection add-filter-collection \
  --name "$RC_NAME" \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --rule-type ApplicationRule \
  --action Allow \
  --priority 600

# winget 基礎設施端點（所有套件共用）：cdn.winget.microsoft.com — winget 套件來源索引與 manifest；winget.azureedge.net — winget 套件來源 CDN
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-infrastructure-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdn.winget.microsoft.com" "winget.azureedge.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.Copilot v1.0.34 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-copilot-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip" "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.Copilot v1.0.34 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-copilot-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.GitHubDesktop v3.5.8 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-githubdesktop-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.GitHubDesktop v3.5.8 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-githubdesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "desktop.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.GitLFS v3.7.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-gitlfs-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.GitLFS v3.7.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-gitlfs-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.cli v2.92.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-cli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/cli/cli/releases/download/*/gh_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.cli v2.92.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-cli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.git-sizer v1.5.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-git-sizer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/github/git-sizer/releases/download/*/git-sizer-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 GitHub.git-sizer v1.5.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-git-sizer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AIShell v1.0.0-preview.8 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aishell-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/PowerShell/AIShell/releases/download/*/AIShell-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/622343786/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AIShell v1.0.0-preview.8 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aishell-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AKSdesktop v0.1.0-alpha 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aksdesktop-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AKSdesktop v0.1.0-alpha 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aksdesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.APM v0.11.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-apm-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.APM v0.11.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-apm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ASRTestTool v4.13.17600.1000 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-asrtesttool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "demo.wd.microsoft.com/Content/ASRtool.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ASRTestTool v4.13.17600.1000 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-asrtesttool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "demo.wd.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AccountLockoutStatus v1.0.0.60 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-accountlockoutstatus-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AccountLockoutStatus v1.0.0.60 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-accountlockoutstatus-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AdministrativeTemplates v11.25H2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-administrativetemplates-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AdministrativeTemplates v11.25H2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-administrativetemplates-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AmendmentAppWordService v4.2.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-amendmentappwordservice-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "amendmentservice.azurewebsites.net/assets/AmendmentAppWordServiceV4.2.Setup.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AmendmentAppWordService v4.2.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-amendmentappwordservice-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "amendmentservice.azurewebsites.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppControlPolicyWizard v2.6.0.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appcontrolpolicywizard-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppControlPolicyWizard v2.6.0.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appcontrolpolicywizard-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "webapp-wdac-wizard.azurewebsites.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppInstaller v1.27.470.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstaller-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppInstaller v1.27.470.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstaller-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppInstallerFileBuilder v1.2020.221.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstallerfilebuilder-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppInstallerFileBuilder v1.2020.221.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstallerfilebuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppLockerPolicyConverter v2.0.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applockerpolicyconverter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AppLockerPolicyConverter v2.0.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applockerpolicyconverter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ApplicationInspector v1.9.55 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applicationinspector-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ApplicationInspector v1.9.55 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applicationinspector-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Aspire v13.1.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aspire-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*" "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Aspire v13.1.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aspire-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "ci.dot.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azd v1.24.300 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azd-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azd v1.24.300 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-adconnectsyncdocumenter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ADConnectSyncDocumenter v1.20.0917.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-adconnectsyncdocumenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.AZCopy.10 v10.32.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-azcopy-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.AZCopy.10 v10.32.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-azcopy-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ArtifactSigningClientTools v0.1.128 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-artifactsigningclienttools-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/ArtifactSigningClientTools.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ArtifactSigningClientTools v0.1.128 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-artifactsigningclienttools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Auth v0.9.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-auth-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Auth v0.9.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-auth-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Az v15.2.0.40510 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-az-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Az v15.2.0.40510 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-az-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.AztfExport v0.19.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-aztfexport-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/aztfexport/releases/download/*/aztfexport_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.AztfExport v0.19.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-aztfexport-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.BatchExplorer v2.23.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-batchexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.BatchExplorer v2.23.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-batchexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cloudhsm-clientsdk-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.CloudHSM-ClientSDK v2.0.2.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cloudhsm-clientsdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-connectedmachineagent-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.ConnectedMachineAgent v1.63.03384.2896 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-connectedmachineagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "gbl.his.arc.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.CosmosEmulator v2.14.27 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cosmosemulator-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.CosmosEmulator v2.14.27 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cosmosemulator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.DataCLI v20.3.14 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datacli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/f/f/f/*/azdata-cli-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.DataCLI v20.3.14 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datacli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.DataStudio v1.52.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datastudio-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.DataStudio v1.52.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datastudio-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.FunctionsCoreTools v4.10.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-functionscoretools-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*" "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*" "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.FunctionsCoreTools v4.10.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-functionscoretools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.GuestProxyAgent v1.0.39 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-guestproxyagent-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*" "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.GuestProxyAgent v1.0.39 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-guestproxyagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.IoTExplorer v0.15.12 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-iotexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.IoTExplorer v0.15.12 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-iotexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Kubelogin v0.2.13 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-kubelogin-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.Kubelogin v0.2.13 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-kubelogin-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "packages.aks.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.QuickReview v3.1.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-quickreview-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.QuickReview v3.1.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-quickreview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.StorageExplorer v1.43.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-storageexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe" "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.StorageExplorer v1.43.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-storageexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.TemplateAnalyzer v0.8.5 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-templateanalyzer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip" "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.TemplateAnalyzer v0.8.5 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-templateanalyzer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.TrustedSigningClientTools v0.1.127 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-trustedsigningclienttools-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/TrustedSigningClientTools.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Azure.TrustedSigningClientTools v0.1.127 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-trustedsigningclienttools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureCLI v2.85.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurecli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "azcliprod.blob.core.windows.net/msi/azure-cli-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureCLI v2.85.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurecli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "azcliprod.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureMonitorAgent v1.41.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azuremonitoragent-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureMonitorAgent v1.41.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azuremonitoragent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureVPNClient v4.0.5.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurevpnclient-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/AzVpnAppx_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.AzureVPNClient v4.0.5.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurevpnclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BTP v1.14.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-btp-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BTP v1.14.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-btp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Bicep v0.42.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bicep-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Bicep v0.42.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bicep-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BotFrameworkComposer v2.1.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-botframeworkcomposer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/BotFramework-Composer/releases/download/*/BotFramework-Composer-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/170615717/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BotFrameworkComposer v2.1.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-botframeworkcomposer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BotFrameworkEmulator v4.15.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-botframeworkemulator-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/BotFramework-Emulator/releases/download/*/BotFramework-Emulator-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/73518607/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.BotFrameworkEmulator v4.15.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-botframeworkemulator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-clrtypessqlserver-2019-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CLRTypesSQLServer.2019 v15.0.2000.5 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-clrtypessqlserver-2019-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CertifiedToolAzureVM v1.6 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-certifiedtoolazurevm-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CertifiedToolAzureVM v1.6 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-certifiedtoolazurevm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CmdPalAzureExtension v0.200.174.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalazureextension-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CmdPalAzureExtension v0.200.174.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalazureextension-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CmdPalGitHubExtension v0.103.178.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalgithubextension-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.CmdPalGitHubExtension v0.103.178.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalgithubextension-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DSC v3.1.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dsc-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/PowerShell/DSC/releases/download/*/DSC-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DSC v3.1.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dsc-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DTrace v2.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dtrace-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi" "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DTrace v2.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dtrace-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DataMigrationAssistant v5.8.5973.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datamigrationassistant-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DataMigrationAssistant v5.8.5973.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datamigrationassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DataTools.IntegrationServices v17.0.1010.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datatools-integrationservices-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DataTools.IntegrationServices v17.0.1010.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datatools-integrationservices-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "ssis.gallerycdn.vsassets.io" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DebugDiag v2.3.2.11 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-debugdiag-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DebugDiag v2.3.2.11 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-debugdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DefenderForCloud.CLI v2.0.03334.114 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-defenderforcloud-cli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DefenderForCloud.CLI v2.0.03334.114 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-defenderforcloud-cli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cli.dfd.security.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DependencyAgent v9.10.18 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dependencyagent-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DependencyAgent v9.10.18 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dependencyagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "da-release-ehacb6gnczcma8hc.b01.azurefd.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DeploymentToolkit v6.3.8456.1000 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-deploymenttoolkit-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi" "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DeploymentToolkit v6.3.8456.1000 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-deploymenttoolkit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DevSkim.CLI.DotNetTool v1.0.59 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-dotnettool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DevSkim.CLI.DotNetTool v1.0.59 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-dotnettool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DevSkim.CLI.LibraryPackage v1.0.59 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-librarypackage-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DevSkim.CLI.LibraryPackage v1.0.59 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-librarypackage-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectAccessCTST v1.4.4.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directaccessctst-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/a/d/0/*/DirectAccessClientTroubleshooter.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectAccessCTST v1.4.4.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directaccessctst-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectX v9.29.1974.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directx-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectX v9.29.1974.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directx-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texassemble v2026.3.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texassemble-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texassemble v2026.3.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texassemble-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texconv v2026.3.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texconv-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texconv v2026.3.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texconv-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texdiag v2026.3.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texdiag-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DirectXTex.Texdiag v2026.3.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DiskSpd v2.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-diskspd-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP" "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DiskSpd v2.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-diskspd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.10 v10.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.10 v10.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.6 v6.0.36 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.6 v6.0.36 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.8 v8.0.26 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.8 v8.0.26 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.9 v9.0.15 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.AspNetCore.9 v9.0.15 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.10 v10.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.10 v10.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.6 v6.0.36 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.6 v6.0.36 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.8 v8.0.26 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.8 v8.0.26 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.9 v9.0.15 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.DesktopRuntime.9 v9.0.15 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.DeveloperPack.4.6 v4.6.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-developerpack-4-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/e/e/c/*/NDP462-DevPack-KB3151934-ENU.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.DeveloperPack.4.6 v4.6.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-developerpack-4-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-developerpack_4-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.DeveloperPack_4 v4.8.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-developerpack_4-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.Runtime v4.8.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-runtime-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Framework.Runtime v4.8.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-runtime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.10 v10.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.10 v10.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.6 v6.0.36 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.6 v6.0.36 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.8 v8.0.26 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.8 v8.0.26 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.9 v9.0.15 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.HostingBundle.9 v9.0.15 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.RepairTool v1.4 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-repairtool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.RepairTool v1.4 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-repairtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.10 v10.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.10 v10.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.6 v6.0.36 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.6 v6.0.36 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.8 v8.0.26 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.8 v8.0.26 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.9 v9.0.15 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.Runtime.9 v9.0.15 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.10 v10.0.203 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-10-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.10 v10.0.203 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.6 v6.0.428 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.6 v6.0.428 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.8 v8.0.420 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.8 v8.0.420 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.9 v9.0.313 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.SDK.9 v9.0.313 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.UninstallTool v1.7.661902 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-uninstalltool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.UninstallTool v1.7.661902 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-uninstalltool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.dotnet-ef v10.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-dotnet-ef-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "globalcdn.nuget.org/packages/dotnet-ef.*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.DotNet.dotnet-ef v10.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-dotnet-ef-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "globalcdn.nuget.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Edge v147.0.3912.86 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edge-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Edge v147.0.3912.86 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edge-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedge.sf.dl.delivery.mp.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EdgeDriver v147.0.3912.86 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgedriver-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "msedgedriver.microsoft.com/*/edgedriver_arm64.zip" "msedgedriver.microsoft.com/*/edgedriver_win32.zip" "msedgedriver.microsoft.com/*/edgedriver_win64.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EdgeDriver v147.0.3912.86 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgedriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedgedriver.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EdgeWebView2Runtime v147.0.3912.98 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgewebview2runtime-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EdgeWebView2Runtime v147.0.3912.98 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgewebview2runtime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedge.sf.dl.delivery.mp.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Edit v2.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edit-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/edit/releases/download/*/edit-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Edit v2.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EnterpriseStateClassify v1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-enterprisestateclassify-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EnterpriseStateClassify v1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-enterprisestateclassify-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EventLogExpert v25.12.11.1105 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-eventlogexpert-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.EventLogExpert v25.12.11.1105 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-eventlogexpert-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FRSDiag v1.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-frsdiag-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/4/c/5/*/frsdiag.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FRSDiag v1.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-frsdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FSLogix v3.26.126.19110 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fslogix-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FSLogix v3.26.126.19110 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fslogix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FoundryLocal v0.8.119.102 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-foundrylocal-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "foundry.onnxruntime.ai/FoundryLocal-arm64-*" "foundry.onnxruntime.ai/FoundryLocal-x64-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FoundryLocal v0.8.119.102 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-foundrylocal-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "foundry.onnxruntime.ai" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FuzzyLookupAddExcel v1.3.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fuzzylookupaddexcel-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/9/8/*/Setup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.FuzzyLookupAddExcel v1.3.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fuzzylookupaddexcel-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.GameInput v3.3.195.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-gameinput-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoftconnect/GameInput/releases/download/*/GameInputRedist.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/1008697947/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.GameInput v3.3.195.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-gameinput-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Garnet.DN8 v1.0.83 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Garnet.DN8 v1.0.83 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Garnet.DN9 v1.0.83 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn9-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Garnet.DN9 v1.0.83 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Git v2.53.0.0.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-git-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/git/releases/download/*/Git-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Git v2.53.0.0.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-git-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.GlobalSecureAccessClient v2.26.108 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-globalsecureaccessclient-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.GlobalSecureAccessClient v2.26.108 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-globalsecureaccessclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.msappproxy.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.HIDTools.Waratah v1.90 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hidtools-waratah-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.HIDTools.Waratah v1.90 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hidtools-waratah-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.HwpConverter v15.0.4454.1506 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hwpconverter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe" "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.HwpConverter v15.0.4454.1506 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hwpconverter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.Compression v1.0.06502 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-compression-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi" "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.Compression v1.0.06502 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-compression-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.ServiceMonitor v2.0.1.10 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-servicemonitor-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.ServiceMonitor v2.0.1.10 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-servicemonitor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.URLRewrite v7.2.1993 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-urlrewrite-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi" "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IIS.URLRewrite v7.2.1993 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-urlrewrite-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IISManagerRemoteAdministration v1.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iismanagerremoteadministration-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi" "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IISManagerRemoteAdministration v1.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iismanagerremoteadministration-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IdFix v2.6.0.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-idfix-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*" "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IdFix v2.6.0.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-idfix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "raw.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IntegrationRuntime v5.65.9593.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-integrationruntime-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IntegrationRuntime v5.65.9593.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-integrationruntime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IntuneWSLPlugin v1.25.4.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-intunewslplugin-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IntuneWSLPlugin v1.25.4.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-intunewslplugin-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "raw.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IronPython.3 v3.4.2.1000 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ironpython-3-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.IronPython.3 v3.4.2.1000 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ironpython-3-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Kanagawa v1.2.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-kanagawa-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/kanagawa/releases/download/*/kanagawa-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Kanagawa v1.2.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-kanagawa-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LAPS v6.2.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-laps-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LAPS v6.2.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-laps-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LightGBM v4.6.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lightgbm-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LightGBM v4.6.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lightgbm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LingeringObjectLiquidator v2.0.21 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lingeringobjectliquidator-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LingeringObjectLiquidator v2.0.21 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lingeringobjectliquidator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LogCheetah v1.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logcheetah-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LogCheetah v1.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logcheetah-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LogParser v2.2.10 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logparser-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/f/f/1/*/LogParser.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.LogParser v2.2.10 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logparser-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.M365AgentsPlayground v0.2.24 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-m365agentsplayground-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.M365AgentsPlayground v0.2.24 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-m365agentsplayground-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MFCMapi v26.0.26111.02 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mfcmapi-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*" "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MFCMapi v26.0.26111.02 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mfcmapi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MIDI.FeatureEnablementChecker v1.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-featureenablementchecker-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip" "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MIDI.FeatureEnablementChecker v1.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-featureenablementchecker-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MIDI.SDK v1.0.16-rc.3.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-sdk-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MIDI.SDK v1.0.16-rc.3.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-sdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MITT v8.03 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mitt-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/7/7/0/*/MITT.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MITT v8.03 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mitt-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIX-Toolkit v10.0.19041.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msix-toolkit-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip" "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIX-Toolkit v10.0.19041.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msix-toolkit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIXCore v1.2.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixcore-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip" "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIXCore v1.2.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixcore-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIXPackagingTool v1.2024.405.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixpackagingtool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MSIXPackagingTool v1.2024.405.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixpackagingtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MUTT v3.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mutt-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MUTT v3.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mutt-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MaliciousSoftwareRemovalTool v5.139 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-malicioussoftwareremovaltool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe" "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MaliciousSoftwareRemovalTool v5.139 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-malicioussoftwareremovaltool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MediaCreationTool v10.0.26100.7019 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mediacreationtool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/MediaCreationTool.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MediaCreationTool v10.0.26100.7019 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mediacreationtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MouseWithoutBorders v2.2.1.327 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mousewithoutborders-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MouseWithoutBorders v2.2.1.327 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mousewithoutborders-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MouseandKeyboardCenter v14.41.137.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mouseandkeyboardcenter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.MouseandKeyboardCenter v14.41.137.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mouseandkeyboardcenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Ntttcp v5.40.0.99012574 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ntttcp-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe" "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Ntttcp v5.40.0.99012574 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ntttcp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.NuGet v7.3.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-nuget-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "dist.nuget.org/win-x86-commandline/*/nuget.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.NuGet v7.3.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-nuget-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "dist.nuget.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OSCDIMG v2.56 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-oscdimg-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe" "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OSCDIMG v2.56 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-oscdimg-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msdl.microsoft.com" "vsblobprodscussu5shard61.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OSConfig v1.3.10.13 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-osconfig-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*" "github.com/microsoft/osconfig/releases/download/*/oscfg-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OSConfig v1.3.10.13 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-osconfig-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Office v16.0.19929.20062 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-office-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "officecdn.microsoft.com/pr/wsus/setup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Office v16.0.19929.20062 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-office-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "officecdn.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OfficeDeploymentTool v16.0.19929.20062 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-officedeploymenttool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OfficeDeploymentTool v16.0.19929.20062 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-officedeploymenttool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneDrive v26.062.0402.0002 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onedrive-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneDrive v26.062.0402.0002 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onedrive-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "oneclient.sfx.ms" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneLakeFileExplorer v1.0.14.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onelakefileexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/OneLake_PuPr_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneLakeFileExplorer v1.0.14.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onelakefileexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneNoteDiagnostics v1.0.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onenotediagnostics-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OneNoteDiagnostics v1.0.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onenotediagnostics-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenAPI.Hidi v3.1.2.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-hidi-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenAPI.Hidi v3.1.2.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-hidi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenAPI.Kiota v1.30.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-kiota-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/kiota/releases/download/*/win-arm64.zip" "github.com/microsoft/kiota/releases/download/*/win-x64.zip" "github.com/microsoft/kiota/releases/download/*/win-x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenAPI.Kiota v1.30.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-kiota-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openclglvulkancompatibilitypack-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenCLGLVulkanCompatibilityPack v1.2404.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openclglvulkancompatibilitypack-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.11 v11.0.30.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-11-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.11 v11.0.30.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-11-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.17 v17.0.18.8 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-17-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.17 v17.0.18.8 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-17-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.21 v21.0.10.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-21-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.21 v21.0.10.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-21-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.25 v25.0.2.10 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-25-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.OpenJDK.25 v25.0.2.10 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-25-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PICT v3.7.4.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pict-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/pict/releases/download/*/pict.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PICT v3.7.4.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pict-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PIX v2603.25 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pix-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe" "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PIX v2603.25 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Pave v0.1.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pave-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip" "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Pave v0.1.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pave-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PerfView v3.2.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-perfview-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/perfview/releases/download/*/PerfView.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PerfView v3.2.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-perfview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAppsCLI v1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerappscli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAppsCLI v1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerappscli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAutomateDesktop v2.67.00143.26090 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomatedesktop-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAutomateDesktop v2.67.00143.26090 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomatedesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAutomateProcessMining v6.1.2506.2252 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomateprocessmining-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerAutomateProcessMining v6.1.2506.2252 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomateprocessmining-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBI v2.153.910.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbi-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBI v2.153.910.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBIReportBuilder v15.7.1817.11 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportbuilder-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBIReportBuilder v15.7.1817.11 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportbuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBIReportServer v1.25.9558.32914 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportserver-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerBIReportServer v1.25.9558.32914 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportserver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerShell v7.6.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powershell-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerShell v7.6.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powershell-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerToys v0.99.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powertoys-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*" "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PowerToys v0.99.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powertoys-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PrintMetadataTroubleshooter v1.0.0.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-printmetadatatroubleshooter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PrintMetadataTroubleshooter v1.0.0.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-printmetadatatroubleshooter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ProfileExplorer v1.2.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-profileexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ProfileExplorer v1.2.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-profileexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ProjectTelescope v0.15.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-projecttelescope-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi" "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ProjectTelescope v0.15.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-projecttelescope-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Promptflow v1.17.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-promptflow-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Promptflow v1.17.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-promptflow-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "promptflowartifact.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PurviewInformationProtection v3.2.57.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-purviewinformationprotection-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/PurviewInfoProtection.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.PurviewInformationProtection v3.2.57.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-purviewinformationprotection-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RMSClient v1.0.5406.9 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-rmsclient-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe" "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RMSClient v1.0.5406.9 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-rmsclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteDesktopClient v1.2.7099.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopclient-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteDesktopClient v1.2.7099.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteDesktopMMRService v1.0.2507.21006 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopmmrservice-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteDesktopMMRService v1.0.2507.21006 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopmmrservice-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "intstreamreleases.z22.web.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteHelp v5.1.1998.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotehelp-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.RemoteHelp v5.1.1998.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotehelp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "catalog.s.download.windowsupdate.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ReportBuilder v15.1.30001.02 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-reportbuilder-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ReportBuilder v15.1.30001.02 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-reportbuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SBOMTool v4.1.5 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sbomtool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SBOMTool v4.1.5 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sbomtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2019.Developer v15.2204.5490.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-developer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2019.Developer v15.2204.5490.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2019.Express v15.2204.5490.2 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-express-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2019.Express v15.2204.5490.2 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2022.Developer v16.0.1000.6 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-developer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2022.Developer v16.0.1000.6 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2022.Express v16.0.1000.6 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-express-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2022.Express v16.0.1000.6 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2025.Developer v17.0.1000.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-developer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2025.Developer v17.0.1000.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2025.Express v17.0.1000.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-express-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.2025.Express v17.0.1000.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.OLEDBDriver v19.4.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-oledbdriver-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi" "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi" "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.OLEDBDriver v19.4.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-oledbdriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.RMLUtilities v09.04.0103 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-rmlutilities-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/6/5/8/*/RMLSetup.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServer.RMLUtilities v09.04.0103 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-rmlutilities-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServerManagementStudio v20.2.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlservermanagementstudio-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/SSMS-Setup-CHS.exe" "download.microsoft.com/download/*/SSMS-Setup-CHT.exe" "download.microsoft.com/download/*/SSMS-Setup-DEU.exe" "download.microsoft.com/download/*/SSMS-Setup-ENU.exe" "download.microsoft.com/download/*/SSMS-Setup-ESN.exe" "download.microsoft.com/download/*/SSMS-Setup-FRA.exe" "download.microsoft.com/download/*/SSMS-Setup-ITA.exe" "download.microsoft.com/download/*/SSMS-Setup-JPN.exe" "download.microsoft.com/download/*/SSMS-Setup-KOR.exe" "download.microsoft.com/download/*/SSMS-Setup-PTB.exe" "download.microsoft.com/download/*/SSMS-Setup-RUS.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SQLServerManagementStudio v20.2.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlservermanagementstudio-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SaRACmd v17.01.3954.000 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-saracmd-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SaRACmd v17.01.3954.000 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-saracmd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SafetyScanner v1.449.54.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-safetyscanner-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "definitionupdates.microsoft.com/packages/content/msert.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SafetyScanner v1.449.54.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-safetyscanner-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "definitionupdates.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ScreenRecorder v0.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-screenrecorder-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ScreenRecorder v0.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-screenrecorder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-lgpo-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/5/c/*/LGPO.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.LGPO v3.0.2004.13001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-lgpo-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-policyanalyzer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.PolicyAnalyzer v4.0.2004.13001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-policyanalyzer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-setobjectsecurity-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SecurityComplianceToolkit.SetObjectSecurity v1.0.2004.13001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-setobjectsecurity-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ServiceFabricRuntime v11.3.475.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricruntime-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ServiceFabricRuntime v11.3.475.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricruntime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ServiceFabricSDK v8.3.475 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricsdk-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.ServiceFabricSDK v8.3.475 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricsdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SetupDiag v1.7.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-setupdiag-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/1/1/*/SetupDiag.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SetupDiag v1.7.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-setupdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SmartDump v1.13 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-smartdump-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SmartDump v1.13 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-smartdump-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SqlPackage v170.3.93 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlpackage-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/sqlpackage-win-x64-en-*" "go.microsoft.com/fwlink/" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SqlPackage v170.3.93 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlpackage-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" "go.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sqlcmd v1.9.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlcmd-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sqlcmd v1.9.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlcmd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SurfaceApp v75.11130.117.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfaceapp-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/Microsoft.SurfaceHub_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SurfaceApp v75.11130.117.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfaceapp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SurfaceHubRecoveryTool v2.7.139.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfacehubrecoverytool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SurfaceHubRecoveryTool v2.7.139.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfacehubrecoverytool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SymCryptUnitTest v103.8.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-symcryptunittest-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*" "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.SymCryptUnitTest v103.8.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-symcryptunittest-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Autologon v3.10 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autologon-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/AutoLogon.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Autologon v3.10 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autologon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Autoruns v14.11 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autoruns-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Autoruns.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Autoruns v14.11 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autoruns-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.BGInfo v4.33 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-bginfo-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/BGInfo.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.BGInfo v4.33 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-bginfo-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Ctrl2Cap v3.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-ctrl2cap-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Ctrl2Cap.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Ctrl2Cap v3.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-ctrl2cap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.DebugView v5.00 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-debugview-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/DebugView.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.DebugView v5.00 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-debugview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Desktops v2.01 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-desktops-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Desktops.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Desktops v2.01 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-desktops-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.FindLinks v1.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-findlinks-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/FindLinks.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.FindLinks v1.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-findlinks-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Handle v5.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-handle-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Handle.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Handle v5.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-handle-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.MoveFile v1.02 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-movefile-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/pendmoves.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.MoveFile v1.02 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-movefile-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.PendMoves v1.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-pendmoves-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/pendmoves.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.PendMoves v1.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-pendmoves-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ProcessExplorer v17.11 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processexplorer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/ProcessExplorer.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ProcessExplorer v17.11 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ProcessMonitor v4.01 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processmonitor-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/ProcessMonitor.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ProcessMonitor v4.01 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processmonitor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RAMMap v1.63 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rammap-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/RAMMap.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RAMMap v1.63 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rammap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RDCMan v3.12 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rdcman-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/RDCMan.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RDCMan v3.12 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rdcman-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RegJump v1.11 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-regjump-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/regjump.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.RegJump v1.11 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-regjump-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.SDelete v2.06 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sdelete-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/SDelete.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.SDelete v2.06 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sdelete-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Sigcheck v2.91 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sigcheck-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Sigcheck.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Sigcheck v2.91 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sigcheck-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Strings v2.54 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-strings-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Strings.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Strings v2.54 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-strings-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Sysmon v15.20 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sysmon-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/Sysmon.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Sysmon v15.20 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sysmon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.TCPView v4.19 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-tcpview-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/TCPView.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.TCPView v4.19 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-tcpview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.VMMap v3.40 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-vmmap-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/VMMap.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.VMMap v3.40 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-vmmap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Whois v1.21 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-whois-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/WhoIs.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.Whois v1.21 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-whois-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ZoomIt v11.00 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-zoomit-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.sysinternals.com/files/ZoomIt.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Sysinternals.ZoomIt v11.00 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-zoomit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TeamMate v0.1.15 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teammate-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TeamMate v0.1.15 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teammate-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Teams v26093.415.4620.1935 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teams-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix" "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix" "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Teams v26093.415.4620.1935 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teams-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "installer.teams.static.microsoft" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TeamsTxNDI v2024.8.1.14 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teamstxndi-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TeamsTxNDI v2024.8.1.14 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teamstxndi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "teams.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TimeTravelDebugging v1.11.584.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-timetraveldebugging-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.TimeTravelDebugging v1.11.584.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-timetraveldebugging-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "windbg.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Tokenizer v1.3.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-tokenizer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Tokenizer v1.3.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-tokenizer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UI.Xaml.2.7 v7.2208.15002.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-7-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UI.Xaml.2.7 v7.2208.15002.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-7-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UI.Xaml.2.8 v8.2310.30001.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UI.Xaml.2.8 v8.2310.30001.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UpdateAssistant v1.4.19041.2183 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-updateassistant-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.UpdateAssistant v1.4.19041.2183 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-updateassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCLibs.14 v14.0.33519.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-14-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCLibs.14 v14.0.33519.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-14-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCLibs.Desktop.14 v14.0.33728.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-desktop-14-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCLibs.Desktop.14 v14.0.33728.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-desktop-14-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2012.x64 v11.0.61030.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2012-x64-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2012.x64 v11.0.61030.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2012-x64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2012.x86 v11.0.61030.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2012-x86-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/6/B/*/VSU_4/vcredist_x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2012.x86 v11.0.61030.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2012-x86-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2013.x64 v12.0.40664.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2013-x64-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/10912041/*/vcredist_x64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2013.x64 v12.0.40664.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2013-x64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2013.x86 v12.0.40664.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2013-x86-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/10912113/*/vcredist_x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2013.x86 v12.0.40664.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2013-x86-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.arm64 v14.50.35719.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-arm64-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.arm64 v14.50.35719.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-arm64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.x64 v14.50.35719.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x64-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.x64 v14.50.35719.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.x86 v14.50.35719.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x86-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VCRedist.2015+.x86 v14.50.35719.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x86-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSDotNetLogCollect v17.0.35214.149 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsdotnetlogcollect-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/8/3/4/*/Collect.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSDotNetLogCollect v17.0.35214.149 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsdotnetlogcollect-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSIXBootstrapper v1.0.37 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsixbootstrapper-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSIXBootstrapper v1.0.37 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsixbootstrapper-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSTOR v10.0.60917 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vstor-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/5/d/2/*/vstor_redist.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VSTOR v10.0.60917 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vstor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisioViewer v16.0.4339.1001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visioviewer-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe" "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisioViewer v16.0.4339.1001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visioviewer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.BuildTools v17.14.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-buildtools-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.BuildTools v17.14.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-buildtools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.Enterprise v17.14.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-enterprise-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.Enterprise v17.14.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-enterprise-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-onecoremsvsmon-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.OnecoreMsvsmon v17.14.6 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-onecoremsvsmon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.Professional v17.14.31 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-professional-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.Professional v17.14.31 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-professional-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.RemoteTools v17.14.8 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-remotetools-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.2022.RemoteTools v17.14.8 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-remotetools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.ConfigFinder v1.0.47.55350 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-configfinder-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.ConfigFinder v1.0.47.55350 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-configfinder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.Extensions.TypeScript v4.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-extensions-typescript-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.Extensions.TypeScript v4.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-extensions-typescript-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "typescriptteam.gallerycdn.vsassets.io" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.Locator v3.1.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-locator-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/vswhere/releases/download/*/vswhere.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudio.Locator v3.1.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-locator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudioCode v1.118.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudiocode-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualStudioCode v1.118.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudiocode-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "vscode.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualTrueType v6.35 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualtruetype-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.VisualTrueType v6.35 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualtruetype-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WSL v2.6.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wsl-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*" "github.com/microsoft/WSL/releases/download/*/wsl.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WSL v2.6.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wsl-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Wassette v0.4.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wassette-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/wassette/releases/download/*/wassette_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Wassette v0.4.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wassette-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WebDeploy v10.0.2001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-webdeploy-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi" "download.microsoft.com/download/WebDeploy_x86_de-DE.msi" "download.microsoft.com/download/WebDeploy_x86_en-US.msi" "download.microsoft.com/download/WebDeploy_x86_es-ES.msi" "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi" "download.microsoft.com/download/WebDeploy_x86_it-IT.msi" "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi" "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi" "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi" "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi" "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi" "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi" "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi" "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi" "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi" "download.microsoft.com/download/webdeploy_amd64_de-DE.msi" "download.microsoft.com/download/webdeploy_amd64_en-US.msi" "download.microsoft.com/download/webdeploy_amd64_es-ES.msi" "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi" "download.microsoft.com/download/webdeploy_amd64_it-IT.msi" "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi" "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi" "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi" "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi" "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi" "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi" "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi" "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WebDeploy v10.0.2001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-webdeploy-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Win32ContentPrepTool v1.8.7 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-win32contentpreptool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*" "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Win32ContentPrepTool v1.8.7 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-win32contentpreptool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "codeload.github.com" "github.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WinAppCli v0.3.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winappcli-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix" "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix" "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WinAppCli v0.3.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winappcli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WinDbg v1.2603.20001.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windbg-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WinDbg v1.2603.20001.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windbg-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "windbg.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsADK v10.1.28000.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadk-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/adk/adksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsADK v10.1.28000.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAdminCenter v2.6.6.18 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadmincenter-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/WindowsAdminCenter2511.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAdminCenter v2.6.6.18 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadmincenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsApp v2.0.1071.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapp-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsApp v2.0.1071.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.5 v1.5.8 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-5-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.5/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.5 v1.5.8 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-5-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.6 v1.6.9 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-6-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.6/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.6 v1.6.9 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-6-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.7 v1.7.9 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-7-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.7 v1.7.9 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-7-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.8 v1.8.6 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-8-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.8/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsAppRuntime.1.8 v1.8.6 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsApplicationDriver v1.2.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapplicationdriver-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsApplicationDriver v1.2.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapplicationdriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsBusesTracing v1.1.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsbusestracing-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip" "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsBusesTracing v1.1.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsbusestracing-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsCloudIOProtectionDriver v0.0.693 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowscloudioprotectiondriver-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*" "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsCloudIOProtectionDriver v0.0.693 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowscloudioprotectiondriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res-1.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsDeviceRecoveryTool v3.17.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsdevicerecoverytool-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/wdrt-hl1.zip" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsDeviceRecoveryTool v3.17.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsdevicerecoverytool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsInstallationAssistant v1.4.19041.6448 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsinstallationassistant-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/Windows11InstallationAssistant.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsInstallationAssistant v1.4.19041.6448 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsinstallationassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsmidiservicessdk-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsMIDIServicesSDK v1.0.14-rc.1.209 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsmidiservicessdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsPCHealthCheck v4.0.2410.23001 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowspchealthcheck-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi" "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsPCHealthCheck v4.0.2410.23001 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowspchealthcheck-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.22000 v10.0.22000.832 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-22000-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/1/0/e/*/windowssdk/winsdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.22000 v10.0.22000.832 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-22000-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-22621-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.22621 v10.0.22621.2428 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-22621-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-26100-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.26100 v10.0.26100.7705 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-26100-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-28000-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsSDK.10.0.28000 v10.0.28000.1721 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-28000-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsTerminal v1.24.10921.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsterminal-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsTerminal v1.24.10921.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsterminal-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopagent-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "go.microsoft.com/fwlink/" "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsVirtualDesktopAgent v1.0.12684.400 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "go.microsoft.com" "query.prod.cms.rt.microsoft.com" "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopbootloader-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsVirtualDesktopBootloader v1.0.9023.1100 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopbootloader-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "query.prod.cms.rt.microsoft.com" "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.22000 v10.1.22000.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-22000-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/7/d/6/*/wdk/wdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.22000 v10.1.22000.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-22000-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-22621-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.22621 v10.1.22621.2428 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-22621-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-26100-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WindowsWDK.10.0.26100 v10.1.26100.6584 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-26100-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WingetCreate v1.12.8.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wingetcreate-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*" "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.WingetCreate v1.12.8.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wingetcreate-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.XMLNotepad v2.9.0.21 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-xmlnotepad-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*" "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.XMLNotepad v2.9.0.21 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-xmlnotepad-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.bitsmanager v1.12.0.4 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bitsmanager-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.bitsmanager v1.12.0.4 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bitsmanager-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.err v6.4.5 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-err-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/4/3/2/*/Err_*/Err_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.err v6.4.5 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-err-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.etl2pcapng v1.11.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-etl2pcapng-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.etl2pcapng v1.11.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-etl2pcapng-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.msodbcsql.17 v17.10.6.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-17-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/6/f/f/*/de-DE/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/de-DE/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/en-US/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/en-US/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/es-ES/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/es-ES/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/fr-FR/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/fr-FR/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/it-IT/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/it-IT/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ja-JP/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ja-JP/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ko-KR/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ko-KR/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/pt-BR/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/pt-BR/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ru-RU/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/ru-RU/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/zh-CN/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/zh-CN/*/x86/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/zh-TW/*/x64/msodbcsql.msi" "download.microsoft.com/download/6/f/f/*/zh-TW/*/x86/msodbcsql.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.msodbcsql.17 v17.10.6.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-17-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.msodbcsql.18 v18.6.2.1 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-18-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi" "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi" "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi" "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi" "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi" "download.microsoft.com/download/*/x86/1028/msodbcsql.msi" "download.microsoft.com/download/*/x86/1031/msodbcsql.msi" "download.microsoft.com/download/*/x86/1033/msodbcsql.msi" "download.microsoft.com/download/*/x86/1036/msodbcsql.msi" "download.microsoft.com/download/*/x86/1040/msodbcsql.msi" "download.microsoft.com/download/*/x86/1041/msodbcsql.msi" "download.microsoft.com/download/*/x86/1042/msodbcsql.msi" "download.microsoft.com/download/*/x86/1046/msodbcsql.msi" "download.microsoft.com/download/*/x86/1049/msodbcsql.msi" "download.microsoft.com/download/*/x86/2052/msodbcsql.msi" "download.microsoft.com/download/*/x86/3082/msodbcsql.msi" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.msodbcsql.18 v18.6.2.1 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-18-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.quicreach v1.3.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-quicreach-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/quicreach/releases/download/*/quicreach.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.quicreach v1.3.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-quicreach-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.winfile v10.4.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winfile-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/winfile/releases/download/*/Winfile_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.winfile v10.4.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winfile-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Telerik.Fiddler.Classic v5.0.20253.3311 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-telerik-fiddler-classic-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 Telerik.Fiddler.Classic v5.0.20253.3311 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-telerik-fiddler-classic-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "downloads.getfiddler.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WiresharkFoundation.Stratoshark v0.9.3 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-stratoshark-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "1.na.dl.wireshark.org/win64/Stratoshark-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WiresharkFoundation.Stratoshark v0.9.3 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-stratoshark-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "1.na.dl.wireshark.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WiresharkFoundation.Wireshark v4.6.5 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-wireshark-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WiresharkFoundation.Wireshark v4.6.5 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-wireshark-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "2.na.dl.wireshark.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# WSL 基礎設施端點（所有 WSL 發行版共用）：wslstorestorage.blob.core.windows.net — WSL 核心元件儲存（kernel 更新、runtime）；cdimages.ubuntu.com — Ubuntu WSL 官方映像下載（24.04+）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "wsl-infrastructure-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-20.04 vUbuntu 20.04 LTS 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-20-04-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/wslubuntu2004" "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-20.04 vUbuntu 20.04 LTS 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-20-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-22.04 vUbuntu 22.04 LTS 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-22-04-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "aka.ms/wslubuntu2204" "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-22.04 vUbuntu 22.04 LTS 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-22-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-24.04 vUbuntu 24.04 LTS 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-24-04-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-24.04 vUbuntu 24.04 LTS 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-24-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-26.04 vUbuntu 26.04 LTS 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-26-04-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"

# winget 套件 WSL.Ubuntu-26.04 vUbuntu 26.04 LTS 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-26-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients"
  # 備用：--source-addresses "10.0.0.0/8"
