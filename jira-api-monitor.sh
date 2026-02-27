#!/bin/bash

# Jira API Monitor for Agent Friday (REST API v3)
# Modern replacement for deprecated jira CLI

# Configuration
JIRA_CONFIG="$HOME/.jira-config"
JIRA_CACHE="$HOME/.jira-cache"
DATE=$(date +"%Y-%m-%d")

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Load configuration
if [[ ! -f "$JIRA_CONFIG" ]]; then
    echo -e "${RED}❌ Jira not configured. Run jira-monitor setup first.${NC}"
    exit 1
fi

source "$JIRA_CONFIG"

# Create auth header
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

# Function to format issues
format_issues() {
    local response="$1"
    local max_display="${2:-10}"
    
    echo "$response" | jq -r --arg max "$max_display" '
        .issues[0:($max|tonumber)] | .[] | 
        "• " + .key + ": " + .fields.summary + 
        " [" + .fields.status.name + "]" +
        (if .fields.assignee then " (@" + .fields.assignee.displayName + ")" else " (Unassigned)" end)
    '
}

echo -e "${BLUE}📋 Jira API Monitor - Scrum Team Dashboard${NC}"
echo "=============================================="
echo -e "${GREEN}🤖 Agent Friday - Live Jira Integration${NC}"
echo "Generated: $(date)"
echo ""

# Project Overview
echo -e "${YELLOW}📊 Project Overview (FF):${NC}"
echo "=========================="

total_issues=$(get_issue_count "project = FF")
echo "• Total Issues: $total_issues"

todo_count=$(get_issue_count "project = FF AND status = 'To Do'")
progress_count=$(get_issue_count "project = FF AND status = 'In Progress'")
done_count=$(get_issue_count "project = FF AND status = 'Done'")

echo "• To Do: $todo_count"
echo "• In Progress: $progress_count"  
echo "• Done: $done_count"
echo ""

# Recent Activity
if [[ $total_issues -gt 0 ]]; then
    echo -e "${YELLOW}📋 Recent Issues:${NC}"
    echo "=================="
    recent=$(query_jira "project = FF ORDER BY updated DESC" 10)
    format_issues "$recent" 5
    echo ""

    # High Priority Items
    echo -e "${YELLOW}🔥 High Priority Items:${NC}"
    echo "======================="
    high_priority=$(query_jira "project = FF AND priority in (High, Highest) ORDER BY priority DESC" 10)
    high_count=$(echo "$high_priority" | jq -r '.total // 0')
    
    if [[ $high_count -gt 0 ]]; then
        format_issues "$high_priority" 5
    else
        echo "✅ No high priority issues"
    fi
    echo ""

    # In Progress Items
    if [[ $progress_count -gt 0 ]]; then
        echo -e "${YELLOW}🏃 Currently In Progress:${NC}"
        echo "========================="
        in_progress=$(query_jira "project = FF AND status = 'In Progress' ORDER BY updated DESC" 10)
        format_issues "$in_progress" 5
        echo ""
    fi
else
    echo -e "${GREEN}✨ No issues found in FF project - clean slate!${NC}"
    echo ""
fi

# Executive Summary
echo -e "${PURPLE}📋 Executive Summary:${NC}"
echo "===================="
echo "• Project: Frequency Foundation ($total_issues total issues)"
echo "• Active Work: $progress_count items in progress"
echo "• Backlog: $todo_count items ready to start"
echo "• Completed: $done_count items finished"

if [[ $progress_count -eq 0 && $todo_count -eq 0 ]]; then
    echo -e "${GREEN}🎉 Team is caught up! No active work in pipeline.${NC}"
elif [[ $progress_count -gt 5 ]]; then
    echo -e "${YELLOW}⚠️  Heavy workload: $progress_count items in progress${NC}"
fi

echo ""
echo -e "${BLUE}🔄 Last updated: $(date)${NC}"