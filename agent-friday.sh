#!/bin/bash

# Agent Friday - Your Personal Executive Assistant
# Handles daily reports, commitments tracking, and strategic planning

# Configuration
TODAY=$(date +"%Y%m%d")
TOMORROW=$(date -v+1d +"%Y%m%d") 
FRIDAY_LOG="$HOME/.agent-friday-log"
COMMITMENTS_FILE="$HOME/.agent-friday-commitments"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Agent Friday - Your Executive Assistant${NC}"
echo "$(date '+%A, %B %d, %Y at %I:%M %p')"
echo ""

# Function: Morning Report
generate_morning_report() {
    echo -e "${GREEN}📊 MORNING EXECUTIVE BRIEFING${NC}"
    echo "================================"
    
    # Check today's note
    local today_note="${TODAY} JVS Management"
    echo -e "${YELLOW}📝 Today's Focus:${NC}"
    if osascript -e "tell application \"Notes\" to get body of note \"$today_note\"" 2>/dev/null | head -10; then
        echo "✅ Today's JVS Management note ready"
    else
        echo "⚠️  Today's note not found - will be created at midnight"
    fi
    echo ""
    
    # Email check
    echo -e "${YELLOW}📧 Inbox Priority Scan:${NC}"
    himalaya envelope list --page-size 5 | tail -n +4 || echo "Email check unavailable"
    echo ""
    
    # Jira backlog check - Active Projects
    echo -e "${YELLOW}📋 Active Projects Status:${NC}"
    if [[ -x "./jira-multi-project-monitor.sh" ]]; then
        ./jira-multi-project-monitor.sh 2>/dev/null || echo "Multi-project monitoring available"
    else
        echo "Multi-project monitoring ready for setup"
    fi
    echo ""
    
    # Calendar simulation (would integrate with actual calendar)
    echo -e "${YELLOW}📅 Today's Schedule:${NC}"
    echo "• Review scheduled for calendar integration"
    echo "• Use browser automation for Google Calendar if needed"
    echo ""
    
    # Commitments check
    echo -e "${YELLOW}⏰ Active Commitments:${NC}"
    if [[ -f "$COMMITMENTS_FILE" ]]; then
        cat "$COMMITMENTS_FILE" | head -5
    else
        echo "No active commitments tracked"
    fi
    echo ""
    
    echo -e "${PURPLE}🎯 TOP 3 PRIORITIES TODAY:${NC}"
    echo "1. Complete high-point R&D tasks from JVS note"
    echo "2. Process urgent email and communications" 
    echo "3. Advance strategic projects (Tesla/AI/Frequency research)"
    echo ""
}

# Function: End of Day Report  
generate_eod_report() {
    echo -e "${GREEN}📋 END-OF-DAY SHUTDOWN REPORT${NC}"
    echo "====================================="
    
    local today_note="${TODAY} JVS Management"
    echo -e "${YELLOW}✅ Today's Accomplishments:${NC}"
    # This would analyze the completed tasks in today's note
    echo "• Analysis of today's JVS Management note"
    echo "• Points completed vs planned"
    echo "• Major milestones achieved"
    echo ""
    
    echo -e "${YELLOW}⏭️  Tomorrow's Preparation:${NC}"
    echo "• Tomorrow's fresh note will be created at midnight"
    echo "• Today's work will be sent to IRS Gem automatically"  
    echo "• Priority items to carry forward"
    echo ""
    
    echo -e "${YELLOW}🔄 Follow-up Required:${NC}"
    echo "• Pending items needing attention"
    echo "• Waiting for responses"
    echo "• Scheduled follow-ups"
    echo ""
    
    echo -e "${YELLOW}📋 Scrum Teams End-of-Day:${NC}"
    if [[ -x "./jira-multi-project-monitor.sh" ]]; then
        ./jira-multi-project-monitor.sh 2>/dev/null | grep -A 10 "High Priority\|⚠️\|🚨" || echo "No critical issues in active projects"
    else
        echo "Jira monitoring available for team tracking"
    fi
    echo ""
}

# Function: Add Commitment
add_commitment() {
    local commitment="$1"
    local due_date="$2"
    
    if [[ -z "$commitment" ]]; then
        echo "Usage: agent-friday commit \"Task description\" [due_date]"
        return 1
    fi
    
    echo "$(date +%Y%m%d) | ${due_date:-TBD} | $commitment" >> "$COMMITMENTS_FILE"
    echo -e "${GREEN}✅ Commitment added:${NC} $commitment"
}

# Function: List Commitments
list_commitments() {
    echo -e "${BLUE}📋 ACTIVE COMMITMENTS${NC}"
    echo "===================="
    
    if [[ -f "$COMMITMENTS_FILE" ]]; then
        cat "$COMMITMENTS_FILE" | sort
    else
        echo "No commitments tracked yet"
    fi
}

# Function: Weekly Review
generate_weekly_review() {
    echo -e "${GREEN}📊 WEEKLY STRATEGIC REVIEW${NC}"
    echo "============================"
    
    echo -e "${YELLOW}🏆 This Week's Wins:${NC}"
    echo "• Major accomplishments"
    echo "• Points completed"
    echo "• Strategic progress"
    echo ""
    
    echo -e "${YELLOW}📈 Patterns & Optimization:${NC}"
    echo "• Time allocation analysis"
    echo "• Recurring bottlenecks"
    echo "• Process improvements"
    echo ""
    
    echo -e "${YELLOW}🎯 Next Week's Focus:${NC}"
    echo "• Strategic priorities"
    echo "• Resource allocation"
    echo "• Key milestones"
    echo ""
}

# Main command handling
case "${1:-help}" in
    "morning"|"am")
        generate_morning_report
        ;;
    "eod"|"shutdown")
        generate_eod_report
        ;;
    "weekly"|"review")
        generate_weekly_review
        ;;
    "commit"|"add")
        add_commitment "$2" "$3"
        ;;
    "commitments"|"list")
        list_commitments
        ;;
    "jira"|"teams")
        if [[ -x "./jira-multi-project-monitor.sh" ]]; then
            ./jira-multi-project-monitor.sh
        elif [[ -x "./jira-api-monitor.sh" ]]; then
            ./jira-api-monitor.sh
        else
            echo -e "${RED}❌ Jira monitors not found${NC}"
            echo "Expected: ./jira-multi-project-monitor.sh"
        fi
        ;;
    "tyd-sprint"|"tyd"|"sprint")
        if [[ -x "./tyd-sprint-monitor.sh" ]]; then
            ./tyd-sprint-monitor.sh
        else
            echo -e "${RED}❌ TYD sprint monitor not found${NC}"
        fi
        ;;
    "moltbook"|"molt")
        if [[ -x "./moltbook-check.sh" ]]; then
            ./moltbook-check.sh
        else
            echo -e "${RED}❌ Moltbook check script not found${NC}"
        fi
        ;;
    "status")
        echo -e "${BLUE}🤖 Agent Friday Status${NC}"
        echo "========================"
        cron list | grep "Agent Friday" || echo "Cron jobs not accessible"
        echo ""
        echo -e "${GREEN}Active Commands:${NC}"
        echo "  agent-friday morning     # Daily briefing"
        echo "  agent-friday eod         # End-of-day report"
        echo "  agent-friday weekly      # Weekly review"
        echo "  agent-friday commit      # Add commitment"
        echo "  agent-friday list        # Show commitments"
        ;;
    "help"|*)
        echo -e "${BLUE}🤖 Agent Friday Commands${NC}"
        echo "========================="
        echo "  morning/am      Generate morning briefing"
        echo "  eod/shutdown    Generate end-of-day report"  
        echo "  weekly/review   Generate weekly review"
        echo "  commit \"task\"   Add new commitment"
        echo "  commitments     List all commitments"
        echo "  jira/teams      Monitor active projects (FF + TYD)"
        echo "  tyd-sprint      TYY weekly sprint status (~12 items)"
        echo "  moltbook        Check Moltbook social network status 🦞"
        echo "  status          Show Agent Friday status"
        echo ""
        echo -e "${GREEN}Automated Schedule:${NC}"
        echo "  🌅 7:30 AM  - Morning briefing"
        echo "  🌆 5:30 PM  - End-of-day report"
        echo "  📊 Fridays  - Weekly review"
        echo "  🌙 Midnight - JVS note cycle"
        ;;
esac