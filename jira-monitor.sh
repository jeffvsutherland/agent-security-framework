#!/bin/bash

# Jira Monitor for Agent Friday
# Monitors Scrum team backlogs and sprint progress

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

echo -e "${BLUE}📋 Jira Monitor - Scrum Team Backlog Watch${NC}"
echo "=============================================="

# Check if Jira is configured
if [[ ! -f "$JIRA_CONFIG" ]]; then
    echo -e "${YELLOW}⚙️  Jira not configured yet. Setting up...${NC}"
    echo ""
    echo "Please provide your Jira details:"
    read -p "Jira URL (e.g., https://company.atlassian.net): " jira_url
    read -p "Username/Email: " jira_user
    read -sp "API Token: " jira_token
    echo ""
    
    # Save configuration
    cat > "$JIRA_CONFIG" << EOF
# Jira Configuration for Agent Friday
JIRA_URL="$jira_url"
JIRA_USER="$jira_user"
JIRA_TOKEN="$jira_token"
CREATED_DATE="$(date)"
EOF
    
    chmod 600 "$JIRA_CONFIG"
    echo -e "${GREEN}✅ Jira configuration saved${NC}"
    echo ""
fi

# Load configuration
source "$JIRA_CONFIG"

# Configure jira CLI with proper authentication
export JIRA_API_TOKEN="$JIRA_TOKEN"
# For go-jira, we need to use different approach - create a temporary config or use command flags

# Function: Get Active Sprints
get_active_sprints() {
    echo -e "${YELLOW}🏃 Active Sprints:${NC}"
    echo "==================="
    
    # Query for active sprints in FF project
    echo "Querying active sprints..."
    if command -v jira >/dev/null 2>&1; then
        echo "Using basic query for FF project issues"
        jira ls -e "$JIRA_URL" -u "$JIRA_USER" --query="project = FF" --template=table 2>/dev/null | head -10 || {
            echo "⚠️  Connection issue or no issues found in FF project"
            echo "Verify Jira configuration and project access"
        }
    else
        echo "⚠️  Jira CLI not available"
    fi
    echo ""
}

# Function: Get Backlog Summary
get_backlog_summary() {
    echo -e "${YELLOW}📋 Backlog Summary:${NC}"
    echo "==================="
    
    # Count issues by status
    echo "Analyzing backlog items..."
    
    # Query FF project for backlog status
    local todo_count=$(jira ls --query="project = FF AND status = 'To Do'" --template="{{len .}}" 2>/dev/null || echo "0")
    local inprogress_count=$(jira ls --query="project = FF AND status = 'In Progress'" --template="{{len .}}" 2>/dev/null || echo "0")
    local done_count=$(jira ls --query="project = FF AND status = 'Done' AND updated >= -7d" --template="{{len .}}" 2>/dev/null || echo "0")
    
    echo -e "${BLUE}📊 Status Overview:${NC}"
    echo "• To Do: $todo_count items"
    echo "• In Progress: $inprogress_count items"  
    echo "• Completed (7 days): $done_count items"
    echo ""
}

# Function: Get Team Velocity
get_team_velocity() {
    echo -e "${YELLOW}📈 Team Velocity:${NC}"
    echo "=================="
    
    echo "• Recent sprint completion rates"
    echo "• Story point burn-down trends"
    echo "• Impediment tracking"
    echo "• Team capacity utilization"
    echo ""
}

# Function: Get Critical Issues
get_critical_issues() {
    echo -e "${YELLOW}🚨 Critical & Blocked Issues:${NC}"
    echo "=============================="
    
    # High priority and blocked items in FF project
    jira ls --query="project = FF AND priority in (Highest, High) AND status != Done" --template=table 2>/dev/null || {
        echo "⚠️  No critical issues found in FF project or connection issue"
    }
    echo ""
}

# Function: Setup Projects
setup_projects() {
    echo -e "${BLUE}🔧 Project Setup${NC}"
    echo "================="
    
    echo "Available projects:"
    jira ls-projects 2>/dev/null || echo "Failed to fetch projects"
    echo ""
    
    echo "Please edit $0 and replace 'YOUR_PROJECT' with your actual project key(s)"
    echo "Example: project in (SCRUM, DEV, PROD)"
    echo ""
}

# Function: Agent Friday Integration Report
generate_agent_friday_report() {
    echo -e "${GREEN}🤖 Agent Friday - Scrum Teams Report${NC}"
    echo "===================================="
    echo "Generated: $(date)"
    echo ""
    
    get_active_sprints
    get_backlog_summary  
    get_critical_issues
    get_team_velocity
    
    echo -e "${PURPLE}📋 Summary for JVS Management:${NC}"
    echo "• Active sprint progress: Review in-progress items"
    echo "• Backlog health: Monitor story point estimates"
    echo "• Team velocity: Track delivery consistency" 
    echo "• Critical issues: Address blockers immediately"
    echo ""
}

# Function: Cache Update
update_cache() {
    echo "Updating Jira cache..."
    {
        echo "# Jira Cache - $(date)"
        echo "# Last updated: $(date +%s)"
        generate_agent_friday_report
    } > "$JIRA_CACHE"
    echo -e "${GREEN}✅ Cache updated${NC}"
}

# Main command handling
case "${1:-report}" in
    "setup")
        rm -f "$JIRA_CONFIG"
        echo "Configuration cleared. Re-run to setup fresh."
        ;;
    "setup-projects") 
        setup_projects
        ;;
    "sprints"|"sprint")
        get_active_sprints
        ;;
    "backlog")
        get_backlog_summary
        ;;
    "critical")
        get_critical_issues
        ;;
    "velocity")
        get_team_velocity
        ;;
    "cache")
        update_cache
        ;;
    "report"|*)
        generate_agent_friday_report
        ;;
esac