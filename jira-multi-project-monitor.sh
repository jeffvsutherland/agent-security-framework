#!/bin/bash

# Multi-Project Jira Monitor for Agent Friday
# Monitors all your active projects

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
    echo -e "${RED}❌ Jira not configured. Run jira-monitor setup first.${NC}"
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

# Function to get issue count
get_issue_count() {
    local jql="$1"
    local response=$(query_jira "$jql" 1000)
    echo "$response" | jq -r '.issues | length'
}

# Project Status Function
project_status() {
    local project="$1"
    local name="$2"

    echo -e "${YELLOW}📊 $name ($project):${NC}"
    echo "=========================="

    local total=$(get_issue_count "project = $project")
    local todo=$(get_issue_count "project = $project AND status = 'To Do'")
    local progress=$(get_issue_count "project = $project AND status = 'In Progress'")
    local done=$(get_issue_count "project = $project AND status = 'Done'")
    local high_priority=$(get_issue_count "project = $project AND priority in (High, Highest)")

    echo "• Total Issues: $total"
    echo "• To Do: $todo"
    echo "• In Progress: $progress"
    echo "• Done: $done"
    echo "• High Priority: $high_priority"

    # Recent activity for large projects
    if [[ $total -gt 50 ]]; then
        echo ""
        echo -e "${CYAN}📋 Recent Issues (last 5):${NC}"
        local recent=$(query_jira "project = $project ORDER BY updated DESC" 5)
        echo "$recent" | jq -r '.issues[] |
            "• " + .key + ": " + .fields.summary[0:60] +
            (if (.fields.summary | length) > 60 then "..." else "" end) +
            " [" + .fields.status.name + "]" +
            (if .fields.assignee then " (@" + .fields.assignee.displayName + ")" else " (Unassigned)" end)'

        if [[ $high_priority -gt 0 ]]; then
            echo ""
            echo -e "${RED}🔥 High Priority Items:${NC}"
            local high_pri=$(query_jira "project = $project AND priority in (High, Highest) ORDER BY priority DESC" 5)
            echo "$high_pri" | jq -r '.issues[] |
                "• " + .key + ": " + .fields.summary[0:60] +
                (if (.fields.summary | length) > 60 then "..." else "" end) +
                " [" + .fields.priority.name + "]"'
        fi
    fi

    echo ""
}

echo -e "${BLUE}📋 Active Projects Monitor - FF + TYD Dashboard${NC}"
echo "=============================================="
echo -e "${GREEN}🤖 Agent Friday - Active Teams Overview${NC}"
echo "Generated: $(date)"
echo ""

# Active Projects Only (FF + TYD)
project_status "FF" "Frequency Foundation"

# TYD - Sprint Focused View
echo -e "${YELLOW}📊 Tending Your Yard - Current Sprint (TYD):${NC}"
echo "=========================="

tyd_sprint=$(query_jira "project = TYD AND status in ('To Do', 'In Progress') ORDER BY updated DESC" 15)
tyd_sprint_count=$(echo "$tyd_sprint" | jq -r '.issues | length')
tyd_todo_count=$(echo "$tyd_sprint" | jq -r '[.issues[] | select(.fields.status.name == "To Do")] | length')
tyd_progress_count=$(echo "$tyd_sprint" | jq -r '[.issues[] | select(.fields.status.name == "In Progress")] | length')
tyd_backlog_total=$(get_issue_count "project = TYD AND status = 'To Do'")
tyd_completed_week=$(get_issue_count "project = TYD AND status = 'Done' AND updated >= '-7d'")

echo "• Current Sprint: $tyd_sprint_count items (typical: ~12)"
echo "• Sprint To Do: $tyd_todo_count"
echo "• Sprint In Progress: $tyd_progress_count"
echo "• Total Backlog: $tyd_backlog_total items"
echo "• Completed This Week: $tyd_completed_week items"

if [[ $tyd_progress_count -eq 0 ]]; then
    echo -e "${RED}  ⚠️  Sprint needs activation (no items in progress)${NC}"
elif [[ $tyd_sprint_count -gt 15 ]]; then
    echo -e "${YELLOW}  📈 Large sprint ($tyd_sprint_count items)${NC}"
fi

echo ""
echo -e "${CYAN}📋 Current Sprint Items:${NC}"
echo "$tyd_sprint" | jq -r '.issues[0:8] | .[] |
    "• " + .key + ": " + (.fields.summary[0:50] + if (.fields.summary | length) > 50 then "..." else "" end) +
    " [" + .fields.status.name + "]" +
    (if .fields.assignee then " (@" + .fields.assignee.displayName + ")" else " (Unassigned)" end)'

if [[ $tyd_sprint_count -gt 8 ]]; then
    echo "• ... and $((tyd_sprint_count - 8)) more sprint items"
fi

echo ""

# Executive Summary - Active Projects Only
echo -e "${PURPLE}📋 Executive Summary:${NC}"
echo "===================="

ff_total=$(get_issue_count "project = FF")
tyd_total=$(get_issue_count "project = TYD")

total_all=$((ff_total + tyd_total))
progress_all=$(($(get_issue_count "project in (FF, TYD) AND status = 'In Progress'")))
high_all=$(($(get_issue_count "project in (FF, TYD) AND priority in (High, Highest)")))

echo "• Total Issues Across Active Projects: $total_all"
echo "• Active Work (In Progress): $progress_all"
echo "• High Priority Items: $high_all"
echo ""
echo "• 🏥 Frequency Foundation: $ff_total issues (treatments/research)"
echo "• 🌱 Tending Your Yard: $tyd_total issues (content/publishing)"  

if [[ $progress_all -gt 5 ]]; then
    echo ""
    echo -e "${YELLOW}⚠️  High workload: $progress_all items actively in progress${NC}"
fi

if [[ $high_all -gt 0 ]]; then
    echo ""
    echo -e "${RED}🚨 $high_all high-priority items need attention${NC}"
fi

echo ""
echo -e "${BLUE}🔄 Last updated: $(date)${NC}"