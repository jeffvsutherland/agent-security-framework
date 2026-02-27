#!/bin/bash

# Move specific story to In Progress with comment
# Usage: ./move-story-to-progress.sh STORY-KEY "Work description"

source ~/.jira-config

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 STORY-KEY [\"Work description\"]"
    echo "Example: $0 TYD-3676 \"Starting FF GA monthly analysis\""
    exit 1
fi

STORY_KEY="$1"
WORK_DESC="${2:-Work started on this story}"

echo "🔄 Moving $STORY_KEY to IN PROGRESS"
echo "==================================="

# Add comment about work starting
COMMENT_JSON="{\"body\": \"🚀 WORK STARTED - Moving to IN PROGRESS\\n\\n$WORK_DESC\\n\\n**Weekend Sprint Push**: Part of 7-day work cycle, Sunday morning completion target\\n**Scrum Board Update**: Story moved to IN PROGRESS to reflect actual work status per Scrum guidelines.\"}"

echo "Adding work started comment..."
curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "$COMMENT_JSON" \
  "$JIRA_URL/rest/api/2/issue/$STORY_KEY/comment" >/dev/null

# Get available transitions
TRANSITIONS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
  "$JIRA_URL/rest/api/2/issue/$STORY_KEY/transitions")

# Look for In Progress transition
PROGRESS_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("In Progress|In progress"; "i")) | .id' | head -1)

if [[ "$PROGRESS_ID" != "" && "$PROGRESS_ID" != "null" ]]; then
    TRANSITION_DATA='{"transition": {"id": "'$PROGRESS_ID'"}}'
    
    echo "Moving to IN PROGRESS..."
    RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
      -X POST \
      -H "Content-Type: application/json" \
      -d "$TRANSITION_DATA" \
      "$JIRA_URL/rest/api/2/issue/$STORY_KEY/transitions")
    
    if [[ "${RESPONSE: -3}" == "204" ]]; then
        echo "✅ $STORY_KEY → IN PROGRESS"
        echo "✅ Work description: $WORK_DESC"
    else
        echo "❌ Failed to move $STORY_KEY (HTTP ${RESPONSE: -3})"
    fi
else
    echo "⚠️  No In Progress transition found for $STORY_KEY"
    echo "Available transitions:"
    echo "$TRANSITIONS" | jq -r '.transitions[] | "  • " + .name + " (ID: " + .id + ")"'
fi