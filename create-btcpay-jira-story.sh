#!/bin/bash

# Create BTCPay Server Infrastructure Jira story for Frequency Foundation
source ~/.jira-config

echo "🏥 Creating BTCPay Server Infrastructure Story in FF Project"
echo "=========================================================="

# Create new story in Frequency Foundation (FF) project
STORY_DATA='{
  "fields": {
    "project": {
      "key": "FF"
    },
    "summary": "Deploy BTCPay Server with Umbrel Backend for Payment Processing",
    "description": "**BUSINESS CRITICAL: Replace broken Coinsnap payment system**\n\n**Problem:** Coinsnap payment processing is down, blocking customer Bitcoin/Lightning payments for Frequency Foundation services.\n\n**Solution:** Deploy self-hosted BTCPay Server using Jeff'\''s Umbrel node as backend.\n\n**Business Benefits:**\n• Restore customer payment processing immediately\n• Eliminate third-party payment processor fees  \n• Full custody of Bitcoin payments\n• Lightning Network support for instant payments\n• No KYC requirements for customers\n\n**Technical Architecture:**\n• BTCPay Server (self-hosted payment processor)\n• Backend: Umbrel Bitcoin Node (Jeff'\''s lab)\n• SSL-secured checkout pages\n• Webhook integration with existing website\n• Bitcoin + Lightning Network payment methods\n\n**Acceptance Criteria:**\n✅ BTCPay Server deployed and accessible via HTTPS\n✅ Connected to Umbrel node for Bitcoin blockchain data\n✅ Lightning Network integration working\n✅ Test payments processed successfully (Bitcoin + Lightning)\n✅ Webhook integration with Frequency Foundation website\n✅ SSL certificate properly configured\n✅ Payment confirmation emails working\n✅ Admin dashboard accessible for payment monitoring\n\n**Priority:** HIGH - Revenue impacting\n**Assignee:** Carlos (Web Team Developer)\n**Timeline:** 48 hours from Umbrel credentials provided\n\n**Documentation Created:**\n• BTCPAY-UMBREL-SETUP-INSTRUCTIONS.md (7,400+ words)\n• UMBREL-INFO-NEEDED-FROM-JEFF.md (configuration checklist)\n\n**Blockers:**\n• Waiting for Umbrel IP address and RPC credentials from Jeff\n• Domain name decision needed for BTCPay server\n\n**Success Metrics:**\n• Customer payments restored within 48 hours\n• Zero transaction processing fees (vs previous processor fees)\n• Lightning payments under 5-second confirmation time\n• 99.9% uptime target",
    "issuetype": {
      "name": "Story"
    },
    "priority": {
      "name": "High"
    },
    "assignee": {
      "accountId": "712020:b1c3f51f-9a90-49c7-8f1b-d5a4747b8c2f"
    },
    "labels": ["infrastructure", "payments", "bitcoin", "critical", "revenue-impact"],
    "components": [
      {
        "name": "Infrastructure"
      }
    ]
  }
}'

echo "Creating BTCPay Server story in FF project..."
CREATE_RESPONSE=$(curl -s -w "\n%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$STORY_DATA" \
  "$JIRA_URL/rest/api/2/issue")

# Extract HTTP status code (last line)
HTTP_CODE=$(echo "$CREATE_RESPONSE" | tail -n1)
STORY_RESPONSE=$(echo "$CREATE_RESPONSE" | head -n -1)

if [[ "$HTTP_CODE" == "201" ]]; then
    STORY_KEY=$(echo "$STORY_RESPONSE" | grep -o '"key":"[^"]*"' | cut -d'"' -f4)
    echo "✅ BTCPay Server story created successfully!"
    echo "📋 Story Key: $STORY_KEY"
    echo "🔗 URL: $JIRA_URL/browse/$STORY_KEY"
    
    # Add comment with technical details
    TECH_COMMENT='{
      "body": "**📋 Technical Implementation Details**\n\n**Complete Documentation Delivered:**\n• BTCPAY-UMBREL-SETUP-INSTRUCTIONS.md (7,412 bytes)\n• UMBREL-INFO-NEEDED-FROM-JEFF.md (1,383 bytes)\n\n**Architecture Overview:**\n```\nCustomer → HTTPS → BTCPay Server → Umbrel Node → Bitcoin Network\n                              └→ Lightning Network\n```\n\n**Next Steps for Carlos:**\n1. Prepare Ubuntu server with Docker\n2. Wait for Umbrel credentials from Jeff\n3. Deploy BTCPay Server with provided configuration\n4. Test Bitcoin and Lightning payments\n5. Integrate webhooks with FF website\n\n**Information Needed from Jeff:**\n• Umbrel IP address: [PENDING]\n• Bitcoin RPC username/password: [PENDING]  \n• Lightning TLS certificate and macaroon: [PENDING]\n• Preferred domain name: [PENDING]\n\n**Estimated Timeline:**\n• Setup preparation: 4 hours\n• Deployment after credentials: 6 hours\n• Testing and integration: 4 hours\n• **Total: 14 hours over 48-hour window**\n\n**Success Criteria:**\n• Replace broken Coinsnap completely\n• Restore customer payment processing\n• Zero ongoing transaction fees\n• Lightning instant payment capability"
    }'
    
    echo "Adding technical implementation comment..."
    COMMENT_RESPONSE=$(curl -s -w "%{http_code}" -u "$JIRA_USER:$JIRA_TOKEN" \
      -X POST \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "$TECH_COMMENT" \
      "$JIRA_URL/rest/api/2/issue/$STORY_KEY/comment")
    
    COMMENT_CODE="${COMMENT_RESPONSE: -3}"
    if [[ "$COMMENT_CODE" == "201" ]]; then
        echo "✅ Technical details comment added"
    else
        echo "⚠️  Story created but comment failed (HTTP $COMMENT_CODE)"
    fi
    
    echo ""
    echo "🎉 BTCPay Server infrastructure story ready for Carlos!"
    echo "📧 Story assigned to Carlos for immediate action"
    echo "⏰ 48-hour delivery target from credential handoff"
    
else
    echo "❌ Failed to create story (HTTP $HTTP_CODE)"
    echo "Response: $STORY_RESPONSE"
fi