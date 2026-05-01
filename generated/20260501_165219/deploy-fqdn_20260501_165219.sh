#!/bin/bash
# Azure Firewall Policy 規則部署指令 — FQDN 層級（無 TLS Inspection）
# ⚠️ 使用 Draft 模式：規則不會直接套用，需手動執行 deploy 指令確認後才生效
# 產生時間：請自行記錄
# 規則數量：282

set -euo pipefail

POLICY_NAME="afwp-global-01"
RESOURCE_GROUP="rg-vdss-afwp-prd-global"
RCG_NAME="rcg-1100-mirror-winget"
RC_NAME="action-allow-mirror-fqdn"
PRIORITY=1100
TOTAL_RULES=282
CURRENT=0
FAILED=0

# 顏色定義
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# =============================================
# 前置檢查
# =============================================
echo -e "${CYAN}🔍 前置檢查...${NC}"

# 確認 az CLI 已登入
if ! az account show --output none 2>/dev/null; then
  echo -e "${RED}❌ 尚未登入 Azure CLI，請先執行 az login${NC}"
  exit 1
fi
SUBSCRIPTION=$(az account show --query "name" -o tsv)
echo -e "${GREEN}✅ 已登入 Azure：${SUBSCRIPTION}${NC}"

# 確認 Firewall Policy 存在
if az network firewall policy show --name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --output none 2>/dev/null; then
  POLICY_SKU=$(az network firewall policy show --name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --query "sku.tier" -o tsv 2>/dev/null || echo "unknown")
  echo -e "${GREEN}✅ Firewall Policy 存在：${POLICY_NAME}（SKU: ${POLICY_SKU}）${NC}"
else
  echo -e "${RED}❌ Firewall Policy 不存在：$POLICY_NAME${NC}"
  echo -e "${RED}   Resource Group: $RESOURCE_GROUP${NC}"
  exit 1
fi

echo ""
echo -e "${CYAN}📋 部署計畫：${NC}"
echo "   Policy:     $POLICY_NAME"
echo "   RCG:        $RCG_NAME"
echo "   Collection: $RC_NAME"
echo "   Priority:   $PRIORITY"
echo "   規則數量:   $TOTAL_RULES"
echo "   模式:       Draft（不會直接套用）"
echo ""

# =============================================
# 步驟 1：建立 Rule Collection Group（若不存在）
# =============================================
echo -e "${CYAN}📦 步驟 1/6：檢查 Rule Collection Group...${NC}"
if az network firewall policy rule-collection-group show --name "$RCG_NAME" --policy-name "$POLICY_NAME" --resource-group "$RESOURCE_GROUP" --output none 2>/dev/null; then
  echo -e "${GREEN}   ✅ RCG 已存在：${RCG_NAME}${NC}"
else
  echo -e "${YELLOW}   ⏳ 建立 RCG：${RCG_NAME} ...${NC}"
  if az network firewall policy rule-collection-group create \
    --name "$RCG_NAME" \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --priority $PRIORITY --output none 2>&1; then
    echo -e "${GREEN}   ✅ RCG 建立成功${NC}"
  else
    echo -e "${RED}   ❌ RCG 建立失敗${NC}"
    exit 1
  fi
fi

# =============================================
# 步驟 2：建立 Firewall Policy Draft
# =============================================
echo -e "${CYAN}📝 步驟 2/6：建立 Policy Draft...${NC}"
if az network firewall policy draft create \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" --output none 2>&1; then
  echo -e "${GREEN}   ✅ Policy Draft 建立成功${NC}"
else
  echo -e "${YELLOW}   ⚠️  Policy Draft 已存在或建立失敗（繼續執行）${NC}"
fi

# =============================================
# 步驟 3：建立 RCG Draft
# =============================================
echo -e "${CYAN}📝 步驟 3/6：建立 RCG Draft...${NC}"
if az network firewall policy rule-collection-group draft create \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --priority $PRIORITY --output none 2>&1; then
  echo -e "${GREEN}   ✅ RCG Draft 建立成功${NC}"
else
  echo -e "${RED}   ❌ RCG Draft 建立失敗${NC}"
  exit 1
fi

# =============================================
# 步驟 4：在 Draft 中建立 Rule Collection
# =============================================
echo -e "${CYAN}📂 步驟 4/6：建立 Rule Collection...${NC}"
if az network firewall policy rule-collection-group draft collection add-filter-collection \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --name "$RC_NAME" \
  --rule-type ApplicationRule \
  --action Allow \
  --collection-priority 1200 --output none 2>&1; then
  echo -e "${GREEN}   ✅ Rule Collection 建立成功：$RC_NAME${NC}"
else
  echo -e "${RED}   ❌ Rule Collection 建立失敗${NC}"
  exit 1
fi

# =============================================
# 步驟 5：新增規則至 Draft（共 282 條）
# =============================================
echo -e "${CYAN}🔧 步驟 5/6：新增 282 條規則至 Draft...${NC}"
echo ""

echo -ne "   [1/282] winget-infrastructure-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-infrastructure-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdn.winget.microsoft.com" "winget.azureedge.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [2/282] winget-github-copilot-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-copilot-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [3/282] winget-github-githubdesktop-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-githubdesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "desktop.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [4/282] winget-github-gitlfs-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-gitlfs-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [5/282] winget-github-cli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-cli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [6/282] winget-github-git-sizer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-github-git-sizer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [7/282] winget-microsoft-aksdesktop-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aksdesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [8/282] winget-microsoft-apm-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-apm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [9/282] winget-microsoft-asrtesttool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-asrtesttool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "demo.wd.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [10/282] winget-microsoft-accountlockoutstatus-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-accountlockoutstatus-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [11/282] winget-microsoft-administrativetemplates-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-administrativetemplates-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [12/282] winget-microsoft-amendmentappwordservice-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-amendmentappwordservice-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "amendmentservice.azurewebsites.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [13/282] winget-microsoft-appcontrolpolicywizard-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appcontrolpolicywizard-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "webapp-wdac-wizard.azurewebsites.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [14/282] winget-microsoft-appinstaller-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstaller-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [15/282] winget-microsoft-appinstallerfilebuilder-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-appinstallerfilebuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [16/282] winget-microsoft-applockerpolicyconverter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applockerpolicyconverter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [17/282] winget-microsoft-applicationinspector-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-applicationinspector-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [18/282] winget-microsoft-aspire-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-aspire-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "ci.dot.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [19/282] winget-microsoft-azd-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [20/282] winget-microsoft-azure-adconnectsyncdocumenter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-adconnectsyncdocumenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [21/282] winget-microsoft-azure-azcopy-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-azcopy-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [22/282] winget-microsoft-azure-artifactsigningclienttools-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-artifactsigningclienttools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [23/282] winget-microsoft-azure-auth-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-auth-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [24/282] winget-microsoft-azure-az-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-az-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [25/282] winget-microsoft-azure-aztfexport-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-aztfexport-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [26/282] winget-microsoft-azure-batchexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-batchexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [27/282] winget-microsoft-azure-cloudhsm-clientsdk-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cloudhsm-clientsdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [28/282] winget-microsoft-azure-connectedmachineagent-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-connectedmachineagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "gbl.his.arc.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [29/282] winget-microsoft-azure-cosmosemulator-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-cosmosemulator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [30/282] winget-microsoft-azure-datacli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datacli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [31/282] winget-microsoft-azure-datastudio-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-datastudio-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [32/282] winget-microsoft-azure-functionscoretools-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-functionscoretools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [33/282] winget-microsoft-azure-guestproxyagent-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-guestproxyagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [34/282] winget-microsoft-azure-iotexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-iotexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [35/282] winget-microsoft-azure-kubelogin-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-kubelogin-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "packages.aks.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [36/282] winget-microsoft-azure-quickreview-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-quickreview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [37/282] winget-microsoft-azure-storageexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-storageexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [38/282] winget-microsoft-azure-templateanalyzer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-templateanalyzer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [39/282] winget-microsoft-azure-trustedsigningclienttools-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azure-trustedsigningclienttools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [40/282] winget-microsoft-azurecli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurecli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "azcliprod.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [41/282] winget-microsoft-azuremonitoragent-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azuremonitoragent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [42/282] winget-microsoft-azurevpnclient-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-azurevpnclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [43/282] winget-microsoft-btp-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-btp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [44/282] winget-microsoft-bicep-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bicep-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [45/282] winget-microsoft-clrtypessqlserver-2019-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-clrtypessqlserver-2019-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [46/282] winget-microsoft-certifiedtoolazurevm-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-certifiedtoolazurevm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [47/282] winget-microsoft-cmdpalazureextension-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalazureextension-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [48/282] winget-microsoft-cmdpalgithubextension-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-cmdpalgithubextension-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [49/282] winget-microsoft-dsc-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dsc-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [50/282] winget-microsoft-dtrace-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dtrace-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [51/282] winget-microsoft-datamigrationassistant-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datamigrationassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [52/282] winget-microsoft-datatools-integrationservices-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-datatools-integrationservices-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "ssis.gallerycdn.vsassets.io" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [53/282] winget-microsoft-debugdiag-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-debugdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [54/282] winget-microsoft-defenderforcloud-cli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-defenderforcloud-cli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cli.dfd.security.azure.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [55/282] winget-microsoft-dependencyagent-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dependencyagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "da-release-ehacb6gnczcma8hc.b01.azurefd.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [56/282] winget-microsoft-deploymenttoolkit-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-deploymenttoolkit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [57/282] winget-microsoft-devskim-cli-dotnettool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-dotnettool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [58/282] winget-microsoft-devskim-cli-librarypackage-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-devskim-cli-librarypackage-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [59/282] winget-microsoft-directx-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directx-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [60/282] winget-microsoft-directxtex-texassemble-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texassemble-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [61/282] winget-microsoft-directxtex-texconv-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texconv-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [62/282] winget-microsoft-directxtex-texdiag-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-directxtex-texdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [63/282] winget-microsoft-diskspd-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-diskspd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [64/282] winget-microsoft-dotnet-aspnetcore-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [65/282] winget-microsoft-dotnet-aspnetcore-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [66/282] winget-microsoft-dotnet-aspnetcore-9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-aspnetcore-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [67/282] winget-microsoft-dotnet-desktopruntime-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [68/282] winget-microsoft-dotnet-desktopruntime-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [69/282] winget-microsoft-dotnet-desktopruntime-9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-desktopruntime-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [70/282] winget-microsoft-dotnet-framework-developerpack_4-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-developerpack_4-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [71/282] winget-microsoft-dotnet-framework-runtime-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-framework-runtime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [72/282] winget-microsoft-dotnet-hostingbundle-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [73/282] winget-microsoft-dotnet-hostingbundle-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [74/282] winget-microsoft-dotnet-hostingbundle-9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-hostingbundle-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [75/282] winget-microsoft-dotnet-repairtool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-repairtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [76/282] winget-microsoft-dotnet-runtime-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [77/282] winget-microsoft-dotnet-runtime-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [78/282] winget-microsoft-dotnet-runtime-9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-runtime-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [79/282] winget-microsoft-dotnet-sdk-10-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-10-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [80/282] winget-microsoft-dotnet-sdk-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [81/282] winget-microsoft-dotnet-sdk-9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-sdk-9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "builds.dotnet.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [82/282] winget-microsoft-dotnet-uninstalltool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-uninstalltool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [83/282] winget-microsoft-dotnet-dotnet-ef-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-dotnet-dotnet-ef-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "globalcdn.nuget.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [84/282] winget-microsoft-edge-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edge-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedge.sf.dl.delivery.mp.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [85/282] winget-microsoft-edgedriver-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgedriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedgedriver.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [86/282] winget-microsoft-edgewebview2runtime-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edgewebview2runtime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msedge.sf.dl.delivery.mp.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [87/282] winget-microsoft-edit-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-edit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [88/282] winget-microsoft-enterprisestateclassify-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-enterprisestateclassify-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [89/282] winget-microsoft-eventlogexpert-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-eventlogexpert-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [90/282] winget-microsoft-fslogix-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fslogix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [91/282] winget-microsoft-foundrylocal-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-foundrylocal-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "foundry.onnxruntime.ai" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [92/282] winget-microsoft-fuzzylookupaddexcel-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-fuzzylookupaddexcel-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [93/282] winget-microsoft-gameinput-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-gameinput-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [94/282] winget-microsoft-garnet-dn8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [95/282] winget-microsoft-garnet-dn9-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-garnet-dn9-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [96/282] winget-microsoft-git-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-git-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [97/282] winget-microsoft-globalsecureaccessclient-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-globalsecureaccessclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.msappproxy.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [98/282] winget-microsoft-hidtools-waratah-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hidtools-waratah-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [99/282] winget-microsoft-hwpconverter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-hwpconverter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [100/282] winget-microsoft-iis-compression-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-compression-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [101/282] winget-microsoft-iis-servicemonitor-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-servicemonitor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [102/282] winget-microsoft-iis-urlrewrite-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iis-urlrewrite-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [103/282] winget-microsoft-iismanagerremoteadministration-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-iismanagerremoteadministration-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [104/282] winget-microsoft-idfix-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-idfix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "raw.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [105/282] winget-microsoft-integrationruntime-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-integrationruntime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [106/282] winget-microsoft-intunewslplugin-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-intunewslplugin-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "raw.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [107/282] winget-microsoft-ironpython-3-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ironpython-3-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [108/282] winget-microsoft-kanagawa-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-kanagawa-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [109/282] winget-microsoft-laps-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-laps-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [110/282] winget-microsoft-lightgbm-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lightgbm-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [111/282] winget-microsoft-lingeringobjectliquidator-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-lingeringobjectliquidator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [112/282] winget-microsoft-logcheetah-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logcheetah-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [113/282] winget-microsoft-logparser-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-logparser-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [114/282] winget-microsoft-m365agentsplayground-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-m365agentsplayground-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [115/282] winget-microsoft-mfcmapi-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mfcmapi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [116/282] winget-microsoft-midi-featureenablementchecker-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-featureenablementchecker-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [117/282] winget-microsoft-midi-sdk-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-midi-sdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [118/282] winget-microsoft-mitt-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mitt-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [119/282] winget-microsoft-msix-toolkit-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msix-toolkit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [120/282] winget-microsoft-msixcore-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixcore-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [121/282] winget-microsoft-msixpackagingtool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msixpackagingtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [122/282] winget-microsoft-mutt-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mutt-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [123/282] winget-microsoft-malicioussoftwareremovaltool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-malicioussoftwareremovaltool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [124/282] winget-microsoft-mediacreationtool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mediacreationtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [125/282] winget-microsoft-mousewithoutborders-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mousewithoutborders-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [126/282] winget-microsoft-mouseandkeyboardcenter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-mouseandkeyboardcenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [127/282] winget-microsoft-ntttcp-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ntttcp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [128/282] winget-microsoft-nuget-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-nuget-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "dist.nuget.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [129/282] winget-microsoft-oscdimg-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-oscdimg-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "msdl.microsoft.com" "vsblobprodscussu5shard61.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [130/282] winget-microsoft-osconfig-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-osconfig-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [131/282] winget-microsoft-office-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-office-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "officecdn.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [132/282] winget-microsoft-officedeploymenttool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-officedeploymenttool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [133/282] winget-microsoft-onedrive-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onedrive-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "oneclient.sfx.ms" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [134/282] winget-microsoft-onelakefileexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onelakefileexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [135/282] winget-microsoft-onenotediagnostics-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-onenotediagnostics-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [136/282] winget-microsoft-openapi-hidi-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-hidi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [137/282] winget-microsoft-openapi-kiota-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openapi-kiota-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [138/282] winget-microsoft-openclglvulkancompatibilitypack-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openclglvulkancompatibilitypack-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [139/282] winget-microsoft-openjdk-11-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-11-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [140/282] winget-microsoft-openjdk-17-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-17-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [141/282] winget-microsoft-openjdk-21-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-21-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [142/282] winget-microsoft-openjdk-25-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-openjdk-25-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [143/282] winget-microsoft-pict-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pict-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [144/282] winget-microsoft-pix-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pix-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [145/282] winget-microsoft-pave-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-pave-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [146/282] winget-microsoft-perfview-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-perfview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [147/282] winget-microsoft-powerappscli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerappscli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [148/282] winget-microsoft-powerautomatedesktop-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomatedesktop-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [149/282] winget-microsoft-powerautomateprocessmining-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerautomateprocessmining-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [150/282] winget-microsoft-powerbi-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [151/282] winget-microsoft-powerbireportbuilder-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportbuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [152/282] winget-microsoft-powerbireportserver-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powerbireportserver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [153/282] winget-microsoft-powershell-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powershell-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [154/282] winget-microsoft-powertoys-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-powertoys-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [155/282] winget-microsoft-printmetadatatroubleshooter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-printmetadatatroubleshooter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [156/282] winget-microsoft-profileexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-profileexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [157/282] winget-microsoft-projecttelescope-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-projecttelescope-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [158/282] winget-microsoft-promptflow-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-promptflow-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "promptflowartifact.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [159/282] winget-microsoft-purviewinformationprotection-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-purviewinformationprotection-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [160/282] winget-microsoft-rmsclient-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-rmsclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [161/282] winget-microsoft-remotedesktopclient-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopclient-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [162/282] winget-microsoft-remotedesktopmmrservice-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotedesktopmmrservice-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "intstreamreleases.z22.web.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [163/282] winget-microsoft-remotehelp-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-remotehelp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "catalog.s.download.windowsupdate.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [164/282] winget-microsoft-reportbuilder-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-reportbuilder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [165/282] winget-microsoft-sbomtool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sbomtool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [166/282] winget-microsoft-sqlserver-2019-developer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [167/282] winget-microsoft-sqlserver-2019-express-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2019-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [168/282] winget-microsoft-sqlserver-2022-developer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [169/282] winget-microsoft-sqlserver-2022-express-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2022-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [170/282] winget-microsoft-sqlserver-2025-developer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-developer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [171/282] winget-microsoft-sqlserver-2025-express-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-2025-express-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [172/282] winget-microsoft-sqlserver-oledbdriver-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-oledbdriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [173/282] winget-microsoft-sqlserver-rmlutilities-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlserver-rmlutilities-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [174/282] winget-microsoft-sqlservermanagementstudio-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlservermanagementstudio-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [175/282] winget-microsoft-saracmd-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-saracmd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [176/282] winget-microsoft-safetyscanner-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-safetyscanner-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "definitionupdates.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [177/282] winget-microsoft-screenrecorder-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-screenrecorder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [178/282] winget-microsoft-securitycompliancetoolkit-lgpo-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-lgpo-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [179/282] winget-microsoft-securitycompliancetoolkit-policyanalyzer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-policyanalyzer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [180/282] winget-microsoft-securitycompliancetoolkit-setobjectsecurity-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-securitycompliancetoolkit-setobjectsecurity-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [181/282] winget-microsoft-servicefabricruntime-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricruntime-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [182/282] winget-microsoft-servicefabricsdk-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-servicefabricsdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [183/282] winget-microsoft-setupdiag-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-setupdiag-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [184/282] winget-microsoft-smartdump-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-smartdump-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [185/282] winget-microsoft-sqlpackage-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlpackage-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" "go.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [186/282] winget-microsoft-sqlcmd-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sqlcmd-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [187/282] winget-microsoft-surfaceapp-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfaceapp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [188/282] winget-microsoft-surfacehubrecoverytool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-surfacehubrecoverytool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [189/282] winget-microsoft-symcryptunittest-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-symcryptunittest-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [190/282] winget-microsoft-sysinternals-autologon-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autologon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [191/282] winget-microsoft-sysinternals-autoruns-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-autoruns-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [192/282] winget-microsoft-sysinternals-bginfo-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-bginfo-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [193/282] winget-microsoft-sysinternals-ctrl2cap-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-ctrl2cap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [194/282] winget-microsoft-sysinternals-debugview-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-debugview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [195/282] winget-microsoft-sysinternals-desktops-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-desktops-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [196/282] winget-microsoft-sysinternals-findlinks-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-findlinks-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [197/282] winget-microsoft-sysinternals-handle-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-handle-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [198/282] winget-microsoft-sysinternals-movefile-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-movefile-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [199/282] winget-microsoft-sysinternals-pendmoves-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-pendmoves-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [200/282] winget-microsoft-sysinternals-processexplorer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processexplorer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [201/282] winget-microsoft-sysinternals-processmonitor-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-processmonitor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [202/282] winget-microsoft-sysinternals-rammap-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rammap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [203/282] winget-microsoft-sysinternals-rdcman-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-rdcman-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [204/282] winget-microsoft-sysinternals-regjump-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-regjump-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [205/282] winget-microsoft-sysinternals-sdelete-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sdelete-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [206/282] winget-microsoft-sysinternals-sigcheck-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sigcheck-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [207/282] winget-microsoft-sysinternals-strings-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-strings-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [208/282] winget-microsoft-sysinternals-sysmon-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-sysmon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [209/282] winget-microsoft-sysinternals-tcpview-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-tcpview-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [210/282] winget-microsoft-sysinternals-vmmap-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-vmmap-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [211/282] winget-microsoft-sysinternals-whois-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-whois-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [212/282] winget-microsoft-sysinternals-zoomit-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-sysinternals-zoomit-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.sysinternals.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [213/282] winget-microsoft-teammate-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teammate-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [214/282] winget-microsoft-teams-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teams-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "installer.teams.static.microsoft" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [215/282] winget-microsoft-teamstxndi-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-teamstxndi-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "teams.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [216/282] winget-microsoft-timetraveldebugging-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-timetraveldebugging-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "windbg.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [217/282] winget-microsoft-tokenizer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-tokenizer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [218/282] winget-microsoft-ui-xaml-2-7-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-7-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [219/282] winget-microsoft-ui-xaml-2-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-ui-xaml-2-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [220/282] winget-microsoft-updateassistant-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-updateassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [221/282] winget-microsoft-vclibs-14-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-14-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [222/282] winget-microsoft-vclibs-desktop-14-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vclibs-desktop-14-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [223/282] winget-microsoft-vcredist-2015+-arm64-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-arm64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [224/282] winget-microsoft-vcredist-2015+-x64-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x64-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [225/282] winget-microsoft-vcredist-2015+-x86-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vcredist-2015+-x86-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [226/282] winget-microsoft-vsdotnetlogcollect-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsdotnetlogcollect-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [227/282] winget-microsoft-vsixbootstrapper-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vsixbootstrapper-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [228/282] winget-microsoft-vstor-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-vstor-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [229/282] winget-microsoft-visioviewer-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visioviewer-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [230/282] winget-microsoft-visualstudio-2022-buildtools-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-buildtools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [231/282] winget-microsoft-visualstudio-2022-enterprise-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-enterprise-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [232/282] winget-microsoft-visualstudio-2022-onecoremsvsmon-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-onecoremsvsmon-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [233/282] winget-microsoft-visualstudio-2022-professional-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-professional-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [234/282] winget-microsoft-visualstudio-2022-remotetools-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-2022-remotetools-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.visualstudio.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [235/282] winget-microsoft-visualstudio-configfinder-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-configfinder-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [236/282] winget-microsoft-visualstudio-extensions-typescript-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-extensions-typescript-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "typescriptteam.gallerycdn.vsassets.io" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [237/282] winget-microsoft-visualstudio-locator-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudio-locator-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [238/282] winget-microsoft-visualstudiocode-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualstudiocode-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "vscode.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [239/282] winget-microsoft-visualtruetype-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-visualtruetype-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [240/282] winget-microsoft-wsl-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wsl-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [241/282] winget-microsoft-wassette-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wassette-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [242/282] winget-microsoft-webdeploy-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-webdeploy-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [243/282] winget-microsoft-win32contentpreptool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-win32contentpreptool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "codeload.github.com" "github.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [244/282] winget-microsoft-winappcli-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winappcli-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [245/282] winget-microsoft-windbg-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windbg-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "windbg.download.prss.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [246/282] winget-microsoft-windowsadk-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [247/282] winget-microsoft-windowsadmincenter-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsadmincenter-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [248/282] winget-microsoft-windowsapp-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapp-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [249/282] winget-microsoft-windowsappruntime-1-7-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-7-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [250/282] winget-microsoft-windowsappruntime-1-8-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsappruntime-1-8-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [251/282] winget-microsoft-windowsapplicationdriver-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsapplicationdriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [252/282] winget-microsoft-windowsbusestracing-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsbusestracing-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [253/282] winget-microsoft-windowscloudioprotectiondriver-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowscloudioprotectiondriver-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "res-1.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [254/282] winget-microsoft-windowsdevicerecoverytool-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsdevicerecoverytool-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [255/282] winget-microsoft-windowsinstallationassistant-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsinstallationassistant-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [256/282] winget-microsoft-windowsmidiservicessdk-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsmidiservicessdk-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [257/282] winget-microsoft-windowspchealthcheck-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowspchealthcheck-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [258/282] winget-microsoft-windowssdk-10-0-22621-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-22621-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [259/282] winget-microsoft-windowssdk-10-0-26100-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-26100-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [260/282] winget-microsoft-windowssdk-10-0-28000-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowssdk-10-0-28000-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [261/282] winget-microsoft-windowsterminal-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsterminal-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [262/282] winget-microsoft-windowsvirtualdesktopagent-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopagent-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "go.microsoft.com" "query.prod.cms.rt.microsoft.com" "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [263/282] winget-microsoft-windowsvirtualdesktopbootloader-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowsvirtualdesktopbootloader-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "query.prod.cms.rt.microsoft.com" "res.cdn.office.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [264/282] winget-microsoft-windowswdk-10-0-22621-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-22621-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [265/282] winget-microsoft-windowswdk-10-0-26100-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-windowswdk-10-0-26100-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [266/282] winget-microsoft-wingetcreate-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-wingetcreate-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [267/282] winget-microsoft-xmlnotepad-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-xmlnotepad-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [268/282] winget-microsoft-bitsmanager-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-bitsmanager-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [269/282] winget-microsoft-err-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-err-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [270/282] winget-microsoft-etl2pcapng-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-etl2pcapng-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [271/282] winget-microsoft-msodbcsql-17-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-17-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [272/282] winget-microsoft-msodbcsql-18-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-msodbcsql-18-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "download.microsoft.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [273/282] winget-microsoft-quicreach-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-quicreach-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [274/282] winget-microsoft-winfile-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-microsoft-winfile-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "github.com" "objects.githubusercontent.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [275/282] winget-telerik-fiddler-classic-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-telerik-fiddler-classic-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "downloads.getfiddler.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [276/282] winget-wiresharkfoundation-stratoshark-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-stratoshark-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "1.na.dl.wireshark.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [277/282] winget-wiresharkfoundation-wireshark-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wiresharkfoundation-wireshark-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "2.na.dl.wireshark.org" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [278/282] wsl-infrastructure-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "wsl-infrastructure-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [279/282] winget-wsl-ubuntu-20-04-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-20-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [280/282] winget-wsl-ubuntu-22-04-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-22-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "aka.ms" "wslstorestorage.blob.core.windows.net" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [281/282] winget-wsl-ubuntu-24-04-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-24-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

echo -ne "   [282/282] winget-wsl-ubuntu-26-04-fqdn ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "winget-wsl-ubuntu-26-04-fqdn" \
  --rule-type ApplicationRule \
  --protocols Https=443 \
  --target-fqdns "cdimages.ubuntu.com" \
  --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
  echo -e "${GREEN}✅${NC}"
  CURRENT=$((CURRENT + 1))
else
  echo -e "${RED}❌${NC}"
  FAILED=$((FAILED + 1))
fi

# =============================================
# 步驟 6：部署摘要
# =============================================
echo ""
echo "=============================="
echo -e "${CYAN}📊 部署摘要${NC}"
echo "=============================="
echo "   Policy:        $POLICY_NAME"
echo "   RCG:           $RCG_NAME"
echo "   Collection:    $RC_NAME"
echo -e "   ✅ 成功:        ${GREEN}$CURRENT / 282${NC}"
if [ $FAILED -gt 0 ]; then
  echo -e "   ❌ 失敗:        ${RED}$FAILED${NC}"
fi
echo "=============================="
echo ""

if [ $FAILED -gt 0 ]; then
  echo -e "${YELLOW}⚠️  有 $FAILED 條規則新增失敗，請檢查錯誤訊息${NC}"
fi

echo -e "${YELLOW}⚠️  規則已寫入 Draft，尚未套用至正式環境${NC}"
echo -e "${YELLOW}   請在 Azure Portal 確認 Draft 內容後，執行以下指令部署：${NC}"
echo ""
echo 'az network firewall policy rule-collection-group draft deploy \'
echo '  --policy-name "'$POLICY_NAME'" \'
echo '  --resource-group "'$RESOURCE_GROUP'" \'
echo '  --rule-collection-group-name "'$RCG_NAME'"'
echo ""
