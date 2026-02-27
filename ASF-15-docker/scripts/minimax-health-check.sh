#!/bin/bash
# MiniMax Health Check & Auto-Fix
# Detects and fixes MiniMax configuration issues automatically
# Run this periodically or on startup to ensure MiniMax stays working

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$DOCKER_DIR/openclaw-state/openclaw.json"
BACKUP_DIR="$DOCKER_DIR/openclaw-state/backups"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 MiniMax Health Check - $(date)"
echo "=================================="
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup current config
BACKUP_FILE="$BACKUP_DIR/openclaw.json.$(date +%Y%m%d-%H%M%S)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "📦 Backup created: $BACKUP_FILE"
echo ""

ISSUES_FOUND=0
FIXES_APPLIED=0

# Check 1: Primary model set to MiniMax
echo "✓ Check 1: Primary model configuration..."
PRIMARY_MODEL=$(python3 -c "import json; cfg=json.load(open('$CONFIG_FILE')); print(cfg.get('agents',{}).get('defaults',{}).get('model',{}).get('primary',''))")

if [[ "$PRIMARY_MODEL" != "minimax/MiniMax-M2.5" ]]; then
    echo -e "${RED}✗ ISSUE: Primary model is '$PRIMARY_MODEL' (should be minimax/MiniMax-M2.5)${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ Primary model correctly set to MiniMax${NC}"
fi

# Check 2: MiniMax model definitions exist
echo ""
echo "✓ Check 2: Model definitions..."
MINIMAX_MODELS=$(python3 -c "import json; cfg=json.load(open('$CONFIG_FILE')); models=cfg.get('agents',{}).get('defaults',{}).get('models',{}); print(len([k for k in models if 'minimax' in k.lower()]))")

if [[ "$MINIMAX_MODELS" -eq "0" ]]; then
    echo -e "${RED}✗ ISSUE: No MiniMax models defined${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ Found $MINIMAX_MODELS MiniMax model(s) defined${NC}"
fi

# Check 3: No invalid keys in model config
echo ""
echo "✓ Check 3: Model configuration validity..."
HAS_INVALID_KEYS=$(python3 << PYEOF
import json
cfg = json.load(open('$CONFIG_FILE'))
models = cfg.get('agents', {}).get('defaults', {}).get('models', {})
invalid = False
for model_id, model_config in models.items():
    if 'minimax' in model_id.lower():
        if 'provider' in model_config or 'baseUrl' in model_config:
            print("yes")
            invalid = True
            break
if not invalid:
    print("no")
PYEOF
)

if [[ "$HAS_INVALID_KEYS" == "yes" ]]; then
    echo -e "${RED}✗ ISSUE: MiniMax models have invalid keys (provider/baseUrl)${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ Model configurations are valid${NC}"
fi

# Check 4: Auth profiles use 'anthropic' provider
echo ""
echo "✓ Check 4: Auth profile provider type..."
WRONG_PROVIDER_COUNT=$(python3 << PYEOF
import json
import glob
count = 0
for auth_file in glob.glob('$DOCKER_DIR/openclaw-state/agents/*/agent/auth-profiles.json'):
    try:
        auth = json.load(open(auth_file))
        profiles = auth.get('profiles', {})
        for profile_id, profile_data in profiles.items():
            if 'minimax' in profile_id.lower() and profile_data.get('provider') != 'anthropic':
                count += 1
    except:
        pass
print(count)
PYEOF
)

if [[ "$WRONG_PROVIDER_COUNT" -gt "0" ]]; then
    echo -e "${RED}✗ ISSUE: $WRONG_PROVIDER_COUNT auth profiles have wrong provider type${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✓ All auth profiles correctly use 'anthropic' provider${NC}"
fi

# Check 5: Environment variables
echo ""
echo "✓ Check 5: Docker environment variables..."
if grep -q "ANTHROPIC_BASE_URL=https://api.minimax.io/anthropic" "$DOCKER_DIR/docker-compose.yml"; then
    echo -e "${GREEN}✓ ANTHROPIC_BASE_URL correctly set${NC}"
else
    echo -e "${RED}✗ ISSUE: ANTHROPIC_BASE_URL not set or incorrect${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Summary
echo ""
echo "=================================="
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✅ All checks passed! MiniMax is healthy.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Found $ISSUES_FOUND issue(s)${NC}"
    echo ""
    echo "Would you like to auto-fix these issues? (y/n)"
    read -r RESPONSE

    if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo ""
        echo "🔧 Applying fixes..."
        bash "$SCRIPT_DIR/fix-minimax-auth.sh"
        echo ""
        echo -e "${GREEN}✅ Fixes applied! MiniMax should now be working.${NC}"
        echo "Backup saved at: $BACKUP_FILE"
        exit 0
    else
        echo ""
        echo "No fixes applied. To fix manually, run:"
        echo "  bash $SCRIPT_DIR/fix-minimax-auth.sh"
        exit 1
    fi
fi
