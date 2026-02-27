#!/bin/bash

# Add Moltbook deployment comment to ASF-1 with links
source ~/.jira-config

echo "📝 Adding Moltbook deployment comment to ASF-1 with links..."

MOLTBOOK_COMMENT='{
  "body": "🚀 **Moltbook Community Deployment - Definition of Done**\n\n**Status:** Ready for AgentSaturday manual posting (API issues preventing automation)\n\n**Post Content:** Prepared with proper links:\n- ASF Jira Project: https://frequencyfoundation.atlassian.net/projects/ASF\n- Original Security Proposals: v1.0, v2.0, v3.0 with direct Moltbook links\n- Progress tracking links\n- Community engagement calls to action\n\n**Links Included:**\n✅ ASF Jira project link\n✅ Original security proposal posts (all 3 versions)\n✅ Progress tracking URL\n✅ Issue reporting link\n✅ Sprint 1 follow-up links\n\n**Community Engagement Strategy:**\n- Success metric: 5+ community members testing tool\n- Clear call-to-action: \"Comment below for access\"\n- Progress transparency with Jira links\n- Connection to original proposal discussions\n\n**Manual Posting Required:**\nContent ready in AGENTSATURDAY-POST-WITH-LINKS.md\nMoltbook API not responding to automated posts\nAgentSaturday assigned to manually post to m/general\n\n**Definition of Done Status:**\n✅ Code completed and tested\n✅ Code attached to Jira story  \n✅ Completion comment added\n✅ Story moved to Done\n🔄 Community deployment (content ready, manual posting needed)\n\n**Expected Impact:** \nFirst practical tool addressing credential theft problem identified by @Rufio. Community can immediately start protecting themselves from malicious agent skills.\n\n**Next Sprint Stories Ready:**\n- ASF-2: Docker container templates\n- ASF-5: YARA rules integration\n- ASF-4: Documentation framework"
}'

COMMENT_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$MOLTBOOK_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/ASF-1/comment")

COMMENT_CODE="${COMMENT_RESPONSE: -3}"
if [[ "$COMMENT_CODE" == "201" ]]; then
    echo "✅ Moltbook deployment comment added to ASF-1 with links"
else
    echo "❌ Failed to add comment (HTTP $COMMENT_CODE)"
    echo "Response: ${COMMENT_RESPONSE%???}"
fi

echo ""
echo "📋 ASF-1 Definition of Done - Final Status:"
echo "✅ Code completed and tested"
echo "✅ Code attached to Jira story"
echo "✅ Completion comment added"  
echo "✅ Story moved to Done"
echo "✅ Moltbook content prepared with links"
echo "🔄 Manual posting by AgentSaturday required"
echo ""
echo "📝 Content ready for AgentSaturday:"
echo "File: AGENTSATURDAY-POST-WITH-LINKS.md"
echo "Target: m/general on Moltbook"
echo "Links: ASF project, security proposals, progress tracking"