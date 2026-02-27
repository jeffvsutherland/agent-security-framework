#!/bin/bash

# Add Definition of Done update comment to ASF-1 with direct story link requirement
source ~/.jira-config

echo "📝 Adding Definition of Done update comment to ASF-1..."

DOD_UPDATE_COMMENT='{
  "body": "🎯 **Definition of Done Update - CRITICAL REQUIREMENT**\n\n**Issue Identified:** Missing direct link to ASF-1 story in community post\n\n**Updated Requirement:** All community posts must include:\n✅ **Direct Story Link:** https://frequencyfoundation.atlassian.net/browse/ASF-1\n✅ **Project Link:** https://frequencyfoundation.atlassian.net/projects/ASF\n✅ **Original References:** Moltbook security proposals\n✅ **Issue Reporting:** Direct back to this story\n✅ **Progress Tracking:** Sprint dashboard\n\n**Updated Content:** AGENTSATURDAY-POST-FINAL.md\n- Added prominent ASF-1 story link at top\n- Added story link in progress tracking section\n- Added story link for issue reporting\n- Maintains all other required links\n\n**Why This Matters:**\n- **Transparency:** Community sees actual work item, not just project\n- **Accountability:** Direct connection between post and delivery\n- **Feedback Loop:** Issues reported to correct story\n- **Traceability:** Complete path from discussion → story → solution\n\n**Definition of Done Status:**\n✅ Code completed and tested\n✅ Code attached to Jira story\n✅ Completion comment added\n✅ Story moved to Done\n🔄 Community deployment (updated with direct story link, ready for AgentSaturday)\n\n**This becomes the standard for ALL ASF stories going forward:**\nEvery community post must include direct story link for full transparency and accountability.\n\n**Next Action:** AgentSaturday posts content from AGENTSATURDAY-POST-FINAL.md to m/general with all required links including direct ASF-1 story URL."
}'

COMMENT_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$DOD_UPDATE_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/ASF-1/comment")

COMMENT_CODE="${COMMENT_RESPONSE: -3}"
if [[ "$COMMENT_CODE" == "201" ]]; then
    echo "✅ Definition of Done update comment added to ASF-1"
else
    echo "❌ Failed to add comment (HTTP $COMMENT_CODE)"
    echo "Response: ${COMMENT_RESPONSE%???}"
fi

echo ""
echo "📋 ASF-1 Definition of Done - Updated Requirements:"
echo "✅ Code completed and tested"
echo "✅ Code attached to Jira story"
echo "✅ Completion comments added"  
echo "✅ Story moved to Done"
echo "✅ Community content prepared with DIRECT story link"
echo "🔄 Manual posting by AgentSaturday (content ready)"
echo ""
echo "🔗 CRITICAL: Direct story link included"
echo "URL: https://frequencyfoundation.atlassian.net/browse/ASF-1"
echo ""
echo "📝 Updated content ready: AGENTSATURDAY-POST-FINAL.md"