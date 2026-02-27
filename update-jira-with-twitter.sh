#!/bin/bash

# Update ASF-13 with Twitter thread link and move to DONE
# Usage: ./update-jira-with-twitter.sh "twitter_thread_url"

JIRA_CONFIG="$HOME/.jira-config"
TWITTER_URL="$1"

if [[ -z "$TWITTER_URL" ]]; then
    echo "Usage: $0 \"https://twitter.com/username/status/123456789\""
    exit 1
fi

# Load configuration
source "$JIRA_CONFIG"

echo "🐦 Updating ASF-13 with Twitter thread link and marking DONE"
echo "============================================================"

# Update story description with Twitter link
UPDATE_DATA='{
    "fields": {
        "description": "Launch comprehensive marketing campaign positioning ASF as solution to fake agent crisis. COMPLETED: Twitter Thread 1 posted successfully.\n\nTwitter Thread: '$TWITTER_URL'\n\nDeliverables completed:\n- Press release drafted\n- Social media content created\n- Twitter Thread 1 posted\n- Stakeholder outreach plan ready\n- Demo video script prepared"
    }
}'

echo "📝 Adding Twitter link to ASF-13 description..."
UPDATE_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    -X PUT \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$UPDATE_DATA" \
    "$JIRA_URL/rest/api/2/issue/ASF-13")

HTTP_CODE="${UPDATE_RESPONSE: -3}"

if [[ "$HTTP_CODE" == "204" ]]; then
    echo "✅ Twitter link added to ASF-13"
else
    echo "❌ Failed to update description (HTTP $HTTP_CODE)"
fi

# Move to DONE
echo "🎯 Moving ASF-13 to DONE status..."

# Get available transitions
TRANSITIONS=$(curl -s -u "$JIRA_USER:$JIRA_TOKEN" \
    "$JIRA_URL/rest/api/2/issue/ASF-13/transitions" \
    -H "Accept: application/json")

DONE_TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name | test("Done|Complete")) | .id' | head -1)

if [[ -n "$DONE_TRANSITION_ID" && "$DONE_TRANSITION_ID" != "null" ]]; then
    TRANSITION_DATA='{"transition": {"id": "'"$DONE_TRANSITION_ID"'"}}'
    
    TRANSITION_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
        -X POST \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$TRANSITION_DATA" \
        "$JIRA_URL/rest/api/2/issue/ASF-13/transitions")
    
    TRANSITION_HTTP_CODE="${TRANSITION_RESPONSE: -3}"
    
    if [[ "$TRANSITION_HTTP_CODE" == "204" ]]; then
        echo "✅ ASF-13 moved to DONE"
    else
        echo "❌ Failed to move to DONE (HTTP $TRANSITION_HTTP_CODE)"
    fi
else
    echo "⚠️ Could not find DONE transition"
fi

echo ""
echo "🎉 ASF-13 Marketing Campaign - COMPLETE!"
echo "📊 Twitter Thread 1 posted: $TWITTER_URL"
echo "🔗 Jira: $JIRA_URL/browse/ASF-13"