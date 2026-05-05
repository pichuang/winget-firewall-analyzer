#!/bin/bash
# Azure Firewall Policy 規則部署指令 — FQDN 層級（無 TLS Inspection）
# ⚠️ 使用 Draft 模式：規則不會直接套用，需手動執行 deploy 指令確認後才生效
# 🔄 冪等執行：相同規則自動跳過，不同規則以最新版本覆蓋
# 產生時間：請自行記錄
# 規則數量：285

set -euo pipefail

POLICY_NAME="afwp-global-01"
RESOURCE_GROUP="rg-vdss-afwp-prd-global"
RCG_NAME="rcg-1100-mirror-winget"
RC_NAME="action-allow-mirror"
PRIORITY=1100
EXPECTED_SUBSCRIPTION_ID=""
TOTAL_RULES=285
CURRENT=0
FAILED=0
SKIPPED=0
UPDATED=0

# 顏色定義
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

# =============================================
# 輔助函式：比對規則是否已存在且內容相同
# =============================================
rule_exists_and_matches() {
  local rule_name=$1
  local expected_targets=$2
  local target_type=$3  # targetUrls 或 targetFqdns

  # 從 Draft 中查詢現有規則
  local existing
  existing=$(az network firewall policy rule-collection-group draft collection rule show \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "$rule_name" \
    --query "{targetUrls: targetUrls, targetFqdns: targetFqdns}" \
    -o json 2>/dev/null) || return 1

  # 取出目前的 targets（依類型選擇欄位）
  local current_targets
  if [ "$target_type" = "targetUrls" ]; then
    current_targets=$(echo "$existing" | jq -r ".targetUrls // [] | sort | join(\",\")" 2>/dev/null)
  else
    current_targets=$(echo "$existing" | jq -r ".targetFqdns // [] | sort | join(\",\")" 2>/dev/null)
  fi

  # 比對排序後的內容
  local sorted_expected
  sorted_expected=$(echo "$expected_targets" | tr " " "\n" | sort | tr "\n" "," | sed "s/,$//")

  if [ "$current_targets" = "$sorted_expected" ]; then
    return 0  # 完全相同
  else
    return 2  # 存在但內容不同
  fi
}

# 移除 Draft 中的指定規則
remove_draft_rule() {
  local rule_name=$1
  az network firewall policy rule-collection-group draft collection rule remove \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "$rule_name" --output none 2>/dev/null || true
}

# =============================================
# 前置檢查
# =============================================
echo -e "${CYAN}🔍 前置檢查...${NC}"

# 啟用 Azure CLI 擴充功能自動安裝（含 preview）
az config set extension.dynamic_install_allow_preview=true --only-show-errors 2>/dev/null || true
echo -e "${GREEN}✅ 已啟用 az CLI 擴充功能自動安裝${NC}"

# 確認 jq 已安裝（冪等比對需要）
if ! command -v jq &>/dev/null; then
  echo -e "${RED}❌ 需要 jq 工具，請先安裝：brew install jq 或 apt install jq${NC}"
  exit 1
fi

# 確認 az CLI 已登入
if ! az account show --output none 2>/dev/null; then
  echo -e "${RED}❌ 尚未登入 Azure CLI，請先執行 az login${NC}"
  exit 1
fi
CURRENT_SUB_NAME=$(az account show --query "name" -o tsv)
CURRENT_SUB_ID=$(az account show --query "id" -o tsv)
echo -e "${GREEN}✅ 已登入 Azure：${CURRENT_SUB_NAME} (${CURRENT_SUB_ID})${NC}"

# 確認 Azure 訂閱正確
if [ -n "$EXPECTED_SUBSCRIPTION_ID" ]; then
  if [ "$CURRENT_SUB_ID" != "$EXPECTED_SUBSCRIPTION_ID" ]; then
    echo -e "${RED}❌ Azure 訂閱不符${NC}"
    echo -e "${RED}   預期: ${EXPECTED_SUBSCRIPTION_ID}${NC}"
    echo -e "${RED}   目前: ${CURRENT_SUB_ID} (${CURRENT_SUB_NAME})${NC}"
    echo -e "${YELLOW}   請執行: az account set --subscription ${EXPECTED_SUBSCRIPTION_ID}${NC}"
    exit 1
  fi
  echo -e "${GREEN}✅ Azure 訂閱正確：${CURRENT_SUB_ID}${NC}"
else
  echo -e "${YELLOW}⚠️  未設定預期訂閱 ID（config.yaml firewall.subscription_id），跳過訂閱檢查${NC}"
  echo -e "${YELLOW}   目前訂閱：${CURRENT_SUB_NAME} (${CURRENT_SUB_ID})${NC}"
fi

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
echo "   模式:       Draft（冪等，不會直接套用）"
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
  echo -e "${YELLOW}   ⚠️  RCG Draft 已存在（繼續執行）${NC}"
fi

# =============================================
# 步驟 4：確認 Rule Collection（沿用既有或建立新的）
# =============================================
echo -e "${CYAN}📂 步驟 4/6：檢查 Rule Collection...${NC}"
# 先檢查 Draft 中是否已有 Rule Collection
RC_EXISTS=false
if az network firewall policy rule-collection-group draft collection show \
  --policy-name "$POLICY_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --rule-collection-group-name "$RCG_NAME" \
  --name "$RC_NAME" --output none 2>/dev/null; then
  RC_EXISTS=true
  echo -e "${GREEN}   ✅ Rule Collection 已存在於 Draft 中：$RC_NAME（沿用）${NC}"
fi
# 若 Draft 中不存在，檢查正式環境（RCG Draft create 會自動複製）
if [ "$RC_EXISTS" = false ]; then
  if az network firewall policy rule-collection-group collection show \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --name "$RC_NAME" --output none 2>/dev/null; then
    RC_EXISTS=true
    echo -e "${GREEN}   ✅ Rule Collection 已存在於正式環境：$RC_NAME（Draft 會自動沿用）${NC}"
  fi
fi
# 都不存在才建立
if [ "$RC_EXISTS" = false ]; then
  echo -e "${YELLOW}   ⏳ 建立 Rule Collection：$RC_NAME ...${NC}"
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
fi

# =============================================
# 步驟 5：新增/更新規則至 Draft（共 285 條）
# =============================================
echo -e "${CYAN}🔧 步驟 5/6：同步 285 條規則至 Draft（冪等模式）...${NC}"
echo ""

echo -ne "   [1/285] mirror-to-winget-infra-https ... "
RC=0
rule_exists_and_matches "mirror-to-winget-infra-https" "cdn.winget.microsoft.com winget.azureedge.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-winget-infra-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [2/285] mirror-to-gh-copilot-https ... "
RC=0
rule_exists_and_matches "mirror-to-gh-copilot-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-gh-copilot-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [3/285] mirror-to-gh-githubdesktop-https ... "
RC=0
rule_exists_and_matches "mirror-to-gh-githubdesktop-https" "desktop.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-gh-githubdesktop-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [4/285] mirror-to-gh-gitlfs-https ... "
RC=0
rule_exists_and_matches "mirror-to-gh-gitlfs-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-gh-gitlfs-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [5/285] mirror-to-gh-cli-https ... "
RC=0
rule_exists_and_matches "mirror-to-gh-cli-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-gh-cli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [6/285] mirror-to-gh-git-sizer-https ... "
RC=0
rule_exists_and_matches "mirror-to-gh-git-sizer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-gh-git-sizer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [7/285] mirror-to-ms-aksdesktop-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-aksdesktop-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-aksdesktop-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [8/285] mirror-to-ms-apm-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-apm-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-apm-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [9/285] mirror-to-ms-asrtesttool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-asrtesttool-https" "demo.wd.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-asrtesttool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [10/285] mirror-to-ms-accessdatabaseengine2016-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-accessdatabaseengine2016-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-accessdatabaseengine2016-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-accessdatabaseengine2016-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-accessdatabaseengine2016-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [11/285] mirror-to-ms-accountlockoutstatus-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-accountlockoutstatus-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-accountlockoutstatus-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [12/285] mirror-to-ms-administrativetemplates-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-administrativetemplates-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-administrativetemplates-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [13/285] mirror-to-ms-advertisingeditor-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-advertisingeditor-https" "prod.editor.ads.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-advertisingeditor-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-advertisingeditor-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "prod.editor.ads.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-advertisingeditor-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "prod.editor.ads.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [14/285] mirror-to-ms-appcontrolpolicywizard-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-appcontrolpolicywizard-https" "webapp-wdac-wizard.azurewebsites.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-appcontrolpolicywizard-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [15/285] mirror-to-ms-appinstaller-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-appinstaller-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-appinstaller-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [16/285] mirror-to-ms-appinstallerfilebuilder-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-appinstallerfilebuilder-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-appinstallerfilebuilder-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [17/285] mirror-to-ms-applockerpolicyconverter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-applockerpolicyconverter-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-applockerpolicyconverter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [18/285] mirror-to-ms-applicationinspector-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-applicationinspector-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-applicationinspector-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [19/285] mirror-to-ms-aspire-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-aspire-https" "ci.dot.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-aspire-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [20/285] mirror-to-ms-azd-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azd-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azd-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [21/285] mirror-to-ms-azure-adconnectsyncdocumenter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-adconnectsyncdocumenter-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-adconnectsyncdocumenter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [22/285] mirror-to-ms-azure-azcopy-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-azcopy-10-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-azcopy-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [23/285] mirror-to-ms-azure-artifactsigningclienttools-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-artifactsigningclienttools-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-artifactsigningclienttools-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [24/285] mirror-to-ms-azure-auth-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-auth-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-auth-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [25/285] mirror-to-ms-azure-az-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-az-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-az-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [26/285] mirror-to-ms-azure-aztfexport-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-aztfexport-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-aztfexport-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [27/285] mirror-to-ms-azure-batchexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-batchexplorer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-batchexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [28/285] mirror-to-ms-azure-cloudhsm-clientsdk-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-cloudhsm-clientsdk-https" "github.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-cloudhsm-clientsdk-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [29/285] mirror-to-ms-azure-connectedmachineagent-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-connectedmachineagent-https" "gbl.his.arc.azure.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-connectedmachineagent-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [30/285] mirror-to-ms-azure-cosmosemulator-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-cosmosemulator-https" "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-cosmosemulator-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [31/285] mirror-to-ms-azure-datacli-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-datacli-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-datacli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [32/285] mirror-to-ms-azure-datastudio-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-datastudio-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-datastudio-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [33/285] mirror-to-ms-azure-functionscoretools-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-functionscoretools-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-functionscoretools-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [34/285] mirror-to-ms-azure-guestproxyagent-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-guestproxyagent-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-guestproxyagent-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [35/285] mirror-to-ms-azure-iotexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-iotexplorer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-iotexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [36/285] mirror-to-ms-azure-kubelogin-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-kubelogin-https" "packages.aks.azure.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-kubelogin-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [37/285] mirror-to-ms-azure-quickreview-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-quickreview-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-quickreview-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [38/285] mirror-to-ms-azure-storageexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-storageexplorer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-storageexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [39/285] mirror-to-ms-azure-templateanalyzer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-templateanalyzer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-templateanalyzer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [40/285] mirror-to-ms-azure-trustedsigningclienttools-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azure-trustedsigningclienttools-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azure-trustedsigningclienttools-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [41/285] mirror-to-ms-azurecli-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azurecli-https" "azcliprod.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azurecli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [42/285] mirror-to-ms-azuremonitoragent-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azuremonitoragent-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azuremonitoragent-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [43/285] mirror-to-ms-azurevpnclient-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-azurevpnclient-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-azurevpnclient-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [44/285] mirror-to-ms-btp-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-btp-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-btp-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [45/285] mirror-to-ms-bicep-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-bicep-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-bicep-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [46/285] mirror-to-ms-clrtypessqlserver-2019-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-clrtypessqlserver-2019-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-clrtypessqlserver-2019-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [47/285] mirror-to-ms-certifiedtoolazurevm-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-certifiedtoolazurevm-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-certifiedtoolazurevm-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [48/285] mirror-to-ms-cmdpalazureextension-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-cmdpalazureextension-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-cmdpalazureextension-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [49/285] mirror-to-ms-cmdpalgithubextension-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-cmdpalgithubextension-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-cmdpalgithubextension-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [50/285] mirror-to-ms-dsc-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dsc-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dsc-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [51/285] mirror-to-ms-dtrace-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dtrace-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dtrace-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [52/285] mirror-to-ms-datamigrationassistant-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-datamigrationassistant-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-datamigrationassistant-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [53/285] mirror-to-ms-datatools-integrationservices-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-datatools-integrationservices-https" "ssis.gallerycdn.vsassets.io" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-datatools-integrationservices-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [54/285] mirror-to-ms-debugdiag-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-debugdiag-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-debugdiag-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [55/285] mirror-to-ms-defenderforcloud-cli-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-defenderforcloud-cli-https" "cli.dfd.security.azure.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-defenderforcloud-cli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [56/285] mirror-to-ms-dependencyagent-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dependencyagent-https" "da-release-ehacb6gnczcma8hc.b01.azurefd.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dependencyagent-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [57/285] mirror-to-ms-deploymenttoolkit-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-deploymenttoolkit-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-deploymenttoolkit-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [58/285] mirror-to-ms-devskim-cli-dotnettool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-devskim-cli-dotnettool-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-devskim-cli-dotnettool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [59/285] mirror-to-ms-devskim-cli-librarypackage-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-devskim-cli-librarypackage-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-devskim-cli-librarypackage-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [60/285] mirror-to-ms-directx-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-directx-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-directx-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [61/285] mirror-to-ms-directxtex-texassemble-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-directxtex-texassemble-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-directxtex-texassemble-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [62/285] mirror-to-ms-directxtex-texconv-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-directxtex-texconv-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-directxtex-texconv-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [63/285] mirror-to-ms-directxtex-texdiag-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-directxtex-texdiag-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-directxtex-texdiag-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [64/285] mirror-to-ms-diskspd-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-diskspd-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-diskspd-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [65/285] mirror-to-ms-dotnet-aspnetcore-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-10-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-aspnetcore-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [66/285] mirror-to-ms-dotnet-aspnetcore-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-8-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-aspnetcore-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [67/285] mirror-to-ms-dotnet-aspnetcore-9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-9-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-aspnetcore-9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [68/285] mirror-to-ms-dotnet-desktopruntime-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-10-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-desktopruntime-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [69/285] mirror-to-ms-dotnet-desktopruntime-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-8-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-desktopruntime-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [70/285] mirror-to-ms-dotnet-desktopruntime-9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-9-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-desktopruntime-9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [71/285] mirror-to-ms-dotnet-framework-developerpack_4-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-framework-developerpack_4-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-framework-developerpack_4-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [72/285] mirror-to-ms-dotnet-framework-runtime-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-framework-runtime-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-framework-runtime-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [73/285] mirror-to-ms-dotnet-hostingbundle-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-10-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-hostingbundle-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [74/285] mirror-to-ms-dotnet-hostingbundle-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-8-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-hostingbundle-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [75/285] mirror-to-ms-dotnet-hostingbundle-9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-9-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-hostingbundle-9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [76/285] mirror-to-ms-dotnet-native-runtime-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-native-runtime-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-native-runtime-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-dotnet-native-runtime-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "github.com" "objects.githubusercontent.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-dotnet-native-runtime-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "github.com" "objects.githubusercontent.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [77/285] mirror-to-ms-dotnet-repairtool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-repairtool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-repairtool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [78/285] mirror-to-ms-dotnet-runtime-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-10-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-runtime-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [79/285] mirror-to-ms-dotnet-runtime-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-8-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-runtime-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [80/285] mirror-to-ms-dotnet-runtime-9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-9-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-runtime-9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [81/285] mirror-to-ms-dotnet-sdk-10-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-10-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-sdk-10-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [82/285] mirror-to-ms-dotnet-sdk-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-8-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-sdk-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [83/285] mirror-to-ms-dotnet-sdk-9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-9-https" "builds.dotnet.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-sdk-9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [84/285] mirror-to-ms-dotnet-uninstalltool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-uninstalltool-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-uninstalltool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [85/285] mirror-to-ms-dotnet-dotnet-ef-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-dotnet-dotnet-ef-https" "globalcdn.nuget.org" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-dotnet-dotnet-ef-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [86/285] mirror-to-ms-edge-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-edge-https" "msedge.sf.dl.delivery.mp.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-edge-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [87/285] mirror-to-ms-edgedriver-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-edgedriver-https" "msedgedriver.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-edgedriver-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [88/285] mirror-to-ms-edgewebview2runtime-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-edgewebview2runtime-https" "msedge.sf.dl.delivery.mp.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-edgewebview2runtime-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [89/285] mirror-to-ms-edit-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-edit-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-edit-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [90/285] mirror-to-ms-enterprisestateclassify-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-enterprisestateclassify-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-enterprisestateclassify-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [91/285] mirror-to-ms-eventlogexpert-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-eventlogexpert-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-eventlogexpert-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [92/285] mirror-to-ms-fslogix-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-fslogix-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-fslogix-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [93/285] mirror-to-ms-foundrylocal-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-foundrylocal-https" "foundry.onnxruntime.ai" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-foundrylocal-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [94/285] mirror-to-ms-fuzzylookupaddexcel-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-fuzzylookupaddexcel-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-fuzzylookupaddexcel-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [95/285] mirror-to-ms-garnet-dn8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-garnet-dn8-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-garnet-dn8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [96/285] mirror-to-ms-garnet-dn9-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-garnet-dn9-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-garnet-dn9-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [97/285] mirror-to-ms-git-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-git-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-git-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [98/285] mirror-to-ms-globalsecureaccessclient-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-globalsecureaccessclient-https" "download.msappproxy.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-globalsecureaccessclient-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [99/285] mirror-to-ms-hidtools-waratah-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-hidtools-waratah-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-hidtools-waratah-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [100/285] mirror-to-ms-hwpconverter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-hwpconverter-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-hwpconverter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [101/285] mirror-to-ms-iis-applicationrequestrouting-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-iis-applicationrequestrouting-https" "download.microsoft.com go.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-iis-applicationrequestrouting-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-iis-applicationrequestrouting-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" "go.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-iis-applicationrequestrouting-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" "go.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [102/285] mirror-to-ms-iis-compression-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-iis-compression-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-iis-compression-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [103/285] mirror-to-ms-iis-servicemonitor-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-iis-servicemonitor-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-iis-servicemonitor-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [104/285] mirror-to-ms-iis-urlrewrite-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-iis-urlrewrite-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-iis-urlrewrite-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [105/285] mirror-to-ms-iismanagerremoteadministration-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-iismanagerremoteadministration-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-iismanagerremoteadministration-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [106/285] mirror-to-ms-idfix-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-idfix-https" "github.com raw.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-idfix-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [107/285] mirror-to-ms-integrationruntime-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-integrationruntime-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-integrationruntime-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [108/285] mirror-to-ms-intunewslplugin-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-intunewslplugin-https" "github.com raw.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-intunewslplugin-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [109/285] mirror-to-ms-ironpython-3-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-ironpython-3-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-ironpython-3-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [110/285] mirror-to-ms-kanagawa-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-kanagawa-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-kanagawa-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [111/285] mirror-to-ms-laps-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-laps-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-laps-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [112/285] mirror-to-ms-lightgbm-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-lightgbm-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-lightgbm-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [113/285] mirror-to-ms-lingeringobjectliquidator-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-lingeringobjectliquidator-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-lingeringobjectliquidator-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [114/285] mirror-to-ms-logcheetah-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-logcheetah-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-logcheetah-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [115/285] mirror-to-ms-logparser-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-logparser-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-logparser-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [116/285] mirror-to-ms-m365agentsplayground-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-m365agentsplayground-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-m365agentsplayground-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [117/285] mirror-to-ms-mfcmapi-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mfcmapi-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mfcmapi-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [118/285] mirror-to-ms-midi-featureenablementchecker-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-midi-featureenablementchecker-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-midi-featureenablementchecker-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [119/285] mirror-to-ms-midi-sdk-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-midi-sdk-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-midi-sdk-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [120/285] mirror-to-ms-mitt-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mitt-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mitt-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [121/285] mirror-to-ms-msix-toolkit-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-msix-toolkit-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-msix-toolkit-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [122/285] mirror-to-ms-msixcore-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-msixcore-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-msixcore-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [123/285] mirror-to-ms-msixpackagingtool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-msixpackagingtool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-msixpackagingtool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [124/285] mirror-to-ms-mutt-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mutt-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mutt-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [125/285] mirror-to-ms-malicioussoftwareremovaltool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-malicioussoftwareremovaltool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-malicioussoftwareremovaltool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [126/285] mirror-to-ms-mediacreationtool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mediacreationtool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mediacreationtool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [127/285] mirror-to-ms-mousewithoutborders-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mousewithoutborders-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mousewithoutborders-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [128/285] mirror-to-ms-mouseandkeyboardcenter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-mouseandkeyboardcenter-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-mouseandkeyboardcenter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [129/285] mirror-to-ms-ntttcp-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-ntttcp-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-ntttcp-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [130/285] mirror-to-ms-nuget-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-nuget-https" "dist.nuget.org" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-nuget-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [131/285] mirror-to-ms-oscdimg-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-oscdimg-https" "msdl.microsoft.com vsblobprodscussu5shard61.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-oscdimg-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [132/285] mirror-to-ms-osconfig-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-osconfig-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-osconfig-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [133/285] mirror-to-ms-office-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-office-https" "officecdn.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-office-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [134/285] mirror-to-ms-officedeploymenttool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-officedeploymenttool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-officedeploymenttool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [135/285] mirror-to-ms-onedrive-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-onedrive-https" "oneclient.sfx.ms" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-onedrive-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [136/285] mirror-to-ms-onelakefileexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-onelakefileexplorer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-onelakefileexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [137/285] mirror-to-ms-onenotediagnostics-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-onenotediagnostics-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-onenotediagnostics-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [138/285] mirror-to-ms-openapi-hidi-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openapi-hidi-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openapi-hidi-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [139/285] mirror-to-ms-openapi-kiota-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openapi-kiota-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openapi-kiota-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [140/285] mirror-to-ms-openclglvulkancompatibilitypack-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openclglvulkancompatibilitypack-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openclglvulkancompatibilitypack-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [141/285] mirror-to-ms-openjdk-11-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openjdk-11-https" "aka.ms download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openjdk-11-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [142/285] mirror-to-ms-openjdk-17-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openjdk-17-https" "aka.ms download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openjdk-17-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [143/285] mirror-to-ms-openjdk-21-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openjdk-21-https" "aka.ms download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openjdk-21-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [144/285] mirror-to-ms-openjdk-25-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-openjdk-25-https" "aka.ms download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-openjdk-25-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [145/285] mirror-to-ms-pict-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-pict-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-pict-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [146/285] mirror-to-ms-pix-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-pix-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-pix-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [147/285] mirror-to-ms-pave-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-pave-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-pave-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [148/285] mirror-to-ms-perfview-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-perfview-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-perfview-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [149/285] mirror-to-ms-powerappscli-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerappscli-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerappscli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [150/285] mirror-to-ms-powerautomatedesktop-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerautomatedesktop-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerautomatedesktop-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [151/285] mirror-to-ms-powerautomateprocessmining-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerautomateprocessmining-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerautomateprocessmining-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [152/285] mirror-to-ms-powerbi-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerbi-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerbi-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [153/285] mirror-to-ms-powerbireportbuilder-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerbireportbuilder-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerbireportbuilder-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [154/285] mirror-to-ms-powerbireportserver-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powerbireportserver-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powerbireportserver-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [155/285] mirror-to-ms-powershell-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powershell-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powershell-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [156/285] mirror-to-ms-powertoys-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-powertoys-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-powertoys-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [157/285] mirror-to-ms-printmetadatatroubleshooter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-printmetadatatroubleshooter-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-printmetadatatroubleshooter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [158/285] mirror-to-ms-profileexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-profileexplorer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-profileexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [159/285] mirror-to-ms-projecttelescope-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-projecttelescope-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-projecttelescope-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [160/285] mirror-to-ms-promptflow-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-promptflow-https" "promptflowartifact.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-promptflow-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [161/285] mirror-to-ms-purviewinformationprotection-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-purviewinformationprotection-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-purviewinformationprotection-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [162/285] mirror-to-ms-rmsclient-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-rmsclient-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-rmsclient-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [163/285] mirror-to-ms-remotedesktopclient-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-remotedesktopclient-https" "res.cdn.office.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-remotedesktopclient-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [164/285] mirror-to-ms-remotedesktopmmrservice-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-remotedesktopmmrservice-https" "intstreamreleases.z22.web.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-remotedesktopmmrservice-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [165/285] mirror-to-ms-remotehelp-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-remotehelp-https" "catalog.s.download.windowsupdate.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-remotehelp-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [166/285] mirror-to-ms-reportbuilder-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-reportbuilder-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-reportbuilder-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [167/285] mirror-to-ms-sbomtool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sbomtool-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sbomtool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [168/285] mirror-to-ms-sqlserver-2019-developer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2019-developer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2019-developer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [169/285] mirror-to-ms-sqlserver-2019-express-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2019-express-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2019-express-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [170/285] mirror-to-ms-sqlserver-2022-developer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2022-developer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2022-developer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [171/285] mirror-to-ms-sqlserver-2022-express-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2022-express-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2022-express-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [172/285] mirror-to-ms-sqlserver-2025-developer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2025-developer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2025-developer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [173/285] mirror-to-ms-sqlserver-2025-express-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-2025-express-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-2025-express-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [174/285] mirror-to-ms-sqlserver-oledbdriver-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-oledbdriver-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-oledbdriver-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [175/285] mirror-to-ms-sqlserver-rmlutilities-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlserver-rmlutilities-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlserver-rmlutilities-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [176/285] mirror-to-ms-sqlservermanagementstudio-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlservermanagementstudio-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlservermanagementstudio-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [177/285] mirror-to-ms-saracmd-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-saracmd-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-saracmd-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [178/285] mirror-to-ms-safetyscanner-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-safetyscanner-https" "definitionupdates.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-safetyscanner-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [179/285] mirror-to-ms-screenrecorder-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-screenrecorder-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-screenrecorder-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [180/285] mirror-to-ms-securitycompliancetoolkit-lgpo-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-lgpo-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-securitycompliancetoolkit-lgpo-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [181/285] mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [182/285] mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [183/285] mirror-to-ms-servicefabricruntime-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-servicefabricruntime-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-servicefabricruntime-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [184/285] mirror-to-ms-servicefabricsdk-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-servicefabricsdk-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-servicefabricsdk-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [185/285] mirror-to-ms-setupdiag-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-setupdiag-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-setupdiag-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [186/285] mirror-to-ms-smartdump-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-smartdump-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-smartdump-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [187/285] mirror-to-ms-sqlpackage-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlpackage-https" "download.microsoft.com go.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlpackage-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [188/285] mirror-to-ms-sqlcmd-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sqlcmd-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sqlcmd-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [189/285] mirror-to-ms-surfaceapp-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-surfaceapp-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-surfaceapp-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [190/285] mirror-to-ms-surfacehubrecoverytool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-surfacehubrecoverytool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-surfacehubrecoverytool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [191/285] mirror-to-ms-symcryptunittest-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-symcryptunittest-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-symcryptunittest-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [192/285] mirror-to-ms-sysinternals-autologon-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-autologon-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-autologon-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [193/285] mirror-to-ms-sysinternals-autoruns-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-autoruns-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-autoruns-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [194/285] mirror-to-ms-sysinternals-bginfo-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-bginfo-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-bginfo-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [195/285] mirror-to-ms-sysinternals-ctrl2cap-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-ctrl2cap-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-ctrl2cap-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [196/285] mirror-to-ms-sysinternals-debugview-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-debugview-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-debugview-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [197/285] mirror-to-ms-sysinternals-desktops-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-desktops-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-desktops-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [198/285] mirror-to-ms-sysinternals-findlinks-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-findlinks-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-findlinks-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [199/285] mirror-to-ms-sysinternals-handle-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-handle-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-handle-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [200/285] mirror-to-ms-sysinternals-movefile-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-movefile-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-movefile-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [201/285] mirror-to-ms-sysinternals-pendmoves-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-pendmoves-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-pendmoves-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [202/285] mirror-to-ms-sysinternals-processexplorer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-processexplorer-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-processexplorer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [203/285] mirror-to-ms-sysinternals-processmonitor-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-processmonitor-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-processmonitor-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [204/285] mirror-to-ms-sysinternals-rammap-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-rammap-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-rammap-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [205/285] mirror-to-ms-sysinternals-rdcman-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-rdcman-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-rdcman-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [206/285] mirror-to-ms-sysinternals-regjump-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-regjump-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-regjump-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [207/285] mirror-to-ms-sysinternals-sdelete-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-sdelete-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-sdelete-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [208/285] mirror-to-ms-sysinternals-sigcheck-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-sigcheck-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-sigcheck-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [209/285] mirror-to-ms-sysinternals-strings-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-strings-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-strings-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [210/285] mirror-to-ms-sysinternals-sysmon-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-sysmon-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-sysmon-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [211/285] mirror-to-ms-sysinternals-tcpview-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-tcpview-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-tcpview-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [212/285] mirror-to-ms-sysinternals-vmmap-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-vmmap-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-vmmap-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [213/285] mirror-to-ms-sysinternals-whois-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-whois-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-whois-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [214/285] mirror-to-ms-sysinternals-zoomit-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-sysinternals-zoomit-https" "download.sysinternals.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-sysinternals-zoomit-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [215/285] mirror-to-ms-teammate-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-teammate-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-teammate-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [216/285] mirror-to-ms-teams-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-teams-https" "installer.teams.static.microsoft" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-teams-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [217/285] mirror-to-ms-teamstxndi-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-teamstxndi-https" "teams.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-teamstxndi-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [218/285] mirror-to-ms-timetraveldebugging-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-timetraveldebugging-https" "windbg.download.prss.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-timetraveldebugging-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [219/285] mirror-to-ms-tokenizer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-tokenizer-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-tokenizer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [220/285] mirror-to-ms-ui-xaml-2-7-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-ui-xaml-2-7-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-ui-xaml-2-7-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [221/285] mirror-to-ms-ui-xaml-2-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-ui-xaml-2-8-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-ui-xaml-2-8-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [222/285] mirror-to-ms-updateassistant-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-updateassistant-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-updateassistant-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [223/285] mirror-to-ms-vclibs-14-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vclibs-14-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vclibs-14-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [224/285] mirror-to-ms-vclibs-desktop-14-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vclibs-desktop-14-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vclibs-desktop-14-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [225/285] mirror-to-ms-vcredist-2015+-arm64-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-arm64-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vcredist-2015+-arm64-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [226/285] mirror-to-ms-vcredist-2015+-x64-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-x64-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vcredist-2015+-x64-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [227/285] mirror-to-ms-vcredist-2015+-x86-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-x86-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vcredist-2015+-x86-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [228/285] mirror-to-ms-vsdotnetlogcollect-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vsdotnetlogcollect-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vsdotnetlogcollect-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [229/285] mirror-to-ms-vsixbootstrapper-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vsixbootstrapper-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vsixbootstrapper-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [230/285] mirror-to-ms-vstor-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-vstor-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-vstor-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [231/285] mirror-to-ms-visioviewer-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visioviewer-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visioviewer-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [232/285] mirror-to-ms-visualstudio-2022-buildtools-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-buildtools-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-2022-buildtools-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [233/285] mirror-to-ms-visualstudio-2022-enterprise-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-enterprise-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-2022-enterprise-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [234/285] mirror-to-ms-visualstudio-2022-onecoremsvsmon-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [235/285] mirror-to-ms-visualstudio-2022-professional-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-professional-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-2022-professional-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [236/285] mirror-to-ms-visualstudio-2022-remotetools-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-remotetools-https" "download.visualstudio.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-2022-remotetools-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [237/285] mirror-to-ms-visualstudio-configfinder-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-configfinder-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-configfinder-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [238/285] mirror-to-ms-visualstudio-extensions-typescript-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-extensions-typescript-https" "typescriptteam.gallerycdn.vsassets.io" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-extensions-typescript-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [239/285] mirror-to-ms-visualstudio-locator-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudio-locator-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudio-locator-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [240/285] mirror-to-ms-visualstudiocode-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualstudiocode-https" "vscode.download.prss.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualstudiocode-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [241/285] mirror-to-ms-visualtruetype-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-visualtruetype-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-visualtruetype-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [242/285] mirror-to-ms-wsl-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-wsl-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-wsl-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [243/285] mirror-to-ms-wassette-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-wassette-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-wassette-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [244/285] mirror-to-ms-webdeploy-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-webdeploy-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-webdeploy-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [245/285] mirror-to-ms-win32contentpreptool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-win32contentpreptool-https" "codeload.github.com github.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-win32contentpreptool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [246/285] mirror-to-ms-winappcli-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-winappcli-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-winappcli-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [247/285] mirror-to-ms-windbg-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windbg-https" "windbg.download.prss.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windbg-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [248/285] mirror-to-ms-windowsadk-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsadk-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsadk-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [249/285] mirror-to-ms-windowsadmincenter-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsadmincenter-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsadmincenter-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [250/285] mirror-to-ms-windowsapp-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsapp-https" "res.cdn.office.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsapp-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [251/285] mirror-to-ms-windowsappruntime-1-7-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsappruntime-1-7-https" "aka.ms download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsappruntime-1-7-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [252/285] mirror-to-ms-windowsappruntime-1-8-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsappruntime-1-8-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsappruntime-1-8-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-windowsappruntime-1-8-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-windowsappruntime-1-8-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "download.microsoft.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [253/285] mirror-to-ms-windowsapplicationdriver-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsapplicationdriver-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsapplicationdriver-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [254/285] mirror-to-ms-windowsbusestracing-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsbusestracing-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsbusestracing-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [255/285] mirror-to-ms-windowscloudioprotectiondriver-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowscloudioprotectiondriver-https" "res-1.cdn.office.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowscloudioprotectiondriver-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [256/285] mirror-to-ms-windowsdevicerecoverytool-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsdevicerecoverytool-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsdevicerecoverytool-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [257/285] mirror-to-ms-windowsinstallationassistant-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsinstallationassistant-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsinstallationassistant-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [258/285] mirror-to-ms-windowsmidiservicessdk-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsmidiservicessdk-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsmidiservicessdk-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [259/285] mirror-to-ms-windowspchealthcheck-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowspchealthcheck-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowspchealthcheck-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [260/285] mirror-to-ms-windowssdk-10-0-22621-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-22621-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowssdk-10-0-22621-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [261/285] mirror-to-ms-windowssdk-10-0-26100-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-26100-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowssdk-10-0-26100-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [262/285] mirror-to-ms-windowssdk-10-0-28000-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-28000-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowssdk-10-0-28000-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [263/285] mirror-to-ms-windowsterminal-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsterminal-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsterminal-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [264/285] mirror-to-ms-windowsvirtualdesktopagent-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsvirtualdesktopagent-https" "go.microsoft.com query.prod.cms.rt.microsoft.com res.cdn.office.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsvirtualdesktopagent-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [265/285] mirror-to-ms-windowsvirtualdesktopbootloader-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowsvirtualdesktopbootloader-https" "query.prod.cms.rt.microsoft.com res.cdn.office.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowsvirtualdesktopbootloader-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [266/285] mirror-to-ms-windowswdk-10-0-22621-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowswdk-10-0-22621-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowswdk-10-0-22621-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [267/285] mirror-to-ms-windowswdk-10-0-26100-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-windowswdk-10-0-26100-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-windowswdk-10-0-26100-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [268/285] mirror-to-ms-wingetcreate-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-wingetcreate-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-wingetcreate-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [269/285] mirror-to-ms-xmlnotepad-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-xmlnotepad-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-xmlnotepad-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [270/285] mirror-to-ms-bitsmanager-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-bitsmanager-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-bitsmanager-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [271/285] mirror-to-ms-ebpfforwindows-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-ebpfforwindows-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-ebpfforwindows-https"
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-ebpfforwindows-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "github.com" "objects.githubusercontent.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
  if az network firewall policy rule-collection-group draft collection rule add \
    --policy-name "$POLICY_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --rule-collection-group-name "$RCG_NAME" \
    --collection-name "$RC_NAME" \
    --name "mirror-to-ms-ebpfforwindows-https" \
    --rule-type ApplicationRule \
    --protocols Https=443 \
    --target-fqdns "github.com" "objects.githubusercontent.com" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [272/285] mirror-to-ms-err-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-err-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-err-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [273/285] mirror-to-ms-etl2pcapng-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-etl2pcapng-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-etl2pcapng-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [274/285] mirror-to-ms-msodbcsql-17-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-msodbcsql-17-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-msodbcsql-17-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [275/285] mirror-to-ms-msodbcsql-18-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-msodbcsql-18-https" "download.microsoft.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-msodbcsql-18-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [276/285] mirror-to-ms-quicreach-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-quicreach-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-quicreach-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [277/285] mirror-to-ms-winfile-https ... "
RC=0
rule_exists_and_matches "mirror-to-ms-winfile-https" "github.com objects.githubusercontent.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-ms-winfile-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [278/285] mirror-to-telerik-fiddler-classic-https ... "
RC=0
rule_exists_and_matches "mirror-to-telerik-fiddler-classic-https" "downloads.getfiddler.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-telerik-fiddler-classic-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [279/285] mirror-to-wiresharkfoundation-stratoshark-https ... "
RC=0
rule_exists_and_matches "mirror-to-wiresharkfoundation-stratoshark-https" "1.na.dl.wireshark.org" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wiresharkfoundation-stratoshark-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [280/285] mirror-to-wiresharkfoundation-wireshark-https ... "
RC=0
rule_exists_and_matches "mirror-to-wiresharkfoundation-wireshark-https" "2.na.dl.wireshark.org" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wiresharkfoundation-wireshark-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [281/285] mirror-to-wsl-infra-https ... "
RC=0
rule_exists_and_matches "mirror-to-wsl-infra-https" "cdimages.ubuntu.com wslstorestorage.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wsl-infra-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [282/285] mirror-to-wsl-ubuntu-20-04-https ... "
RC=0
rule_exists_and_matches "mirror-to-wsl-ubuntu-20-04-https" "aka.ms wslstorestorage.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wsl-ubuntu-20-04-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [283/285] mirror-to-wsl-ubuntu-22-04-https ... "
RC=0
rule_exists_and_matches "mirror-to-wsl-ubuntu-22-04-https" "aka.ms wslstorestorage.blob.core.windows.net" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wsl-ubuntu-22-04-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [284/285] mirror-to-wsl-ubuntu-24-04-https ... "
RC=0
rule_exists_and_matches "mirror-to-wsl-ubuntu-24-04-https" "cdimages.ubuntu.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wsl-ubuntu-24-04-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
fi

echo -ne "   [285/285] mirror-to-wsl-ubuntu-26-04-https ... "
RC=0
rule_exists_and_matches "mirror-to-wsl-ubuntu-26-04-https" "cdimages.ubuntu.com" "targetFqdns" || RC=$?
if [ $RC -eq 0 ]; then
  echo -e "${CYAN}⏭️  跳過（已存在且相同）${NC}"
  SKIPPED=$((SKIPPED + 1))
elif [ $RC -eq 2 ]; then
  # 規則存在但內容不同 → 移除後重新新增
  echo -ne "${YELLOW}🔄 更新中...${NC} "
  remove_draft_rule "mirror-to-wsl-ubuntu-26-04-https"
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
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
else
  # 規則不存在 → 新增
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
    echo -e "${GREEN}✅ 新增${NC}"
    CURRENT=$((CURRENT + 1))
  else
    echo -e "${RED}❌${NC}"
    FAILED=$((FAILED + 1))
  fi
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
echo -e "   ✅ 新增:        ${GREEN}$CURRENT${NC}"
echo -e "   🔄 更新:        ${YELLOW}$UPDATED${NC}"
echo -e "   ⏭️  跳過:        $SKIPPED"
if [ $FAILED -gt 0 ]; then
  echo -e "   ❌ 失敗:        ${RED}$FAILED${NC}"
fi
echo "=============================="
echo ""

if [ $FAILED -gt 0 ]; then
  echo -e "${YELLOW}⚠️  有 $FAILED 條規則處理失敗，請檢查錯誤訊息${NC}"
fi

echo -e "${YELLOW}⚠️  規則已寫入 Draft，尚未套用至正式環境${NC}"
echo -e "${YELLOW}   請在 Azure Portal 確認 Draft 內容後，執行以下指令部署：${NC}"
echo ""
echo 'az network firewall policy rule-collection-group draft deploy \'
echo '  --policy-name "'$POLICY_NAME'" \'
echo '  --resource-group "'$RESOURCE_GROUP'" \'
echo '  --rule-collection-group-name "'$RCG_NAME'"'
echo ""
