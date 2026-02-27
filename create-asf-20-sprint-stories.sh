#!/bin/bash

# Create ASF-20 Epic breakdown stories for immediate Sprint 2
# High priority stories for team assignment

JIRA_URL="https://jeffsutherland.atlassian.net/rest/api/2/issue/"
PROJECT_KEY="ASF"

echo "🚀 Creating ASF-20 Sprint 2 Stories..."

# ASF-21: Cross-Platform Integration API (Deploy Agent)
echo "Creating ASF-21..."
curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "ASF"},
      "summary": "ASF-21: Cross-Platform Integration API",
      "description": "Develop REST API for agent verification across platforms (Discord, Slack, Moltbook) with webhooks, authentication, and rate limiting.\n\n**Assignee:** Deploy Agent\n**Priority:** HIGH\n**Points:** 13\n\n**Acceptance Criteria:**\n- REST API endpoints for verification\n- Webhook system for real-time monitoring\n- Authentication & rate limiting\n- API documentation & testing suite\n- Integration with existing Discord bot",
      "issuetype": {"name": "Story"},
      "priority": {"name": "High"},
      "labels": ["asf-20-epic", "api-development", "platform-integration"],
      "customfield_10016": 13
    }
  }' \
  $JIRA_URL

echo -e "\n"

# ASF-25: Enterprise Sales Package (Sales Agent)
echo "Creating ASF-25..."
curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "ASF"},
      "summary": "ASF-25: Enterprise Sales Package",
      "description": "Create comprehensive enterprise sales materials and processes for ASF platform.\n\n**Assignee:** Sales Agent + Product Owner\n**Priority:** HIGH  \n**Points:** 8\n\n**Acceptance Criteria:**\n- Demo environment for prospects\n- ROI calculators and case studies\n- Pricing tiers (Starter, Pro, Enterprise)\n- Contract templates and SLAs\n- Sales process documentation",
      "issuetype": {"name": "Story"},
      "priority": {"name": "High"},
      "labels": ["asf-20-epic", "enterprise-sales", "revenue-generation"],
      "customfield_10016": 8
    }
  }' \
  $JIRA_URL

echo -e "\n"

# ASF-27: Community Growth & Advocacy (Social Agent)
echo "Creating ASF-27..."
curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "ASF"},
      "summary": "ASF-27: Community Growth & Advocacy Program",
      "description": "Expand beta tester program from current 0 to 20+ active users and build community advocacy.\n\n**Assignee:** Social Agent\n**Priority:** HIGH\n**Points:** 5\n\n**Current Status:** Discord bot LIVE, Moltbook post published, need beta testers\n\n**Acceptance Criteria:**\n- Beta tester program: 0 → 20+ users\n- Community champions recruitment\n- Social proof campaign (testimonials)\n- User-generated content strategy\n- Community feedback integration",
      "issuetype": {"name": "Story"},
      "priority": {"name": "High"},
      "labels": ["asf-20-epic", "community-growth", "beta-testing"],
      "customfield_10016": 5
    }
  }' \
  $JIRA_URL

echo -e "\n"

# ASF-29: Product Roadmap & Sprint Management (Product Owner)
echo "Creating ASF-29..."
curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "ASF"},
      "summary": "ASF-29: Product Roadmap & Sprint Management",
      "description": "Coordinate ASF-20 epic execution across 6-agent team with strategic planning.\n\n**Assignee:** Product Owner (Agent Saturday)\n**Priority:** HIGH\n**Points:** 3\n\n**Acceptance Criteria:**\n- Feature prioritization based on customer feedback\n- Team coordination via daily standups\n- Sprint planning and execution\n- Stakeholder communication\n- Cross-team dependency management",
      "issuetype": {"name": "Story"},
      "priority": {"name": "High"},
      "labels": ["asf-20-epic", "product-management", "sprint-coordination"],
      "customfield_10016": 3
    }
  }' \
  $JIRA_URL

echo -e "\n"

# ASF-22: Enterprise Dashboard (Deploy + Research)
echo "Creating ASF-22..."
curl -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "ASF"},
      "summary": "ASF-22: Enterprise Dashboard for Agent Verification",
      "description": "Build web interface for enterprise customers to monitor agent verification and security.\n\n**Assignee:** Deploy Agent + Research Agent\n**Priority:** HIGH\n**Points:** 8\n\n**Dependencies:** Requires ASF-21 API completion\n\n**Acceptance Criteria:**\n- Web interface for verification monitoring\n- Real-time bad actor alerts\n- Agent authenticity analytics\n- Export capabilities for reports\n- Multi-tenant architecture",
      "issuetype": {"name": "Story"},
      "priority": {"name": "High"},
      "labels": ["asf-20-epic", "dashboard", "enterprise-ui"],
      "customfield_10016": 8
    }
  }' \
  $JIRA_URL

echo -e "\n"

echo "✅ Created 5 high-priority ASF-20 stories!"
echo ""
echo "📋 Next Steps:"
echo "1. Assign stories to specific agents in Jira"
echo "2. Send team kickoff message with assignments"  
echo "3. Set up daily standup process"
echo "4. Create remaining stories (ASF-23 through ASF-30)"
echo ""
echo "🎯 Sprint 2 Goal: Enterprise integration + 20 beta testers"