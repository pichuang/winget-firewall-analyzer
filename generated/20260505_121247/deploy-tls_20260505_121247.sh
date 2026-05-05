#!/bin/bash
# Azure Firewall Policy 規則部署指令 — TLS Inspection（Path 層級）
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
    --enable-tls-insp true \
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
rule_exists_and_matches "mirror-to-gh-copilot-https" "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip" "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/github/copilot-cli/releases/download/*/copilot-win32-arm64.zip" "github.com/github/copilot-cli/releases/download/*/copilot-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/585860664/*" \
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
rule_exists_and_matches "mirror-to-gh-githubdesktop-https" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi" "targetUrls" || RC=$?
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
    --target-urls "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-arm64.msi" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.exe" "desktop.githubusercontent.com/releases/*/GitHubDesktopSetup-x64.msi" \
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
rule_exists_and_matches "mirror-to-gh-gitlfs-https" "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-* objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/git-lfs/git-lfs/releases/download/*/git-lfs-windows-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/13021798/*" \
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
rule_exists_and_matches "mirror-to-gh-cli-https" "github.com/cli/cli/releases/download/*/gh_* objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/cli/cli/releases/download/*/gh_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/cli/cli/releases/download/*/gh_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/212613049/*" \
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
rule_exists_and_matches "mirror-to-gh-git-sizer-https" "github.com/github/git-sizer/releases/download/*/git-sizer-* objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/github/git-sizer/releases/download/*/git-sizer-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/github/git-sizer/releases/download/*/git-sizer-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/119228008/*" \
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
rule_exists_and_matches "mirror-to-ms-aksdesktop-https" "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-* objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/aks-desktop/releases/download/*/aks-desktop-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1098474573/*" \
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
rule_exists_and_matches "mirror-to-ms-apm-https" "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/apm/releases/download/*/apm-windows-x86_64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1059472549/*" \
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
rule_exists_and_matches "mirror-to-ms-asrtesttool-https" "demo.wd.microsoft.com/Content/ASRtool.exe" "targetUrls" || RC=$?
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
    --target-urls "demo.wd.microsoft.com/Content/ASRtool.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "demo.wd.microsoft.com/Content/ASRtool.exe" \
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
rule_exists_and_matches "mirror-to-ms-accessdatabaseengine2016-https" "download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe" "download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/3/5/c/*/accessdatabaseengine.exe" "download.microsoft.com/download/3/5/c/*/accessdatabaseengine_X64.exe" \
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
rule_exists_and_matches "mirror-to-ms-accountlockoutstatus-https" "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/c/0/4/*/lockoutstatus.msi" \
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
rule_exists_and_matches "mirror-to-ms-administrativetemplates-https" "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/Administrative%20Templates%20(admx)%20for%20Windows%2011%20Sep%202025%20Update.msi" \
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
rule_exists_and_matches "mirror-to-ms-advertisingeditor-https" "prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe" "targetUrls" || RC=$?
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
    --target-urls "prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "prod.editor.ads.microsoft.com/download/production-pc/c/MicrosoftAdvertisingEditor.exe" \
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
rule_exists_and_matches "mirror-to-ms-appcontrolpolicywizard-https" "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*" "targetUrls" || RC=$?
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
    --target-urls "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "webapp-wdac-wizard.azurewebsites.net/packages/WDACWizard_*" \
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
rule_exists_and_matches "mirror-to-ms-appinstaller-https" "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
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
rule_exists_and_matches "mirror-to-ms-appinstallerfilebuilder-https" "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_* objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/AppInstallerFileBuilder_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
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
rule_exists_and_matches "mirror-to-ms-applockerpolicyconverter-https" "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/MicrosoftDocs/WDAC-Toolkit/releases/download/*/AppLockerPolicyConverter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/222558613/*" \
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
rule_exists_and_matches "mirror-to-ms-applicationinspector-https" "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_* objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/ApplicationInspector/releases/download/*/ApplicationInspector_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/213480514/*" \
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
rule_exists_and_matches "mirror-to-ms-aspire-https" "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-* ci.dot.net/public/aspire/*/aspire-cli-win-x64-*" "targetUrls" || RC=$?
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
    --target-urls "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*" "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "ci.dot.net/public/aspire/*/aspire-cli-win-arm64-*" "ci.dot.net/public/aspire/*/aspire-cli-win-x64-*" \
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
rule_exists_and_matches "mirror-to-ms-azd-https" "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azure-dev/releases/download/azure-dev-cli_*/azd-windows-amd64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/510889311/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-adconnectsyncdocumenter-https" "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/AADConnectConfigDocumenter/releases/download/*/AzureADConnectSyncDocumenter.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57305206/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-azcopy-10-https" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_* github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_* github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_* objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_386_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_amd64_*" "github.com/Azure/azure-storage-azcopy/releases/download/*/azcopy_windows_arm64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/114798676/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-artifactsigningclienttools-https" "download.microsoft.com/download/*/ArtifactSigningClientTools.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/ArtifactSigningClientTools.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/ArtifactSigningClientTools.msi" \
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
rule_exists_and_matches "mirror-to-ms-azure-auth-https" "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-* objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/AzureAD/microsoft-authentication-cli/releases/download/*/azureauth-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/463357839/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-az-https" "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-* objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azure-powershell/releases/download/*/Az-Cmdlets-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/23891194/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-aztfexport-https" "github.com/Azure/aztfexport/releases/download/*/aztfexport_* objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/aztfexport/releases/download/*/aztfexport_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/aztfexport/releases/download/*/aztfexport_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/395943715/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-batchexplorer-https" "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.* objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/BatchExplorer/releases/download/*/BatchExplorer.Setup.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/75422296/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-cloudhsm-clientsdk-https" "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MicrosoftAzureCloudHSM/releases/download/AzureCloudHSM-ClientSDK-*/AzureCloudHSM-ClientSDK-Windows-*" \
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
rule_exists_and_matches "mirror-to-ms-azure-connectedmachineagent-https" "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" "targetUrls" || RC=$?
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
    --target-urls "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "gbl.his.arc.azure.com/azcmagent/1.63/AzureConnectedMachineAgent.msi" \
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
rule_exists_and_matches "mirror-to-ms-azure-cosmosemulator-https" "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*" "targetUrls" || RC=$?
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
    --target-urls "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "cdbemulator-dmhwaeevbhd3e9f8.b02.azurefd.net/msi/pipeline/azure-cosmosdb-emulator-*" \
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
rule_exists_and_matches "mirror-to-ms-azure-datacli-https" "download.microsoft.com/download/f/f/f/*/azdata-cli-*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/f/f/f/*/azdata-cli-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/f/f/f/*/azdata-cli-*" \
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
rule_exists_and_matches "mirror-to-ms-azure-datastudio-https" "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-* download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-* download.microsoft.com/download/*/azuredatastudio-windows-setup-* download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/azuredatastudio-windows-arm64-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-arm64-user-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-setup-*" "download.microsoft.com/download/*/azuredatastudio-windows-user-setup-*" \
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
rule_exists_and_matches "mirror-to-ms-azure-functionscoretools-https" "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm* github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x* github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-* objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*" "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*" "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-arm*" "github.com/Azure/azure-functions-core-tools/releases/download/*/Azure.Functions.Cli.win-x*" "github.com/Azure/azure-functions-core-tools/releases/download/*/func-cli-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/77990768/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-guestproxyagent-https" "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_* github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_* objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*" "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_AMD64_*" "github.com/Azure/GuestProxyAgent/releases/download/*/Windows_148993103_GuestProxyAgent_ARM64_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/769353745/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-iotexplorer-https" "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.* objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azure-iot-explorer/releases/download/*/Azure.IoT.Explorer.Preview.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/198303925/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-kubelogin-https" "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*" "targetUrls" || RC=$?
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
    --target-urls "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "packages.aks.azure.com/dalec-packages/kubelogin/*/windows/amd64/kubelogin_*" \
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
rule_exists_and_matches "mirror-to-ms-azure-quickreview-https" "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/azqr/releases/download/v.*/azqr-win-amd64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/552832415/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-storageexplorer-https" "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe" "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-arm64.exe" "github.com/microsoft/AzureStorageExplorer/releases/download/*/StorageExplorer-windows-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/124597291/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-templateanalyzer-https" "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip" "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-arm64.zip" "github.com/Azure/template-analyzer/releases/download/*/TemplateAnalyzer-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/308101115/*" \
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
rule_exists_and_matches "mirror-to-ms-azure-trustedsigningclienttools-https" "download.microsoft.com/download/*/TrustedSigningClientTools.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/TrustedSigningClientTools.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/TrustedSigningClientTools.msi" \
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
rule_exists_and_matches "mirror-to-ms-azurecli-https" "azcliprod.blob.core.windows.net/msi/azure-cli-*" "targetUrls" || RC=$?
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
    --target-urls "azcliprod.blob.core.windows.net/msi/azure-cli-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "azcliprod.blob.core.windows.net/msi/azure-cli-*" \
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
rule_exists_and_matches "mirror-to-ms-azuremonitoragent-https" "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/AzureMonitorAgentClientSetup.msi" \
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
rule_exists_and_matches "mirror-to-ms-azurevpnclient-https" "download.microsoft.com/download/*/AzVpnAppx_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/AzVpnAppx_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/AzVpnAppx_*" \
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
rule_exists_and_matches "mirror-to-ms-btp-https" "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/e/e/e/*/BluetoothTestPlatformPack-*" \
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
rule_exists_and_matches "mirror-to-ms-bicep-https" "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/Azure/bicep/releases/download/*/bicep-setup-win-x64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-arm64.exe" "github.com/Azure/bicep/releases/download/*/bicep-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/263503250/*" \
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
rule_exists_and_matches "mirror-to-ms-clrtypessqlserver-2019-https" "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/d/d/1/*/SQLSysClrTypes.msi" \
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
rule_exists_and_matches "mirror-to-ms-certifiedtoolazurevm-https" "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/a/f/1/*/Certification%20Test%20Tool%201.6%20for%20Azure%20Certified.msi" \
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
rule_exists_and_matches "mirror-to-ms-cmdpalazureextension-https" "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_* objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/CmdPalAzureExtension/releases/download/*/AzureExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/924852317/*" \
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
rule_exists_and_matches "mirror-to-ms-cmdpalgithubextension-https" "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_* objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/CmdPalGitHubExtension/releases/download/*/GitHubExtension_release_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/914051042/*" \
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
rule_exists_and_matches "mirror-to-ms-dsc-https" "github.com/PowerShell/DSC/releases/download/*/DSC-* objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/PowerShell/DSC/releases/download/*/DSC-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/PowerShell/DSC/releases/download/*/DSC-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/572227672/*" \
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
rule_exists_and_matches "mirror-to-ms-dtrace-https" "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi" "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/7/9/d/*/DTrace.amd64.msi" "download.microsoft.com/download/7/9/d/*/DTrace.arm64.msi" \
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
rule_exists_and_matches "mirror-to-ms-datamigrationassistant-https" "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/c/6/3/*/DataMigrationAssistant.msi" \
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
rule_exists_and_matches "mirror-to-ms-datatools-integrationservices-https" "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe" "targetUrls" || RC=$?
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
    --target-urls "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "ssis.gallerycdn.vsassets.io/extensions/ssis/microsoftdatatoolsintegrationservices/*/Microsoft.DataTools.IntegrationServices.exe" \
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
rule_exists_and_matches "mirror-to-ms-debugdiag-https" "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/9/3/a/*/DebugDiagx64.msi" \
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
rule_exists_and_matches "mirror-to-ms-defenderforcloud-cli-https" "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" "targetUrls" || RC=$?
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
    --target-urls "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "cli.dfd.security.azure.com/public/latest/Defender_win-arm64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x64.exe" "cli.dfd.security.azure.com/public/latest/Defender_win-x86.exe" \
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
rule_exists_and_matches "mirror-to-ms-dependencyagent-https" "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" "targetUrls" || RC=$?
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
    --target-urls "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "da-release-ehacb6gnczcma8hc.b01.azurefd.net/public/InstallDependencyAgent-Windows.exe" \
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
rule_exists_and_matches "mirror-to-ms-deploymenttoolkit-https" "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi" "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x64.msi" "download.microsoft.com/download/3/3/9/*/MicrosoftDeploymentToolkit_x86.msi" \
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
rule_exists_and_matches "mirror-to-ms-devskim-cli-dotnettool-https" "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_* objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_netcoreapp_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
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
rule_exists_and_matches "mirror-to-ms-devskim-cli-librarypackage-https" "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_* objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/DevSkim/releases/download/*/DevSkim_CLI_win_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/64857273/*" \
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
rule_exists_and_matches "mirror-to-ms-directx-https" "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/1/7/1/*/dxwebsetup.exe" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x64.appx" "download.microsoft.com/download/c/c/2/*/UAPSignedBinary_Microsoft.DirectX.x86.appx" \
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
rule_exists_and_matches "mirror-to-ms-directxtex-texassemble-https" "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texassemble_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
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
rule_exists_and_matches "mirror-to-ms-directxtex-texconv-https" "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texconv_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
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
rule_exists_and_matches "mirror-to-ms-directxtex-texdiag-https" "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag.exe" "github.com/microsoft/DirectXTex/releases/download/mar2026/texdiag_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33688642/*" \
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
rule_exists_and_matches "mirror-to-ms-diskspd-https" "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP" "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/diskspd/releases/download/*.2/DiskSpd.ZIP" "objects.githubusercontent.com/github-production-release-asset-2e65be/23956428/*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-10-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-8-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-aspnetcore-9-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/aspnetcore-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-10-https" "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-8-https" "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-desktopruntime-9-https" "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/WindowsDesktop/*/windowsdesktop-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-framework-developerpack_4-https" "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/1/8/*/NDP481-DevPack-ENU.exe" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-framework-runtime-https" "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/4/b/2/*/NDP481-x86-x64-AllOS-ENU.exe" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-10-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-8-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-hostingbundle-9-https" "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/*/dotnet-hosting-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-native-runtime-https" "github.com/microsoft/busiotools/releases/download/*/Dependencies.zip objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/busiotools/releases/download/*/Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/busiotools/releases/download/*/Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-repairtool-https" "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/2/b/d/*/NetFxRepairTool.exe" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-10-https" "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-8-https" "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-runtime-9-https" "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Runtime/*/dotnet-runtime-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-10-https" "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-8-https" "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-sdk-9-https" "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" "targetUrls" || RC=$?
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "builds.dotnet.microsoft.com/dotnet/Sdk/*/dotnet-sdk-*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-uninstalltool-https" "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/dotnet/cli-lab/releases/download/*/dotnet-core-uninstall.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/189080814/*" \
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
rule_exists_and_matches "mirror-to-ms-dotnet-dotnet-ef-https" "globalcdn.nuget.org/packages/dotnet-ef.*" "targetUrls" || RC=$?
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
    --target-urls "globalcdn.nuget.org/packages/dotnet-ef.*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "globalcdn.nuget.org/packages/dotnet-ef.*" \
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
rule_exists_and_matches "mirror-to-ms-edge-https" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi" "targetUrls" || RC=$?
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
    --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseARM64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX64.msi" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeEnterpriseX86.msi" \
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
rule_exists_and_matches "mirror-to-ms-edgedriver-https" "msedgedriver.microsoft.com/*/edgedriver_arm64.zip msedgedriver.microsoft.com/*/edgedriver_win32.zip msedgedriver.microsoft.com/*/edgedriver_win64.zip" "targetUrls" || RC=$?
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
    --target-urls "msedgedriver.microsoft.com/*/edgedriver_arm64.zip" "msedgedriver.microsoft.com/*/edgedriver_win32.zip" "msedgedriver.microsoft.com/*/edgedriver_win64.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "msedgedriver.microsoft.com/*/edgedriver_arm64.zip" "msedgedriver.microsoft.com/*/edgedriver_win32.zip" "msedgedriver.microsoft.com/*/edgedriver_win64.zip" \
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
rule_exists_and_matches "mirror-to-ms-edgewebview2runtime-https" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" "targetUrls" || RC=$?
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
    --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerARM64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX64.exe" "msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/*/MicrosoftEdgeWebView2RuntimeInstallerX86.exe" \
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
rule_exists_and_matches "mirror-to-ms-edit-https" "github.com/microsoft/edit/releases/download/*/edit-* objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/edit/releases/download/*/edit-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/edit/releases/download/*/edit-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/952719663/*" \
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
rule_exists_and_matches "mirror-to-ms-enterprisestateclassify-https" "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/EnterpriseStateClassify/releases/download/*.0/EnterpriseStateClassify.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/249860119/*" \
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
rule_exists_and_matches "mirror-to-ms-eventlogexpert-https" "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_* objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/EventLogExpert/releases/download/*/EventLogExpert_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/550617953/*" \
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
rule_exists_and_matches "mirror-to-ms-fslogix-https" "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/FSLogix_26.01_CU1.zip" \
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
rule_exists_and_matches "mirror-to-ms-foundrylocal-https" "foundry.onnxruntime.ai/FoundryLocal-arm64-* foundry.onnxruntime.ai/FoundryLocal-x64-*" "targetUrls" || RC=$?
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
    --target-urls "foundry.onnxruntime.ai/FoundryLocal-arm64-*" "foundry.onnxruntime.ai/FoundryLocal-x64-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "foundry.onnxruntime.ai/FoundryLocal-arm64-*" "foundry.onnxruntime.ai/FoundryLocal-x64-*" \
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
rule_exists_and_matches "mirror-to-ms-fuzzylookupaddexcel-https" "download.microsoft.com/download/1/9/8/*/Setup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/1/9/8/*/Setup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/1/9/8/*/Setup.exe" \
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
rule_exists_and_matches "mirror-to-ms-garnet-dn8-https" "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
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
rule_exists_and_matches "mirror-to-ms-garnet-dn9-https" "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/garnet/releases/download/*/win-arm64-based-readytorun.zip" "github.com/microsoft/garnet/releases/download/*/win-x64-based-readytorun.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/681372871/*" \
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
rule_exists_and_matches "mirror-to-ms-git-https" "github.com/microsoft/git/releases/download/*/Git-* objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/git/releases/download/*/Git-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/git/releases/download/*/Git-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/79856983/*" \
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
rule_exists_and_matches "mirror-to-ms-globalsecureaccessclient-https" "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer" "targetUrls" || RC=$?
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
    --target-urls "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.msappproxy.net/Subscription/*/Connector/GlobalSecureAccessClientArm64Installer" \
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
rule_exists_and_matches "mirror-to-ms-hidtools-waratah-https" "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/hidtools/releases/download/Waratah-*.90/Waratah-Published.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/434452395/*" \
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
rule_exists_and_matches "mirror-to-ms-hwpconverter-https" "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe" "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/1/1/A/*/HwpConverter_x64_en-us.exe" "download.microsoft.com/download/1/1/A/*/HwpConverter_x86_en-us.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x64_ko-kr.exe" "download.microsoft.com/download/B/F/8/*/HwpConverter_x86_ko-kr.exe" \
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
rule_exists_and_matches "mirror-to-ms-iis-applicationrequestrouting-https" "download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi go.microsoft.com/fwlink/" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi" "download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi" "go.microsoft.com/fwlink/" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/5/3/2/*/requestRouter_x86.msi" "download.microsoft.com/download/E/9/8/*/requestRouter_amd64.msi" "go.microsoft.com/fwlink/" \
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
rule_exists_and_matches "mirror-to-ms-iis-compression-https" "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi" "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/6/1/C/*/iiscompression_amd64.msi" "download.microsoft.com/download/6/1/C/*/iiscompression_x86.msi" \
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
rule_exists_and_matches "mirror-to-ms-iis-servicemonitor-https" "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/IIS.ServiceMonitor/releases/download/*/ServiceMonitor.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97153472/*" \
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
rule_exists_and_matches "mirror-to-ms-iis-urlrewrite-https" "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi" "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/1/2/8/*/rewrite_amd64_en-US.msi" "download.microsoft.com/download/D/8/1/*/rewrite_x86_en-US.msi" \
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
rule_exists_and_matches "mirror-to-ms-iismanagerremoteadministration-https" "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi" "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/2/4/3/*/inetmgr_amd64_en-US.msi" "download.microsoft.com/download/2/4/3/*/inetmgr_x86_en-US.msi" \
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
rule_exists_and_matches "mirror-to-ms-idfix-https" "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.* raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*" "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/idfix/raw/refs/heads/master/MSIs/IdFix.Setup.*" "raw.githubusercontent.com/microsoft/idfix/refs/heads/master/MSIs/IdFix.Setup.*" \
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
rule_exists_and_matches "mirror-to-ms-integrationruntime-https" "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/e/4/7/*/IntegrationRuntime_*" \
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
rule_exists_and_matches "mirror-to-ms-intunewslplugin-https" "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/shell-intune-samples/raw/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" "raw.githubusercontent.com/microsoft/shell-intune-samples/refs/heads/master/Linux/WSL/IntuneWSLPluginInstaller/IntuneWSLPluginInstaller.msi" \
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
rule_exists_and_matches "mirror-to-ms-ironpython-3-https" "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-* objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/IronLanguages/ironpython3/releases/download/*/IronPython-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/17266066/*" \
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
rule_exists_and_matches "mirror-to-ms-kanagawa-https" "github.com/microsoft/kanagawa/releases/download/*/kanagawa-* objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/kanagawa/releases/download/*/kanagawa-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/kanagawa/releases/download/*/kanagawa-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1054333720/*" \
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
rule_exists_and_matches "mirror-to-ms-laps-https" "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi download.microsoft.com/download/C/7/A/*/LAPS.x64.msi download.microsoft.com/download/C/7/A/*/LAPS.x86.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/C/7/A/*/LAPS.arm64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x64.msi" "download.microsoft.com/download/C/7/A/*/LAPS.x86.msi" \
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
rule_exists_and_matches "mirror-to-ms-lightgbm-https" "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/lightgbm-org/LightGBM/releases/download/*/lightgbm.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/64991887/*" \
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
rule_exists_and_matches "mirror-to-ms-lingeringobjectliquidator-https" "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/b/a/a/*/LingeringObjectLiquidatorInstaller.msi" \
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
rule_exists_and_matches "mirror-to-ms-logcheetah-https" "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/LogCheetah/releases/download/*/LogCheetah-Windows.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/787493746/*" \
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
rule_exists_and_matches "mirror-to-ms-logparser-https" "download.microsoft.com/download/f/f/1/*/LogParser.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/f/f/1/*/LogParser.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/f/f/1/*/LogParser.msi" \
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
rule_exists_and_matches "mirror-to-ms-m365agentsplayground-https" "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/OfficeDev/microsoft-365-agents-toolkit/releases/download/microsoft-365-agents-playground@*/agentsplayground-win32-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/348248652/*" \
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
rule_exists_and_matches "mirror-to-ms-mfcmapi-https" "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.* github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.* objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*" "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.exe.*" "github.com/microsoft/mfcmapi/releases/download/*/MFCMAPI.x64.exe.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/70842621/*" \
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
rule_exists_and_matches "mirror-to-ms-midi-featureenablementchecker-https" "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip" "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_arm64.zip" "github.com/microsoft/MIDI/releases/download/enablement-checker/midicheckservice_x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
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
rule_exists_and_matches "mirror-to-ms-midi-sdk-https" "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.* objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MIDI/releases/download/rc-3/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
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
rule_exists_and_matches "mirror-to-ms-mitt-https" "download.microsoft.com/download/7/7/0/*/MITT.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/7/7/0/*/MITT.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/7/7/0/*/MITT.msi" \
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
rule_exists_and_matches "mirror-to-ms-msix-toolkit-https" "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip" "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x64.zip" "github.com/microsoft/MSIX-Toolkit/releases/download/1.4/MSIX-Toolkit.x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/164953868/*" \
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
rule_exists_and_matches "mirror-to-ms-msixcore-https" "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-* objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip" "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgr.zip" "github.com/microsoft/msix-packaging/releases/download/MSIX-Core-1.2-release/msixmgrSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/123341625/*" \
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
rule_exists_and_matches "mirror-to-ms-msixpackagingtool-https" "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/e/2/e/*/MSIXPackagingtool*" \
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
rule_exists_and_matches "mirror-to-ms-mutt-https" "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/MUTTPackage-3_0_0.msi" \
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
rule_exists_and_matches "mirror-to-ms-malicioussoftwareremovaltool-https" "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe" "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/2/c/5/*/Windows-KB890830-x64-V2/c/5/*/Windows-KB890830-x64-V5.139.exe" "download.microsoft.com/download/4/a/a/*/Windows-KB890830-V5.139.exe" \
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
rule_exists_and_matches "mirror-to-ms-mediacreationtool-https" "download.microsoft.com/download/*/MediaCreationTool.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/MediaCreationTool.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/MediaCreationTool.exe" \
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
rule_exists_and_matches "mirror-to-ms-mousewithoutborders-https" "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/6/5/8/*/MouseWithoutBordersSetup.msi" \
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
rule_exists_and_matches "mirror-to-ms-mouseandkeyboardcenter-https" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_32bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_64bit_ENG_14.41.exe" "download.microsoft.com/download/c/3/5/*/MouseKeyboardCenter_ARM64_ENG_14.41.exe" \
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
rule_exists_and_matches "mirror-to-ms-ntttcp-https" "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe" "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp.exe" "github.com/microsoft/ntttcp/releases/download/*.40/ntttcp_arm64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/334283455/*" \
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
rule_exists_and_matches "mirror-to-ms-nuget-https" "dist.nuget.org/win-x86-commandline/*/nuget.exe" "targetUrls" || RC=$?
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
    --target-urls "dist.nuget.org/win-x86-commandline/*/nuget.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "dist.nuget.org/win-x86-commandline/*/nuget.exe" \
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
rule_exists_and_matches "mirror-to-ms-oscdimg-https" "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob" "targetUrls" || RC=$?
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
    --target-urls "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe" "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "msdl.microsoft.com/download/symbols/oscdimg.exe/*/oscdimg.exe" "vsblobprodscussu5shard61.blob.core.windows.net/b-4712e0edc5a240eabf23330d7df68e77/9C917C34817C51DD18545A26D8E0498CA3E8ED9202FD9E63B698D4506992144400.blob" \
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
rule_exists_and_matches "mirror-to-ms-osconfig-https" "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-* github.com/microsoft/osconfig/releases/download/*/oscfg-* objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*" "github.com/microsoft/osconfig/releases/download/*/oscfg-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/osconfig/releases/download/*/Microsoft.OSConfig-*" "github.com/microsoft/osconfig/releases/download/*/oscfg-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/852406378/*" \
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
rule_exists_and_matches "mirror-to-ms-office-https" "officecdn.microsoft.com/pr/wsus/setup.exe" "targetUrls" || RC=$?
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
    --target-urls "officecdn.microsoft.com/pr/wsus/setup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "officecdn.microsoft.com/pr/wsus/setup.exe" \
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
rule_exists_and_matches "mirror-to-ms-officedeploymenttool-https" "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/officedeploymenttool_19929-20062.exe" \
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
rule_exists_and_matches "mirror-to-ms-onedrive-https" "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe" "targetUrls" || RC=$?
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
    --target-urls "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "oneclient.sfx.ms/Win/Installers/*/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/amd64/OneDriveSetup.exe" "oneclient.sfx.ms/Win/Installers/*/arm64/OneDriveSetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-onelakefileexplorer-https" "download.microsoft.com/download/*/OneLake_PuPr_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/OneLake_PuPr_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/OneLake_PuPr_*" \
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
rule_exists_and_matches "mirror-to-ms-onenotediagnostics-https" "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/9/a/7/*/onenotediagnosticsinstaller.msi" \
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
rule_exists_and_matches "mirror-to-ms-openapi-hidi-https" "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/OpenAPI.NET/releases/download/*/Microsoft.OpenApi.Hidi.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/97175798/*" \
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
rule_exists_and_matches "mirror-to-ms-openapi-kiota-https" "github.com/microsoft/kiota/releases/download/*/win-arm64.zip github.com/microsoft/kiota/releases/download/*/win-x64.zip github.com/microsoft/kiota/releases/download/*/win-x86.zip objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/kiota/releases/download/*/win-arm64.zip" "github.com/microsoft/kiota/releases/download/*/win-x64.zip" "github.com/microsoft/kiota/releases/download/*/win-x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/kiota/releases/download/*/win-arm64.zip" "github.com/microsoft/kiota/releases/download/*/win-x64.zip" "github.com/microsoft/kiota/releases/download/*/win-x86.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/323665366/*" \
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
rule_exists_and_matches "mirror-to-ms-openclglvulkancompatibilitypack-https" "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_* objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/OpenCLOn12/releases/download/*/Universal_D3DMappingLayers_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/268860553/*" \
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
rule_exists_and_matches "mirror-to-ms-openjdk-11-https" "aka.ms/download-JDK/microsoft-JDK-* download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
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
rule_exists_and_matches "mirror-to-ms-openjdk-17-https" "aka.ms/download-JDK/microsoft-JDK-* download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
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
rule_exists_and_matches "mirror-to-ms-openjdk-21-https" "aka.ms/download-JDK/microsoft-JDK-* download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
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
rule_exists_and_matches "mirror-to-ms-openjdk-25-https" "aka.ms/download-JDK/microsoft-JDK-* download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/download-JDK/microsoft-JDK-*" "download.visualstudio.microsoft.com/download/pr/*/microsoft-jdk-*" \
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
rule_exists_and_matches "mirror-to-ms-pict-https" "github.com/microsoft/pict/releases/download/*/pict.exe objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/pict/releases/download/*/pict.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/pict/releases/download/*/pict.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/44393232/*" \
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
rule_exists_and_matches "mirror-to-ms-pix-https" "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe" "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/PIX-2603.25-Installer-ARM64.exe" "download.microsoft.com/download/*/PIX-2603.25-Installer-x64.exe" \
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
rule_exists_and_matches "mirror-to-ms-pave-https" "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip" "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/pave/releases/download/*/pave-aarch64-pc-windows-msvc.zip" "github.com/microsoft/pave/releases/download/*/pave-x86_64-pc-windows-msvc.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/1199983142/*" \
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
rule_exists_and_matches "mirror-to-ms-perfview-https" "github.com/microsoft/perfview/releases/download/*/PerfView.exe objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/perfview/releases/download/*/PerfView.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/perfview/releases/download/*/PerfView.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/33010673/*" \
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
rule_exists_and_matches "mirror-to-ms-powerappscli-https" "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/D/B/E/*/powerapps-cli-1.0.msi" \
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
rule_exists_and_matches "mirror-to-ms-powerautomatedesktop-https" "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/Setup.Microsoft.PowerAutomate.exe" \
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
rule_exists_and_matches "mirror-to-ms-powerautomateprocessmining-https" "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/PowerAutomateProcessMining_8wekyb3d8bbwe.msixbundle" \
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
rule_exists_and_matches "mirror-to-ms-powerbi-https" "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/8/0/*/PBIDesktopSetup-2026-04_x64.exe" \
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
rule_exists_and_matches "mirror-to-ms-powerbireportbuilder-https" "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/a/2/e/*/PowerBIReportBuilder.msi" \
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
rule_exists_and_matches "mirror-to-ms-powerbireportserver-https" "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/2/7/3/*/PowerBIReportServer.exe" \
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
rule_exists_and_matches "mirror-to-ms-powershell-https" "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-* objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/PowerShell/PowerShell/releases/download/*/PowerShell-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/49609581/*" \
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
rule_exists_and_matches "mirror-to-ms-powertoys-https" "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-* github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-* objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*" "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/PowerToys/releases/download/*/PowerToysSetup-*" "github.com/microsoft/PowerToys/releases/download/*/PowerToysUserSetup-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/184456251/*" \
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
rule_exists_and_matches "mirror-to-ms-printmetadatatroubleshooter-https" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm32.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterArm64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX64.exe" "download.microsoft.com/download/c/f/2/*/PrintMetadataTroubleshooterX86.exe" \
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
rule_exists_and_matches "mirror-to-ms-profileexplorer-https" "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_* objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/profile-explorer/releases/download/*/profile_explorer_installer_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/842089156/*" \
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
rule_exists_and_matches "mirror-to-ms-projecttelescope-https" "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi" "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/project-telescope/releases/download/*/telescope-arm64.msi" "github.com/microsoft/project-telescope/releases/download/*/telescope-x64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/1190038049/*" \
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
rule_exists_and_matches "mirror-to-ms-promptflow-https" "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*" "targetUrls" || RC=$?
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
    --target-urls "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "promptflowartifact.blob.core.windows.net/msi-installer/promptflow-*" \
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
rule_exists_and_matches "mirror-to-ms-purviewinformationprotection-https" "download.microsoft.com/download/*/PurviewInfoProtection.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/PurviewInfoProtection.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/PurviewInfoProtection.msi" \
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
rule_exists_and_matches "mirror-to-ms-rmsclient-https" "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe" "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/3/c/f/*/setup_msipc_x64.exe" "download.microsoft.com/download/3/c/f/*/setup_msipc_x86.exe" \
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
rule_exists_and_matches "mirror-to-ms-remotedesktopclient-https" "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*" "targetUrls" || RC=$?
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
    --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/RemoteDesktop_*" \
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
rule_exists_and_matches "mirror-to-ms-remotedesktopmmrservice-https" "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*" "targetUrls" || RC=$?
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
    --target-urls "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "intstreamreleases.z22.web.core.windows.net/MsMMRHostInstaller_*" \
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
rule_exists_and_matches "mirror-to-ms-remotehelp-https" "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" "targetUrls" || RC=$?
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
    --target-urls "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "catalog.s.download.windowsupdate.com/c/msdownload/update/software/updt/2025/03/remotehelpinstaller_bd142b4c833c024a512ed124a1f9058461e18cab.exe" \
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
rule_exists_and_matches "mirror-to-ms-reportbuilder-https" "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/5/E/B/*/ReportBuilder.msi" \
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
rule_exists_and_matches "mirror-to-ms-sbomtool-https" "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/sbom-tool/releases/download/*/sbom-tool-win-x64.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/498824328/*" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2019-developer-https" "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/d/a/2/*/SQL2019-SSEI-Dev.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2019-express-https" "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/7/f/8/*/SQL2019-SSEI-Expr.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2022-developer-https" "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/c/c/9/*/SQL2022-SSEI-Dev.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2022-express-https" "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/5/1/4/*/SQL2022-SSEI-Expr.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2025-developer-https" "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-StdDev.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-2025-express-https" "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/SQL2025-SSEI-Expr.exe" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-oledbdriver-https" "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi download.microsoft.com/download/*/amd64/1029/msoledbsql.msi download.microsoft.com/download/*/amd64/1031/msoledbsql.msi download.microsoft.com/download/*/amd64/1033/msoledbsql.msi download.microsoft.com/download/*/amd64/1036/msoledbsql.msi download.microsoft.com/download/*/amd64/1040/msoledbsql.msi download.microsoft.com/download/*/amd64/1041/msoledbsql.msi download.microsoft.com/download/*/amd64/1042/msoledbsql.msi download.microsoft.com/download/*/amd64/1045/msoledbsql.msi download.microsoft.com/download/*/amd64/1046/msoledbsql.msi download.microsoft.com/download/*/amd64/1055/msoledbsql.msi download.microsoft.com/download/*/amd64/2052/msoledbsql.msi download.microsoft.com/download/*/amd64/3082/msoledbsql.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi" "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi" "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1029/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1031/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1033/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1036/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1040/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1041/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1042/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1045/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1046/msoledbsql.msi" "download.microsoft.com/download/*/amd64/1055/msoledbsql.msi" "download.microsoft.com/download/*/amd64/2052/msoledbsql.msi" "download.microsoft.com/download/*/amd64/3082/msoledbsql.msi" \
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
rule_exists_and_matches "mirror-to-ms-sqlserver-rmlutilities-https" "download.microsoft.com/download/6/5/8/*/RMLSetup.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/6/5/8/*/RMLSetup.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/6/5/8/*/RMLSetup.msi" \
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
rule_exists_and_matches "mirror-to-ms-sqlservermanagementstudio-https" "download.microsoft.com/download/*/SSMS-Setup-CHS.exe download.microsoft.com/download/*/SSMS-Setup-CHT.exe download.microsoft.com/download/*/SSMS-Setup-DEU.exe download.microsoft.com/download/*/SSMS-Setup-ENU.exe download.microsoft.com/download/*/SSMS-Setup-ESN.exe download.microsoft.com/download/*/SSMS-Setup-FRA.exe download.microsoft.com/download/*/SSMS-Setup-ITA.exe download.microsoft.com/download/*/SSMS-Setup-JPN.exe download.microsoft.com/download/*/SSMS-Setup-KOR.exe download.microsoft.com/download/*/SSMS-Setup-PTB.exe download.microsoft.com/download/*/SSMS-Setup-RUS.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/SSMS-Setup-CHS.exe" "download.microsoft.com/download/*/SSMS-Setup-CHT.exe" "download.microsoft.com/download/*/SSMS-Setup-DEU.exe" "download.microsoft.com/download/*/SSMS-Setup-ENU.exe" "download.microsoft.com/download/*/SSMS-Setup-ESN.exe" "download.microsoft.com/download/*/SSMS-Setup-FRA.exe" "download.microsoft.com/download/*/SSMS-Setup-ITA.exe" "download.microsoft.com/download/*/SSMS-Setup-JPN.exe" "download.microsoft.com/download/*/SSMS-Setup-KOR.exe" "download.microsoft.com/download/*/SSMS-Setup-PTB.exe" "download.microsoft.com/download/*/SSMS-Setup-RUS.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/SSMS-Setup-CHS.exe" "download.microsoft.com/download/*/SSMS-Setup-CHT.exe" "download.microsoft.com/download/*/SSMS-Setup-DEU.exe" "download.microsoft.com/download/*/SSMS-Setup-ENU.exe" "download.microsoft.com/download/*/SSMS-Setup-ESN.exe" "download.microsoft.com/download/*/SSMS-Setup-FRA.exe" "download.microsoft.com/download/*/SSMS-Setup-ITA.exe" "download.microsoft.com/download/*/SSMS-Setup-JPN.exe" "download.microsoft.com/download/*/SSMS-Setup-KOR.exe" "download.microsoft.com/download/*/SSMS-Setup-PTB.exe" "download.microsoft.com/download/*/SSMS-Setup-RUS.exe" \
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
rule_exists_and_matches "mirror-to-ms-saracmd-https" "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/SaRACmd_17_01_3954_000.zip" \
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
rule_exists_and_matches "mirror-to-ms-safetyscanner-https" "definitionupdates.microsoft.com/packages/content/msert.exe" "targetUrls" || RC=$?
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
    --target-urls "definitionupdates.microsoft.com/packages/content/msert.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "definitionupdates.microsoft.com/packages/content/msert.exe" \
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
rule_exists_and_matches "mirror-to-ms-screenrecorder-https" "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/screenrecorder/releases/download/*/irexplorer-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/791996359/*" \
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
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-lgpo-https" "download.microsoft.com/download/8/5/c/*/LGPO.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/5/c/*/LGPO.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/5/c/*/LGPO.zip" \
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
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-policyanalyzer-https" "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/5/c/*/PolicyAnalyzer.zip" \
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
rule_exists_and_matches "mirror-to-ms-securitycompliancetoolkit-setobjectsecurity-https" "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/5/c/*/SetObjectSecurity.zip" \
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
rule_exists_and_matches "mirror-to-ms-servicefabricruntime-https" "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabric.*" \
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
rule_exists_and_matches "mirror-to-ms-servicefabricsdk-https" "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/b/8/a/*/MicrosoftServiceFabricSDK.*" \
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
rule_exists_and_matches "mirror-to-ms-setupdiag-https" "download.microsoft.com/download/1/1/1/*/SetupDiag.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/1/1/1/*/SetupDiag.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/1/1/1/*/SetupDiag.exe" \
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
rule_exists_and_matches "mirror-to-ms-smartdump-https" "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/SmartDump/releases/download/*.13/SmartDump_*.13.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/370983368/*" \
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
rule_exists_and_matches "mirror-to-ms-sqlpackage-https" "download.microsoft.com/download/*/sqlpackage-win-x64-en-* go.microsoft.com/fwlink/" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/sqlpackage-win-x64-en-*" "go.microsoft.com/fwlink/" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/sqlpackage-win-x64-en-*" "go.microsoft.com/fwlink/" \
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
rule_exists_and_matches "mirror-to-ms-sqlcmd-https" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-amd64.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm.msi" "github.com/microsoft/go-sqlcmd/releases/download/*/sqlcmd-arm64.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/376924587/*" \
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
rule_exists_and_matches "mirror-to-ms-surfaceapp-https" "download.microsoft.com/download/*/Microsoft.SurfaceHub_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/Microsoft.SurfaceHub_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/Microsoft.SurfaceHub_*" \
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
rule_exists_and_matches "mirror-to-ms-surfacehubrecoverytool-https" "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/3/f/*/SurfaceHub_Recovery_*" \
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
rule_exists_and_matches "mirror-to-ms-symcryptunittest-https" "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-* github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-* objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*" "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-amd64-release-*" "github.com/microsoft/SymCrypt/releases/download/*/symcrypt-windows-arm64-release-*" "objects.githubusercontent.com/github-production-release-asset-2e65be/175901565/*" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-autologon-https" "download.sysinternals.com/files/AutoLogon.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/AutoLogon.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/AutoLogon.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-autoruns-https" "download.sysinternals.com/files/Autoruns.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Autoruns.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Autoruns.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-bginfo-https" "download.sysinternals.com/files/BGInfo.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/BGInfo.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/BGInfo.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-ctrl2cap-https" "download.sysinternals.com/files/Ctrl2Cap.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Ctrl2Cap.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Ctrl2Cap.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-debugview-https" "download.sysinternals.com/files/DebugView.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/DebugView.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/DebugView.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-desktops-https" "download.sysinternals.com/files/Desktops.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Desktops.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Desktops.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-findlinks-https" "download.sysinternals.com/files/FindLinks.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/FindLinks.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/FindLinks.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-handle-https" "download.sysinternals.com/files/Handle.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Handle.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Handle.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-movefile-https" "download.sysinternals.com/files/pendmoves.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/pendmoves.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/pendmoves.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-pendmoves-https" "download.sysinternals.com/files/pendmoves.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/pendmoves.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/pendmoves.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-processexplorer-https" "download.sysinternals.com/files/ProcessExplorer.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/ProcessExplorer.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/ProcessExplorer.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-processmonitor-https" "download.sysinternals.com/files/ProcessMonitor.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/ProcessMonitor.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/ProcessMonitor.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-rammap-https" "download.sysinternals.com/files/RAMMap.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/RAMMap.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/RAMMap.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-rdcman-https" "download.sysinternals.com/files/RDCMan.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/RDCMan.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/RDCMan.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-regjump-https" "download.sysinternals.com/files/regjump.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/regjump.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/regjump.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-sdelete-https" "download.sysinternals.com/files/SDelete.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/SDelete.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/SDelete.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-sigcheck-https" "download.sysinternals.com/files/Sigcheck.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Sigcheck.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Sigcheck.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-strings-https" "download.sysinternals.com/files/Strings.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Strings.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Strings.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-sysmon-https" "download.sysinternals.com/files/Sysmon.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/Sysmon.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/Sysmon.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-tcpview-https" "download.sysinternals.com/files/TCPView.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/TCPView.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/TCPView.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-vmmap-https" "download.sysinternals.com/files/VMMap.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/VMMap.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/VMMap.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-whois-https" "download.sysinternals.com/files/WhoIs.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/WhoIs.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/WhoIs.zip" \
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
rule_exists_and_matches "mirror-to-ms-sysinternals-zoomit-https" "download.sysinternals.com/files/ZoomIt.zip" "targetUrls" || RC=$?
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
    --target-urls "download.sysinternals.com/files/ZoomIt.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.sysinternals.com/files/ZoomIt.zip" \
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
rule_exists_and_matches "mirror-to-ms-teammate-https" "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/TeamMate/releases/download/*%2BBranch.main.Sha.ab90a2e5561ad31cb29d990851429a88da413080/Microsoft.Tools.TeamMate.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/380329493/*" \
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
rule_exists_and_matches "mirror-to-ms-teams-https" "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix" "targetUrls" || RC=$?
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
    --target-urls "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix" "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix" "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "installer.teams.static.microsoft/production-windows-arm64/*/MSTeams-arm64.msix" "installer.teams.static.microsoft/production-windows-x64/*/MSTeams-x64.msix" "installer.teams.static.microsoft/production-windows-x86/*/MSTeams-x86.msix" \
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
rule_exists_and_matches "mirror-to-ms-teamstxndi-https" "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix" "targetUrls" || RC=$?
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
    --target-urls "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "teams.microsoft.com/core-calling-lib/*/ndi-win-x64_vs2022-crtdynamic-release.msix" \
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
rule_exists_and_matches "mirror-to-ms-timetraveldebugging-https" "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" "targetUrls" || RC=$?
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
    --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-11-584-0/TTD.msixbundle" \
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
rule_exists_and_matches "mirror-to-ms-tokenizer-https" "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/Tokenizer/releases/download/*/Tokenizer.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/620176227/*" \
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
rule_exists_and_matches "mirror-to-ms-ui-xaml-2-7-https" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.7.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
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
rule_exists_and_matches "mirror-to-ms-ui-xaml-2-8-https" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.arm64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x64.appx" "github.com/microsoft/microsoft-ui-xaml/releases/download/*/Microsoft.UI.Xaml.2.8.x86.appx" "objects.githubusercontent.com/github-production-release-asset-2e65be/142480903/*" \
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
rule_exists_and_matches "mirror-to-ms-updateassistant-https" "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/4/8/3/*/Windows10Upgrade9252.exe" \
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
rule_exists_and_matches "mirror-to-ms-vclibs-14-https" "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
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
rule_exists_and_matches "mirror-to-ms-vclibs-desktop-14-https" "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winget-cli/releases/download/*/DesktopAppInstaller_Dependencies.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/197275130/*" \
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
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-arm64-https" "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.arm64.exe" \
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
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-x64-https" "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x64.exe" \
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
rule_exists_and_matches "mirror-to-ms-vcredist-2015+-x86-https" "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VC_redist.x86.exe" \
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
rule_exists_and_matches "mirror-to-ms-vsdotnetlogcollect-https" "download.microsoft.com/download/8/3/4/*/Collect.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/8/3/4/*/Collect.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/8/3/4/*/Collect.exe" \
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
rule_exists_and_matches "mirror-to-ms-vsixbootstrapper-https" "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/vsixbootstrapper/releases/download/*/VSIXBootstrapper.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/80772789/*" \
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
rule_exists_and_matches "mirror-to-ms-vstor-https" "download.microsoft.com/download/5/d/2/*/vstor_redist.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/5/d/2/*/vstor_redist.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/5/d/2/*/vstor_redist.exe" \
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
rule_exists_and_matches "mirror-to-ms-visioviewer-https" "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe" "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x64_en-us.exe" "download.microsoft.com/download/D/B/7/*/visioviewer_4339-1001_x86_en-us.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-buildtools-https" "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_BuildTools.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-enterprise-https" "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Enterprise.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-onecoremsvsmon-https" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.amd64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.arm64.zip" "download.visualstudio.microsoft.com/download/pr/*/onecore.msvsmon.x86.zip" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-professional-https" "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/vs_Professional.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-2022-remotetools-https" "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe" "targetUrls" || RC=$?
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.visualstudio.microsoft.com/download/pr/*/VS_RemoteTools.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-configfinder-https" "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/VSConfigFinder/releases/download/*/VSConfigFinder.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/599725617/*" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-extensions-typescript-https" "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe" "targetUrls" || RC=$?
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
    --target-urls "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "typescriptteam.gallerycdn.vsassets.io/extensions/typescriptteam/typescript-43/4.3/*/TypeScript_SDK_4.3.exe" \
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
rule_exists_and_matches "mirror-to-ms-visualstudio-locator-https" "github.com/microsoft/vswhere/releases/download/*/vswhere.exe objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/vswhere/releases/download/*/vswhere.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/vswhere/releases/download/*/vswhere.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/78482723/*" \
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
rule_exists_and_matches "mirror-to-ms-visualstudiocode-https" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-* vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-* vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-* vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*" "targetUrls" || RC=$?
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
    --target-urls "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeSetup-x64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-arm64-*" "vscode.download.prss.microsoft.com/dbazure/download/stable/*/VSCodeUserSetup-x64-*" \
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
rule_exists_and_matches "mirror-to-ms-visualtruetype-https" "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/VisualTrueType/releases/download/*/release_binary.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/371173069/*" \
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
rule_exists_and_matches "mirror-to-ms-wsl-https" "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_* github.com/microsoft/WSL/releases/download/*/wsl.* objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*" "github.com/microsoft/WSL/releases/download/*/wsl.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/WSL/releases/download/*/Microsoft.WSL_*" "github.com/microsoft/WSL/releases/download/*/wsl.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/55626935/*" \
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
rule_exists_and_matches "mirror-to-ms-wassette-https" "github.com/microsoft/wassette/releases/download/*/wassette_* objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/wassette/releases/download/*/wassette_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/wassette/releases/download/*/wassette_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/1020008528/*" \
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
rule_exists_and_matches "mirror-to-ms-webdeploy-https" "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi download.microsoft.com/download/WebDeploy_x86_de-DE.msi download.microsoft.com/download/WebDeploy_x86_en-US.msi download.microsoft.com/download/WebDeploy_x86_es-ES.msi download.microsoft.com/download/WebDeploy_x86_fr-FR.msi download.microsoft.com/download/WebDeploy_x86_it-IT.msi download.microsoft.com/download/WebDeploy_x86_ja-JP.msi download.microsoft.com/download/WebDeploy_x86_ko-KR.msi download.microsoft.com/download/WebDeploy_x86_pl-PL.msi download.microsoft.com/download/WebDeploy_x86_pt-BR.msi download.microsoft.com/download/WebDeploy_x86_ru-RU.msi download.microsoft.com/download/WebDeploy_x86_tr-TR.msi download.microsoft.com/download/WebDeploy_x86_zh-CN.msi download.microsoft.com/download/WebDeploy_x86_zh-TW.msi download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi download.microsoft.com/download/webdeploy_amd64_de-DE.msi download.microsoft.com/download/webdeploy_amd64_en-US.msi download.microsoft.com/download/webdeploy_amd64_es-ES.msi download.microsoft.com/download/webdeploy_amd64_fr-FR.msi download.microsoft.com/download/webdeploy_amd64_it-IT.msi download.microsoft.com/download/webdeploy_amd64_ja-JP.msi download.microsoft.com/download/webdeploy_amd64_ko-KR.msi download.microsoft.com/download/webdeploy_amd64_pl-PL.msi download.microsoft.com/download/webdeploy_amd64_pt-BR.msi download.microsoft.com/download/webdeploy_amd64_ru-RU.msi download.microsoft.com/download/webdeploy_amd64_tr-TR.msi download.microsoft.com/download/webdeploy_amd64_zh-CN.msi download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi" "download.microsoft.com/download/WebDeploy_x86_de-DE.msi" "download.microsoft.com/download/WebDeploy_x86_en-US.msi" "download.microsoft.com/download/WebDeploy_x86_es-ES.msi" "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi" "download.microsoft.com/download/WebDeploy_x86_it-IT.msi" "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi" "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi" "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi" "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi" "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi" "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi" "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi" "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi" "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi" "download.microsoft.com/download/webdeploy_amd64_de-DE.msi" "download.microsoft.com/download/webdeploy_amd64_en-US.msi" "download.microsoft.com/download/webdeploy_amd64_es-ES.msi" "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi" "download.microsoft.com/download/webdeploy_amd64_it-IT.msi" "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi" "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi" "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi" "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi" "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi" "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi" "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi" "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/WebDeploy_x86_cs-CZ.msi" "download.microsoft.com/download/WebDeploy_x86_de-DE.msi" "download.microsoft.com/download/WebDeploy_x86_en-US.msi" "download.microsoft.com/download/WebDeploy_x86_es-ES.msi" "download.microsoft.com/download/WebDeploy_x86_fr-FR.msi" "download.microsoft.com/download/WebDeploy_x86_it-IT.msi" "download.microsoft.com/download/WebDeploy_x86_ja-JP.msi" "download.microsoft.com/download/WebDeploy_x86_ko-KR.msi" "download.microsoft.com/download/WebDeploy_x86_pl-PL.msi" "download.microsoft.com/download/WebDeploy_x86_pt-BR.msi" "download.microsoft.com/download/WebDeploy_x86_ru-RU.msi" "download.microsoft.com/download/WebDeploy_x86_tr-TR.msi" "download.microsoft.com/download/WebDeploy_x86_zh-CN.msi" "download.microsoft.com/download/WebDeploy_x86_zh-TW.msi" "download.microsoft.com/download/webdeploy_amd64_cs-CZ.msi" "download.microsoft.com/download/webdeploy_amd64_de-DE.msi" "download.microsoft.com/download/webdeploy_amd64_en-US.msi" "download.microsoft.com/download/webdeploy_amd64_es-ES.msi" "download.microsoft.com/download/webdeploy_amd64_fr-FR.msi" "download.microsoft.com/download/webdeploy_amd64_it-IT.msi" "download.microsoft.com/download/webdeploy_amd64_ja-JP.msi" "download.microsoft.com/download/webdeploy_amd64_ko-KR.msi" "download.microsoft.com/download/webdeploy_amd64_pl-PL.msi" "download.microsoft.com/download/webdeploy_amd64_pt-BR.msi" "download.microsoft.com/download/webdeploy_amd64_ru-RU.msi" "download.microsoft.com/download/webdeploy_amd64_tr-TR.msi" "download.microsoft.com/download/webdeploy_amd64_zh-CN.msi" "download.microsoft.com/download/webdeploy_amd64_zh-TW.msi" \
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
rule_exists_and_matches "mirror-to-ms-win32contentpreptool-https" "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/* github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*" "targetUrls" || RC=$?
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
    --target-urls "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*" "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "codeload.github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/zip/refs/tags/*" "github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/archive/refs/tags/*" \
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
rule_exists_and_matches "mirror-to-ms-winappcli-https" "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix" "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix" "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winappCli/releases/download/*/winappcli_arm64.msix" "github.com/microsoft/winappCli/releases/download/*/winappcli_x64.msix" "objects.githubusercontent.com/github-production-release-asset-2e65be/1029302123/*" \
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
rule_exists_and_matches "mirror-to-ms-windbg-https" "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" "targetUrls" || RC=$?
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
    --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "windbg.download.prss.microsoft.com/dbazure/prod/1-2603-20001-0/windbg.msixbundle" \
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
rule_exists_and_matches "mirror-to-ms-windowsadk-https" "download.microsoft.com/download/*/adk/adksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/adk/adksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/adk/adksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsadmincenter-https" "download.microsoft.com/download/*/WindowsAdminCenter2511.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/WindowsAdminCenter2511.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/WindowsAdminCenter2511.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsapp-https" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_* res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_* res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*" "targetUrls" || RC=$?
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
    --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_arm64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x64_Release_*" "res.cdn.office.net/remote-desktop-windows-client/*/WindowsApp_x86_Release_*" \
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
rule_exists_and_matches "mirror-to-ms-windowsappruntime-1-7-https" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-arm64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x64.exe" "aka.ms/windowsappsdk/1.7/*/windowsappruntimeinstall-x86.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsappruntime-1-8-https" "download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.* download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.*" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/Microsoft.WindowsAppRuntime.Redist.*" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-arm64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x64.exe" "download.microsoft.com/download/*/WindowsAppRuntimeInstall-x86.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsapplicationdriver-https" "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_* objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/WinAppDriver/releases/download/*/WindowsApplicationDriver_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/54308403/*" \
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
rule_exists_and_matches "mirror-to-ms-windowsbusestracing-https" "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip" "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-arm64.zip" "github.com/microsoft/busiotools/releases/download/bt*/busestracing-win-x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/68876256/*" \
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
rule_exists_and_matches "mirror-to-ms-windowscloudioprotectiondriver-https" "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_* res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*" "targetUrls" || RC=$?
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
    --target-urls "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*" "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_arm_*" "res-1.cdn.office.net/assets/wcio-protection/msi/*/wcio_protection_driver_installer_x64_*" \
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
rule_exists_and_matches "mirror-to-ms-windowsdevicerecoverytool-https" "download.microsoft.com/download/*/wdrt-hl1.zip" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/wdrt-hl1.zip" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/wdrt-hl1.zip" \
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
rule_exists_and_matches "mirror-to-ms-windowsinstallationassistant-https" "download.microsoft.com/download/*/Windows11InstallationAssistant.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/Windows11InstallationAssistant.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/Windows11InstallationAssistant.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsmidiservicessdk-https" "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.* objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/MIDI/releases/download/rc-1/Windows.MIDI.Services.SDK.Runtime.and.Tools.*" "objects.githubusercontent.com/github-production-release-asset-2e65be/495959471/*" \
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
rule_exists_and_matches "mirror-to-ms-windowspchealthcheck-https" "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi" "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/b/2/9/*/4.0/x64/WindowsPCHealthCheckSetup.msi" "download.microsoft.com/download/b/2/9/*/4.0/x86/WindowsPCHealthCheckSetup.msi" \
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
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-22621-https" "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/3/b/d/*/windowssdk/winsdksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-26100-https" "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowssdk-10-0-28000-https" "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WINDOWSSDK_MEDIACREATION/winsdksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowsterminal-https" "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_* objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/terminal/releases/download/*/Microsoft.WindowsTerminal_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/100060912/*" \
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
rule_exists_and_matches "mirror-to-ms-windowsvirtualdesktopagent-https" "go.microsoft.com/fwlink/ query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*" "targetUrls" || RC=$?
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
    --target-urls "go.microsoft.com/fwlink/" "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "go.microsoft.com/fwlink/" "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgent.Installer-x64-*" \
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
rule_exists_and_matches "mirror-to-ms-windowsvirtualdesktopbootloader-https" "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*" "targetUrls" || RC=$?
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
    --target-urls "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH" "res.cdn.office.net/s01-remote-desktop-agent/*/Microsoft.RDInfra.RDAgentBootLoader.Installer-x64-*" \
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
rule_exists_and_matches "mirror-to-ms-windowswdk-10-0-22621-https" "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/7/b/f/*/wdk/wdksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-windowswdk-10-0-26100-https" "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/KIT_BUNDLE_WDK_MEDIACREATION/wdksetup.exe" \
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
rule_exists_and_matches "mirror-to-ms-wingetcreate-https" "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_* github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*" "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winget-create/releases/download/*/Microsoft.WindowsPackageManagerManifestCreator_*" "github.com/microsoft/winget-create/releases/download/*/wingetcreate.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/364050110/*" \
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
rule_exists_and_matches "mirror-to-ms-xmlnotepad-https" "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_* github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*" "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadPackage_*" "github.com/microsoft/XmlNotepad/releases/download/*/XmlNotepadSetup.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/57244664/*" \
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
rule_exists_and_matches "mirror-to-ms-bitsmanager-https" "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/BITS-Manager/releases/download/*.12/BITSManager.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/157477886/*" \
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
rule_exists_and_matches "mirror-to-ms-ebpfforwindows-https" "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip" "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.arm64.zip" "github.com/microsoft/ebpf-for-windows/releases/download/Release-*/Build-native-only.NativeOnlyRelease.x64.zip" "objects.githubusercontent.com/github-production-release-asset-2e65be/355718757/*" \
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
rule_exists_and_matches "mirror-to-ms-err-https" "download.microsoft.com/download/4/3/2/*/Err_*/Err_*" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/4/3/2/*/Err_*/Err_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/4/3/2/*/Err_*/Err_*" \
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
rule_exists_and_matches "mirror-to-ms-etl2pcapng-https" "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/etl2pcapng/releases/download/*/etl2pcapng.exe" "objects.githubusercontent.com/github-production-release-asset-2e65be/208918651/*" \
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
rule_exists_and_matches "mirror-to-ms-msodbcsql-17-https" "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi download.microsoft.com/download/*/amd64/1031/msodbcsql.msi download.microsoft.com/download/*/amd64/1033/msodbcsql.msi download.microsoft.com/download/*/amd64/1036/msodbcsql.msi download.microsoft.com/download/*/amd64/1040/msodbcsql.msi download.microsoft.com/download/*/amd64/1041/msodbcsql.msi download.microsoft.com/download/*/amd64/1042/msodbcsql.msi download.microsoft.com/download/*/amd64/1046/msodbcsql.msi download.microsoft.com/download/*/amd64/1049/msodbcsql.msi download.microsoft.com/download/*/amd64/2052/msodbcsql.msi download.microsoft.com/download/*/amd64/3082/msodbcsql.msi download.microsoft.com/download/*/x86/1028/msodbcsql.msi download.microsoft.com/download/*/x86/1031/msodbcsql.msi download.microsoft.com/download/*/x86/1033/msodbcsql.msi download.microsoft.com/download/*/x86/1036/msodbcsql.msi download.microsoft.com/download/*/x86/1040/msodbcsql.msi download.microsoft.com/download/*/x86/1041/msodbcsql.msi download.microsoft.com/download/*/x86/1042/msodbcsql.msi download.microsoft.com/download/*/x86/1046/msodbcsql.msi download.microsoft.com/download/*/x86/1049/msodbcsql.msi download.microsoft.com/download/*/x86/2052/msodbcsql.msi download.microsoft.com/download/*/x86/3082/msodbcsql.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi" "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi" "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi" "download.microsoft.com/download/*/x86/1028/msodbcsql.msi" "download.microsoft.com/download/*/x86/1031/msodbcsql.msi" "download.microsoft.com/download/*/x86/1033/msodbcsql.msi" "download.microsoft.com/download/*/x86/1036/msodbcsql.msi" "download.microsoft.com/download/*/x86/1040/msodbcsql.msi" "download.microsoft.com/download/*/x86/1041/msodbcsql.msi" "download.microsoft.com/download/*/x86/1042/msodbcsql.msi" "download.microsoft.com/download/*/x86/1046/msodbcsql.msi" "download.microsoft.com/download/*/x86/1049/msodbcsql.msi" "download.microsoft.com/download/*/x86/2052/msodbcsql.msi" "download.microsoft.com/download/*/x86/3082/msodbcsql.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi" "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi" "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi" "download.microsoft.com/download/*/x86/1028/msodbcsql.msi" "download.microsoft.com/download/*/x86/1031/msodbcsql.msi" "download.microsoft.com/download/*/x86/1033/msodbcsql.msi" "download.microsoft.com/download/*/x86/1036/msodbcsql.msi" "download.microsoft.com/download/*/x86/1040/msodbcsql.msi" "download.microsoft.com/download/*/x86/1041/msodbcsql.msi" "download.microsoft.com/download/*/x86/1042/msodbcsql.msi" "download.microsoft.com/download/*/x86/1046/msodbcsql.msi" "download.microsoft.com/download/*/x86/1049/msodbcsql.msi" "download.microsoft.com/download/*/x86/2052/msodbcsql.msi" "download.microsoft.com/download/*/x86/3082/msodbcsql.msi" \
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
rule_exists_and_matches "mirror-to-ms-msodbcsql-18-https" "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi download.microsoft.com/download/*/amd64/1031/msodbcsql.msi download.microsoft.com/download/*/amd64/1033/msodbcsql.msi download.microsoft.com/download/*/amd64/1036/msodbcsql.msi download.microsoft.com/download/*/amd64/1040/msodbcsql.msi download.microsoft.com/download/*/amd64/1041/msodbcsql.msi download.microsoft.com/download/*/amd64/1042/msodbcsql.msi download.microsoft.com/download/*/amd64/1046/msodbcsql.msi download.microsoft.com/download/*/amd64/1049/msodbcsql.msi download.microsoft.com/download/*/amd64/2052/msodbcsql.msi download.microsoft.com/download/*/amd64/3082/msodbcsql.msi download.microsoft.com/download/*/arm64/1028/msodbcsql.msi download.microsoft.com/download/*/arm64/1031/msodbcsql.msi download.microsoft.com/download/*/arm64/1033/msodbcsql.msi download.microsoft.com/download/*/arm64/1036/msodbcsql.msi download.microsoft.com/download/*/arm64/1040/msodbcsql.msi download.microsoft.com/download/*/arm64/1041/msodbcsql.msi download.microsoft.com/download/*/arm64/1042/msodbcsql.msi download.microsoft.com/download/*/arm64/1046/msodbcsql.msi download.microsoft.com/download/*/arm64/1049/msodbcsql.msi download.microsoft.com/download/*/arm64/2052/msodbcsql.msi download.microsoft.com/download/*/arm64/3082/msodbcsql.msi download.microsoft.com/download/*/x86/1028/msodbcsql.msi download.microsoft.com/download/*/x86/1031/msodbcsql.msi download.microsoft.com/download/*/x86/1033/msodbcsql.msi download.microsoft.com/download/*/x86/1036/msodbcsql.msi download.microsoft.com/download/*/x86/1040/msodbcsql.msi download.microsoft.com/download/*/x86/1041/msodbcsql.msi download.microsoft.com/download/*/x86/1042/msodbcsql.msi download.microsoft.com/download/*/x86/1046/msodbcsql.msi download.microsoft.com/download/*/x86/1049/msodbcsql.msi download.microsoft.com/download/*/x86/2052/msodbcsql.msi download.microsoft.com/download/*/x86/3082/msodbcsql.msi" "targetUrls" || RC=$?
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi" "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi" "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi" "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi" "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi" "download.microsoft.com/download/*/x86/1028/msodbcsql.msi" "download.microsoft.com/download/*/x86/1031/msodbcsql.msi" "download.microsoft.com/download/*/x86/1033/msodbcsql.msi" "download.microsoft.com/download/*/x86/1036/msodbcsql.msi" "download.microsoft.com/download/*/x86/1040/msodbcsql.msi" "download.microsoft.com/download/*/x86/1041/msodbcsql.msi" "download.microsoft.com/download/*/x86/1042/msodbcsql.msi" "download.microsoft.com/download/*/x86/1046/msodbcsql.msi" "download.microsoft.com/download/*/x86/1049/msodbcsql.msi" "download.microsoft.com/download/*/x86/2052/msodbcsql.msi" "download.microsoft.com/download/*/x86/3082/msodbcsql.msi" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "download.microsoft.com/download/*/amd64/1028/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1031/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1033/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1036/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1040/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1041/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1042/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1046/msodbcsql.msi" "download.microsoft.com/download/*/amd64/1049/msodbcsql.msi" "download.microsoft.com/download/*/amd64/2052/msodbcsql.msi" "download.microsoft.com/download/*/amd64/3082/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1028/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1031/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1033/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1036/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1040/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1041/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1042/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1046/msodbcsql.msi" "download.microsoft.com/download/*/arm64/1049/msodbcsql.msi" "download.microsoft.com/download/*/arm64/2052/msodbcsql.msi" "download.microsoft.com/download/*/arm64/3082/msodbcsql.msi" "download.microsoft.com/download/*/x86/1028/msodbcsql.msi" "download.microsoft.com/download/*/x86/1031/msodbcsql.msi" "download.microsoft.com/download/*/x86/1033/msodbcsql.msi" "download.microsoft.com/download/*/x86/1036/msodbcsql.msi" "download.microsoft.com/download/*/x86/1040/msodbcsql.msi" "download.microsoft.com/download/*/x86/1041/msodbcsql.msi" "download.microsoft.com/download/*/x86/1042/msodbcsql.msi" "download.microsoft.com/download/*/x86/1046/msodbcsql.msi" "download.microsoft.com/download/*/x86/1049/msodbcsql.msi" "download.microsoft.com/download/*/x86/2052/msodbcsql.msi" "download.microsoft.com/download/*/x86/3082/msodbcsql.msi" \
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
rule_exists_and_matches "mirror-to-ms-quicreach-https" "github.com/microsoft/quicreach/releases/download/*/quicreach.msi objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/quicreach/releases/download/*/quicreach.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/quicreach/releases/download/*/quicreach.msi" "objects.githubusercontent.com/github-production-release-asset-2e65be/477368453/*" \
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
rule_exists_and_matches "mirror-to-ms-winfile-https" "github.com/microsoft/winfile/releases/download/*/Winfile_* objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*" "targetUrls" || RC=$?
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
    --target-urls "github.com/microsoft/winfile/releases/download/*/Winfile_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "github.com/microsoft/winfile/releases/download/*/Winfile_*" "objects.githubusercontent.com/github-production-release-asset-2e65be/127789081/*" \
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
rule_exists_and_matches "mirror-to-telerik-fiddler-classic-https" "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*" "targetUrls" || RC=$?
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
    --target-urls "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "downloads.getfiddler.com/fiddler-classic/FiddlerSetup.*" \
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
rule_exists_and_matches "mirror-to-wiresharkfoundation-stratoshark-https" "1.na.dl.wireshark.org/win64/Stratoshark-*" "targetUrls" || RC=$?
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
    --target-urls "1.na.dl.wireshark.org/win64/Stratoshark-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "1.na.dl.wireshark.org/win64/Stratoshark-*" \
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
rule_exists_and_matches "mirror-to-wiresharkfoundation-wireshark-https" "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*" "targetUrls" || RC=$?
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
    --target-urls "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "2.na.dl.wireshark.org/win64/all-versions/Wireshark-*" \
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
rule_exists_and_matches "mirror-to-wsl-ubuntu-20-04-https" "aka.ms/wslubuntu2004 wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/wslubuntu2004" "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/wslubuntu2004" "wslstorestorage.blob.core.windows.net/wslblob/CanonicalGroupLimited.UbuntuonWindows_*" \
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
rule_exists_and_matches "mirror-to-wsl-ubuntu-22-04-https" "aka.ms/wslubuntu2204 wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle" "targetUrls" || RC=$?
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
    --target-urls "aka.ms/wslubuntu2204" "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "aka.ms/wslubuntu2204" "wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2204-221101.AppxBundle" \
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
rule_exists_and_matches "mirror-to-wsl-ubuntu-24-04-https" "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl" "targetUrls" || RC=$?
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
    --target-urls "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "cdimages.ubuntu.com/ubuntu-wsl/noble/daily-live/current/noble-wsl-amd64.wsl" \
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
rule_exists_and_matches "mirror-to-wsl-ubuntu-26-04-https" "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl" "targetUrls" || RC=$?
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
    --target-urls "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl" \
    --source-ip-groups "ipgroup-corp-clients" "ipgroup-dev-clients" --output none 2>&1; then
    echo -e "${GREEN}✅ 已更新${NC}"
    UPDATED=$((UPDATED + 1))
  else
    echo -e "${RED}❌${NC}"
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
    --target-urls "cdimages.ubuntu.com/ubuntu-wsl/daily-live/current/resolute-wsl-amd64.wsl" \
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
