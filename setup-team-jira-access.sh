#!/bin/bash

# ASF Team Jira Access Setup Script
# This script configures automated Jira access for all ASF team agents

echo "🔧 ASF Team Jira Access Setup"
echo "================================"

# Configuration
JIRA_URL="https://frequencyfoundation.atlassian.net"
JIRA_USER="jeff.sutherland@gmail.com"
JIRA_PROJECT="ASF"

# Check if API token is available
if [ -z "$JIRA_API_TOKEN" ]; then
    echo "❌ ERROR: JIRA_API_TOKEN environment variable not found!"
    echo ""
    echo "To fix this, add to your shell profile (~/.zshrc or ~/.bashrc):"
    echo "export JIRA_API_TOKEN='your-token-here'"
    echo ""
    echo "Get your API token from: https://id.atlassian.com/manage-profile/security/api-tokens"
    exit 1
fi

echo "✅ JIRA_API_TOKEN found"
echo ""

# Function to test Jira access
test_jira_access() {
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X GET \
        -H "Accept: application/json" \
        "${JIRA_URL}/rest/api/3/myself")
    
    local body=$(echo "$response" | sed '$d')
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "200" ]; then
        echo "✅ Jira authentication successful!"
        echo "   User: $(echo "$body" | jq -r '.displayName // .emailAddress')"
        return 0
    else
        echo "❌ Jira authentication failed (HTTP $status_code)"
        echo "   Response: $body"
        return 1
    fi
}

# Test current access
echo "🔍 Testing Jira API access..."
if test_jira_access; then
    echo ""
else
    echo ""
    echo "⚠️  Authentication failed. Please check:"
    echo "   1. API token is valid"
    echo "   2. User email is correct: $JIRA_USER"
    echo "   3. You have access to the ASF project"
    exit 1
fi

# Create automated Jira functions
echo "📝 Creating automated Jira functions..."

cat > ./jira-automation.sh << 'EOF'
#!/bin/bash

# Source this file to get Jira automation functions
# Usage: source ./jira-automation.sh

# Check required environment variables
if [ -z "$JIRA_API_TOKEN" ]; then
    echo "❌ ERROR: JIRA_API_TOKEN not set. Run setup-team-jira-access.sh first."
    return 1
fi

# Configuration
export JIRA_URL="${JIRA_URL:-https://frequencyfoundation.atlassian.net}"
export JIRA_USER="${JIRA_USER:-jeff.sutherland@gmail.com}"
export JIRA_PROJECT="${JIRA_PROJECT:-ASF}"

# Function to create a Jira story
jira_create_story() {
    local title="$1"
    local description="$2"
    local story_points="${3:-5}"
    local assignee="${4:-}"
    local priority="${5:-Medium}"
    
    if [ -z "$title" ]; then
        echo "Usage: jira_create_story 'title' 'description' [points] [assignee] [priority]"
        return 1
    fi
    
    # Map priority names
    case "$priority" in
        "High"|"HIGH"|"high") priority_id="2" ;;
        "Medium"|"MEDIUM"|"medium") priority_id="3" ;;
        "Low"|"LOW"|"low") priority_id="4" ;;
        *) priority_id="3" ;;
    esac
    
    # Build JSON payload
    local json_payload=$(jq -n \
        --arg proj "$JIRA_PROJECT" \
        --arg title "$title" \
        --arg desc "$description" \
        --arg points "$story_points" \
        --arg priority "$priority_id" \
        '{
            "fields": {
                "project": {"key": $proj},
                "summary": $title,
                "description": {
                    "type": "doc",
                    "version": 1,
                    "content": [{
                        "type": "paragraph",
                        "content": [{
                            "type": "text",
                            "text": $desc
                        }]
                    }]
                },
                "issuetype": {"name": "Story"},
                "priority": {"id": $priority},
                "customfield_10016": ($points | tonumber)
            }
        }')
    
    # Add assignee if provided
    if [ -n "$assignee" ]; then
        json_payload=$(echo "$json_payload" | jq --arg user "$assignee" '.fields.assignee = {"accountId": $user}')
    fi
    
    # Create the story
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "${JIRA_URL}/rest/api/3/issue")
    
    local body=$(echo "$response" | sed '$d')
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "201" ]; then
        local issue_key=$(echo "$body" | jq -r '.key')
        echo "✅ Created story: $issue_key - $title"
        echo "   URL: ${JIRA_URL}/browse/$issue_key"
        return 0
    else
        echo "❌ Failed to create story (HTTP $status_code)"
        echo "   Response: $body"
        return 1
    fi
}

# Function to update story status
jira_transition_story() {
    local issue_key="$1"
    local transition="$2"  # "To Do", "In Progress", "Done"
    
    if [ -z "$issue_key" ] || [ -z "$transition" ]; then
        echo "Usage: jira_transition_story 'ASF-XX' 'In Progress'"
        return 1
    fi
    
    # Get available transitions
    local transitions=$(curl -s \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X GET \
        -H "Accept: application/json" \
        "${JIRA_URL}/rest/api/3/issue/${issue_key}/transitions")
    
    # Find transition ID
    local transition_id=$(echo "$transitions" | jq -r ".transitions[] | select(.name == \"$transition\") | .id")
    
    if [ -z "$transition_id" ]; then
        echo "❌ Transition '$transition' not found. Available transitions:"
        echo "$transitions" | jq -r '.transitions[].name'
        return 1
    fi
    
    # Execute transition
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"transition\": {\"id\": \"$transition_id\"}}" \
        "${JIRA_URL}/rest/api/3/issue/${issue_key}/transitions")
    
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "204" ]; then
        echo "✅ Transitioned $issue_key to $transition"
        return 0
    else
        echo "❌ Failed to transition story (HTTP $status_code)"
        return 1
    fi
}

# Function to add comment to story
jira_add_comment() {
    local issue_key="$1"
    local comment="$2"
    
    if [ -z "$issue_key" ] || [ -z "$comment" ]; then
        echo "Usage: jira_add_comment 'ASF-XX' 'Your comment here'"
        return 1
    fi
    
    local json_payload=$(jq -n --arg comment "$comment" '{
        "body": {
            "type": "doc",
            "version": 1,
            "content": [{
                "type": "paragraph",
                "content": [{
                    "type": "text",
                    "text": $comment
                }]
            }]
        }
    }')
    
    local response=$(curl -s -w "\n%{http_code}" \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$json_payload" \
        "${JIRA_URL}/rest/api/3/issue/${issue_key}/comment")
    
    local status_code=$(echo "$response" | tail -n1)
    
    if [ "$status_code" = "201" ]; then
        echo "✅ Added comment to $issue_key"
        return 0
    else
        echo "❌ Failed to add comment (HTTP $status_code)"
        return 1
    fi
}

# Function to list ASF stories
jira_list_stories() {
    local status="${1:-}"  # Optional: filter by status
    local jql="project = ASF"
    
    if [ -n "$status" ]; then
        jql="$jql AND status = '$status'"
    fi
    
    jql="$jql ORDER BY created DESC"
    
    local response=$(curl -s \
        -u "${JIRA_USER}:${JIRA_API_TOKEN}" \
        -X GET \
        -H "Accept: application/json" \
        -G \
        --data-urlencode "jql=$jql" \
        --data-urlencode "fields=summary,status,customfield_10016,assignee" \
        "${JIRA_URL}/rest/api/3/search")
    
    echo "📋 ASF Stories${status:+ (Status: $status)}:"
    echo "$response" | jq -r '.issues[] | 
        "\(.key): \(.fields.summary) [\(.fields.status.name)] \(.fields.customfield_10016 // 0) pts"'
}

echo "✅ Jira automation functions loaded. Available commands:"
echo "   - jira_create_story 'title' 'description' [points] [assignee] [priority]"
echo "   - jira_transition_story 'ASF-XX' 'In Progress'"
echo "   - jira_add_comment 'ASF-XX' 'Your comment'"
echo "   - jira_list_stories [status]"
EOF

chmod +x ./jira-automation.sh

# Create Sprint 2 story creation script
echo "📝 Creating Sprint 2 automation script..."

cat > ./create-asf-sprint2-stories-automated.sh << 'EOF'
#!/bin/bash

# Source the automation functions
source ./jira-automation.sh || exit 1

echo "🚀 Creating ASF Sprint 2 Stories"
echo "================================"

# Story details from team estimates
declare -a stories=(
    "ASF-21|Cross-Platform Integration API|13|Deploy Agent|High|Create enterprise-ready API for multi-platform ASF integration"
    "ASF-22|Enterprise Dashboard|8|Deploy Agent|Medium|Build enterprise dashboard for agent monitoring"
    "ASF-23|Advanced Detection Algorithm|8|Research Agent|High|Machine learning for fake agent detection"
    "ASF-24|Competitive Intelligence|5|Research Agent|Medium|Monitor fake agent threat landscape"
    "ASF-25|Enterprise Sales Package|8|Sales Agent|High|Create comprehensive enterprise sales materials"
    "ASF-26|Partnership & Integration Program|5|Sales Agent|Medium|Build reseller and platform partnership network"
    "ASF-27|Community Growth & Advocacy|5|Social Agent|High|Grow from 0 to 20+ beta testers"
    "ASF-28|Thought Leadership Campaign|5|Social Agent|Medium|Establish ASF as industry thought leader"
    "ASF-29|Product Roadmap & Sprint Management|3|Agent Saturday|High|Strategic product management and coordination"
    "ASF-30|QA & Operations|5|Deploy Agent|Medium|Quality assurance and operational excellence"
)

# Create each story
for story in "${stories[@]}"; do
    IFS='|' read -r key title points assignee priority description <<< "$story"
    echo ""
    echo "Creating $key..."
    jira_create_story "$title" "$description" "$points" "" "$priority"
    sleep 1  # Rate limiting
done

echo ""
echo "✅ Sprint 2 story creation complete!"
echo ""
echo "Next steps:"
echo "1. Assign stories to specific agent account IDs"
echo "2. Add stories to Sprint 2"
echo "3. Send kickoff messages to agents"
EOF

chmod +x ./create-asf-sprint2-stories-automated.sh

# Create agent configuration file
cat > ./asf-team-jira-config.json << 'EOF'
{
  "project": "ASF",
  "jira_url": "https://frequencyfoundation.atlassian.net",
  "agents": {
    "deploy": {
      "name": "ASF Deploy Agent",
      "telegram_id": "TBD",
      "jira_account_id": "TBD",
      "assigned_stories": ["ASF-21", "ASF-22", "ASF-30"]
    },
    "research": {
      "name": "ASF Research Agent", 
      "telegram_id": "TBD",
      "jira_account_id": "TBD",
      "assigned_stories": ["ASF-22", "ASF-23", "ASF-24"]
    },
    "sales": {
      "name": "ASF Sales Agent",
      "telegram_id": "TBD",
      "jira_account_id": "TBD",
      "assigned_stories": ["ASF-25", "ASF-26"]
    },
    "social": {
      "name": "ASF Social Agent",
      "telegram_id": "TBD",
      "jira_account_id": "TBD", 
      "assigned_stories": ["ASF-27", "ASF-28"]
    },
    "product_owner": {
      "name": "Agent Saturday",
      "telegram_id": "@AgentSaturday",
      "jira_account_id": "TBD",
      "assigned_stories": ["ASF-28", "ASF-29", "ASF-30"]
    }
  },
  "sprint_2": {
    "start_date": "2026-02-17",
    "end_date": "2026-03-03",
    "total_points": 67,
    "goals": [
      "Enterprise API with 3+ integrations",
      "20+ beta testers recruited",
      "5+ enterprise prospects",
      "2+ partnerships signed"
    ]
  }
}
EOF

echo ""
echo "✅ Setup complete! Created:"
echo "   - jira-automation.sh (core functions)"
echo "   - create-asf-sprint2-stories-automated.sh (Sprint 2 stories)"
echo "   - asf-team-jira-config.json (team configuration)"
echo ""
echo "🔧 To use the automation:"
echo "   1. source ./jira-automation.sh"
echo "   2. Run any jira_* function"
echo ""
echo "📊 To create Sprint 2 stories:"
echo "   ./create-asf-sprint2-stories-automated.sh"
echo ""
echo "⚠️  Note: You'll need to get agent Jira account IDs for assignee mapping"