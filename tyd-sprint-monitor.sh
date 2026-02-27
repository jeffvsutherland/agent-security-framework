#!/bin/bash

# TYD Sprint Monitor - Weekly Sprint Focus
# Shows current ~12 sprint items vs full backlog

# Configuration
JIRA_CONFIG="$HOME/.jira-config"
DATE=$(date +"%Y-%m-%d")

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Load configuration
if [[ ! -f "$JIRA_CONFIG" ]]; then
    echo -e "${RED}❌ Jira not configured.${NC}"
    exit 1
fi

source "$JIRA_CONFIG"
AUTH_HEADER="Authorization: Basic $(echo -n "${JIRA_USER}:${JIRA_TOKEN}" | base64)"

# Function to query Jira API
query_jira() {
    local jql="$1"
    local max_results="${2:-50}"
    
    curl -s -X POST \
        -H "$AUTH_HEADER" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "{\"jql\":\"$jql\",\"maxResults\":$max_results,\"fields\":[\"summary\",\"status\",\"priority\",\"assignee\",\"created\",\"updated\"]}" \
        "$JIRA_URL/rest/api/3/search/jql"
}

echo -e "${BLUE}🌱 Tending Your Yard - Weekly Sprint Monitor${NC}"
echo "============================================"
echo -e "${GREEN}📅 Current Sprint Dashboard${NC}"
echo "Generated: $(date)"
echo ""

# Current Sprint Items (most recently updated "To Do" + "In Progress")
echo -e "${YELLOW}🏃 CURRENT SPRINT (~12 items):${NC}"
echo "============================="

current_sprint=$(query_jira "project = TYD AND status in ('To Do', 'In Progress') ORDER BY updated DESC" 15)
sprint_count=$(echo "$current_sprint" | jq -r '.issues | length')

echo "Active Sprint Items: $sprint_count"
echo ""

# Format current sprint items
echo "$current_sprint" | jq -r '.issues[] | 
    "• " + .key + ": " + (.fields.summary[0:65] + if (.fields.summary | length) > 65 then "..." else "" end) +
    " [" + .fields.status.name + "]" +
    (if .fields.assignee then " (@" + .fields.assignee.displayName + ")" else " (Unassigned)" end)'

echo ""

# Recently Completed (last 7 days)
echo -e "${YELLOW}✅ RECENTLY COMPLETED:${NC}"
echo "======================="

completed_recent=$(query_jira "project = TYD AND status = 'Done' AND updated >= '-7d' ORDER BY updated DESC" 10)
completed_count=$(echo "$completed_recent" | jq -r '.issues | length')

echo "Completed this week: $completed_count items"
echo ""

if [[ $completed_count -gt 0 ]]; then
    echo "$completed_recent" | jq -r '.issues[] | 
        "• " + .key + ": " + (.fields.summary[0:65] + if (.fields.summary | length) > 65 then "..." else "" end) +
        " (@" + (if .fields.assignee then .fields.assignee.displayName else "Unassigned" end) + ")"'
else
    echo "No items completed in the last 7 days"
fi

echo ""

# Sprint Team Activity
echo -e "${YELLOW}👥 TEAM ACTIVITY (Current Sprint):${NC}"
echo "=================================="

# Count by assignee in current sprint
echo "$current_sprint" | jq -r '
    [.issues[] | if .fields.assignee then .fields.assignee.displayName else "Unassigned" end] |
    group_by(.) | 
    map({assignee: .[0], count: length}) |
    sort_by(.count) | reverse |
    .[] | "• " + .assignee + ": " + (.count | tostring) + " items"'

echo ""

# Sprint Health Check
echo -e "${YELLOW}📊 SPRINT HEALTH:${NC}"
echo "================="

todo_count=$(echo "$current_sprint" | jq -r '[.issues[] | select(.fields.status.name == "To Do")] | length')
progress_count=$(echo "$current_sprint" | jq -r '[.issues[] | select(.fields.status.name == "In Progress")] | length')

echo "• Sprint Load: $sprint_count total items"
echo "• To Do: $todo_count items"  
echo "• In Progress: $progress_count items"

# Sprint recommendations
if [[ $progress_count -eq 0 ]]; then
    echo -e "${RED}⚠️  No items in progress - sprint may need activation${NC}"
elif [[ $progress_count -gt 5 ]]; then
    echo -e "${YELLOW}⚠️  High WIP ($progress_count items) - consider limiting work in progress${NC}"
else
    echo -e "${GREEN}✅ Good WIP management ($progress_count items in progress)${NC}"
fi

if [[ $sprint_count -gt 15 ]]; then
    echo -e "${YELLOW}📈 Large sprint ($sprint_count items) - typical weekly sprint is ~12${NC}"
elif [[ $sprint_count -lt 8 ]]; then
    echo -e "${BLUE}📉 Light sprint ($sprint_count items) - room for more if needed${NC}"
fi

# Backlog Summary
echo ""
echo -e "${PURPLE}📋 BACKLOG OVERVIEW:${NC}"
echo "===================="

total_backlog=$(query_jira "project = TYD AND status = 'To Do'" 1000)
backlog_total=$(echo "$total_backlog" | jq -r '.issues | length')
total_done=$(query_jira "project = TYD AND status = 'Done'" 1000)
done_total=$(echo "$total_done" | jq -r '.issues | length')

echo "• Total Backlog: $backlog_total items"
echo "• Sprint Ready: $sprint_count items (~$(($sprint_count * 100 / $backlog_total))% of backlog)"
echo "• Total Completed: $done_total items"

echo ""
echo -e "${BLUE}🔄 Last updated: $(date)${NC}"