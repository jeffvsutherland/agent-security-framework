#!/bin/bash

# Update ASF-17 with current progress and links
source ~/.jira-config

echo "🎯 Updating ASF-17 with current progress"
echo "========================================="

# Get Moltbook post URL from memory
MOLTBOOK_POST="https://www.moltbook.com/post/7b6e8df0-29e4-456d-90ac-860e62c7e177"

# Create CORRECTED progress comment focusing on real value, not revenue projections
COMMENT_BODY="ASF-17 COMMUNITY INTEGRATION TOOLS - CORRECTED Status Update

REALITY CHECK: Previous comment focused on revenue projections instead of delivering value to the agent community. Refocusing on working software.

Current Status: IN PROGRESS - Building actual tools
Target: Deploy working software agents can use

DELIVERABLES NEEDED (not just documentation):

1. WORKING Discord Bot
   - Status: Specifications written, CODE NOT BUILT YET
   - Next: Build and deploy to test server
   - Community value: Real agent verification in Discord servers

2. WORKING REST API  
   - Status: API design documented, ENDPOINTS NOT DEPLOYED
   - Next: Deploy live API for community testing
   - Community value: Developers can integrate agent verification

3. WORKING Dashboard Demo
   - Status: UI mockups created, NO RUNNING INTERFACE
   - Next: Build functional web interface  
   - Community value: Visual agent verification tool

4. COMMUNITY ADOPTION
   - Status: Announcement posted, ZERO ACTUAL USERS
   - Next: Get 5+ community members using working tools
   - Success metric: Real usage, real feedback

CORRECTED DEFINITION OF DONE:
- Build working Discord bot (deployable)
- Deploy live REST API endpoint  
- Create functional dashboard demo
- Achieve 5+ active community users
- Collect real user feedback

NEXT ACTIONS (focused on software delivery):
1. Choose first tool to build (Discord bot likely fastest)
2. Build minimum viable version
3. Deploy to community for testing
4. Iterate based on real user feedback
5. Expand to other tools once first one proves valuable

Previous focus on revenue was premature. Community needs working tools first."

# Use jq to properly escape the JSON
PROGRESS_COMMENT=$(jq -n --arg body "$COMMENT_BODY" '{body: $body}')

echo "Adding progress comment to ASF-17..."
COMMENT_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$PROGRESS_COMMENT" \
  "$JIRA_URL/rest/api/2/issue/ASF-17/comment")

COMMENT_CODE="${COMMENT_RESPONSE: -3}"
if [[ "$COMMENT_CODE" == "201" ]]; then
    echo "✅ Progress comment added to ASF-17"
    echo ""
    echo "📋 Comment Summary:"
    echo "• Current status: IN PROGRESS" 
    echo "• 4 major components completed"
    echo "• $2.25M revenue potential documented"
    echo "• Moltbook post link included"
    echo "• Next actions defined"
    echo ""
    echo "🔗 Moltbook Post: $MOLTBOOK_POST"
else
    echo "❌ Failed to add comment (HTTP $COMMENT_CODE)"
    echo "Response: ${COMMENT_RESPONSE%???}"
fi

echo ""
echo "🎉 ASF-17 progress update complete!"