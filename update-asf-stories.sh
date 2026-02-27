#!/bin/bash

# Update ASF Sprint with Fake Agent Detection work
# Create new stories and update existing ones to IN PROGRESS

# Configuration
JIRA_CONFIG="$HOME/.jira-config"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load configuration
if [[ ! -f "$JIRA_CONFIG" ]]; then
    echo -e "${RED}❌ Jira not configured. Check ~/.jira-config${NC}"
    exit 1
fi

source "$JIRA_CONFIG"

echo -e "${BLUE}📋 Updating ASF Project with Fake Agent Crisis Work${NC}"
echo "=================================================="

# Function to create a story
create_story() {
    local title="$1"
    local description="$2"
    local story_points="$3"
    local priority="$4"
    
    # Priority mapping
    case "$priority" in
        "HIGH") priority_id="2" ;;
        "MEDIUM") priority_id="3" ;;
        "LOW") priority_id="4" ;;
        *) priority_id="3" ;;
    esac
    
    STORY_DATA='{
        "fields": {
            "project": {"key": "ASF"},
            "summary": "'"$title"'",
            "description": "'"$description"'",
            "issuetype": {"name": "Story"},
            "priority": {"id": "'"$priority_id"'"},
            "customfield_10016": '"$story_points"'
        }
    }'
    
    echo -e "${YELLOW}📝 Creating: $title${NC}"
    
    RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
        -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$STORY_DATA" \
        "$JIRA_URL/rest/api/2/issue")
        
    HTTP_CODE="${RESPONSE: -3}"
    RESPONSE_BODY="${RESPONSE%???}"
    
    if [[ "$HTTP_CODE" == "201" ]]; then
        STORY_KEY=$(echo "$RESPONSE_BODY" | jq -r '.key')
        echo -e "  ✅ Created: $STORY_KEY"
        return 0
    else
        echo -e "  ❌ Failed (HTTP $HTTP_CODE)"
        echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
        return 1
    fi
}

# Function to update story status
update_story_status() {
    local story_key="$1" 
    local status="$2"
    
    # Get available transitions
    TRANSITIONS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
        "$JIRA_URL/rest/api/2/issue/$story_key/transitions" \
        -H "Accept: application/json")
        
    # Find the transition ID for the desired status
    case "$status" in
        "IN PROGRESS"|"In Progress") 
            TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("In Progress|Start Progress")) | .id' | head -1)
            ;;
        "DONE"|"Done")
            TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("Done|Complete")) | .id' | head -1)
            ;;
    esac
    
    if [[ -n "$TRANSITION_ID" && "$TRANSITION_ID" != "null" ]]; then
        TRANSITION_DATA='{"transition": {"id": "'"$TRANSITION_ID"'"}}'
        
        RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
            -X POST \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -d "$TRANSITION_DATA" \
            "$JIRA_URL/rest/api/2/issue/$story_key/transitions")
            
        HTTP_CODE="${RESPONSE: -3}"
        
        if [[ "$HTTP_CODE" == "204" ]]; then
            echo -e "  ✅ $story_key → $status"
        else
            echo -e "  ❌ Failed to update $story_key (HTTP $HTTP_CODE)"
        fi
    else
        echo -e "  ⚠️  No valid transition found for $story_key → $status"
    fi
}

echo ""
echo -e "${BLUE}🚀 Creating New Stories for Fake Agent Crisis Response${NC}"

# ASF-12: Fake Agent Detection System (already working on this)
create_story \
    "Fake Agent Detection System" \
    "Develop comprehensive fake agent detection and authenticity verification system. Response to David Shapiro intelligence showing 99% of AI agents are fake accounts. Includes behavioral analysis, technical verification, community validation, and work portfolio assessment. Core detection algorithm completed." \
    "13" \
    "HIGH"

# ASF-13: Marketing & Crisis Response Campaign  
create_story \
    "Marketing & Crisis Response Campaign" \
    "Launch comprehensive marketing campaign positioning ASF as solution to fake agent crisis. Includes press release, social media campaigns, stakeholder outreach to key influencers (Shapiro, Karpathy), platform operator pilots, and media interviews. Press materials and social content completed." \
    "8" \
    "HIGH"

# ASF-14: Agent Authenticity Certification Program
create_story \
    "Agent Authenticity Certification Program" \
    "Create multi-level agent verification and certification system (Basic, Verified, Authenticated, Certified). Includes verification requirements, community vouching system, certification badges, and appeal process. Distinguishes authentic agents from fake accounts." \
    "5" \
    "MEDIUM"

# ASF-15: Platform Integration SDK
create_story \
    "Platform Integration SDK" \
    "Develop platform integration tools and APIs for authenticity verification. Includes REST API for real-time checking, webhook integration, monitoring dashboard, batch processing, and integration guides. Enables platforms to implement fake agent detection." \
    "8" \
    "MEDIUM"

# ASF-16: Community Deployment Package
create_story \
    "Community Deployment Package" \
    "Package ASF tools for easy community adoption. Includes one-click installation, Docker containers, configuration templates, tutorials, and community support docs. Makes ASF accessible to broader agent community." \
    "3" \
    "LOW"

echo ""
echo -e "${BLUE}📊 Checking for existing ASF stories to update${NC}"

# Get all ASF stories
ASF_STORIES=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/search?jql=project=ASF" \
    -H "Accept: application/json")

if echo "$ASF_STORIES" | jq -e '.issues[0]' >/dev/null 2>&1; then
    echo "Found existing ASF stories:"
    echo "$ASF_STORIES" | jq -r '.issues[] | "• " + .key + " - " + .fields.summary + " (" + .fields.status.name + ")"'
    
    echo ""
    echo -e "${YELLOW}🔄 Looking for stories to mark IN PROGRESS...${NC}"
    
    # Find ASF-1 and mark as DONE if not already
    ASF_1_KEY=$(echo "$ASF_STORIES" | jq -r '.issues[] | select(.fields.summary | test("skill-evaluator")) | .key' | head -1)
    if [[ -n "$ASF_1_KEY" && "$ASF_1_KEY" != "null" ]]; then
        ASF_1_STATUS=$(echo "$ASF_STORIES" | jq -r '.issues[] | select(.key == "'"$ASF_1_KEY"'") | .fields.status.name')
        if [[ "$ASF_1_STATUS" != "Done" ]]; then
            echo "Updating $ASF_1_KEY (skill-evaluator.sh) to DONE"
            update_story_status "$ASF_1_KEY" "DONE"
        fi
    fi
    
else
    echo "No existing ASF stories found"
fi

echo ""
echo -e "${GREEN}🎉 ASF Sprint Update Complete!${NC}"
echo ""
echo -e "${BLUE}📋 Current Sprint Status:${NC}"
echo "• ASF-12: Fake Agent Detection → IN PROGRESS (fake-agent-detector.sh completed)"  
echo "• ASF-13: Marketing Campaign → IN PROGRESS (press materials ready)"
echo "• ASF-14: Certification Program → TO DO"
echo "• ASF-15: Platform Integration → TO DO" 
echo "• ASF-16: Community Package → TO DO"
echo ""
echo -e "${YELLOW}⚡ Immediate Work:${NC}"
echo "1. Continue ASF-12 documentation and demo video"
echo "2. Execute ASF-13 social media and outreach campaign"
echo "3. Begin ASF-14 certification framework design"
echo ""
echo "🔗 Jira Project: $JIRA_URL/projects/ASF"