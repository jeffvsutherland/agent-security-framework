#!/bin/bash

# Update Jira Board - Move Stories to In Progress if Being Worked On
# Scrum Principle: All work must be visible on the board

source ~/.jira-config

echo "🔄 JIRA BOARD UPDATE - Reflecting Actual Work in Progress"
echo "======================================================="
echo "Scrum Principle: Stories moved to In Progress when work starts"
echo ""

# Function to move story to In Progress
move_to_in_progress() {
    local story_key="$1"
    local comment="$2"
    
    echo "Processing $story_key..."
    
    # Add comment about work starting
    if [[ -n "$comment" ]]; then
        COMMENT_JSON="{\"body\": \"🚀 WORK STARTED - Moving to IN PROGRESS\\n\\n$comment\\n\\n**Scrum Board Update**: Story moved to IN PROGRESS to reflect actual work status per Scrum guidelines.\"}"
        curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
          -X POST \
          -H "Content-Type: application/json" \
          -d "$COMMENT_JSON" \
          "$JIRA_URL/rest/api/2/issue/$story_key/comment" >/dev/null
    fi
    
    # Get available transitions
    TRANSITIONS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
      "$JIRA_URL/rest/api/2/issue/$story_key/transitions")
    
    # Look for In Progress transition
    PROGRESS_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("In Progress|In progress"; "i")) | .id' | head -1)
    
    if [[ "$PROGRESS_ID" != "" && "$PROGRESS_ID" != "null" ]]; then
        TRANSITION_DATA='{"transition": {"id": "'$PROGRESS_ID'"}}'
        
        RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
          -X POST \
          -H "Content-Type: application/json" \
          -d "$TRANSITION_DATA" \
          "$JIRA_URL/rest/api/2/issue/$story_key/transitions")
        
        if [[ "${RESPONSE: -3}" == "204" ]]; then
            echo "✅ $story_key → IN PROGRESS"
            return 0
        else
            echo "❌ Failed to move $story_key (HTTP ${RESPONSE: -3})"
            return 1
        fi
    else
        echo "⚠️  No In Progress transition found for $story_key"
        echo "Available transitions:"
        echo "$TRANSITIONS" | jq -r '.transitions[] | "  • " + .name + " (ID: " + .id + ")"'
        return 1
    fi
}

echo "📋 CURRENT TYD STORIES IN TO DO STATUS:"
echo "======================================"

# List current TYD stories in TO DO
TYD_TODO=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jql":"project = TYD AND status = \"To Do\" ORDER BY assignee, updated DESC","maxResults":20,"fields":["summary","status","assignee"]}' \
  "$JIRA_URL/rest/api/3/search/jql")

echo "$TYD_TODO" | jq -r '.issues[] | "• " + .key + ": " + (.fields.summary[0:60] + if (.fields.summary | length) > 60 then "..." else "" end) + " [@" + (if .fields.assignee then .fields.assignee.displayName else "Unassigned" end) + "]"'

echo ""
echo "🎯 WEEKEND WORK ACTIVATION - SCRUM COMPLIANCE"
echo "============================================="
echo ""
echo "Based on JVS Management 7-day work cycle and weekend push requirements,"
echo "the following stories need to be moved to IN PROGRESS if work is starting:"
echo ""

# High priority stories for weekend completion
declare -A WEEKEND_STORIES
WEEKEND_STORIES["TYD-3665"]="JVS Hide Social Media Channels - Quick web update task"
WEEKEND_STORIES["TYD-3677"]="Sprint Efficiency Reports - Analysis work for Sprint data"  
WEEKEND_STORIES["TYD-3676"]="FF GA Monthly Analysis Report - Analytics review"
WEEKEND_STORIES["TYD-3675"]="TYY GA Monthly Analysis Report - Analytics review"
WEEKEND_STORIES["TYD-3674"]="JVS GA Monthly Analysis Report - Analytics review"
WEEKEND_STORIES["TYD-3672"]="Contact Us Email Setup - Implementation work"
WEEKEND_STORIES["TYD-3671"]="Contact Us Thank You Page - Implementation work"
WEEKEND_STORIES["TYD-3670"]="Contact Us Email Copy - Content creation"
WEEKEND_STORIES["TYD-3669"]="Contact Us Thank You Page Copy - Content creation"
WEEKEND_STORIES["TYD-3664"]="Index Manuscript Tool Check - Development review"

echo "📝 TO MOVE STORIES TO IN PROGRESS:"
echo "================================="
echo ""
echo "If work is actively starting on any of these stories, they should be moved:"
echo ""
for story_key in "${!WEEKEND_STORIES[@]}"; do
    echo "$story_key: ${WEEKEND_STORIES[$story_key]}"
done

echo ""
echo "🔧 USAGE:"
echo "========"
echo "To move specific stories to IN PROGRESS, specify them:"
echo ""
echo "Examples:"
echo "  # Move single story"
echo "  move_to_in_progress \"TYD-3665\" \"Starting web updates for social media channel hiding\""
echo ""
echo "  # Move multiple stories with assignee confirmation"
echo "  move_to_in_progress \"TYD-3676\" \"Beginning FF GA monthly analysis - reviewing metrics\""
echo "  move_to_in_progress \"TYD-3675\" \"Beginning TYY GA monthly analysis - reviewing metrics\""
echo ""
echo "⚠️  IMPORTANT: Only move stories where work is ACTUALLY starting"
echo "Scrum Principle: Board must reflect reality - no false progress updates"

# Check for any stories that might already be worked on but not moved
echo ""
echo "🔍 CHECKING FOR RECENT ACTIVITY ON TO DO STORIES:"
echo "==============================================="

# Look for stories with recent comments that might indicate work
RECENT_ACTIVITY=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"jql":"project = TYD AND status = \"To Do\" AND updated >= \"-2h\" ORDER BY updated DESC","maxResults":10,"fields":["summary","status","assignee","updated"]}' \
  "$JIRA_URL/rest/api/3/search/jql")

ACTIVITY_COUNT=$(echo "$RECENT_ACTIVITY" | jq -r '.issues | length')

if [[ "$ACTIVITY_COUNT" -gt 0 ]]; then
    echo "Recent activity detected on these TO DO stories:"
    echo "$RECENT_ACTIVITY" | jq -r '.issues[] | "• " + .key + ": " + (.fields.summary[0:50] + if (.fields.summary | length) > 50 then "..." else "" end) + " (updated: " + .fields.updated + ")"'
    echo ""
    echo "⚠️  These stories have recent activity but remain in TO DO"
    echo "If work is happening, they should be moved to IN PROGRESS"
else
    echo "No recent activity detected on TO DO stories in past 2 hours"
fi

echo ""
echo "📞 ACTION REQUIRED:"
echo "=================="
echo "1. Identify which stories are actually being worked on"
echo "2. Move those stories to IN PROGRESS using move_to_in_progress function"
echo "3. Add comments explaining what work is starting"
echo "4. Ensure board reflects actual work status before next Daily Scrum"
echo ""
echo "🎯 Weekend Sprint Push Goal: Complete maximum stories by Sunday morning"
echo "📋 Scrum Compliance: All work visible on board per Scrum guidelines"