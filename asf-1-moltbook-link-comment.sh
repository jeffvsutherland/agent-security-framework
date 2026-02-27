#!/bin/bash

# Add comment to ASF-1 with Moltbook post link for Definition of Done traceability
source ~/.jira-config

echo "🔗 Adding Moltbook post link comment to ASF-1 for Definition of Done..."

MOLTBOOK_LINK_COMMENT='{
  "body": "🔗 **Definition of Done - Bidirectional Links Required**\n\n**Community Deployment Status:**\n\n**Moltbook Post:** [PENDING - AgentSaturday to post]\nOnce posted, URL will be: https://moltbook.com/post/[POST-ID]\n\n**Purpose of Bidirectional Links:**\n- Jira Story → Moltbook Post (this comment)\n- Moltbook Post → Jira Story (already included in post content)\n\n**Complete Traceability Chain:**\n1. **Original Discussion:** Security proposal posts (v1.0, v2.0, v3.0)\n2. **Work Item:** This ASF-1 story\n3. **Deliverable:** skill-evaluator.sh tool with attachments\n4. **Community Deployment:** Moltbook post (link TBD)\n5. **Feedback Loop:** Issues reported back to this story\n\n**Definition of Done Requirements:**\n✅ Code completed and tested\n✅ Code attached to Jira story\n✅ Completion comments added\n✅ Story moved to Done\n🔄 Community deployment with bidirectional links\n\n**Next Action Required:**\n1. AgentSaturday posts content from AGENTSATURDAY-POST-FINAL.md\n2. Update this comment with actual Moltbook post URL\n3. Verify bidirectional link traceability\n\n**Review Process:**\nReviewers can follow links from Jira → Moltbook → Community feedback → Back to Jira for complete story validation.\n\n**This comment will be updated with the actual Moltbook post URL once AgentSaturday completes the posting.**"
}'

COMMENT_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$MOLTBOOK_LINK_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/ASF-1/comment")

COMMENT_CODE="${COMMENT_RESPONSE: -3}"
if [[ "$COMMENT_CODE" == "201" ]]; then
    echo "✅ Moltbook link placeholder comment added to ASF-1"
else
    echo "❌ Failed to add comment (HTTP $COMMENT_CODE)"
    echo "Response: ${COMMENT_RESPONSE%???}"
fi

echo ""
echo "📋 Definition of Done - Bidirectional Links:"
echo "✅ Jira → Moltbook: Comment added (placeholder for post URL)"
echo "✅ Moltbook → Jira: Included in post content"
echo "🔄 Waiting for AgentSaturday to post and provide Moltbook URL"
echo ""
echo "📝 Next Steps:"
echo "1. AgentSaturday posts AGENTSATURDAY-POST-FINAL.md to m/general"
echo "2. Update ASF-1 comment with actual Moltbook post URL"
echo "3. Verify complete bidirectional traceability"
echo "4. Definition of Done = 100% complete"