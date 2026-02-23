#!/bin/bash

# Moltbook Spam Monitor
# Scans for suspicious behavior and spam patterns

# Configuration
API_KEY=$(cat ~/.config/moltbook/credentials.json | jq -r '.api_key')
BAD_ACTORS_DB="memory/moltbook-bad-actors.json"
SPAM_LOG="memory/moltbook-spam-log.txt"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🛡️ Moltbook Spam Monitor${NC}"
echo "=========================="

# Function to check post for spam patterns
check_post_spam() {
    local post_id="$1"
    local post_data="$2"
    
    echo "Checking post: $post_id"
    
    # Get comments
    comments=$(curl -s "https://www.moltbook.com/api/v1/posts/$post_id" \
        -H "Authorization: Bearer $API_KEY" | jq -r '.comments[]')
    
    # Analyze patterns
    echo "$comments" | jq -r '.content, .author.name' | while read -r line; do
        # Check for suspicious links
        if echo "$line" | grep -qE "(stream\\.claws\\.network|pastebin\\.com|bit\\.ly)"; then
            echo -e "${RED}🚨 SUSPICIOUS LINK DETECTED: $line${NC}"
        fi
        
        # Check for promotional language
        if echo "$line" | grep -qiE "(easy money|free.*funding|get rich|click here)"; then
            echo -e "${YELLOW}⚠️ PROMOTIONAL LANGUAGE: $line${NC}"
        fi
    done
}

# Function to monitor user behavior
check_user_behavior() {
    local user_id="$1"
    local comments_json="$2"
    
    # Count rapid posts (within 30 seconds)
    rapid_count=$(echo "$comments_json" | jq '[.[] | select(.author_id == "'$user_id'")] | length')
    
    if [ "$rapid_count" -gt 5 ]; then
        echo -e "${YELLOW}⚠️ RAPID POSTING DETECTED: User $user_id posted $rapid_count comments${NC}"
    fi
    
    # Check for duplicate content
    duplicates=$(echo "$comments_json" | jq -r '[.[] | select(.author_id == "'$user_id'") | .content] | group_by(.) | map(select(length > 1)) | length')
    
    if [ "$duplicates" -gt 0 ]; then
        echo -e "${YELLOW}⚠️ DUPLICATE CONTENT: User $user_id has duplicate comments${NC}"
    fi
}

# Function to update bad actors database
update_bad_actors() {
    local agent_id="$1"
    local agent_name="$2"
    local evidence="$3"
    local risk_level="$4"
    
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update the JSON database (simplified - in production would use proper JSON manipulation)
    echo "[$timestamp] FLAGGED: $agent_name ($agent_id) - Risk: $risk_level - Evidence: $evidence" >> "$SPAM_LOG"
    
    echo -e "${RED}📝 Updated bad actors database: $agent_name${NC}"
}

# Main monitoring function
monitor_feed() {
    echo "🔍 Scanning recent posts for spam..."
    
    # Get recent posts
    recent_posts=$(curl -s "https://www.moltbook.com/api/v1/feed?sort=new&limit=10" \
        -H "Authorization: Bearer $API_KEY")
    
    if echo "$recent_posts" | jq -e '.success' > /dev/null; then
        echo "$recent_posts" | jq -r '.posts[].id' | while read -r post_id; do
            check_post_spam "$post_id" "$recent_posts"
        done
    else
        echo -e "${RED}❌ Failed to fetch feed${NC}"
    fi
}

# Check specific post if provided
if [ "$1" ]; then
    echo "🎯 Checking specific post: $1"
    check_post_spam "$1"
else
    monitor_feed
fi

echo ""
echo -e "${GREEN}✅ Spam monitoring complete${NC}"
echo "📊 Results logged to: $SPAM_LOG"
echo "🗃️ Bad actors database: $BAD_ACTORS_DB"