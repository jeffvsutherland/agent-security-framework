#!/bin/bash

# Create BTCPay Server Infrastructure Jira story for Frequency Foundation
source ~/.jira-config

echo "🏥 Creating BTCPay Server Infrastructure Story in FF Project"
echo "=========================================================="

# Simplified story creation (without assignee for now)
STORY_DATA='{
  "fields": {
    "project": {
      "key": "FF"
    },
    "summary": "Deploy BTCPay Server with Umbrel Backend for Payment Processing",
    "description": "BUSINESS CRITICAL: Replace broken Coinsnap payment system\n\nProblem: Coinsnap payment processing is down, blocking customer Bitcoin/Lightning payments for Frequency Foundation services.\n\nSolution: Deploy self-hosted BTCPay Server using Jeff Umbrel node as backend.\n\nBusiness Benefits:\n- Restore customer payment processing immediately\n- Eliminate third-party payment processor fees\n- Full custody of Bitcoin payments\n- Lightning Network support for instant payments\n- No KYC requirements for customers\n\nTechnical Architecture:\n- BTCPay Server (self-hosted payment processor)\n- Backend: Umbrel Bitcoin Node (Jeff lab)\n- SSL-secured checkout pages\n- Webhook integration with existing website\n- Bitcoin + Lightning Network payment methods\n\nAcceptance Criteria:\n- BTCPay Server deployed and accessible via HTTPS\n- Connected to Umbrel node for Bitcoin blockchain data\n- Lightning Network integration working\n- Test payments processed successfully (Bitcoin + Lightning)\n- Webhook integration with Frequency Foundation website\n- SSL certificate properly configured\n- Payment confirmation emails working\n- Admin dashboard accessible for payment monitoring\n\nPriority: HIGH - Revenue impacting\nAssignee: Carlos (Web Team Developer)\nTimeline: 48 hours from Umbrel credentials provided\n\nDocumentation Created:\n- BTCPAY-UMBREL-SETUP-INSTRUCTIONS.md (7,400+ words)\n- UMBREL-INFO-NEEDED-FROM-JEFF.md (configuration checklist)\n\nBlockers:\n- Waiting for Umbrel IP address and RPC credentials from Jeff\n- Domain name decision needed for BTCPay server\n\nSuccess Metrics:\n- Customer payments restored within 48 hours\n- Zero transaction processing fees\n- Lightning payments under 5-second confirmation time\n- 99.9% uptime target",
    "issuetype": {
      "name": "Story"
    },
    "priority": {
      "name": "High"
    }
  }
}'

echo "Creating BTCPay Server story in FF project..."
curl -u "$JIRA_USER:$JIRA_TOKEN" \
  -X POST \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$STORY_DATA" \
  "$JIRA_URL/rest/api/2/issue" | jq .

echo "✅ BTCPay Server story creation attempted"