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
    local filter_status="${1:-}"  # Optional: filter by status
    local jql="project = ASF"
    
    if [ -n "$filter_status" ]; then
        jql="$jql AND status = '$filter_status'"
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
    
    echo "📋 ASF Stories${filter_status:+ (Status: $filter_status)}:"
    echo "$response" | jq -r '.issues[] | 
        "\(.key): \(.fields.summary) [\(.fields.status.name)] \(.fields.customfield_10016 // 0) pts"'
}

echo "✅ Jira automation functions loaded. Available commands:"
echo "   - jira_create_story 'title' 'description' [points] [assignee] [priority]"
echo "   - jira_transition_story 'ASF-XX' 'In Progress'"
echo "   - jira_add_comment 'ASF-XX' 'Your comment'"
echo "   - jira_list_stories [status]"
