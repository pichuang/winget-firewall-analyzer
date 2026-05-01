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

# WSL 基礎設施端點（所有 WSL 發行版共用）：wslstorestorage.blob.core.windows.net — WSL 核心元件儲存（kernel 更新、runtime）
az network firewall policy rule-collection-group collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rcg-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "wsl-infrastructure-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "wslstorestorage.blob.core.windows.net" \
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
