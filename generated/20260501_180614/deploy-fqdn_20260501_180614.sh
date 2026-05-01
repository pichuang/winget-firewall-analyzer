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
# 步驟 3：在 Draft 中建立 Rule Collection
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

echo -ne "   [1/282] mirror-to-winget-infra-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-winget-infra-https" \
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

echo -ne "   [2/282] mirror-to-gh-copilot-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-gh-copilot-https" \
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

echo -ne "   [3/282] mirror-to-gh-githubdesktop-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-gh-githubdesktop-https" \
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

echo -ne "   [4/282] mirror-to-gh-gitlfs-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-gh-gitlfs-https" \
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

echo -ne "   [5/282] mirror-to-gh-cli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-gh-cli-https" \
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

echo -ne "   [6/282] mirror-to-gh-git-sizer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-gh-git-sizer-https" \
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

echo -ne "   [7/282] mirror-to-ms-aksdesktop-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-aksdesktop-https" \
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

echo -ne "   [8/282] mirror-to-ms-apm-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-apm-https" \
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

echo -ne "   [9/282] mirror-to-ms-asrtesttool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-asrtesttool-https" \
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

echo -ne "   [10/282] mirror-to-ms-accountlockoutstatus-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-accountlockoutstatus-https" \
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

echo -ne "   [11/282] mirror-to-ms-administrativetemplates-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-administrativetemplates-https" \
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

echo -ne "   [12/282] mirror-to-ms-amendmentappwordservice-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-amendmentappwordservice-https" \
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

echo -ne "   [13/282] mirror-to-ms-appcontrolpolicywizard-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-appcontrolpolicywizard-https" \
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

echo -ne "   [14/282] mirror-to-ms-appinstaller-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-appinstaller-https" \
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

echo -ne "   [15/282] mirror-to-ms-appinstallerfilebuilder-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-appinstallerfilebuilder-https" \
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

echo -ne "   [16/282] mirror-to-ms-applockerpolicyconverter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-applockerpolicyconverter-https" \
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

echo -ne "   [17/282] mirror-to-ms-applicationinspector-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-applicationinspector-https" \
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

echo -ne "   [18/282] mirror-to-ms-aspire-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-aspire-https" \
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

echo -ne "   [19/282] mirror-to-ms-azd-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azd-https" \
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

echo -ne "   [20/282] mirror-to-ms-azure-adconnectsyncdocumenter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-adconnectsyncdocumenter-https" \
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

echo -ne "   [21/282] mirror-to-ms-azure-azcopy-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-azcopy-10-https" \
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

echo -ne "   [22/282] mirror-to-ms-azure-artifactsigningclienttools-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-artifactsigningclienttools-https" \
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

echo -ne "   [23/282] mirror-to-ms-azure-auth-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-auth-https" \
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

echo -ne "   [24/282] mirror-to-ms-azure-az-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-az-https" \
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

echo -ne "   [25/282] mirror-to-ms-azure-aztfexport-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-aztfexport-https" \
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

echo -ne "   [26/282] mirror-to-ms-azure-batchexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-batchexplorer-https" \
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

echo -ne "   [27/282] mirror-to-ms-azure-cloudhsm-clientsdk-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-cloudhsm-clientsdk-https" \
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

echo -ne "   [28/282] mirror-to-ms-azure-connectedmachineagent-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-connectedmachineagent-https" \
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

echo -ne "   [29/282] mirror-to-ms-azure-cosmosemulator-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-cosmosemulator-https" \
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

echo -ne "   [30/282] mirror-to-ms-azure-datacli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-datacli-https" \
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

echo -ne "   [31/282] mirror-to-ms-azure-datastudio-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-datastudio-https" \
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

echo -ne "   [32/282] mirror-to-ms-azure-functionscoretools-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-functionscoretools-https" \
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

echo -ne "   [33/282] mirror-to-ms-azure-guestproxyagent-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-guestproxyagent-https" \
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

echo -ne "   [34/282] mirror-to-ms-azure-iotexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-iotexplorer-https" \
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

echo -ne "   [35/282] mirror-to-ms-azure-kubelogin-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-kubelogin-https" \
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

echo -ne "   [36/282] mirror-to-ms-azure-quickreview-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-quickreview-https" \
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

echo -ne "   [37/282] mirror-to-ms-azure-storageexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-storageexplorer-https" \
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

echo -ne "   [38/282] mirror-to-ms-azure-templateanalyzer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-templateanalyzer-https" \
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

echo -ne "   [39/282] mirror-to-ms-azure-trustedsigningclienttools-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azure-trustedsigningclienttools-https" \
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

echo -ne "   [40/282] mirror-to-ms-azurecli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azurecli-https" \
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

echo -ne "   [41/282] mirror-to-ms-azuremonitoragent-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azuremonitoragent-https" \
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

echo -ne "   [42/282] mirror-to-ms-azurevpnclient-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-azurevpnclient-https" \
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

echo -ne "   [43/282] mirror-to-ms-btp-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-btp-https" \
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

echo -ne "   [44/282] mirror-to-ms-bicep-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-bicep-https" \
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

echo -ne "   [45/282] mirror-to-ms-clrtypessqlserver-2019-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-clrtypessqlserver-2019-https" \
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

echo -ne "   [46/282] mirror-to-ms-certifiedtoolazurevm-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-certifiedtoolazurevm-https" \
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

echo -ne "   [47/282] mirror-to-ms-cmdpalazureextension-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-cmdpalazureextension-https" \
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

echo -ne "   [48/282] mirror-to-ms-cmdpalgithubextension-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-cmdpalgithubextension-https" \
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

echo -ne "   [49/282] mirror-to-ms-dsc-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dsc-https" \
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

echo -ne "   [50/282] mirror-to-ms-dtrace-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dtrace-https" \
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

echo -ne "   [51/282] mirror-to-ms-datamigrationassistant-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-datamigrationassistant-https" \
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

echo -ne "   [52/282] mirror-to-ms-datatools-integrationservices-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-datatools-integrationservices-https" \
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

echo -ne "   [53/282] mirror-to-ms-debugdiag-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-debugdiag-https" \
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

echo -ne "   [54/282] mirror-to-ms-defenderforcloud-cli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-defenderforcloud-cli-https" \
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

echo -ne "   [55/282] mirror-to-ms-dependencyagent-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dependencyagent-https" \
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

echo -ne "   [56/282] mirror-to-ms-deploymenttoolkit-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-deploymenttoolkit-https" \
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

echo -ne "   [57/282] mirror-to-ms-devskim-cli-dotnettool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-devskim-cli-dotnettool-https" \
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

echo -ne "   [58/282] mirror-to-ms-devskim-cli-librarypackage-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-devskim-cli-librarypackage-https" \
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

echo -ne "   [59/282] mirror-to-ms-directx-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-directx-https" \
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

echo -ne "   [60/282] mirror-to-ms-directxtex-texassemble-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-directxtex-texassemble-https" \
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

echo -ne "   [61/282] mirror-to-ms-directxtex-texconv-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-directxtex-texconv-https" \
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

echo -ne "   [62/282] mirror-to-ms-directxtex-texdiag-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-directxtex-texdiag-https" \
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

echo -ne "   [63/282] mirror-to-ms-diskspd-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-diskspd-https" \
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

echo -ne "   [64/282] mirror-to-ms-dotnet-aspnetcore-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-aspnetcore-10-https" \
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

echo -ne "   [65/282] mirror-to-ms-dotnet-aspnetcore-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-aspnetcore-8-https" \
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

echo -ne "   [66/282] mirror-to-ms-dotnet-aspnetcore-9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-aspnetcore-9-https" \
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

echo -ne "   [67/282] mirror-to-ms-dotnet-desktopruntime-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-desktopruntime-10-https" \
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

echo -ne "   [68/282] mirror-to-ms-dotnet-desktopruntime-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-desktopruntime-8-https" \
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

echo -ne "   [69/282] mirror-to-ms-dotnet-desktopruntime-9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-desktopruntime-9-https" \
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

echo -ne "   [70/282] mirror-to-ms-dotnet-framework-developerpack_4-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-framework-developerpack_4-https" \
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

echo -ne "   [71/282] mirror-to-ms-dotnet-framework-runtime-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-framework-runtime-https" \
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

echo -ne "   [72/282] mirror-to-ms-dotnet-hostingbundle-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-hostingbundle-10-https" \
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

echo -ne "   [73/282] mirror-to-ms-dotnet-hostingbundle-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-hostingbundle-8-https" \
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

echo -ne "   [74/282] mirror-to-ms-dotnet-hostingbundle-9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-hostingbundle-9-https" \
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

echo -ne "   [75/282] mirror-to-ms-dotnet-repairtool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-repairtool-https" \
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

echo -ne "   [76/282] mirror-to-ms-dotnet-runtime-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-runtime-10-https" \
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

echo -ne "   [77/282] mirror-to-ms-dotnet-runtime-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-runtime-8-https" \
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

echo -ne "   [78/282] mirror-to-ms-dotnet-runtime-9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-runtime-9-https" \
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

echo -ne "   [79/282] mirror-to-ms-dotnet-sdk-10-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-sdk-10-https" \
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

echo -ne "   [80/282] mirror-to-ms-dotnet-sdk-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-sdk-8-https" \
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

echo -ne "   [81/282] mirror-to-ms-dotnet-sdk-9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-sdk-9-https" \
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

echo -ne "   [82/282] mirror-to-ms-dotnet-uninstalltool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-uninstalltool-https" \
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

echo -ne "   [83/282] mirror-to-ms-dotnet-dotnet-ef-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-dotnet-dotnet-ef-https" \
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

echo -ne "   [84/282] mirror-to-ms-edge-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-edge-https" \
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

echo -ne "   [85/282] mirror-to-ms-edgedriver-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-edgedriver-https" \
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

echo -ne "   [86/282] mirror-to-ms-edgewebview2runtime-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-edgewebview2runtime-https" \
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

echo -ne "   [87/282] mirror-to-ms-edit-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-edit-https" \
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

echo -ne "   [88/282] mirror-to-ms-enterprisestateclassify-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-enterprisestateclassify-https" \
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

echo -ne "   [89/282] mirror-to-ms-eventlogexpert-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-eventlogexpert-https" \
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

echo -ne "   [90/282] mirror-to-ms-fslogix-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-fslogix-https" \
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

echo -ne "   [91/282] mirror-to-ms-foundrylocal-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-foundrylocal-https" \
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

echo -ne "   [92/282] mirror-to-ms-fuzzylookupaddexcel-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-fuzzylookupaddexcel-https" \
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

echo -ne "   [93/282] mirror-to-ms-gameinput-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-gameinput-https" \
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

echo -ne "   [94/282] mirror-to-ms-garnet-dn8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-garnet-dn8-https" \
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

echo -ne "   [95/282] mirror-to-ms-garnet-dn9-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-garnet-dn9-https" \
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

echo -ne "   [96/282] mirror-to-ms-git-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-git-https" \
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

echo -ne "   [97/282] mirror-to-ms-globalsecureaccessclient-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-globalsecureaccessclient-https" \
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

echo -ne "   [98/282] mirror-to-ms-hidtools-waratah-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-hidtools-waratah-https" \
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

echo -ne "   [99/282] mirror-to-ms-hwpconverter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-hwpconverter-https" \
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

echo -ne "   [100/282] mirror-to-ms-iis-compression-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-iis-compression-https" \
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

echo -ne "   [101/282] mirror-to-ms-iis-servicemonitor-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-iis-servicemonitor-https" \
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

echo -ne "   [102/282] mirror-to-ms-iis-urlrewrite-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-iis-urlrewrite-https" \
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

echo -ne "   [103/282] mirror-to-ms-iismanagerremoteadministration-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-iismanagerremoteadministration-https" \
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

echo -ne "   [104/282] mirror-to-ms-idfix-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-idfix-https" \
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

echo -ne "   [105/282] mirror-to-ms-integrationruntime-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-integrationruntime-https" \
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

echo -ne "   [106/282] mirror-to-ms-intunewslplugin-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-intunewslplugin-https" \
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

echo -ne "   [107/282] mirror-to-ms-ironpython-3-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-ironpython-3-https" \
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

echo -ne "   [108/282] mirror-to-ms-kanagawa-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-kanagawa-https" \
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

echo -ne "   [109/282] mirror-to-ms-laps-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-laps-https" \
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

echo -ne "   [110/282] mirror-to-ms-lightgbm-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-lightgbm-https" \
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

echo -ne "   [111/282] mirror-to-ms-lingeringobjectliquidator-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-lingeringobjectliquidator-https" \
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

echo -ne "   [112/282] mirror-to-ms-logcheetah-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-logcheetah-https" \
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

echo -ne "   [113/282] mirror-to-ms-logparser-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-logparser-https" \
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

echo -ne "   [114/282] mirror-to-ms-m365agentsplayground-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-m365agentsplayground-https" \
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

echo -ne "   [115/282] mirror-to-ms-mfcmapi-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mfcmapi-https" \
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

echo -ne "   [116/282] mirror-to-ms-midi-featureenablementchecker-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-midi-featureenablementchecker-https" \
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

echo -ne "   [117/282] mirror-to-ms-midi-sdk-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-midi-sdk-https" \
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

echo -ne "   [118/282] mirror-to-ms-mitt-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mitt-https" \
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

echo -ne "   [119/282] mirror-to-ms-msix-toolkit-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-msix-toolkit-https" \
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

echo -ne "   [120/282] mirror-to-ms-msixcore-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-msixcore-https" \
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

echo -ne "   [121/282] mirror-to-ms-msixpackagingtool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-msixpackagingtool-https" \
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

echo -ne "   [122/282] mirror-to-ms-mutt-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mutt-https" \
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

echo -ne "   [123/282] mirror-to-ms-malicioussoftwareremovaltool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-malicioussoftwareremovaltool-https" \
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

echo -ne "   [124/282] mirror-to-ms-mediacreationtool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mediacreationtool-https" \
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

echo -ne "   [125/282] mirror-to-ms-mousewithoutborders-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mousewithoutborders-https" \
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

echo -ne "   [126/282] mirror-to-ms-mouseandkeyboardcenter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-mouseandkeyboardcenter-https" \
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

echo -ne "   [127/282] mirror-to-ms-ntttcp-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-ntttcp-https" \
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

echo -ne "   [128/282] mirror-to-ms-nuget-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-nuget-https" \
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

echo -ne "   [129/282] mirror-to-ms-oscdimg-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-oscdimg-https" \
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

echo -ne "   [130/282] mirror-to-ms-osconfig-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-osconfig-https" \
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

echo -ne "   [131/282] mirror-to-ms-office-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-office-https" \
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

echo -ne "   [132/282] mirror-to-ms-officedeploymenttool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-officedeploymenttool-https" \
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

echo -ne "   [133/282] mirror-to-ms-onedrive-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-onedrive-https" \
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

echo -ne "   [134/282] mirror-to-ms-onelakefileexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-onelakefileexplorer-https" \
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

echo -ne "   [135/282] mirror-to-ms-onenotediagnostics-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-onenotediagnostics-https" \
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

echo -ne "   [136/282] mirror-to-ms-openapi-hidi-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openapi-hidi-https" \
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

echo -ne "   [137/282] mirror-to-ms-openapi-kiota-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openapi-kiota-https" \
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

echo -ne "   [138/282] mirror-to-ms-openclglvulkancompatibilitypack-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openclglvulkancompatibilitypack-https" \
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

echo -ne "   [139/282] mirror-to-ms-openjdk-11-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openjdk-11-https" \
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

echo -ne "   [140/282] mirror-to-ms-openjdk-17-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openjdk-17-https" \
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

echo -ne "   [141/282] mirror-to-ms-openjdk-21-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openjdk-21-https" \
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

echo -ne "   [142/282] mirror-to-ms-openjdk-25-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-openjdk-25-https" \
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

echo -ne "   [143/282] mirror-to-ms-pict-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-pict-https" \
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

echo -ne "   [144/282] mirror-to-ms-pix-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-pix-https" \
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

echo -ne "   [145/282] mirror-to-ms-pave-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-pave-https" \
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

echo -ne "   [146/282] mirror-to-ms-perfview-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-perfview-https" \
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

echo -ne "   [147/282] mirror-to-ms-powerappscli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerappscli-https" \
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

echo -ne "   [148/282] mirror-to-ms-powerautomatedesktop-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerautomatedesktop-https" \
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

echo -ne "   [149/282] mirror-to-ms-powerautomateprocessmining-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerautomateprocessmining-https" \
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

echo -ne "   [150/282] mirror-to-ms-powerbi-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerbi-https" \
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

echo -ne "   [151/282] mirror-to-ms-powerbireportbuilder-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerbireportbuilder-https" \
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

echo -ne "   [152/282] mirror-to-ms-powerbireportserver-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powerbireportserver-https" \
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

echo -ne "   [153/282] mirror-to-ms-powershell-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powershell-https" \
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

echo -ne "   [154/282] mirror-to-ms-powertoys-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-powertoys-https" \
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

echo -ne "   [155/282] mirror-to-ms-printmetadatatroubleshooter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-printmetadatatroubleshooter-https" \
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

echo -ne "   [156/282] mirror-to-ms-profileexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-profileexplorer-https" \
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

echo -ne "   [157/282] mirror-to-ms-projecttelescope-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-projecttelescope-https" \
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

echo -ne "   [158/282] mirror-to-ms-promptflow-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-promptflow-https" \
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

echo -ne "   [159/282] mirror-to-ms-purviewinformationprotection-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-purviewinformationprotection-https" \
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

echo -ne "   [160/282] mirror-to-ms-rmsclient-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-rmsclient-https" \
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

echo -ne "   [161/282] mirror-to-ms-remotedesktopclient-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-remotedesktopclient-https" \
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

echo -ne "   [162/282] mirror-to-ms-remotedesktopmmrservice-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-remotedesktopmmrservice-https" \
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

echo -ne "   [163/282] mirror-to-ms-remotehelp-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-remotehelp-https" \
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

echo -ne "   [164/282] mirror-to-ms-reportbuilder-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-reportbuilder-https" \
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

echo -ne "   [165/282] mirror-to-ms-sbomtool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sbomtool-https" \
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

echo -ne "   [166/282] mirror-to-ms-sqlserver-2019-developer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2019-developer-https" \
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

echo -ne "   [167/282] mirror-to-ms-sqlserver-2019-express-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2019-express-https" \
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

echo -ne "   [168/282] mirror-to-ms-sqlserver-2022-developer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2022-developer-https" \
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

echo -ne "   [169/282] mirror-to-ms-sqlserver-2022-express-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2022-express-https" \
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

echo -ne "   [170/282] mirror-to-ms-sqlserver-2025-developer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2025-developer-https" \
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

echo -ne "   [171/282] mirror-to-ms-sqlserver-2025-express-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-2025-express-https" \
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

echo -ne "   [172/282] mirror-to-ms-sqlserver-oledbdriver-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-oledbdriver-https" \
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

echo -ne "   [173/282] mirror-to-ms-sqlserver-rmlutilities-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlserver-rmlutilities-https" \
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

echo -ne "   [174/282] mirror-to-ms-sqlservermanagementstudio-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlservermanagementstudio-https" \
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

echo -ne "   [175/282] mirror-to-ms-saracmd-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-saracmd-https" \
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

echo -ne "   [176/282] mirror-to-ms-safetyscanner-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-safetyscanner-https" \
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

echo -ne "   [177/282] mirror-to-ms-screenrecorder-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-screenrecorder-https" \
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

echo -ne "   [178/282] mirror-to-ms-securitycompliancetoolkit-lgpo-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-securitycompliancetoolkit-lgpo-https" \
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

echo -ne "   [179/282] mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https" \
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

echo -ne "   [180/282] mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https" \
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

echo -ne "   [181/282] mirror-to-ms-servicefabricruntime-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-servicefabricruntime-https" \
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

echo -ne "   [182/282] mirror-to-ms-servicefabricsdk-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-servicefabricsdk-https" \
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

echo -ne "   [183/282] mirror-to-ms-setupdiag-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-setupdiag-https" \
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

echo -ne "   [184/282] mirror-to-ms-smartdump-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-smartdump-https" \
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

echo -ne "   [185/282] mirror-to-ms-sqlpackage-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlpackage-https" \
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

echo -ne "   [186/282] mirror-to-ms-sqlcmd-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sqlcmd-https" \
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

echo -ne "   [187/282] mirror-to-ms-surfaceapp-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-surfaceapp-https" \
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

echo -ne "   [188/282] mirror-to-ms-surfacehubrecoverytool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-surfacehubrecoverytool-https" \
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

echo -ne "   [189/282] mirror-to-ms-symcryptunittest-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-symcryptunittest-https" \
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

echo -ne "   [190/282] mirror-to-ms-sysinternals-autologon-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-autologon-https" \
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

echo -ne "   [191/282] mirror-to-ms-sysinternals-autoruns-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-autoruns-https" \
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

echo -ne "   [192/282] mirror-to-ms-sysinternals-bginfo-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-bginfo-https" \
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

echo -ne "   [193/282] mirror-to-ms-sysinternals-ctrl2cap-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-ctrl2cap-https" \
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

echo -ne "   [194/282] mirror-to-ms-sysinternals-debugview-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-debugview-https" \
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

echo -ne "   [195/282] mirror-to-ms-sysinternals-desktops-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-desktops-https" \
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

echo -ne "   [196/282] mirror-to-ms-sysinternals-findlinks-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-findlinks-https" \
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

echo -ne "   [197/282] mirror-to-ms-sysinternals-handle-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-handle-https" \
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

echo -ne "   [198/282] mirror-to-ms-sysinternals-movefile-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-movefile-https" \
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

echo -ne "   [199/282] mirror-to-ms-sysinternals-pendmoves-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-pendmoves-https" \
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

echo -ne "   [200/282] mirror-to-ms-sysinternals-processexplorer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-processexplorer-https" \
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

echo -ne "   [201/282] mirror-to-ms-sysinternals-processmonitor-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-processmonitor-https" \
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

echo -ne "   [202/282] mirror-to-ms-sysinternals-rammap-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-rammap-https" \
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

echo -ne "   [203/282] mirror-to-ms-sysinternals-rdcman-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-rdcman-https" \
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

echo -ne "   [204/282] mirror-to-ms-sysinternals-regjump-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-regjump-https" \
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

echo -ne "   [205/282] mirror-to-ms-sysinternals-sdelete-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-sdelete-https" \
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

echo -ne "   [206/282] mirror-to-ms-sysinternals-sigcheck-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-sigcheck-https" \
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

echo -ne "   [207/282] mirror-to-ms-sysinternals-strings-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-strings-https" \
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

echo -ne "   [208/282] mirror-to-ms-sysinternals-sysmon-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-sysmon-https" \
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

echo -ne "   [209/282] mirror-to-ms-sysinternals-tcpview-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-tcpview-https" \
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

echo -ne "   [210/282] mirror-to-ms-sysinternals-vmmap-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-vmmap-https" \
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

echo -ne "   [211/282] mirror-to-ms-sysinternals-whois-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-whois-https" \
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

echo -ne "   [212/282] mirror-to-ms-sysinternals-zoomit-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-sysinternals-zoomit-https" \
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

echo -ne "   [213/282] mirror-to-ms-teammate-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-teammate-https" \
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

echo -ne "   [214/282] mirror-to-ms-teams-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-teams-https" \
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

echo -ne "   [215/282] mirror-to-ms-teamstxndi-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-teamstxndi-https" \
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

echo -ne "   [216/282] mirror-to-ms-timetraveldebugging-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-timetraveldebugging-https" \
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

echo -ne "   [217/282] mirror-to-ms-tokenizer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-tokenizer-https" \
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

echo -ne "   [218/282] mirror-to-ms-ui-xaml-2-7-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-ui-xaml-2-7-https" \
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

echo -ne "   [219/282] mirror-to-ms-ui-xaml-2-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-ui-xaml-2-8-https" \
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

echo -ne "   [220/282] mirror-to-ms-updateassistant-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-updateassistant-https" \
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

echo -ne "   [221/282] mirror-to-ms-vclibs-14-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vclibs-14-https" \
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

echo -ne "   [222/282] mirror-to-ms-vclibs-desktop-14-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vclibs-desktop-14-https" \
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

echo -ne "   [223/282] mirror-to-ms-vcredist-2015+-arm64-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vcredist-2015+-arm64-https" \
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

echo -ne "   [224/282] mirror-to-ms-vcredist-2015+-x64-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vcredist-2015+-x64-https" \
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

echo -ne "   [225/282] mirror-to-ms-vcredist-2015+-x86-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vcredist-2015+-x86-https" \
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

echo -ne "   [226/282] mirror-to-ms-vsdotnetlogcollect-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vsdotnetlogcollect-https" \
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

echo -ne "   [227/282] mirror-to-ms-vsixbootstrapper-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vsixbootstrapper-https" \
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

echo -ne "   [228/282] mirror-to-ms-vstor-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-vstor-https" \
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

echo -ne "   [229/282] mirror-to-ms-visioviewer-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visioviewer-https" \
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

echo -ne "   [230/282] mirror-to-ms-visualstudio-2022-buildtools-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-2022-buildtools-https" \
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

echo -ne "   [231/282] mirror-to-ms-visualstudio-2022-enterprise-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-2022-enterprise-https" \
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

echo -ne "   [232/282] mirror-to-ms-visualstudio-2022-onecoremsvsmon-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https" \
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

echo -ne "   [233/282] mirror-to-ms-visualstudio-2022-professional-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-2022-professional-https" \
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

echo -ne "   [234/282] mirror-to-ms-visualstudio-2022-remotetools-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-2022-remotetools-https" \
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

echo -ne "   [235/282] mirror-to-ms-visualstudio-configfinder-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-configfinder-https" \
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

echo -ne "   [236/282] mirror-to-ms-visualstudio-extensions-typescript-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-extensions-typescript-https" \
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

echo -ne "   [237/282] mirror-to-ms-visualstudio-locator-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudio-locator-https" \
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

echo -ne "   [238/282] mirror-to-ms-visualstudiocode-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualstudiocode-https" \
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

echo -ne "   [239/282] mirror-to-ms-visualtruetype-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-visualtruetype-https" \
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

echo -ne "   [240/282] mirror-to-ms-wsl-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-wsl-https" \
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

echo -ne "   [241/282] mirror-to-ms-wassette-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-wassette-https" \
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

echo -ne "   [242/282] mirror-to-ms-webdeploy-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-webdeploy-https" \
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

echo -ne "   [243/282] mirror-to-ms-win32contentpreptool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-win32contentpreptool-https" \
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

echo -ne "   [244/282] mirror-to-ms-winappcli-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-winappcli-https" \
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

echo -ne "   [245/282] mirror-to-ms-windbg-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windbg-https" \
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

echo -ne "   [246/282] mirror-to-ms-windowsadk-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsadk-https" \
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

echo -ne "   [247/282] mirror-to-ms-windowsadmincenter-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsadmincenter-https" \
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

echo -ne "   [248/282] mirror-to-ms-windowsapp-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsapp-https" \
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

echo -ne "   [249/282] mirror-to-ms-windowsappruntime-1-7-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsappruntime-1-7-https" \
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

echo -ne "   [250/282] mirror-to-ms-windowsappruntime-1-8-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsappruntime-1-8-https" \
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

echo -ne "   [251/282] mirror-to-ms-windowsapplicationdriver-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsapplicationdriver-https" \
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

echo -ne "   [252/282] mirror-to-ms-windowsbusestracing-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsbusestracing-https" \
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

echo -ne "   [253/282] mirror-to-ms-windowscloudioprotectiondriver-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowscloudioprotectiondriver-https" \
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

echo -ne "   [254/282] mirror-to-ms-windowsdevicerecoverytool-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsdevicerecoverytool-https" \
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

echo -ne "   [255/282] mirror-to-ms-windowsinstallationassistant-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsinstallationassistant-https" \
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

echo -ne "   [256/282] mirror-to-ms-windowsmidiservicessdk-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsmidiservicessdk-https" \
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

echo -ne "   [257/282] mirror-to-ms-windowspchealthcheck-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowspchealthcheck-https" \
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

echo -ne "   [258/282] mirror-to-ms-windowssdk-10-0-22621-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowssdk-10-0-22621-https" \
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

echo -ne "   [259/282] mirror-to-ms-windowssdk-10-0-26100-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowssdk-10-0-26100-https" \
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

echo -ne "   [260/282] mirror-to-ms-windowssdk-10-0-28000-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowssdk-10-0-28000-https" \
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

echo -ne "   [261/282] mirror-to-ms-windowsterminal-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsterminal-https" \
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

echo -ne "   [262/282] mirror-to-ms-windowsvirtualdesktopagent-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsvirtualdesktopagent-https" \
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

echo -ne "   [263/282] mirror-to-ms-windowsvirtualdesktopbootloader-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowsvirtualdesktopbootloader-https" \
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

echo -ne "   [264/282] mirror-to-ms-windowswdk-10-0-22621-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowswdk-10-0-22621-https" \
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

echo -ne "   [265/282] mirror-to-ms-windowswdk-10-0-26100-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-windowswdk-10-0-26100-https" \
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

echo -ne "   [266/282] mirror-to-ms-wingetcreate-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-wingetcreate-https" \
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

echo -ne "   [267/282] mirror-to-ms-xmlnotepad-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-xmlnotepad-https" \
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

echo -ne "   [268/282] mirror-to-ms-bitsmanager-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-bitsmanager-https" \
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

echo -ne "   [269/282] mirror-to-ms-err-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-err-https" \
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

echo -ne "   [270/282] mirror-to-ms-etl2pcapng-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-etl2pcapng-https" \
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

echo -ne "   [271/282] mirror-to-ms-msodbcsql-17-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-msodbcsql-17-https" \
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

echo -ne "   [272/282] mirror-to-ms-msodbcsql-18-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-msodbcsql-18-https" \
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

echo -ne "   [273/282] mirror-to-ms-quicreach-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-quicreach-https" \
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

echo -ne "   [274/282] mirror-to-ms-winfile-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-ms-winfile-https" \
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

echo -ne "   [275/282] mirror-to-telerik-fiddler-classic-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-telerik-fiddler-classic-https" \
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

echo -ne "   [276/282] mirror-to-wiresharkfoundation-stratoshark-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wiresharkfoundation-stratoshark-https" \
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

echo -ne "   [277/282] mirror-to-wiresharkfoundation-wireshark-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wiresharkfoundation-wireshark-https" \
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

echo -ne "   [278/282] mirror-to-wsl-infra-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wsl-infra-https" \
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

echo -ne "   [279/282] mirror-to-wsl-ubuntu-20-04-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wsl-ubuntu-20-04-https" \
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

echo -ne "   [280/282] mirror-to-wsl-ubuntu-22-04-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wsl-ubuntu-22-04-https" \
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

echo -ne "   [281/282] mirror-to-wsl-ubuntu-24-04-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wsl-ubuntu-24-04-https" \
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

echo -ne "   [282/282] mirror-to-wsl-ubuntu-26-04-https ... "
if az network firewall policy rule-collection-group draft collection rule add \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --collection-name "$RC_NAME" \
  --name "mirror-to-wsl-ubuntu-26-04-https" \
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
