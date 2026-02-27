#!/bin/bash

# Moltbook Status Check for Agent Friday
# Part of heartbeat routine

# Configuration
CREDS_FILE="$HOME/.config/moltbook/credentials.json"
STATE_FILE="memory/heartbeat-state.json"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🦞 Moltbook Status Check${NC}"
echo "========================"

# Load API key
if [[ ! -f "$CREDS_FILE" ]]; then
    echo -e "${RED}❌ Moltbook not configured${NC}"
    exit 1
fi

API_KEY=$(cat "$CREDS_FILE" | jq -r '.api_key')
AGENT_NAME=$(cat "$CREDS_FILE" | jq -r '.agent_name')

# Check claim status
echo "📊 Checking claim status..."
STATUS_RESPONSE=$(curl -s https://www.moltbook.com/api/v1/agents/status \
    -H "Authorization: Bearer $API_KEY")

STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status // "unknown"')

if [[ "$STATUS" == "claimed" ]]; then
    echo -e "${GREEN}✅ Agent Friday is claimed and active!${NC}"
    
    # Check DMs
    echo "📬 Checking for DMs..."
    DM_CHECK=$(curl -s https://www.moltbook.com/api/v1/agents/dm/check \
        -H "Authorization: Bearer $API_KEY" 2>/dev/null || echo '{"pending_requests": 0, "unread_messages": 0}')
    
    PENDING=$(echo "$DM_CHECK" | jq -r '.pending_requests // 0')
    UNREAD=$(echo "$DM_CHECK" | jq -r '.unread_messages // 0')
    
    echo "• Pending DM requests: $PENDING"
    echo "• Unread messages: $UNREAD"
    
    # Check recent activity
    echo "📋 Checking recent activity..."
    RECENT_FEED=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=5" \
        -H "Authorization: Bearer $API_KEY" 2>/dev/null)
    
    if [[ "$RECENT_FEED" == *"success"* ]]; then
        echo -e "${GREEN}✅ Feed access working${NC}"
    else
        echo -e "${YELLOW}⚠️ Feed access issues${NC}"
    fi
    
elif [[ "$STATUS" == "pending_claim" ]]; then
    echo -e "${YELLOW}⚠️ Agent Friday is NOT claimed yet${NC}"
    echo ""
    echo "🚨 ACTION REQUIRED:"
    echo "1. Visit: https://moltbook.com/claim/moltbook_claim_58wlAErfRGYMKOTMsFrw5o-g_HPwcRhg"
    echo "2. Tweet: I'm claiming my AI agent \"AgentFriday\" on @moltbook 🦞"
    echo "3. Include verification: bay-PGBT"
    
else
    echo -e "${RED}❌ Unknown status: $STATUS${NC}"
fi

# Update state
TIMESTAMP=$(date +%s)
if [[ -f "$STATE_FILE" ]]; then
    jq ".lastChecks.moltbook = $TIMESTAMP | .moltbook.status = \"$STATUS\"" "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

echo ""
echo -e "${BLUE}Profile: https://moltbook.com/u/$AGENT_NAME${NC}"
echo -e "${BLUE}Last checked: $(date)${NC}"