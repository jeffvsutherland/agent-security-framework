#!/bin/bash

# Mark ASF-12 and ASF-13 as IN PROGRESS since we're actively working on them

# Configuration
JIRA_CONFIG="$HOME/.jira-config"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load configuration
source "$JIRA_CONFIG"

echo -e "${BLUE}🔄 Marking Active Stories as IN PROGRESS${NC}"
echo "========================================"

# Function to transition story
transition_story() {
    local story_key="$1"
    local target_status="$2"
    
    echo -e "${YELLOW}📋 Processing $story_key → $target_status${NC}"
    
    # Get current status
    ISSUE_INFO=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/issue/$story_key" \
        -H "Accept: application/json")
    
    CURRENT_STATUS=$(echo "$ISSUE_INFO" | jq -r '.fields.status.name')
    echo "  Current status: $CURRENT_STATUS"
    
    if [[ "$CURRENT_STATUS" == "$target_status" ]]; then
        echo -e "  ✅ Already in $target_status status"
        return 0
    fi
    
    # Get available transitions
    TRANSITIONS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/issue/$story_key/transitions" \
        -H "Accept: application/json")
    
    echo "  Available transitions:"
    echo "$TRANSITIONS" | jq -r '.transitions[] | "    • " + .name + " (ID: " + .id + ")"'
    
    # Find transition for In Progress
    TRANSITION_ID=""
    if [[ "$target_status" == "In Progress" ]]; then
        TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("In Progress|Start Progress|Start Work")) | .id' | head -1)
    fi
    
    if [[ -n "$TRANSITION_ID" && "$TRANSITION_ID" != "null" ]]; then
        echo "  Using transition ID: $TRANSITION_ID"
        
        TRANSITION_DATA='{"transition": {"id": "'"$TRANSITION_ID"'"}}'
        
        RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
            -X POST \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$TRANSITION_DATA" \
            "$JIRA_URL/rest/api/2/issue/$story_key/transitions")
        
        HTTP_CODE="${RESPONSE: -3}"
        RESPONSE_BODY="${RESPONSE%???}"
        
        if [[ "$HTTP_CODE" == "204" ]]; then
            echo -e "  ✅ Successfully moved to $target_status"
        else
            echo -e "  ❌ Failed to transition (HTTP $HTTP_CODE)"
            echo "  Response: $RESPONSE_BODY"
        fi
    else
        echo -e "  ⚠️  No valid transition found for $target_status"
        echo "  Manual update may be required in Jira UI"
    fi
    
    echo ""
}

# Update the stories we're actively working on
echo "Marking stories currently being worked on as IN PROGRESS:"
echo ""

# ASF-12: Fake Agent Detection (we have working tool, doing documentation)
transition_story "ASF-12" "In Progress"

# ASF-13: Marketing Campaign (we have materials ready, doing outreach)  
transition_story "ASF-13" "In Progress"

echo -e "${GREEN}🎉 Story Status Updates Complete!${NC}"
echo ""
echo -e "${BLUE}📋 Current Active Work:${NC}"
echo "• ASF-12: Completing documentation and demo video"
echo "• ASF-13: Executing social media and stakeholder outreach"
echo ""
echo "🔗 View in Jira: $JIRA_URL/projects/ASF"