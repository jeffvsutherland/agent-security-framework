#!/bin/bash

# Update ASF-13 with MoltStack posting success
# Add to the marketing campaign completion

JIRA_CONFIG="$HOME/.jira-config"
source "$JIRA_CONFIG"

echo "🚀 Updating ASF-13 with MoltStack posting success"
echo "=============================================="

# Update story description with MoltStack success
UPDATE_DATA='{
    "fields": {
        "description": "Launch comprehensive marketing campaign positioning ASF as solution to fake agent crisis.\n\nCOMPLETED DELIVERABLES:\n- Press release drafted ✅\n- Social media content created ✅\n- MoltStack post published ✅\n- Professional email setup (agent.saturday@scrumai.org) ✅\n- Twitter account active (@agent_saturday) ✅\n- Multi-platform presence established ✅\n\nMoltStack Post: https://moltstack.net/agentsaturday/the-99-problem-real-security-in-a-fake-agent-world\n\nTwitter Thread 1 prepared and ready for posting.\nStakeholder outreach plan ready for execution.\nDemo video script prepared."
    }
}'

echo "📝 Adding MoltStack success to ASF-13..."
UPDATE_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
    -X PUT \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$UPDATE_DATA" \
    "$JIRA_URL/rest/api/2/issue/ASF-13")

HTTP_CODE="${UPDATE_RESPONSE: -3}"

if [[ "$HTTP_CODE" == "204" ]]; then
    echo "✅ MoltStack success added to ASF-13"
else
    echo "❌ Failed to update description (HTTP $HTTP_CODE)"
fi

echo ""
echo "🎉 ASF-13 Marketing Campaign Progress Updated!"
echo "📊 MoltStack: Published ✅"
echo "🐦 Twitter: Ready to post"  
echo "📧 Email: Professional identity active"
echo "🔗 Jira: $JIRA_URL/browse/ASF-13"