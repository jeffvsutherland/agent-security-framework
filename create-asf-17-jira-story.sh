#!/bin/bash

# Create ASF-17 Enterprise Integration Package story in ASF project
source ~/.jira-config

echo "🏢 Creating ASF-17 Enterprise Integration Package Story"
echo "===================================================="

# Create new story in ASF project  
STORY_DATA='{
  "fields": {
    "project": {
      "key": "ASF"
    },
    "summary": "ASF-17: Enterprise Integration Package",
    "description": "**Enterprise-Grade Agent Security Framework Integration Package**\n\n**Business Opportunity:** With 1,261+ agents on Moltbook and eudaemon_0 supply chain security post at 4,354 upvotes, there is clear enterprise demand for agent security solutions.\n\n**Problem:** Current ASF tools are developer-focused. Enterprises need:\n• Platform-specific integrations (Discord, Slack, API gateways)\n• White-label deployment options\n• Enterprise licensing and support\n• Scalable infrastructure packages\n\n**Solution:** Create enterprise-ready integration package that allows platforms and organizations to deploy ASF security at scale.\n\n**Target Customers:**\n• Discord servers with AI agents\n• Slack workspaces using agent integrations\n• API platforms hosting agent services\n• Enterprise organizations adopting AI agents\n• Platform operators mentioned in ASF-13 marketing campaign\n\n**Business Benefits:**\n• Revenue generation through enterprise licensing\n• Market positioning as definitive agent security solution\n• Scalable deployment for high-volume environments\n• Professional support and consulting opportunities\n\n**Technical Components:**\n• REST API for real-time agent verification\n• Platform-specific SDKs and plugins\n• Dashboard interface for security monitoring\n• Batch processing for large agent populations\n• White-label branding capabilities\n\n**Acceptance Criteria:**\n✅ Discord Bot Integration (fake agent detection for Discord servers)\n✅ Slack App Integration (workspace agent verification)\n✅ REST API with authentication and rate limiting\n✅ Web Dashboard for security monitoring and reporting\n✅ White-label deployment package with custom branding\n✅ Enterprise licensing documentation and pricing\n✅ Professional installation and configuration guide\n✅ Support documentation and troubleshooting guide\n\n**Success Metrics:**\n• 3+ platform integrations completed and tested\n• Enterprise demo environment deployed\n• Pricing and licensing structure defined\n• Professional sales materials created\n• Reference customer identified (target: Discord/Slack community)\n\n**Dependencies:**\n• ASF-12 (Fake Agent Detection) - COMPLETE ✅\n• ASF-13 (Marketing Campaign) - COMPLETE ✅\n• ASF-14 (Certification System) - COMPLETE ✅\n• ASF-15 (Platform Integration SDK) - COMPLETE ✅\n\n**Market Context:**\n• Moltbook supply chain security discussion trending (108K+ comments)\n• Enterprise demand validated through community response\n• Competitive advantage: first-to-market comprehensive solution\n• Revenue potential: $10K-100K+ per enterprise deployment\n\n**Timeline:** 2-3 days for core integrations, 1 week for complete package",
    "issuetype": {
      "name": "Story"
    },
    "priority": {
      "name": "High"
    },
    "assignee": {
      "accountId": "70121:14326677-ddb5-47ab-bd97-8a2a5d57587f"
    },
    "labels": ["enterprise", "integration", "revenue", "platform", "security"],
    "customfield_10016": 8,
    "components": [
      {
        "name": "Enterprise"
      }
    ]
  }
}'

echo "Creating ASF-17 story in ASF project..."
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
    echo "✅ ASF-17 story created successfully!"
    echo "📋 Story Key: $STORY_KEY"
    echo "🔗 URL: $JIRA_URL/browse/$STORY_KEY"
    
    echo ""
    echo "🏢 ASF-17 Enterprise Integration Package ready for development!"
    echo "🎯 Focus: Platform integrations (Discord, Slack, API) + Enterprise licensing"
    echo "💼 Business Value: Revenue generation through enterprise deployments"
    
else
    echo "❌ Failed to create story (HTTP $HTTP_CODE)"
    echo "Response: $STORY_RESPONSE"
fi