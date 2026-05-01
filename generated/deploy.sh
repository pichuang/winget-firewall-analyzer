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
  --source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Git v2.48.0.vfs.0.0 下載所需路徑（TLS Inspection）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-git-path" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-urls "github.com/microsoft/git/releases/download/*/Git-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/23216272/*" \
  --source-addresses "10.0.0.0/8"

# winget 套件 Microsoft.Git v2.48.0.vfs.0.0 下載所需網域（FQDN 層級）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-git-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-addresses "10.0.0.0/8"

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
  --source-addresses "10.0.0.0/8"

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
  --source-addresses "10.0.0.0/8"

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
  --source-addresses "10.0.0.0/8"

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
  --source-addresses "10.0.0.0/8"

